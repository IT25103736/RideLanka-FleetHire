<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle"   value="Dashboard" scope="request"/>
<c:set var="sectionName" value="Home"      scope="request"/>
<c:set var="activePage"  value="dashboard" scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  /* ════════════════════════════════════════════════════════════
     Dashboard — dark+glass landing
     ════════════════════════════════════════════════════════════ */
  .ds-stats {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 16px;
    margin-bottom: 22px;
  }
  @media (max-width: 1080px) { .ds-stats { grid-template-columns: repeat(2, 1fr); } }
  @media (max-width: 600px)  { .ds-stats { grid-template-columns: 1fr; } }

  .ds-stat {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    padding: 20px 22px;
    transition: transform var(--t-base), background var(--t-base), border-color var(--t-base);
    text-decoration: none;
    color: inherit;
    display: block;
  }
  .ds-stat:hover {
    transform: translateY(-3px);
    background: var(--glass-bg-strong);
    border-color: rgba(255,255,255,0.18);
  }
  .ds-stat__head { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }
  .ds-stat__icon {
    width: 36px; height: 36px;
    border-radius: 10px;
    /* Kit §Focus §8 — flat tint, no decorative gradients on data surfaces. */
    background: rgba(111,203,163,0.10);
    border: 1px solid rgba(111,203,163,0.24);
    color: var(--bx-primary);
    display: inline-flex; align-items: center; justify-content: center;
    font-size: 18px;
  }
  .ds-stat--info  .ds-stat__icon { background: rgba(125,211,252,0.10); border-color: rgba(125,211,252,0.24); color: var(--bx-info); }
  .ds-stat--warn  .ds-stat__icon { background: rgba(251,191,36,0.10);  border-color: rgba(251,191,36,0.26); color: var(--bx-warning); }
  .ds-stat__lbl {
    font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase;
    color: rgba(255,255,255,0.55); font-weight: 600;
  }
  .ds-stat__val {
    font-family: 'Space Grotesk', var(--font-sans);
    font-size: 30px; font-weight: 700;
    letter-spacing: -0.025em; color: #fff;
    line-height: 1.05;
  }
  .ds-stat__sub { font-size: 11px; color: rgba(255,255,255,0.45); margin-top: 4px; }

  /* Row: recent + actions */
  .ds-row {
    display: grid;
    grid-template-columns: 1.6fr 1fr;
    gap: 18px;
    margin-bottom: 18px;
  }
  @media (max-width: 980px) { .ds-row { grid-template-columns: 1fr; } }

  .ds-card {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    overflow: hidden;
  }
  .ds-card__head {
    display: flex; align-items: center; justify-content: space-between;
    padding: 16px 22px;
    border-bottom: 1px solid var(--glass-border);
  }
  .ds-card__head h3 {
    font-family: var(--font-sans);
    font-size: 14px; font-weight: 600;
    color: #fff;
    display: inline-flex; align-items: center; gap: 8px;
  }
  .ds-card__head h3 i { color: var(--bx-primary); font-size: 16px; }
  .ds-card__body { padding: 20px 22px; }

  /* Mini table */
  .ds-table { width: 100%; border-collapse: collapse; }
  .ds-table thead th {
    text-align: left;
    padding: 10px 22px;
    font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase;
    color: rgba(255,255,255,0.5); font-weight: 700;
    border-bottom: 1px solid var(--glass-border);
  }
  .ds-table tbody td {
    padding: 12px 22px;
    font-size: 13px;
    color: rgba(255,255,255,0.78);
    border-bottom: 1px solid rgba(255,255,255,0.04);
  }
  .ds-table tbody tr:last-child td { border-bottom: 0; }
  .ds-table tbody tr:hover { background: rgba(255,255,255,0.03); }
  .ds-mono { font-family: var(--font-mono); }

  /* Badges */
  .ds-badge {
    display: inline-flex; align-items: center; gap: 5px;
    padding: 3px 10px;
    border-radius: var(--r-pill);
    font-size: 11px; font-weight: 600;
    letter-spacing: 0.02em;
    border: 1px solid;
  }
  .ds-badge--ok    { background: rgba(111,203,163,0.14); color: var(--bx-primary); border-color: rgba(111,203,163,0.32); }
  .ds-badge--info  { background: rgba(125,211,252,0.10); color: var(--bx-info); border-color: rgba(125,211,252,0.24); }
  .ds-badge--warn  { background: rgba(251,191,36,0.14); color: var(--bx-warning); border-color: rgba(251,191,36,0.28); }
  .ds-badge--err   { background: rgba(248,113,113,0.14); color: var(--bx-danger); border-color: rgba(248,113,113,0.32); }
  .ds-badge--gray  { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.65); border-color: var(--glass-border); }

  /* Quick actions */
  .ds-actions {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 10px;
  }
  .ds-action {
    display: flex; align-items: center; gap: 12px;
    padding: 14px 16px;
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-md);
    text-decoration: none;
    color: rgba(255,255,255,0.85);
    transition: background var(--t-fast), border-color var(--t-fast), transform var(--t-fast);
  }
  .ds-action:hover {
    background: rgba(111,203,163,0.06);
    border-color: rgba(111,203,163,0.32);
    transform: translateY(-2px);
  }
  .ds-action__icon {
    width: 34px; height: 34px;
    border-radius: 9px;
    background: rgba(111,203,163,0.16);
    color: var(--bx-primary);
    border: 1px solid rgba(111,203,163,0.24);
    display: inline-flex; align-items: center; justify-content: center;
    font-size: 17px;
    flex-shrink: 0;
  }
  .ds-action__title { font-size: 13px; font-weight: 600; color: #fff; letter-spacing: -0.005em; }
  .ds-action__sub   { font-size: 11px; color: rgba(255,255,255,0.5); margin-top: 2px; }

  /* Component status */
  .ds-comp { font-family: var(--font-mono); font-size: 11px; color: var(--bx-primary); letter-spacing: 0.04em; }

  /* Kit §Trust §6 — empty state must offer a next action, not just a message. */
  .ds-empty {
    text-align: center; padding: 48px 20px;
    color: rgba(255,255,255,0.55);
  }
  .ds-empty i { font-size: 32px; color: var(--bx-primary); display: block; margin-bottom: 10px; }
  .ds-empty h4 { color: #fff; font-size: 14px; margin: 0 0 4px; }
  .ds-empty p  { margin: 0 0 14px; font-size: 13px; }
</style>

<div class="page-header reveal">
  <span class="eyebrow">Live snapshot</span>
  <h1>Dashboard, <em>at a glance.</em></h1>
  <p>Welcome back &mdash; every component of the rental system, rendered in real time </p>
</div>

<!-- ── Stats grid — each card is a drill-down link ── -->
<div class="ds-stats">
  <a class="ds-stat" data-antigravity href="${pageContext.request.contextPath}/vehicle?action=list">
    <div class="ds-stat__head">
      <span class="ds-stat__icon"><i class="ti ti-car"></i></span>
      <span class="ds-stat__lbl">Total vehicles</span>
    </div>
    <div class="ds-stat__val">${not empty totalVehicles ? totalVehicles : 0}</div>
    <div class="ds-stat__sub">Fleet &middot; all classes</div>
  </a>
  <a class="ds-stat" data-antigravity href="${pageContext.request.contextPath}/vehicle?action=list">
    <div class="ds-stat__head">
      <span class="ds-stat__icon"><i class="ti ti-circle-check"></i></span>
      <span class="ds-stat__lbl">Available</span>
    </div>
    <div class="ds-stat__val">${not empty availableVehicles ? availableVehicles : 0}</div>
    <div class="ds-stat__sub">Ready for handover</div>
  </a>
  <a class="ds-stat ds-stat--info" data-antigravity href="${pageContext.request.contextPath}/admin/bookings">
    <div class="ds-stat__head">
      <span class="ds-stat__icon"><i class="ti ti-calendar-check"></i></span>
      <span class="ds-stat__lbl">Reservations</span>
    </div>
    <div class="ds-stat__val">${not empty totalBookings ? totalBookings : 0}</div>
    <div class="ds-stat__sub">View all &rarr;</div>
  </a>
  <a class="ds-stat" data-antigravity href="${pageContext.request.contextPath}/admin/members">
    <div class="ds-stat__head">
      <span class="ds-stat__icon"><i class="ti ti-users"></i></span>
      <span class="ds-stat__lbl">Members</span>
    </div>
    <div class="ds-stat__val">${not empty totalUsers ? totalUsers : 0}</div>
    <div class="ds-stat__sub">Member directory &rarr;</div>
  </a>
  <a class="ds-stat ds-stat--warn" data-antigravity href="${pageContext.request.contextPath}/payment/list">
    <div class="ds-stat__head">
      <span class="ds-stat__icon"><i class="ti ti-wallet"></i></span>
      <span class="ds-stat__lbl">Payments</span>
    </div>
    <div class="ds-stat__val">${not empty totalPayments ? totalPayments : 0}</div>
    <div class="ds-stat__sub">Payment ledger &rarr;</div>
  </a>
  <a class="ds-stat" data-antigravity href="${pageContext.request.contextPath}/review/moderate">
    <div class="ds-stat__head">
      <span class="ds-stat__icon"><i class="ti ti-quote"></i></span>
      <span class="ds-stat__lbl">Reviews</span>
    </div>
    <div class="ds-stat__val">${not empty totalReviews ? totalReviews : 0}</div>
    <div class="ds-stat__sub">Moderation queue &rarr;</div>
  </a>
</div>

<!-- ── Two-up chart row: revenue trend + booking mix ── -->
<div class="ds-row" style="grid-template-columns: 1.6fr 1fr; margin-bottom: 18px;">
  <div class="ds-card reveal">
    <div class="ds-card__head">
      <h3><i class="ti ti-chart-line"></i> Revenue trend</h3>
      <a href="${pageContext.request.contextPath}/admin/revenue" class="btn btn-ghost btn-sm">
        Full report <span class="ico-pill"><i class="ti ti-arrow-up-right"></i></span>
      </a>
    </div>
    <div style="padding:18px 22px;"><canvas id="chAdminRevenue" height="120"></canvas></div>
  </div>
  <div class="ds-card reveal">
    <div class="ds-card__head">
      <h3><i class="ti ti-chart-donut"></i> Booking mix</h3>
    </div>
    <div style="padding:18px 22px;"><canvas id="chAdminBookingMix" height="220"></canvas></div>
  </div>
</div>

<!-- ── Recent reservations + Quick actions ── -->
<div class="ds-row">

  <div class="ds-card reveal">
    <div class="ds-card__head">
      <h3><i class="ti ti-calendar-event"></i> Recent reservations</h3>
      <a href="${pageContext.request.contextPath}/booking?action=list" class="btn btn-ghost btn-sm">
        View all <span class="ico-pill"><i class="ti ti-arrow-up-right"></i></span>
      </a>
    </div>
    <table class="ds-table">
      <thead>
        <tr><th>ID</th><th>Member</th><th>Vehicle</th><th>Type</th><th>Pick-up</th><th>Status</th></tr>
      </thead>
      <tbody>
        <c:choose>
          <c:when test="${not empty recentBookings}">
            <c:forEach var="b" items="${recentBookings}">
              <tr>
                <td class="ds-mono" style="color:#fff;">${b.bookingId}</td>
                <td style="color:rgba(255,255,255,0.55);">${b.userId}</td>
                <td style="font-weight:500; color:#fff;">${b.vehicleId}</td>
                <td>
                  <%-- Kit §Focus §2 — booking type is a category, not a status:
                       icons (bolt / calendar) carry the distinction, palette stays neutral. --%>
                  <c:choose>
                    <c:when test="${b.bookingType == 'INSTANT'}">
                      <span class="ds-badge ds-badge--gray"><i class="ti ti-bolt"></i> Instant</span>
                    </c:when>
                    <c:otherwise>
                      <span class="ds-badge ds-badge--gray"><i class="ti ti-calendar-event"></i> Advance</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td style="color:rgba(255,255,255,0.7); font-size:12px;">
                  <c:choose>
                    <c:when test="${not empty b.pickupLocation}">
                      ${b.pickupLocation} &middot;
                      <span class="ds-mono" style="color:rgba(255,255,255,0.5);">${b.pickupTime}</span>
                    </c:when>
                    <c:otherwise><span style="color:rgba(255,255,255,0.3);">—</span></c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${b.status == 'ACTIVE'}"><span class="ds-badge ds-badge--ok">Active</span></c:when>
                    <c:when test="${b.status == 'COMPLETED'}"><span class="ds-badge ds-badge--info">Completed</span></c:when>
                    <c:when test="${b.status == 'CANCELLED'}"><span class="ds-badge ds-badge--err">Cancelled</span></c:when>
                    <c:otherwise><span class="ds-badge ds-badge--gray">${b.status}</span></c:otherwise>
                  </c:choose>
                </td>
              </tr>
            </c:forEach>
          </c:when>
          <c:otherwise>
            <tr><td colspan="6">
              <div class="ds-empty">
                <i class="ti ti-calendar-off"></i>
                <h4>No reservations yet</h4>
                <p>The booking ledger is empty &mdash; once members reserve a vehicle, the most recent ones land here.</p>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/booking?action=form">
                  <i class="ti ti-calendar-plus"></i> Create a reservation
                </a>
              </div>
            </td></tr>
          </c:otherwise>
        </c:choose>
      </tbody>
    </table>
  </div>

  <div class="ds-card reveal">
    <div class="ds-card__head">
      <h3><i class="ti ti-bolt"></i> Quick actions</h3>
    </div>
    <div class="ds-card__body">
      <div class="ds-actions">
        <a href="${pageContext.request.contextPath}/booking?action=form" class="ds-action">
          <span class="ds-action__icon"><i class="ti ti-calendar-plus"></i></span>
          <div>
            <div class="ds-action__title">New reservation</div>
            <div class="ds-action__sub">Instant or advance</div>
          </div>
        </a>
        <a href="${pageContext.request.contextPath}/search" class="ds-action">
          <span class="ds-action__icon"><i class="ti ti-zoom-in"></i></span>
          <div>
            <div class="ds-action__title">Browse fleet</div>
            <div class="ds-action__sub">50 vehicles</div>
          </div>
        </a>
        <a href="${pageContext.request.contextPath}/payment/history" class="ds-action">
          <span class="ds-action__icon"><i class="ti ti-wallet"></i></span>
          <div>
            <div class="ds-action__title">My payments</div>
            <div class="ds-action__sub">Pending &amp; paid bookings</div>
          </div>
        </a>
        <a href="${pageContext.request.contextPath}/review/submit" class="ds-action">
          <span class="ds-action__icon"><i class="ti ti-quote"></i></span>
          <div>
            <div class="ds-action__title">Leave a review</div>
            <div class="ds-action__sub">Tied to a booking</div>
          </div>
        </a>
        <a href="${pageContext.request.contextPath}/vehicle?action=list" class="ds-action">
          <span class="ds-action__icon"><i class="ti ti-car"></i></span>
          <div>
            <div class="ds-action__title">Fleet inventory</div>
            <div class="ds-action__sub">Admin only</div>
          </div>
        </a>
        <a href="${pageContext.request.contextPath}/profile" class="ds-action">
          <span class="ds-action__icon"><i class="ti ti-user-circle"></i></span>
          <div>
            <div class="ds-action__title">My profile</div>
            <div class="ds-action__sub">Account &amp; details</div>
          </div>
        </a>
      </div>
    </div>
  </div>

</div>

<script>
  (function () {
    if (!window.Chart) return;

    // Weekly revenue (last 8 weeks)
    const wLabels = [<c:forEach var="e" items="${weeklyRevenue}" varStatus="s">'${e.key}'<c:if test="${!s.last}">,</c:if></c:forEach>];
    const wValues = [<c:forEach var="e" items="${weeklyRevenue}" varStatus="s">${e.value}<c:if test="${!s.last}">,</c:if></c:forEach>];
    const cvAdminRev = document.getElementById('chAdminRevenue');
    if (cvAdminRev) {
      // Flat 10% tint (kit §Focus §7 — no gradient stops on chart fills).
      const grad = 'rgba(111,203,163,0.10)';
      new Chart(cvAdminRev, {
        type: 'line',
        data: { labels: wLabels, datasets: [{
          label: 'LKR', data: wValues,
          borderColor: VRMS_CHART.primary, backgroundColor: grad,
          tension: 0.35, fill: true, pointRadius: 2
        }]},
        options: { responsive: true, plugins: { legend: { display: false } },
          scales: { y: { grid: { color: VRMS_CHART.gridColor } }, x: { grid: { display: false } } } }
      });
    }

    // Booking mix (Instant vs Advance) — non-cancelled
    const cvMix = document.getElementById('chAdminBookingMix');
    if (cvMix) {
      new Chart(cvMix, {
        type: 'doughnut',
        data: { labels: ['Instant', 'Advance'],
          datasets: [{ data: [${instantCount}, ${advanceCount}],
            backgroundColor: [VRMS_CHART.primary, VRMS_CHART.warn],
            borderColor: 'rgba(0,0,0,0.15)', borderWidth: 2 }] },
        options: { responsive: true, cutout: '62%', plugins: { legend: { position: 'bottom' } } }
      });
    }
  })();
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
