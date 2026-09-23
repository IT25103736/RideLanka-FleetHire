<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Create your RideLanka account — VRMS</title>
  <link rel="preconnect" href="https://fonts.googleapis.com"/>
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@500;600;700&family=Space+Grotesk:wght@500;600;700&family=Bebas+Neue&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/vrms-theme.css"/>
  <style>
    body { background: var(--bx-night); }

    .auth-split { display: grid; grid-template-columns: 1.05fr 1fr; min-height: 100dvh; }

    .auth-poster {
      position: relative; padding: 48px 56px;
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
      letter-spacing: 0.04em; color: #fff;
    }
    .auth-brand__text small {
      margin-top: 4px;
      font-family: 'Space Grotesk', var(--font-sans);
      font-size: 9px; font-weight: 500;
      letter-spacing: 0.10em; text-transform: uppercase;
      color: var(--bx-primary);
    }

    .auth-quote { position: relative; z-index: 1; margin-top: 36px; }
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
      font-size: clamp(34px, 4.2vw, 56px);
      font-weight: 600;
      letter-spacing: -0.035em;
      line-height: 1.04;
      color: #fff; max-width: 14ch;
    }
    .auth-quote h1 em { font-style: normal; color: var(--bx-primary); }
    .auth-quote p {
      font-size: 15px; line-height: 1.7;
      color: rgba(255,255,255,0.7);
      margin-top: 22px; max-width: 40ch;
    }
    .auth-perks {
      position: relative; z-index: 1;
      display: flex; flex-direction: column; gap: 12px;
      margin-top: 26px;
    }
    .auth-perks .perk {
      display: flex; align-items: center; gap: 12px;
      font-size: 14px; color: rgba(255,255,255,0.88);
    }
    .auth-perks .perk i {
      width: 30px; height: 30px; border-radius: 50%;
      background: rgba(111,203,163,0.18);
      border: 1px solid rgba(111,203,163,0.32);
      display: inline-flex; align-items: center; justify-content: center;
      font-size: 14px; color: var(--bx-primary);
      flex-shrink: 0;
    }
    .auth-foot {
      position: relative; z-index: 1;
      display: flex; justify-content: space-between;
      font-family: var(--font-mono); font-size: 11px;
      color: rgba(255,255,255,0.42); letter-spacing: 0.04em;
      border-top: 1px solid rgba(255,255,255,0.10); padding-top: 18px;
    }

    /* Right form column */
    .auth-form-col {
      display: flex; align-items: center; justify-content: center;
      padding: 48px 56px;
      background: var(--bx-night);
    }
    .auth-form-shell { width: 100%; max-width: 460px; }
    .auth-form-shell h2 {
      font-family: 'Manrope', var(--font-sans);
      font-size: 38px; font-weight: 600;
      letter-spacing: -0.030em; line-height: 1.1;
      color: #fff;
    }
    .auth-form-shell h2 em { font-style: normal; color: var(--bx-primary); }
    .auth-form-shell .lede {
      font-size: 15px; color: rgba(255,255,255,0.65);
      margin-top: 12px; line-height: 1.6;
    }

    .auth-form {
      margin-top: 28px;
      padding: 28px;
      background: var(--glass-bg);
      -webkit-backdrop-filter: blur(20px) saturate(180%);
              backdrop-filter: blur(20px) saturate(180%);
      border: 1px solid var(--glass-border);
      border-radius: var(--r-shell);
      box-shadow: var(--glass-shadow);
    }

    .auth-fld { display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; }
    .auth-fld:last-of-type { margin-bottom: 26px; }
    .auth-fld__lbl {
      font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase;
      font-weight: 600; color: rgba(255,255,255,0.55);
    }
    .auth-fld__lbl .req { color: var(--bx-danger); margin-left: 3px; }
    .auth-fld input {
      width: 100%;
      background: rgba(255,255,255,0.04);
      border: 1px solid var(--glass-border);
      border-radius: var(--r-md);
      color: #fff;
      font-family: var(--font-sans);
      font-size: 14px;
      padding: 12px 14px;
      outline: none;
      transition: border-color var(--t-fast), background var(--t-fast);
    }
    .auth-fld input:focus {
      border-color: var(--bx-primary);
      background: rgba(111,203,163,0.06);
    }
    .auth-fld input::placeholder { color: rgba(255,255,255,0.34); }
    .auth-fld__hint {
      font-size: 11px;
      color: rgba(255,255,255,0.5);
      margin-top: 4px;
    }

    .auth-cta { width: 100%; justify-content: center; }

    .auth-switch {
      text-align: center; font-size: 14px;
      color: rgba(255,255,255,0.6);
      margin-top: 24px;
    }
    .auth-switch a {
      color: var(--bx-primary); font-weight: 600; text-decoration: none;
      border-bottom: 1px solid rgba(111,203,163,0.32);
      transition: border-color var(--t-fast);
    }
    .auth-switch a:hover { border-color: var(--bx-primary); }

    .auth-alert {
      padding: 12px 14px;
      border-radius: var(--r-md);
      display: flex; gap: 10px; align-items: flex-start;
      font-size: 13px;
      margin-bottom: 18px;
    }
    .auth-alert i { font-size: 18px; flex-shrink: 0; margin-top: 1px; }
    .auth-alert--err { background: rgba(248,113,113,0.10); border: 1px solid rgba(248,113,113,0.32); color: rgba(255,255,255,0.85); }
    .auth-alert--err i { color: var(--bx-danger); }
    .auth-alert strong { color: #fff; }

    @media (max-width: 900px) {
      .auth-split { grid-template-columns: 1fr; }
      .auth-poster { padding: 36px 24px; min-height: 320px; }
      .auth-form-col { padding: 36px 24px; }
      .auth-quote { margin-top: 24px; }
      .auth-quote h1 { font-size: 32px; }
      .auth-form { padding: 22px; }
    }
  </style>
</head>
<body>

<div class="auth-split">

  <aside class="auth-poster">
    <a href="${pageContext.request.contextPath}/" class="auth-brand" style="text-decoration:none;">
      <img src="${pageContext.request.contextPath}/images/vrms-logo.png" alt="VRMS"/>
      <div class="auth-brand__text">
        <span class="brand">VRMS</span>
        <small>&mdash; Vehicle Rental &mdash;</small>
      </div>
    </a>

    <div>
      <div class="auth-quote">
        <span class="auth-eyebrow">Complimentary membership</span>
        <h1>Begin a card,<br/>earn from <em>kilometre one.</em></h1>
        <p>
          Create your RideLanka account in under thirty seconds. No fees, no minimums &mdash;
          and a point credited for every LKR 1,000 you spend with us.
        </p>
      </div>

      <div class="auth-perks">
        <div class="perk"><i class="ti ti-check"></i> Loyalty points from your first booking</div>
        <div class="perk"><i class="ti ti-check"></i> Avurudu &amp; off-season offers in inbox</div>
        <div class="perk"><i class="ti ti-check"></i> One-tap re-booking on past vehicles</div>
      </div>
    </div>

    <div class="auth-foot">
      <span>[ No card required ]</span>
      <span>v. 3.0 &mdash; Seafoam</span>
    </div>
  </aside>

  <section class="auth-form-col">
    <div class="auth-form-shell">
      <h2>Open <em>an account.</em></h2>
      <p class="lede">Earn one loyalty point per LKR 1,000 spent &mdash; applied from your very first reservation.</p>

      <div class="auth-form">

        <% if ("emailExists".equals(request.getParameter("error"))) { %>
          <div class="auth-alert auth-alert--err">
            <i class="ti ti-alert-circle"></i>
            <div><strong>This email is already registered.</strong><br/>Try signing in instead.</div>
          </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/user/register" method="post">

          <div class="auth-fld">
            <label class="auth-fld__lbl" for="name">Full name<span class="req">*</span></label>
            <input type="text" id="name" name="name"
                   placeholder="e.g. Kamal Perera" required autofocus/>
          </div>

          <div class="auth-fld">
            <label class="auth-fld__lbl" for="email">Email address<span class="req">*</span></label>
            <input type="email" id="email" name="email"
                   placeholder="kamal@example.com" required/>
          </div>

          <div class="auth-fld">
            <label class="auth-fld__lbl" for="phone">Phone number<span class="req">*</span></label>
            <input type="tel" id="phone" name="phone" placeholder="077 123 4567" required/>
          </div>

          <div class="auth-fld">
            <label class="auth-fld__lbl" for="licenseNo">Driving licence / ID<span class="req">*</span></label>
            <input type="text" id="licenseNo" name="licenseNo" placeholder="B1234567" required/>
          </div>

          <div class="auth-fld">
            <label class="auth-fld__lbl" for="password">Password<span class="req">*</span></label>
            <input type="password" id="password" name="password"
                   placeholder="Min. 6 characters" required/>
            <div class="auth-fld__hint">Choose something memorable &mdash; six characters or more.</div>
          </div>

          <button type="submit" class="btn btn-primary btn-lg auth-cta" data-antigravity>
            Create account
            <span class="ico-pill"><i class="ti ti-arrow-right"></i></span>
          </button>
        </form>

        <div class="auth-switch">
          Already a member?
          <a href="${pageContext.request.contextPath}/login">Sign in instead</a>
        </div>
      </div>
    </div>
  </section>
</div>

</body>
</html>
