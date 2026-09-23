<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle"   value="Invoice"   scope="request"/>
<c:set var="sectionName" value="Payments"   scope="request"/>
<c:set var="activePage"  value="payment"    scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  /* ════════════════════════════════════════════════════════════
     Invoice — dark glass on screen, light on print
     ════════════════════════════════════════════════════════════ */
  .iv-shell { max-width: 720px; margin: 0 auto; }

  .iv-card {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    overflow: hidden;
  }

  .iv-head {
    display: flex; justify-content: space-between; align-items: flex-start;
    padding: 24px 28px 20px;
    border-bottom: 1px solid var(--glass-border);
  }
  .iv-head__brand { display: flex; align-items: center; gap: 14px; }
  .iv-head__brand img { height: 44px; width: auto; border-radius: 12px; }
  .iv-head__brand-text { line-height: 1.2; }
  .iv-head__brand-text .name {
    font-family: 'Space Grotesk', var(--font-sans);
    font-size: 20px; font-weight: 700;
    letter-spacing: 0.04em;
    color: #fff;
  }
  .iv-head__brand-text .addr {
    font-size: 12px; color: rgba(255,255,255,0.55);
    margin-top: 4px;
  }

  .iv-head__ref { text-align: right; }
  .iv-head__lbl {
    font-size: 10px; letter-spacing: 0.18em; text-transform: uppercase;
    color: rgba(255,255,255,0.5); font-weight: 700;
  }
  .iv-head__no {
    font-family: var(--font-mono);
    font-size: 22px; font-weight: 700;
    color: var(--bx-primary);
    margin-top: 4px;
    letter-spacing: 0.02em;
  }
  .iv-head__date {
    font-size: 12px; color: rgba(255,255,255,0.55);
    margin-top: 4px;
    font-family: var(--font-mono);
  }
  .iv-paid {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 4px 10px;
    margin-top: 10px;
    border-radius: var(--r-pill);
    background: rgba(111,203,163,0.14);
    color: var(--bx-primary);
    border: 1px solid rgba(111,203,163,0.32);
    font-size: 11px; font-weight: 600;
  }
  .iv-paid i { font-size: 12px; }

  /* Billing info section */
  .iv-bill {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 24px;
    padding: 20px 28px;
    border-bottom: 1px solid var(--glass-border);
  }
  .iv-bill__lbl {
    font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase;
    color: rgba(255,255,255,0.5); font-weight: 700;
    margin-bottom: 8px;
  }
  .iv-bill__val { font-weight: 600; color: #fff; }
  .iv-bill__sub { font-size: 13px; color: rgba(255,255,255,0.65); margin-top: 4px; }
  .iv-bill strong { color: #fff; }

  /* Line items table */
  .iv-table { width: 100%; border-collapse: collapse; }
  .iv-table thead th {
    text-align: left;
    padding: 12px 28px;
    font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase;
    color: rgba(255,255,255,0.5); font-weight: 700;
    background: rgba(255,255,255,0.02);
    border-bottom: 1px solid var(--glass-border);
  }
  .iv-table tbody td {
    padding: 14px 28px;
    font-size: 13px;
    color: rgba(255,255,255,0.78);
    border-bottom: 1px solid rgba(255,255,255,0.04);
  }
  .iv-table tbody tr:last-child td { border-bottom: 0; }
  .iv-mono { font-family: var(--font-mono); }
  .iv-discount { color: var(--bx-primary); }

  /* Total bar */
  .iv-total {
    display: flex; justify-content: flex-end; gap: 48px;
    padding: 22px 28px;
    background: rgba(111,203,163,0.06);
    border-top: 1px solid var(--glass-border);
    align-items: baseline;
  }
  .iv-total__lbl {
    font-size: 11px; letter-spacing: 0.18em; text-transform: uppercase;
    color: rgba(255,255,255,0.65); font-weight: 700;
  }
  .iv-total__val {
    font-family: 'Space Grotesk', var(--font-sans);
    font-size: 28px; font-weight: 700;
    color: var(--bx-primary);
    letter-spacing: -0.02em;
    font-family: var(--font-mono);
  }

  .iv-foot {
    padding: 16px 28px;
    border-top: 1px solid var(--glass-border);
    text-align: center;
    font-size: 12px;
    color: rgba(255,255,255,0.5);
  }

  /* ── Print stylesheet: render as a clean light invoice ── */
  @media print {
    body { background: #fff !important; color: #000 !important; }
    .vrms-sidebar, .vrms-topbar, .page-header-row > div:last-child { display: none !important; }
    .vrms-main, .vrms-content { margin: 0 !important; padding: 0 !important; background: #fff !important; }
    .iv-card {
      background: #fff !important;
      border: 1px solid #ddd !important;
      box-shadow: none !important;
      backdrop-filter: none !important;
    }
    .iv-head, .iv-bill, .iv-table thead th, .iv-table tbody td, .iv-total, .iv-foot {
      border-color: #ddd !important;
    }
    .iv-head__brand-text .name { color: #000 !important; }
    .iv-head__brand-text .addr,
    .iv-head__lbl,
    .iv-bill__lbl,
    .iv-bill__sub,
    .iv-table thead th,
    .iv-table tbody td,
    .iv-foot { color: #444 !important; }
    .iv-bill__val, .iv-bill strong { color: #000 !important; }
    .iv-head__no, .iv-total__val { color: #2D5F4C !important; }
    .iv-total { background: #f3f7f5 !important; }
    .iv-paid { background: #f3f7f5 !important; border-color: #c5e2d4 !important; color: #2D5F4C !important; }
  }
</style>

<div class="page-header-row reveal">
  <div class="page-header" style="margin-bottom:0;">
    <span class="eyebrow">Settlement receipt</span>
    <h1>Invoice<em>.</em></h1>
    <p>Payment receipt for your booking. Use the print button for a paper copy.</p>
  </div>
  <div style="display:flex; gap:8px;">
    <button onclick="window.print()" class="btn btn-secondary"><i class="ti ti-printer"></i> Print</button>
    <a href="${pageContext.request.contextPath}/booking?action=list" class="btn btn-primary" data-antigravity>
      <i class="ti ti-list-check"></i> My bookings
    </a>
  </div>
</div>

<div class="iv-shell">
  <div class="iv-card reveal">

    <!-- Header -->
    <div class="iv-head">
      <div class="iv-head__brand">
        <img src="${pageContext.request.contextPath}/images/vrms-logo.png" alt="VRMS"/>
        <div class="iv-head__brand-text">
          <span class="name">VRMS</span>
          <div class="addr">
            Vehicle Rental Management System<br/>
            Colombo, Sri Lanka
          </div>
        </div>
      </div>
      <div class="iv-head__ref">
        <div class="iv-head__lbl">Invoice</div>
        <div class="iv-head__no">#${not empty payment.paymentId ? payment.paymentId : 'INV-0000'}</div>
        <div class="iv-head__date">
          Date: ${not empty payment.date ? payment.date : '—'}
        </div>
        <span class="iv-paid"><i class="ti ti-circle-check"></i> Paid</span>
      </div>
    </div>

    <!-- Billing info -->
    <div class="iv-bill">
      <div>
        <div class="iv-bill__lbl">Billed to</div>
        <div class="iv-bill__val">${not empty payment.customerName ? payment.customerName : '—'}</div>
        <div class="iv-bill__sub">${not empty param.customerEmail ? param.customerEmail : '—'}</div>
        <div class="iv-bill__sub">${not empty param.customerPhone ? param.customerPhone : '—'}</div>
      </div>
      <div>
        <div class="iv-bill__lbl">Booking details</div>
        <div class="iv-bill__sub">Booking ID: <strong class="iv-mono">${not empty bookingId ? bookingId : (not empty param.bookingId ? param.bookingId : '—')}</strong></div>
        <div class="iv-bill__sub" style="margin-top:4px;">Payment Method: <strong>${not empty paymentMethod ? paymentMethod : (not empty param.paymentMethod ? param.paymentMethod : '—')}</strong></div>
      </div>
    </div>

    <!-- Line items -->
    <table class="iv-table">
      <thead>
        <tr>
          <th>Description</th>
          <th style="text-align:center;">Qty / Days</th>
          <th style="text-align:right;">Unit Rate</th>
          <th style="text-align:right;">Amount</th>
        </tr>
      </thead>
      <c:set var="ivVehicleId" value="${not empty vehicleId ? vehicleId : (not empty param.vehicleId ? param.vehicleId : '—')}"/>
      <c:set var="ivStartDate" value="${not empty startDate ? startDate : (not empty param.startDate ? param.startDate : '—')}"/>
      <c:set var="ivEndDate"   value="${not empty endDate ? endDate : (not empty param.endDate ? param.endDate : '—')}"/>
      <c:set var="ivDuration"  value="${not empty duration ? duration : (not empty param.duration ? param.duration : 1)}"/>
      <c:set var="ivAmount"    value="${not empty payment.amount ? payment.amount : 0}"/>
      <c:set var="ivUnitRate"  value="${ivDuration > 0 ? ivAmount / ivDuration : ivAmount}"/>

      <tbody>
        <tr>
          <td>
            <div style="font-weight:600; color:#fff;">Vehicle Rental &mdash; ${ivVehicleId}</div>
            <div style="font-size:11px; color:rgba(255,255,255,0.5); margin-top:2px;">
              ${ivStartDate} to ${ivEndDate}
            </div>
          </td>
          <td style="text-align:center;">${ivDuration}</td>
          <td style="text-align:right;" class="iv-mono">LKR <fmt:formatNumber value="${ivUnitRate}" pattern="#,##0.00"/></td>
          <td style="text-align:right;" class="iv-mono">LKR <fmt:formatNumber value="${ivAmount}" pattern="#,##0.00"/></td>
        </tr>
        <c:if test="${not empty param.discount && param.discount != '0.00'}">
          <tr>
            <td colspan="3" style="text-align:right;" class="iv-discount">Promo Discount</td>
            <td style="text-align:right;" class="iv-mono iv-discount">- LKR <fmt:formatNumber value="${param.discount}" pattern="#,##0.00"/></td>
          </tr>
        </c:if>
      </tbody>
    </table>

    <!-- Total -->
    <div class="iv-total">
      <span class="iv-total__lbl">Total Paid</span>
      <span class="iv-total__val">LKR <fmt:formatNumber value="${ivAmount}" pattern="#,##0.00"/></span>
    </div>

    <!-- Footer -->
    <div class="iv-foot">
      Thank you for choosing VRMS. This is a computer-generated invoice.
    </div>
  </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
