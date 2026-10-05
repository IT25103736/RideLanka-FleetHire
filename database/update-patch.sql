/* RideLanka FleetHire - NON-DESTRUCTIVE UPDATE PATCH
   Run this only when the RideLankaFleetHire database already exists.
   It does not DROP the database, delete application rows, or reseed existing records.
*/
SET NOCOUNT ON;
GO
IF DB_ID(N'RideLankaFleetHire') IS NULL
    THROW 50002, 'RideLankaFleetHire does not exist. Use database/current-schema.sql for a fresh install.', 1;
GO
USE RideLankaFleetHire;
GO

/* ---- Core columns used by the final Java application ---- */
IF OBJECT_ID('dbo.users','U') IS NOT NULL AND COL_LENGTH('dbo.users','phone') IS NULL ALTER TABLE dbo.users ADD phone VARCHAR(30) NULL;
IF OBJECT_ID('dbo.users','U') IS NOT NULL AND COL_LENGTH('dbo.users','license_no') IS NULL ALTER TABLE dbo.users ADD license_no VARCHAR(80) NULL;
IF OBJECT_ID('dbo.users','U') IS NOT NULL AND COL_LENGTH('dbo.users','last_login_at') IS NULL ALTER TABLE dbo.users ADD last_login_at DATETIME2(0) NULL;
GO
IF OBJECT_ID('dbo.branches','U') IS NOT NULL AND COL_LENGTH('dbo.branches','address_line') IS NULL ALTER TABLE dbo.branches ADD address_line VARCHAR(220) NULL;
IF OBJECT_ID('dbo.branches','U') IS NOT NULL AND COL_LENGTH('dbo.branches','phone') IS NULL ALTER TABLE dbo.branches ADD phone VARCHAR(30) NULL;
IF OBJECT_ID('dbo.branches','U') IS NOT NULL AND COL_LENGTH('dbo.branches','status') IS NULL ALTER TABLE dbo.branches ADD status VARCHAR(20) NOT NULL CONSTRAINT DF_branches_status_patch DEFAULT 'ACTIVE' WITH VALUES;
GO
IF OBJECT_ID('dbo.vehicle_categories','U') IS NOT NULL AND COL_LENGTH('dbo.vehicle_categories','description') IS NULL ALTER TABLE dbo.vehicle_categories ADD description VARCHAR(250) NULL;
GO
IF OBJECT_ID('dbo.vehicles','U') IS NOT NULL AND COL_LENGTH('dbo.vehicles','image_url') IS NULL ALTER TABLE dbo.vehicles ADD image_url VARCHAR(500) NULL;
IF OBJECT_ID('dbo.vehicles','U') IS NOT NULL AND COL_LENGTH('dbo.vehicles','registration_expiry') IS NULL ALTER TABLE dbo.vehicles ADD registration_expiry DATE NULL;
IF OBJECT_ID('dbo.vehicles','U') IS NOT NULL AND COL_LENGTH('dbo.vehicles','insurance_expiry') IS NULL ALTER TABLE dbo.vehicles ADD insurance_expiry DATE NULL;
IF OBJECT_ID('dbo.vehicles','U') IS NOT NULL AND COL_LENGTH('dbo.vehicles','permit_expiry') IS NULL ALTER TABLE dbo.vehicles ADD permit_expiry DATE NULL;
IF OBJECT_ID('dbo.vehicles','U') IS NOT NULL AND COL_LENGTH('dbo.vehicles','vehicle_type') IS NULL ALTER TABLE dbo.vehicles ADD vehicle_type VARCHAR(10) NOT NULL CONSTRAINT DF_vehicles_type_patch DEFAULT 'Car' WITH VALUES;
GO

/* ---- Role/type constraints: broaden safely to values supported by the app ---- */
IF OBJECT_ID('dbo.users','U') IS NOT NULL AND EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_users_role' AND parent_object_id=OBJECT_ID('dbo.users'))
    ALTER TABLE dbo.users DROP CONSTRAINT CK_users_role;
