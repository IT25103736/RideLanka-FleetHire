<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle"   value="My Payments" scope="request"/>
<c:set var="sectionName" value="Payments"     scope="request"/>
<c:set var="activePage"  value="payment"      scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  .mp-layout {
    display: grid;
    grid-template-columns: 1fr 320px;
    gap: 22px;
    align-items: start;
  }
  @media (max-width: 1100px) { .mp-layout { grid-template-columns: 1fr; } }

  .mp-card {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    overflow: hidden;
    margin-bottom: 18px;
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
  .mp-table thead th:last-child { text-align: right; }
  .mp-table tbody td {
    padding: 14px 22px;
    font-size: 13px;
    color: rgba(255,255,255,0.78);
    border-bottom: 1px solid rgba(255,255,255,0.04);
    vertical-align: middle;
  }
  .mp-table tbody tr:last-child td { border-bottom: 0; }
  .mp-table tbody tr:hover { background: rgba(255,255,255,0.03); }
  .mp-table tbody tr.is-cancelled { opacity: 0.55; }
  .mp-mono   { font-family: var(--font-mono); }
  .mp-nowrap { white-space: nowrap; }

  /* Status badges */
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
  .mp-badge--paid    { background: rgba(111,203,163,0.14); color: var(--bx-primary); border-color: rgba(111,203,163,0.32); }
  .mp-badge--pending { background: rgba(251,191,36,0.14);  color: var(--bx-warning); border-color: rgba(251,191,36,0.30); }
  .mp-badge--cancel  { background: rgba(248,113,113,0.14); color: var(--bx-danger);  border-color: rgba(248,113,113,0.32); }
  .mp-badge--done    { background: rgba(125,211,252,0.10); color: var(--bx-info);    border-color: rgba(125,211,252,0.24); }
  .mp-badge--gray    { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.65); border-color: var(--glass-border); }

  /* Payment-method mini tags */
  .mp-method {
    display: inline-flex; align-items: center; gap: 5px;
    padding: 2px 8px;
    border-radius: var(--r-pill);
    font-size: 10px; font-weight: 600;
    border: 1px solid;
  }
  .mp-method--card   { background: rgba(125,211,252,0.10); color: var(--bx-info);    border-color: rgba(125,211,252,0.24); }
  .mp-method--wallet { background: rgba(111,203,163,0.14); color: var(--bx-primary); border-color: rgba(111,203,163,0.32); }

  /* Action buttons */
  .mp-actions { display: inline-flex; gap: 6px; flex-wrap: wrap; justify-content: flex-end; }
  .mp-btn {
    display: inline-flex; align-items: center; gap: 5px;
    padding: 6px 12px;
    border-radius: var(--r-md);
    font-size: 12px; font-weight: 600;
    text-decoration: none;
    border: 1px solid;
    cursor: pointer;
    font-family: var(--font-sans);
    transition: background var(--t-fast), border-color var(--t-fast);
  }
  .mp-btn--pay {
    background: var(--bx-primary);
    color: var(--bx-night);
    border-color: var(--bx-primary);
  }
  .mp-btn--pay:hover { background: rgba(111,203,163,0.85); }
  .mp-btn--cancel {
    background: rgba(248,113,113,0.10);
    color: var(--bx-danger);
    border-color: rgba(248,113,113,0.28);
  }
  .mp-btn--cancel:hover {
    background: rgba(248,113,113,0.20);
    border-color: rgba(248,113,113,0.45);
  }
  .mp-btn--ghost {
    background: transparent;
    color: rgba(255,255,255,0.7);
    border-color: var(--glass-border);
  }

  /* Empty state */
  .mp-empty { text-align: center; padding: 64px 24px; color: rgba(255,255,255,0.55); }
  .mp-empty i { font-size: 36px; color: var(--bx-primary); display: block; margin-bottom: 12px; }

  /* Right-rail stats */
  .mp-stat {
    background: var(--glass-bg-strong);
    -webkit-backdrop-filter: blur(28px) saturate(180%);
            backdrop-filter: blur(28px) saturate(180%);
    border: 1px solid var(--glass-border-top);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow-lg);
    padding: 22px;
    margin-bottom: 14px;
  }
  .mp-stat__lbl {
    font-size: 10px; letter-spacing: 0.18em; text-transform: uppercase;
    color: rgba(255,255,255,0.55); font-weight: 600;
  }
  .mp-stat__val {
    font-family: 'Manrope', var(--font-sans);
    font-size: 32px; font-weight: 700;
    color: var(--bx-primary);
    letter-spacing: -0.022em;
    margin-top: 6px;
    line-height: 1;
  }
  .mp-stat__val sup {
    font-size: 12px; color: rgba(255,255,255,0.55);
    margin-right: 4px; font-weight: 500; vertical-align: top;
  }
  .mp-stat__hint { font-size: 11px; color: rgba(255,255,255,0.5); margin-top: 6px; }

  .mp-receipt {
    font-size: 11px;
    color: rgba(255,255,255,0.55);
    margin-top: 2px;
    font-family: var(--font-mono);
  }
