<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Payment Management" scope="request"/>
<c:set var="sectionName" value="Payments" scope="request"/>
<c:set var="activePage" value="paymentlist" scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  .pl-card{background:var(--glass-bg);backdrop-filter:blur(20px) saturate(180%);border:1px solid var(--glass-border);border-radius:var(--r-shell);box-shadow:var(--glass-shadow);overflow:hidden;margin-bottom:18px}
  .pl-card__head{display:flex;align-items:center;justify-content:space-between;gap:12px;padding:18px 24px;border-bottom:1px solid var(--glass-border)}
  .pl-card__head h3{font-size:14px;font-weight:600;color:#fff;display:inline-flex;align-items:center;gap:8px}.pl-card__head h3 i{color:var(--bx-primary)}
  .pl-chip{display:inline-flex;align-items:center;gap:6px;padding:4px 10px;background:rgba(255,255,255,.04);border:1px solid var(--glass-border);border-radius:var(--r-pill);font-size:11px;color:rgba(255,255,255,.6)}
  .pl-table{width:100%;border-collapse:collapse}.pl-table th{text-align:left;padding:12px 20px;font-size:10px;letter-spacing:.12em;text-transform:uppercase;color:rgba(255,255,255,.5);border-bottom:1px solid var(--glass-border)}
  .pl-table td{padding:14px 20px;font-size:13px;color:rgba(255,255,255,.78);border-bottom:1px solid rgba(255,255,255,.04);vertical-align:middle}.pl-table tr:last-child td{border-bottom:0}.pl-table tr:hover td{background:rgba(255,255,255,.025)}
  .pl-table th:last-child,.pl-table td:last-child{text-align:right}.pl-mono{font-family:var(--font-mono)}.pl-nowrap{white-space:nowrap}
  .pl-badge{display:inline-flex;align-items:center;gap:5px;padding:4px 9px;border-radius:var(--r-pill);font-size:11px;font-weight:600;border:1px solid var(--glass-border);background:rgba(255,255,255,.05);color:rgba(255,255,255,.72)}
  .pl-badge--ok{background:rgba(111,203,163,.14);border-color:rgba(111,203,163,.32);color:var(--bx-primary)}.pl-badge--pending{background:rgba(251,191,36,.14);border-color:rgba(251,191,36,.32);color:var(--bx-warning)}.pl-badge--err{background:rgba(248,113,113,.14);border-color:rgba(248,113,113,.32);color:var(--bx-danger)}
  .pl-btn{display:inline-flex;align-items:center;justify-content:center;gap:6px;padding:7px 11px;border-radius:8px;border:1px solid var(--glass-border);background:rgba(255,255,255,.04);color:rgba(255,255,255,.82);font:600 11px var(--font-sans);cursor:pointer;text-decoration:none}.pl-btn:hover{border-color:rgba(111,203,163,.35);color:var(--bx-primary)}
  .pl-btn--ok{border-color:rgba(111,203,163,.32);background:rgba(111,203,163,.10);color:var(--bx-primary)}.pl-btn--danger{border-color:rgba(248,113,113,.32);background:rgba(248,113,113,.08);color:var(--bx-danger)}
  .pl-actions{display:flex;gap:7px;justify-content:flex-end;flex-wrap:wrap}.pl-inline{display:inline}.pl-empty{text-align:center;padding:48px 24px;color:rgba(255,255,255,.55)}.pl-empty i{font-size:34px;color:var(--bx-primary);display:block;margin-bottom:10px}
  .pl-alert{padding:13px 16px;border-radius:var(--r-md);display:flex;gap:10px;margin-bottom:16px;font-size:13px;background:rgba(125,211,252,.08);border:1px solid rgba(125,211,252,.24);color:rgba(255,255,255,.85)}.pl-alert--err{background:rgba(248,113,113,.10);border-color:rgba(248,113,113,.28);color:#fecaca}
  .pl-sub{font-size:11px;color:rgba(255,255,255,.45);margin-top:3px}.pl-ref{max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;display:block}
  @media(max-width:900px){.pl-card{overflow-x:auto}.pl-table{min-width:800px}}
</style>

<div class="page-header-row reveal">
  <div class="page-header" style="margin-bottom:0">
    <span class="eyebrow">Finance</span>
    <h1>Payment <em>management.</em></h1>
    <p>Review bank transfers and inspect payment records stored in Microsoft SQL Server.</p>
  </div>
  <a class="btn btn-secondary" href="${pageContext.request.contextPath}/payment/promotions"><i class="ti ti-tag"></i> Promotions</a>
</div>

<c:if test="${not empty param.msg}"><div class="pl-alert"><i class="ti ti-circle-check"></i><div>Payment operation completed.</div></div></c:if>
<c:if test="${not empty param.error}"><div class="pl-alert pl-alert--err"><i class="ti ti-alert-triangle"></i><div><c:out value="${param.error}"/></div></div></c:if>
<c:if test="${not empty errorMsg}"><div class="pl-alert pl-alert--err"><i class="ti ti-alert-triangle"></i><div><c:out value="${errorMsg}"/></div></div></c:if>

<c:if test="${not empty pendingTransfers}">
  <div class="pl-card reveal">
    <div class="pl-card__head">
      <h3><i class="ti ti-building-bank"></i> Bank transfers awaiting verification</h3>
      <span class="pl-chip">${fn:length(pendingTransfers)} pending</span>
    </div>
    <table class="pl-table">
      <thead><tr><th>Payment</th><th>Booking</th><th>Customer</th><th>Reference</th><th>Amount</th><th>Date</th><th>Actions</th></tr></thead>
      <tbody>
      <c:forEach var="p" items="${pendingTransfers}">
        <tr>
          <td class="pl-mono"><c:out value="${p.paymentId}"/></td>
          <td class="pl-mono"><c:out value="${p.bookingId}"/></td>
          <td><c:out value="${p.customerName}"/></td>
          <td><span class="pl-ref pl-mono" title="${fn:escapeXml(p.transactionReference)}"><c:out value="${p.transactionReference}"/></span></td>
          <td class="pl-mono">LKR <fmt:formatNumber value="${p.amount}" pattern="#,##0.00"/></td>
          <td class="pl-mono pl-nowrap"><c:out value="${p.date}"/></td>
          <td>
            <div class="pl-actions">
              <form class="pl-inline" method="post" action="${pageContext.request.contextPath}/payment/bank-review">
                <input type="hidden" name="paymentId" value="${fn:escapeXml(p.paymentId)}"/>
                <button class="pl-btn pl-btn--ok" name="decision" value="approve" type="submit" onclick="return confirm('Approve this transfer and confirm the linked booking?');"><i class="ti ti-check"></i> Approve</button>
              </form>
              <form class="pl-inline" method="post" action="${pageContext.request.contextPath}/payment/bank-review">
                <input type="hidden" name="paymentId" value="${fn:escapeXml(p.paymentId)}"/>
                <button class="pl-btn pl-btn--danger" name="decision" value="reject" type="submit" onclick="return confirm('Reject this transfer?');"><i class="ti ti-x"></i> Reject</button>
              </form>
            </div>
          </td>
        </tr>
      </c:forEach>
      </tbody>
    </table>
  </div>
</c:if>

<c:if test="${not empty pendingAdvances}">
  <div class="pl-card reveal">
    <div class="pl-card__head">
      <h3><i class="ti ti-hourglass"></i> Advance bookings awaiting customer payment</h3>
      <span class="pl-chip">${fn:length(pendingAdvances)} awaiting payment</span>
    </div>
    <table class="pl-table">
      <thead><tr><th>Booking</th><th>Customer</th><th>Vehicle</th><th>Pickup</th><th>Amount</th><th>Due</th><th>Status</th></tr></thead>
      <tbody>
      <c:forEach var="row" items="${pendingAdvances}">
        <tr>
          <td class="pl-mono"><c:out value="${row.bookingId}"/></td>
          <td><c:out value="${row.customerName}"/></td>
          <td><c:out value="${row.vehicleLabel}"/></td>
          <td class="pl-mono"><c:out value="${row.startDate}"/><div class="pl-sub">${row.duration} day(s)<c:if test="${row.withDriver}"> · with driver</c:if></div></td>
          <td class="pl-mono">LKR <fmt:formatNumber value="${row.estimatedTotal}" pattern="#,##0.00"/></td>
          <td class="pl-mono"><c:out value="${row.dueDate}"/></td>
          <td><c:choose><c:when test="${row.daysUntilDue lt 0}"><span class="pl-badge pl-badge--err">Overdue</span></c:when><c:otherwise><span class="pl-badge pl-badge--pending">Customer payment required</span></c:otherwise></c:choose></td>
        </tr>
      </c:forEach>
      </tbody>
    </table>
  </div>
</c:if>

<div class="pl-card reveal">
  <div class="pl-card__head">
    <h3><i class="ti ti-receipt"></i> All persisted payments</h3>
    <span class="pl-chip"><i class="ti ti-database"></i> MSSQL</span>
  </div>
  <c:choose>
    <c:when test="${not empty paymentRecords}">
      <table class="pl-table">
        <thead><tr><th>Method</th><th>Payment</th><th>Booking</th><th>Customer</th><th>Amount</th><th>Date</th><th>Status</th><th>Action</th></tr></thead>
        <tbody>
        <c:forEach var="p" items="${paymentRecords}">
          <tr>
            <td><span class="pl-badge"><c:out value="${p.paymentMethod}"/></span></td>
            <td class="pl-mono"><c:out value="${p.paymentId}"/></td>
            <td class="pl-mono"><c:out value="${p.bookingId}"/></td>
            <td><c:out value="${p.customerName}"/></td>
            <td class="pl-mono">LKR <fmt:formatNumber value="${p.amount}" pattern="#,##0.00"/></td>
            <td class="pl-mono pl-nowrap"><c:out value="${p.date}"/></td>
            <td>
              <c:choose>
                <c:when test="${p.status eq 'SUCCESS'}"><span class="pl-badge pl-badge--ok">SUCCESS</span></c:when>
                <c:when test="${p.status eq 'PENDING'}"><span class="pl-badge pl-badge--pending">PENDING</span></c:when>
                <c:when test="${p.status eq 'FAILED'}"><span class="pl-badge pl-badge--err">FAILED</span></c:when>
                <c:otherwise><span class="pl-badge"><c:out value="${p.status}"/></span></c:otherwise>
              </c:choose>
            </td>
            <td>
              <c:choose>
                <c:when test="${p.status eq 'FAILED'}">
                  <form class="pl-inline" method="post" action="${pageContext.request.contextPath}/payment/void">
                    <input type="hidden" name="paymentId" value="${fn:escapeXml(p.paymentId)}"/>
                    <button class="pl-btn pl-btn--danger" type="submit" onclick="return confirm('Void this failed payment record?');">Void</button>
                  </form>
                </c:when>
                <c:when test="${p.status eq 'PENDING' && p.paymentMethod eq 'BANK_TRANSFER'}"><span class="pl-sub">Review above</span></c:when>
                <c:otherwise><span class="pl-sub">—</span></c:otherwise>
              </c:choose>
            </td>
          </tr>
        </c:forEach>
        </tbody>
      </table>
    </c:when>
    <c:otherwise><div class="pl-empty"><i class="ti ti-credit-card-off"></i><p>No payment records found.</p></div></c:otherwise>
  </c:choose>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
