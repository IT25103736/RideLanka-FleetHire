$ErrorActionPreference = "Continue"
$BASE = "http://localhost:8080"
$pass = 0
$fail = 0
$fails = @()

function Check {
    param([string]$Name, [bool]$Ok, [string]$Detail = "")
    if ($Ok) {
        Write-Host "  [PASS] $Name" -ForegroundColor Green
        $script:pass++
    } else {
        Write-Host "  [FAIL] $Name $Detail" -ForegroundColor Red
        $script:fail++
        $script:fails += "$Name $Detail"
    }
}

function Get-Url {
    param([string]$Url, $Session, [int]$MaxRedir = 0)
    try {
        return Invoke-WebRequest -Uri $Url -Method Get -WebSession $Session -UseBasicParsing -MaximumRedirection $MaxRedir -ErrorAction SilentlyContinue -TimeoutSec 15
    } catch {
        $err = $_.Exception.Response
        if ($err) { return [PSCustomObject]@{ StatusCode = [int]$err.StatusCode; Content = ""; Headers = $err.Headers } }
        return [PSCustomObject]@{ StatusCode = 0; Content = "" }
    }
}

function Post-Form {
    param([string]$Url, [hashtable]$Body, $Session, [int]$MaxRedir = 0)
    try {
        return Invoke-WebRequest -Uri $Url -Method Post -Body $Body -WebSession $Session -UseBasicParsing -MaximumRedirection $MaxRedir -ErrorAction SilentlyContinue -TimeoutSec 15
    } catch {
        $err = $_.Exception.Response
        if ($err) { return [PSCustomObject]@{ StatusCode = [int]$err.StatusCode; Content = "" } }
        return [PSCustomObject]@{ StatusCode = 0; Content = "" }
    }
}

Write-Host "=== VRMS Fix Verification ===" -ForegroundColor Cyan

# Log in as the seeded U002 (Kamal) so we have known bookings to use.
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$r = Post-Form -Url "$BASE/user/login" -Body @{ email = "kamal@example.com"; password = "password" } -Session $session
Check "Login as U002 Kamal" ($r.StatusCode -eq 302) "status=$($r.StatusCode)"

# ----------------------------------------------------------------
# FIX #1 — Checkout amount bug
# ----------------------------------------------------------------
Write-Host "`n[FIX #1] Checkout amount + booking guard" -ForegroundColor Yellow

# 1a. No bookingId → must redirect to /booking?action=list
$r = Get-Url -Url "$BASE/payment/checkout" -Session $session
$loc = if ($r.Headers) { $r.Headers["Location"] } else { $null }
Check "GET /payment/checkout (no params) redirects" ($r.StatusCode -eq 302) "status=$($r.StatusCode)"
Check "  Redirect target is /booking?action=list" (($loc -match "/booking.action=list")) "loc=$loc"

# 1b. Bogus bookingId → also redirect (booking not found)
$r = Get-Url -Url "$BASE/payment/checkout?bookingId=DOES_NOT_EXIST&amount=100" -Session $session
Check "GET /payment/checkout?bookingId=bogus redirects" ($r.StatusCode -eq 302) "status=$($r.StatusCode)"

# 1c. amount=0 → redirect (refuses to render free-checkout page)
$r = Get-Url -Url "$BASE/payment/checkout?bookingId=B001&amount=0" -Session $session
Check "GET /payment/checkout?amount=0 redirects" ($r.StatusCode -eq 302) "status=$($r.StatusCode)"

# 1d. Valid booking + amount → renders with the right booking + amount, NOT zero
$r = Get-Url -Url "$BASE/payment/checkout?bookingId=B001&amount=27500&customerName=Kamal+Perera" -Session $session
Check "GET /payment/checkout (valid) renders 200" ($r.StatusCode -eq 200) "status=$($r.StatusCode)"
Check "  Page shows the real booking ID B001" ($r.Content -match "B001")
Check "  Page shows LKR 27,500.00 (2-decimal)" ($r.Content -match "27,500\.00")
Check "  Page does NOT show 'LKR 0' as total" (-not ($r.Content -match "<sup>LKR</sup>0(?!\d)"))

# 1e. POST /payment/process with amount=0 must NOT create a payment
$beforeCount = (Get-Content data/payments.txt | Measure-Object -Line).Lines
$r = Post-Form -Url "$BASE/payment/process" -Body @{
    bookingId = "B001"; paymentMethod = "card"; customerName = "Kamal Perera"; amount = "0"
    cardHolderName = "Test"; cardNumber = "4111111111111111"; expiryDate = "12/27"; cvv = "123"
} -Session $session
$afterCount = (Get-Content data/payments.txt | Measure-Object -Line).Lines
Check "POST /payment/process amount=0 blocked" ($r.StatusCode -eq 200) "status=$($r.StatusCode)"
Check "  Server returned the checkout page with errorMsg" ($r.Content -match "couldn't find a booking|errorMsg|ck-alert--err")
Check "  payments.txt unchanged ($beforeCount lines)" ($afterCount -eq $beforeCount) "before=$beforeCount after=$afterCount"