</style>

<div class="page-header-row reveal">
  <div class="page-header" style="margin-bottom:0;">
    <span class="eyebrow">Account</span>
    <h1>My <em>payments.</em></h1>
    <p>Pay for pending bookings, review settled invoices, and track loyalty points &mdash; all in one ledger.</p>
  </div>
  <a href="${pageContext.request.contextPath}/booking?action=form" class="btn btn-primary" data-antigravity>
    <i class="ti ti-plus"></i> New booking
  </a>
</div>

<div class="mp-layout">

  <%-- ════════════ MAIN COLUMN ════════════ --%>
  <div>

    <%-- ── Pending payments (action required) ── --%>
    <div class="mp-card reveal">
      <div class="mp-card__head">
        <h3><i class="ti ti-clock-hour-3"></i> Pending payments</h3>
        <span class="chip"><i class="ti ti-alert-circle" style="color:var(--bx-warning);"></i> ${pendingCount} awaiting payment</span>
      </div>

      <c:set var="hasPending" value="false"/>
      <c:forEach var="r" items="${rows}">
        <c:if test="${r.pending}"><c:set var="hasPending" value="true"/></c:if>
      </c:forEach>

      <c:choose>
        <c:when test="${hasPending}">
          <table class="mp-table">
            <thead>
              <tr>
                <th>Booking</th>
                <th>Vehicle</th>
                <th>Dates</th>
                <th>Type</th>
                <th>Amount</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="r" items="${rows}">
                <c:if test="${r.pending}">
                  <tr>
                    <td class="mp-mono" style="color:#fff;">${r.booking.bookingId}</td>
                    <td style="font-weight:600; color:#fff;">${r.booking.vehicleId}</td>
                    <td class="mp-mono mp-nowrap" style="color:rgba(255,255,255,0.7);">
                      ${r.booking.startDate} &rarr; ${r.booking.endDate}
                      <div class="mp-receipt">${r.durationDays} day(s)</div>
                    </td>
                    <td style="font-size:12px;">
                      <c:choose>
                        <c:when test="${r.booking.bookingType == 'INSTANT'}">
                          <span class="mp-badge mp-badge--paid"><i class="ti ti-bolt"></i> Instant</span>
                        </c:when>
                        <c:otherwise>
                          <span class="mp-badge mp-badge--pending"><i class="ti ti-calendar-event"></i> Advance</span>
                        </c:otherwise>
                      </c:choose>
                      <c:if test="${not empty r.booking.pickupLocation}">
                        <div style="margin-top:6px; color:rgba(255,255,255,0.65); font-size:11px;">
                          <i class="ti ti-map-pin" style="color:var(--bx-primary);"></i>
                          ${r.booking.pickupLocation} &middot;
                          <span class="mp-mono">${r.booking.pickupTime}</span>
                        </div>
                      </c:if>
                    </td>
                    <td class="mp-mono mp-nowrap">
                      <span style="color:var(--bx-primary); font-weight:600;">LKR</span>
                      <fmt:formatNumber value="${r.computedTotal}" pattern="#,##0.00"/>
                    </td>
                    <td style="text-align:right;">
                      <div class="mp-actions">
                        <a class="mp-btn mp-btn--pay"
                           href="${pageContext.request.contextPath}/payment/checkout?bookingId=${r.booking.bookingId}&amount=${r.computedTotal}&customerName=${sessionScope.loggedUser.name}">
                          <i class="ti ti-credit-card"></i> Pay now
                        </a>
                        <form action="${pageContext.request.contextPath}/booking" method="post"
                              style="display:inline;"
                              onsubmit="return confirm('Cancel booking ${r.booking.bookingId}? This cannot be undone.');">
                          <input type="hidden" name="action"    value="cancel"/>
                          <input type="hidden" name="bookingId" value="${r.booking.bookingId}"/>
                          <button type="submit" class="mp-btn mp-btn--cancel">
                            <i class="ti ti-x"></i> Cancel
                          </button>
                        </form>
                      </div>
                    </td>
                  </tr>
                </c:if>
              </c:forEach>
            </tbody>
          </table>
        </c:when>
        <c:otherwise>
          <div class="mp-empty">
            <i class="ti ti-circle-check"></i>
            <p>All caught up &mdash; no bookings are awaiting payment.</p>
          </div>
        </c:otherwise>
      </c:choose>
    </div>

    <%-- ── Paid bookings ── --%>
    <div class="mp-card reveal">
      <div class="mp-card__head">
        <h3><i class="ti ti-check"></i> Paid bookings</h3>
        <span class="chip"><i class="ti ti-receipt" style="color:var(--bx-primary);"></i> ${paidCount} settled</span>
      </div>

      <c:set var="hasPaid" value="false"/>
      <c:forEach var="r" items="${rows}">
        <c:if test="${r.paid}"><c:set var="hasPaid" value="true"/></c:if>
      </c:forEach>

      <c:choose>
        <c:when test="${hasPaid}">
          <table class="mp-table">
            <thead>
              <tr>
                <th>Booking</th>
                <th>Vehicle</th>
                <th>Dates</th>
                <th>Method</th>
                <th>Amount paid</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="r" items="${rows}">
                <c:if test="${r.paid}">
                  <tr>
                    <td class="mp-mono" style="color:#fff;">
                      ${r.booking.bookingId}
                      <div class="mp-receipt">${r.paymentId}</div>
                    </td>
                    <td style="font-weight:600; color:#fff;">
                      ${r.booking.vehicleId}
                      <c:if test="${not empty r.booking.pickupLocation}">
                        <div style="margin-top:4px; color:rgba(255,255,255,0.55); font-size:11px; font-weight:400;">
                          <i class="ti ti-map-pin" style="color:var(--bx-primary);"></i>
                          ${r.booking.pickupLocation} &middot;
                          <span class="mp-mono">${r.booking.pickupTime}</span>
                        </div>
                      </c:if>
                    </td>
                    <td class="mp-mono mp-nowrap" style="color:rgba(255,255,255,0.7);">
                      ${r.booking.startDate} &rarr; ${r.booking.endDate}
                      <div class="mp-receipt">Paid ${r.paymentDate}</div>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${r.paymentMethod == 'CARD'}">
                          <span class="mp-method mp-method--card"><i class="ti ti-credit-card"></i> Card</span>
                        </c:when>
                        <c:otherwise>
                          <span class="mp-method mp-method--wallet"><i class="ti ti-wallet"></i> Wallet</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td class="mp-mono mp-nowrap">
                      <span style="color:var(--bx-primary); font-weight:600;">LKR</span>
                      <fmt:formatNumber value="${r.paymentAmount}" pattern="#,##0.00"/>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${r.payStatus == 'COMPLETED'}">
                          <span class="mp-badge mp-badge--done">Completed</span>
                        </c:when>
                        <c:otherwise>
                          <span class="mp-badge mp-badge--paid">Paid</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                  </tr>
                </c:if>
              </c:forEach>
            </tbody>
          </table>
        </c:when>
        <c:otherwise>
          <div class="mp-empty">
            <i class="ti ti-credit-card-off"></i>
            <p>No paid bookings yet. Pending payments above are ready to go.</p>
          </div>
        </c:otherwise>
      </c:choose>
    </div>

    <%-- ── Cancelled ── --%>
    <c:set var="hasCancelled" value="false"/>
    <c:forEach var="r" items="${rows}">
      <c:if test="${r.cancelled}"><c:set var="hasCancelled" value="true"/></c:if>
    </c:forEach>
    <c:if test="${hasCancelled}">
      <div class="mp-card reveal">
        <div class="mp-card__head">
          <h3><i class="ti ti-ban"></i> Cancelled</h3>
        </div>
        <table class="mp-table">
          <thead>
            <tr>
              <th>Booking</th>
              <th>Vehicle</th>
              <th>Dates</th>
              <th>Would-be total</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="r" items="${rows}">
              <c:if test="${r.cancelled}">
                <tr class="is-cancelled">
                  <td class="mp-mono">${r.booking.bookingId}</td>
                  <td>${r.booking.vehicleId}</td>
                  <td class="mp-mono mp-nowrap">${r.booking.startDate} &rarr; ${r.booking.endDate}</td>
                  <td class="mp-mono">LKR <fmt:formatNumber value="${r.computedTotal}" pattern="#,##0.00"/></td>
                  <td><span class="mp-badge mp-badge--cancel">Cancelled</span></td>
                </tr>
              </c:if>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </c:if>

    <%-- ── Legacy receipts without a bookingId ── --%>
    <c:if test="${not empty unlinkedPayments}">
      <div class="mp-card reveal">
        <div class="mp-card__head">
          <h3><i class="ti ti-history"></i> Older receipts</h3>
          <span class="chip">Imported without booking link</span>
        </div>
        <table class="mp-table">
          <thead>
            <tr>
              <th>Method</th>
              <th>Payment ID</th>
              <th>Amount</th>
              <th>Date</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="line" items="${unlinkedPayments}">
              <c:set var="parts" value="${fn:split(line, '|')}"/>
              <c:if test="${fn:length(parts) >= 6}">
                <tr>
                  <td>
                    <c:choose>
                      <c:when test="${parts[0] == 'CARD'}">
                        <span class="mp-method mp-method--card"><i class="ti ti-credit-card"></i> Card</span>
                      </c:when>
                      <c:otherwise>
                        <span class="mp-method mp-method--wallet"><i class="ti ti-wallet"></i> Wallet</span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td class="mp-mono" style="color:#fff;">${parts[1]}</td>
                  <td class="mp-mono">
                    <span style="color:var(--bx-primary); font-weight:600;">LKR</span>
                    <fmt:parseNumber  var="amt"  value="${parts[3]}" integerOnly="false"/>
                    <fmt:formatNumber value="${amt}" pattern="#,##0.00"/>
                  </td>
                  <td class="mp-mono mp-nowrap" style="color:rgba(255,255,255,0.6);">${parts[4]}</td>
                  <td>
                    <c:choose>
                      <c:when test="${parts[5] == 'Success'}"><span class="mp-badge mp-badge--paid">Success</span></c:when>
                      <c:when test="${parts[5] == 'Failed'}"><span class="mp-badge mp-badge--cancel">Failed</span></c:when>
                      <c:otherwise><span class="mp-badge mp-badge--gray">${parts[5]}</span></c:otherwise>
                    </c:choose>
                  </td>
                </tr>
              </c:if>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </c:if>

    <%-- ── Truly empty (no bookings AND no legacy receipts) ── --%>
    <c:if test="${empty rows and empty unlinkedPayments}">
      <div class="mp-card reveal">
        <div class="mp-empty" style="padding: 96px 24px;">
          <i class="ti ti-credit-card-off"></i>
          <p>You haven't made any bookings yet.<br/>
            <a href="${pageContext.request.contextPath}/search"
               style="color:var(--bx-primary); text-decoration:underline;">
              Browse the fleet
            </a>
            to get started.
          </p>
        </div>
      </div>
    </c:if>

  </div>

  <%-- ════════════ RIGHT RAIL ════════════ --%>
  <aside>
    <div class="mp-stat reveal">
      <div class="mp-stat__lbl">Total spent</div>
      <div class="mp-stat__val"><sup>LKR</sup><fmt:formatNumber value="${not empty totalSpent ? totalSpent : 0}" pattern="#,##0.00"/></div>
      <div class="mp-stat__hint">Lifetime, successful transactions only</div>
    </div>

    <div class="mp-stat reveal" style="background: linear-gradient(135deg, rgba(251,191,36,0.14) 0%, rgba(251,191,36,0.02) 100%); border-color: rgba(251,191,36,0.30);">
      <div class="mp-stat__lbl">Pending</div>
      <div class="mp-stat__val" style="color: var(--bx-warning);">${pendingCount}</div>
      <div class="mp-stat__hint">Bookings awaiting payment</div>
    </div>

    <div class="mp-stat reveal">
      <div class="mp-stat__lbl">Paid</div>
      <div class="mp-stat__val" style="color:#fff;">${paidCount}</div>
      <div class="mp-stat__hint">Settled bookings on file</div>
    </div>

    <div class="mp-stat reveal" style="background: linear-gradient(135deg, rgba(251,191,36,0.14) 0%, rgba(251,191,36,0.02) 100%); border-color: rgba(251,191,36,0.30);">
      <div class="mp-stat__lbl">Loyalty points</div>
      <div class="mp-stat__val" style="color: var(--bx-warning);">${not empty loyaltyPoints ? loyaltyPoints : 0}</div>
      <div class="mp-stat__hint">Redeemable on your next booking</div>
    </div>
  </aside>

</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
