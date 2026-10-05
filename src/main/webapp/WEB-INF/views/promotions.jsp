<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Promotions" scope="request"/>
<c:set var="sectionName" value="Payments" scope="request"/>
<c:set var="activePage" value="promotions" scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<style>
.pm-grid{display:grid;grid-template-columns:minmax(280px,420px) 1fr;gap:20px;align-items:start}.pm-card{background:var(--glass-bg);backdrop-filter:blur(20px) saturate(180%);border:1px solid var(--glass-border);border-radius:var(--r-shell);box-shadow:var(--glass-shadow);overflow:hidden}.pm-head{padding:18px 22px;border-bottom:1px solid var(--glass-border);color:#fff;font-weight:600}.pm-body{padding:22px}.pm-fld{display:flex;flex-direction:column;gap:7px;margin-bottom:14px}.pm-fld label{font-size:10px;letter-spacing:.12em;text-transform:uppercase;color:rgba(255,255,255,.55)}.pm-fld input{padding:11px 13px;background:rgba(255,255,255,.04);border:1px solid var(--glass-border);border-radius:var(--r-md);color:#fff;text-transform:uppercase}.pm-alert{margin-top:14px;padding:12px 14px;border-radius:var(--r-md);font-size:13px}.ok{background:rgba(111,203,163,.10);border:1px solid rgba(111,203,163,.3);color:var(--bx-primary)}.err{background:rgba(248,113,113,.10);border:1px solid rgba(248,113,113,.3);color:#fecaca}.pm-promos{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px}.pm-promo{padding:16px;border:1px solid var(--glass-border);border-radius:var(--r-md);background:rgba(255,255,255,.03)}.pm-code{font-family:var(--font-mono);color:var(--bx-primary);font-weight:700}.pm-discount{float:right;color:#fff;font-weight:700}.pm-desc{margin-top:10px;color:rgba(255,255,255,.72);font-size:13px}.pm-exp{margin-top:8px;color:rgba(255,255,255,.45);font-size:11px}@media(max-width:900px){.pm-grid{grid-template-columns:1fr}.pm-promos{grid-template-columns:1fr}}
</style>
<div class="page-header reveal"><span class="eyebrow">Payment offers</span><h1>Active <em>promotions.</em></h1><p>Promo codes are validated against the MSSQL promotions table and applied during eligible card/wallet checkout.</p></div>
<div class="pm-grid">
  <div class="pm-card reveal"><div class="pm-head"><i class="ti ti-tag"></i> Check a promo code</div><div class="pm-body">
    <form action="${pageContext.request.contextPath}/payment/promotions" method="get">
      <div class="pm-fld"><label for="promoCode">Promo code</label><input id="promoCode" name="promoCode" maxlength="40" value="${param.promoCode}" placeholder="e.g. RIDE10"/></div>
      <button type="submit" class="btn btn-primary" style="width:100%"><i class="ti ti-check"></i> Validate code</button>
    </form>
    <c:if test="${not empty promoResult}"><div class="pm-alert ${promoValid ? 'ok' : 'err'}"><c:out value="${promoResult}"/></div></c:if>
  </div></div>
  <div class="pm-card reveal"><div class="pm-head"><i class="ti ti-speakerphone"></i> Active promotions</div><div class="pm-body">
    <c:choose><c:when test="${not empty promotions}"><div class="pm-promos"><c:forEach var="p" items="${promotions}"><div class="pm-promo"><span class="pm-code"><c:out value="${p.code}"/></span><span class="pm-discount"><c:out value="${p.discount}"/></span><div class="pm-desc"><c:out value="${p.description}"/></div><div class="pm-exp">Expires: <c:out value="${p.expiryDate}"/></div></div></c:forEach></div></c:when><c:otherwise><p style="color:rgba(255,255,255,.6)">No active promotions are available today.</p></c:otherwise></c:choose>
  </div></div>
</div>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