# 1f. POST /payment/process with empty bookingId blocked
$r = Post-Form -Url "$BASE/payment/process" -Body @{
    bookingId = ""; paymentMethod = "card"; customerName = "Kamal Perera"; amount = "12000"
    cardHolderName = "Test"; cardNumber = "4111111111111111"; expiryDate = "12/27"; cvv = "123"
} -Session $session
$afterCount2 = (Get-Content data/payments.txt | Measure-Object -Line).Lines
Check "POST /payment/process empty bookingId blocked" ($r.StatusCode -eq 200) "status=$($r.StatusCode)"
Check "  payments.txt still unchanged" ($afterCount2 -eq $beforeCount) "before=$beforeCount after=$afterCount2"

# ----------------------------------------------------------------
# FIX #2 — Wallet input must accept only digits (client-side JS check)
# ----------------------------------------------------------------
Write-Host "`n[FIX #2] Wallet input digit-only" -ForegroundColor Yellow

$r = Get-Url -Url "$BASE/payment/checkout?bookingId=B001&amount=27500&customerName=Kamal+Perera" -Session $session
# The <input id="walletNumber" ...> tag is split across multiple lines in the JSP — collapse
# whitespace so the regex spans the whole tag.
$flat = $r.Content -replace '\s+', ' '
$tagMatch = [regex]::Match($flat, '<input[^>]*id="walletNumber"[^>]*>')
$walletTag = if ($tagMatch.Success) { $tagMatch.Value } else { '' }
Check "Wallet input has digit-strip oninput" ([bool]($walletTag -match "oninput=`"this.value=this.value.replace")) "tag=$walletTag"
Check "Wallet input has inputmode=numeric"   ([bool]($walletTag -match 'inputmode="numeric"'))
Check "Wallet input has pattern=[0-9]*"      ([bool]($walletTag -match 'pattern="\[0-9\]\*"'))
Check "Wallet input has maxlength=10"        ([bool]($walletTag -match 'maxlength="10"'))

# ----------------------------------------------------------------
# FIX #3 — Invoice details
# ----------------------------------------------------------------
Write-Host "`n[FIX #3] Invoice shows vehicle + dates" -ForegroundColor Yellow

# Create a brand-new booking so we have a known one to pay for. Use ADVANCE (>=7 days
# out) so the post returns the confirmation page with the booking id in the response
# body. INSTANT now redirects straight to checkout, hiding the id in the Location header.
$offset = Get-Random -Minimum 4000 -Maximum 9000
$r = Post-Form -Url "$BASE/booking" -Body @{
    vehicleId      = "CAR001"
    startDate      = (Get-Date).AddDays($offset).ToString("yyyy-MM-dd")
    duration       = "4"
    dailyRate      = "5000"
    bookingType    = "advance"
    acceptTerms    = "true"
    customerName   = "Kamal Perera"
    pickupLocation = "Colombo"
    pickupTime     = "10:00"
} -Session $session -MaxRedir 5
$newBookingId = $null
if ($r.Content -match '(B\d{10,})') { $newBookingId = $matches[1] }
Check "Created new test booking" ($null -ne $newBookingId) "id=$newBookingId"

if ($newBookingId) {
    # Pay for it
    $r = Post-Form -Url "$BASE/payment/process" -Body @{
        bookingId      = $newBookingId
        paymentMethod  = "card"
        customerName   = "Kamal Perera"
        amount         = "32700"
        cardHolderName = "Kamal Perera"
        cardNumber     = "4111111111111111"
        expiryDate     = "12/27"
        cvv            = "123"
    } -Session $session -MaxRedir 5
    Check "POST /payment/process renders invoice" ($r.StatusCode -eq 200) "status=$($r.StatusCode)"
    Check "  Invoice shows real vehicle ID CAR001"   ($r.Content -match "CAR001")
    Check "  Invoice shows booking ID $newBookingId" ($r.Content -match $newBookingId)
    Check "  Invoice does NOT show 'Vehicle Rental dash dash'" ([bool](-not ($r.Content -match "Vehicle Rental &mdash; &mdash;")))
    Check "  Invoice shows LKR 32,700.00 (2-decimal)" ($r.Content -match "LKR 32,700\.00")
    Check "  Invoice shows the start date"            ($r.Content -match (Get-Date).AddDays($offset).ToString("yyyy-MM-dd"))
    Check "  Invoice shows duration 4 days"           ($r.Content -match "(?s)Qty.*?4")
}

# ----------------------------------------------------------------
# FIX #4 — Notification bell removed from header
# ----------------------------------------------------------------
Write-Host "`n[FIX #4] Notification bell removed" -ForegroundColor Yellow
$r = Get-Url -Url "$BASE/dashboard" -Session $session
Check "Dashboard does not contain Notifications button" (-not ($r.Content -match 'title="Notifications"'))
Check "Dashboard does not contain ti-bell icon"         (-not ($r.Content -match 'class="ti ti-bell"'))

# ----------------------------------------------------------------
# FIX #5 — paymentList Date column nowrap
# ----------------------------------------------------------------
Write-Host "`n[FIX #5] paymentList date column nowrap" -ForegroundColor Yellow

# Sign in as admin first so we can see /payment/list
$adminSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$r = Post-Form -Url "$BASE/user/login" -Body @{ email = "admin@vrms.lk"; password = "admin123" } -Session $adminSession
Check "Login as admin" ($r.StatusCode -eq 302) "status=$($r.StatusCode)"

$r = Get-Url -Url "$BASE/payment/list" -Session $adminSession
Check "GET /payment/list renders 200" ($r.StatusCode -eq 200) "status=$($r.StatusCode)"
Check "  Page declares .pl-nowrap class" ($r.Content -match "\.pl-nowrap\s*\{\s*white-space:\s*nowrap")
Check "  Date cells use pl-nowrap"       ($r.Content -match 'class="pl-mono pl-nowrap"')

# ----------------------------------------------------------------
# FIX #6 — Currency formatting 2-decimal
# ----------------------------------------------------------------
Write-Host "`n[FIX #6] LKR formatted to 2 decimals" -ForegroundColor Yellow

# Payment list amount column should now show #.##0.00, not "17500.0"
Check "  paymentList amounts use 2 decimals"  ($r.Content -match "LKR</span>\s*17,500\.00")
Check "  paymentList no naked '17500.0'"      (-not ($r.Content -match "LKR</span>\s+17500\.0(?!\d)"))

# Vehicle list (admin)
$r2 = Get-Url -Url "$BASE/vehicle?action=list" -Session $adminSession
Check "  vehicle-list price uses 2 decimals" ($r2.Content -match "LKR</span>\s*[\d,]+\.\d{2}")

# Vehicle search results (public) — same /search route, with a filter that triggers result rendering
$r3 = Get-Url -Url "$BASE/search?vehicleType=Car" -Session $session -MaxRedir 5
$flat3 = $r3.Content -replace '\s+', ' '
Check "  search-results price uses 2 decimals" ([bool]($flat3 -match "<sup>LKR</sup>[\d,]+\.\d{2}"))

# Admin revenue
$r4 = Get-Url -Url "$BASE/admin/revenue" -Session $adminSession
Check "  admin-revenue total uses 2 decimals" ($r4.Content -match "<sup>LKR</sup><span[^>]*>[\d,]+\.\d{2}|<sup>LKR</sup>[\d,]+\.\d{2}")

# ----------------------------------------------------------------
# FIX #7 — My Payments shows Pending + Paid bookings with actions
# ----------------------------------------------------------------
Write-Host "`n[FIX #7] My Payments page -- booking-centric view" -ForegroundColor Yellow

# Create a fresh ADVANCE booking with pickup so it lands as PENDING in myPayments.
# (After the data migration, Kamal has no seed pending bookings -- everything was
#  cancelled or paid -- so we manufacture one to exercise the pending-row UI.)
$mpOffset = Get-Random -Minimum 200 -Maximum 600
$mpStart = (Get-Date).AddDays($mpOffset).ToString("yyyy-MM-dd")
$rNew = Post-Form -Url "$BASE/booking" -Body @{
    vehicleId      = "CAR001"
    startDate      = $mpStart
    duration       = "3"
    dailyRate      = "5000"
    bookingType    = "advance"
    acceptTerms    = "true"
    customerName   = "Kamal Perera"
    pickupLocation = "Colombo"
    pickupTime     = "13:00"
} -Session $session -MaxRedir 5
$pendingBid = $null
if ($rNew.Content -match '(B\d{10,})') { $pendingBid = $matches[1] }
Check "Created pending advance booking for myPayments test" ([bool]$pendingBid) "id=$pendingBid"

$r = Get-Url -Url "$BASE/payment/history" -Session $session
$flat = $r.Content -replace '\s+', ' '
Check "GET /payment/history renders 200" ($r.StatusCode -eq 200) "status=$($r.StatusCode)"
Check "  Has 'Pending payments' section"        ([bool]($flat -match 'Pending payments'))
Check "  Has 'Paid bookings' section"           ([bool]($flat -match 'Paid bookings'))
Check "  Has B001 row marked as paid"           ([bool]($flat -match 'B001.*?PAY001|PAY001.*?B001'))
Check "  New pending booking visible"           ([bool]($flat -match $pendingBid))
Check "  Pending row shows 'Pay now' CTA"       ([bool]($flat -match 'Pay now'))
Check "  Pending row shows 'Cancel' button"     ([bool]($flat -match 'mp-btn--cancel'))
$payNowPattern = '/payment/checkout\?bookingId=' + [regex]::Escape($pendingBid) + '&amount=\d'
Check "  Pay-now URL carries computed amount"   ([bool]($flat -match $payNowPattern))
Check "  Total spent stat shows non-zero LKR"   ([bool]($flat -match 'Total spent.*?LKR.*?[1-9]'))
Check "  Pending count visible"                 ([bool]($flat -match 'Pending</div>\s*<div[^>]*>\s*[1-9]'))

# Verify a fresh payment now writes bookingId on the line
$beforeLines = Get-Content data/payments.txt
$offset = Get-Random -Minimum 4000 -Maximum 9000
$r = Post-Form -Url "$BASE/booking" -Body @{
    vehicleId      = "BIKE001"
    startDate      = (Get-Date).AddDays($offset).ToString("yyyy-MM-dd")
    duration       = "2"
    dailyRate      = "2000"
    bookingType    = "instant"
    acceptTerms    = "true"
    customerName   = "Kamal Perera"
    pickupLocation = "Kandy"
    pickupTime     = "12:00"
} -Session $session -MaxRedir 5
$newBid = $null
if ($r.Content -match '(B\d{10,})') { $newBid = $matches[1] }

if ($newBid) {
    $r = Post-Form -Url "$BASE/payment/process" -Body @{
        bookingId      = $newBid
        paymentMethod  = "card"
        customerName   = "Kamal Perera"
        amount         = "11700"
        cardHolderName = "Kamal Perera"
        cardNumber     = "4111111111111111"
        expiryDate     = "12/27"
        cvv            = "123"
    } -Session $session -MaxRedir 5
    $afterLines = Get-Content data/payments.txt
    $newLine = $afterLines | Where-Object { $_ -notin $beforeLines } | Select-Object -First 1
    Check "New payment line written"               ([bool]$newLine) "line=$newLine"
    $endPattern = '\|' + [regex]::Escape($newBid) + '$'
    Check "  New payment line ends with bookingId" ([bool]($newLine -match $endPattern)) "pattern=$endPattern"

    # And the new payment shows up in the Paid section
    $r = Get-Url -Url "$BASE/payment/history" -Session $session
    $flat2 = $r.Content -replace '\s+', ' '
    Check "  New paid booking visible in 'Paid bookings'" ([bool]($flat2 -match $newBid))
}

# Anonymous request still redirects to login
$r = Get-Url -Url "$BASE/payment/history" -Session (New-Object Microsoft.PowerShell.Commands.WebRequestSession)
Check "Anon GET /payment/history redirects to login" ($r.StatusCode -eq 302) "status=$($r.StatusCode)"

# Sidebar nav points to /payment/history (not /payment/checkout) for regular users
$r = Get-Url -Url "$BASE/dashboard" -Session $session
Check "Sidebar Payments link is /payment/history" ([bool]($r.Content -match "/payment/history"))
Check "Sidebar no longer carries /payment/checkout user-nav" ([bool](-not ($r.Content -match 'href="[^"]*?/payment/checkout"[^>]*?class="nav-item')))

# ----------------------------------------------------------------
# FIX #8 -- Pickup location/time + instant->checkout + advance 7d rule
# ----------------------------------------------------------------
Write-Host "`n[FIX #8] Pickup details + instant-pay-now + advance 7d lead" -ForegroundColor Yellow

# 8a. Booking form exposes pickup dropdowns + advance lead-day notice
$rForm = Get-Url -Url "$BASE/booking?action=form" -Session $session
$flatForm = $rForm.Content -replace '\s+', ' '
Check "Booking form has pickupLocation select"      ([bool]($flatForm -match 'name="pickupLocation"'))
Check "  Colombo option present"                    ([bool]($flatForm -match '>Colombo<'))
Check "  Kandy option present"                      ([bool]($flatForm -match '>Kandy<'))
Check "Booking form has pickupTime select"          ([bool]($flatForm -match 'name="pickupTime"'))
Check "  09:00 time slot present"                   ([bool]($flatForm -match '>09:00<'))
Check "  21:00 time slot present"                   ([bool]($flatForm -match '>21:00<'))
Check "Form mentions advance 7-day rule"            ([bool]($flatForm -match 'at least <strong>7 days</strong>'))

# 8b. Missing pickup is rejected
$offset = Get-Random -Minimum 4000 -Maximum 9000
$r = Post-Form -Url "$BASE/booking" -Body @{
    vehicleId    = "CAR001"
    startDate    = (Get-Date).AddDays($offset).ToString("yyyy-MM-dd")
    duration     = "2"
    dailyRate    = "5000"
    bookingType  = "instant"
    acceptTerms  = "true"
    customerName = "Kamal Perera"
    # pickupLocation + pickupTime intentionally omitted
} -Session $session -MaxRedir 0
Check "POST /booking without pickup is rejected" ([bool]($r.Content -match 'pick-up location'))

# 8c. Advance booking less than 7 days out is rejected
$nearStart = (Get-Date).AddDays(3).ToString("yyyy-MM-dd")
$r = Post-Form -Url "$BASE/booking" -Body @{
    vehicleId      = "CAR001"
    startDate      = $nearStart
    duration       = "2"
    dailyRate      = "5000"
    bookingType    = "advance"
    acceptTerms    = "true"
    customerName   = "Kamal Perera"
    pickupLocation = "Colombo"
    pickupTime     = "10:00"
} -Session $session -MaxRedir 0
Check "POST /booking advance <7 days out rejected" ([bool]($r.Content -match 'at least 7 days'))

# 8d. Instant booking redirects to /payment/checkout (not the confirmation page)
$farOffset = Get-Random -Minimum 9000 -Maximum 11000
$farStart = (Get-Date).AddDays($farOffset).ToString("yyyy-MM-dd")
$r = Post-Form -Url "$BASE/booking" -Body @{
    vehicleId      = "CAR001"
    startDate      = $farStart
    duration       = "3"
    dailyRate      = "5000"
    bookingType    = "instant"
    acceptTerms    = "true"
    customerName   = "Kamal Perera"
    pickupLocation = "Colombo"
    pickupTime     = "14:00"
} -Session $session -MaxRedir 0
$loc = if ($r.Headers) { $r.Headers["Location"] } else { "" }
Check "POST /booking instant -> 302" ($r.StatusCode -eq 302) "status=$($r.StatusCode)"
Check "  Redirect lands on /payment/checkout" ([bool]($loc -match '/payment/checkout\?bookingId=B\d+&amount=\d'))

# Extract the created bookingId from the redirect Location and follow through to checkout
$instantBid = $null
if ($loc -match 'bookingId=(B\d+)') { $instantBid = $matches[1] }
Check "  Created instant booking id captured" ([bool]$instantBid) "id=$instantBid"

if ($instantBid) {
    $r = Get-Url -Url "$BASE/payment/checkout?bookingId=$instantBid&amount=27600" -Session $session
    Check "  Checkout for new instant renders 200" ($r.StatusCode -eq 200) "status=$($r.StatusCode)"
    Check "    Checkout page shows the new booking id" ([bool]($r.Content -match $instantBid))
}

# 8e. Advance booking >=7 days out succeeds + lands on confirmation page (not redirect)
$advOffset = Get-Random -Minimum 30 -Maximum 200
$advStart = (Get-Date).AddDays($advOffset).ToString("yyyy-MM-dd")
$r = Post-Form -Url "$BASE/booking" -Body @{
    vehicleId      = "CAR001"
    startDate      = $advStart
    duration       = "2"
    dailyRate      = "5000"
    bookingType    = "advance"
    acceptTerms    = "true"
    customerName   = "Kamal Perera"
    pickupLocation = "Kandy"
    pickupTime     = "11:00"
} -Session $session -MaxRedir 0
Check "POST /booking advance(>=7d) returns confirmation 200" ($r.StatusCode -eq 200) "status=$($r.StatusCode)"
$advBid = $null
if ($r.Content -match '(B\d{10,})') { $advBid = $matches[1] }
Check "  Advance booking id present in confirmation" ([bool]$advBid)
$flatConf = $r.Content -replace '\s+', ' '
Check "  Confirmation shows pickup Kandy / 11:00"   ([bool]($flatConf -match 'Kandy.*?11:00|11:00.*?Kandy'))

# 8f. bookings.txt advance booking row carries pickup fields
if ($advBid) {
    $line = (Get-Content data/bookings.txt | Where-Object { $_ -match [regex]::Escape($advBid) }) | Select-Object -First 1
    Check "  Advance booking row written"                ([bool]$line) "line=$line"
    Check "  Advance row contains |Kandy|11:00 tail"     ([bool]($line -match '\|Kandy\|11:00$'))
}

# 8g. Migration: B002/B004 (advance no pickup) + B006 are now CANCELLED in data
$bk = Get-Content data/bookings.txt
Check "Migration: B002 advance->CANCELLED" ([bool](($bk -match '^B002\|') -match 'CANCELLED'))
Check "Migration: B004 advance->CANCELLED" ([bool](($bk -match '^B004\|') -match 'CANCELLED'))
Check "Migration: B006 advance->CANCELLED" ([bool](($bk -match '^B006\|') -match 'CANCELLED'))
Check "Migration: B001 instant paid kept ACTIVE" ([bool](($bk -match '^B001\|') -match 'ACTIVE'))
Check "Migration: B001 instant has pickup details" ([bool](($bk -match '^B001\|') -match 'Colombo\|10:00'))

# 8h. myPayments shows pickup info on rows
$r = Get-Url -Url "$BASE/payment/history" -Session $session
$flatMP = $r.Content -replace '\s+', ' '
Check "myPayments has pickup map-pin icon"       ([bool]($flatMP -match 'ti-map-pin'))
Check "myPayments displays Colombo or Kandy pickup" ([bool]($flatMP -match '(Colombo|Kandy)\s*&middot;\s*<span class="mp-mono">\d\d:\d\d'))

# 8i. Admin dashboard recent reservations has Pick-up column (use admin session since
#     /dashboard now splits by role — regular users land on userDashboard.jsp)
$r = Get-Url -Url "$BASE/dashboard" -Session $adminSession
$flatDB = $r.Content -replace '\s+', ' '
Check "Admin dashboard recent reservations has Pick-up column" ([bool]($flatDB -match '<th>Pick-up</th>'))
Check "Admin dashboard quick action points to /payment/history" ([bool]($flatDB -match '/payment/history" class="ds-action'))

# ----------------------------------------------------------------
# FIX #9 -- Admin/user dashboard split, vehicle add hardening, images, ledger removal
# ----------------------------------------------------------------
Write-Host "`n[FIX #9] Dashboard split + vehicle add + images + ledger removal" -ForegroundColor Yellow

# Need an admin session for the admin checks
$adminSession2 = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$r = Post-Form -Url "$BASE/user/login" -Body @{ email = "admin@vrms.lk"; password = "admin123" } -Session $adminSession2
Check "Admin login for FIX #9 checks" ($r.StatusCode -eq 302) "status=$($r.StatusCode)"

# 9a. Admin dashboard is the analytics view (has Members + Revenue stat) and NO System ledger
$rAdmin = Get-Url -Url "$BASE/dashboard" -Session $adminSession2
$flatAdmin = $rAdmin.Content -replace '\s+', ' '
Check "Admin dashboard renders 200"             ($rAdmin.StatusCode -eq 200) "status=$($rAdmin.StatusCode)"
Check "  Admin shows analytics (Members card)"  ([bool]($flatAdmin -match 'Members</span'))
Check "  Admin shows Total vehicles stat"       ([bool]($flatAdmin -match 'Total vehicles'))
Check "  Admin does NOT have System ledger"     ([bool](-not ($flatAdmin -match 'System ledger')))
Check "  Admin does NOT have C01..C06 ledger refs" ([bool](-not ($flatAdmin -match 'class="ds-comp">C0\d')))

# 9b. User dashboard differs from admin -- no admin analytics, has pickup/recommended sections
$rUser = Get-Url -Url "$BASE/dashboard" -Session $session
$flatUser = $rUser.Content -replace '\s+', ' '
Check "User dashboard renders 200"              ($rUser.StatusCode -eq 200) "status=$($rUser.StatusCode)"
Check "  User dashboard greets the user"        ([bool]($flatUser -match 'Hello,\s*<em>Kamal'))
Check "  User dashboard has Pending payments"   ([bool]($flatUser -match 'Pending payments'))
Check "  User dashboard has Paid bookings"      ([bool]($flatUser -match 'Paid bookings'))
Check "  User dashboard has Recommended"        ([bool]($flatUser -match 'Recommended for you'))
Check "  User dashboard does NOT show 'Members' admin card" ([bool](-not ($flatUser -match 'Registered drivers')))
Check "  User dashboard does NOT show 'Total revenue'"      ([bool](-not ($flatUser -match 'Total revenue')))

# 9c. Vehicle add error handling -- bad year should re-render form with banner (not 500)
$r = Post-Form -Url "$BASE/vehicle" -Body @{
    action = "add"; vehicleId = "VTEST1"; type = "Car"; brand = "Toyota"; model = "Test"
    year = ""; rentalPricePerDay = "5000"; available = "true"; extraField = "5"
} -Session $adminSession2 -MaxRedir 0
$flat = $r.Content -replace '\s+', ' '
Check "POST /vehicle bad year returns 200 (form re-render)" ($r.StatusCode -eq 200) "status=$($r.StatusCode)"
Check "  Form re-render shows friendly error banner" ([bool]($flat -match "Couldn't save:.*Year is required"))
Check "  Submitted brand value is preserved"         ([bool]($flat -match 'name="brand"[^>]*value="Toyota"'))

# 9d. Vehicle add error handling -- non-numeric extraField re-renders form (not silent drop)
$r = Post-Form -Url "$BASE/vehicle" -Body @{
    action = "add"; vehicleId = "VTEST2"; type = "Car"; brand = "Toyota"; model = "Test"
    year = "2025"; rentalPricePerDay = "5000"; available = "true"; extraField = "abc"
} -Session $adminSession2 -MaxRedir 0
$flat = $r.Content -replace '\s+', ' '
Check "POST /vehicle bad extraField re-renders form" ($r.StatusCode -eq 200) "status=$($r.StatusCode)"
Check "  Banner mentions seat/capacity guidance" ([bool]($flat -match "Couldn't build"))

# 9e. Vehicle add SUCCESS happy path -- writes imageUrl on the row
$imgUrl = "https://images.pexels.com/photos/170811/pexels-photo-170811.jpeg?auto=compress&cs=tinysrgb&w=1400"
$r = Post-Form -Url "$BASE/vehicle" -Body @{
    action = "add"; vehicleId = "VTEST3"; type = "Car"; brand = "TestBrand"; model = "TestModel"
    year = "2025"; rentalPricePerDay = "5000"; available = "true"; extraField = "5"
    imageUrl = $imgUrl
} -Session $adminSession2 -MaxRedir 0
Check "POST /vehicle happy path returns 302"     ($r.StatusCode -eq 302) "status=$($r.StatusCode)"
$row = (Get-Content data/vehicles.txt | Where-Object { $_ -match "^VTEST3\|" }) | Select-Object -First 1
Check "  VTEST3 row appended"                    ([bool]$row) "row=$row"
Check "  VTEST3 row carries imageUrl"            ([bool]($row -like "*pexels-photo-170811*"))

# 9f. Duplicate vehicle ID rejected
$r = Post-Form -Url "$BASE/vehicle" -Body @{
    action = "add"; vehicleId = "VTEST3"; type = "Car"; brand = "Other"; model = "Dup"
    year = "2025"; rentalPricePerDay = "5000"; available = "true"; extraField = "5"
} -Session $adminSession2 -MaxRedir 0
Check "POST /vehicle duplicate ID re-renders form" ($r.StatusCode -eq 200) "status=$($r.StatusCode)"
$flatDup = $r.Content -replace '\s+', ' '
Check "  Banner mentions duplicate"                ([bool]($flatDup -match "already exists"))

# Clean up VTEST3 so subsequent runs stay deterministic
$kept = Get-Content data/vehicles.txt | Where-Object { $_ -notmatch "^VTEST3\|" }
$kept | Set-Content data/vehicles.txt

# 9g. Vehicle images use per-vehicle imageUrl (search results page)
$rSearch = Get-Url -Url "$BASE/search?vehicleType=Car" -Session $session -MaxRedir 5
$flatSearch = $rSearch.Content -replace '\s+', ' '
# vehicles.txt has V004 Toyota Prius with imageUrl ending in pexels-photo-116675
Check "search-results uses per-vehicle imageUrl" ([bool]($flatSearch -match 'pexels-photo-116675'))

# 9h. Vehicle detail page uses per-vehicle imageUrl
$rDetail = Get-Url -Url "$BASE/vehicle?action=view&id=V004" -Session $session
$flatDetail = $rDetail.Content -replace '\s+', ' '
Check "vehicle-detail uses per-vehicle imageUrl (V004 Prius)" ([bool]($flatDetail -match 'pexels-photo-116675'))

# 9i. Vehicle form (admin) has the imageUrl input
$rForm = Get-Url -Url "$BASE/vehicle?action=add" -Session $adminSession2
Check "Vehicle add form has imageUrl input" ([bool]($rForm.Content -match 'name="imageUrl"'))

# ----------------------------------------------------------------
# FIX #10 -- Chart.js dashboards + admin drill-down pages
# ----------------------------------------------------------------
Write-Host "`n[FIX #10] Chart.js + admin drill-down pages" -ForegroundColor Yellow

# 10a. Chart.js loads on authenticated pages + theme defaults set
$rDash = Get-Url -Url "$BASE/dashboard" -Session $adminSession
Check "Header loads Chart.js from cdn.jsdelivr"  ([bool]($rDash.Content -match 'cdn.jsdelivr.net/npm/chart.js@4'))
Check "Header sets Chart.defaults.color"         ([bool]($rDash.Content -match 'Chart\.defaults\.color'))
Check "Header exposes VRMS_CHART palette"        ([bool]($rDash.Content -match 'window\.VRMS_CHART'))

# 10b. Admin dashboard -- cards clickable, two new charts present
$flatA = $rDash.Content -replace '\s+', ' '
Check "Admin Members card -> /admin/members"     ([bool]($flatA -match '<a[^>]*class="ds-stat[^"]*"[^>]*href="[^"]*admin/members"'))
Check "Admin Reservations card -> /admin/bookings" ([bool]($flatA -match '<a[^>]*class="ds-stat[^"]*"[^>]*href="[^"]*admin/bookings"'))
Check "Admin dashboard has chAdminRevenue canvas"   ([bool]($flatA -match 'id="chAdminRevenue"'))
Check "Admin dashboard has chAdminBookingMix canvas" ([bool]($flatA -match 'id="chAdminBookingMix"'))

# 10c. User dashboard -- stat cards clickable, two new charts present
$rUd = Get-Url -Url "$BASE/dashboard" -Session $session
$flatU = $rUd.Content -replace '\s+', ' '
$ctUser = ([regex]::Matches($flatU, '<a[^>]*class="ud-stat[^"]*"[^>]*href="[^"]*/payment/history"')).Count
Check "User dashboard: 3 stat cards link to /payment/history" ($ctUser -eq 3) "count=$ctUser"
Check "User dashboard has chUserSpending canvas" ([bool]($flatU -match 'id="chUserSpending"'))
Check "User dashboard has chUserBookingMix canvas" ([bool]($flatU -match 'id="chUserBookingMix"'))

# 10d. /admin/revenue carries the three named canvases + the top-vehicles link
$rRev = Get-Url -Url "$BASE/admin/revenue" -Session $adminSession
$flatR = $rRev.Content -replace '\s+', ' '
Check "Revenue page has chRevenue canvas"      ([bool]($flatR -match 'id="chRevenue"'))
Check "Revenue page has chTypeMix doughnut"    ([bool]($flatR -match 'id="chTypeMix"'))
Check "Revenue page has chTopVehicles bar"     ([bool]($flatR -match 'id="chTopVehicles"'))
Check "Top Vehicle KPI links to /admin/top-vehicles" ([bool]($flatR -match '/admin/top-vehicles'))

# 10e. /admin/members
$rMem = Get-Url -Url "$BASE/admin/members" -Session $adminSession
Check "GET /admin/members renders 200"          ($rMem.StatusCode -eq 200) "status=$($rMem.StatusCode)"
Check "  Members page lists Kamal Perera"       ([bool]($rMem.Content -match 'Kamal Perera'))
$rMemNon = Get-Url -Url "$BASE/admin/members" -Session $session -MaxRedir 0
Check "Non-admin redirected from /admin/members" ($rMemNon.StatusCode -eq 302) "status=$($rMemNon.StatusCode)"

# 10f. /admin/bookings
$rBook = Get-Url -Url "$BASE/admin/bookings" -Session $adminSession
$flatB = $rBook.Content -replace '\s+', ' '
Check "GET /admin/bookings renders 200"         ($rBook.StatusCode -eq 200) "status=$($rBook.StatusCode)"
Check "  Bookings page contains B001"           ([bool]($flatB -match 'B001'))
Check "  Bookings page has status filter chips" ([bool]($flatB -match 'data-status-filter="ALL"'))

# 10g. /admin/top-vehicles
$rTop = Get-Url -Url "$BASE/admin/top-vehicles" -Session $adminSession
Check "GET /admin/top-vehicles renders 200"     ($rTop.StatusCode -eq 200) "status=$($rTop.StatusCode)"
Check "  Top vehicles page contains a V### row" ([bool]($rTop.Content -match 'V\d{3}'))

# ----------------------------------------------------------------
# Summary
# ----------------------------------------------------------------
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "PASSED: $pass" -ForegroundColor Green
Write-Host "FAILED: $fail" -ForegroundColor $(if ($fail -gt 0) { 'Red' } else { 'Green' })
if ($fail -gt 0) {
    Write-Host "`nFailures:" -ForegroundColor Red
    $fails | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}
exit 0
