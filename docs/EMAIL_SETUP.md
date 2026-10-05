# RideLanka FleetHire - Gmail SMTP setup

The application is configured to use the demo sender address `northamerica382@gmail.com`.

## Important
Google Gmail SMTP requires a **Google App Password** for username/password SMTP authentication.
Do not use or commit the Gmail account's normal sign-in password.

1. Sign in to the demo Google account.
2. Enable 2-Step Verification.
3. Create an App Password for the RideLanka demo.
4. In the same Windows Command Prompt used to start Spring Boot:

```bat
set RIDELANKA_MAIL_PASSWORD=YOUR_16_CHARACTER_GOOGLE_APP_PASSWORD
mvnw.cmd clean
mvnw.cmd spring-boot:run
```

The sender address, SMTP host and SMTP port already have safe defaults in `application.properties`.
You can override them with `RIDELANKA_MAIL_USERNAME`, `RIDELANKA_MAIL_FROM`, `RIDELANKA_MAIL_HOST` and `RIDELANKA_MAIL_PORT` if needed.

Email is best-effort. SMTP authentication/network errors are logged to the console but do not prevent a successful login or password change.
