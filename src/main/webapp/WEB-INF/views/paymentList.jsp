<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle"   value="All Payments" scope="request"/>
<c:set var="sectionName" value="Payments"      scope="request"/>
<c:set var="activePage"  value="paymentlist"   scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  .pl-card {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    overflow: hidden;
  }
  .pl-card__head {
    display: flex; align-items: center; justify-content: space-between;
    padding: 18px 24px;
    border-bottom: 1px solid var(--glass-border);
  }
  .pl-card__head h3 {
    font-family: var(--font-sans);
    font-size: 14px; font-weight: 600; color: #fff;
    display: inline-flex; align-items: center; gap: 8px;
  }
  .pl-card__head h3 i { color: var(--bx-primary); }
  .pl-card__head .chip {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 4px 10px;
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-pill);
    font-size: 11px;
    color: rgba(255,255,255,0.6);
  }

  .pl-table { width: 100%; border-collapse: collapse; }
  .pl-table thead th {
    text-align: left;
    padding: 12px 22px;
    font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase;
    color: rgba(255,255,255,0.5); font-weight: 700;
    border-bottom: 1px solid var(--glass-border);
  }
  .pl-table thead th:last-child { text-align: right; }
  .pl-table tbody td {
    padding: 14px 22px;
    font-size: 13px;
    color: rgba(255,255,255,0.78);
    border-bottom: 1px solid rgba(255,255,255,0.04);
  }
  .pl-table tbody tr:last-child td { border-bottom: 0; }
  .pl-table tbody tr:hover { background: rgba(255,255,255,0.03); }
  .pl-mono { font-family: var(--font-mono); }
  .pl-nowrap { white-space: nowrap; }

  .pl-badge {
    display: inline-flex; align-items: center; gap: 5px;
    padding: 4px 10px;
    border-radius: var(--r-pill);
    font-size: 11px; font-weight: 600;
    border: 1px solid;
  }
  .pl-badge--card   { background: rgba(125,211,252,0.10); color: var(--bx-info); border-color: rgba(125,211,252,0.24); }
  .pl-badge--wallet { background: rgba(111,203,163,0.14); color: var(--bx-primary); border-color: rgba(111,203,163,0.32); }
  .pl-badge--ok     { background: rgba(111,203,163,0.14); color: var(--bx-primary); border-color: rgba(111,203,163,0.32); }
  .pl-badge--err    { background: rgba(248,113,113,0.14); color: var(--bx-danger); border-color: rgba(248,113,113,0.32); }
  .pl-badge--gray   { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.65); border-color: var(--glass-border); }
  .pl-badge--ok::before, .pl-badge--err::before {
    content: ""; width: 6px; height: 6px; border-radius: 50%;
    background: currentColor;
    box-shadow: 0 0 0 3px rgba(255,255,255,0.08);
  }

  .pl-action {
    display: inline-flex; align-items: center; justify-content: center;
    width: 32px; height: 32px;
    border-radius: 8px;
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--glass-border);
    color: rgba(255,255,255,0.75);
    transition: background var(--t-fast), color var(--t-fast), border-color var(--t-fast);
    text-decoration: none;
  }
  .pl-action--danger:hover {
    color: var(--bx-danger);
    border-color: rgba(248,113,113,0.32);
    background: rgba(248,113,113,0.08);
  }

  .pl-empty { text-align: center; padding: 64px 24px; color: rgba(255,255,255,0.55); }
  .pl-empty i { font-size: 36px; color: var(--bx-primary); display: block; margin-bottom: 12px; }

  .pl-alert {
    padding: 14px 18px;
    border-radius: var(--r-md);
    display: flex; gap: 12px; align-items: flex-start;
    font-size: 13px;
    margin-bottom: 18px;
    background: rgba(125,211,252,0.08);
    border: 1px solid rgba(125,211,252,0.24);
    color: rgba(255,255,255,0.85);
  }
  .pl-alert i { font-size: 18px; color: var(--bx-info); margin-top: 1px; flex-shrink: 0; }

  /* ── Pending advances — amber-tinted card to flag "needs collection" rows ── */
  .pl-badge--pending {
    background: rgba(251,191,36,0.14);
    color: var(--bx-warning);
    border-color: rgba(251,191,36,0.32);
  }
  .pl-badge--overdue {
    background: rgba(248,113,113,0.16);
    color: var(--bx-danger);
    border-color: rgba(248,113,113,0.38);
  }
  .pl-pay-btn {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 6px 12px;
    background: rgba(111,203,163,0.12);
    border: 1px solid rgba(111,203,163,0.32);
    color: var(--bx-primary);
    border-radius: var(--r-pill);
    font-family: var(--font-sans);
    font-size: 11px; font-weight: 600;
    letter-spacing: 0.02em;
    text-decoration: none;
    transition: background var(--t-fast), border-color var(--t-fast), color var(--t-fast);
  }
  .pl-pay-btn:hover {
    background: var(--bx-primary);
    border-color: var(--bx-primary);
    color: var(--bx-night);
  }
  .pl-pay-btn i { font-size: 13px; }
  .pl-due-meta {
    font-size: 11px;
    color: rgba(255,255,255,0.45);
    margin-top: 2px;
  }
