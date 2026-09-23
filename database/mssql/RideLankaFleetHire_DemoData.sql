USE RideLankaFleetHire;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.branches WHERE branch_id='BR001') INSERT dbo.branches VALUES('BR001','Kandy Branch','Kandy','Peradeniya Road, Kandy');
IF NOT EXISTS (SELECT 1 FROM dbo.branches WHERE branch_id='BR002') INSERT dbo.branches VALUES('BR002','Colombo Branch','Colombo','Duplication Road, Colombo 03');
IF NOT EXISTS (SELECT 1 FROM dbo.branches WHERE branch_id='BR003') INSERT dbo.branches VALUES('BR003','Galle Branch','Galle','Wakwella Road, Galle');

IF NOT EXISTS (SELECT 1 FROM dbo.vehicle_categories WHERE category_id='CAT001') INSERT dbo.vehicle_categories VALUES('CAT001','Economy');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicle_categories WHERE category_id='CAT002') INSERT dbo.vehicle_categories VALUES('CAT002','Sedan');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicle_categories WHERE category_id='CAT003') INSERT dbo.vehicle_categories VALUES('CAT003','SUV');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicle_categories WHERE category_id='CAT004') INSERT dbo.vehicle_categories VALUES('CAT004','Hybrid');

IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V011') INSERT dbo.vehicles VALUES('V011','CBB-2011','Mitsubishi','Montero',2018,'Automatic','Diesel',7,78200,9000,'AVAILABLE','CAT003','BR001','2027-03-31');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V018') INSERT dbo.vehicles VALUES('V018','CAX-2018','Mazda','3',2021,'Automatic','Petrol',5,46500,5200,'AVAILABLE','CAT002','BR002','2027-06-30');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V021') INSERT dbo.vehicles VALUES('V021','CAB-2021','Toyota','Camry Hybrid',2021,'Automatic','Hybrid',5,35400,6500,'AVAILABLE','CAT004','BR002','2027-11-30');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V026') INSERT dbo.vehicles VALUES('V026','CAG-2026','Toyota','Prado',2020,'Automatic','Diesel',7,61200,12000,'AVAILABLE','CAT003','BR003','2027-09-30');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V031') INSERT dbo.vehicles VALUES('V031','CAD-2031','Suzuki','Wagon R',2020,'Automatic','Petrol',4,52200,3000,'AVAILABLE','CAT001','BR001','2027-04-30');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V032') INSERT dbo.vehicles VALUES('V032','CBE-2032','Suzuki','Swift',2021,'Manual','Petrol',4,41800,3400,'AVAILABLE','CAT001','BR002','2027-05-31');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V038') INSERT dbo.vehicles VALUES('V038','CAB-2038','Nissan','Leaf',2021,'Automatic','Electric',5,27900,6500,'AVAILABLE','CAT004','BR003','2027-08-31');
IF NOT EXISTS (SELECT 1 FROM dbo.vehicles WHERE vehicle_id='V039') INSERT dbo.vehicles VALUES('V039','CBB-2039','Tesla','Model 3',2022,'Automatic','Electric',5,18200,11000,'AVAILABLE','CAT004','BR002','2027-12-31');

IF NOT EXISTS (SELECT 1 FROM dbo.maintenance_records WHERE maintenance_id='MT001')
INSERT dbo.maintenance_records VALUES('MT001','V011','SERVICE','Routine 10,000 km service','2026-09-15',NULL,8500,'Kandy Auto Care','SCHEDULED');
IF NOT EXISTS (SELECT 1 FROM dbo.maintenance_records WHERE maintenance_id='MT002')
INSERT dbo.maintenance_records VALUES('MT002','V018','REPAIR','Brake inspection and repair','2026-09-12','2026-09-12',14500,'Central Motor Works','COMPLETED');
IF NOT EXISTS (SELECT 1 FROM dbo.inspections WHERE vehicle_id='V018' AND maintenance_id='MT002')
INSERT dbo.inspections(vehicle_id,maintenance_id,inspection_date,result,notes) VALUES('V018','MT002','2026-09-12','PASS','Brakes checked; vehicle cleared for rental.');
GO
