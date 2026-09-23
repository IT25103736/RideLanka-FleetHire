<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Admin Control Center" scope="request"/>
<c:set var="sectionName" value="Administration" scope="request"/>
<c:set var="activePage" value="admin-dashboard" scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  .ad-hero{display:flex;align-items:flex-start;justify-content:space-between;gap:18px;margin-bottom:22px}
  .ad-hero h1{margin-bottom:6px}.ad-hero p{max-width:680px}
  .ad-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:20px}
  .ad-card{background:var(--glass-bg);border:1px solid var(--glass-border);backdrop-filter:blur(20px);border-radius:var(--r-shell);box-shadow:var(--glass-shadow);padding:18px}
  .ad-card .label{font-size:9px;letter-spacing:.14em;text-transform:uppercase;color:rgba(255,255,255,.5)}
  .ad-card .num{font-size:30px;font-weight:700;color:#fff;margin-top:5px}.ad-card .sub{font-size:11px;color:rgba(255,255,255,.55);margin-top:3px}
  .ad-modules{display:grid;grid-template-columns:repeat(3,1fr);gap:15px}
  .ad-module{display:flex;flex-direction:column;justify-content:space-between;min-height:160px}
  .ad-module .icon{font-size:24px;color:var(--bx-primary);margin-bottom:12px}.ad-module h3{font-size:15px;color:#fff;margin-bottom:6px}.ad-module p{font-size:12px;line-height:1.55;color:rgba(255,255,255,.62);margin-bottom:14px}
  .ad-two{display:grid;grid-template-columns:1.4fr 1fr;gap:15px;margin-top:15px}.ad-list{width:100%;border-collapse:collapse}.ad-list th,.ad-list td{padding:10px 12px;border-bottom:1px solid rgba(255,255,255,.06);font-size:11px;text-align:left}.ad-list th{font-size:9px;text-transform:uppercase;letter-spacing:.12em;color:rgba(255,255,255,.45)}.ad-list td{color:rgba(255,255,255,.75)}
  @media(max-width:1000px){.ad-grid{grid-template-columns:repeat(2,1fr)}.ad-modules{grid-template-columns:1fr 1fr}.ad-two{grid-template-columns:1fr}}
  @media(max-width:620px){.ad-grid,.ad-modules{grid-template-columns:1fr}.ad-hero{flex-direction:column}}
</style>

<div class="ad-hero reveal">
  <div class="page-header" style="margin-bottom:0">
    <span class="eyebrow">RideLanka Administration</span>
    <h1>Admin control <em>center.</em></h1>
    <p>Manage accounts, control system access, monitor fleet readiness and open the operational tools used by RideLanka staff.</p>
  </div>
  <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary">Sign out <span class="ico-pill"><i class="ti ti-logout"></i></span></a>
</div>

<div class="ad-grid reveal">
  <div class="ad-card"><div class="label">Users</div><div class="num">${totalUsers}</div><div class="sub">${activeUsers} active · ${suspendedUsers} suspended</div></div>
  <div class="ad-card"><div class="label">Fleet</div><div class="num">${totalVehicles}</div><div class="sub">${availableVehicles} available · ${rentedVehicles} rented</div></div>
  <div class="ad-card"><div class="label">Maintenance</div><div class="num">${scheduledMaintenance + inProgressMaintenance}</div><div class="sub">${scheduledMaintenance} scheduled · ${inProgressMaintenance} in progress</div></div>
  <div class="ad-card"><div class="label">Out of service</div><div class="num">${maintenanceVehicles}</div><div class="sub">vehicles currently in maintenance</div></div>
</div>

<div class="ad-modules reveal">
  <div class="ad-card ad-module"><div><div class="icon"><i class="ti ti-users"></i></div><h3>User Management</h3><p>Create, edit, suspend, activate and deactivate user accounts. Control roles, customer details and access status.</p></div><a class="btn btn-primary" href="${pageContext.request.contextPath}/admin/members">Open User Management</a></div>
  <div class="ad-card ad-module"><div><div class="icon"><i class="ti ti-car"></i></div><h3>Vehicle Management</h3><p>Open vehicle records to review cars, categories, availability and current operational information.</p></div><a class="btn btn-secondary" href="${pageContext.request.contextPath}/vehicle?action=list">Open Vehicles</a></div>
  <div class="ad-card ad-module"><div><div class="icon"><i class="ti ti-tool"></i></div><h3>Fleet &amp; Maintenance</h3><p>Schedule service, start or complete maintenance, record inspections and control vehicle readiness.</p></div><a class="btn btn-secondary" href="${pageContext.request.contextPath}/fleet">Open Fleet &amp; Maintenance</a></div>
  <div class="ad-card ad-module"><div><div class="icon"><i class="ti ti-calendar-event"></i></div><h3>Booking Oversight</h3><p>Review current reservation information and operational booking activity.</p></div><a class="btn btn-secondary" href="${pageContext.request.contextPath}/admin/bookings">Open Bookings</a></div>
  <div class="ad-card ad-module"><div><div class="icon"><i class="ti ti-credit-card"></i></div><h3>Payment Oversight</h3><p>Open the existing payment log for transaction review and finance-related follow-up.</p></div><a class="btn btn-secondary" href="${pageContext.request.contextPath}/payment/list">Open Payment Log</a></div>
  <div class="ad-card ad-module"><div><div class="icon"><i class="ti ti-shield-check"></i></div><h3>Feedback &amp; Controls</h3><p>Review customer feedback and keep account access, moderation and administrative controls in one place.</p></div><a class="btn btn-secondary" href="${pageContext.request.contextPath}/review/moderate">Open Moderation</a></div>
</div>

<div class="ad-two reveal">
  <div class="ad-card"><div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px"><h3 style="color:#fff;font-size:14px">Recent maintenance activity</h3><a href="${pageContext.request.contextPath}/fleet" class="btn btn-ghost btn-sm">View all</a></div>
    <div style="overflow:auto"><table class="ad-list"><thead><tr><th>ID</th><th>Vehicle</th><th>Type</th><th>Status</th></tr></thead><tbody>
      <c:forEach var="m" items="${recentMaintenance}"><tr><td>${m.maintenanceId}</td><td>${m.vehicleId}</td><td>${m.maintenanceType}</td><td>${m.status}</td></tr></c:forEach>
      <c:if test="${empty recentMaintenance}"><tr><td colspan="4">No maintenance records found.</td></tr></c:if>
    </tbody></table></div>
  </div>
  <div class="ad-card"><h3 style="color:#fff;font-size:14px;margin-bottom:10px">Admin controls</h3>
    <p style="font-size:12px;color:rgba(255,255,255,.65);line-height:1.6;margin-bottom:12px">Role-limited access is enforced before administrative screens are opened. Important account changes are logged in the audit trail.</p>
    <div style="display:grid;gap:8px">
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/admin/members"><i class="ti ti-user-cog"></i> Manage accounts</a>
      <a class="btn btn-secondary" href="${pageContext.request.contextPath}/fleet"><i class="ti ti-tool"></i> Monitor maintenance</a>
    </div>
  </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