</style>

<div class="page-header-row reveal">
  <div class="page-header" style="margin-bottom:0;">
    <span class="eyebrow">Admin</span>
    <h1>Payment <em>history.</em></h1>
    <p>All recorded transactions across the VRMS system </p>
  </div>
  <a href="${pageContext.request.contextPath}/payment/checkout" class="btn btn-primary" data-antigravity>
    <i class="ti ti-credit-card"></i> New payment
  </a>
</div>

<c:if test="${not empty message}">
  <div class="pl-alert"><i class="ti ti-info-circle"></i><div>${message}</div></div>
</c:if>

<%-- ════════════════════════════════════════════════════════════════════════
     Pending advance payments — Active Advance bookings without a Success
     payment yet. Sorted by soonest-due so admins triage the most urgent.
     ════════════════════════════════════════════════════════════════════════ --%>
<c:if test="${not empty pendingAdvances}">
  <div class="pl-card reveal" style="margin-bottom: 18px;">
    <div class="pl-card__head">
      <h3>
        <i class="ti ti-hourglass" style="color: var(--bx-warning) !important;"></i>
        Pending advance payments
      </h3>
      <span class="chip">
        <i class="ti ti-calendar-due" style="color: var(--bx-warning);"></i>
        ${fn:length(pendingAdvances)} awaiting collection
      </span>
    </div>

    <table class="pl-table">
      <thead>
        <tr>
          <th>Booking ID</th>
          <th>Customer</th>
          <th>Vehicle</th>
          <th>Pick-up</th>
          <th>Estimated (LKR)</th>
          <th>Payment due</th>
          <th>Status</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        <c:forEach var="row" items="${pendingAdvances}">
          <tr>
            <td class="pl-mono" style="color:#fff;">${row.bookingId}</td>
            <td style="color:rgba(255,255,255,0.78);">${row.customerName}</td>
            <td style="color:rgba(255,255,255,0.78);">${row.vehicleLabel}</td>
            <td class="pl-mono pl-nowrap" style="color:rgba(255,255,255,0.65);">
              ${row.startDate}
              <div class="pl-due-meta">
                ${row.duration} day${row.duration == 1 ? '' : 's'}
                <c:if test="${not empty row.pickupLocation}">&middot; ${row.pickupLocation}</c:if>
                <c:if test="${row.withDriver}">&middot; with driver</c:if>
              </div>
            </td>
            <td class="pl-mono">
              <span style="color: var(--bx-primary); font-weight:600;">LKR</span>
              <fmt:formatNumber value="${row.estimatedTotal}" pattern="#,##0.00"/>
            </td>
            <td class="pl-mono pl-nowrap" style="color: rgba(255,255,255,0.78);">
              ${row.dueDate}
              <div class="pl-due-meta">
                <c:choose>
                  <c:when test="${row.daysUntilDue < 0}">
                    <span style="color: var(--bx-danger);">${-row.daysUntilDue} day${-row.daysUntilDue == 1 ? '' : 's'} overdue</span>
                  </c:when>
                  <c:when test="${row.daysUntilDue == 0}">
                    <span style="color: var(--bx-warning);">due today</span>
                  </c:when>
                  <c:otherwise>
                    in ${row.daysUntilDue} day${row.daysUntilDue == 1 ? '' : 's'}
                  </c:otherwise>
                </c:choose>
              </div>
            </td>
            <td>
              <c:choose>
                <c:when test="${row.daysUntilDue < 0}">
                  <span class="pl-badge pl-badge--overdue">Overdue</span>
                </c:when>
                <c:otherwise>
                  <span class="pl-badge pl-badge--pending">Pending</span>
                </c:otherwise>
              </c:choose>
            </td>
            <td style="text-align: right;">
              <a href="${pageContext.request.contextPath}/payment/checkout?bookingId=${row.bookingId}&amount=${row.estimatedTotal}&customerName=${row.customerName}"
                 class="pl-pay-btn" title="Open checkout for this booking">
                <i class="ti ti-credit-card"></i> Collect payment
              </a>
            </td>
          </tr>
        </c:forEach>
      </tbody>
    </table>
  </div>
