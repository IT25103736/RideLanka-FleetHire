<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle"   value="My Reservations" scope="request"/>
<c:set var="sectionName" value="Reservations"     scope="request"/>
<c:set var="activePage"  value="mybookings"       scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  /* ════════════════════════════════════════════════════════════
     My reservations — dark+glass ledger
     ════════════════════════════════════════════════════════════ */
  .mb-card {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    overflow: hidden;
  }
  .mb-table { width: 100%; border-collapse: collapse; }
  .mb-table thead th {
    text-align: left;
    padding: 14px 20px;
    font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase;
    color: rgba(255,255,255,0.5); font-weight: 700;
    border-bottom: 1px solid var(--glass-border);
  }
  .mb-table thead th:last-child { text-align: right; }
  .mb-table tbody td {
    padding: 14px 20px;
    border-bottom: 1px solid rgba(255,255,255,0.04);
    font-size: 13px;
    color: rgba(255,255,255,0.78);
    vertical-align: middle;
  }
  .mb-table tbody tr:last-child td { border-bottom: 0; }
  .mb-table tbody tr { transition: background var(--t-fast); }
  .mb-table tbody tr:hover { background: rgba(255,255,255,0.03); }
  .mb-table tbody tr.is-cancelled { opacity: 0.55; }

  .mb-mono { font-family: var(--font-mono); }

  /* Badges */
  .mb-badge {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 4px 10px;
    border-radius: var(--r-pill);
    font-size: 11px; font-weight: 600;
    letter-spacing: 0.02em;
    border: 1px solid;
  }
  .mb-badge--type-instant {
    background: rgba(111,203,163,0.14);
    color: var(--bx-primary);
    border-color: rgba(111,203,163,0.32);
  }
  .mb-badge--type-advance {
    background: rgba(251,191,36,0.14);
    color: var(--bx-warning);
    border-color: rgba(251,191,36,0.28);
  }
  .mb-badge--st-active {
    background: rgba(111,203,163,0.14);
    color: var(--bx-primary);
    border-color: rgba(111,203,163,0.32);
  }
  .mb-badge--st-cancelled {
    background: rgba(248,113,113,0.14);
    color: var(--bx-danger);
    border-color: rgba(248,113,113,0.32);
  }
  .mb-badge--st-completed {
    background: rgba(125,211,252,0.10);
    color: var(--bx-info);
    border-color: rgba(125,211,252,0.24);
  }
  .mb-badge--st-active::before, .mb-badge--st-cancelled::before, .mb-badge--st-completed::before {
    content: ""; width: 6px; height: 6px; border-radius: 50%;
    background: currentColor;
    box-shadow: 0 0 0 3px rgba(255,255,255,0.08);
  }

  /* "With Chauffeur" badge */
  .mb-driver {
    display: inline-flex; align-items: center; gap: 5px;
    padding: 3px 9px;
    border-radius: var(--r-pill);
    font-size: 10px; font-weight: 600;
    letter-spacing: 0.04em;
    background: rgba(111,203,163,0.10);
    border: 1px solid rgba(111,203,163,0.28);
    color: var(--bx-primary);
    margin-left: 6px;
  }
  .mb-driver i { font-size: 12px; }

  /* Cancel button */
  .mb-cancel {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 6px 12px;
    background: rgba(248,113,113,0.10);
    border: 1px solid rgba(248,113,113,0.28);
    color: var(--bx-danger);
    border-radius: var(--r-md);
    font-family: var(--font-sans);
    font-size: 12px; font-weight: 600;
    cursor: pointer;
    transition: background var(--t-fast), border-color var(--t-fast);
  }
  .mb-cancel:hover {
    background: rgba(248,113,113,0.18);
    border-color: rgba(248,113,113,0.40);
  }
  .mb-actions { display:inline-flex; align-items:center; justify-content:flex-end; gap:6px; flex-wrap:wrap; }
  .mb-action {
    display:inline-flex; align-items:center; gap:6px; padding:6px 10px;
    border-radius:var(--r-md); font-size:12px; font-weight:600; text-decoration:none;
    border:1px solid var(--glass-border); color:rgba(255,255,255,0.82); background:rgba(255,255,255,0.04);
  }
  .mb-action:hover { border-color:rgba(111,203,163,0.34); color:var(--bx-primary); }
  .mb-action--pay { background:rgba(111,203,163,0.12); border-color:rgba(111,203,163,0.30); color:var(--bx-primary); }

  /* Cancelled section header */
  .mb-section-row td {
    background: rgba(255,255,255,0.02) !important;
    color: rgba(255,255,255,0.5) !important;
    font-size: 10px !important;
    font-weight: 700 !important;
    text-transform: uppercase !important;
    letter-spacing: 0.22em !important;
    padding: 12px 22px !important;
  }

  /* Empty state */
  .mb-empty {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    padding: 80px 24px;
    text-align: center;
  }
  .mb-empty__icon {
    width: 72px; height: 72px;
    border-radius: 50%;
    background: linear-gradient(135deg, rgba(111,203,163,0.18) 0%, rgba(111,203,163,0.04) 100%);
    border: 1px solid rgba(111,203,163,0.28);
    color: var(--bx-primary);
    display: inline-flex; align-items: center; justify-content: center;
    font-size: 32px;
    margin: 0 auto 22px;
  }
  .mb-empty h3 {
    font-family: 'Manrope', var(--font-sans);
    font-size: 28px; font-weight: 600;
    letter-spacing: -0.025em;
    color: #fff;
  }
  .mb-empty h3 em { font-style: normal; color: var(--bx-primary); }
  .mb-empty p {
    color: rgba(255,255,255,0.65);
    font-size: 14px;
    margin: 14px auto 26px; max-width: 42ch;
  }

  /* Alerts */
  .mb-alert {
    padding: 14px 18px;
    border-radius: var(--r-md);
    display: flex; gap: 12px; align-items: flex-start;
    font-size: 13px;
    margin-bottom: 18px;
  }
  .mb-alert i { font-size: 18px; margin-top: 1px; flex-shrink: 0; }
  .mb-alert--ok  { background: rgba(111,203,163,0.10); border: 1px solid rgba(111,203,163,0.32); color: var(--bx-primary-ink); }
  .mb-alert--ok  i { color: var(--bx-primary); }
  .mb-alert--err { background: rgba(248,113,113,0.10); border: 1px solid rgba(248,113,113,0.32); color: var(--bx-danger-ink); }
  .mb-alert--err i { color: var(--bx-danger); }

  @media (max-width: 760px) {
    .mb-table thead { display: none; }
    .mb-table tbody tr { display: block; padding: 10px 0; border-bottom: 1px solid var(--glass-border); }
    .mb-table tbody td { padding: 6px 16px; display: block; }
    .mb-table tbody td:last-child { padding-bottom: 14px; }
  }
