$ErrorActionPreference = "Stop"
Write-Host "Starting VRMS End-to-End Test..."

# Create a session variable to store cookies
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

# 1. Register a new user
Write-Host "`n1. Registering new user..."
$registerBody = @{
    name = "AutoTestUser"
    email = "auto@example.com"
    password = "password123"
}
$response = Invoke-WebRequest -Uri "http://localhost:8080/user/register" -Method Post -Body $registerBody -WebSession $session -UseBasicParsing -MaximumRedirection 0 -ErrorAction SilentlyContinue
Write-Host "Register Redirect Status: $($response.StatusCode) (Expected 302)"

# 2. Login
Write-Host "`n2. Logging in..."
$loginBody = @{
    email = "auto@example.com"
    password = "password123"
}
$response = Invoke-WebRequest -Uri "http://localhost:8080/user/login" -Method Post -Body $loginBody -WebSession $session -UseBasicParsing -MaximumRedirection 0 -ErrorAction SilentlyContinue
Write-Host "Login Redirect Status: $($response.StatusCode) (Expected 302)"

# Follow redirect to /search
$response = Invoke-WebRequest -Uri "http://localhost:8080/search" -Method Get -WebSession $session -UseBasicParsing
Write-Host "Search Page Loaded: $($response.StatusCode) (Expected 200)"

# 3. Create a Booking
Write-Host "`n3. Creating a Booking..."
# Randomize date offset to avoid collisions with prior bookings on the same vehicle.
$dayOffset = Get-Random -Minimum 3000 -Maximum 9000
$bookingBody = @{
    vehicleId = "CAR001"
    startDate = (Get-Date).AddDays($dayOffset).ToString("yyyy-MM-dd")
    endDate = (Get-Date).AddDays($dayOffset + 2).ToString("yyyy-MM-dd")
    bookingType = "INSTANT"
    dailyRate = "5000"
    duration = "2"
    customerName = "AutoTestUser"
}
# We POST to /booking which is handled by BookingServlet
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/booking" -Method Post -Body $bookingBody -WebSession $session -UseBasicParsing
    Write-Host "Booking Submission Status: $($response.StatusCode) (Expected 200)"
} catch {
    Write-Host "Error creating booking!"
    $stream = $_.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($stream)
    Write-Host $reader.ReadToEnd()
    exit 1
}

# Assuming the booking created a record, we extract the booking ID from the response HTML
$html = $response.Content
$bookingId = "B0000"
if ($html -match 'bookingId=(B\d+)') {
    $bookingId = $matches[1]
    Write-Host "Found Booking ID: $bookingId"
} elseif ($html -match '(B\d{10,})') {
    $bookingId = $matches[1]
    Write-Host "Found Booking ID: $bookingId"
} else {
    Write-Host "Could not parse Booking ID from confirmation page."
}

# 4. Proceed to Checkout / Payment
Write-Host "`n4. Processing Payment..."
$paymentBody = @{
    bookingId = $bookingId
    paymentMethod = "card"
    customerName = "AutoTestUser"
    amount = "10000"
    cardHolderName = "Auto Tester"
    cardNumber = "1234123412341234"
    expiryDate = "12/25"
    cvv = "123"
}
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/payment/process" -Method Post -Body $paymentBody -WebSession $session -UseBasicParsing
    Write-Host "Payment Submission Status: $($response.StatusCode) (Expected 200)"
    if ($response.Content -match 'INVOICE') {
        Write-Host "Invoice generated successfully!"
    } else {
        Write-Host "Invoice generation failed."
    }
} catch {
    Write-Host "Error creating payment!"
    $stream = $_.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($stream)
    Write-Host $reader.ReadToEnd()
    exit 1
}

# 5. Verify My Bookings
Write-Host "`n5. Verifying 'My Bookings' page..."
$response = Invoke-WebRequest -Uri "http://localhost:8080/booking?action=list" -Method Get -WebSession $session -UseBasicParsing
Write-Host "My Bookings Load Status: $($response.StatusCode) (Expected 200)"
if ($response.Content -match $bookingId) {
    Write-Host "SUCCESS: Booking $bookingId is visible in the My Bookings list!"
} else {
    Write-Host "FAILURE: Booking $bookingId is NOT visible in the My Bookings list."
}

Write-Host "`nE2E Test Complete."
