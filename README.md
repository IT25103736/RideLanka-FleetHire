# RideLanka FleetHire

RideLanka FleetHire is a university vehicle-rental and fleet-operations web application built with Java, Spring Boot / Spring MVC, JSP/JSTL, JDBC, Maven, and Microsoft SQL Server. The final application uses **Microsoft SQL Server as the only persistent data source**; TXT files are not used for application data.

## Technology stack

- Java 17
- Spring Boot / Spring MVC
- JSP / JSTL, HTML, CSS, JavaScript
- JDBC with Microsoft SQL Server
- Maven / Maven Wrapper
- Microsoft SQL Server JDBC driver

## Architecture

The normal request flow is:

`JSP -> Spring Controller -> Service/business rules (where required) -> Repository/DAO -> JDBC PreparedStatement -> MSSQL`

Controllers handle HTTP/session concerns; services hold cross-record business rules and transaction-oriented decisions; repositories contain JDBC and SQL; JSPs render the UI. SQL input is parameterized with `PreparedStatement` rather than concatenating request data into queries.

## Six major functions and ownership

| Function | Team member | Main implementation |
|---|---|---|
| User & Customer Management | S. M. H. C. B. D. Rambukpitiya — IT25103736 | `UserController`, `AdminController`, `UserRepository` |
| Vehicle Management | I. K. S. P. Jayawardana — IT25103732 | `VehicleController`, `VehicleRepository`, vehicle JSPs |
| Booking & Reservation Management | W. M. K. K. G. N. A. Weerasingha — IT25103737 | `BookingServlet`, `BookingService`, `BookingRepository` |
| Payment Management | R. M. M. D. Bhagyamathi — IT25103733 | `PaymentServlet`, `PaymentService`, `PaymentRepository` |
| Feedback & Support Management | R. M. R. D. Rajapaksha — IT25103734 | `ReviewServlet`, `FeedbackRepository` |
| Fleet Management | K. A. K. Dananjaya — IT25103735 | `FleetMaintenanceController`, `FleetMaintenanceService`, `MaintenanceRepository` |

Vehicle Management owns vehicle master data. Fleet Management operates on those existing vehicle records for operational status, maintenance and inspections; it does not create duplicate vehicles.

## Database setup

The canonical database scripts are in `database/`.

### Fresh database

Use this only when the `RideLankaFleetHire` database does **not** exist:

1. Open SQL Server Management Studio (SSMS).
2. Run `database/current-schema.sql`.
3. The script creates the database, schema, constraints/indexes and demo rows.
4. The fresh installer intentionally throws an error if `RideLankaFleetHire` already exists; it will not overwrite a working database.

### Existing RideLanka database

1. Back up the existing database first.
2. Run `database/update-patch.sql`.
3. Do **not** run `current-schema.sql` over an existing working database.

The patch is intended to be non-destructive: it adds missing columns/tables/indexes needed by the final application without dropping the database or deleting existing application rows. Review any SQL Server error before re-running a partially applied patch.

## Application configuration

Set database credentials using environment variables. Do not commit real passwords.

```text
RIDELANKA_DB_URL=jdbc:sqlserver://localhost:1433;databaseName=RideLankaFleetHire;encrypt=false;trustServerCertificate=true
RIDELANKA_DB_USERNAME=sa
RIDELANKA_DB_PASSWORD=<your SQL Server password>
```

`RIDELANKA_DB_URL` and `RIDELANKA_DB_USERNAME` have local-development defaults; `RIDELANKA_DB_PASSWORD` intentionally has no password default.

## Running the application

Windows:

```bat
mvnw.cmd clean package
mvnw.cmd spring-boot:run
```

Linux/macOS:

```bash
./mvnw clean package
./mvnw spring-boot:run
```

Then open `http://localhost:8080/`.

### Fresh-install demo accounts

These accounts are seeded only by `database/current-schema.sql`:

| Role | Email | Password |
|---|---|---|
| Admin | `admin@ridelanka.lk` | `admin123` |
| Maintenance | `maint@ridelanka.lk` | `maint123` |
| Customer | `kamal@ridelanka.lk` | `password` |
| Fleet | `fleet@ridelanka.lk` | `admin123` |
| Finance | `finance@ridelanka.lk` | `admin123` |
| Branch Staff | `branch@ridelanka.lk` | `admin123` |
| Vehicle Management | `vehicle@ridelanka.lk` | `admin123` |

