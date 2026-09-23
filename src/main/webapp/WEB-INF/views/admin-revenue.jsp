<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle"   value="Revenue Report" scope="request"/>
<c:set var="sectionName" value="Admin"           scope="request"/>
<c:set var="activePage"  value="revenue"         scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  /* ════════════════════════════════════════════════════════════
     Revenue dashboard — glass KPIs, seafoam bars, dark tables
     ════════════════════════════════════════════════════════════ */
  .rv-kpis {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 18px;
    margin-bottom: 24px;
  }
  @media (max-width: 1080px) { .rv-kpis { grid-template-columns: repeat(2, 1fr); } }
  @media (max-width: 540px)  { .rv-kpis { grid-template-columns: 1fr; } }

  .rv-kpi {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    padding: 22px 24px;
    transition: transform var(--t-base), background var(--t-base), border-color var(--t-base);
  }
  .rv-kpi:hover {
    transform: translateY(-3px);
    background: var(--glass-bg-strong);
    border-color: rgba(255,255,255,0.18);
  }
  .rv-kpi__head {
    display: flex; align-items: center; gap: 10px;
    margin-bottom: 14px;
  }
  .rv-kpi__icon {
    width: 36px; height: 36px;
    border-radius: 10px;
    /* Kit §Focus §8 — flat tint, no decorative gradients on data surfaces. */
    background: rgba(111,203,163,0.10);
    border: 1px solid rgba(111,203,163,0.24);
    color: var(--bx-primary);
    display: inline-flex; align-items: center; justify-content: center;
    font-size: 18px;
  }
  .rv-kpi--info  .rv-kpi__icon {
    background: rgba(125,211,252,0.10);
    border-color: rgba(125,211,252,0.24);
    color: var(--bx-info);
  }
  .rv-kpi--warn  .rv-kpi__icon {
    background: rgba(251,191,36,0.10);
    border-color: rgba(251,191,36,0.26);
    color: var(--bx-warning);
  }
  .rv-kpi__lbl {
    font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase;
    color: rgba(255,255,255,0.55); font-weight: 600;
  }
  .rv-kpi__val {
    font-family: 'Space Grotesk', var(--font-sans);
    font-size: 28px; font-weight: 700;
    letter-spacing: -0.025em;
    color: #fff;
    line-height: 1.05;
    word-break: break-all;
  }
  .rv-kpi__val sup {
    font-size: 12px;
    color: var(--bx-primary);
    font-weight: 600;
    margin-right: 4px;
    vertical-align: top;
  }
  .rv-kpi__hint {
    margin-top: 6px;
    font-family: var(--font-mono);
    font-size: 10px;
    color: rgba(255,255,255,0.45);
    letter-spacing: 0.06em;
  }

  /* Two-up section: monthly bar table + rentals table */
  .rv-grid {
    display: grid;
    grid-template-columns: 1.4fr 1fr;
    gap: 20px;
  }
  @media (max-width: 980px) { .rv-grid { grid-template-columns: 1fr; } }

  .rv-card {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    overflow: hidden;
  }
  .rv-card__head {
    display: flex; align-items: center; justify-content: space-between;
    padding: 18px 22px;
    border-bottom: 1px solid var(--glass-border);
  }
  .rv-card__head h3 {
    font-family: var(--font-sans);
    font-size: 14px; font-weight: 600;
    color: #fff;
    display: inline-flex; align-items: center; gap: 8px;
  }
  .rv-card__head h3 i { color: var(--bx-primary); font-size: 16px; }
  .rv-card__src {
    font-family: var(--font-mono);
    font-size: 10px;
    color: rgba(255,255,255,0.5);
    letter-spacing: 0.04em;
  }

  .rv-table { width: 100%; border-collapse: collapse; }
  .rv-table thead th {
    text-align: left;
    padding: 12px 20px;
    font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase;
    color: rgba(255,255,255,0.5); font-weight: 700;
    border-bottom: 1px solid var(--glass-border);
  }
  .rv-table tbody td {
    padding: 12px 20px;
    font-size: 13px;
    color: rgba(255,255,255,0.78);
    border-bottom: 1px solid rgba(255,255,255,0.04);
  }
  .rv-table tbody tr:last-child td { border-bottom: 0; }
  .rv-table tbody tr:hover { background: rgba(255,255,255,0.03); }
  .rv-mono { font-family: var(--font-mono); }

  /* Seafoam bar */
  .rv-bar {
    height: 8px;
    background: rgba(255,255,255,0.06);
    border-radius: 999px;
    overflow: hidden;
    position: relative;
  }
  .rv-bar__fill {
    height: 100%;
    background: linear-gradient(90deg, var(--bx-primary) 0%, var(--bx-primary-deep) 100%);
    border-radius: 999px;
    box-shadow: 0 0 12px rgba(111,203,163,0.4);
  }

  /* Kit §Trust §6 — empty state must offer a next action, not just a message. */
  .rv-empty {
    text-align: center;
    padding: 56px 24px;
    color: rgba(255,255,255,0.55);
  }
  .rv-empty i { font-size: 32px; color: var(--bx-primary); display: block; margin-bottom: 10px; }
  .rv-empty h4 { color: #fff; font-size: 15px; margin: 0 0 6px; }
  .rv-empty p  { margin: 0 0 16px; font-size: 13px; }

  /* ── 7-slice palette for the Revenue-by-type donut. Order matches the LinkedHashMap
       in AdminRevenueController.revenueByType() and the typeColors array in JS. ── */
  :root {
    --rv-c0: #6FCBA3;  /* Sedan     */
    --rv-c1: #7DD3FC;  /* Hybrid    */
    --rv-c2: #FBBF24;  /* SUV       */
    --rv-c3: #C084FC;  /* Hatchback */
    --rv-c4: #34D399;  /* Electric  */
    --rv-c5: #F472B6;  /* Van       */
    --rv-c6: #FB923C;  /* unused legacy category */
  }
  .rv-dot {
    display: inline-block;
    width: 10px; height: 10px;
    border-radius: 50%;
    margin-right: 8px;
    vertical-align: middle;
    box-shadow: 0 0 0 1px rgba(0,0,0,0.25);
  }
</style>

<div class="page-header-row reveal">
  <div class="page-header" style="margin-bottom:0;">
    <span class="eyebrow">Admin</span>
    <h1>Revenue &amp; <em>analytics.</em></h1>
    <p>
      Aggregated booking and payment metrics across the fleet

    </p>
  </div>
  <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-secondary">
    <i class="ti ti-arrow-left"></i> Back to Dashboard
  </a>
</div>

<!-- ── Headline KPIs ── -->
<div class="rv-kpis reveal">

  <div class="rv-kpi" data-antigravity>
    <div class="rv-kpi__head">
      <span class="rv-kpi__icon"><i class="ti ti-cash"></i></span>
      <span class="rv-kpi__lbl">Total revenue</span>
    </div>
    <div class="rv-kpi__val">
      <sup>LKR</sup><fmt:formatNumber value="${totalRevenue}" pattern="#,##0.00"/>
    </div>
    <div class="rv-kpi__hint">Lifetime, all approved payments</div>
  </div>

  <div class="rv-kpi rv-kpi--info" data-antigravity>
    <div class="rv-kpi__head">
      <span class="rv-kpi__icon"><i class="ti ti-calendar-check"></i></span>
      <span class="rv-kpi__lbl">Total bookings</span>
    </div>
    <div class="rv-kpi__val">${totalBookings}</div>
    <div class="rv-kpi__hint">Active + completed + cancelled</div>
  </div>

  <div class="rv-kpi rv-kpi--warn" data-antigravity>
    <div class="rv-kpi__head">
      <span class="rv-kpi__icon"><i class="ti ti-clock"></i></span>
      <span class="rv-kpi__lbl">Avg duration</span>
    </div>
    <div class="rv-kpi__val">
      <fmt:formatNumber value="${avgDuration}" maxFractionDigits="1" minFractionDigits="1"/>
      <span style="font-size:14px; color:rgba(255,255,255,0.55); font-weight:500;">&nbsp;days</span>
    </div>
    <div class="rv-kpi__hint">Per non-cancelled rental</div>
  </div>

  <a class="rv-kpi" data-antigravity
     href="${pageContext.request.contextPath}/admin/top-vehicles"
     style="text-decoration:none; color:inherit; display:block;">
    <div class="rv-kpi__head">
      <span class="rv-kpi__icon"><i class="ti ti-trophy"></i></span>
      <span class="rv-kpi__lbl">Top vehicle</span>
    </div>
    <div class="rv-kpi__val" style="font-size:22px;">${mostRentedId}</div>
    <div class="rv-kpi__hint">View full leaderboard &rarr;</div>
  </a>

</div>

<!-- ── Monthly revenue line chart (full width) ── -->
<div class="rv-card reveal" style="margin-bottom:18px;">
  <div class="rv-card__head">
    <h3><i class="ti ti-chart-line"></i> Monthly revenue</h3>
    <span class="rv-card__src">payments.txt &middot; last 4 months</span>
  </div>
  <c:choose>
    <c:when test="${not empty monthly}">
      <div style="padding:18px 22px;"><canvas id="chRevenue" height="110"></canvas></div>
    </c:when>
    <c:otherwise>
      <div class="rv-empty">
        <i class="ti ti-chart-bar-off"></i>
        <h4>No payments recorded yet</h4>
        <p>Confirmed bookings and processed payments will surface here. Start by opening the bookings ledger to see what's pending.</p>
        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/admin/bookings">
          <i class="ti ti-calendar-event"></i> Open reservations
        </a>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<!-- ── Two-up: revenue by type (doughnut) + top 5 (horizontal bar) ── -->
<div class="rv-grid">

  <div class="rv-card reveal">
    <div class="rv-card__head">
      <h3><i class="ti ti-chart-donut"></i> Revenue by vehicle type</h3>
      <span class="rv-card__src">7 categories &middot; payment &rarr; booking &rarr; vehicle</span>
    </div>
    <div style="padding:18px 22px;"><canvas id="chTypeMix" height="220"></canvas></div>
    <c:if test="${not empty revenueByType}">
      <c:set var="typeTotal" value="0"/>
      <c:forEach var="e" items="${revenueByType}">
        <c:set var="typeTotal" value="${typeTotal + e.value}"/>
      </c:forEach>
      <table class="rv-table" style="border-top:1px solid var(--glass-border);">
        <thead>
          <tr>
            <th>Category</th>
            <th style="text-align:right;">Revenue (LKR)</th>
            <th style="text-align:right; width:90px;">Share</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="e" items="${revenueByType}" varStatus="s">
            <tr>
              <td>
                <span class="rv-dot" style="background: var(--rv-c${s.index});"></span>
                ${e.key}
              </td>
              <td class="rv-mono" style="text-align:right; color:#fff;">
                <fmt:formatNumber value="${e.value}" pattern="#,##0.00"/>
              </td>
              <td class="rv-mono" style="text-align:right; color:rgba(255,255,255,0.55);">
                <c:choose>
                  <c:when test="${typeTotal > 0}">
                    <fmt:formatNumber value="${(e.value / typeTotal) * 100}" pattern="#0.0"/>%
                  </c:when>
                  <c:otherwise>&mdash;</c:otherwise>
                </c:choose>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </c:if>
  </div>

  <div class="rv-card reveal">
    <div class="rv-card__head">
      <h3><i class="ti ti-chart-bar"></i> Top 5 most-rented</h3>
      <a href="${pageContext.request.contextPath}/admin/top-vehicles" class="rv-card__src" style="text-decoration:none;">
        Full leaderboard &rarr;
      </a>
    </div>
    <div style="padding:18px 22px;"><canvas id="chTopVehicles" height="220"></canvas></div>
  </div>

</div>

<!-- ── Monthly revenue table (data view fallback) ── -->
<div class="rv-card reveal" style="margin-top:18px;">
  <div class="rv-card__head">
    <h3><i class="ti ti-table"></i> Monthly revenue (table view)</h3>
    <span class="rv-card__src">data/payments.txt</span>
  </div>
  <c:if test="${not empty monthly}">
    <c:set var="maxVal" value="0"/>
    <c:forEach var="e" items="${monthly}">
      <c:if test="${e.value > maxVal}"><c:set var="maxVal" value="${e.value}"/></c:if>
    </c:forEach>
    <table class="rv-table">
      <thead>
        <tr>
          <th>Month</th>
          <th style="text-align:right;">Revenue (LKR)</th>
          <th style="width:42%;">Trend</th>
        </tr>
      </thead>
      <tbody>
        <c:forEach var="e" items="${monthly}">
          <tr>
            <td class="rv-mono" style="color:#fff;">${e.key}</td>
            <td class="rv-mono" style="text-align:right; color:var(--bx-primary); font-weight:600;">
              <fmt:formatNumber value="${e.value}" pattern="#,##0.00"/>
            </td>
            <td>
              <div class="rv-bar">
                <div class="rv-bar__fill" style="width:${maxVal > 0 ? (e.value / maxVal) * 100 : 0}%;"></div>
              </div>
            </td>
          </tr>
        </c:forEach>
      </tbody>
    </table>
  </c:if>
</div>

<script>
  (function () {
    if (!window.Chart) return;

    // ── Monthly revenue — line with seafoam area fill ──
    const monthlyLabels = [<c:forEach var="e" items="${monthly}" varStatus="s">'${e.key}'<c:if test="${!s.last}">,</c:if></c:forEach>];
    const monthlyValues = [<c:forEach var="e" items="${monthly}" varStatus="s">${e.value}<c:if test="${!s.last}">,</c:if></c:forEach>];
    const cvRev = document.getElementById('chRevenue');
    if (cvRev) {
      const ctx = cvRev.getContext('2d');
      // Flat 10% tint (kit §Focus §7 — no gradient stops on chart fills).
      const grad = 'rgba(111,203,163,0.10)';
      new Chart(cvRev, {
        type: 'line',
        data: { labels: monthlyLabels, datasets: [{
          label: 'LKR', data: monthlyValues,
          borderColor: VRMS_CHART.primary, backgroundColor: grad,
          tension: 0.35, fill: true, pointRadius: 3, pointHoverRadius: 5
        }]},
        options: { responsive: true, plugins: { legend: { display: false },
          tooltip: { callbacks: { label: function (c) { return 'LKR ' + c.parsed.y.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }); } } } },
          scales: { y: { grid: { color: VRMS_CHART.gridColor }}, x: { grid: { display: false } } } }
      });
    }

    // Revenue by category — cars and vans only
    // Palette mirrors --rv-c0..6 declared in CSS so the data table dots line up exactly.
    const typeColors = [
      '#6FCBA3', // Sedan     — seafoam (primary)
      '#7DD3FC', // Hybrid    — sky
      '#FBBF24', // SUV       — amber
      '#C084FC', // Hatchback — violet
      '#34D399', // Electric  — emerald
      '#F472B6', // Van       — pink
    ];
    new Chart(document.getElementById('chTypeMix'), {
      type: 'doughnut',
      data: {
        labels: [<c:forEach var="e" items="${revenueByType}" varStatus="s">'${e.key}'<c:if test="${!s.last}">,</c:if></c:forEach>],
        datasets: [{
          data: [<c:forEach var="e" items="${revenueByType}" varStatus="s">${e.value}<c:if test="${!s.last}">,</c:if></c:forEach>],
          backgroundColor: typeColors,
          borderColor: 'rgba(5,9,18,0.85)', borderWidth: 2
        }]
      },
      options: {
        responsive: true, cutout: '62%',
        plugins: {
          legend: { position: 'bottom', labels: { boxWidth: 12, boxHeight: 12, padding: 12 } },
          tooltip: { callbacks: { label: function (c) {
            const v = c.parsed || 0;
            return c.label + ': LKR ' + v.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
          } } }
        }
      }
    });

    // ── Top 5 most-rented — horizontal bar ──
    new Chart(document.getElementById('chTopVehicles'), {
      type: 'bar',
      data: {
        labels: [<c:forEach var="e" items="${topN}" varStatus="s">'${e.key}'<c:if test="${!s.last}">,</c:if></c:forEach>],
        datasets: [{
          label: 'Rentals',
          data: [<c:forEach var="e" items="${topN}" varStatus="s">${e.value}<c:if test="${!s.last}">,</c:if></c:forEach>],
          backgroundColor: VRMS_CHART.primarySoft,
          borderColor: VRMS_CHART.primary, borderWidth: 1
        }]
      },
      options: { indexAxis: 'y', responsive: true, plugins: { legend: { display: false } },
        scales: { x: { grid: { color: VRMS_CHART.gridColor }, beginAtZero: true, ticks: { precision: 0 } },
                  y: { grid: { display: false } } } }
    });
  })();
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
