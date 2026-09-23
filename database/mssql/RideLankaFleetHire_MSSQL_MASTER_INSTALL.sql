/* RideLanka FleetHire - MSSQL MASTER INSTALLER
   Fresh progress-demo database. No legacy TXT migration.
   Run this script alone in SSMS on the target SQL Server instance.
   It recreates RideLankaFleetHire from scratch, creates all tables needed
   by the six project functions, and seeds safe demo data.

   WARNING: The database is dropped/recreated. Use this for the project demo
   database only.
*/
SET NOCOUNT ON;
GO

IF DB_ID(N'RideLankaFleetHire') IS NOT NULL
BEGIN
    ALTER DATABASE RideLankaFleetHire SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RideLankaFleetHire;
END;
GO
CREATE DATABASE RideLankaFleetHire;
GO
USE RideLankaFleetHire;
GO

/* ================================================================
   1. REFERENCE / SECURITY TABLES
   ================================================================ */

IF OBJECT_ID(N'dbo.users', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.users
    (
        user_id         VARCHAR(20)  NOT NULL,
        name            VARCHAR(120) NOT NULL,
        email           VARCHAR(180) NOT NULL,
        password_hash   VARCHAR(500) NOT NULL,
        role            VARCHAR(30)  NOT NULL,
        created_date    DATE         NOT NULL CONSTRAINT DF_users_created_date DEFAULT CAST(GETDATE() AS DATE),
        status          VARCHAR(20)  NOT NULL CONSTRAINT DF_users_status DEFAULT 'ACTIVE',
        phone           VARCHAR(30)  NULL,
        license_no      VARCHAR(80)  NULL,
        last_login_at   DATETIME2(0) NULL,
        CONSTRAINT PK_users PRIMARY KEY (user_id),
        CONSTRAINT UQ_users_email UNIQUE (email),
        CONSTRAINT CK_users_role CHECK (role IN
            ('CUSTOMER','BRANCH_STAFF','FINANCE','MAINTENANCE','FLEET','ADMIN')),
        CONSTRAINT CK_users_status CHECK (status IN
            ('ACTIVE','SUSPENDED','DEACTIVATED'))
    );
END;
GO

IF OBJECT_ID(N'dbo.customers', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.customers
    (
        customer_id      VARCHAR(20) NOT NULL,
        user_id          VARCHAR(20) NOT NULL,
        driving_license  VARCHAR(80) NULL,
        id_document_no   VARCHAR(80) NULL,
        address_line     VARCHAR(220) NULL,
        city              VARCHAR(80) NULL,
        date_of_birth    DATE NULL,
        verification_status VARCHAR(20) NOT NULL CONSTRAINT DF_customers_ver DEFAULT 'PENDING',
        CONSTRAINT PK_customers PRIMARY KEY (customer_id),
        CONSTRAINT UQ_customers_user UNIQUE (user_id),
        CONSTRAINT FK_customers_user FOREIGN KEY (user_id) REFERENCES dbo.users(user_id),
        CONSTRAINT CK_customers_verification CHECK (verification_status IN ('PENDING','VERIFIED','REJECTED'))
    );
END;
GO

IF OBJECT_ID(N'dbo.staff', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.staff
    (
        staff_id      VARCHAR(20) NOT NULL,
        user_id       VARCHAR(20) NOT NULL,
        branch_id     VARCHAR(20) NULL,
        employee_code VARCHAR(30) NULL,
        job_title     VARCHAR(100) NULL,
        CONSTRAINT PK_staff PRIMARY KEY (staff_id),
        CONSTRAINT UQ_staff_user UNIQUE (user_id),
        CONSTRAINT UQ_staff_employee_code UNIQUE (employee_code),
        CONSTRAINT FK_staff_user FOREIGN KEY (user_id) REFERENCES dbo.users(user_id)
    );
END;
GO

IF OBJECT_ID(N'dbo.branches', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.branches
    (
        branch_id     VARCHAR(20)  NOT NULL,
        branch_name   VARCHAR(100) NOT NULL,
        city          VARCHAR(80)  NOT NULL,
        address_line  VARCHAR(220) NULL,
        phone         VARCHAR(30)  NULL,
        status        VARCHAR(20)  NOT NULL CONSTRAINT DF_branches_status DEFAULT 'ACTIVE',
        CONSTRAINT PK_branches PRIMARY KEY (branch_id),
        CONSTRAINT CK_branches_status CHECK (status IN ('ACTIVE','INACTIVE'))
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_staff_branch')
BEGIN
    ALTER TABLE dbo.staff
    ADD CONSTRAINT FK_staff_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches(branch_id);
END;
GO

IF OBJECT_ID(N'dbo.vehicle_categories', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.vehicle_categories
    (
        category_id   VARCHAR(20) NOT NULL,
        category_name VARCHAR(50) NOT NULL,
        description   VARCHAR(250) NULL,
        CONSTRAINT PK_vehicle_categories PRIMARY KEY (category_id),
        CONSTRAINT UQ_vehicle_categories_name UNIQUE (category_name)
    );
END;
GO

/* ================================================================
   2. VEHICLE + FLEET MANAGEMENT
   ================================================================ */

IF OBJECT_ID(N'dbo.vehicles', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.vehicles
    (
        vehicle_id        VARCHAR(20) NOT NULL,
        plate_no           VARCHAR(30) NOT NULL,
        make               VARCHAR(60) NOT NULL,
        model              VARCHAR(80) NOT NULL,
        vehicle_year      INT NOT NULL,
        transmission       VARCHAR(20) NOT NULL,
        fuel_type          VARCHAR(20) NOT NULL,
        seats              INT NOT NULL,
        mileage            INT NOT NULL CONSTRAINT DF_vehicles_mileage DEFAULT 0,
        daily_rate         DECIMAL(12,2) NOT NULL,
        status             VARCHAR(20) NOT NULL CONSTRAINT DF_vehicles_status DEFAULT 'AVAILABLE',
        category_id        VARCHAR(20) NOT NULL,
        branch_id          VARCHAR(20) NOT NULL,
        image_url          VARCHAR(500) NULL,
        registration_expiry DATE NULL,
        insurance_expiry   DATE NULL,
        permit_expiry      DATE NULL,
        created_at         DATETIME2(0) NOT NULL CONSTRAINT DF_vehicles_created DEFAULT SYSDATETIME(),
        CONSTRAINT PK_vehicles PRIMARY KEY (vehicle_id),
        CONSTRAINT UQ_vehicles_plate UNIQUE (plate_no),
        CONSTRAINT FK_vehicles_category FOREIGN KEY (category_id) REFERENCES dbo.vehicle_categories(category_id),
        CONSTRAINT FK_vehicles_branch FOREIGN KEY (branch_id) REFERENCES dbo.branches(branch_id),
        CONSTRAINT CK_vehicles_year CHECK (vehicle_year BETWEEN 1980 AND 2100),
        CONSTRAINT CK_vehicles_seats CHECK (seats BETWEEN 1 AND 20),
        CONSTRAINT CK_vehicles_mileage CHECK (mileage >= 0),
        CONSTRAINT CK_vehicles_rate CHECK (daily_rate >= 0),
        CONSTRAINT CK_vehicles_status CHECK (status IN
            ('AVAILABLE','RESERVED','RENTED','MAINTENANCE','OUT_OF_SERVICE')),
        CONSTRAINT CK_vehicles_transmission CHECK (transmission IN ('MANUAL','AUTOMATIC')),
        CONSTRAINT CK_vehicles_fuel CHECK (fuel_type IN ('PETROL','DIESEL','HYBRID','ELECTRIC'))
    );
END;
GO

IF OBJECT_ID(N'dbo.vehicle_branch_transfers', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.vehicle_branch_transfers
    (
        transfer_id       INT IDENTITY(1,1) NOT NULL,
        vehicle_id        VARCHAR(20) NOT NULL,
        from_branch_id    VARCHAR(20) NULL,
        to_branch_id      VARCHAR(20) NOT NULL,
        transfer_date     DATETIME2(0) NOT NULL CONSTRAINT DF_transfers_date DEFAULT SYSDATETIME(),
        transferred_by    VARCHAR(20) NULL,
        notes             VARCHAR(300) NULL,
        CONSTRAINT PK_vehicle_branch_transfers PRIMARY KEY (transfer_id),
        CONSTRAINT FK_transfer_vehicle FOREIGN KEY (vehicle_id) REFERENCES dbo.vehicles(vehicle_id),
        CONSTRAINT FK_transfer_from_branch FOREIGN KEY (from_branch_id) REFERENCES dbo.branches(branch_id),
        CONSTRAINT FK_transfer_to_branch FOREIGN KEY (to_branch_id) REFERENCES dbo.branches(branch_id),
        CONSTRAINT FK_transfer_user FOREIGN KEY (transferred_by) REFERENCES dbo.users(user_id)
    );
END;
GO

IF OBJECT_ID(N'dbo.vehicle_documents', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.vehicle_documents
    (
        document_id    INT IDENTITY(1,1) NOT NULL,
        vehicle_id      VARCHAR(20) NOT NULL,
        document_type   VARCHAR(30) NOT NULL,
        document_number VARCHAR(80) NULL,
        issue_date      DATE NULL,
        expiry_date     DATE NULL,
        document_status VARCHAR(20) NOT NULL CONSTRAINT DF_vehicle_documents_status DEFAULT 'VALID',
        notes           VARCHAR(300) NULL,
        CONSTRAINT PK_vehicle_documents PRIMARY KEY (document_id),
        CONSTRAINT FK_vehicle_documents_vehicle FOREIGN KEY (vehicle_id) REFERENCES dbo.vehicles(vehicle_id),
        CONSTRAINT CK_vehicle_documents_type CHECK (document_type IN ('REGISTRATION','INSURANCE','PERMIT','OTHER')),
        CONSTRAINT CK_vehicle_documents_status CHECK (document_status IN ('VALID','EXPIRING','EXPIRED'))
    );
END;
GO

/* ================================================================
   3. BOOKING & RESERVATION MANAGEMENT
   ================================================================ */

IF OBJECT_ID(N'dbo.promotions', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.promotions
    (
        promotion_id       VARCHAR(20) NOT NULL,
        promo_code          VARCHAR(40) NOT NULL,
        description         VARCHAR(250) NULL,
        discount_type       VARCHAR(10) NOT NULL,
        discount_value      DECIMAL(10,2) NOT NULL,
        start_date          DATE NOT NULL,
        end_date            DATE NOT NULL,
        max_uses            INT NULL,
        uses_count           INT NOT NULL CONSTRAINT DF_promotions_uses DEFAULT 0,
        status              VARCHAR(20) NOT NULL CONSTRAINT DF_promotions_status DEFAULT 'ACTIVE',
        CONSTRAINT PK_promotions PRIMARY KEY (promotion_id),
        CONSTRAINT UQ_promotions_code UNIQUE (promo_code),
        CONSTRAINT CK_promotions_discount_type CHECK (discount_type IN ('PERCENT','FIXED')),
        CONSTRAINT CK_promotions_discount_value CHECK (discount_value >= 0),
        CONSTRAINT CK_promotions_dates CHECK (end_date >= start_date),
        CONSTRAINT CK_promotions_status CHECK (status IN ('ACTIVE','INACTIVE','EXPIRED'))
    );
END;
GO

IF OBJECT_ID(N'dbo.bookings', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.bookings
    (
        booking_id        VARCHAR(20) NOT NULL,
        customer_id       VARCHAR(20) NOT NULL,
        vehicle_id        VARCHAR(20) NOT NULL,
        pickup_branch_id  VARCHAR(20) NOT NULL,
        return_branch_id  VARCHAR(20) NULL,
        start_date        DATE NOT NULL,
        end_date          DATE NOT NULL,
        pickup_time       TIME(0) NULL,
        customer_phone    VARCHAR(30) NULL,
        booking_type      VARCHAR(10) NOT NULL,
        days_in_advance   INT NULL,
        with_driver       BIT NOT NULL CONSTRAINT DF_bookings_driver DEFAULT 0,
        promotion_id      VARCHAR(20) NULL,
        base_amount       DECIMAL(12,2) NOT NULL CONSTRAINT DF_bookings_base DEFAULT 0,
        discount_amount   DECIMAL(12,2) NOT NULL CONSTRAINT DF_bookings_discount DEFAULT 0,
        driver_charge     DECIMAL(12,2) NOT NULL CONSTRAINT DF_bookings_driver_charge DEFAULT 0,
        total_amount      DECIMAL(12,2) NOT NULL CONSTRAINT DF_bookings_total DEFAULT 0,
        status            VARCHAR(20) NOT NULL CONSTRAINT DF_bookings_status DEFAULT 'PENDING',
        created_at        DATETIME2(0) NOT NULL CONSTRAINT DF_bookings_created DEFAULT SYSDATETIME(),
        cancelled_at      DATETIME2(0) NULL,
        cancellation_reason VARCHAR(300) NULL,
        CONSTRAINT PK_bookings PRIMARY KEY (booking_id),
        CONSTRAINT FK_bookings_customer FOREIGN KEY (customer_id) REFERENCES dbo.customers(customer_id),
        CONSTRAINT FK_bookings_vehicle FOREIGN KEY (vehicle_id) REFERENCES dbo.vehicles(vehicle_id),
        CONSTRAINT FK_bookings_pickup_branch FOREIGN KEY (pickup_branch_id) REFERENCES dbo.branches(branch_id),
        CONSTRAINT FK_bookings_return_branch FOREIGN KEY (return_branch_id) REFERENCES dbo.branches(branch_id),
        CONSTRAINT FK_bookings_promotion FOREIGN KEY (promotion_id) REFERENCES dbo.promotions(promotion_id),
        CONSTRAINT CK_bookings_type CHECK (booking_type IN ('INSTANT','ADVANCE')),
        CONSTRAINT CK_bookings_dates CHECK (end_date >= start_date),
        CONSTRAINT CK_bookings_days_advance CHECK (days_in_advance IS NULL OR days_in_advance >= 0),
        CONSTRAINT CK_bookings_amounts CHECK (base_amount >= 0 AND discount_amount >= 0 AND driver_charge >= 0 AND total_amount >= 0),
        CONSTRAINT CK_bookings_status CHECK (status IN
            ('PENDING','CONFIRMED','ACTIVE','COMPLETED','CANCELLED','REJECTED'))
    );
END;
GO

/* ================================================================
   4. PAYMENT & FINANCE MANAGEMENT
   ================================================================ */

IF OBJECT_ID(N'dbo.payments', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.payments
    (
        payment_id           VARCHAR(20) NOT NULL,
        booking_id           VARCHAR(20) NOT NULL,
        customer_id          VARCHAR(20) NOT NULL,
        amount               DECIMAL(12,2) NOT NULL,
        payment_method       VARCHAR(20) NOT NULL,
        transaction_reference VARCHAR(100) NULL,
        status                VARCHAR(20) NOT NULL CONSTRAINT DF_payments_status DEFAULT 'PENDING',
        payment_date         DATETIME2(0) NOT NULL CONSTRAINT DF_payments_date DEFAULT SYSDATETIME(),
        gateway_response     VARCHAR(300) NULL,
        parent_payment_id    VARCHAR(20) NULL,
        CONSTRAINT PK_payments PRIMARY KEY (payment_id),
        CONSTRAINT FK_payments_booking FOREIGN KEY (booking_id) REFERENCES dbo.bookings(booking_id),
        CONSTRAINT FK_payments_customer FOREIGN KEY (customer_id) REFERENCES dbo.customers(customer_id),
        CONSTRAINT FK_payments_parent FOREIGN KEY (parent_payment_id) REFERENCES dbo.payments(payment_id),
        CONSTRAINT UQ_payments_transaction_reference UNIQUE (transaction_reference),
        CONSTRAINT CK_payments_amount CHECK (amount >= 0),
        CONSTRAINT CK_payments_method CHECK (payment_method IN ('CARD','BANK_TRANSFER','WALLET','CASH','OTHER')),
        CONSTRAINT CK_payments_status CHECK (status IN
            ('PENDING','SUCCESS','FAILED','REFUNDED','PARTIALLY_REFUNDED','VOID'))
    );
END;
GO

IF OBJECT_ID(N'dbo.payment_charges', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.payment_charges
    (
        charge_id     INT IDENTITY(1,1) NOT NULL,
        booking_id    VARCHAR(20) NOT NULL,
        charge_type   VARCHAR(20) NOT NULL,
        description   VARCHAR(250) NULL,
        amount        DECIMAL(12,2) NOT NULL,
        approved_by   VARCHAR(20) NULL,
        created_at    DATETIME2(0) NOT NULL CONSTRAINT DF_payment_charges_created DEFAULT SYSDATETIME(),
        CONSTRAINT PK_payment_charges PRIMARY KEY (charge_id),
        CONSTRAINT FK_payment_charges_booking FOREIGN KEY (booking_id) REFERENCES dbo.bookings(booking_id),
        CONSTRAINT FK_payment_charges_user FOREIGN KEY (approved_by) REFERENCES dbo.users(user_id),
        CONSTRAINT CK_payment_charges_type CHECK (charge_type IN ('LATE_RETURN','FUEL','DAMAGE','ADD_ON','OTHER')),
        CONSTRAINT CK_payment_charges_amount CHECK (amount >= 0)
    );
END;
GO

IF OBJECT_ID(N'dbo.refunds', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.refunds
    (
        refund_id            VARCHAR(20) NOT NULL,
        payment_id           VARCHAR(20) NOT NULL,
        booking_id           VARCHAR(20) NOT NULL,
        amount               DECIMAL(12,2) NOT NULL,
        reason               VARCHAR(300) NULL,
        status               VARCHAR(20) NOT NULL CONSTRAINT DF_refunds_status DEFAULT 'REQUESTED',
        requested_by         VARCHAR(20) NULL,
        approved_by          VARCHAR(20) NULL,
        requested_at         DATETIME2(0) NOT NULL CONSTRAINT DF_refunds_requested DEFAULT SYSDATETIME(),
        processed_at         DATETIME2(0) NULL,
        CONSTRAINT PK_refunds PRIMARY KEY (refund_id),
        CONSTRAINT FK_refunds_payment FOREIGN KEY (payment_id) REFERENCES dbo.payments(payment_id),
        CONSTRAINT FK_refunds_booking FOREIGN KEY (booking_id) REFERENCES dbo.bookings(booking_id),
        CONSTRAINT FK_refunds_requester FOREIGN KEY (requested_by) REFERENCES dbo.users(user_id),
        CONSTRAINT FK_refunds_approver FOREIGN KEY (approved_by) REFERENCES dbo.users(user_id),
        CONSTRAINT CK_refunds_amount CHECK (amount >= 0),
        CONSTRAINT CK_refunds_status CHECK (status IN ('REQUESTED','APPROVED','PROCESSED','REJECTED'))
    );
END;
GO

IF OBJECT_ID(N'dbo.invoices', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.invoices
    (
        invoice_id       VARCHAR(20) NOT NULL,
        booking_id       VARCHAR(20) NOT NULL,
        customer_id      VARCHAR(20) NOT NULL,
        invoice_date     DATE NOT NULL CONSTRAINT DF_invoices_date DEFAULT CAST(GETDATE() AS DATE),
        subtotal         DECIMAL(12,2) NOT NULL DEFAULT 0,
        discount_amount  DECIMAL(12,2) NOT NULL DEFAULT 0,
        tax_amount       DECIMAL(12,2) NOT NULL DEFAULT 0,
        additional_charges DECIMAL(12,2) NOT NULL DEFAULT 0,
        total_amount     DECIMAL(12,2) NOT NULL DEFAULT 0,
        status           VARCHAR(20) NOT NULL DEFAULT 'ISSUED',
        CONSTRAINT PK_invoices PRIMARY KEY (invoice_id),
        CONSTRAINT FK_invoices_booking FOREIGN KEY (booking_id) REFERENCES dbo.bookings(booking_id),
        CONSTRAINT FK_invoices_customer FOREIGN KEY (customer_id) REFERENCES dbo.customers(customer_id),
        CONSTRAINT CK_invoices_amounts CHECK (subtotal >= 0 AND discount_amount >= 0 AND tax_amount >= 0 AND additional_charges >= 0 AND total_amount >= 0),
        CONSTRAINT CK_invoices_status CHECK (status IN ('DRAFT','ISSUED','PAID','VOID'))
    );
END;
GO

/* ================================================================
   5. VEHICLE MAINTENANCE / FLEET OPERATIONS
   ================================================================ */

IF OBJECT_ID(N'dbo.maintenance_records', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.maintenance_records
    (
        maintenance_id   VARCHAR(20) NOT NULL,
        vehicle_id       VARCHAR(20) NOT NULL,
        maintenance_type VARCHAR(30) NOT NULL,
        description      VARCHAR(500) NULL,
        scheduled_date   DATE NOT NULL,
        service_date     DATE NULL,
        cost             DECIMAL(12,2) NOT NULL CONSTRAINT DF_maintenance_cost DEFAULT 0,
        technician       VARCHAR(120) NULL,
        status            VARCHAR(20) NOT NULL CONSTRAINT DF_maintenance_status DEFAULT 'SCHEDULED',
        created_by       VARCHAR(20) NULL,
        completed_by     VARCHAR(20) NULL,
        CONSTRAINT PK_maintenance_records PRIMARY KEY (maintenance_id),
        CONSTRAINT FK_maintenance_vehicle FOREIGN KEY (vehicle_id) REFERENCES dbo.vehicles(vehicle_id),
        CONSTRAINT FK_maintenance_created_by FOREIGN KEY (created_by) REFERENCES dbo.users(user_id),
        CONSTRAINT FK_maintenance_completed_by FOREIGN KEY (completed_by) REFERENCES dbo.users(user_id),
        CONSTRAINT CK_maintenance_type CHECK (maintenance_type IN ('SERVICE','REPAIR','INSPECTION','OTHER')),
        CONSTRAINT CK_maintenance_status CHECK (status IN ('SCHEDULED','IN_PROGRESS','COMPLETED','CANCELLED')),
        CONSTRAINT CK_maintenance_cost CHECK (cost >= 0)
    );
END;
GO

IF OBJECT_ID(N'dbo.inspections', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.inspections
    (
        inspection_id  INT IDENTITY(1,1) NOT NULL,
        vehicle_id     VARCHAR(20) NOT NULL,
        maintenance_id VARCHAR(20) NULL,
        inspection_date DATE NOT NULL,
        result         VARCHAR(10) NOT NULL,
        notes          VARCHAR(500) NULL,
        inspector_id   VARCHAR(20) NULL,
        CONSTRAINT PK_inspections PRIMARY KEY (inspection_id),
        CONSTRAINT FK_inspections_vehicle FOREIGN KEY (vehicle_id) REFERENCES dbo.vehicles(vehicle_id),
        CONSTRAINT FK_inspections_maintenance FOREIGN KEY (maintenance_id) REFERENCES dbo.maintenance_records(maintenance_id),
        CONSTRAINT FK_inspections_inspector FOREIGN KEY (inspector_id) REFERENCES dbo.users(user_id),
        CONSTRAINT CK_inspections_result CHECK (result IN ('PASS','FAIL'))
    );
END;
GO

/* ================================================================
   6. FEEDBACK & CUSTOMER SUPPORT
   ================================================================ */

IF OBJECT_ID(N'dbo.feedback', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.feedback
    (
        feedback_id  VARCHAR(20) NOT NULL,
        customer_id  VARCHAR(20) NOT NULL,
        booking_id   VARCHAR(20) NULL,
        vehicle_id   VARCHAR(20) NULL,
        rating       INT NOT NULL,
        comment      VARCHAR(1000) NULL,
        review_type  VARCHAR(20) NOT NULL DEFAULT 'PUBLIC',
        status       VARCHAR(20) NOT NULL DEFAULT 'VISIBLE',
        created_at   DATETIME2(0) NOT NULL CONSTRAINT DF_feedback_created DEFAULT SYSDATETIME(),
        updated_at   DATETIME2(0) NULL,
        CONSTRAINT PK_feedback PRIMARY KEY (feedback_id),
        CONSTRAINT FK_feedback_customer FOREIGN KEY (customer_id) REFERENCES dbo.customers(customer_id),
        CONSTRAINT FK_feedback_booking FOREIGN KEY (booking_id) REFERENCES dbo.bookings(booking_id),
        CONSTRAINT FK_feedback_vehicle FOREIGN KEY (vehicle_id) REFERENCES dbo.vehicles(vehicle_id),
        CONSTRAINT CK_feedback_rating CHECK (rating BETWEEN 1 AND 5),
        CONSTRAINT CK_feedback_type CHECK (review_type IN ('PUBLIC','VERIFIED')),
        CONSTRAINT CK_feedback_status CHECK (status IN ('VISIBLE','HIDDEN','FLAGGED','REMOVED'))
    );
END;
GO

IF OBJECT_ID(N'dbo.complaints', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.complaints
    (
        complaint_id  VARCHAR(20) NOT NULL,
        customer_id   VARCHAR(20) NOT NULL,
        booking_id    VARCHAR(20) NULL,
        vehicle_id    VARCHAR(20) NULL,
        subject       VARCHAR(180) NOT NULL,
        description   VARCHAR(1500) NOT NULL,
        priority      VARCHAR(10) NOT NULL DEFAULT 'MEDIUM',
        status        VARCHAR(20) NOT NULL DEFAULT 'OPEN',
        assigned_to   VARCHAR(20) NULL,
        resolution    VARCHAR(1500) NULL,
        created_at    DATETIME2(0) NOT NULL CONSTRAINT DF_complaints_created DEFAULT SYSDATETIME(),
        resolved_at   DATETIME2(0) NULL,
        CONSTRAINT PK_complaints PRIMARY KEY (complaint_id),
        CONSTRAINT FK_complaints_customer FOREIGN KEY (customer_id) REFERENCES dbo.customers(customer_id),
        CONSTRAINT FK_complaints_booking FOREIGN KEY (booking_id) REFERENCES dbo.bookings(booking_id),
        CONSTRAINT FK_complaints_vehicle FOREIGN KEY (vehicle_id) REFERENCES dbo.vehicles(vehicle_id),
        CONSTRAINT FK_complaints_assigned FOREIGN KEY (assigned_to) REFERENCES dbo.users(user_id),
        CONSTRAINT CK_complaints_priority CHECK (priority IN ('LOW','MEDIUM','HIGH','URGENT')),
        CONSTRAINT CK_complaints_status CHECK (status IN ('OPEN','IN_PROGRESS','RESOLVED','CLOSED'))
    );
END;
GO

/* ================================================================
   7. NOTIFICATIONS + AUDIT
   ================================================================ */

IF OBJECT_ID(N'dbo.notifications', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.notifications
    (
        notification_id   VARCHAR(30) NOT NULL,
        recipient_user_id VARCHAR(20) NOT NULL,
        notification_type VARCHAR(40) NOT NULL,
        title              VARCHAR(180) NOT NULL,
        message            VARCHAR(1000) NOT NULL,
        is_read            BIT NOT NULL CONSTRAINT DF_notifications_read DEFAULT 0,
        related_booking_id VARCHAR(20) NULL,
        created_at         DATETIME2(0) NOT NULL CONSTRAINT DF_notifications_created DEFAULT SYSDATETIME(),
        read_at            DATETIME2(0) NULL,
        CONSTRAINT PK_notifications PRIMARY KEY (notification_id),
        CONSTRAINT FK_notifications_user FOREIGN KEY (recipient_user_id) REFERENCES dbo.users(user_id),
        CONSTRAINT FK_notifications_booking FOREIGN KEY (related_booking_id) REFERENCES dbo.bookings(booking_id)
    );
END;
GO

IF OBJECT_ID(N'dbo.notification_templates', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.notification_templates
    (
        template_id     VARCHAR(20) NOT NULL,
        template_code   VARCHAR(50) NOT NULL,
        channel         VARCHAR(20) NOT NULL,
        subject_template VARCHAR(200) NULL,
        message_template VARCHAR(1000) NOT NULL,
        is_active       BIT NOT NULL DEFAULT 1,
        CONSTRAINT PK_notification_templates PRIMARY KEY (template_id),
        CONSTRAINT UQ_notification_templates_code UNIQUE (template_code),
        CONSTRAINT CK_notification_templates_channel CHECK (channel IN ('IN_APP','EMAIL','SMS','WHATSAPP'))
    );
END;
GO

IF OBJECT_ID(N'dbo.audit_logs', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.audit_logs
    (
        audit_id     BIGINT IDENTITY(1,1) NOT NULL,
        user_id      VARCHAR(20) NULL,
        action       VARCHAR(100) NOT NULL,
        target_type  VARCHAR(50) NULL,
        target_id    VARCHAR(50) NULL,
        old_value    VARCHAR(MAX) NULL,
        new_value    VARCHAR(MAX) NULL,
        details      VARCHAR(1000) NULL,
        event_time   DATETIME2(0) NOT NULL CONSTRAINT DF_audit_event DEFAULT SYSDATETIME(),
        CONSTRAINT PK_audit_logs PRIMARY KEY (audit_id),
        CONSTRAINT FK_audit_user FOREIGN KEY (user_id) REFERENCES dbo.users(user_id)
    );
END;
GO

/* ================================================================
   8. RENTAL RETURN / HANDOVER SUPPORT
   ================================================================ */

IF OBJECT_ID(N'dbo.rental_checkouts', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.rental_checkouts
    (
        checkout_id      INT IDENTITY(1,1) NOT NULL,
        booking_id       VARCHAR(20) NOT NULL,
        vehicle_id       VARCHAR(20) NOT NULL,
        handed_over_by   VARCHAR(20) NULL,
        handover_time    DATETIME2(0) NOT NULL,
        start_mileage    INT NOT NULL,
        fuel_level       DECIMAL(5,2) NULL,
        damage_notes     VARCHAR(1000) NULL,
        CONSTRAINT PK_rental_checkouts PRIMARY KEY (checkout_id),
        CONSTRAINT UQ_rental_checkouts_booking UNIQUE (booking_id),
        CONSTRAINT FK_checkout_booking FOREIGN KEY (booking_id) REFERENCES dbo.bookings(booking_id),
        CONSTRAINT FK_checkout_vehicle FOREIGN KEY (vehicle_id) REFERENCES dbo.vehicles(vehicle_id),
        CONSTRAINT FK_checkout_staff FOREIGN KEY (handed_over_by) REFERENCES dbo.users(user_id),
        CONSTRAINT CK_checkout_mileage CHECK (start_mileage >= 0),
        CONSTRAINT CK_checkout_fuel CHECK (fuel_level IS NULL OR fuel_level BETWEEN 0 AND 100)
    );
END;
GO

IF OBJECT_ID(N'dbo.rental_returns', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.rental_returns
    (
        return_id       INT IDENTITY(1,1) NOT NULL,
        booking_id      VARCHAR(20) NOT NULL,
        vehicle_id      VARCHAR(20) NOT NULL,
        returned_at     DATETIME2(0) NOT NULL,
        received_by     VARCHAR(20) NULL,
        end_mileage     INT NOT NULL,
        fuel_level      DECIMAL(5,2) NULL,
        damage_notes    VARCHAR(1000) NULL,
        late_days       INT NOT NULL DEFAULT 0,
        return_status   VARCHAR(20) NOT NULL DEFAULT 'COMPLETED',
        CONSTRAINT PK_rental_returns PRIMARY KEY (return_id),
        CONSTRAINT UQ_rental_returns_booking UNIQUE (booking_id),
        CONSTRAINT FK_returns_booking FOREIGN KEY (booking_id) REFERENCES dbo.bookings(booking_id),
        CONSTRAINT FK_returns_vehicle FOREIGN KEY (vehicle_id) REFERENCES dbo.vehicles(vehicle_id),
        CONSTRAINT FK_returns_staff FOREIGN KEY (received_by) REFERENCES dbo.users(user_id),
        CONSTRAINT CK_returns_mileage CHECK (end_mileage >= 0),
        CONSTRAINT CK_returns_fuel CHECK (fuel_level IS NULL OR fuel_level BETWEEN 0 AND 100),
        CONSTRAINT CK_returns_late_days CHECK (late_days >= 0),
        CONSTRAINT CK_returns_status CHECK (return_status IN ('COMPLETED','PENDING_INSPECTION'))
    );
END;
GO

/* ================================================================
   9. INDEXES FOR DEMO / REPORTING PERFORMANCE
   ================================================================ */

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_users_role_status' AND object_id=OBJECT_ID(N'dbo.users'))
    CREATE INDEX IX_users_role_status ON dbo.users(role,status);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_vehicles_branch_status' AND object_id=OBJECT_ID(N'dbo.vehicles'))
    CREATE INDEX IX_vehicles_branch_status ON dbo.vehicles(branch_id,status);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_vehicles_category_status' AND object_id=OBJECT_ID(N'dbo.vehicles'))
    CREATE INDEX IX_vehicles_category_status ON dbo.vehicles(category_id,status);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_bookings_vehicle_dates' AND object_id=OBJECT_ID(N'dbo.bookings'))
    CREATE INDEX IX_bookings_vehicle_dates ON dbo.bookings(vehicle_id,start_date,end_date,status);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_bookings_customer' AND object_id=OBJECT_ID(N'dbo.bookings'))
    CREATE INDEX IX_bookings_customer ON dbo.bookings(customer_id,created_at DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_payments_booking' AND object_id=OBJECT_ID(N'dbo.payments'))
    CREATE INDEX IX_payments_booking ON dbo.payments(booking_id,payment_date DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_maintenance_vehicle_status' AND object_id=OBJECT_ID(N'dbo.maintenance_records'))
    CREATE INDEX IX_maintenance_vehicle_status ON dbo.maintenance_records(vehicle_id,status,scheduled_date);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_complaints_status_assigned' AND object_id=OBJECT_ID(N'dbo.complaints'))
    CREATE INDEX IX_complaints_status_assigned ON dbo.complaints(status,assigned_to,created_at DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_notifications_recipient_read' AND object_id=OBJECT_ID(N'dbo.notifications'))
    CREATE INDEX IX_notifications_recipient_read ON dbo.notifications(recipient_user_id,is_read,created_at DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_audit_user_time' AND object_id=OBJECT_ID(N'dbo.audit_logs'))
    CREATE INDEX IX_audit_user_time ON dbo.audit_logs(user_id,event_time DESC);
GO

/* ================================================================
   10. DEMO SEED DATA - NO LEGACY TEXT DATA IMPORT
   ================================================================ */

/* Branches */
IF NOT EXISTS (SELECT 1 FROM dbo.branches WHERE branch_id='BR001')
    INSERT dbo.branches(branch_id,branch_name,city,address_line,phone)
    VALUES ('BR001','Kandy Branch','Kandy','Peradeniya Road, Kandy','0812000001');
IF NOT EXISTS (SELECT 1 FROM dbo.branches WHERE branch_id='BR002')
    INSERT dbo.branches(branch_id,branch_name,city,address_line,phone)
    VALUES ('BR002','Colombo Branch','Colombo','Duplication Road, Colombo 03','0112000002');
IF NOT EXISTS (SELECT 1 FROM dbo.branches WHERE branch_id='BR003')
    INSERT dbo.branches(branch_id,branch_name,city,address_line,phone)
    VALUES ('BR003','Galle Branch','Galle','Wakwella Road, Galle','0912000003');
GO

/* Categories */
IF NOT EXISTS (SELECT 1 FROM dbo.vehicle_categories WHERE category_id='CAT001')
    INSERT dbo.vehicle_categories(category_id,category_name,description)
    VALUES ('CAT001','Economy','Compact cars for economical city travel');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicle_categories WHERE category_id='CAT002')
    INSERT dbo.vehicle_categories(category_id,category_name,description)
    VALUES ('CAT002','Sedan','Comfortable passenger sedans');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicle_categories WHERE category_id='CAT003')
    INSERT dbo.vehicle_categories(category_id,category_name,description)
    VALUES ('CAT003','SUV','Larger vehicles for family and long-distance use');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicle_categories WHERE category_id='CAT004')
    INSERT dbo.vehicle_categories(category_id,category_name,description)
    VALUES ('CAT004','Hybrid / Electric','Hybrid and electric vehicles');
GO

/* Demo users - PBKDF2 hashes used by the current progress ZIP */
IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE user_id='U001')
    INSERT dbo.users(user_id,name,email,password_hash,role,status,phone,license_no)
    VALUES ('U001','RideLanka Admin','admin@ridelanka.lk','PBKDF2$120000$3jbXQt3lYD2PsP0vJg6sZA==$yWu1UfCAq8CmpFOqI15qExqLlaD9T37xbFrC0pSyplI=','ADMIN','ACTIVE','0710000000',NULL);
IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE user_id='U002')
    INSERT dbo.users(user_id,name,email,password_hash,role,status,phone,license_no)
    VALUES ('U002','Fleet Maintenance Demo','maint@ridelanka.lk','PBKDF2$120000$UX4Wk957wgc55WT0z0mvOw==$n3L7Dl7mYAMyq3eUYeONvzv+sNSrehaOh2GxP42MTAE=','MAINTENANCE','ACTIVE','0711111111','NIC-MAINT-01');
IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE user_id='U003')
    INSERT dbo.users(user_id,name,email,password_hash,role,status,phone,license_no)
    VALUES ('U003','Kamal Perera','kamal@ridelanka.lk','PBKDF2$120000$FfUh0gQqwzEkUkRxfs93hA==$MDiENs/V94PJ/hZ3KoPgCL80kjGqCqGahMbtohKcxsg=','CUSTOMER','ACTIVE','0772222222','B1234567');
IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE user_id='U004')
    INSERT dbo.users(user_id,name,email,password_hash,role,status,phone,license_no)
    VALUES ('U004','Fleet Operations Demo','fleet@ridelanka.lk','PBKDF2$120000$3jbXQt3lYD2PsP0vJg6sZA==$yWu1UfCAq8CmpFOqI15qExqLlaD9T37xbFrC0pSyplI=','FLEET','ACTIVE','0713333333','NIC-FLEET-01');
IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE user_id='U005')
    INSERT dbo.users(user_id,name,email,password_hash,role,status,phone,license_no)
    VALUES ('U005','Finance Demo','finance@ridelanka.lk','PBKDF2$120000$3jbXQt3lYD2PsP0vJg6sZA==$yWu1UfCAq8CmpFOqI15qExqLlaD9T37xbFrC0pSyplI=','FINANCE','ACTIVE','0714444444',NULL);
IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE user_id='U006')
    INSERT dbo.users(user_id,name,email,password_hash,role,status,phone,license_no)
    VALUES ('U006','Branch Staff Demo','branch@ridelanka.lk','PBKDF2$120000$3jbXQt3lYD2PsP0vJg6sZA==$yWu1UfCAq8CmpFOqI15qExqLlaD9T37xbFrC0pSyplI=','BRANCH_STAFF','ACTIVE','0715555555',NULL);
GO

/* Subtypes */
IF NOT EXISTS (SELECT 1 FROM dbo.customers WHERE customer_id='C001')
    INSERT dbo.customers(customer_id,user_id,driving_license,id_document_no,address_line,city,verification_status)
    VALUES ('C001','U003','B1234567','NIC-DEMO-01','Kandy Road','Kandy','VERIFIED');

IF NOT EXISTS (SELECT 1 FROM dbo.staff WHERE staff_id='S001')
    INSERT dbo.staff(staff_id,user_id,branch_id,employee_code,job_title)
    VALUES ('S001','U002','BR001','EMP-M001','Vehicle Maintenance Coordinator');
IF NOT EXISTS (SELECT 1 FROM dbo.staff WHERE staff_id='S002')
    INSERT dbo.staff(staff_id,user_id,branch_id,employee_code,job_title)
    VALUES ('S002','U004','BR001','EMP-F001','Fleet Operations Staff');
IF NOT EXISTS (SELECT 1 FROM dbo.staff WHERE staff_id='S003')
    INSERT dbo.staff(staff_id,user_id,branch_id,employee_code,job_title)
    VALUES ('S003','U005','BR002','EMP-FIN01','Finance Officer');
IF NOT EXISTS (SELECT 1 FROM dbo.staff WHERE staff_id='S004')
    INSERT dbo.staff(staff_id,user_id,branch_id,employee_code,job_title)
    VALUES ('S004','U006','BR001','EMP-BR01','Branch Front Desk Staff');
GO

/* Cars only - no bike rows */
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V011')
    INSERT dbo.vehicles(vehicle_id,plate_no,make,model,vehicle_year,transmission,fuel_type,seats,mileage,daily_rate,status,category_id,branch_id,insurance_expiry)
    VALUES ('V011','CBB-2011','Mitsubishi','Montero',2018,'AUTOMATIC','DIESEL',7,78200,9000,'AVAILABLE','CAT003','BR001','2027-03-31');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V018')
    INSERT dbo.vehicles(vehicle_id,plate_no,make,model,vehicle_year,transmission,fuel_type,seats,mileage,daily_rate,status,category_id,branch_id,insurance_expiry)
    VALUES ('V018','CAX-2018','Mazda','3',2021,'AUTOMATIC','PETROL',5,46500,5200,'AVAILABLE','CAT002','BR002','2027-06-30');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V021')
    INSERT dbo.vehicles(vehicle_id,plate_no,make,model,vehicle_year,transmission,fuel_type,seats,mileage,daily_rate,status,category_id,branch_id,insurance_expiry)
    VALUES ('V021','CAB-2021','Toyota','Camry Hybrid',2021,'AUTOMATIC','HYBRID',5,35400,6500,'AVAILABLE','CAT004','BR002','2027-11-30');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V026')
    INSERT dbo.vehicles(vehicle_id,plate_no,make,model,vehicle_year,transmission,fuel_type,seats,mileage,daily_rate,status,category_id,branch_id,insurance_expiry)
    VALUES ('V026','CAG-2026','Toyota','Prado',2020,'AUTOMATIC','DIESEL',7,61200,12000,'AVAILABLE','CAT003','BR003','2027-09-30');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V031')
    INSERT dbo.vehicles(vehicle_id,plate_no,make,model,vehicle_year,transmission,fuel_type,seats,mileage,daily_rate,status,category_id,branch_id,insurance_expiry)
    VALUES ('V031','CAD-2031','Suzuki','Wagon R',2020,'AUTOMATIC','PETROL',4,52200,3000,'AVAILABLE','CAT001','BR001','2027-04-30');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V032')
    INSERT dbo.vehicles(vehicle_id,plate_no,make,model,vehicle_year,transmission,fuel_type,seats,mileage,daily_rate,status,category_id,branch_id,insurance_expiry)
    VALUES ('V032','CBE-2032','Suzuki','Swift',2021,'MANUAL','PETROL',4,41800,3400,'AVAILABLE','CAT001','BR002','2027-05-31');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V038')
    INSERT dbo.vehicles(vehicle_id,plate_no,make,model,vehicle_year,transmission,fuel_type,seats,mileage,daily_rate,status,category_id,branch_id,insurance_expiry)
    VALUES ('V038','CAB-2038','Nissan','Leaf',2021,'AUTOMATIC','ELECTRIC',5,27900,6500,'AVAILABLE','CAT004','BR003','2027-08-31');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V039')
    INSERT dbo.vehicles(vehicle_id,plate_no,make,model,vehicle_year,transmission,fuel_type,seats,mileage,daily_rate,status,category_id,branch_id,insurance_expiry)
    VALUES ('V039','CBB-2039','Tesla','Model 3',2022,'AUTOMATIC','ELECTRIC',5,18200,11000,'AVAILABLE','CAT004','BR002','2027-12-31');
GO

/* Maintenance demo */
IF NOT EXISTS (SELECT 1 FROM dbo.maintenance_records WHERE maintenance_id='MT001')
    INSERT dbo.maintenance_records(maintenance_id,vehicle_id,maintenance_type,description,scheduled_date,service_date,cost,technician,status,created_by)
    VALUES ('MT001','V011','SERVICE','Routine 10,000 km service','2026-09-15',NULL,8500,'Kandy Auto Care','SCHEDULED','U002');
IF NOT EXISTS (SELECT 1 FROM dbo.maintenance_records WHERE maintenance_id='MT002')
    INSERT dbo.maintenance_records(maintenance_id,vehicle_id,maintenance_type,description,scheduled_date,service_date,cost,technician,status,created_by,completed_by)
    VALUES ('MT002','V018','REPAIR','Brake inspection and repair','2026-09-12','2026-09-12',14500,'Central Motor Works','COMPLETED','U002','U002');
IF NOT EXISTS (SELECT 1 FROM dbo.inspections WHERE vehicle_id='V018' AND maintenance_id='MT002')
    INSERT dbo.inspections(vehicle_id,maintenance_id,inspection_date,result,notes,inspector_id)
    VALUES ('V018','MT002','2026-09-12','PASS','Brakes checked; vehicle cleared for rental.','U002');
GO

/* One sample promotion */
IF NOT EXISTS (SELECT 1 FROM dbo.promotions WHERE promotion_id='PR001')
    INSERT dbo.promotions(promotion_id,promo_code,description,discount_type,discount_value,start_date,end_date,max_uses,status)
    VALUES ('PR001','RIDE10','10 percent rental discount','PERCENT',10,'2026-09-01','2026-12-31',100,'ACTIVE');
GO

/* ================================================================
   DEMO DATA - fresh, no TXT migration
   ================================================================ */

INSERT dbo.branches(branch_id,branch_name,city,address_line,phone) VALUES
('BR001','Kandy Branch','Kandy','Peradeniya Road, Kandy','0812000001'),
('BR002','Colombo Branch','Colombo','Duplication Road, Colombo 03','0112000002'),
('BR003','Galle Branch','Galle','Wakwella Road, Galle','0912000003');
GO

INSERT dbo.vehicle_categories(category_id,category_name,description) VALUES
('CAT001','Economy','Compact cars for economical city travel'),
('CAT002','Sedan','Comfortable passenger sedans'),
('CAT003','SUV','Larger vehicles for family and long-distance use'),
('CAT004','Hybrid / Electric','Hybrid and electric vehicles');
GO

/* PBKDF2 values below are the same hashes used by the current progress ZIP.
   Demo passwords:
   ADMIN: admin123
   MAINTENANCE: maint123
   CUSTOMER: password
   FLEET: admin123
   FINANCE: admin123
   BRANCH STAFF: admin123
*/
INSERT dbo.users(user_id,name,email,password_hash,role,status,phone,license_no) VALUES
('U001','RideLanka Admin','admin@ridelanka.lk','PBKDF2$120000$3jbXQt3lYD2PsP0vJg6sZA==$yWu1UfCAq8CmpFOqI15qExqLlaD9T37xbFrC0pSyplI=','ADMIN','ACTIVE','0710000000',NULL),
('U002','Fleet Maintenance Demo','maint@ridelanka.lk','PBKDF2$120000$UX4Wk957wgc55WT0z0mvOw==$n3L7Dl7mYAMyq3eUYeONvzv+sNSrehaOh2GxP42MTAE=','MAINTENANCE','ACTIVE','0711111111','NIC-MAINT-01'),
('U003','Kamal Perera','kamal@ridelanka.lk','PBKDF2$120000$FfUh0gQqwzEkUkRxfs93hA==$MDiENs/V94PJ/hZ3KoPgCL80kjGqCqGahMbtohKcxsg=','CUSTOMER','ACTIVE','0772222222','B1234567'),
('U004','Fleet Operations Demo','fleet@ridelanka.lk','PBKDF2$120000$3jbXQt3lYD2PsP0vJg6sZA==$yWu1UfCAq8CmpFOqI15qExqLlaD9T37xbFrC0pSyplI=','FLEET','ACTIVE','0713333333','NIC-FLEET-01'),
('U005','Finance Demo','finance@ridelanka.lk','PBKDF2$120000$3jbXQt3lYD2PsP0vJg6sZA==$yWu1UfCAq8CmpFOqI15qExqLlaD9T37xbFrC0pSyplI=','FINANCE','ACTIVE','0714444444',NULL),
('U006','Branch Staff Demo','branch@ridelanka.lk','PBKDF2$120000$3jbXQt3lYD2PsP0vJg6sZA==$yWu1UfCAq8CmpFOqI15qExqLlaD9T37xbFrC0pSyplI=','BRANCH_STAFF','ACTIVE','0715555555',NULL);
GO

INSERT dbo.customers(customer_id,user_id,driving_license,id_document_no,address_line,city,verification_status) VALUES
('C001','U003','B1234567','NIC-DEMO-01','Kandy Road','Kandy','VERIFIED');

INSERT dbo.staff(staff_id,user_id,branch_id,employee_code,job_title) VALUES
('S001','U002','BR001','EMP-M001','Vehicle Maintenance Coordinator'),
('S002','U004','BR001','EMP-F001','Fleet Operations Staff'),
('S003','U005','BR002','EMP-FIN01','Finance Officer'),
('S004','U006','BR001','EMP-BR01','Branch Front Desk Staff');
GO

INSERT dbo.vehicles(vehicle_id,plate_no,make,model,vehicle_year,transmission,fuel_type,seats,mileage,daily_rate,status,category_id,branch_id,insurance_expiry) VALUES
('V011','CBB-2011','Mitsubishi','Montero',2018,'AUTOMATIC','DIESEL',7,78200,9000,'AVAILABLE','CAT003','BR001','2027-03-31'),
('V018','CAX-2018','Mazda','3',2021,'AUTOMATIC','PETROL',5,46500,5200,'AVAILABLE','CAT002','BR002','2027-06-30'),
('V021','CAB-2021','Toyota','Camry Hybrid',2021,'AUTOMATIC','HYBRID',5,35400,6500,'AVAILABLE','CAT004','BR002','2027-11-30'),
('V026','CAG-2026','Toyota','Prado',2020,'AUTOMATIC','DIESEL',7,61200,12000,'AVAILABLE','CAT003','BR003','2027-09-30'),
('V031','CAD-2031','Suzuki','Wagon R',2020,'AUTOMATIC','PETROL',4,52200,3000,'AVAILABLE','CAT001','BR001','2027-04-30'),
('V032','CBE-2032','Suzuki','Swift',2021,'MANUAL','PETROL',4,41800,3400,'AVAILABLE','CAT001','BR002','2027-05-31'),
('V038','CAB-2038','Nissan','Leaf',2021,'AUTOMATIC','ELECTRIC',5,27900,6500,'AVAILABLE','CAT004','BR003','2027-08-31'),
('V039','CBB-2039','Tesla','Model 3',2022,'AUTOMATIC','ELECTRIC',5,18200,11000,'AVAILABLE','CAT004','BR002','2027-12-31');
GO

INSERT dbo.promotions(promotion_id,promo_code,description,discount_type,discount_value,start_date,end_date,max_uses,status) VALUES
('PR001','RIDE10','10 percent rental discount','PERCENT',10,'2026-09-01','2026-12-31',100,'ACTIVE');
GO

INSERT dbo.bookings(booking_id,customer_id,vehicle_id,pickup_branch_id,return_branch_id,start_date,end_date,pickup_time,customer_phone,booking_type,days_in_advance,with_driver,promotion_id,base_amount,discount_amount,driver_charge,total_amount,status) VALUES
('B001','C001','V018','BR002','BR002','2026-09-10','2026-09-12','10:00','0772222222','ADVANCE',7,0,NULL,10400,0,0,10400,'COMPLETED'),
('B002','C001','V021','BR002','BR001','2026-10-10','2026-10-13','09:00','0772222222','ADVANCE',20,0,'PR001',19500,1950,0,17550,'CONFIRMED');
GO

INSERT dbo.payments(payment_id,booking_id,customer_id,amount,payment_method,transaction_reference,status,payment_date,gateway_response) VALUES
('PAY001','B001','C001',10400,'CARD','TXN-RL-0001','SUCCESS','2026-09-08 10:05:00','DEMO_SUCCESS'),
('PAY002','B002','C001',17550,'CARD','TXN-RL-0002','SUCCESS','2026-09-14 09:30:00','DEMO_SUCCESS');
GO

INSERT dbo.invoices(invoice_id,booking_id,customer_id,invoice_date,subtotal,discount_amount,tax_amount,additional_charges,total_amount,status) VALUES
('INV001','B001','C001','2026-09-08',10400,0,0,0,10400,'PAID'),
('INV002','B002','C001','2026-09-14',19500,1950,0,0,17550,'PAID');
GO

INSERT dbo.feedback(feedback_id,customer_id,booking_id,vehicle_id,rating,comment,review_type,status) VALUES
('FB001','C001','B001','V018',5,'Clean vehicle and smooth rental experience.','VERIFIED','VISIBLE');
GO

INSERT dbo.complaints(complaint_id,customer_id,booking_id,vehicle_id,subject,description,priority,status,assigned_to) VALUES
('CMP001','C001','B001','V018','Sample post-rental complaint','Demo complaint for customer-support progress testing.','MEDIUM','OPEN','U006');
GO

INSERT dbo.maintenance_records(maintenance_id,vehicle_id,maintenance_type,description,scheduled_date,service_date,cost,technician,status,created_by) VALUES
('MT001','V011','SERVICE','Routine 10,000 km service','2026-09-15',NULL,8500,'Kandy Auto Care','SCHEDULED','U002'),
('MT002','V018','REPAIR','Brake inspection and repair','2026-09-12','2026-09-12',14500,'Central Motor Works','COMPLETED','U002');
GO

INSERT dbo.inspections(vehicle_id,maintenance_id,inspection_date,result,notes,inspector_id) VALUES
('V018','MT002','2026-09-12','PASS','Brakes checked; vehicle cleared for rental.','U002');
GO

INSERT dbo.notifications(notification_id,recipient_user_id,notification_type,title,message,is_read,related_booking_id) VALUES
('N001','U003','BOOKING_CONFIRMED','Booking confirmed','Your RideLanka booking B002 is confirmed.','0','B002'),
('N002','U002','MAINTENANCE_DUE','Maintenance due','Vehicle V011 has scheduled service on 2026-09-15.','0',NULL);
GO

/* ================================================================
   VALIDATION / DEMO QUERIES
   ================================================================ */

SELECT 'users' AS table_name, COUNT(*) AS row_count FROM dbo.users
UNION ALL SELECT 'customers', COUNT(*) FROM dbo.customers
UNION ALL SELECT 'staff', COUNT(*) FROM dbo.staff
UNION ALL SELECT 'branches', COUNT(*) FROM dbo.branches
UNION ALL SELECT 'vehicle_categories', COUNT(*) FROM dbo.vehicle_categories
UNION ALL SELECT 'vehicles', COUNT(*) FROM dbo.vehicles
UNION ALL SELECT 'bookings', COUNT(*) FROM dbo.bookings
UNION ALL SELECT 'payments', COUNT(*) FROM dbo.payments
UNION ALL SELECT 'invoices', COUNT(*) FROM dbo.invoices
UNION ALL SELECT 'promotions', COUNT(*) FROM dbo.promotions
UNION ALL SELECT 'maintenance_records', COUNT(*) FROM dbo.maintenance_records
UNION ALL SELECT 'inspections', COUNT(*) FROM dbo.inspections
UNION ALL SELECT 'feedback', COUNT(*) FROM dbo.feedback
UNION ALL SELECT 'complaints', COUNT(*) FROM dbo.complaints
UNION ALL SELECT 'notifications', COUNT(*) FROM dbo.notifications
UNION ALL SELECT 'audit_logs', COUNT(*) FROM dbo.audit_logs;
GO

SELECT v.vehicle_id,v.plate_no,v.make,v.model,v.vehicle_year,v.transmission,v.fuel_type,v.seats,v.mileage,v.daily_rate,v.status,b.branch_name,vc.category_name
FROM dbo.vehicles v
JOIN dbo.branches b ON b.branch_id=v.branch_id
JOIN dbo.vehicle_categories vc ON vc.category_id=v.category_id
ORDER BY v.vehicle_id;
GO

SELECT m.maintenance_id,m.vehicle_id,v.plate_no,v.make,v.model,m.maintenance_type,m.scheduled_date,m.service_date,m.cost,m.status
FROM dbo.maintenance_records m
JOIN dbo.vehicles v ON v.vehicle_id=m.vehicle_id
ORDER BY m.scheduled_date,m.maintenance_id;
GO

SELECT b.booking_id,c.customer_id,u.name AS customer_name,v.plate_no,v.make,v.model,b.start_date,b.end_date,b.status,b.total_amount
FROM dbo.bookings b
JOIN dbo.customers c ON c.customer_id=b.customer_id
JOIN dbo.users u ON u.user_id=c.user_id
JOIN dbo.vehicles v ON v.vehicle_id=b.vehicle_id
ORDER BY b.start_date,b.booking_id;
GO