These are demo credentials, not production credentials. Change them for any deployment outside the assessment/demo environment.

## Important routes

- `/` — public home
- `/login`, `/register`, `/profile` — account functions
- `/search` — MSSQL-backed vehicle search/filtering
- `/dashboard` — role-aware dashboard
- `/vehicle` — Vehicle Management CRUD (authorized roles)
- `/booking` — customer reservations and booking management
- `/payment/history` — customer payment history
- `/payment/list` — Finance/Admin payment management
- `/payment/promotions` — promotions
- `/review/view`, `/review/submit` — feedback
- `/review/moderate` — admin feedback moderation
- `/fleet` — Fleet/Maintenance operations
- `/admin/members`, `/admin/bookings`, `/admin/revenue` — admin views

## Business and validation rules implemented

### User & Customer

- Public registration always creates a `CUSTOMER`; browser input cannot self-assign an administrative role.
- Name, normalized email, password and Sri Lankan phone format are validated server-side.
- Duplicate email is rejected and backed by database uniqueness.
- Registration creates the corresponding MSSQL customer subtype in the same repository transaction.
- Login verifies the stored PBKDF2 hash and active status, updates `last_login_at`, and establishes a 30-minute session.
- Role checks protect administrative, Finance, Vehicle and Fleet routes; admin self-demotion/suspension is blocked in the member screen.

### Vehicle

- Vehicle ID, plate, make/model, year, transmission, fuel, seats, mileage, daily rate, document dates and image URL are server-validated.
- Duplicate plates/IDs are rejected.
- Both `Car` and `Van` are supported consistently with the database schema.
- Branch changes update the existing vehicle and create a branch-transfer history record atomically.
- Delete is POST-only and foreign-key-protected.
- Missing vehicle photos show an honest placeholder rather than an unrelated stock vehicle.

### Booking

- Only the logged-in customer can create/change/cancel their own reservation.
- Dates cannot be in the past; duration is limited to 1–90 days.
- Vehicle operational status, maintenance windows and overlapping active bookings are checked server-side against MSSQL.
- Booking amount is calculated server-side from the vehicle daily rate and booking rules.
- New reservations are persisted as `PENDING` and keep blocking overlapping dates until their status changes legitimately.
- Only unpaid `PENDING` bookings can be modified; dates and price are revalidated/recalculated in a serializable transaction.
- Customer cancellation is limited to supported states and keeps linked payment/invoice states consistent.

### Payment

- Browser-supplied amounts are not trusted; the current MSSQL booking total is authoritative.
- Card/wallet demo validation never persists full card number or CVV.
- Bank transfers are persisted as `PENDING` and require Finance/Admin approval.
- Approval confirms only a still-`PENDING` booking and writes/updates the paid invoice in the same transaction.
- A booking cannot have duplicate successful or simultaneously pending payments; filtered unique indexes also protect this in SQL Server.
- Promotions are validated server-side and usage is incremented transactionally for successful immediate payments.

### Feedback & Support

- Rating/content length and markup are validated server-side.
- Booking-linked feedback requires a matching completed booking owned by the customer.
- Duplicate active feedback for the same booking is blocked.
- Customers can edit/remove their own feedback; administrators can moderate status without silently rewriting customer text.

### Fleet

- Maintenance and inspection operations reference the existing vehicle master row.
- Operational status values and maintenance/inspection transitions are validated in the service/repository layer.
- Maintenance scheduling/status changes and vehicle operational state are synchronized transactionally.
- A passing inspection does not incorrectly release a vehicle while open maintenance still exists.

## Design patterns actually used

