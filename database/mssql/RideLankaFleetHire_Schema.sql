/* RideLanka FleetHire - SQL Server progress-demo schema
   Creates only the database areas needed for the currently prioritised
   User & Customer Management and Fleet / Maintenance workflows. */

IF DB_ID(N'RideLankaFleetHire') IS NULL
    CREATE DATABASE RideLankaFleetHire;
GO
USE RideLankaFleetHire;
GO

IF OBJECT_ID('dbo.users','U') IS NULL
BEGIN
    CREATE TABLE dbo.users (
        user_id       varchar(20)  NOT NULL PRIMARY KEY,
        name          varchar(120) NOT NULL,
        email         varchar(180) NOT NULL UNIQUE,
        password_hash varchar(500) NOT NULL,
        role          varchar(30)  NOT NULL,
        created_date  date         NOT NULL DEFAULT CAST(GETDATE() AS date),
        status        varchar(20)  NOT NULL DEFAULT 'ACTIVE',
        phone         varchar(30)  NULL,
        license_no    varchar(80)  NULL,
        CONSTRAINT CK_users_role CHECK (role IN ('CUSTOMER','BRANCH_STAFF','FINANCE','MAINTENANCE','FLEET','ADMIN')),
        CONSTRAINT CK_users_status CHECK (status IN ('ACTIVE','SUSPENDED','DEACTIVATED'))
    );
END
GO

IF OBJECT_ID('dbo.audit_logs','U') IS NULL
BEGIN
    CREATE TABLE dbo.audit_logs (
        audit_id   int IDENTITY(1,1) PRIMARY KEY,
        user_id    varchar(20) NULL,
        action     varchar(80) NOT NULL,
        target_id  varchar(50) NULL,
        details    varchar(500) NULL,
        event_time datetime2 NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_audit_user FOREIGN KEY(user_id) REFERENCES dbo.users(user_id)
    );
END
GO


IF OBJECT_ID('dbo.branches','U') IS NULL
BEGIN
    CREATE TABLE dbo.branches (
        branch_id varchar(20) NOT NULL PRIMARY KEY,
        branch_name varchar(100) NOT NULL,
        city varchar(80) NOT NULL,
        address varchar(220) NULL
    );
END
GO

IF OBJECT_ID('dbo.vehicle_categories','U') IS NULL
BEGIN
    CREATE TABLE dbo.vehicle_categories (
        category_id varchar(20) NOT NULL PRIMARY KEY,
        category_name varchar(50) NOT NULL UNIQUE
    );
END
GO

IF OBJECT_ID('dbo.vehicles','U') IS NULL
BEGIN
    CREATE TABLE dbo.vehicles (
        vehicle_id varchar(20) NOT NULL PRIMARY KEY,
        plate_no varchar(30) NOT NULL UNIQUE,
        make varchar(60) NOT NULL,
        model varchar(80) NOT NULL,
        vehicle_year int NOT NULL,
        transmission varchar(20) NOT NULL,
        fuel_type varchar(20) NOT NULL,
        seats int NOT NULL,
        mileage int NOT NULL DEFAULT 0,
        daily_rate decimal(12,2) NOT NULL,
        status varchar(20) NOT NULL DEFAULT 'AVAILABLE',
        category_id varchar(20) NOT NULL,
        branch_id varchar(20) NOT NULL,
        insurance_expiry date NULL,
        CONSTRAINT FK_vehicle_category FOREIGN KEY(category_id) REFERENCES dbo.vehicle_categories(category_id),
        CONSTRAINT FK_vehicle_branch FOREIGN KEY(branch_id) REFERENCES dbo.branches(branch_id),
        CONSTRAINT CK_vehicle_status CHECK(status IN ('AVAILABLE','RESERVED','RENTED','MAINTENANCE','OUT_OF_SERVICE'))
    );
END
GO

IF OBJECT_ID('dbo.maintenance_records','U') IS NULL
BEGIN
    CREATE TABLE dbo.maintenance_records (
        maintenance_id  varchar(20) PRIMARY KEY,
        vehicle_id      varchar(20) NOT NULL,
        maintenance_type varchar(30) NOT NULL,
        description     varchar(500) NULL,
        scheduled_date  date NOT NULL,
        service_date    date NULL,
        cost            decimal(12,2) NOT NULL DEFAULT 0,
        technician      varchar(120) NULL,
        status          varchar(20) NOT NULL DEFAULT 'SCHEDULED',
        CONSTRAINT CK_maintenance_type CHECK (maintenance_type IN ('SERVICE','REPAIR','INSPECTION','OTHER')),
        CONSTRAINT CK_maintenance_status CHECK (status IN ('SCHEDULED','IN_PROGRESS','COMPLETED','CANCELLED'))
    );
END
GO

IF OBJECT_ID('dbo.inspections','U') IS NULL
BEGIN
    CREATE TABLE dbo.inspections (
        inspection_id  int IDENTITY(1,1) PRIMARY KEY,
        vehicle_id     varchar(20) NOT NULL,
        maintenance_id varchar(20) NULL,
        inspection_date date NOT NULL,
        result         varchar(10) NOT NULL,
        notes          varchar(500) NULL,
        CONSTRAINT CK_inspection_result CHECK (result IN ('PASS','FAIL')),
        CONSTRAINT FK_inspection_maintenance FOREIGN KEY(maintenance_id) REFERENCES dbo.maintenance_records(maintenance_id)
    );
END
GO

IF OBJECT_ID('dbo.maintenance_records','U') IS NOT NULL
    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_maintenance_vehicle')
        ALTER TABLE dbo.maintenance_records ADD CONSTRAINT FK_maintenance_vehicle FOREIGN KEY(vehicle_id) REFERENCES dbo.vehicles(vehicle_id);
GO
