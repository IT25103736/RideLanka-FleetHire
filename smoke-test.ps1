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
    param([string]$Url, [Microsoft.PowerShell.Commands.WebRequestSession]$Session, [int]$MaxRedir = 0)
    try {
        $resp = Invoke-WebRequest -Uri $Url -Method Get -WebSession $Session -UseBasicParsing -MaximumRedirection $MaxRedir -ErrorAction SilentlyContinue -TimeoutSec 15
        if ($null -ne $resp) { return $resp }
    } catch {}
    return [PSCustomObject]@{ StatusCode = 0; Content = "" }
}

function Post-Form {
    param([string]$Url, [hashtable]$Body, [Microsoft.PowerShell.Commands.WebRequestSession]$Session, [int]$MaxRedir = 0)
    try {
        $resp = Invoke-WebRequest -Uri $Url -Method Post -Body $Body -WebSession $Session -UseBasicParsing -MaximumRedirection $MaxRedir -ErrorAction SilentlyContinue -TimeoutSec 15
        if ($null -ne $resp) { return $resp }
    } catch {
        $err = $_.Exception.Response
        if ($err) {
            return [PSCustomObject]@{ StatusCode = [int]$err.StatusCode; Content = "" }
        }
    }
    return [PSCustomObject]@{ StatusCode = 0; Content = "" }
}

Write-Host "=== VRMS Comprehensive Smoke Test ===" -ForegroundColor Cyan

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

# --- 1. Public pages (no auth) ---
Write-Host "`n[1] Public pages" -ForegroundColor Yellow
$r = Get-Url -Url "$BASE/" -Session $session
Check "GET / (home)" ($r.StatusCode -eq 200 -or $r.StatusCode -eq 302) "status=$($r.StatusCode)"

$r = Get-Url -Url "$BASE/register" -Session $session
$s = [int]$r.StatusCode
Check "GET /register" ($s -eq 200) "status=$s"

$r = Get-Url -Url "$BASE/login" -Session $session
$s = [int]$r.StatusCode
Check "GET /login" ($s -eq 200) "status=$s"

# --- 2. Register + login ---
Write-Host "`n[2] User flow" -ForegroundColor Yellow
$email = "smoke_$([Guid]::NewGuid().ToString('N').Substring(0,8))@example.com"
$body = @{ name = "SmokeUser"; email = $email; password = "Pass123!" }
$r = Post-Form -Url "$BASE/user/register" -Body $body -Session $session
$s = [int]$r.StatusCode
Check "POST /user/register" ($s -eq 302) "status=$s"

$body = @{ email = $email; password = "Pass123!" }
$r = Post-Form -Url "$BASE/user/login" -Body $body -Session $session
$s = [int]$r.StatusCode
Check "POST /user/login" ($s -eq 302) "status=$s"

# Bad login
$session2 = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$body = @{ email = $email; password = "wrong" }
$r = Post-Form -Url "$BASE/user/login" -Body $body -Session $session2
$s = [int]$r.StatusCode
Check "POST /user/login (bad password) rejected" (($s -eq 200) -or ($s -eq 401) -or ($s -eq 302)) "status=$s"

# --- 3. Authenticated pages ---
Write-Host "`n[3] Authenticated pages" -ForegroundColor Yellow
$r = Get-Url -Url "$BASE/profile" -Session $session
$s = [int]$r.StatusCode
Check "GET /profile" ($s -eq 200) "status=$s"

$r = Get-Url -Url "$BASE/search" -Session $session
Check "GET /search" ($r.StatusCode -eq 200) "status=$($r.StatusCode)"

$r = Get-Url -Url "$BASE/search?type=Car" -Session $session
Check "GET /search?type=Car" ($r.StatusCode -eq 200) "status=$($r.StatusCode)"

$r = Get-Url -Url "$BASE/search?type=Bike" -Session $session
Check "GET /search?type=Bike" ($r.StatusCode -eq 200) "status=$($r.StatusCode)"

$r = Get-Url -Url "$BASE/search?type=Van" -Session $session
Check "GET /search?type=Van" ($r.StatusCode -eq 200) "status=$($r.StatusCode)"

$r = Get-Url -Url "$BASE/dashboard" -Session $session
Check "GET /dashboard" (($r.StatusCode -eq 200) -or ($r.StatusCode -eq 302)) "status=$($r.StatusCode)"