| Function | Pattern | Where | Why |
|---|---|---|---|
| User & Customer | MVC + Repository/DAO + Dependency Injection | `UserController` / `AdminController` -> `UserRepository` | Separates request/session handling from JDBC and makes dependencies explicit through constructors. |
| Vehicle | MVC + Repository/DAO | `VehicleController` -> `VehicleRepository` -> MSSQL | Keeps vehicle CRUD/branch-transfer SQL out of JSP/controller presentation logic. |
| Booking | MVC + Service Layer + Repository + polymorphic booking strategy | `BookingServlet` -> `BookingService` -> `BookingRepository`; `Booking.classify()` returns `InstantBooking`/`AdvanceBooking` | Centralizes booking rules/transactions while subclasses implement booking-type-specific validation/pricing behavior. |
| Payment | MVC + Service Layer + Repository/transaction boundary | `PaymentServlet` -> `PaymentService` -> `PaymentRepository` | Prevents browser-controlled totals and keeps payment + booking + invoice + promotion updates consistent. |
| Feedback & Support | MVC + Repository/DAO | `ReviewServlet` -> `FeedbackRepository` | Separates feedback ownership/moderation HTTP rules from parameterized SQL persistence. |
| Fleet | MVC + Service Layer + Repository | `FleetMaintenanceController` -> `FleetMaintenanceService` -> `MaintenanceRepository` | Keeps maintenance state rules separate from JDBC and synchronizes fleet state with the existing vehicle row. |

## Simple MSSQL verification queries

Run these in SSMS before and after performing the corresponding action in the UI:

```sql
USE RideLankaFleetHire;

-- User/customer registration and account changes
SELECT TOP 20 user_id, name, email, role, status, phone, last_login_at
FROM dbo.users ORDER BY user_id DESC;
SELECT TOP 20 customer_id, user_id, verification_status
FROM dbo.customers ORDER BY customer_id DESC;

-- Vehicle master data and branch-transfer history
SELECT vehicle_id, plate_no, make, model, vehicle_type, status, branch_id, daily_rate
FROM dbo.vehicles ORDER BY vehicle_id;
SELECT TOP 20 * FROM dbo.vehicle_branch_transfers ORDER BY transfer_date DESC;

-- Booking operations
SELECT TOP 20 booking_id, customer_id, vehicle_id, start_date, end_date, booking_type, total_amount, status
FROM dbo.bookings ORDER BY created_at DESC;

-- Payment/invoice operations
SELECT TOP 20 payment_id, booking_id, amount, payment_method, transaction_reference, status, payment_date
FROM dbo.payments ORDER BY payment_date DESC;
SELECT TOP 20 invoice_id, booking_id, total_amount, status, invoice_date
FROM dbo.invoices ORDER BY invoice_date DESC;

-- Feedback
SELECT TOP 20 feedback_id, customer_id, booking_id, vehicle_id, rating, review_type, status, created_at
FROM dbo.feedback ORDER BY created_at DESC;

-- Fleet / maintenance
SELECT TOP 20 * FROM dbo.maintenance_records ORDER BY scheduled_date DESC;
SELECT TOP 20 * FROM dbo.inspections ORDER BY inspection_date DESC;
SELECT vehicle_id, status FROM dbo.vehicles ORDER BY vehicle_id;
```

## Verification status of this delivered source

- All Java source files were compiled with Java 17 language level against local lightweight framework/servlet API stubs to catch Java syntax, type, constructor and internal API mismatches; this check passed.
- Static checks were performed for legacy runtime TXT/file-handler references, database credential defaults, old visible branding, broken payment actions, and controller/JSP route consistency.
- A real Maven dependency-resolution build could not be completed in the preparation runtime because Maven was not installed and the wrapper could not download Maven from Maven Central in that environment.
- A live SQL Server instance was not available in the preparation runtime, so database integration must be exercised on the target MSSQL machine using the supplied scripts and verification queries above.

See `docs/VERIFICATION.md` for the final local verification commands/results.


## Optional security email notifications

RideLanka can send best-effort SMTP security alerts after a successful sign-in and after a password change. Email is disabled by default and does not affect authentication if SMTP is unavailable.

Windows CMD example for Gmail SMTP (use a Google App Password, never your normal password):

```bat
set RIDELANKA_MAIL_ENABLED=true
set RIDELANKA_MAIL_USERNAME=ridelankafleethire@gmail.com
set RIDELANKA_MAIL_PASSWORD=YOUR_GOOGLE_APP_PASSWORD
set RIDELANKA_MAIL_FROM=ridelankafleethire@gmail.com
```

Optional overrides: `RIDELANKA_MAIL_HOST` and `RIDELANKA_MAIL_PORT`. Never commit SMTP credentials to GitHub. Customers who know their current password can change it from **My Profile** or from the **Change password** link on the sign-in page.