GO
IF OBJECT_ID('dbo.users','U') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_users_role' AND parent_object_id=OBJECT_ID('dbo.users'))
    ALTER TABLE dbo.users ADD CONSTRAINT CK_users_role CHECK (role IN ('CUSTOMER','BRANCH_STAFF','FINANCE','MAINTENANCE','FLEET','VEHICLE','ADMIN'));
GO
IF OBJECT_ID('dbo.vehicles','U') IS NOT NULL AND EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_vehicles_type' AND parent_object_id=OBJECT_ID('dbo.vehicles'))
    ALTER TABLE dbo.vehicles DROP CONSTRAINT CK_vehicles_type;
GO
IF OBJECT_ID('dbo.vehicles','U') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_vehicles_type' AND parent_object_id=OBJECT_ID('dbo.vehicles'))
    ALTER TABLE dbo.vehicles ADD CONSTRAINT CK_vehicles_type CHECK (vehicle_type IN ('Car','Van'));
GO

/* ---- Customer subtype required by registration/booking ---- */
IF OBJECT_ID('dbo.customers','U') IS NULL
BEGIN
    CREATE TABLE dbo.customers(
      customer_id VARCHAR(20) NOT NULL CONSTRAINT PK_customers PRIMARY KEY,
      user_id VARCHAR(20) NOT NULL CONSTRAINT UQ_customers_user UNIQUE,
      driving_license VARCHAR(80) NULL,id_document_no VARCHAR(80) NULL,address_line VARCHAR(220) NULL,city VARCHAR(80) NULL,date_of_birth DATE NULL,
      verification_status VARCHAR(20) NOT NULL CONSTRAINT DF_customers_ver_patch DEFAULT 'PENDING',
      CONSTRAINT FK_customers_user FOREIGN KEY(user_id) REFERENCES dbo.users(user_id),
      CONSTRAINT CK_customers_verification CHECK(verification_status IN ('PENDING','VERIFIED','REJECTED'))
    );
END;
GO
/* Backfill missing CUSTOMER subtype rows without changing existing customer data. */
INSERT dbo.customers(customer_id,user_id,driving_license,verification_status)
SELECT 'C'+RIGHT('00000'+CAST(ROW_NUMBER() OVER(ORDER BY u.user_id)+(SELECT ISNULL(MAX(TRY_CAST(SUBSTRING(customer_id,2,20) AS INT)),0) FROM dbo.customers) AS VARCHAR(10)),5),
       u.user_id,u.license_no,'PENDING'
FROM dbo.users u
WHERE u.role='CUSTOMER' AND NOT EXISTS(SELECT 1 FROM dbo.customers c WHERE c.user_id=u.user_id);
GO