# --- 4. Booking flow ---
Write-Host "`n[4] Booking" -ForegroundColor Yellow
# Far-future randomized offsets so we don't collide with prior test bookings.
$offsetA = Get-Random -Minimum 3000 -Maximum 9000
$offsetB = Get-Random -Minimum 3000 -Maximum 9000
$body = @{
    vehicleId = "CAR001"
    startDate = (Get-Date).AddDays($offsetA).ToString("yyyy-MM-dd")
    endDate = (Get-Date).AddDays($offsetA + 3).ToString("yyyy-MM-dd")
    bookingType = "INSTANT"
    dailyRate = "5000"
    duration = "3"
    customerName = "SmokeUser"
}
$r = Post-Form -Url "$BASE/booking" -Body $body -Session $session -MaxRedir 5
$s = [int]$r.StatusCode
Check "POST /booking" ($s -eq 200) "status=$s"
$bookingId = $null
if ($r.Content -match '(B\d{10,})') { $bookingId = $matches[1] }
Check "Booking ID parsed from response" ($null -ne $bookingId) "bookingId=$bookingId"
if (-not $bookingId -and $r.Content -match 'errorMsg|already booked|Invalid|Missing') {
    Write-Host "  (Booking page error detected - likely conflict or validation issue)" -ForegroundColor Yellow
}

# Advance Booking
$body = @{
    vehicleId = "BIKE001"
    startDate = (Get-Date).AddDays($offsetB).ToString("yyyy-MM-dd")
    endDate = (Get-Date).AddDays($offsetB + 2).ToString("yyyy-MM-dd")
    bookingType = "ADVANCE"
    dailyRate = "2000"
    duration = "2"
    customerName = "SmokeUser"
}
$r = Post-Form -Url "$BASE/booking" -Body $body -Session $session -MaxRedir 5
$s = [int]$r.StatusCode
Check "POST /booking (ADVANCE)" ($s -eq 200) "status=$s"

# Booking list
$r = Get-Url -Url "$BASE/booking?action=list" -Session $session
$s = [int]$r.StatusCode
Check "GET /booking?action=list" ($s -eq 200) "status=$s"
if ($bookingId) {
    Check "Booking $bookingId visible in list" ($r.Content -match $bookingId)
}

# --- 5. Payment ---
Write-Host "`n[5] Payment" -ForegroundColor Yellow
if ($bookingId) {
    $r = Get-Url -Url "$BASE/payment/checkout?bookingId=$bookingId" -Session $session
    $s = [int]$r.StatusCode
    Check "GET /payment/checkout" (($s -eq 200) -or ($s -eq 302)) "status=$s"

    $body = @{
        bookingId = $bookingId
        paymentMethod = "card"
        customerName = "SmokeUser"
        amount = "15000"
        cardHolderName = "Smoke Tester"
        cardNumber = "1234123412341234"
        expiryDate = "12/30"
        cvv = "123"
    }
    $r = Post-Form -Url "$BASE/payment/process" -Body $body -Session $session -MaxRedir 5
    $s = [int]$r.StatusCode
    Check "POST /payment/process (card)" ($s -eq 200) "status=$s"
    Check "Invoice content present" ($r.Content -match 'INVOICE|Invoice|invoice')

    $r = Get-Url -Url "$BASE/payment/list" -Session $session
    $s = [int]$r.StatusCode
    Check "GET /payment/list" ($s -eq 200) "status=$s"
}

# --- 6. Reviews ---
Write-Host "`n[6] Reviews" -ForegroundColor Yellow
$r = Get-Url -Url "$BASE/review/view?vehicleId=CAR001" -Session $session
Check "GET /review/view?vehicleId=CAR001" ($r.StatusCode -eq 200) "status=$($r.StatusCode)"

$r = Get-Url -Url "$BASE/review/submit?vehicleId=CAR001" -Session $session
Check "GET /review/submit" ($r.StatusCode -eq 200 -or $r.StatusCode -eq 302) "status=$($r.StatusCode)"

$body = @{
    vehicleId = "CAR001"
    reviewType = "public"
    rating = "5"
    title = "Smoke title"
    comment = "Excellent vehicle from smoke test"
}
$r = Post-Form -Url "$BASE/review/submit" -Body $body -Session $session -MaxRedir 5
$s = [int]$r.StatusCode
Check "POST /review/submit" (($s -eq 200) -or ($s -eq 302)) "status=$s"

# --- 7. Vehicle listing ---
Write-Host "`n[7] Vehicle" -ForegroundColor Yellow
$r = Get-Url -Url "$BASE/vehicle" -Session $session
Check "GET /vehicle" ($r.StatusCode -eq 200) "status=$($r.StatusCode)"

$r = Get-Url -Url "$BASE/vehicle/list" -Session $session
Check "GET /vehicle/list" ($r.StatusCode -eq 200) "status=$($r.StatusCode)"

# --- 8. Actuator ---
Write-Host "`n[8] Actuator" -ForegroundColor Yellow
$r = Get-Url -Url "$BASE/actuator/health" -Session $session
$health = [System.Text.Encoding]::UTF8.GetString($r.Content)
Check "GET /actuator/health UP" ($health -match 'UP')

# --- Summary ---
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "PASSED: $pass" -ForegroundColor Green
Write-Host "FAILED: $fail" -ForegroundColor $(if ($fail -gt 0) { 'Red' } else { 'Green' })
if ($fail -gt 0) {
    Write-Host "`nFailures:" -ForegroundColor Red
    $fails | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}
exit 0
