# Final furnishing pass — 2026-10-04

This pass intentionally preserves the existing RideLanka FleetHire Spring MVC/JSP/JDBC/MSSQL architecture and concentrates on User/Customer Management, Vehicle/Fleet presentation and validation.

## Changes
- Expanded the demo fleet from 9 to 21 vehicles: 18 cars and 3 passenger vans; no bikes/motorcycles were introduced.
- Added `image_url` values for every seeded vehicle and safe image-error fallbacks in customer/admin vehicle views.
- Added the same vehicles and image backfill to `database/update-patch.sql` using additive/conditional statements only.
- Connected the existing customer verification fields (`id_document_no`, `address_line`, `city`, `date_of_birth`, `verification_status`) to My Profile.
- Added Admin-only customer verification status management; customers can view but cannot self-verify.
- A VERIFIED profile returns to PENDING only when identity/verification data changes, not for ordinary name/email changes.
- Kept the Seafoam/dark-glass site theme and checked every top-level JSP for a theme source.
- Removed remaining Java scriptlets from `login.jsp` and retained JSTL-only message rendering.
- Aligned Fleet Maintenance input limits with MSSQL column/constraint sizes and strengthened client/server validation.
- Strengthened Vehicle Management field limits and requires an image URL for newly saved/edited vehicles.
- Admin create-user errors now preserve non-sensitive form fields; passwords are deliberately not preserved.

## Verification performed
- Changed Java classes compile with `javac --release 17` against the existing compiled application classes plus minimal Spring/Servlet API stubs.
- JSP structural checks: matching JSTL/form tags; no Java scriptlets; all top-level JSP pages have a shared/direct theme source.
- SQL seed check: 21 seeded vehicles, 0 seeded vehicle rows with a NULL image URL.
- Existing-database vehicle patch check: no `DROP DATABASE`, `TRUNCATE TABLE`, or vehicle-row delete operation.

## Environment limitation
A full Maven dependency build could not be executed in the sandbox because `mvnw` could not download Maven 3.9.12 from Maven Central. Run `mvnw.cmd clean package` on the normal development machine before final submission/deployment.


## Vehicle image packaging correction
Vehicle demo images are now packaged locally in `src/main/resources/static/images/vehicles/`. The seed SQL and non-destructive update patch use `/images/vehicles/...` paths. Known previous Wikimedia seed URLs are migrated to the local packaged paths without overwriting unrelated custom image URLs.


## Security email / password change addition
- Added optional SMTP email strategy using Spring Mail. Disabled by default and configured only through environment variables.
- Successful login and successful password changes can send a security email to the account's database email address. Mail failure is non-blocking.
- Added authenticated password change in My Profile and a sign-in-page Change Password route for users who still know their current password.
- Password changes verify the existing PBKDF2 hash and store a newly generated PBKDF2 hash; plain-text passwords are never persisted or emailed.
