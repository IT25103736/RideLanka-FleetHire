# RideLanka FleetHire — Progress Demo MSSQL Setup

This package is for the **progress presentation**. The project keeps the existing Spring Boot + JSP modules, but the vehicle/fleet boundary is now explicit:

- **Vehicle Management (Jayawardana)** = vehicle master data: add/edit/delete vehicle identity and specification fields.
- **Fleet & Maintenance (Dananjaya / Maintenance staff)** = operational status, service/repair scheduling and inspections.
- Maintenance staff can set a vehicle to **AVAILABLE, RESERVED, RENTED, MAINTENANCE or OUT_OF_SERVICE** without editing its master details.

The six core ownership split in the project proposal remains: User & Customer, Vehicle, Booking & Reservation, Payment, Feedback & Support, and Fleet Management.

## 1. Requirements
- JDK 17+
- Maven 3.9+ (or the included wrapper)
- Microsoft SQL Server / SQL Server Express
- SSMS

## 2. Create the database
For the current progress ZIP, use **only** the root-level master installer:

`RideLankaFleetHire_MSSQL_MASTER_INSTALL.sql`

Run it once in SSMS. It creates a fresh `RideLankaFleetHire` database, tables, constraints, indexes and demo data. **Do not run the older `database/mssql/*Seed.sql` / `*DemoData.sql` scripts afterwards** because those files belong to the earlier schema.

If you already created the older progress database and do not want to recreate it, run:

`RideLankaFleetHire_MSSQL_FUNCTION_SEPARATION_PATCH.sql`

This patch adds the `vehicle_type` field, allows the `VEHICLE` role and creates the Vehicle Management demo account.

## 3. Configure SQL Server credentials
Edit:

`src/main/resources/application.properties`

Example for local SQL Server Authentication:

```properties
ridelanka.db.url=jdbc:sqlserver://localhost:1433;databaseName=RideLankaFleetHire;encrypt=false;trustServerCertificate=true
ridelanka.db.username=sa
ridelanka.db.password=YOUR_SA_PASSWORD
```

The Java `MssqlConnection` class reads these values; no database credentials are hard-coded in Java.

## 4. Demo accounts
- Admin: `admin@ridelanka.lk` / `admin123`
- Vehicle Management: `vehicle@ridelanka.lk` / `admin123`
- Maintenance: `maint@ridelanka.lk` / `maint123`
- Fleet: `fleet@ridelanka.lk` / `admin123`
- Customer: `kamal@ridelanka.lk` / `password`

## 5. Run
On Windows PowerShell:

```powershell
.\mvnw.cmd spring-boot:run
```

Then open `http://localhost:8080`.

## 6. Demo flow — Vehicle Management
1. Sign in as `vehicle@ridelanka.lk`.
2. Open **Vehicle Management**.
3. Add a new car with plate, make, model, year, transmission, fuel, seats, mileage, daily rate, category, branch and document expiry dates.
4. Confirm the row is stored in `dbo.vehicles`.
5. Edit the master record.
6. Do not use this page to change operational status.

## 7. Demo flow — Fleet / Maintenance
1. Sign in as `maint@ridelanka.lk` or `fleet@ridelanka.lk`.
2. Open **Fleet & Maintenance**.
3. Select an existing vehicle and set **MAINTENANCE** or **OUT_OF_SERVICE**.
4. Schedule a `SERVICE` or `REPAIR` job.
5. Move `SCHEDULED → IN_PROGRESS → COMPLETED`.
6. Record an inspection with `PASS` / `FAIL`.
7. Confirm the vehicle operational status changes in MSSQL.

## 8. Separation rule
Vehicle Management owns **what the vehicle is**. Fleet/Maintenance owns **what condition/state the vehicle is currently in**. This prevents Jayawardana's Vehicle Management CRUD and Dananjaya's Fleet operations from writing the same responsibilities.