/* ---- Missing functional tables (created only when absent) ---- */
IF OBJECT_ID('dbo.promotions','U') IS NULL
BEGIN
 CREATE TABLE dbo.promotions(promotion_id VARCHAR(20) NOT NULL PRIMARY KEY,promo_code VARCHAR(40) NOT NULL UNIQUE,description VARCHAR(250) NULL,discount_type VARCHAR(10) NOT NULL,discount_value DECIMAL(10,2) NOT NULL,start_date DATE NOT NULL,end_date DATE NOT NULL,max_uses INT NULL,uses_count INT NOT NULL DEFAULT 0,status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',CONSTRAINT CK_promotions_discount_type CHECK(discount_type IN ('PERCENT','FIXED')),CONSTRAINT CK_promotions_dates CHECK(end_date>=start_date),CONSTRAINT CK_promotions_status CHECK(status IN ('ACTIVE','INACTIVE','EXPIRED')));
END;
GO
IF OBJECT_ID('dbo.bookings','U') IS NULL
BEGIN
 CREATE TABLE dbo.bookings(booking_id VARCHAR(20) NOT NULL PRIMARY KEY,customer_id VARCHAR(20) NOT NULL,vehicle_id VARCHAR(20) NOT NULL,pickup_branch_id VARCHAR(20) NOT NULL,return_branch_id VARCHAR(20) NULL,start_date DATE NOT NULL,end_date DATE NOT NULL,pickup_time TIME(0) NULL,customer_phone VARCHAR(30) NULL,booking_type VARCHAR(10) NOT NULL,days_in_advance INT NULL,with_driver BIT NOT NULL DEFAULT 0,promotion_id VARCHAR(20) NULL,base_amount DECIMAL(12,2) NOT NULL DEFAULT 0,discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0,driver_charge DECIMAL(12,2) NOT NULL DEFAULT 0,total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,status VARCHAR(20) NOT NULL DEFAULT 'PENDING',created_at DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),cancelled_at DATETIME2(0) NULL,cancellation_reason VARCHAR(300) NULL,CONSTRAINT FK_bookings_customer FOREIGN KEY(customer_id) REFERENCES dbo.customers(customer_id),CONSTRAINT FK_bookings_vehicle FOREIGN KEY(vehicle_id) REFERENCES dbo.vehicles(vehicle_id),CONSTRAINT FK_bookings_pickup_branch FOREIGN KEY(pickup_branch_id) REFERENCES dbo.branches(branch_id),CONSTRAINT FK_bookings_return_branch FOREIGN KEY(return_branch_id) REFERENCES dbo.branches(branch_id),CONSTRAINT FK_bookings_promotion FOREIGN KEY(promotion_id) REFERENCES dbo.promotions(promotion_id),CONSTRAINT CK_bookings_type CHECK(booking_type IN ('INSTANT','ADVANCE')),CONSTRAINT CK_bookings_dates CHECK(end_date>=start_date),CONSTRAINT CK_bookings_status CHECK(status IN ('PENDING','CONFIRMED','ACTIVE','COMPLETED','CANCELLED','REJECTED')));
END;
GO
IF OBJECT_ID('dbo.payments','U') IS NULL
BEGIN
 CREATE TABLE dbo.payments(payment_id VARCHAR(20) NOT NULL PRIMARY KEY,booking_id VARCHAR(20) NOT NULL,customer_id VARCHAR(20) NOT NULL,amount DECIMAL(12,2) NOT NULL,payment_method VARCHAR(20) NOT NULL,transaction_reference VARCHAR(100) NULL,status VARCHAR(20) NOT NULL DEFAULT 'PENDING',payment_date DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),gateway_response VARCHAR(300) NULL,parent_payment_id VARCHAR(20) NULL,CONSTRAINT FK_payments_booking FOREIGN KEY(booking_id) REFERENCES dbo.bookings(booking_id),CONSTRAINT FK_payments_customer FOREIGN KEY(customer_id) REFERENCES dbo.customers(customer_id),CONSTRAINT CK_payments_method CHECK(payment_method IN ('CARD','BANK_TRANSFER','WALLET','CASH','OTHER')),CONSTRAINT CK_payments_status CHECK(status IN ('PENDING','SUCCESS','FAILED','REFUNDED','PARTIALLY_REFUNDED','VOID')));
END;
GO
IF OBJECT_ID('dbo.invoices','U') IS NULL
BEGIN
 CREATE TABLE dbo.invoices(invoice_id VARCHAR(20) NOT NULL PRIMARY KEY,booking_id VARCHAR(20) NOT NULL,customer_id VARCHAR(20) NOT NULL,invoice_date DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),subtotal DECIMAL(12,2) NOT NULL DEFAULT 0,discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0,tax_amount DECIMAL(12,2) NOT NULL DEFAULT 0,additional_charges DECIMAL(12,2) NOT NULL DEFAULT 0,total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,status VARCHAR(20) NOT NULL DEFAULT 'ISSUED',CONSTRAINT FK_invoices_booking FOREIGN KEY(booking_id) REFERENCES dbo.bookings(booking_id),CONSTRAINT FK_invoices_customer FOREIGN KEY(customer_id) REFERENCES dbo.customers(customer_id),CONSTRAINT CK_invoices_status CHECK(status IN ('DRAFT','ISSUED','PAID','VOID')));
