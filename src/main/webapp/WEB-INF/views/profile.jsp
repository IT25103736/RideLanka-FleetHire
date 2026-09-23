<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle"   value="Profile"  scope="request"/>
<c:set var="sectionName" value="Account"   scope="request"/>
<c:set var="activePage"  value="profile"   scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<c:set var="u" value="${sessionScope.loggedUser}"/>

<style>
  /* ════════════════════════════════════════════════════════════
     Profile — dark+glass identity + edit + danger zone
     ════════════════════════════════════════════════════════════ */
  .pr-grid {
    display: grid;
    grid-template-columns: 320px 1fr;
    gap: 22px;
    align-items: start;
  }
  @media (max-width: 900px) { .pr-grid { grid-template-columns: 1fr; } }

  /* Identity card */
  .pr-id {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    padding: 32px 24px 26px;
    text-align: center;
  }
  .pr-avatar {
    width: 96px; height: 96px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--bx-primary) 0%, var(--bx-primary-deep) 100%);
    color: var(--bx-night);
    display: inline-flex; align-items: center; justify-content: center;
    font-family: 'Space Grotesk', var(--font-sans);
    font-size: 40px; font-weight: 700;
    letter-spacing: -0.02em;
    margin-bottom: 18px;
    box-shadow: inset 0 1px 0 rgba(255,255,255,0.32), 0 12px 32px -16px rgba(111,203,163,0.55);
  }
  .pr-name {
    font-family: 'Manrope', var(--font-sans);
    font-size: 22px; font-weight: 600;
    color: #fff;
    letter-spacing: -0.015em;
  }
  .pr-email {
    font-family: var(--font-mono);
    font-size: 12px;
    color: rgba(255,255,255,0.55);
    margin-top: 6px;
  }
  .pr-role {
    display: inline-flex; align-items: center; gap: 6px;
    margin-top: 14px;
    padding: 5px 12px;
    background: rgba(111,203,163,0.14);
    color: var(--bx-primary);
    border: 1px solid rgba(111,203,163,0.32);
    border-radius: var(--r-pill);
    font-size: 11px; font-weight: 600;
    letter-spacing: 0.02em;
  }
  .pr-id__meta {
    display: flex; flex-direction: column; gap: 10px;
    margin-top: 22px; padding-top: 22px;
    border-top: 1px solid var(--glass-border);
    text-align: left;
  }
  .pr-id__row {
    display: flex; align-items: center; gap: 10px;
    font-size: 12px;
    color: rgba(255,255,255,0.65);
  }
  .pr-id__row i { font-size: 15px; color: var(--bx-primary); }
  .pr-id__row .val {
    margin-left: auto;
    font-family: var(--font-mono);
    color: #fff;
    font-size: 11px;
  }

  /* Danger zone */
  .pr-danger {
    background: rgba(248,113,113,0.04);
    border: 1px solid rgba(248,113,113,0.24);
    border-radius: var(--r-shell);
    margin-top: 16px;
    padding: 22px;
    box-shadow: var(--glass-shadow);
  }
  .pr-danger h4 {
    font-family: 'Manrope', var(--font-sans);
    font-size: 16px; font-weight: 600;
    color: var(--bx-danger);
    margin-bottom: 6px;
    letter-spacing: -0.005em;
  }
  .pr-danger p {
    font-size: 12px;
    color: rgba(255,255,255,0.6);
    margin-bottom: 14px;
    line-height: 1.6;
  }
  .pr-danger__btn {
    display: flex; align-items: center; justify-content: center; gap: 8px;
    width: 100%;
    padding: 12px 18px;
    background: rgba(248,113,113,0.12);
    border: 1px solid rgba(248,113,113,0.32);
    color: var(--bx-danger);
    border-radius: var(--r-md);
    font-family: var(--font-sans);
    font-size: 13px; font-weight: 600;
    cursor: pointer;
    transition: background var(--t-fast), border-color var(--t-fast);
  }
  .pr-danger__btn:hover {
    background: rgba(248,113,113,0.22);
    border-color: rgba(248,113,113,0.50);
  }

  /* Edit form card */
  .pr-form {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    overflow: hidden;
  }
  .pr-form__head {
    display: flex; align-items: center; justify-content: space-between;
    padding: 18px 24px;
    border-bottom: 1px solid var(--glass-border);
  }
  .pr-form__head h3 {
    font-family: var(--font-sans);
    font-size: 14px; font-weight: 600; color: #fff;
    display: inline-flex; align-items: center; gap: 8px;
  }
  .pr-form__head h3 i { color: var(--bx-primary); font-size: 16px; }
  .pr-form__head .chip {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 4px 10px;
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-pill);
    font-size: 11px;
    color: rgba(255,255,255,0.6);
  }
  .pr-form__body { padding: 24px; }

  .pr-fld { display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; }
  .pr-fld__lbl {
    font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase;
    font-weight: 600; color: rgba(255,255,255,0.55);
  }
  .pr-fld__lbl .req { color: var(--bx-danger); margin-left: 3px; }
  .pr-fld input {
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
  .pr-fld input:focus {
    border-color: var(--bx-primary);
    background: rgba(111,203,163,0.06);
  }
  .pr-fld__hint {
    font-size: 11px;
    color: rgba(255,255,255,0.5);
    margin-top: 4px;
  }

  .pr-actions {
    display: flex; gap: 10px; justify-content: flex-end;
    margin-top: 12px;
    padding-top: 20px;
    border-top: 1px solid var(--glass-border);
  }

  /* Alerts */
  .pr-alert {
    padding: 14px 18px;
    border-radius: var(--r-md);
    display: flex; gap: 12px; align-items: flex-start;
    font-size: 13px;
    margin-bottom: 18px;
  }
  .pr-alert i { font-size: 18px; margin-top: 1px; flex-shrink: 0; }
  .pr-alert--ok   { background: rgba(111,203,163,0.10); border: 1px solid rgba(111,203,163,0.32); color: var(--bx-primary-ink); }
  .pr-alert--ok   i { color: var(--bx-primary); }
  .pr-alert--err  { background: rgba(248,113,113,0.10); border: 1px solid rgba(248,113,113,0.32); color: var(--bx-danger-ink); }
  .pr-alert--err  i { color: var(--bx-danger); }
  .pr-alert--warn { background: rgba(251,191,36,0.10); border: 1px solid rgba(251,191,36,0.28); color: rgba(255,255,255,0.85); }
  .pr-alert--warn i { color: var(--bx-warning); }
  .pr-alert a { color: var(--bx-primary); text-decoration: none; border-bottom: 1px solid rgba(111,203,163,0.32); }
</style>

<div class="page-header-row reveal">
  <div class="page-header" style="margin-bottom:0;">
    <span class="eyebrow">Account</span>
    <h1>My <em>profile.</em></h1>
    <p>Manage your account, contact details, and how we reach you.</p>
  </div>
</div>

<c:if test="${not empty param.msg && param.msg == 'updated'}">
  <div class="pr-alert pr-alert--ok"><i class="ti ti-circle-check"></i><div>Profile updated successfully.</div></div>
</c:if>
<c:if test="${not empty param.error}">
  <div class="pr-alert pr-alert--err"><i class="ti ti-alert-circle"></i><div>Something went wrong. Please try again.</div></div>
</c:if>

<c:if test="${empty u}">
  <div class="pr-alert pr-alert--warn">
    <i class="ti ti-alert-triangle"></i>
    <div>
      <strong style="color:#fff;">You're not signed in.</strong><br/>
      <a href="${pageContext.request.contextPath}/login">Sign in to continue &rarr;</a>
    </div>
  </div>
</c:if>

<c:if test="${not empty u}">
<div class="pr-grid">

  <!-- Identity column -->
  <div>
    <div class="pr-id reveal">
      <div class="pr-avatar">${u.name.substring(0,1).toUpperCase()}</div>
      <div class="pr-name">${u.name}</div>
      <div class="pr-email">${u.email}</div>
      <div>
        <span class="pr-role"><i class="ti ti-user-circle"></i> ${u.role}</span>
      </div>
      <div class="pr-id__meta">
        <div class="pr-id__row">
          <i class="ti ti-id-badge"></i>
          <span>Member ID</span>
          <span class="val">${u.id}</span>
        </div>
      </div>
    </div>

    <div class="pr-danger reveal">
      <h4>Close this account</h4>
      <p>This action is permanent. Reservations and the loyalty balance are retained for record but no longer accessible to you.</p>
      <form action="${pageContext.request.contextPath}/user/delete" method="post"
            onsubmit="return confirm('Are you sure? This cannot be undone.');">
        <button type="submit" class="pr-danger__btn">
          <i class="ti ti-trash"></i> Delete account
        </button>
      </form>
    </div>
  </div>

  <!-- Edit form -->
  <div class="pr-form reveal">
    <div class="pr-form__head">
      <h3><i class="ti ti-pencil"></i> Edit profile</h3>
      <span class="chip"><i class="ti ti-database" style="color:var(--bx-primary);"></i> MSSQL users</span>
    </div>
    <div class="pr-form__body">
      <form action="${pageContext.request.contextPath}/user/update" method="post">

        <div class="pr-fld">
          <label class="pr-fld__lbl" for="name">Full name<span class="req">*</span></label>
          <input type="text" id="name" name="name"
                 value="${u.name}" required placeholder="e.g. Kamal Perera"/>
        </div>

        <div class="pr-fld">
          <label class="pr-fld__lbl" for="email">Email address<span class="req">*</span></label>
          <input type="email" id="email" name="email"
                 value="${u.email}" required/>
          <input type="text" id="phone" name="phone" value="${u.phone}" placeholder="Phone number"/>
          <input type="text" id="licenseNo" name="licenseNo" value="${u.licenseNo}" placeholder="Driving licence / ID"/>
          <div class="pr-fld__hint">Used for reservation confirmations and password recovery.</div>
        </div>

        <div class="pr-actions">
          <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-ghost">Cancel</a>
          <button type="submit" class="btn btn-primary" data-antigravity>
            Save changes
            <span class="ico-pill"><i class="ti ti-check"></i></span>
          </button>
        </div>
      </form>
    </div>
  </div>

</div>
</c:if>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
