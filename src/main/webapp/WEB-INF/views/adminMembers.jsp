<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle"   value="Members" scope="request"/>
<c:set var="sectionName" value="Admin"   scope="request"/>
<c:set var="activePage"  value="members" scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  .mp-card {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    overflow: hidden;
  }
  .mp-card__head {
    display: flex; align-items: center; justify-content: space-between;
    padding: 18px 24px;
    border-bottom: 1px solid var(--glass-border);
  }
  .mp-card__head h3 {
    font-family: var(--font-sans);
    font-size: 14px; font-weight: 600; color: #fff;
    display: inline-flex; align-items: center; gap: 8px;
  }
  .mp-card__head h3 i { color: var(--bx-primary); font-size: 16px; }
  .mp-card__head .chip {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 4px 10px;
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-pill);
    font-size: 11px;
    color: rgba(255,255,255,0.6);
  }

  .mp-table { width: 100%; border-collapse: collapse; }
  .mp-table thead th {
    text-align: left;
    padding: 12px 22px;
    font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase;
    color: rgba(255,255,255,0.5); font-weight: 700;
    border-bottom: 1px solid var(--glass-border);
  }
  .mp-table tbody td {
    padding: 14px 22px;
    font-size: 13px;
    color: rgba(255,255,255,0.78);
    border-bottom: 1px solid rgba(255,255,255,0.04);
    vertical-align: middle;
  }
  .mp-table tbody tr:last-child td { border-bottom: 0; }
  .mp-table tbody tr:hover { background: rgba(255,255,255,0.03); }
  .mp-mono   { font-family: var(--font-mono); }
  .mp-nowrap { white-space: nowrap; }

  .mp-badge {
    display: inline-flex; align-items: center; gap: 5px;
    padding: 4px 10px;
    border-radius: var(--r-pill);
    font-size: 11px; font-weight: 600;
    border: 1px solid;
  }
  .mp-badge::before {
    content: ""; width: 6px; height: 6px; border-radius: 50%;
    background: currentColor;
    box-shadow: 0 0 0 3px rgba(255,255,255,0.08);
  }
  /* Kit §Focus §2 — "Admin" is a category not a status; blue is the accent,
     not a status color. Use neutral so accent stays on actions/active state. */
  .mp-badge--admin   { background: rgba(255,255,255,0.06); color: #fff; border-color: var(--glass-border); }
  .mp-badge--member  { background: rgba(255,255,255,0.04); color: rgba(255,255,255,0.78); border-color: var(--glass-border); }

  /* Kit §Trust §6 — empty state must explain + offer a next action. */
  .mp-empty {
    text-align: center;
    padding: 56px 24px;
    color: rgba(255,255,255,0.55);
  }
  .mp-empty i {
    font-size: 32px;
    color: var(--bx-primary);
    display: block;
    margin-bottom: 12px;
  }
  .mp-empty h4 {
    color: #fff;
    font-size: 15px;
    margin: 0 0 6px;
  }
  .mp-empty p {
    margin: 0 0 16px;
    font-size: 13px;
  }
</style>

<div class="page-header-row reveal">
  <div class="page-header" style="margin-bottom:0;">
    <span class="eyebrow">Admin</span>
    <h1>Members <em>directory.</em></h1>
    <p>MSSQL-backed user accounts, roles, account status and customer details.</p>
  </div>
  <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-secondary">
    <i class="ti ti-arrow-left"></i> Back to Dashboard
  </a>
</div>

<div class="mp-card reveal">
  <div class="mp-card__head">
    <h3><i class="ti ti-users"></i> Members</h3>
    <span class="chip"><i class="ti ti-database" style="color:var(--bx-primary);"></i> ${fn:length(users)} registered</span>
  </div>
  <c:choose>
    <c:when test="${not empty users}">
      <table class="mp-table">
        <thead>
          <tr><th>Member</th><th>Email</th><th>Role</th><th>Licence</th><th>Status</th><th>Joined</th><th>Bookings</th><th>Actions</th></tr>
        </thead>
        <tbody>
          <c:forEach var="u" items="${users}">
            <tr>
              <td style="font-weight:600;color:#fff;">${u.name}</td>
              <td class="mp-mono">${u.email}</td>
              <td><span class="mp-badge mp-badge--member">${u.role}</span></td>
              <td class="mp-mono">${not empty u.licenseNo ? u.licenseNo : '—'}</td>
              <td><span class="mp-badge mp-badge--member">${u.status}</span></td>
              <td class="mp-mono mp-nowrap">${u.createdDate}</td>
              <td class="mp-mono">${not empty bookingCount[u.id] ? bookingCount[u.id] : 0}</td>
              <td>
                <div style="display:flex;gap:5px;flex-wrap:wrap;">
                  <form action="${pageContext.request.contextPath}/admin/users/status" method="post" style="display:inline-flex;gap:5px;">
                    <input type="hidden" name="id" value="${u.id}"/>
                    <c:choose><c:when test="${u.status == 'ACTIVE'}"><button class="btn btn-secondary btn-sm" name="status" value="SUSPENDED">Suspend</button></c:when><c:otherwise><button class="btn btn-primary btn-sm" name="status" value="ACTIVE">Activate</button></c:otherwise></c:choose>
                    <button class="btn btn-ghost btn-sm" name="status" value="DEACTIVATED">Deactivate</button>
                  </form>
                  <details>
                    <summary class="btn btn-ghost btn-sm" style="display:inline-flex;align-items:center;cursor:pointer;">Edit</summary>
                    <form action="${pageContext.request.contextPath}/admin/users/update" method="post" style="margin-top:8px;display:grid;grid-template-columns:1fr 1fr;gap:6px;min-width:330px;">
                      <input type="hidden" name="id" value="${u.id}"/>
                      <input name="name" value="${u.name}" required placeholder="Name"/>
                      <input type="email" name="email" value="${u.email}" required placeholder="Email"/>
                      <select name="role"><option value="CUSTOMER" ${u.role=='CUSTOMER'?'selected':''}>Customer</option><option value="BRANCH_STAFF" ${u.role=='BRANCH_STAFF'?'selected':''}>Branch Staff</option><option value="FINANCE" ${u.role=='FINANCE'?'selected':''}>Finance</option><option value="MAINTENANCE" ${u.role=='MAINTENANCE'?'selected':''}>Maintenance</option><option value="FLEET" ${u.role=='FLEET'?'selected':''}>Fleet</option><option value="VEHICLE" ${u.role=='VEHICLE'?'selected':''}>Vehicle Management</option><option value="ADMIN" ${u.role=='ADMIN'?'selected':''}>Admin</option></select>
                      <select name="status"><option value="ACTIVE" ${u.status=='ACTIVE'?'selected':''}>Active</option><option value="SUSPENDED" ${u.status=='SUSPENDED'?'selected':''}>Suspended</option><option value="DEACTIVATED" ${u.status=='DEACTIVATED'?'selected':''}>Deactivated</option></select>
                      <input name="phone" value="${u.phone}" placeholder="Phone"/>
                      <input name="licenseNo" value="${u.licenseNo}" placeholder="Licence / ID"/>
                      <button class="btn btn-primary btn-sm" type="submit" style="grid-column:1/-1;">Save user</button>
                    </form>
                  </details>
                </div>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </c:when>
    <c:otherwise>
      <div class="mp-empty">
        <i class="ti ti-users-off"></i>
        <h4>No members on file</h4>
        <p>Once someone signs up, they'll appear here with their bookings and spend.</p>
        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/register">
          <i class="ti ti-user-plus"></i> Open sign-up
        </a>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<div class="mp-card reveal" style="margin-top:18px;padding:22px;">
  <div class="mp-card__head" style="padding:0 0 16px;border:0;"><h3><i class="ti ti-user-plus"></i> Create user</h3></div>
  <form action="${pageContext.request.contextPath}/admin/users/create" method="post" style="display:grid;grid-template-columns:repeat(3,1fr);gap:12px;">
    <input name="name" placeholder="Full name" required/>
    <input type="email" name="email" placeholder="Email" required/>
    <input type="password" name="password" placeholder="Temporary password" minlength="6" required/>
    <select name="role" required><option value="CUSTOMER">Customer</option><option value="BRANCH_STAFF">Branch Staff</option><option value="FINANCE">Finance</option><option value="MAINTENANCE">Maintenance</option><option value="FLEET">Fleet</option><option value="VEHICLE">Vehicle Management</option><option value="ADMIN">Admin</option></select>
    <input name="phone" placeholder="Phone"/>
    <input name="licenseNo" placeholder="Driving licence / ID"/>
    <button class="btn btn-primary" type="submit" style="grid-column:1/-1;">Create account</button>
  </form>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
