USE RideLankaFleetHire;
GO
/* Run this only if your database was created with the older progress script. */
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.vehicles') AND name='vehicle_type')
    ALTER TABLE dbo.vehicles ADD vehicle_type VARCHAR(10) NOT NULL CONSTRAINT DF_vehicles_type_patch DEFAULT 'Car' WITH VALUES;
GO
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_users_role' AND parent_object_id=OBJECT_ID('dbo.users'))
    ALTER TABLE dbo.users DROP CONSTRAINT CK_users_role;
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_users_role' AND parent_object_id=OBJECT_ID('dbo.users'))
    ALTER TABLE dbo.users ADD CONSTRAINT CK_users_role CHECK (role IN ('CUSTOMER','BRANCH_STAFF','FINANCE','MAINTENANCE','FLEET','VEHICLE','ADMIN'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_vehicles_type' AND parent_object_id=OBJECT_ID('dbo.vehicles'))
    ALTER TABLE dbo.vehicles ADD CONSTRAINT CK_vehicles_type CHECK (vehicle_type IN ('Car'));
GO
IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE user_id='U007')
    INSERT dbo.users(user_id,name,email,password_hash,role,status,phone,license_no)
    VALUES ('U007','Vehicle Management Demo','vehicle@ridelanka.lk','PBKDF2$120000$3jbXQt3lYD2PsP0vJg6sZA==$yWu1UfCAq8CmpFOqI15qExqLlaD9T37xbFrC0pSyplI=','VEHICLE','ACTIVE','0716666666',NULL);
GO
IF NOT EXISTS (SELECT 1 FROM dbo.staff WHERE staff_id='S005')
    INSERT dbo.staff(staff_id,user_id,branch_id,employee_code,job_title)
    VALUES ('S005','U007','BR001','EMP-VH01','Vehicle Management Officer');
GO
SELECT user_id,email,role,status FROM dbo.users WHERE user_id IN ('U002','U004','U007') ORDER BY user_id;
SELECT vehicle_id,plate_no,make,model,status,vehicle_type,branch_id FROM dbo.vehicles ORDER BY vehicle_id;
GO

select * from users

select * from rental_checkouts
