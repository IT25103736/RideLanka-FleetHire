<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"  %>
<c:set var="pageTitle"   value="Reservation Confirmed" scope="request"/>
<c:set var="sectionName" value="Reservations"           scope="request"/>
<c:set var="activePage"  value="booking"                scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  /* ════════════════════════════════════════════════════════════
     Confirmation — Step 3 of 3, dark + glass + seafoam
     ════════════════════════════════════════════════════════════ */
  .conf-shell { max-width: 820px; margin: 0 auto; }

  /* Step indicator at top */
  .conf-steps {
    display: grid;
    grid-template-columns: 1fr 24px 1fr 24px 1fr;
    align-items: center;
    gap: 8px;
    margin: 0 0 32px;
    padding: 18px 24px;
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
  }
  .conf-step { display: flex; align-items: center; gap: 12px; min-width: 0; }
  .conf-step__num {
    flex-shrink: 0;
    width: 32px; height: 32px;
    border-radius: 50%;
    background: rgba(111,203,163,0.18);
    border: 1px solid rgba(111,203,163,0.32);
    color: var(--bx-primary);
    font-family: var(--font-mono);
    font-size: 13px; font-weight: 600;
    display: inline-flex; align-items: center; justify-content: center;
  }
  .conf-step__text { min-width: 0; display: flex; flex-direction: column; gap: 2px; }
  .conf-step__lbl {
    font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase;
    color: rgba(255,255,255,0.5); font-weight: 600;
  }
  .conf-step__name { font-size: 14px; font-weight: 600; color: rgba(255,255,255,0.78); }
  .conf-step.is-active .conf-step__num {
    background: var(--bx-primary);
    color: var(--bx-night);
    border-color: var(--bx-primary);
    box-shadow: 0 0 0 4px rgba(111,203,163,0.18);
  }
  .conf-step.is-active .conf-step__name { color: #fff; }
  .conf-step__sep { height: 1px; background: rgba(111,203,163,0.32); }
  @media (max-width: 720px) {
    .conf-steps { grid-template-columns: 1fr; gap: 12px; }
    .conf-step__sep { display: none; }
  }

  /* Success hero */
  .conf-hero { text-align: center; padding: 18px 16px 36px; }
  .conf-ring {
    width: 92px; height: 92px;
    border-radius: 50%;
    background: linear-gradient(135deg, rgba(111,203,163,0.24) 0%, rgba(111,203,163,0.06) 100%);
    border: 1px solid rgba(111,203,163,0.32);
    color: var(--bx-primary);
    display: inline-flex; align-items: center; justify-content: center;
    font-size: 42px;
    margin-bottom: 22px;
    box-shadow: inset 0 1px 0 rgba(255,255,255,0.12), 0 12px 36px -16px rgba(111,203,163,0.6);
  }
  .conf-eyebrow {
    display: inline-flex;
    padding: 5px 12px;
    border-radius: 999px;
    background: rgba(111,203,163,0.10);
    border: 1px solid rgba(111,203,163,0.24);
    font-size: 10px; letter-spacing: 0.22em; text-transform: uppercase;
    color: var(--bx-primary);
    font-weight: 700;
    margin-bottom: 14px;
  }
  .conf-title {
    font-family: 'Manrope', var(--font-sans);
    font-size: clamp(38px, 4.4vw, 56px);
    font-weight: 600;
    letter-spacing: -0.035em;
    line-height: 1.05;
    color: #fff;
  }
  .conf-title em { font-style: normal; color: var(--bx-primary); }
  .conf-sub {
    font-size: 15px;
    color: rgba(255,255,255,0.65);
    margin-top: 14px;
    max-width: 52ch;
    margin-left: auto; margin-right: auto;
    line-height: 1.7;
  }

  /* Reference strip */
  .conf-card {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    overflow: hidden;
  }
  .ref-strip {
    background:
      radial-gradient(60% 90% at 100% 0%, rgba(111,203,163,0.22) 0%, transparent 65%),
      linear-gradient(135deg, rgba(255,255,255,0.04) 0%, rgba(0,0,0,0.2) 100%);
    color: #fff;
    padding: 24px 28px;
    display: flex; justify-content: space-between; align-items: center;
    gap: 16px;
    border-bottom: 1px solid var(--glass-border);
  }
  .ref-strip .lbl {
    font-size: 10px; letter-spacing: 0.22em; text-transform: uppercase;
    color: rgba(255,255,255,0.5); font-weight: 600;
  }
  .ref-strip .ref {
    font-family: var(--font-mono);
    font-size: 22px;
    color: #fff;
    margin-top: 6px;
    letter-spacing: 0.04em;
  }
  .ref-strip__type {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 6px 12px;
    border-radius: var(--r-pill);
    font-size: 11px; font-weight: 600;
    letter-spacing: 0.08em;
    border: 1px solid;
  }
  .ref-strip__type--instant {
    background: rgba(111,203,163,0.16);
    color: var(--bx-primary);
    border-color: rgba(111,203,163,0.32);
  }
  .ref-strip__type--advance {
    background: rgba(251,191,36,0.14);
    color: var(--bx-warning);
    border-color: rgba(251,191,36,0.28);
  }
  @media (max-width: 600px) {
    .ref-strip { flex-direction: column; align-items: flex-start; }
  }

  /* Detail grid */
  .conf-body { padding: 28px; }
  .detail-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 22px;
    margin-bottom: 22px;
  }
  @media (max-width: 600px) { .detail-grid { grid-template-columns: 1fr; } }
  .detail-block .lbl {
    font-size: 10px; letter-spacing: 0.18em; text-transform: uppercase;
    color: rgba(255,255,255,0.5); font-weight: 700;
    margin-bottom: 10px;
  }
  .detail-row {
    display: flex; gap: 12px; align-items: flex-start;
    padding: 10px 0;
    border-bottom: 1px solid var(--glass-border);
  }
  .detail-row:last-child { border-bottom: 0; }
  .detail-row i {
    width: 32px; height: 32px;
    border-radius: 8px;
    background: rgba(111,203,163,0.12);
    color: var(--bx-primary);
    border: 1px solid rgba(111,203,163,0.22);
    display: inline-flex; align-items: center; justify-content: center;
    font-size: 14px; flex-shrink: 0;
  }
  .detail-row .l { font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase; color: rgba(255,255,255,0.5); font-weight: 600; }
  .detail-row .v { font-weight: 500; color: #fff; font-size: 14px; margin-top: 3px; }

  /* Breakdown strip */
  .break-strip {
    background: rgba(255,255,255,0.03);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-md);
    padding: 20px 22px;
  }
  .break-strip h4 {
    font-size: 11px; letter-spacing: 0.14em; text-transform: uppercase;
    color: rgba(255,255,255,0.55); font-weight: 700;
    margin-bottom: 14px;
    display: inline-flex; align-items: center; gap: 8px;
  }
  .break-strip h4 i { color: var(--bx-primary); font-size: 14px; }
  .break-strip .row {
    display: flex; justify-content: space-between; align-items: center;
    padding: 6px 0;
    font-size: 13px;
  }
  .break-strip .row .lbl { color: rgba(255,255,255,0.72); }
  .break-strip .row .val { color: #fff; font-weight: 500; }
  .break-strip .row.is-info {
    font-size: 11px;
    padding-top: 0; padding-bottom: 8px;
  }
  .break-strip .row.is-info .lbl,
  .break-strip .row.is-info .val { color: rgba(255,255,255,0.42); font-family: var(--font-mono); }
  .break-strip .row.is-surcharge .lbl,
  .break-strip .row.is-surcharge .val { color: var(--bx-warning); }
  .break-strip .total-row {
    border-top: 1px solid var(--glass-border);
    padding-top: 16px;
    margin-top: 10px;
    align-items: flex-end;
  }
  .break-strip .total-row .lbl {
    font-size: 11px; letter-spacing: 0.18em; text-transform: uppercase;
    color: rgba(255,255,255,0.62); font-weight: 600;
  }
  .break-strip .total-row .val {
    font-family: var(--font-sans);
    font-size: 32px; font-weight: 700;
    letter-spacing: -0.022em;
    line-height: 1.05;
    color: var(--bx-primary);
  }
  .break-strip .total-row .val sup {
    font-size: 13px; color: rgba(255,255,255,0.55);
    margin-right: 4px; font-weight: 500; vertical-align: top;
  }
  .break-deposit {
    margin-top: 8px;
    font-family: var(--font-mono);
    font-size: 11px;
    color: rgba(255,255,255,0.45);
    text-align: right;
  }

  .conf-note {
    margin-top: 22px;
    padding: 14px 18px;
    background: rgba(125,211,252,0.08);
    border: 1px solid rgba(125,211,252,0.22);
    border-radius: var(--r-md);
    font-size: 13px;
    color: rgba(255,255,255,0.78);
    display: flex; gap: 12px; align-items: flex-start;
  }
  .conf-note i { color: var(--bx-info); font-size: 18px; flex-shrink: 0; margin-top: 1px; }
  .conf-note strong { color: #fff; }
</style>

<div class="conf-shell">

  <!-- Step indicator -->
  <div class="conf-steps reveal">
    <div class="conf-step"><span class="conf-step__num">1</span><span class="conf-step__text"><span class="conf-step__lbl">Step 1</span><span class="conf-step__name">Trip details</span></span></div>
    <div class="conf-step__sep"></div>
    <div class="conf-step"><span class="conf-step__num">2</span><span class="conf-step__text"><span class="conf-step__lbl">Step 2</span><span class="conf-step__name">Reviewed</span></span></div>
    <div class="conf-step__sep"></div>
    <div class="conf-step is-active"><span class="conf-step__num"><i class="ti ti-check" style="font-size:14px;"></i></span><span class="conf-step__text"><span class="conf-step__lbl">Step 3 of 3</span><span class="conf-step__name">Confirmed</span></span></div>
  </div>

  <!-- Hero -->
  <div class="conf-hero reveal">
    <div class="conf-ring"><i class="ti ti-circle-check"></i></div>
    <span class="conf-eyebrow">Reservation logged</span>
    <h1 class="conf-title">Confirmed.<br/><em>Drive safely.</em></h1>
    <p class="conf-sub">
      Your reservation is on the ledger. A confirmation has been emailed to the driver
      and our host will be in touch shortly with pickup details.
    </p>
  </div>

  <!-- Reservation card -->
  <div class="conf-card reveal">

    <div class="ref-strip">
      <div>
        <div class="lbl">Booking reference</div>
        <div class="ref">${not empty booking.bookingId ? booking.bookingId : 'B-0000'}</div>
      </div>
      <c:choose>
        <c:when test="${booking.bookingType == 'INSTANT'}">
          <span class="ref-strip__type ref-strip__type--instant">
            <i class="ti ti-bolt"></i> Instant
          </span>
        </c:when>
        <c:otherwise>
          <span class="ref-strip__type ref-strip__type--advance">
            <i class="ti ti-calendar-event"></i> Advance
          </span>
        </c:otherwise>
      </c:choose>
    </div>

    <div class="conf-body">

      <div class="detail-grid">
        <div class="detail-block">
          <div class="lbl">Driver</div>
          <div class="detail-row">
            <i class="ti ti-user"></i>
            <div>
              <div class="l">Name</div>
              <div class="v">${not empty customerName ? customerName : '—'}</div>
            </div>
          </div>
          <div class="detail-row">
            <i class="ti ti-phone"></i>
            <div>
              <div class="l">Contact</div>
              <div class="v">${not empty param.phone ? param.phone : '—'}</div>
            </div>
          </div>
          <c:if test="${withDriver}">
            <div class="detail-row">
              <i class="ti ti-steering-wheel"></i>
              <div>
                <div class="l">Chauffeur</div>
                <div class="v">Included &mdash; English-speaking</div>
              </div>
            </div>
          </c:if>
        </div>

        <div class="detail-block">
          <div class="lbl">Reservation</div>
          <div class="detail-row">
            <i class="ti ti-car"></i>
            <div>
              <div class="l">Vehicle</div>
              <div class="v">${not empty booking.vehicleId ? booking.vehicleId : '—'}</div>
            </div>
          </div>
          <div class="detail-row">
            <i class="ti ti-calendar"></i>
            <div>
              <div class="l">Start date</div>
              <div class="v">${not empty booking.startDate ? booking.startDate : '—'}</div>
            </div>
          </div>
          <div class="detail-row">
            <i class="ti ti-clock"></i>
            <div>
              <div class="l">Duration</div>
              <div class="v">${not empty duration ? duration : '—'} day(s)</div>
            </div>
          </div>
          <div class="detail-row">
            <i class="ti ti-map-pin"></i>
            <div>
              <div class="l">Pick-up</div>
              <div class="v">
                ${not empty booking.pickupLocation ? booking.pickupLocation : '—'}
                <c:if test="${not empty booking.pickupTime}">
                  &middot; <span style="color:var(--bx-primary);">${booking.pickupTime}</span>
                </c:if>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Full price breakdown -->
      <div class="break-strip">
        <h4><i class="ti ti-receipt"></i> Price breakdown</h4>
        <div class="row">
          <span class="lbl">Base rental</span>
          <span class="val">LKR <fmt:formatNumber value="${dailyRate * duration}" pattern="#,##0.00"/></span>
        </div>
        <div class="row is-info">
          <span class="lbl">&nbsp;LKR <fmt:formatNumber value="${dailyRate}" pattern="#,##0.00"/> &times; ${duration} day(s)</span>
          <span class="val"></span>
        </div>
        <c:if test="${appliedSurcharge > 0}">
          <div class="row is-surcharge">
            <span class="lbl">
              <c:choose>
                <c:when test="${appliedSurcharge == 0.25}">Same-day surcharge (+25%)</c:when>
                <c:when test="${appliedSurcharge == 0.10}">Short-notice surcharge (+10%)</c:when>
                <c:otherwise>Instant surcharge (+5%)</c:otherwise>
              </c:choose>
            </span>
            <span class="val">LKR <fmt:formatNumber value="${baseCost - (dailyRate * duration)}" pattern="#,##0.00"/></span>
          </div>
        </c:if>
        <c:if test="${withDriver and driverFee > 0}">
          <div class="row">
            <span class="lbl">Professional chauffeur</span>
            <span class="val">LKR <fmt:formatNumber value="${driverFee}" pattern="#,##0.00"/></span>
          </div>
        </c:if>
        <div class="row">
          <span class="lbl">Insurance</span>
          <span class="val">LKR <fmt:formatNumber value="${insurance}" pattern="#,##0.00"/></span>
        </div>
        <div class="row">
          <span class="lbl">Delivery (Kandy &amp; Colombo)</span>
          <span class="val">LKR <fmt:formatNumber value="${delivery}" pattern="#,##0.00"/></span>
        </div>
        <div class="row total-row">
          <span class="lbl">Total due</span>
          <span class="val"><sup>LKR</sup><fmt:formatNumber value="${totalCost}" pattern="#,##0.00"/></span>
        </div>
        <div class="break-deposit">
          + LKR <fmt:formatNumber value="${deposit}" pattern="#,##0.00"/> refundable deposit (held at pickup)
        </div>
      </div>

      <c:if test="${not empty param.notes}">
        <div class="conf-note" style="margin-top:18px;">
          <i class="ti ti-notes"></i>
          <div><strong>Notes from the driver.</strong><br/>${param.notes}</div>
        </div>
      </c:if>

      <div class="conf-note">
        <i class="ti ti-info-circle"></i>
        <div>
          <strong>What happens next?</strong><br/>
          Your reservation is stored in RideLanka FleetHire and is visible under My Reservations.
          Complete payment through the payment page when required; booking and payment status are read from MSSQL.
        </div>
      </div>

      <c:if test="${not empty whatsappUrl}">
        <div class="wa-card">
          <span class="wa-card__ico"><i class="ti ti-brand-whatsapp"></i></span>
          <div class="wa-card__body">
            <div class="wa-card__title">Optional WhatsApp contact</div>
            <div class="wa-card__sub">
              Use the button to open WhatsApp with a pre-filled message about booking
              <strong>${booking.bookingId}</strong>. Sending the message is optional and happens only after you confirm it in WhatsApp.
            </div>
          </div>
          <a href="${whatsappUrl}"
             target="_blank" rel="noopener" class="wa-card__cta">
            <i class="ti ti-brand-whatsapp"></i> Message us
          </a>
        </div>
      </c:if>

    </div>
  </div>

  <div style="display:flex; gap:10px; justify-content:center; margin-top:28px; flex-wrap:wrap;">
    <a href="${pageContext.request.contextPath}/payment/checkout?bookingId=${booking.bookingId}"
       class="btn btn-primary btn-lg" data-antigravity>
      Pay now
      <span class="ico-pill"><i class="ti ti-arrow-up-right"></i></span>
    </a>
    <a href="${pageContext.request.contextPath}/booking?action=list" class="btn btn-secondary">
      My reservations
      <span class="ico-pill"><i class="ti ti-arrow-right"></i></span>
    </a>
    <a href="${pageContext.request.contextPath}/booking?action=form" class="btn btn-ghost">
      <i class="ti ti-plus"></i> New booking
    </a>
    <button onclick="window.print()" class="btn btn-ghost">
      <i class="ti ti-printer"></i> Print
    </button>
  </div>

</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
