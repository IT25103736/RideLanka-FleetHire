# SE1020 - Vehicle Rental Management System

## Team Information
- **Module:** SE1020 - Object Oriented Programming
- **Project:** Vehicle Rental Management System

## Branch Structure
- `main` - final stable version
- `dev` - integration branch
- `feature/component-01` - Vehicle Search & Filtering
- `feature/component-02` - Booking & Reservation System
- `feature/component-03` - User Accounts & Profiles
- `feature/component-04` - Payment Gateway Integration
- `feature/component-05` - Vehicle Management Dashboard
- `feature/component-06` - Review & Rating System

## Commit Message Convention
- `feat:` - new feature
- `fix:` - bug fix
- `ui:` - UI changes
- `docs:` - documentation
- `chore:` - setup/config changes

## Data File Schemas

### vehicles.txt
```
vehicleId,type,brand,model,pricePerDay,fuelType,transmission,seats,available
V001,Car,Toyota,Corolla,5000,Petrol,Automatic,5,true
```

### bookings.txt
```
bookingId,userId,vehicleId,startDate,endDate,type,status
B001,U001,V001,2026-03-15,2026-03-18,Instant,Active
```

### users.txt
```
userId,username,passwordHash,email,role
U001,yehan123,encoded_password,yehan@email.com,RegularUser
```

### payments.txt
```
paymentId,bookingId,amount,method,status,date
P001,B001,15000,Card,Completed,2026-03-15
```

### invoices.txt
```
invoiceId,paymentId,userId,total,promoCode,date
I001,P001,U001,15000,NONE,2026-03-15
```

### reviews.txt
```
reviewId,userId,vehicleId,rating,comment,type,status
R001,U001,V001,5,Great car!,PublicReview,Approved
```

### revenue.txt
```
month,totalRevenue,totalBookings
2026-03,15000,1
```

## Technology Stack
- Java, Spring Boot
- JSP, HTML, CSS
- Bootstrap/Tailwind CSS
- File-based storage (.txt files) for legacy modules; MSSQL for RideLanka progress modules
- GitHub for version control

## RideLanka Progress Demo Update — MSSQL

The current progress version uses Microsoft SQL Server for the prioritised **User & Customer Management** and **Fleet Maintenance** workflows while the remaining legacy modules are still being migrated incrementally.

### SQL setup
1. Open SQL Server Management Studio.
2. Run `database/mssql/RideLankaFleetHire_Schema.sql`.
3. Run `database/mssql/RideLankaFleetHire_Seed.sql`.
4. Optionally run `database/mssql/RideLankaFleetHire_DemoData.sql`.
5. Set `RIDELANKA_DB_USERNAME` and `RIDELANKA_DB_PASSWORD` or edit the defaults in `src/main/resources/application.properties`.

### Demo accounts
- Admin: `admin@ridelanka.lk` / `admin123`
- Maintenance: `maint@ridelanka.lk` / `maint123`
- Customer: `kamal@ridelanka.lk` / `password`

### Priority demo flows
**User Management:** login → admin dashboard → User Management → create user → suspend/activate/deactivate → audit.

**Fleet Management:** Fleet Maintenance → schedule service → vehicle becomes unavailable in the legacy vehicle inventory → start/complete service → record inspection → PASS returns vehicle to available.

The maintenance workflow intentionally bridges the current text-based vehicle inventory so the team can demonstrate the new MSSQL maintenance records without forcing a full application rewrite before the progress presentation.
