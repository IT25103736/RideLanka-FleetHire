# verify-booking-rules.ps1 -- covers spec scenarios 1, 2, 4, 6, 8, 10, 12 from
# docs/superpowers/specs/2026-05-24-booking-rules-instant-advance-classification-design.md
#
# RUNTIME REQUIREMENTS
#   1. Server must be running on http://localhost:8080 (start via .\mvnw.cmd spring-boot:run).
#   2. Run before 15:00 local time so the same-day pickup scenarios have valid
#      slots within the 09:00-21:00 pickup window. If now+6h > 21:00 the
#      same-day-accept scenario (2) will be SKIPPED.
#   3. Side-effect: each accept scenario adds a row to data/bookings.txt.
#      Re-running stacks more rows. Not destructive, but the file grows.
#
# ASSERTION NOTES
#   Scenario 1: before 16:00 local, matches "hours notice" (with earliest slot).
#               At/after 16:00, matches "same-day slots remaining". Both accepted.
#   Scenario 12: past date routes through InstantBooking (daysAhead=-1 < 7) which
#                fires its past-date guard (daysAhead < 0) returning "Start date cannot
#                be in the past." before DateValidator gets to run. Script asserts the
#                exact friendly error string.

$ErrorActionPreference = "Continue"
$BASE = "http://localhost:8080"
$pass = 0
$fail = 0
$skip = 0
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

function Skip-Scenario {
    param([string]$Name, [string]$Reason)
    Write-Host "  [SKIP] $Name - $Reason" -ForegroundColor Yellow
    $script:skip++
}

function Post-Form {
    param([string]$Url, [hashtable]$Body, [Microsoft.PowerShell.Commands.WebRequestSession]$Session, [int]$MaxRedir = 0)
    try {
        return Invoke-WebRequest -Uri $Url -Method Post -Body $Body -WebSession $Session `
                                 -UseBasicParsing -MaximumRedirection $MaxRedir `
                                 -ErrorAction SilentlyContinue -TimeoutSec 20
    } catch {
        $err = $_.Exception.Response
        if ($err) { return [PSCustomObject]@{ StatusCode = [int]$err.StatusCode; Content = "" } }
        return [PSCustomObject]@{ StatusCode = 0; Content = "" }
    }
}

function Format-Date { param([int]$Offset) (Get-Date).AddDays($Offset).ToString("yyyy-MM-dd") }
function Format-Hour { param([int]$Offset) (Get-Date).AddHours($Offset).ToString("HH") + ":00" }

function Build-Body {
    param([string]$VehicleId, [string]$Start, [int]$Duration, [string]$PickupTime, [int]$DailyRate = 3500)
    return @{
        vehicleId       = $VehicleId
        startDate       = $Start
        duration        = $Duration
        dailyRate       = $DailyRate
        pickupLocation  = "Colombo"
        pickupTime      = $PickupTime
        acceptTerms     = "true"
        customerName    = "Kamal Perera"
        withDriver      = "false"
    }
}

Write-Host "=== VRMS Booking Rules Verification ===" -ForegroundColor Cyan
$nowHour = (Get-Date).Hour
Write-Host "Local time: $(Get-Date -Format 'HH:mm') (hour=$nowHour)" -ForegroundColor Gray

# --- Login as seeded U002 Kamal ---
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$login = Post-Form -Url "$BASE/user/login" -Body @{
    email = "kamal@example.com"; password = "password"
} -Session $session -MaxRedir 1
Check "Login as Kamal (U002)" ($login.StatusCode -ge 200 -and $login.StatusCode -lt 400) "status=$($login.StatusCode)"

# Scenario 1: same-day, 2h lead -> reject (5h lead rule)
# Error message: "hours notice" if earliest slot <= 21:00, else "same-day slots remaining"
Write-Host "`n[1] Same-day, 2h lead - expect rejection (V001)" -ForegroundColor Yellow
if ($nowHour + 2 -gt 21) {
    Skip-Scenario "Same-day 2h lead" "now+2h would exceed 21:00 pickup window"
} else {
    $r = Post-Form -Url "$BASE/booking?action=create" -Body (Build-Body "V001" (Format-Date 0) 2 (Format-Hour 2) 3500) -Session $session
    $rejected = $r.StatusCode -eq 200 -and ($r.Content -match "hours notice" -or $r.Content -match "same-day slots remaining")
    Check "Reject same-day with 2h lead" $rejected "status=$($r.StatusCode)"
}