END;
GO
IF OBJECT_ID('dbo.vehicle_branch_transfers','U') IS NULL
BEGIN
 CREATE TABLE dbo.vehicle_branch_transfers(transfer_id INT IDENTITY(1,1) PRIMARY KEY,vehicle_id VARCHAR(20) NOT NULL,from_branch_id VARCHAR(20) NULL,to_branch_id VARCHAR(20) NOT NULL,transfer_date DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),transferred_by VARCHAR(20) NULL,notes VARCHAR(300) NULL,CONSTRAINT FK_transfer_vehicle FOREIGN KEY(vehicle_id) REFERENCES dbo.vehicles(vehicle_id),CONSTRAINT FK_transfer_from_branch FOREIGN KEY(from_branch_id) REFERENCES dbo.branches(branch_id),CONSTRAINT FK_transfer_to_branch FOREIGN KEY(to_branch_id) REFERENCES dbo.branches(branch_id),CONSTRAINT FK_transfer_user FOREIGN KEY(transferred_by) REFERENCES dbo.users(user_id));
END;
GO
IF OBJECT_ID('dbo.feedback','U') IS NULL
BEGIN
 CREATE TABLE dbo.feedback(feedback_id VARCHAR(20) NOT NULL PRIMARY KEY,customer_id VARCHAR(20) NOT NULL,booking_id VARCHAR(20) NULL,vehicle_id VARCHAR(20) NULL,rating INT NOT NULL,comment VARCHAR(1000) NULL,review_type VARCHAR(20) NOT NULL DEFAULT 'PUBLIC',status VARCHAR(20) NOT NULL DEFAULT 'VISIBLE',created_at DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),updated_at DATETIME2(0) NULL,CONSTRAINT FK_feedback_customer FOREIGN KEY(customer_id) REFERENCES dbo.customers(customer_id),CONSTRAINT FK_feedback_booking FOREIGN KEY(booking_id) REFERENCES dbo.bookings(booking_id),CONSTRAINT FK_feedback_vehicle FOREIGN KEY(vehicle_id) REFERENCES dbo.vehicles(vehicle_id),CONSTRAINT CK_feedback_rating CHECK(rating BETWEEN 1 AND 5),CONSTRAINT CK_feedback_status CHECK(status IN ('VISIBLE','HIDDEN','FLAGGED','REMOVED')));
END;
GO
IF OBJECT_ID('dbo.notifications','U') IS NULL
BEGIN
 CREATE TABLE dbo.notifications(notification_id VARCHAR(30) NOT NULL PRIMARY KEY,recipient_user_id VARCHAR(20) NOT NULL,notification_type VARCHAR(40) NOT NULL,title VARCHAR(180) NOT NULL,message VARCHAR(1000) NOT NULL,is_read BIT NOT NULL DEFAULT 0,related_booking_id VARCHAR(20) NULL,created_at DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),read_at DATETIME2(0) NULL,CONSTRAINT FK_notifications_user FOREIGN KEY(recipient_user_id) REFERENCES dbo.users(user_id),CONSTRAINT FK_notifications_booking FOREIGN KEY(related_booking_id) REFERENCES dbo.bookings(booking_id));
END;
GO

/* Older progress schemas already contain maintenance/inspections; add Java-required FKs/columns where absent. */
IF OBJECT_ID('dbo.maintenance_records','U') IS NOT NULL AND COL_LENGTH('dbo.maintenance_records','created_by') IS NULL ALTER TABLE dbo.maintenance_records ADD created_by VARCHAR(20) NULL;
IF OBJECT_ID('dbo.maintenance_records','U') IS NOT NULL AND COL_LENGTH('dbo.maintenance_records','completed_by') IS NULL ALTER TABLE dbo.maintenance_records ADD completed_by VARCHAR(20) NULL;
IF OBJECT_ID('dbo.inspections','U') IS NOT NULL AND COL_LENGTH('dbo.inspections','inspector_id') IS NULL ALTER TABLE dbo.inspections ADD inspector_id VARCHAR(20) NULL;
GO

