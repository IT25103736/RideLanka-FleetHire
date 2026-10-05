# Final verification — RideLanka FleetHire

## Completed locally

- Reviewed the final Java source tree after the MSSQL migration.
- Compiled all Java application sources cleanly with `javac --release 17 -Xlint:all` against lightweight local Spring/Servlet API stubs. This verifies Java syntax, application type consistency, constructors and internal method calls without changing project source dependencies.
- Checked active Java/JSP code for legacy TXT repository/file-handler imports and removed the runtime TXT persistence path.
- Checked payment views/controllers so Finance renders `PaymentRecord` data from MSSQL and bank-transfer decisions use POST endpoints.
- Checked customer booking create/read/update/cancel paths and MSSQL status names (`PENDING`, `CONFIRMED`, `CANCELLED`).
- Checked server-side vehicle, booking, payment, feedback and fleet validations and parameterized JDBC usage.
- Checked configuration for committed database passwords; `RIDELANKA_DB_PASSWORD` is environment-provided with no password default.
- Replaced misleading stock vehicle fallbacks with a neutral no-photo state where a verified image URL is absent.
- Ran JSP structural checks for balanced JSTL loops/conditions and HTML forms; no mismatches were found.
- Cross-checked every `dbo.*` table referenced by active Java repositories against `database/current-schema.sql`; all referenced tables are present.
- Scanned active Java/JSP/SQL/configuration for legacy TXT persistence, visible old branding, committed database passwords and destructive database recreation statements in the canonical scripts.

## Environment limitations

A full Maven/Spring Boot startup and live MSSQL CRUD run could not be executed in the preparation container because Maven was not installed, the Maven wrapper could not fetch Maven from Maven Central in that environment, and no SQL Server instance was available there.

On the target development machine, run:

```bash
./mvnw clean package
./mvnw spring-boot:run
```

Then exercise the six module flows and use the SQL verification queries in the root `README.md` to confirm database changes.


## 2026-10-04 registration/login corrective patch
- Fixed `/user/login` session rotation: a new session is created after invalidating the old session.
- Fixed Admin create-user role validation to accept `BRANCH_STAFF`, matching the UI and database role constraint.
- Public and Admin registration forms now enforce the same password rule as the Java backend: minimum 8 characters, at least one letter and one digit.
- Registration pages now display validation/database errors instead of silently returning to the form.
- UserRepository registration remains transactional and now also creates a `staff` subtype for operational staff roles; subtype insert failures cause rollback.
- SQL exceptions during public/Admin user creation are logged with stack traces for diagnosis.
- Maven compile could not be executed in this environment because the Maven wrapper could not download Maven from repo.maven.apache.org.
