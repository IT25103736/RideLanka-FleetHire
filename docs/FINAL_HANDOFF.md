# RideLanka FleetHire — Final Handoff

## Database order

### Fresh installation
1. Ensure the `RideLankaFleetHire` database does **not** already exist.
2. Run `database/current-schema.sql` in SQL Server Management Studio.
3. Set `RIDELANKA_DB_PASSWORD` (and optionally `RIDELANKA_DB_URL` / `RIDELANKA_DB_USERNAME`).
4. Run `mvnw.cmd clean package` and `mvnw.cmd spring-boot:run` on Windows, or the `./mvnw` equivalents on Linux/macOS.

`current-schema.sql` intentionally refuses to overwrite an existing `RideLankaFleetHire` database.

### Existing RideLanka database
1. Back up the existing database.
2. Run **only** `database/update-patch.sql`.
3. Configure the environment variables above.
4. Build/run the application.

Do not run the fresh installer over an existing working database.

## Configuration

```text
RIDELANKA_DB_URL=jdbc:sqlserver://localhost:1433;databaseName=RideLankaFleetHire;encrypt=false;trustServerCertificate=true
RIDELANKA_DB_USERNAME=sa
RIDELANKA_DB_PASSWORD=<your SQL Server password>
```

No real password is committed in Java or `application.properties`.

## Major corrections

- Removed active TXT/file-based persistence and migrated runtime data access to JDBC/MSSQL.
- Reconciled Java queries with the canonical SQL Server schema.
- Preserved and separated all six required major functions.
- Added/strengthened server-side validation, ownership checks, role checks and parameterized SQL.
- Made customer creation create the MSSQL customer subtype transactionally.
- Added safe vehicle master CRUD with duplicate-plate checks and branch-transfer history.
- Implemented MSSQL booking create/read/update/cancel with overlap, maintenance and ownership checks.
- Made booking totals authoritative on the server instead of accepting browser-supplied payment amounts.
- Added card/wallet demo settlement and bank-transfer verification with transactional booking/invoice updates.
- Implemented MSSQL-backed feedback, moderation and booking-linked verified-review rules.
- Implemented MSSQL-backed notifications.
- Synchronized fleet maintenance/inspection state with the existing vehicle row rather than creating duplicate vehicles.
- Unified RideLanka FleetHire branding and removed misleading file-era/fake-success UI text.
- Replaced unrelated stock vehicle fallback images with a neutral no-photo state.
- Removed hard-coded database password defaults and excluded generated/IDE/Git clutter from this final package.

## Design patterns

| Function | Pattern | Where | Why |
|---|---|---|---|
| User & Customer | MVC + Repository/DAO + DI | `UserController` / `AdminController` -> `UserRepository` | Keeps HTTP/session handling separate from JDBC. |
| Vehicle | MVC + Repository/DAO | `VehicleController` -> `VehicleRepository` | Separates vehicle master CRUD and SQL; branch history is transactional. |
| Booking | MVC + Service + Repository + polymorphism | `BookingServlet` -> `BookingService` -> `BookingRepository`; `InstantBooking` / `AdvanceBooking` | Centralizes rules and transaction boundaries while preserving booking-type behavior. |
| Payment | MVC + Service + Repository | `PaymentServlet` -> `PaymentService` -> `PaymentRepository` | Makes MSSQL booking totals authoritative and keeps payment/booking/invoice changes consistent. |
| Feedback & Support | MVC + Repository/DAO | `ReviewServlet` -> `FeedbackRepository` | Separates ownership/moderation HTTP rules from persistence. |
| Fleet | MVC + Service + Repository | `FleetMaintenanceController` -> `FleetMaintenanceService` -> `MaintenanceRepository` | Enforces maintenance transitions and synchronizes the existing vehicle state. |

## Validation summary

- **User/Customer:** required data, normalized email, password, Sri Lankan phone, duplicate email, public-role restriction, active login state.
- **Vehicle:** ID/plate formats, duplicate plate/ID, make/model, year, transmission/fuel, seats, mileage, rate, document dates, HTTP(S) image URLs, category/branch FKs.
- **Booking:** ownership, valid dates/duration, supported location/time, phone, vehicle existence/state, maintenance conflicts, overlapping reservations, editable/cancellable states.
- **Payment:** valid owned booking, database-authoritative amount, card/wallet formats, bank reference, duplicate success/pending prevention, promotion validity, Finance-only bank review.
- **Feedback:** rating/comment rules, markup rejection, customer ownership, completed booking requirement for linked reviews, duplicate linked feedback prevention, moderation states.
- **Fleet:** vehicle existence, maintenance date/cost/type, valid maintenance transitions, PASS/FAIL inspection results, open-maintenance state protection.

## MSSQL demo queries

```sql
USE RideLankaFleetHire;

SELECT TOP 20 user_id,name,email,role,status,last_login_at
FROM dbo.users ORDER BY user_id DESC;

SELECT TOP 20 vehicle_id,plate_no,make,model,status,branch_id,daily_rate
FROM dbo.vehicles ORDER BY vehicle_id DESC;

SELECT TOP 20 booking_id,customer_id,vehicle_id,start_date,end_date,total_amount,status
FROM dbo.bookings ORDER BY created_at DESC;

SELECT TOP 20 payment_id,booking_id,amount,payment_method,status,payment_date
FROM dbo.payments ORDER BY payment_date DESC;

SELECT TOP 20 invoice_id,booking_id,total_amount,status,invoice_date
FROM dbo.invoices ORDER BY invoice_date DESC;

SELECT TOP 20 feedback_id,customer_id,booking_id,vehicle_id,rating,status
FROM dbo.feedback ORDER BY created_at DESC;

SELECT TOP 20 maintenance_id,vehicle_id,maintenance_type,scheduled_date,status
FROM dbo.maintenance_records ORDER BY scheduled_date DESC;

SELECT TOP 20 inspection_id,vehicle_id,maintenance_id,inspection_date,result
FROM dbo.inspections ORDER BY inspection_date DESC;
```

## Verification status

Completed locally:
- Clean `javac --release 17 -Xlint:all` compile of all active application Java sources against lightweight Spring/Servlet API stubs.
- Active-source scan for TXT persistence/file handlers, old visible branding and hard-coded DB credentials.
- JSP structural balance checks for JSTL conditions/loops/forms.
- Java `dbo.*` table-reference cross-check against `database/current-schema.sql`.
- Canonical SQL safety scan for destructive database recreation/drop/delete operations.

Environment limitation:
- The preparation environment had no installed Maven, could not download the Maven distribution through the wrapper, and had no SQL Server instance. Therefore a real Maven dependency build, Spring Boot startup, JSP rendering against Tomcat, and live MSSQL CRUD execution were **not** falsely claimed. Run those final environment-dependent checks on the target machine using the commands above.