/* ---- Integrity indexes, created only if the existing data permits them ---- */
IF OBJECT_ID('dbo.bookings','U') IS NOT NULL AND NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name='IX_bookings_vehicle_dates' AND object_id=OBJECT_ID('dbo.bookings')) CREATE INDEX IX_bookings_vehicle_dates ON dbo.bookings(vehicle_id,start_date,end_date,status);
IF OBJECT_ID('dbo.payments','U') IS NOT NULL AND NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name='IX_payments_booking' AND object_id=OBJECT_ID('dbo.payments')) CREATE INDEX IX_payments_booking ON dbo.payments(booking_id,payment_date DESC);
IF OBJECT_ID('dbo.notifications','U') IS NOT NULL AND NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name='IX_notifications_recipient_read' AND object_id=OBJECT_ID('dbo.notifications')) CREATE INDEX IX_notifications_recipient_read ON dbo.notifications(recipient_user_id,is_read,created_at DESC);
GO
IF OBJECT_ID('dbo.payments','U') IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.payments WHERE status='SUCCESS' GROUP BY booking_id HAVING COUNT(*)>1) AND NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name='UX_payments_booking_success' AND object_id=OBJECT_ID('dbo.payments')) CREATE UNIQUE INDEX UX_payments_booking_success ON dbo.payments(booking_id) WHERE status='SUCCESS';
IF OBJECT_ID('dbo.payments','U') IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.payments WHERE status='PENDING' GROUP BY booking_id HAVING COUNT(*)>1) AND NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name='UX_payments_booking_pending' AND object_id=OBJECT_ID('dbo.payments')) CREATE UNIQUE INDEX UX_payments_booking_pending ON dbo.payments(booking_id) WHERE status='PENDING';
IF OBJECT_ID('dbo.invoices','U') IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.invoices GROUP BY booking_id HAVING COUNT(*)>1) AND NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name='UX_invoices_booking' AND object_id=OBJECT_ID('dbo.invoices')) CREATE UNIQUE INDEX UX_invoices_booking ON dbo.invoices(booking_id);
GO
IF OBJECT_ID('dbo.feedback','U') IS NOT NULL AND COL_LENGTH('dbo.feedback','active_booking_id') IS NULL ALTER TABLE dbo.feedback ADD active_booking_id AS (CASE WHEN booking_id IS NOT NULL AND status <> 'REMOVED' THEN booking_id END) PERSISTED;
GO
IF OBJECT_ID('dbo.feedback','U') IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.feedback WHERE active_booking_id IS NOT NULL GROUP BY active_booking_id HAVING COUNT(*)>1) AND NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name='UX_feedback_active_booking' AND object_id=OBJECT_ID('dbo.feedback')) CREATE UNIQUE INDEX UX_feedback_active_booking ON dbo.feedback(active_booking_id) WHERE active_booking_id IS NOT NULL;
GO