</c:if>

<div class="pl-card reveal">
  <div class="pl-card__head">
    <h3><i class="ti ti-receipt"></i> All payments</h3>
    <span class="chip"><i class="ti ti-database" style="color:var(--bx-primary);"></i> data/payments.txt</span>
  </div>

  <c:choose>
    <c:when test="${not empty payments}">
      <table class="pl-table">
        <thead>
          <tr>
            <th>Method</th>
            <th>Payment ID</th>
            <th>Customer</th>
            <th>Amount (LKR)</th>
            <th>Date</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="line" items="${payments}">
            <c:set var="parts" value="${fn:split(line, '|')}"/>
            <c:if test="${fn:length(parts) >= 6}">
              <tr>
                <td>
                  <c:choose>
                    <c:when test="${parts[0] == 'CARD'}">
                      <span class="pl-badge pl-badge--card"><i class="ti ti-credit-card"></i> Card</span>
                    </c:when>
                    <c:otherwise>
                      <span class="pl-badge pl-badge--wallet"><i class="ti ti-wallet"></i> Wallet</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td class="pl-mono" style="color:#fff;">${parts[1]}</td>
                <td style="color:rgba(255,255,255,0.78);">${parts[2]}</td>
                <td class="pl-mono">
                  <span style="color:var(--bx-primary); font-weight:600;">LKR</span>
                  <fmt:parseNumber var="amt" value="${parts[3]}" integerOnly="false"/>
                  <fmt:formatNumber value="${amt}" pattern="#,##0.00"/>
                </td>
                <td class="pl-mono pl-nowrap" style="color:rgba(255,255,255,0.6);">${parts[4]}</td>
                <td>
                  <c:choose>
                    <c:when test="${parts[5] == 'Success'}"><span class="pl-badge pl-badge--ok">Success</span></c:when>
                    <c:when test="${parts[5] == 'Failed'}"><span class="pl-badge pl-badge--err">Failed</span></c:when>
                    <c:otherwise><span class="pl-badge pl-badge--gray">${parts[5]}</span></c:otherwise>
                  </c:choose>
                </td>
                <td style="text-align:right;">
                  <a href="${pageContext.request.contextPath}/payment/delete?paymentId=${parts[1]}"
                     class="pl-action pl-action--danger"
                     onclick="return confirm('Delete payment ${parts[1]}? This rewrites payments.txt.');"
                     title="Delete">
                    <i class="ti ti-trash"></i>
                  </a>
                </td>
              </tr>
            </c:if>
          </c:forEach>
        </tbody>
      </table>
    </c:when>
    <c:otherwise>
      <div class="pl-empty">
        <i class="ti ti-credit-card-off"></i>
        <p>No payments recorded yet.</p>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
