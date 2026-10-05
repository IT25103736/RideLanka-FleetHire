# RideLanka FleetHire — SQL Server setup

Microsoft SQL Server is the application's only persistent data source.

## Fresh install

Run `current-schema.sql` only when `RideLankaFleetHire` does **not** already exist. The script intentionally throws instead of dropping or overwriting an existing database. It creates the schema, constraints, indexes and fresh-install demo data.

## Existing database

1. Back up the existing `RideLankaFleetHire` database.
2. Run `update-patch.sql`.
3. Do not run the fresh installer on that database.

`update-patch.sql` is non-destructive by design: it creates missing application objects/columns and integrity indexes without dropping the database or deleting existing rows. Existing data that conflicts with a new uniqueness rule is left intact and the corresponding index is skipped rather than deleting data automatically.

## Application connection

Configure these environment variables before starting the application:

```text
RIDELANKA_DB_URL=jdbc:sqlserver://localhost:1433;databaseName=RideLankaFleetHire;encrypt=false;trustServerCertificate=true
RIDELANKA_DB_USERNAME=sa
RIDELANKA_DB_PASSWORD=<your SQL Server password>
```

No real SQL Server password is stored in source code.