# Scenario 2: same-day, 6h lead -> accept with 25% surcharge (V002)
Write-Host "`n[2] Same-day, 6h lead - expect accept + 25% surcharge (V002)" -ForegroundColor Yellow
if ($nowHour + 6 -gt 21) {
    Skip-Scenario "Same-day 6h lead accept" "now+6h would exceed 21:00 pickup window - re-run before 15:00 local"
} else {
    $r = Post-Form -Url "$BASE/booking?action=create" -Body (Build-Body "V002" (Format-Date 0) 2 (Format-Hour 6) 4500) -Session $session
    Check "Accept same-day 6h lead (redirect to checkout)" ($r.StatusCode -eq 302 -or $r.StatusCode -eq 303) "status=$($r.StatusCode)"
}

# Scenario 4: day-1 tier - 10% surcharge (V003)
Write-Host "`n[4] Day-1 pickup - expect accept + 10% tier (V003)" -ForegroundColor Yellow
$r = Post-Form -Url "$BASE/booking?action=create" -Body (Build-Body "V003" (Format-Date 1) 2 "10:00" 2800) -Session $session
Check "Accept day-1 booking" ($r.StatusCode -eq 302 -or $r.StatusCode -eq 303) "status=$($r.StatusCode)"

# Scenario 6: day-4 tier boundary - 5% surcharge (V008)
Write-Host "`n[6] Day-4 pickup - expect accept + 5% tier (V008)" -ForegroundColor Yellow
$r = Post-Form -Url "$BASE/booking?action=create" -Body (Build-Body "V008" (Format-Date 4) 2 "10:00" 1500) -Session $session
Check "Accept day-4 booking" ($r.StatusCode -eq 302 -or $r.StatusCode -eq 303) "status=$($r.StatusCode)"

# Scenario 8: duration over cap -> reject (V001 reusable since this rejects)
Write-Host "`n[8] Instant duration 6 nights - expect rejection (cap is 5) (V001)" -ForegroundColor Yellow
$r = Post-Form -Url "$BASE/booking?action=create" -Body (Build-Body "V001" (Format-Date 2) 6 "10:00" 3500) -Session $session
Check "Reject instant duration over MAX_INSTANT_DAYS=5" ($r.StatusCode -eq 200 -and $r.Content -match "at most 5 days") "status=$($r.StatusCode)"

# Scenario 10: day-7 -> Advance, no surcharge, confirmation interstitial (V009)
Write-Host "`n[10] Day-7 pickup - expect accept + Advance interstitial + 0% surcharge (V009)" -ForegroundColor Yellow
$r = Post-Form -Url "$BASE/booking?action=create" -Body (Build-Body "V009" (Format-Date 7) 3 "10:00" 1200) -Session $session
$isInterstitial = [bool]($r.StatusCode -eq 200 -and $r.Content -match "Booking reference")
Check "Accept day-7 Advance - interstitial served, not checkout redirect" $isInterstitial "status=$($r.StatusCode)"

# Scenario 12: past date -> reject with friendly error
# NOTE: past date routes through InstantBooking (daysAhead=-1 < 7). Its validateBookingRules
# fires the past-date guard (daysAhead < 0) and returns "Start date cannot be in the past."
# DateValidator "cannot be in the past" is never reached; rejection comes from
# InstantBooking.validateBookingRules's past-date guard, not DateValidator.
Write-Host "`n[12] Past date - expect rejection (V001)" -ForegroundColor Yellow
$r = Post-Form -Url "$BASE/booking?action=create" -Body (Build-Body "V001" (Format-Date -1) 2 "10:00" 3500) -Session $session
$pastRejected = $r.StatusCode -eq 200 -and $r.Content -match "Start date cannot be in the past"
Check "Reject past start date with friendly error" $pastRejected "status=$($r.StatusCode)"

# --- Summary ---
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "Pass: $pass" -ForegroundColor Green
Write-Host "Skip: $skip" -ForegroundColor Yellow
Write-Host "Fail: $fail" -ForegroundColor $(if ($fail -eq 0) { "Green" } else { "Red" })
if ($fail -gt 0) {
    Write-Host "`nFailures:" -ForegroundColor Red
    $fails | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}
exit 0
