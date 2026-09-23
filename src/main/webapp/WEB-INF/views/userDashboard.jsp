<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle"   value="Dashboard"  scope="request"/>
<c:set var="sectionName" value="Home"       scope="request"/>
<c:set var="activePage"  value="dashboard"  scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  /* ════════════════════════════════════════════════════════════
     User dashboard — pending & paid + pickup details + recos
     ════════════════════════════════════════════════════════════ */
  .ud-stats {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 16px;
    margin-bottom: 22px;
  }
  @media (max-width: 980px) { .ud-stats { grid-template-columns: repeat(2, 1fr); } }
  @media (max-width: 600px) { .ud-stats { grid-template-columns: 1fr; } }

  .ud-stat {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    padding: 22px;
    text-decoration: none;
    color: inherit;
    display: block;
    transition: transform var(--t-base), border-color var(--t-base);
  }
  .ud-stat:hover {
    transform: translateY(-3px);
    border-color: rgba(111,203,163,0.32);
  }
  .ud-stat__lbl {
    font-size: 10px; letter-spacing: 0.18em; text-transform: uppercase;
    color: rgba(255,255,255,0.55); font-weight: 600;
  }
  .ud-stat__val {
    font-family: 'Manrope', var(--font-sans);
    font-size: 32px; font-weight: 700;
    color: var(--bx-primary);
    letter-spacing: -0.022em;
    margin-top: 6px; line-height: 1;
  }
  .ud-stat__val sup {
    font-size: 12px; color: rgba(255,255,255,0.55);
    margin-right: 4px; font-weight: 500; vertical-align: top;
  }
  .ud-stat--pending .ud-stat__val { color: var(--bx-warning); }
  .ud-stat--paid    .ud-stat__val { color: #fff; }
  .ud-stat__hint { font-size: 11px; color: rgba(255,255,255,0.5); margin-top: 6px; }

  .ud-card {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    overflow: hidden;
    margin-bottom: 18px;
  }
  .ud-card__head {
    display: flex; align-items: center; justify-content: space-between;
    padding: 18px 24px;
    border-bottom: 1px solid var(--glass-border);
  }
  .ud-card__head h3 {
    font-family: var(--font-sans);
    font-size: 14px; font-weight: 600; color: #fff;
    display: inline-flex; align-items: center; gap: 8px;
  }
  .ud-card__head h3 i { color: var(--bx-primary); font-size: 16px; }
  .ud-card__head .chip {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 4px 10px;
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-pill);
    font-size: 11px; color: rgba(255,255,255,0.65);
  }

  .ud-table { width: 100%; border-collapse: collapse; }
  .ud-table thead th {
    text-align: left;
    padding: 12px 22px;
    font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase;
    color: rgba(255,255,255,0.5); font-weight: 700;
    border-bottom: 1px solid var(--glass-border);
  }
  .ud-table thead th:last-child { text-align: right; }
  .ud-table tbody td {
    padding: 14px 22px;
    font-size: 13px;
    color: rgba(255,255,255,0.78);
    border-bottom: 1px solid rgba(255,255,255,0.04);
    vertical-align: middle;
  }
  .ud-table tbody tr:last-child td { border-bottom: 0; }
  .ud-mono   { font-family: var(--font-mono); }
  .ud-nowrap { white-space: nowrap; }

  .ud-badge {
    display: inline-flex; align-items: center; gap: 5px;
    padding: 3px 10px;
    border-radius: var(--r-pill);
    font-size: 11px; font-weight: 600;
    border: 1px solid;
  }
  .ud-badge--pending { background: rgba(251,191,36,0.14);  color: var(--bx-warning); border-color: rgba(251,191,36,0.30); }
  .ud-badge--paid    { background: rgba(111,203,163,0.14); color: var(--bx-primary); border-color: rgba(111,203,163,0.32); }
  .ud-badge--type    { background: rgba(125,211,252,0.10); color: var(--bx-info);    border-color: rgba(125,211,252,0.24); }
  /* Kit §Focus §2 — booking type (Instant/Advance) is a category, not a status.
     Icons (bolt / calendar) carry the distinction; palette stays neutral. */
  .ud-badge--btype   { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.82); border-color: var(--glass-border); }

  .ud-btn {
    display: inline-flex; align-items: center; gap: 5px;
    padding: 6px 12px;
    border-radius: var(--r-md);
    font-size: 12px; font-weight: 600;
    text-decoration: none;
    border: 1px solid;
    cursor: pointer;
    font-family: var(--font-sans);
  }
  .ud-btn--pay {
    background: var(--bx-primary);
    color: var(--bx-night);
    border-color: var(--bx-primary);
  }
  .ud-btn--cancel {
    background: rgba(248,113,113,0.10);
    color: var(--bx-danger);
    border-color: rgba(248,113,113,0.28);
  }
  .ud-actions { display: inline-flex; gap: 6px; flex-wrap: wrap; justify-content: flex-end; }

  .ud-pickup {
    display: inline-flex; flex-direction: column; gap: 2px;
    font-size: 12px;
  }
  .ud-pickup__loc { color: #fff; }
  .ud-pickup__loc i { color: var(--bx-primary); }
  .ud-pickup__time { color: rgba(255,255,255,0.55); font-family: var(--font-mono); font-size: 11px; }

  .ud-empty { text-align: center; padding: 48px 24px; color: rgba(255,255,255,0.55); }
  .ud-empty i { font-size: 32px; color: var(--bx-primary); display: block; margin-bottom: 10px; }

  /* Recommended vehicles grid */
  .ud-reco-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 14px;
    padding: 18px;
  }
  @media (max-width: 980px) { .ud-reco-grid { grid-template-columns: repeat(2, 1fr); } }
  @media (max-width: 540px) { .ud-reco-grid { grid-template-columns: 1fr; } }

  .ud-reco {
    background: rgba(255,255,255,0.03);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-md);
    overflow: hidden;
    text-decoration: none;
    color: inherit;
    transition: transform var(--t-base), border-color var(--t-base);
    display: flex; flex-direction: column;
  }
  .ud-reco:hover { transform: translateY(-3px); border-color: rgba(111,203,163,0.32); }
  .ud-reco__media {
    aspect-ratio: 16 / 10;
    background: rgba(0,0,0,0.4) center/cover no-repeat;
    position: relative;
  }
  .ud-reco__media img { width: 100%; height: 100%; object-fit: cover; display: block; }
  .ud-reco__body { padding: 12px 14px; }
  .ud-reco__name { font-weight: 600; color: #fff; font-size: 13px; }
  .ud-reco__sub  { font-size: 11px; color: rgba(255,255,255,0.55); margin-top: 3px; }
  .ud-reco__price {
    margin-top: 8px;
    font-family: var(--font-mono);
    font-size: 13px; font-weight: 600;
    color: var(--bx-primary);
  }
  .ud-reco__price small { font-size: 10px; color: rgba(255,255,255,0.55); font-weight: 500; }
</style>

<div class="page-header reveal">
  <span class="eyebrow">Your account</span>
  <h1>Hello, <em>${sessionScope.loggedUser.name}.</em></h1>
  <p>Track your pending payments, upcoming pickups and discover what to drive next &mdash; all in one place.</p>
</div>

<!-- ── Stats row — each card drills into /payment/history ── -->
<div class="ud-stats">
  <a class="ud-stat ud-stat--pending" href="${pageContext.request.contextPath}/payment/history">
    <div class="ud-stat__lbl">Pending payments</div>
    <div class="ud-stat__val">${pendingCount}</div>
    <div class="ud-stat__hint">Bookings awaiting payment</div>
  </a>
  <a class="ud-stat ud-stat--paid" href="${pageContext.request.contextPath}/payment/history">
    <div class="ud-stat__lbl">Paid bookings</div>
    <div class="ud-stat__val">${paidCount}</div>
    <div class="ud-stat__hint">Settled and confirmed</div>
  </a>
  <a class="ud-stat" href="${pageContext.request.contextPath}/payment/history">
    <div class="ud-stat__lbl">Total spent</div>
    <div class="ud-stat__val"><sup>LKR</sup><fmt:formatNumber value="${not empty totalSpent ? totalSpent : 0}" pattern="#,##0.00"/></div>
    <div class="ud-stat__hint">Lifetime, successful only</div>
  </a>
</div>

<!-- ── Two-up chart row: spending trend + status mix ── -->
<div style="display:grid; grid-template-columns: 1.6fr 1fr; gap: 16px; margin-bottom: 18px;">
  <div class="ud-card reveal">
    <div class="ud-card__head">
      <h3><i class="ti ti-chart-line"></i> Spending trend</h3>
      <span class="chip">Last 6 months</span>
    </div>
    <div style="padding:18px 22px;"><canvas id="chUserSpending" height="120"></canvas></div>
  </div>
  <div class="ud-card reveal">
    <div class="ud-card__head">
      <h3><i class="ti ti-chart-donut"></i> Bookings by status</h3>
    </div>
    <div style="padding:18px 22px;"><canvas id="chUserBookingMix" height="220"></canvas></div>
  </div>
</div>

<!-- ── Pending payments ── -->
<div class="ud-card reveal">
  <div class="ud-card__head">
    <h3><i class="ti ti-clock-hour-3"></i> Pending payments</h3>
    <span class="chip">${pendingCount} awaiting payment</span>
  </div>
  <c:choose>
    <c:when test="${not empty pendingBookings}">
      <table class="ud-table">
        <thead>
          <tr>
            <th>Booking</th>
            <th>Vehicle</th>
            <th>Dates</th>
            <th>Pick-up</th>
            <th>Type</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="b" items="${pendingBookings}">
            <tr>
              <td class="ud-mono" style="color:#fff;">${b.bookingId}</td>
              <td style="font-weight:600; color:#fff;">${b.vehicleId}</td>
              <td class="ud-mono ud-nowrap" style="color:rgba(255,255,255,0.7);">
                ${b.startDate} &rarr; ${b.endDate}
              </td>
              <td>
                <c:choose>
                  <c:when test="${not empty b.pickupLocation}">
                    <span class="ud-pickup">
                      <span class="ud-pickup__loc"><i class="ti ti-map-pin"></i> ${b.pickupLocation}</span>
                      <span class="ud-pickup__time">Pickup ${b.pickupTime} &middot; Return ${b.endDate} ${b.pickupTime}</span>
                    </span>
                  </c:when>
                  <c:otherwise><span style="color:rgba(255,255,255,0.35);">&mdash;</span></c:otherwise>
                </c:choose>
              </td>
              <td>
                <c:choose>
                  <c:when test="${b.bookingType == 'INSTANT'}">
                    <span class="ud-badge ud-badge--btype"><i class="ti ti-bolt"></i> Instant</span>
                  </c:when>
                  <c:otherwise>
                    <span class="ud-badge ud-badge--btype"><i class="ti ti-calendar-event"></i> Advance</span>
                  </c:otherwise>
                </c:choose>
              </td>
              <td style="text-align:right;">
                <div class="ud-actions">
                  <%-- /payment/history computes the right amount + renders Pay-now CTAs --%>
                  <a class="ud-btn ud-btn--pay"
                     href="${pageContext.request.contextPath}/payment/history">
                    <i class="ti ti-credit-card"></i> Pay now
                  </a>
                  <form action="${pageContext.request.contextPath}/booking" method="post"
                        style="display:inline;"
                        onsubmit="return confirm('Cancel booking ${b.bookingId}?');">
                    <input type="hidden" name="action"    value="cancel"/>
                    <input type="hidden" name="bookingId" value="${b.bookingId}"/>
                    <button type="submit" class="ud-btn ud-btn--cancel">
                      <i class="ti ti-x"></i> Cancel
                    </button>
                  </form>
                </div>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </c:when>
    <c:otherwise>
      <div class="ud-empty">
        <i class="ti ti-circle-check"></i>
        <p>All caught up &mdash; no bookings are awaiting payment.</p>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<!-- ── Paid bookings + upcoming pickups ── -->
<div class="ud-card reveal">
  <div class="ud-card__head">
    <h3><i class="ti ti-check"></i> Paid bookings &middot; Pickup &amp; return</h3>
    <span class="chip">${paidCount} settled</span>
  </div>
  <c:choose>
    <c:when test="${not empty paidBookings}">
      <table class="ud-table">
        <thead>
          <tr>
            <th>Booking</th>
            <th>Vehicle</th>
            <th>Pick-up</th>
            <th>Return</th>
            <th>Type</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="b" items="${paidBookings}">
            <tr>
              <td class="ud-mono" style="color:#fff;">${b.bookingId}</td>
              <td style="font-weight:600; color:#fff;">${b.vehicleId}</td>
              <td>
                <span class="ud-pickup">
                  <span class="ud-pickup__loc">
                    <i class="ti ti-map-pin"></i>
                    ${not empty b.pickupLocation ? b.pickupLocation : '—'}
                  </span>
                  <span class="ud-pickup__time">
                    ${b.startDate}
                    <c:if test="${not empty b.pickupTime}"> &middot; ${b.pickupTime}</c:if>
                  </span>
                </span>
              </td>
              <td>
                <span class="ud-pickup">
                  <span class="ud-pickup__loc">
                    <i class="ti ti-flag"></i>
                    ${not empty b.pickupLocation ? b.pickupLocation : '—'}
                  </span>
                  <span class="ud-pickup__time">
                    ${b.endDate}
                    <c:if test="${not empty b.pickupTime}"> &middot; ${b.pickupTime}</c:if>
                  </span>
                </span>
              </td>
              <td>
                <c:choose>
                  <c:when test="${b.bookingType == 'INSTANT'}">
                    <span class="ud-badge ud-badge--btype"><i class="ti ti-bolt"></i> Instant</span>
                  </c:when>
                  <c:otherwise>
                    <span class="ud-badge ud-badge--btype"><i class="ti ti-calendar-event"></i> Advance</span>
                  </c:otherwise>
                </c:choose>
              </td>
              <td>
                <c:choose>
                  <c:when test="${b.status == 'COMPLETED'}"><span class="ud-badge ud-badge--type">Completed</span></c:when>
                  <c:otherwise><span class="ud-badge ud-badge--paid">Paid</span></c:otherwise>
                </c:choose>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </c:when>
    <c:otherwise>
      <div class="ud-empty">
        <i class="ti ti-credit-card-off"></i>
        <p>No paid bookings yet. Pay a pending booking above to see it here with your pickup &amp; return times.</p>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<!-- ── Recommended vehicles ── -->
<div class="ud-card reveal">
  <div class="ud-card__head">
    <h3><i class="ti ti-sparkles"></i> Recommended for you</h3>
    <a href="${pageContext.request.contextPath}/search" class="chip" style="text-decoration:none;">
      Browse fleet <i class="ti ti-arrow-up-right"></i>
    </a>
  </div>
  <c:choose>
    <c:when test="${not empty recommendedVehicles}">
      <div class="ud-reco-grid">
        <c:forEach var="v" items="${recommendedVehicles}">
          <c:choose>
            <c:when test="${v.vehicleType == 'Van'}">
              <c:set var="recoFallback" value="https://images.pexels.com/photos/2920064/pexels-photo-2920064.jpeg?auto=compress&cs=tinysrgb&w=600"/>
            </c:when>
            <c:otherwise>
              <c:set var="recoFallback" value="https://images.pexels.com/photos/170811/pexels-photo-170811.jpeg?auto=compress&cs=tinysrgb&w=600"/>
            </c:otherwise>
          </c:choose>
          <a class="ud-reco" href="${pageContext.request.contextPath}/vehicle?action=view&id=${v.vehicleId}">
            <div class="ud-reco__media">
              <img src="${not empty v.imageUrl ? v.imageUrl : recoFallback}" alt="${v.brand} ${v.model}" loading="lazy" decoding="async"/>
            </div>
            <div class="ud-reco__body">
              <div class="ud-reco__name">${v.brand} ${v.model}</div>
              <div class="ud-reco__sub">${v.vehicleType} &middot; ${v.year}</div>
              <div class="ud-reco__price">
                LKR <fmt:formatNumber value="${v.rentalPricePerDay}" pattern="#,##0.00"/>
                <small>/day</small>
              </div>
            </div>
          </a>
        </c:forEach>
      </div>
    </c:when>
    <c:otherwise>
      <div class="ud-empty">
        <i class="ti ti-car-off"></i>
        <p>No vehicles available right now &mdash; check back soon.</p>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<script>
  (function () {
    if (!window.Chart) return;

    // Spending trend (last 6 months)
    const sLabels = [<c:forEach var="e" items="${spendByMonth}" varStatus="s">'${e.key}'<c:if test="${!s.last}">,</c:if></c:forEach>];
    const sValues = [<c:forEach var="e" items="${spendByMonth}" varStatus="s">${e.value}<c:if test="${!s.last}">,</c:if></c:forEach>];
    const cvSpend = document.getElementById('chUserSpending');
    if (cvSpend) {
      // Flat 10% tint (kit §Focus §7 — no gradient stops on chart fills).
      const grad = 'rgba(111,203,163,0.10)';
      new Chart(cvSpend, {
        type: 'line',
        data: { labels: sLabels, datasets: [{ label: 'LKR', data: sValues,
          borderColor: VRMS_CHART.primary, backgroundColor: grad,
          tension: 0.35, fill: true, pointRadius: 3 }] },
        options: { responsive: true, plugins: { legend: { display: false },
          tooltip: { callbacks: { label: function (c) { return 'LKR ' + c.parsed.y.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }); } } } },
          scales: { y: { grid: { color: VRMS_CHART.gridColor } }, x: { grid: { display: false } } } }
      });
    }

    // Bookings by status — doughnut
    const cvMix = document.getElementById('chUserBookingMix');
    if (cvMix) {
      new Chart(cvMix, {
        type: 'doughnut',
        data: { labels: ['Pending', 'Paid', 'Cancelled'],
          datasets: [{ data: [${pendingCount}, ${paidCount}, ${cancelledCount}],
            backgroundColor: [VRMS_CHART.warn, VRMS_CHART.primary, VRMS_CHART.danger],
            borderColor: 'rgba(0,0,0,0.15)', borderWidth: 2 }] },
        options: { responsive: true, cutout: '62%', plugins: { legend: { position: 'bottom' } } }
      });
    }
  })();
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
