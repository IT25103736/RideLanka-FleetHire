<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Change Password — RideLanka FleetHire</title>
  <link rel="preconnect" href="https://fonts.googleapis.com"/>
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@500;600;700&family=Space+Grotesk:wght@500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/vrms-theme.css"/>
  <style>
    *{box-sizing:border-box} body{margin:0;min-height:100dvh;background:var(--bx-night);color:#fff;font-family:'DM Sans',sans-serif}
    .auth-split{display:grid;grid-template-columns:1.05fr 1fr;min-height:100dvh}
    .auth-poster{position:relative;padding:48px 56px;background:linear-gradient(180deg,rgba(5,9,18,.55),rgba(5,9,18,.92)),url('${pageContext.request.contextPath}/images/hero-sunset-drive.png') center/cover no-repeat,var(--bx-night);display:flex;flex-direction:column;justify-content:space-between;overflow:hidden}
    .auth-poster:after{content:"";position:absolute;inset:0;pointer-events:none;background:radial-gradient(50% 50% at 90% 10%,rgba(111,203,163,.18),transparent 60%)}
    .auth-brand,.auth-copy,.auth-foot{position:relative;z-index:1}.auth-brand{display:flex;align-items:center;gap:14px;text-decoration:none}.auth-brand img{height:52px;border-radius:14px}.auth-brand strong{font:700 22px 'Space Grotesk',sans-serif;color:#fff}.auth-copy .eyebrow{display:inline-flex;align-items:center;gap:8px;padding:6px 14px;border-radius:999px;background:rgba(111,203,163,.10);border:1px solid rgba(111,203,163,.24);font-size:11px;font-weight:600;letter-spacing:.18em;text-transform:uppercase;color:var(--bx-primary);margin-bottom:22px}.auth-copy h1{font:600 clamp(34px,4.2vw,56px)/1.04 'Manrope',sans-serif;letter-spacing:-.035em;margin:0;max-width:12ch}.auth-copy h1 em{font-style:normal;color:var(--bx-primary)}.auth-copy p{max-width:40ch;color:rgba(255,255,255,.68);line-height:1.7}.auth-foot{display:flex;justify-content:space-between;border-top:1px solid rgba(255,255,255,.10);padding-top:18px;font:11px 'JetBrains Mono',monospace;color:rgba(255,255,255,.42)}
    .auth-form-col{display:flex;align-items:center;justify-content:center;padding:48px 56px}.auth-form-shell{width:100%;max-width:460px}.auth-form-shell h2{font:600 38px/1.1 'Manrope',sans-serif;letter-spacing:-.03em;margin:0}.auth-form-shell h2 em{font-style:normal;color:var(--bx-primary)}.lede{color:rgba(255,255,255,.65);line-height:1.6}.auth-form{margin-top:28px;padding:28px;background:var(--glass-bg);backdrop-filter:blur(20px) saturate(180%);border:1px solid var(--glass-border);border-radius:var(--r-shell);box-shadow:var(--glass-shadow)}
    .fld{display:flex;flex-direction:column;gap:6px;margin-bottom:17px}.fld label{font-size:10px;letter-spacing:.14em;text-transform:uppercase;font-weight:600;color:rgba(255,255,255,.55)}.fld input{width:100%;min-width:0;padding:12px 14px;border-radius:var(--r-md);border:1px solid var(--glass-border);background:rgba(255,255,255,.04);color:#fff;outline:none}.fld input:focus{border-color:var(--bx-primary);box-shadow:0 0 0 3px rgba(111,203,163,.08)}.fld small{font-size:11px;color:rgba(255,255,255,.45);line-height:1.45}.auth-cta{width:100%;justify-content:center;margin-top:6px}.switch{text-align:center;margin-top:20px;font-size:14px;color:rgba(255,255,255,.60)}.switch a{color:var(--bx-primary);font-weight:600;text-decoration:none}.alert{display:flex;gap:10px;padding:12px 14px;border-radius:var(--r-md);margin-bottom:18px;font-size:13px;line-height:1.5}.alert.err{background:rgba(248,113,113,.10);border:1px solid rgba(248,113,113,.32)}.alert i{color:#f87171;font-size:18px}
    @media(max-width:900px){.auth-split{grid-template-columns:1fr}.auth-poster{min-height:300px;padding:36px 24px}.auth-form-col{padding:36px 24px}.auth-form{padding:22px}}
  </style>
</head>
<body>
<div class="auth-split">
  <aside class="auth-poster">
    <a href="${pageContext.request.contextPath}/" class="auth-brand"><img src="${pageContext.request.contextPath}/images/vrms-logo.png" alt="RideLanka FleetHire"><strong>RideLanka FleetHire</strong></a>
    <div class="auth-copy"><span class="eyebrow"><i class="ti ti-shield-lock"></i> Account security</span><h1>Choose a new <em>password.</em></h1><p>This option is for customers who still know their current password. It verifies the existing password before any change is saved.</p></div>
    <div class="auth-foot"><span>[ Secure account update ]</span><span>Seafoam</span></div>
  </aside>
  <section class="auth-form-col">
    <div class="auth-form-shell">
      <h2>Change your<br/><em>password.</em></h2>
      <p class="lede">Enter your account email and current password, then choose a new password.</p>
      <div class="auth-form">
        <c:if test="${not empty param.error}">
          <div class="alert err"><i class="ti ti-alert-circle"></i><div><c:choose>
            <c:when test="${param.error == 'weak'}">New password must be 8–128 characters and contain at least one letter and one number.</c:when>
            <c:when test="${param.error == 'mismatch'}">The new password and confirmation do not match.</c:when>
            <c:when test="${param.error == 'same'}">Choose a new password that is different from your current password.</c:when>
            <c:when test="${param.error == 'db'}">The password could not be changed because of a database problem. Please try again.</c:when>
            <c:otherwise>The email or current password is incorrect.</c:otherwise>
          </c:choose></div></div>
        </c:if>
        <form action="${pageContext.request.contextPath}/user/change-password" method="post" id="passwordForm">
          <div class="fld"><label for="email">Email address *</label><input type="email" id="email" name="email" maxlength="180" autocomplete="email" required></div>
          <div class="fld"><label for="currentPassword">Current password *</label><input type="password" id="currentPassword" name="currentPassword" maxlength="128" autocomplete="current-password" required></div>
          <div class="fld"><label for="newPassword">New password *</label><input type="password" id="newPassword" name="newPassword" minlength="8" maxlength="128" pattern="(?=.*[A-Za-z])(?=.*[0-9]).{8,128}" autocomplete="new-password" required><small>At least 8 characters with one letter and one number.</small></div>
          <div class="fld"><label for="confirmPassword">Confirm new password *</label><input type="password" id="confirmPassword" name="confirmPassword" minlength="8" maxlength="128" autocomplete="new-password" required></div>
          <button type="submit" class="btn btn-primary btn-lg auth-cta">Change password <span class="ico-pill"><i class="ti ti-key"></i></span></button>
        </form>
        <div class="switch">Return to <a href="${pageContext.request.contextPath}/login">Sign in</a></div>
      </div>
    </div>
  </section>
</div>
<script>
  document.addEventListener('DOMContentLoaded',function(){
    const form=document.getElementById('passwordForm'),n=document.getElementById('newPassword'),c=document.getElementById('confirmPassword'),e=document.getElementById('email');
    function match(){c.setCustomValidity(c.value!==''&&n.value!==c.value?'Passwords do not match.':'');}
    n.addEventListener('input',match);c.addEventListener('input',match);
    form.addEventListener('submit',function(ev){e.value=e.value.trim();match();if(!form.checkValidity()){ev.preventDefault();form.reportValidity();}});
  });
</script>
</body>
</html>