/* ---- Expanded demo fleet and safe image backfill (non-destructive) ---- */
GO
/* Additional demo fleet - cars and passenger vans only */
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V041')
    INSERT dbo.vehicles(vehicle_id,plate_no,make,model,vehicle_year,transmission,fuel_type,seats,mileage,daily_rate,status,category_id,branch_id,image_url,registration_expiry,insurance_expiry,permit_expiry,vehicle_type)
    VALUES ('V041','CAX-3041','Toyota','Aqua',2021,'AUTOMATIC','HYBRID',5,32500,5000,'AVAILABLE','CAT004','BR001','/images/vehicles/toyota-aqua.jpg','2027-10-31','2027-10-31',NULL,'Car');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V042')
    INSERT dbo.vehicles(vehicle_id,plate_no,make,model,vehicle_year,transmission,fuel_type,seats,mileage,daily_rate,status,category_id,branch_id,image_url,registration_expiry,insurance_expiry,permit_expiry,vehicle_type)
    VALUES ('V042','CBE-3042','Honda','Fit',2020,'AUTOMATIC','PETROL',5,41700,4000,'AVAILABLE','CAT001','BR002','/images/vehicles/honda-fit.jpg','2027-08-31','2027-08-31',NULL,'Car');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V043')
    INSERT dbo.vehicles(vehicle_id,plate_no,make,model,vehicle_year,transmission,fuel_type,seats,mileage,daily_rate,status,category_id,branch_id,image_url,registration_expiry,insurance_expiry,permit_expiry,vehicle_type)
    VALUES ('V043','CAD-3043','Honda','Vezel',2021,'AUTOMATIC','HYBRID',5,38200,7500,'AVAILABLE','CAT003','BR002','/images/vehicles/honda-vezel.jpg','2027-11-30','2027-11-30',NULL,'Car');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V044')
    INSERT dbo.vehicles(vehicle_id,plate_no,make,model,vehicle_year,transmission,fuel_type,seats,mileage,daily_rate,status,category_id,branch_id,image_url,registration_expiry,insurance_expiry,permit_expiry,vehicle_type)
    VALUES ('V044','CBF-3044','Toyota','Corolla',2022,'AUTOMATIC','PETROL',5,24600,6000,'AVAILABLE','CAT002','BR003','/images/vehicles/toyota-corolla.jpg','2028-01-31','2028-01-31',NULL,'Car');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V045')
    INSERT dbo.vehicles(vehicle_id,plate_no,make,model,vehicle_year,transmission,fuel_type,seats,mileage,daily_rate,status,category_id,branch_id,image_url,registration_expiry,insurance_expiry,permit_expiry,vehicle_type)
    VALUES ('V045','CAG-3045','Toyota','Axio Hybrid',2020,'AUTOMATIC','HYBRID',5,44500,5500,'AVAILABLE','CAT004','BR001','/images/vehicles/toyota-axio-hybrid.jpg','2027-09-30','2027-09-30',NULL,'Car');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V046')
    INSERT dbo.vehicles(vehicle_id,plate_no,make,model,vehicle_year,transmission,fuel_type,seats,mileage,daily_rate,status,category_id,branch_id,image_url,registration_expiry,insurance_expiry,permit_expiry,vehicle_type)
    VALUES ('V046','CAQ-3046','Nissan','X-Trail',2020,'AUTOMATIC','PETROL',5,53800,8500,'AVAILABLE','CAT003','BR003','/images/vehicles/nissan-xtrail.jpg','2027-06-30','2027-06-30',NULL,'Car');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V047')
    INSERT dbo.vehicles(vehicle_id,plate_no,make,model,vehicle_year,transmission,fuel_type,seats,mileage,daily_rate,status,category_id,branch_id,image_url,registration_expiry,insurance_expiry,permit_expiry,vehicle_type)
    VALUES ('V047','CAY-3047','Suzuki','Alto',2021,'AUTOMATIC','PETROL',4,29900,3000,'AVAILABLE','CAT001','BR002','/images/vehicles/suzuki-alto.jpg','2027-12-31','2027-12-31',NULL,'Car');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V048')
    INSERT dbo.vehicles(vehicle_id,plate_no,make,model,vehicle_year,transmission,fuel_type,seats,mileage,daily_rate,status,category_id,branch_id,image_url,registration_expiry,insurance_expiry,permit_expiry,vehicle_type)
    VALUES ('V048','CBH-3048','Kia','Sportage',2022,'AUTOMATIC','PETROL',5,28100,9000,'AVAILABLE','CAT003','BR001','/images/vehicles/kia-sportage.jpg','2028-02-28','2028-02-28',NULL,'Car');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V049')
    INSERT dbo.vehicles(vehicle_id,plate_no,make,model,vehicle_year,transmission,fuel_type,seats,mileage,daily_rate,status,category_id,branch_id,image_url,registration_expiry,insurance_expiry,permit_expiry,vehicle_type)
    VALUES ('V049','CBK-3049','Hyundai','Elantra',2021,'AUTOMATIC','PETROL',5,36100,6200,'AVAILABLE','CAT002','BR002','/images/vehicles/hyundai-elantra.jpg','2027-11-30','2027-11-30',NULL,'Car');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V050')
    INSERT dbo.vehicles(vehicle_id,plate_no,make,model,vehicle_year,transmission,fuel_type,seats,mileage,daily_rate,status,category_id,branch_id,image_url,registration_expiry,insurance_expiry,permit_expiry,vehicle_type)
    VALUES ('V050','CBA-3050','Toyota','Prius',2021,'AUTOMATIC','HYBRID',5,34400,6500,'AVAILABLE','CAT004','BR003','/images/vehicles/toyota-prius.jpg','2027-10-31','2027-10-31',NULL,'Car');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V051')
    INSERT dbo.vehicles(vehicle_id,plate_no,make,model,vehicle_year,transmission,fuel_type,seats,mileage,daily_rate,status,category_id,branch_id,image_url,registration_expiry,insurance_expiry,permit_expiry,vehicle_type)
    VALUES ('V051','NCF-3051','Toyota','KDH Hiace',2020,'AUTOMATIC','DIESEL',12,58400,15000,'AVAILABLE','CAT005','BR002','/images/vehicles/toyota-kdh-hiace.jpg','2027-09-30','2027-09-30','2027-09-30','Van');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V052')
    INSERT dbo.vehicles(vehicle_id,plate_no,make,model,vehicle_year,transmission,fuel_type,seats,mileage,daily_rate,status,category_id,branch_id,image_url,registration_expiry,insurance_expiry,permit_expiry,vehicle_type)
    VALUES ('V052','NCG-3052','Nissan','Caravan',2021,'AUTOMATIC','DIESEL',12,51300,14000,'AVAILABLE','CAT005','BR003','/images/vehicles/nissan-caravan.jpg','2027-12-31','2027-12-31','2027-12-31','Van');


