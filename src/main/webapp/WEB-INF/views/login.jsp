<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Sign in — RideLanka FleetHire</title>
  <link rel="preconnect" href="https://fonts.googleapis.com"/>
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@500;600;700&family=Space+Grotesk:wght@500;600;700&family=Bebas+Neue&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/vrms-theme.css"/>
  <style>
    body { background: var(--bx-night); }

    .auth-split { display: grid; grid-template-columns: 1.05fr 1fr; min-height: 100dvh; }

    /* ─ Left poster (already dark) ─ */
    .auth-poster {
      position: relative;
      padding: 48px 56px;
      background:
        linear-gradient(180deg, rgba(5,9,18,0.55) 0%, rgba(5,9,18,0.92) 100%),
        url('${pageContext.request.contextPath}/images/hero-sunset-drive.png') center/cover no-repeat,
        var(--bx-night);
      color: #fff;
      display: flex; flex-direction: column; justify-content: space-between;
      overflow: hidden;
    }
    .auth-poster::after {
      content: ""; position: absolute; inset: 0; pointer-events: none;
      background: radial-gradient(50% 50% at 90% 10%, rgba(111,203,163,0.18) 0%, transparent 60%);
    }
    .auth-brand { display: flex; align-items: center; gap: 14px; position: relative; z-index: 1; }
    .auth-brand img { height: 52px; width: auto; border-radius: 14px; }
    .auth-brand__text { line-height: 1; display: flex; flex-direction: column; align-items: center; }
    .auth-brand__text .brand {
      font-family: 'Space Grotesk', var(--font-sans);
      font-weight: 700; font-size: 22px;
      letter-spacing: 0.04em;
      color: #fff;
    }
    .auth-brand__text small {
      margin-top: 4px;
      font-family: 'Space Grotesk', var(--font-sans);
      font-size: 9px; font-weight: 500;
      letter-spacing: 0.10em; text-transform: uppercase;
      color: var(--bx-primary);
    }

    .auth-quote { position: relative; z-index: 1; margin-top: 48px; }
    .auth-eyebrow {
      display: inline-flex; align-items: center; gap: 8px;
      padding: 6px 14px; border-radius: 999px;
      background: rgba(111,203,163,0.10);
      border: 1px solid rgba(111,203,163,0.24);
      font-size: 11px; font-weight: 600;
      letter-spacing: 0.18em; text-transform: uppercase;
      color: var(--bx-primary); margin-bottom: 22px;
    }
    .auth-quote h1 {
      font-family: 'Manrope', var(--font-sans);
      font-size: clamp(38px, 4.4vw, 58px);
      font-weight: 600;
      letter-spacing: -0.035em;
      line-height: 1.04;
      color: #fff; max-width: 14ch;
    }
    .auth-quote h1 em { font-style: normal; color: var(--bx-primary); }
    .auth-quote p {
      font-size: 15px; line-height: 1.7;
      color: rgba(255,255,255,0.7);
      margin-top: 22px; max-width: 38ch;
    }
    .auth-foot {
      position: relative; z-index: 1;
      display: flex; justify-content: space-between;
      font-family: var(--font-mono); font-size: 11px;
      color: rgba(255,255,255,0.42); letter-spacing: 0.04em;
      border-top: 1px solid rgba(255,255,255,0.10); padding-top: 18px;
    }

    /* ─ Right form column ─ */
    .auth-form-col {
      display: flex; align-items: center; justify-content: center;
      padding: 48px 56px;
      background: var(--bx-night);
    }
    .auth-form-shell { width: 100%; max-width: 440px; }
    .auth-form-shell h2 {
      font-family: 'Manrope', var(--font-sans);
      font-size: 38px; font-weight: 600;
      letter-spacing: -0.030em;
      line-height: 1.1;
      color: #fff;
    }
    .auth-form-shell h2 em { font-style: normal; color: var(--bx-primary); }
    .auth-form-shell .lede {
      font-size: 15px;
      color: rgba(255,255,255,0.65);
      margin-top: 12px; line-height: 1.6;
    }

    /* Glass form card wrapping the inputs */
    .auth-form {
      margin-top: 32px;
      padding: 28px;
      background: var(--glass-bg);
      -webkit-backdrop-filter: blur(20px) saturate(180%);
              backdrop-filter: blur(20px) saturate(180%);
      border: 1px solid var(--glass-border);
      border-radius: var(--r-shell);
      box-shadow: var(--glass-shadow);
    }

    /* Field styling */
    .auth-fld { display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; }
    .auth-fld:last-of-type { margin-bottom: 28px; }
    .auth-fld__lbl {
      font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase;
      font-weight: 600; color: rgba(255,255,255,0.55);
    }
    .auth-fld__lbl .req { color: var(--bx-danger); margin-left: 3px; }
    .auth-fld__wrap { position: relative; }
    .auth-fld__wrap i {
      position: absolute; left: 14px; top: 50%; transform: translateY(-50%);
      color: rgba(255,255,255,0.45);
      font-size: 16px; pointer-events: none;
    }
    .auth-fld input {
      width: 100%;
      background: rgba(255,255,255,0.04);
      border: 1px solid var(--glass-border);
      border-radius: var(--r-md);
      color: #fff;
      font-family: var(--font-sans);
      font-size: 14px;
      padding: 12px 14px 12px 42px;
      outline: none;
      transition: border-color var(--t-fast), background var(--t-fast);
    }
    .auth-fld input:focus {
      border-color: var(--bx-primary);
      background: rgba(111,203,163,0.06);
    }
    .auth-fld input::placeholder { color: rgba(255,255,255,0.34); }

    .auth-cta {
      width: 100%;
      justify-content: center;
    }

    .auth-divider {
      display: flex; align-items: center; gap: 12px;
      color: rgba(255,255,255,0.4); font-size: 11px;
      letter-spacing: 0.18em; text-transform: uppercase;
      margin: 24px 0 18px;
    }
    .auth-divider::before, .auth-divider::after {
      content: ''; flex: 1; height: 1px;
      background: var(--glass-border);
    }
    .auth-switch {
      text-align: center; font-size: 14px;
      color: rgba(255,255,255,0.6);
    }
    .auth-switch a {
      color: var(--bx-primary); font-weight: 600; text-decoration: none;
      border-bottom: 1px solid rgba(111,203,163,0.32);
      transition: border-color var(--t-fast);
    }
    .auth-switch a:hover { border-color: var(--bx-primary); }

    /* Alerts (in-form) */
    .auth-alert {
      padding: 12px 14px;
      border-radius: var(--r-md);
      display: flex; gap: 10px; align-items: flex-start;
      font-size: 13px;
      margin-bottom: 18px;
    }
    .auth-alert i { font-size: 18px; flex-shrink: 0; margin-top: 1px; }
    .auth-alert--ok  { background: rgba(111,203,163,0.10); border: 1px solid rgba(111,203,163,0.32); color: rgba(255,255,255,0.85); }
    .auth-alert--ok i { color: var(--bx-primary); }
    .auth-alert--info { background: rgba(125,211,252,0.08); border: 1px solid rgba(125,211,252,0.24); color: rgba(255,255,255,0.85); }
    .auth-alert--info i { color: var(--bx-info); }
    .auth-alert--err { background: rgba(248,113,113,0.10); border: 1px solid rgba(248,113,113,0.32); color: rgba(255,255,255,0.85); }
    .auth-alert--err i { color: var(--bx-danger); }
    .auth-alert strong { color: #fff; }

    @media (max-width: 900px) {
      .auth-split { grid-template-columns: 1fr; }
      .auth-poster { padding: 36px 24px; min-height: 320px; }
      .auth-form-col { padding: 36px 24px; }
      .auth-quote { margin-top: 28px; }
      .auth-quote h1 { font-size: 36px; }
      .auth-form { padding: 22px; }
    }
  </style>
</head>
<body>

<div class="auth-split">

  <aside class="auth-poster">
    <a href="${pageContext.request.contextPath}/" class="auth-brand" style="text-decoration:none;">
      <img src="${pageContext.request.contextPath}/images/vrms-logo.png" alt="RideLanka FleetHire"/>
      <div class="auth-brand__text">
        <span class="brand">RideLanka FleetHire</span>
        <small>&mdash; Vehicle Rental &mdash;</small>
      </div>
    </a>

    <div class="auth-quote">
      <span class="auth-eyebrow">Welcome back</span>
      <h1>The island,<br/><em>and a key.</em></h1>
      <p>
        Sign in to manage your reservations, settle payments, and revisit
        the drives that have shaped your itinerary so far.
      </p>
    </div>

    <div class="auth-foot">
      <span>[ Colombo &middot; Galle &middot; Kandy ]</span>
      <span>v. 3.0 &mdash; Seafoam</span>
    </div>
  </aside>

  <section class="auth-form-col">
    <div class="auth-form-shell">
      <h2>Sign in to<br/>your <em>account.</em></h2>
      <p class="lede">Continue where you left off &mdash; reservations, payments, reviews, all in one place.</p>

      <div class="auth-form">

        <c:if test="${param.msg == 'registered'}">
          <div class="auth-alert auth-alert--ok">
            <i class="ti ti-circle-check"></i>
            <div><strong>Account created.</strong><br/>Please sign in to begin.</div>
          </div>
        </c:if>
        <c:if test="${param.msg == 'deleted'}">
          <div class="auth-alert auth-alert--info">
            <i class="ti ti-info-circle"></i>
            <div>Your account has been deactivated.</div>
          </div>
        </c:if>
        <c:if test="${param.msg == 'passwordChanged'}">
          <div class="auth-alert auth-alert--ok">
            <i class="ti ti-shield-check"></i>
            <div><strong>Password changed.</strong><br/>You can now sign in with your new password.</div>
          </div>
        </c:if>
        <c:if test="${param.error == 'db'}">
          <div class="auth-alert auth-alert--err"><i class="ti ti-database-off"></i><div><strong>Database connection failed.</strong><br/>Please try again or contact the system administrator.</div></div>
        </c:if>
        <c:if test="${param.error == 'invalid'}">
          <div class="auth-alert auth-alert--err">
            <i class="ti ti-alert-circle"></i>
            <div><strong>Couldn't sign you in.</strong><br/>The email or password didn't match.</div>
          </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/user/login" method="post">
          <div class="auth-fld">
            <label class="auth-fld__lbl" for="email">Email address<span class="req">*</span></label>
            <div class="auth-fld__wrap">
              <i class="ti ti-mail"></i>
              <input type="email" id="email" name="email"
                     placeholder="kamal@example.com" maxlength="180" autocomplete="email" required autofocus/>
            </div>
          </div>

          <div class="auth-fld">
            <label class="auth-fld__lbl" for="password">Password<span class="req">*</span></label>
            <div class="auth-fld__wrap">
              <i class="ti ti-lock"></i>
              <input type="password" id="password" name="password"
                     placeholder="Enter your password" maxlength="200" autocomplete="current-password" required/>
            </div>
          </div>

          <button type="submit" class="btn btn-primary btn-lg auth-cta" data-antigravity>
            Sign in
            <span class="ico-pill"><i class="ti ti-arrow-right"></i></span>
          </button>
        </form>

        <div class="auth-switch" style="margin-top:16px;">
          Know your current password but need a new one?
          <a href="${pageContext.request.contextPath}/change-password">Change password</a>
        </div>

        <div class="auth-divider">or</div>

        <div class="auth-switch">
          New to RideLanka?
          <a href="${pageContext.request.contextPath}/register">Open an account</a>
        </div>
      </div>
    </div>
  </section>
</div>

</body>
</html>
