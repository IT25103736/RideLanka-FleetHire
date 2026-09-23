USE RideLankaFleetHire;
GO

/* Demo credentials
   ADMIN: admin@ridelanka.lk / admin123
   MAINTENANCE: maint@ridelanka.lk / maint123
   CUSTOMER: kamal@ridelanka.lk / password
*/

IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE email='admin@ridelanka.lk')
INSERT dbo.users(user_id,name,email,password_hash,role,status,phone,license_no)
VALUES('U001','RideLanka Admin','admin@ridelanka.lk','PBKDF2$120000$3jbXQt3lYD2PsP0vJg6sZA==$yWu1UfCAq8CmpFOqI15qExqLlaD9T37xbFrC0pSyplI=','ADMIN','ACTIVE','0710000000',NULL);

IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE email='maint@ridelanka.lk')
INSERT dbo.users(user_id,name,email,password_hash,role,status,phone,license_no)
VALUES('U002','Fleet Maintenance Demo','maint@ridelanka.lk','PBKDF2$120000$UX4Wk957wgc55WT0z0mvOw==$n3L7Dl7mYAMyq3eUYeONvzv+sNSrehaOh2GxP42MTAE=','MAINTENANCE','ACTIVE','0711111111','NIC-MAINT-01');

IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE email='kamal@ridelanka.lk')
INSERT dbo.users(user_id,name,email,password_hash,role,status,phone,license_no)
VALUES('U003','Kamal Perera','kamal@ridelanka.lk','PBKDF2$120000$FfUh0gQqwzEkUkRxfs93hA==$MDiENs/V94PJ/hZ3KoPgCL80kjGqCqGahMbtohKcxsg=','CUSTOMER','ACTIVE','0772222222','B1234567');
GO