/* Normalize known demo-fleet image paths to packaged local assets.
   Existing custom non-Wikimedia image URLs are preserved. */
UPDATE dbo.vehicles SET image_url='/images/vehicles/mitsubishi-montero.jpg' WHERE vehicle_id='V011' AND (image_url IS NULL OR LTRIM(RTRIM(image_url))='' OR image_url LIKE 'https://upload.wikimedia.org/%');
UPDATE dbo.vehicles SET image_url='/images/vehicles/mazda-3.jpg' WHERE vehicle_id='V018' AND (image_url IS NULL OR LTRIM(RTRIM(image_url))='' OR image_url LIKE 'https://upload.wikimedia.org/%');
UPDATE dbo.vehicles SET image_url='/images/vehicles/toyota-camry-hybrid.jpg' WHERE vehicle_id='V021' AND (image_url IS NULL OR LTRIM(RTRIM(image_url))='' OR image_url LIKE 'https://upload.wikimedia.org/%');
UPDATE dbo.vehicles SET image_url='/images/vehicles/toyota-prado.jpg' WHERE vehicle_id='V026' AND (image_url IS NULL OR LTRIM(RTRIM(image_url))='' OR image_url LIKE 'https://upload.wikimedia.org/%');
UPDATE dbo.vehicles SET image_url='/images/vehicles/suzuki-wagon-r.jpg' WHERE vehicle_id='V031' AND (image_url IS NULL OR LTRIM(RTRIM(image_url))='' OR image_url LIKE 'https://upload.wikimedia.org/%');
UPDATE dbo.vehicles SET image_url='/images/vehicles/suzuki-swift.jpg' WHERE vehicle_id='V032' AND (image_url IS NULL OR LTRIM(RTRIM(image_url))='' OR image_url LIKE 'https://upload.wikimedia.org/%');
UPDATE dbo.vehicles SET image_url='/images/vehicles/nissan-leaf.jpg' WHERE vehicle_id='V038' AND (image_url IS NULL OR LTRIM(RTRIM(image_url))='' OR image_url LIKE 'https://upload.wikimedia.org/%');
UPDATE dbo.vehicles SET image_url='/images/vehicles/tesla-model-3.jpg' WHERE vehicle_id='V039' AND (image_url IS NULL OR LTRIM(RTRIM(image_url))='' OR image_url LIKE 'https://upload.wikimedia.org/%');
UPDATE dbo.vehicles SET image_url='/images/vehicles/toyota-hiace.jpg' WHERE vehicle_id='V040' AND (image_url IS NULL OR LTRIM(RTRIM(image_url))='' OR image_url LIKE 'https://upload.wikimedia.org/%');
UPDATE dbo.vehicles SET image_url='/images/vehicles/toyota-aqua.jpg' WHERE vehicle_id='V041' AND (image_url IS NULL OR LTRIM(RTRIM(image_url))='' OR image_url LIKE 'https://upload.wikimedia.org/%');
UPDATE dbo.vehicles SET image_url='/images/vehicles/honda-fit.jpg' WHERE vehicle_id='V042' AND (image_url IS NULL OR LTRIM(RTRIM(image_url))='' OR image_url LIKE 'https://upload.wikimedia.org/%');
UPDATE dbo.vehicles SET image_url='/images/vehicles/honda-vezel.jpg' WHERE vehicle_id='V043' AND (image_url IS NULL OR LTRIM(RTRIM(image_url))='' OR image_url LIKE 'https://upload.wikimedia.org/%');
UPDATE dbo.vehicles SET image_url='/images/vehicles/toyota-corolla.jpg' WHERE vehicle_id='V044' AND (image_url IS NULL OR LTRIM(RTRIM(image_url))='' OR image_url LIKE 'https://upload.wikimedia.org/%');
UPDATE dbo.vehicles SET image_url='/images/vehicles/toyota-axio-hybrid.jpg' WHERE vehicle_id='V045' AND (image_url IS NULL OR LTRIM(RTRIM(image_url))='' OR image_url LIKE 'https://upload.wikimedia.org/%');
UPDATE dbo.vehicles SET image_url='/images/vehicles/nissan-xtrail.jpg' WHERE vehicle_id='V046' AND (image_url IS NULL OR LTRIM(RTRIM(image_url))='' OR image_url LIKE 'https://upload.wikimedia.org/%');
UPDATE dbo.vehicles SET image_url='/images/vehicles/suzuki-alto.jpg' WHERE vehicle_id='V047' AND (image_url IS NULL OR LTRIM(RTRIM(image_url))='' OR image_url LIKE 'https://upload.wikimedia.org/%');
UPDATE dbo.vehicles SET image_url='/images/vehicles/kia-sportage.jpg' WHERE vehicle_id='V048' AND (image_url IS NULL OR LTRIM(RTRIM(image_url))='' OR image_url LIKE 'https://upload.wikimedia.org/%');
UPDATE dbo.vehicles SET image_url='/images/vehicles/hyundai-elantra.jpg' WHERE vehicle_id='V049' AND (image_url IS NULL OR LTRIM(RTRIM(image_url))='' OR image_url LIKE 'https://upload.wikimedia.org/%');
UPDATE dbo.vehicles SET image_url='/images/vehicles/toyota-prius.jpg' WHERE vehicle_id='V050' AND (image_url IS NULL OR LTRIM(RTRIM(image_url))='' OR image_url LIKE 'https://upload.wikimedia.org/%');
UPDATE dbo.vehicles SET image_url='/images/vehicles/toyota-kdh-hiace.jpg' WHERE vehicle_id='V051' AND (image_url IS NULL OR LTRIM(RTRIM(image_url))='' OR image_url LIKE 'https://upload.wikimedia.org/%');
UPDATE dbo.vehicles SET image_url='/images/vehicles/nissan-caravan.jpg' WHERE vehicle_id='V052' AND (image_url IS NULL OR LTRIM(RTRIM(image_url))='' OR image_url LIKE 'https://upload.wikimedia.org/%');
GO

PRINT 'RideLanka FleetHire update patch completed without recreating the database.';
GO