</style>

<div class="page-header-row reveal">
  <div class="page-header" style="margin-bottom:0;">
    <span class="eyebrow">Your ledger</span>
    <h1>My <em>reservations.</em></h1>
    <p>Every drive you've booked &mdash; present, past, and the ones you decided against.</p>
  </div>
  <a href="${pageContext.request.contextPath}/booking?action=form" class="btn btn-primary" data-antigravity>
    New reservation
    <span class="ico-pill"><i class="ti ti-arrow-up-right"></i></span>
  </a>
</div>

<c:if test="${not empty successMsg}">
  <div class="mb-alert mb-alert--ok reveal">
    <i class="ti ti-circle-check"></i><div>${successMsg}</div>
  </div>
</c:if>
<c:if test="${not empty errorMsg}">
  <div class="mb-alert mb-alert--err reveal">
    <i class="ti ti-alert-circle"></i><div>${errorMsg}</div>
  </div>
</c:if>

<c:choose>
  <c:when test="${empty activeBookings and empty bookings and empty cancelledBookings}">
    <div class="mb-empty reveal">
      <div class="mb-empty__icon"><i class="ti ti-bookmark-off"></i></div>
      <h3>The ledger is <em>quiet.</em></h3>
      <p>You haven't booked a drive yet. Browse the fleet and the first reservation lands here in under a minute.</p>
      <a href="${pageContext.request.contextPath}/search" class="btn btn-primary btn-lg" data-antigravity>
        Browse the fleet
        <span class="ico-pill"><i class="ti ti-arrow-up-right"></i></span>
      </a>
    </div>
  </c:when>
  <c:otherwise>
    <div class="mb-card reveal">
      <table class="mb-table">
        <thead>
          <tr>
            <th>Booking ID</th>
            <th>Vehicle</th>
            <th>Type</th>
            <th>Dates</th>
            <th>Pick-up</th>
            <th>Status</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>

          <c:set var="activeList" value="${not empty activeBookings ? activeBookings : bookings}"/>

          <c:forEach var="b" items="${activeList}">
            <c:if test="${b.status != 'CANCELLED'}">
              <tr>
                <td class="mb-mono" style="color:#fff;">${b.bookingId}</td>
                <td style="font-weight:600; color:#fff;">
                  ${b.vehicleId}
                  <c:if test="${b.withDriver}">
                    <span class="mb-driver"><i class="ti ti-steering-wheel"></i> With chauffeur</span>
                  </c:if>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${b.bookingType == 'INSTANT'}">
                      <span class="mb-badge mb-badge--type-instant"><i class="ti ti-bolt"></i> Instant</span>
                    </c:when>
                    <c:otherwise>
                      <span class="mb-badge mb-badge--type-advance"><i class="ti ti-calendar-event"></i> Advance</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td class="mb-mono" style="color:rgba(255,255,255,0.7);">
                  ${b.startDate} &rarr; ${b.endDate}
                </td>
                <td style="font-size:12px;">
                  <c:choose>
                    <c:when test="${not empty b.pickupLocation}">
                      <div style="color:#fff;"><i class="ti ti-map-pin" style="color:var(--bx-primary);"></i> ${b.pickupLocation}</div>
                      <div style="color:rgba(255,255,255,0.55); font-family:var(--font-mono); font-size:11px;">${b.pickupTime}</div>
                    </c:when>
                    <c:otherwise><span style="color:rgba(255,255,255,0.35);">—</span></c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${b.status == 'PENDING'}"><span class="mb-badge mb-badge--type-advance">Pending payment</span></c:when>
                    <c:when test="${b.status == 'CONFIRMED'}"><span class="mb-badge mb-badge--st-active">Confirmed</span></c:when>
                    <c:when test="${b.status == 'ACTIVE'}"><span class="mb-badge mb-badge--st-active">Active rental</span></c:when>
                    <c:when test="${b.status == 'COMPLETED'}"><span class="mb-badge mb-badge--st-completed">Completed</span></c:when>
                    <c:otherwise><span class="mb-badge mb-badge--st-active">${b.status}</span></c:otherwise>
                  </c:choose>
                </td>
                <td style="text-align:right;">
                  <span class="mb-actions">
                    <c:if test="${b.status == 'PENDING'}">
                      <a class="mb-action" href="${pageContext.request.contextPath}/booking?action=edit&amp;bookingId=${b.bookingId}"><i class="ti ti-edit"></i> Edit</a>
                      <a class="mb-action mb-action--pay" href="${pageContext.request.contextPath}/payment/checkout?bookingId=${b.bookingId}"><i class="ti ti-credit-card"></i> Pay</a>
                    </c:if>
                    <c:if test="${b.status == 'PENDING' or b.status == 'CONFIRMED'}">
                      <form action="${pageContext.request.contextPath}/booking" method="post" style="display:inline;" onsubmit="return confirm('Cancel booking ${b.bookingId}?');">
                        <input type="hidden" name="action" value="cancel"/>
                        <input type="hidden" name="bookingId" value="${b.bookingId}"/>
                        <button type="submit" class="mb-cancel"><i class="ti ti-x"></i> Cancel</button>
                      </form>
                    </c:if>
                  </span>
                </td>
              </tr>
            </c:if>
          </c:forEach>

          <c:if test="${not empty cancelledBookings}">
            <tr class="mb-section-row">
              <td colspan="7">Cancelled bookings</td>
            </tr>
            <c:forEach var="b" items="${cancelledBookings}">
              <tr class="is-cancelled">
                <td class="mb-mono" style="color:rgba(255,255,255,0.55);">${b.bookingId}</td>
                <td style="color:rgba(255,255,255,0.55);">
                  ${b.vehicleId}
                  <c:if test="${b.withDriver}">
                    <span class="mb-driver"><i class="ti ti-steering-wheel"></i> With chauffeur</span>
                  </c:if>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${b.bookingType == 'INSTANT'}">
                      <span class="mb-badge mb-badge--type-instant">Instant</span>
                    </c:when>
                    <c:otherwise>
                      <span class="mb-badge mb-badge--type-advance">Advance</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td class="mb-mono" style="color:rgba(255,255,255,0.45);">
                  ${b.startDate} &rarr; ${b.endDate}
                </td>
                <td style="color:rgba(255,255,255,0.4); font-size:12px;">
                  <c:choose>
                    <c:when test="${not empty b.pickupLocation}">
                      ${b.pickupLocation} &middot; ${b.pickupTime}
                    </c:when>
                    <c:otherwise>—</c:otherwise>
                  </c:choose>
                </td>
                <td><span class="mb-badge mb-badge--st-cancelled">Cancelled</span></td>
                <td></td>
              </tr>
            </c:forEach>
          </c:if>

        </tbody>
      </table>
    </div>
  </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
