<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="pageTitle"   value="All Reservations" scope="request"/>
<c:set var="sectionName" value="Admin"            scope="request"/>
<c:set var="activePage"  value="bookings"         scope="request"/>
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
  .mp-badge--paid    { background: rgba(111,203,163,0.14); color: var(--bx-primary); border-color: rgba(111,203,163,0.32); }
  .mp-badge--pending { background: rgba(251,191,36,0.14);  color: var(--bx-warning); border-color: rgba(251,191,36,0.30); }
  .mp-badge--cancel  { background: rgba(248,113,113,0.14); color: var(--bx-danger);  border-color: rgba(248,113,113,0.32); }
  .mp-badge--gray    { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.65); border-color: var(--glass-border); }

  /* Status filter chips */
  .ab-chips {
    display: flex; gap: 8px;
    padding: 14px 22px;
    border-bottom: 1px solid var(--glass-border);
  }
  .ab-chip {
    padding: 5px 12px;
    border-radius: var(--r-pill);
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--glass-border);
    color: rgba(255,255,255,0.7);
    font-size: 11px; font-weight: 600;
    cursor: pointer;
    font-family: var(--font-sans);
    transition: background var(--t-fast), border-color var(--t-fast);
  }
  .ab-chip:hover {
    border-color: rgba(111,203,163,0.32);
    background: rgba(111,203,163,0.06);
  }
  .ab-chip.is-active {
    background: rgba(111,203,163,0.18);
    color: var(--bx-primary);
    border-color: rgba(111,203,163,0.40);
  }

  /* Kit §Trust §6 — distinct empty states: nothing on file vs filter-returns-zero. */
  .mp-empty {
    text-align: center;
    padding: 56px 24px;
    color: rgba(255,255,255,0.55);
  }
  .mp-empty i { font-size: 32px; color: var(--bx-primary); display: block; margin-bottom: 12px; }
  .mp-empty h4 { color: #fff; font-size: 15px; margin: 0 0 6px; }
  .mp-empty p { margin: 0 0 16px; font-size: 13px; }
  .mp-empty--filter { display: none; }
  .mp-empty--filter.is-visible { display: block; }

  /* ── WhatsApp "Notify customer" button ── */
  .mp-wa-btn {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 6px 12px;
    background: rgba(37,211,102,0.12);
    border: 1px solid rgba(37,211,102,0.45);
    color: #25D366;
    border-radius: var(--r-pill);
    font-family: var(--font-sans);
    font-size: 11px; font-weight: 600;
    letter-spacing: 0.02em;
    text-decoration: none;
    transition: background var(--t-fast), border-color var(--t-fast), color var(--t-fast);
  }
  .mp-wa-btn:hover {
    background: #25D366;
    border-color: #25D366;
    color: #fff;
  }
  .mp-wa-btn i { font-size: 14px; }
</style>

<div class="page-header-row reveal">
  <div class="page-header" style="margin-bottom:0;">
    <span class="eyebrow">Admin</span>
    <h1>All <em>reservations.</em></h1>
    <p>Every booking across all members &mdash; sourced from <span class="mp-mono">data/bookings.txt</span>.</p>
  </div>
  <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-secondary">
    <i class="ti ti-arrow-left"></i> Back to Dashboard
  </a>
</div>

<div class="mp-card reveal">
  <div class="mp-card__head">
    <h3><i class="ti ti-calendar-event"></i> All reservations</h3>
    <span class="chip"><i class="ti ti-database" style="color:var(--bx-primary);"></i> ${fn:length(bookings)} on file</span>
  </div>

  <c:if test="${not empty bookings}">
  <div class="ab-chips">
    <button class="ab-chip is-active" data-status-filter="ALL">All</button>
    <button class="ab-chip" data-status-filter="ACTIVE">Active</button>
    <button class="ab-chip" data-status-filter="COMPLETED">Completed</button>
    <button class="ab-chip" data-status-filter="CANCELLED">Cancelled</button>
  </div>
  </c:if>

  <c:choose>
    <c:when test="${not empty bookings}">
  <table class="mp-table">
    <thead>
      <tr>
        <th>Booking ID</th>
        <th>Member</th>
        <th>Vehicle</th>
        <th>Type</th>
        <th>Dates</th>
        <th>Pick-up</th>
        <th>Status</th>
        <th style="width:120px;">Notify</th>
      </tr>
    </thead>
    <tbody>
      <c:forEach var="b" items="${bookings}">
        <tr data-row-status="${b.status}">
          <td class="mp-mono" style="color:#fff;">${b.bookingId}</td>
          <td>${not empty nameById[b.userId] ? nameById[b.userId] : b.userId}</td>
          <td style="font-weight:500; color:#fff;">${b.vehicleId}</td>
          <td>
            <%-- Kit §Focus §2 — booking type is a category, not a status: neutral pill + icon. --%>
            <c:choose>
              <c:when test="${b.bookingType == 'INSTANT'}"><span class="mp-badge mp-badge--gray"><i class="ti ti-bolt"></i>Instant</span></c:when>
              <c:otherwise><span class="mp-badge mp-badge--gray"><i class="ti ti-calendar-event"></i>Advance</span></c:otherwise>
            </c:choose>
          </td>
          <td class="mp-mono mp-nowrap" style="color:rgba(255,255,255,0.7);">${b.startDate} &rarr; ${b.endDate}</td>
          <td style="font-size:12px;">
            <c:choose>
              <c:when test="${not empty b.pickupLocation}">
                <span style="color:#fff;"><i class="ti ti-map-pin" style="color:var(--bx-primary);"></i> ${b.pickupLocation}</span>
                <span class="mp-mono" style="color:rgba(255,255,255,0.55); margin-left:6px;">${b.pickupTime}</span>
              </c:when>
              <c:otherwise><span style="color:rgba(255,255,255,0.4);">&mdash;</span></c:otherwise>
            </c:choose>
          </td>
          <td>
            <c:choose>
              <c:when test="${b.status == 'ACTIVE'}"><span class="mp-badge mp-badge--paid">Active</span></c:when>
              <c:when test="${b.status == 'COMPLETED'}"><span class="mp-badge mp-badge--gray">Completed</span></c:when>
              <c:when test="${b.status == 'CANCELLED'}"><span class="mp-badge mp-badge--cancel">Cancelled</span></c:when>
              <c:otherwise><span class="mp-badge mp-badge--gray">${b.status}</span></c:otherwise>
            </c:choose>
          </td>
          <td>
            <%-- Admin clicks → opens WhatsApp from the 94778119913 business
                 account → sends the formatted confirmation to the customer.
                 Skipped when booking has no phone or status is CANCELLED. --%>
            <c:choose>
              <c:when test="${b.status != 'CANCELLED' and not empty waUrlByBooking[b.bookingId]}">
                <a class="mp-wa-btn" target="_blank" rel="noopener"
                   href="${waUrlByBooking[b.bookingId]}"
                   title="Send confirmation on WhatsApp from +94 77 811 9913">
                  <i class="ti ti-brand-whatsapp"></i> WhatsApp
                </a>
              </c:when>
              <c:when test="${empty b.customerPhone}">
                <span class="mp-mono" style="color:rgba(255,255,255,0.3); font-size:11px;">no phone</span>
              </c:when>
              <c:otherwise>
                <span class="mp-mono" style="color:rgba(255,255,255,0.3); font-size:11px;">&mdash;</span>
              </c:otherwise>
            </c:choose>
          </td>
        </tr>
      </c:forEach>
    </tbody>
  </table>

  <!-- Kit §Trust §6 — "filter returns zero" surface, toggled by the filter JS below. -->
  <div class="mp-empty mp-empty--filter" id="abFilterEmpty">
    <i class="ti ti-filter-off"></i>
    <h4>No reservations match this filter</h4>
    <p>Try a different status or clear the filter to see every booking.</p>
    <button type="button" class="btn btn-secondary" id="abClearFilter">
      <i class="ti ti-x"></i> Clear filter
    </button>
  </div>
    </c:when>
    <c:otherwise>
      <div class="mp-empty">
        <i class="ti ti-calendar-off"></i>
        <h4>No reservations on file</h4>
        <p>The booking ledger is empty. New reservations from members will surface here.</p>
        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/booking?action=form">
          <i class="ti ti-calendar-plus"></i> Create a reservation
        </a>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<script>
  (function () {
    var chips    = document.querySelectorAll('.ab-chip');
    var rows     = document.querySelectorAll('tr[data-row-status]');
    var empty    = document.getElementById('abFilterEmpty');
    var clearBtn = document.getElementById('abClearFilter');

    function applyFilter(want) {
      var shown = 0;
      rows.forEach(function (row) {
        var status = row.getAttribute('data-row-status');
        var match  = (want === 'ALL' || status === want);
        row.style.display = match ? '' : 'none';
        if (match) shown++;
      });
      if (empty) empty.classList.toggle('is-visible', shown === 0 && want !== 'ALL');
    }

    chips.forEach(function (btn) {
      btn.addEventListener('click', function () {
        chips.forEach(function (b) { b.classList.toggle('is-active', b === btn); });
        applyFilter(btn.getAttribute('data-status-filter'));
      });
    });

    if (clearBtn) {
      clearBtn.addEventListener('click', function () {
        var all = document.querySelector('.ab-chip[data-status-filter="ALL"]');
        if (all) all.click();
      });
    }
  })();
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
