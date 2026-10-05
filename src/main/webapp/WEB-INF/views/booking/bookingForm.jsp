<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"  %>
<c:set var="pageTitle"   value="Reserve a Vehicle" scope="request"/>
<c:set var="sectionName" value="Reservations"       scope="request"/>
<c:set var="activePage"  value="booking"            scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  /* ════════════════════════════════════════════════════════════
     Booking form — Liquid Glass on dark, seafoam accents
     ════════════════════════════════════════════════════════════ */

  /* ── 3-step progress bar ── */
  .bk-steps {
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
  .bk-step {
    display: flex; align-items: center; gap: 12px;
    min-width: 0;
  }
  .bk-step__num {
    flex-shrink: 0;
    width: 32px; height: 32px;
    border-radius: 50%;
    background: rgba(255,255,255,0.06);
    border: 1px solid var(--glass-border);
    color: rgba(255,255,255,0.55);
    font-family: var(--font-mono);
    font-size: 13px; font-weight: 600;
    display: inline-flex; align-items: center; justify-content: center;
    transition: background var(--t-fast), color var(--t-fast), border-color var(--t-fast);
  }
  .bk-step__text {
    min-width: 0;
    display: flex; flex-direction: column; gap: 2px;
  }
  .bk-step__lbl {
    font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase;
    color: rgba(255,255,255,0.5); font-weight: 600;
  }
  .bk-step__name {
    font-size: 14px; font-weight: 600;
    color: rgba(255,255,255,0.65);
    letter-spacing: -0.005em;
  }
  .bk-step.is-active .bk-step__num {
    background: var(--bx-primary);
    color: var(--bx-night);
    border-color: var(--bx-primary);
    box-shadow: 0 0 0 4px rgba(111,203,163,0.18);
  }
  .bk-step.is-active .bk-step__name { color: #fff; }
  .bk-step.is-done .bk-step__num {
    background: rgba(111,203,163,0.18);
    color: var(--bx-primary);
    border-color: rgba(111,203,163,0.32);
  }
  .bk-step__sep {
    height: 1px;
    background: linear-gradient(90deg, var(--glass-border), rgba(255,255,255,0.02));
  }
  @media (max-width: 720px) {
    .bk-steps { grid-template-columns: 1fr; gap: 14px; }
    .bk-step__sep { display: none; }
  }

  .booking-grid {
    display: grid;
    grid-template-columns: 1fr 380px;
    gap: 24px;
    align-items: start;
  }
  @media (max-width: 1080px) { .booking-grid { grid-template-columns: 1fr; } }

  /* ── Form card (left) ── */
  .bk-card {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    overflow: hidden;
  }
  .bk-card__head {
    display: flex; align-items: center; justify-content: space-between;
    padding: 22px 28px;
    border-bottom: 1px solid var(--glass-border);
  }
  .bk-card__head h3 {
    font-family: var(--font-sans);
    font-size: 16px; font-weight: 600;
    color: #fff; letter-spacing: -0.01em;
    display: inline-flex; align-items: center; gap: 10px;
  }
  .bk-card__head h3 i { color: var(--bx-primary); }
  .bk-card__body { padding: 28px; }

  /* Form fields */
  .bk-form-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 18px;
  }
  .bk-form-grid--full { grid-column: 1 / -1; }
  @media (max-width: 640px) { .bk-form-grid { grid-template-columns: 1fr; } }
  .bk-fld { display: flex; flex-direction: column; gap: 6px; }
  .bk-fld__lbl {
    font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase;
    font-weight: 600; color: rgba(255,255,255,0.5);
  }
  .bk-fld__lbl .req { color: var(--bx-danger); margin-left: 3px; }
  .bk-fld input, .bk-fld select, .bk-fld textarea {
    width: 100%;
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-md);
    color: #fff;
    font-family: var(--font-sans);
    font-size: 14px;
    padding: 11px 14px;
    outline: none;
    transition: border-color var(--t-fast), background var(--t-fast);
    -webkit-appearance: none;
            appearance: none;
  }
  .bk-fld input:focus, .bk-fld select:focus, .bk-fld textarea:focus {
    border-color: var(--bx-primary);
    background: rgba(111,203,163,0.06);
  }
  .bk-fld input::placeholder, .bk-fld textarea::placeholder {
    color: rgba(255,255,255,0.34);
  }
  .bk-fld textarea { resize: vertical; min-height: 80px; }
  .bk-fld select option { background: var(--bx-paper); color: #fff; }
  .bk-fld input[readonly] {
    background: rgba(255,255,255,0.02);
    color: rgba(255,255,255,0.55);
    cursor: not-allowed;
  }

  /* With-driver toggle — same pattern as elsewhere */
  .bk-driver {
    display: flex; align-items: center; gap: 14px;
    padding: 14px 18px;
    background: linear-gradient(135deg, rgba(111,203,163,0.10) 0%, rgba(111,203,163,0.02) 100%);
    border: 1px solid rgba(111,203,163,0.24);
    border-radius: var(--r-md);
    cursor: pointer;
    transition: background var(--t-fast), border-color var(--t-fast);
    user-select: none;
  }
  .bk-driver:hover {
    background: linear-gradient(135deg, rgba(111,203,163,0.18) 0%, rgba(111,203,163,0.05) 100%);
    border-color: rgba(111,203,163,0.40);
  }
  .bk-driver input { position: absolute; opacity: 0; pointer-events: none; }
  .bk-driver__dot {
    width: 22px; height: 22px; flex-shrink: 0;
    border-radius: 50%;
    border: 2px solid var(--bx-primary);
    position: relative;
  }
  .bk-driver__dot::after {
    content: ""; position: absolute; inset: 4px;
    border-radius: 50%;
    background: var(--bx-primary);
    transform: scale(0); transition: transform var(--t-fast);
  }
  .bk-driver input:checked + .bk-driver__dot::after { transform: scale(1); }
  .bk-driver__text { display: flex; flex-direction: column; gap: 2px; line-height: 1.3; flex: 1; }
  .bk-driver__text strong { font-size: 14px; color: #fff; font-weight: 600; }
  .bk-driver__text small  { font-size: 12px; color: rgba(255,255,255,0.62); }
  .bk-driver__fee {
    font-family: var(--font-mono);
    font-size: 12px;
    color: var(--bx-primary);
    font-weight: 600;
    white-space: nowrap;
  }

  /* Requirements acknowledgement */
  .bk-terms {
    margin-top: 22px;
    background: rgba(255,255,255,0.03);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    overflow: hidden;
  }
  .bk-terms__head {
    display: flex; align-items: center; gap: 12px;
    padding: 16px 20px;
    cursor: pointer;
    list-style: none;
    user-select: none;
  }
  .bk-terms__head::-webkit-details-marker { display: none; }
  .bk-terms__icon {
    width: 32px; height: 32px;
    border-radius: 8px;
    background: rgba(111,203,163,0.16);
    color: var(--bx-primary);
    border: 1px solid rgba(111,203,163,0.24);
    display: inline-flex; align-items: center; justify-content: center;
    font-size: 16px;
    flex-shrink: 0;
  }
  .bk-terms__head strong {
    flex: 1;
    font-size: 14px; font-weight: 600;
    color: #fff;
  }
  .bk-terms__head strong small {
    display: block;
    font-size: 12px;
    color: rgba(255,255,255,0.55);
    font-weight: 400;
    margin-top: 2px;
  }
  .bk-terms__chev {
    color: rgba(255,255,255,0.5);
    transition: transform var(--t-fast);
  }
  .bk-terms[open] .bk-terms__chev { transform: rotate(180deg); color: var(--bx-primary); }
  .bk-terms__body {
    padding: 0 20px 20px 64px;
    font-size: 13px;
    color: rgba(255,255,255,0.72);
    line-height: 1.65;
  }
  .bk-terms__body ul { list-style: none; padding: 0; margin: 0 0 12px; display: flex; flex-direction: column; gap: 8px; }
  .bk-terms__body li { display: flex; align-items: flex-start; gap: 10px; }
  .bk-terms__body li i { color: var(--bx-primary); font-size: 15px; margin-top: 1px; flex-shrink: 0; }
  .bk-terms__body em { font-style: normal; color: var(--bx-primary); font-weight: 500; }
  .bk-terms__body a {
    color: var(--bx-primary);
    text-decoration: none;
    border-bottom: 1px solid rgba(111,203,163,0.32);
  }
  .bk-accept {
    margin-top: 18px;
    display: flex; align-items: center; gap: 12px;
    padding: 14px 16px;
    background: rgba(111,203,163,0.06);
    border: 1px solid rgba(111,203,163,0.24);
    border-radius: var(--r-md);
    cursor: pointer;
    user-select: none;
  }
  .bk-accept input { position: absolute; opacity: 0; pointer-events: none; }
  .bk-accept__box {
    width: 20px; height: 20px; flex-shrink: 0;
    border-radius: 5px;
    border: 2px solid var(--bx-primary);
    position: relative;
  }
  .bk-accept__box::after {
    content: "\2714"; position: absolute; inset: 0;
    color: var(--bx-night);
    font-size: 14px; font-weight: 900;
    display: flex; align-items: center; justify-content: center;
    transform: scale(0);
    transition: transform var(--t-fast);
  }
  .bk-accept input:checked ~ .bk-accept__box {
    background: var(--bx-primary);
  }
  .bk-accept input:checked ~ .bk-accept__box::after { transform: scale(1); }
  .bk-accept__text {
    font-size: 13px;
    color: rgba(255,255,255,0.85);
  }
  .bk-accept__text strong { color: #fff; }

  /* Alert */
  .bk-alert {
    margin-bottom: 18px;
    padding: 14px 18px;
    border-radius: var(--r-md);
    display: flex; gap: 12px; align-items: flex-start;
    font-size: 13px;
  }
  .bk-alert i { font-size: 18px; margin-top: 1px; flex-shrink: 0; }
  .bk-alert--err {
    background: rgba(248,113,113,0.10);
    border: 1px solid rgba(248,113,113,0.32);
    color: var(--bx-danger-ink);
  }
  .bk-alert--err i { color: var(--bx-danger); }
  .bk-alert--ok {
    background: rgba(111,203,163,0.10);
    border: 1px solid rgba(111,203,163,0.32);
    color: var(--bx-primary-ink);
  }
  .bk-alert--ok i { color: var(--bx-primary); }

  /* ── Sticky breakdown rail ── */
  .bk-rail { position: sticky; top: calc(var(--topbar-height) + 24px); }
  @media (max-width: 1080px) { .bk-rail { position: static; } }
  .bk-summary {
    background: var(--glass-bg-strong);
    -webkit-backdrop-filter: blur(28px) saturate(180%);
            backdrop-filter: blur(28px) saturate(180%);
    border: 1px solid var(--glass-border-top);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow-lg);
    padding: 26px 28px 22px;
  }
  .bk-summary__head {
    display: flex; align-items: center; justify-content: space-between;
    margin-bottom: 6px;
  }
  .bk-summary__head h3 {
    font-family: var(--font-sans);
    font-size: 16px; font-weight: 600;
    color: #fff; letter-spacing: -0.012em;
  }
  .bk-summary__live {
    display: inline-flex; align-items: center; gap: 6px;
    font-family: var(--font-mono);
    font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase;
    color: var(--bx-primary);
    font-weight: 600;
  }
  .bk-summary__live::before {
    content: ""; width: 7px; height: 7px; border-radius: 50%;
    background: var(--bx-primary);
    animation: livePulse 1.6s ease-in-out infinite;
  }
  @keyframes livePulse {
    0%, 100% { box-shadow: 0 0 0 0 rgba(111,203,163,0.5); }
    50%      { box-shadow: 0 0 0 6px rgba(111,203,163,0); }
  }

  .bk-summary__meta {
    margin: 14px 0 18px;
    padding-bottom: 14px;
    border-bottom: 1px solid var(--glass-border);
  }
  .bk-summary__meta-row {
    display: flex; justify-content: space-between; align-items: center;
    padding: 6px 0;
    font-size: 12.5px;
  }
  .bk-summary__meta-row .lbl {
    color: rgba(255,255,255,0.5);
    font-size: 11px; letter-spacing: 0.10em; text-transform: uppercase;
  }
  .bk-summary__meta-row .val { color: #fff; font-weight: 500; }

  .bk-break {
    display: flex; flex-direction: column; gap: 4px;
    margin-bottom: 18px;
  }
  .bk-break__row {
    display: flex; justify-content: space-between; align-items: center;
    padding: 6px 0;
    font-size: 13px;
  }
  .bk-break__row .lbl { color: rgba(255,255,255,0.72); }
  .bk-break__row .val { color: #fff; font-family: var(--font-sans); font-weight: 500; }
  .bk-break__row.is-hidden { display: none; }
  .bk-break__row.is-discount .lbl { color: var(--bx-warning); }
  .bk-break__row.is-discount .val { color: var(--bx-warning); }
  .bk-break__row.is-info { font-size: 11px; padding-top: 2px; }
  .bk-break__row.is-info .lbl { color: rgba(255,255,255,0.45); }
  .bk-break__row.is-info .val { color: rgba(255,255,255,0.55); font-family: var(--font-mono); font-size: 11px; }

  .bk-total {
    padding: 18px 0 6px;
    border-top: 1px solid var(--glass-border);
    display: flex; justify-content: space-between; align-items: flex-end;
  }
  .bk-total .lbl {
    font-size: 11px; letter-spacing: 0.14em; text-transform: uppercase;
    color: rgba(255,255,255,0.65); font-weight: 600;
  }
  .bk-total .val {
    font-family: var(--font-sans);
    font-size: 32px; font-weight: 700;
    letter-spacing: -0.022em;
    line-height: 1.05;
    color: var(--bx-primary);
  }
  .bk-total .val sup {
    font-size: 13px; color: rgba(255,255,255,0.55);
    margin-right: 4px; font-weight: 500; vertical-align: top;
  }
  .bk-total__deposit {
    margin-top: 8px;
    text-align: right;
    font-family: var(--font-mono);
    font-size: 11px;
    color: rgba(255,255,255,0.45);
  }

  .bk-note {
    margin-top: 18px;
    padding: 12px 14px;
    background: rgba(125,211,252,0.08);
    border: 1px solid rgba(125,211,252,0.22);
    border-radius: var(--r-md);
    font-size: 12px;
    color: rgba(255,255,255,0.78);
    display: flex; gap: 10px; align-items: flex-start;
  }
  .bk-note i { color: var(--bx-info); font-size: 16px; flex-shrink: 0; margin-top: 1px; }
</style>

<div class="page-header-row reveal">
  <div class="page-header" style="margin-bottom:0;">
    <span class="eyebrow">New reservation</span>
    <h1>Reserve a <em>drive.</em></h1>
    <p>Tell us when and where &mdash; we'll handle the rest. Payment is collected after confirmation.</p>
  </div>
  <a href="${pageContext.request.contextPath}/booking?action=list" class="btn btn-secondary">
    <i class="ti ti-bookmark"></i> My reservations
  </a>
</div>

<!-- ═══ 3-step progress bar ═══ -->
<div class="bk-steps reveal">
  <div class="bk-step is-active">
    <span class="bk-step__num">1</span>
    <span class="bk-step__text">
      <span class="bk-step__lbl">Step 1 of 3</span>
      <span class="bk-step__name">Trip details</span>
    </span>
  </div>
  <div class="bk-step__sep"></div>
  <div class="bk-step">
    <span class="bk-step__num">2</span>
    <span class="bk-step__text">
      <span class="bk-step__lbl">Step 2 of 3</span>
      <span class="bk-step__name">Review price</span>
    </span>
  </div>
  <div class="bk-step__sep"></div>
  <div class="bk-step">
    <span class="bk-step__num">3</span>
    <span class="bk-step__text">
      <span class="bk-step__lbl">Step 3 of 3</span>
      <span class="bk-step__name">Confirm &amp; pay</span>
    </span>
  </div>
</div>

<c:if test="${not empty errorMsg}">
  <div class="bk-alert bk-alert--err reveal">
    <i class="ti ti-alert-circle"></i><div>${errorMsg}</div>
  </div>
</c:if>
<c:if test="${not empty successMsg}">
  <div class="bk-alert bk-alert--ok reveal">
    <i class="ti ti-circle-check"></i><div>${successMsg}</div>
  </div>
</c:if>

<div class="booking-grid">

  <!-- ═══ LEFT — booking form ═══ -->
  <div class="bk-card reveal">
    <div class="bk-card__head">
      <h3><i class="ti ti-calendar-event"></i> Booking details</h3>
      <span style="display:inline-flex; align-items:center; gap:6px; padding:5px 11px; background:rgba(111,203,163,0.14); color:var(--bx-primary); border:1px solid rgba(111,203,163,0.24); border-radius:var(--r-pill); font-size:11px; font-weight:600; letter-spacing:0.06em;">
        <i class="ti ti-spark"></i> No paperwork
      </span>
    </div>
    <div class="bk-card__body">
      <c:set var="effectiveStartDate" value="${not empty formStartDate ? formStartDate : (editMode ? editBooking.startDate : '')}"/>
      <c:set var="effectiveDuration" value="${not empty formDuration ? formDuration : (editMode ? editDuration : 3)}"/>
      <c:set var="effectivePickupLocation" value="${not empty formPickupLocation ? formPickupLocation : (editMode ? editBooking.pickupLocation : '')}"/>
      <c:set var="effectivePickupTime" value="${not empty formPickupTime ? formPickupTime : (editMode ? editBooking.pickupTime : '')}"/>
      <c:set var="effectivePhone" value="${not empty formPhone ? formPhone : (editMode ? editBooking.customerPhone : '')}"/>
      <c:set var="effectiveWithDriver" value="${not empty formWithDriver ? formWithDriver : (editMode ? editBooking.withDriver : false)}"/>
      <form action="${pageContext.request.contextPath}/booking" method="post" id="bookingForm">
        <input type="hidden" name="action" value="${editMode ? 'update' : 'create'}"/>
        <c:if test="${editMode}"><input type="hidden" name="bookingId" value="${not empty editBookingId ? editBookingId : editBooking.bookingId}"/></c:if>

        <div class="bk-fld" style="margin-bottom:20px;">
          <div id="auto-class-hint" style="padding:14px 16px; background:rgba(111,203,163,0.08); border:1px solid rgba(111,203,163,0.22); border-radius:var(--r-pill); font-size:13px; line-height:1.55; color:var(--bx-body);">
            <strong style="color:var(--bx-primary);"><i class="ti ti-info-circle"></i> Booking type is auto-classified by pickup date:</strong>
            pickup within 7 days &rarr; <strong>Instant</strong> (max 5 nights; same-day +25%, days 1&ndash;3 +10%, days 4&ndash;6 +5%).
            Pickup 7+ days ahead &rarr; <strong>Advance</strong> (standard rate, payment due 7 days before pickup).
          </div>
        </div>

        <div class="bk-form-grid">

          <div class="bk-fld">
            <label class="bk-fld__lbl" for="customerName">Driver name<span class="req">*</span></label>
            <input type="text" id="customerName"
                   value="${not empty sessionScope.loggedUser ? sessionScope.loggedUser.name : ''}" readonly/>
          </div>

          <div class="bk-fld">
            <label class="bk-fld__lbl" for="vehicleId">Vehicle<span class="req">*</span></label>
            <c:choose>
              <c:when test="${editMode}">
                <input type="hidden" name="vehicleId" value="${vehicleId}"/>
                <select id="vehicleId" disabled>
                  <c:forEach var="v" items="${vehicleList}">
                    <option value="${v.vehicleId}" data-rate="${v.rentalPricePerDay}" ${v.vehicleId == vehicleId ? 'selected' : ''}>
                      ${v.brand} ${v.model} (${v.displayCategory}) — LKR ${v.rentalPricePerDay}/day
                    </option>
                  </c:forEach>
                </select>
                <small style="font-size:11px;color:rgba(255,255,255,0.5);">Vehicle cannot be changed after a reservation is created.</small>
              </c:when>
              <c:otherwise>
                <select id="vehicleId" name="vehicleId" required onchange="onVehicleChange()">
                  <option value="">— Select vehicle —</option>
                  <c:forEach var="v" items="${vehicleList}">
                    <option value="${v.vehicleId}" data-rate="${v.rentalPricePerDay}" ${v.vehicleId == vehicleId ? 'selected' : ''}>
                      ${v.brand} ${v.model} (${v.displayCategory}) — LKR ${v.rentalPricePerDay}/day
                    </option>
                  </c:forEach>
                </select>
              </c:otherwise>
            </c:choose>
          </div>

          <div class="bk-fld">
            <label class="bk-fld__lbl" for="startDate">Start date<span class="req">*</span></label>
            <input type="date" id="startDate" name="startDate" value="${effectiveStartDate}" required/>
          </div>

          <div class="bk-fld">
            <label class="bk-fld__lbl" for="duration">Duration · days<span class="req">*</span></label>
            <input type="number" id="duration" name="duration"
                   min="1" max="90" placeholder="e.g. 3" value="${effectiveDuration}" required onchange="updateSummary()"/>
          </div>

          <div class="bk-fld">
            <label class="bk-fld__lbl" for="dailyRate">Daily rate · LKR</label>
            <input type="number" id="dailyRate" name="dailyRate" min="0"
                   placeholder="auto-filled from vehicle"
                   value="${not empty dailyRate ? dailyRate : ''}" readonly/>
          </div>

          <div class="bk-fld">
            <label class="bk-fld__lbl" for="phone">Contact number</label>
            <input type="tel" id="phone" name="phone" value="${effectivePhone}" placeholder="e.g. 0771234567" maxlength="16" inputmode="tel" pattern="(?:\+94|94|0)?7[0-9]{8}"/>
          </div>

          <div class="bk-fld">
            <label class="bk-fld__lbl" for="pickupLocation">Pick-up location<span class="req">*</span></label>
            <select id="pickupLocation" name="pickupLocation" required>
              <option value="">— Select location —</option>
              <c:forEach var="loc" items="${pickupLocations}">
                <option value="${loc}" ${loc == effectivePickupLocation ? 'selected' : ''}>${loc}</option>
              </c:forEach>
            </select>
          </div>

          <div class="bk-fld">
            <label class="bk-fld__lbl" for="pickupTime">Pick-up time<span class="req">*</span></label>
            <select id="pickupTime" name="pickupTime" required>
              <option value="">— Select time —</option>
              <c:forEach var="t" items="${pickupTimes}">
                <option value="${t}" ${t == effectivePickupTime ? 'selected' : ''}>${t}</option>
              </c:forEach>
            </select>
            <small style="font-size:11px; color:rgba(255,255,255,0.5); margin-top:4px;">
              Pick-up window: 9:00 AM &mdash; 9:00 PM
            </small>
          </div>

          <!-- With-driver toggle -->
          <div class="bk-fld bk-form-grid--full">
            <label class="bk-driver">
              <input type="checkbox" name="withDriver" id="withDriver" value="true" ${effectiveWithDriver ? 'checked' : ''} onchange="updateSummary()"/>
              <span class="bk-driver__dot"></span>
              <span class="bk-driver__text">
                <strong>With Professional Chauffeur</strong>
                <small>English-speaking, 5+ years island-wide experience &mdash; removes age &amp; licence requirements</small>
              </span>
              <span class="bk-driver__fee">+ LKR 4,500 / day</span>
            </label>
          </div>

        </div>

        <!-- Rental requirements: new bookings must explicitly accept them. -->
        <details class="bk-terms" id="bkTerms" open>
          <summary class="bk-terms__head">
            <span class="bk-terms__icon"><i class="ti ti-list-check"></i></span>
            <strong>
              Rental requirements
              <small>Quick rules &mdash; must agree before booking</small>
            </strong>
            <i class="ti ti-chevron-down bk-terms__chev"></i>
          </summary>
          <div class="bk-terms__body">
            <ul>
              <li><i class="ti ti-id"></i> <em>IDP + DMT temporary permit</em> required for foreign drivers (we can arrange the DMT permit at pickup &mdash; LKR 1,500)</li>
              <li><i class="ti ti-user-check"></i> Minimum age <em>23</em> with at least <em>2 years on a full licence</em>, or book with chauffeur to skip these</li>
              <li><i class="ti ti-credit-card"></i> Refundable <em>LKR 25,000 deposit</em> at pickup, released within 5 working days post-trip</li>
              <li><i class="ti ti-gas-station"></i> <em>Full-to-full fuel policy</em> &mdash; return with the same level you collected</li>
              <li><i class="ti ti-umbrella"></i> Booking protection charge of LKR 1,200/day is included in the calculated booking total</li>
              <li><i class="ti ti-calendar-x"></i> Cancellation is available while a booking is PENDING or CONFIRMED; any recorded demo payment is voided with cancellation</li>
            </ul>
            <p>The full version lives at <a href="${pageContext.request.contextPath}/policies" target="_blank">Rental Policies &rarr;</a></p>
          </div>
        </details>

        <c:if test="${not editMode}">
          <label class="bk-accept">
            <input type="checkbox" name="acceptTerms" value="true" required/>
            <span class="bk-accept__box"></span>
            <span class="bk-accept__text">
              <strong>I have read and agree to the rental requirements above</strong>
              &nbsp;&mdash; including the deposit, age/licence and full-to-full fuel policy.
            </span>
          </label>
        </c:if>

        <hr style="border:0; border-top:1px solid var(--glass-border); margin:28px 0;"/>

        <div style="display:flex; gap:10px; justify-content:flex-end;">
          <a href="${pageContext.request.contextPath}/booking?action=list" class="btn btn-ghost">Cancel</a>
          <button type="submit" class="btn btn-primary btn-lg" data-antigravity>
            ${editMode ? 'Update reservation' : 'Confirm reservation'}
            <span class="ico-pill"><i class="ti ti-arrow-up-right"></i></span>
          </button>
        </div>

      </form>
    </div>
  </div>

  <!-- ═══ RIGHT — sticky live breakdown rail ═══ -->
  <aside class="bk-rail">
    <div class="bk-summary reveal">
      <div class="bk-summary__head">
        <h3>Price breakdown</h3>
        <span class="bk-summary__live">Live</span>
      </div>

      <div class="bk-summary__meta">
        <div class="bk-summary__meta-row">
          <span class="lbl">Vehicle</span>
          <span class="val" id="sum-vehicle">—</span>
        </div>
        <div class="bk-summary__meta-row">
          <span class="lbl">Type</span>
          <span class="val" id="sum-type">Instant</span>
        </div>
        <div class="bk-summary__meta-row">
          <span class="lbl">Start</span>
          <span class="val" id="sum-start">Today</span>
        </div>
        <div class="bk-summary__meta-row">
          <span class="lbl">Duration</span>
          <span class="val" id="sum-duration">3 day(s)</span>
        </div>
      </div>

      <div class="bk-break">
        <div class="bk-break__row">
          <span class="lbl">Base rental</span>
          <span class="val">LKR <span id="sum-base">0</span></span>
        </div>
        <div class="bk-break__row is-info" id="row-rate">
          <span class="lbl">&nbsp;&nbsp;<span id="sum-rate-info">— × 0 days</span></span>
          <span class="val"></span>
        </div>
        <div class="bk-break__row is-hidden" id="row-surcharge">
          <span class="lbl" id="surcharge-label">Surcharge</span>
          <span class="val">LKR <span id="sum-surcharge">0</span></span>
        </div>
        <div class="bk-break__row is-hidden" id="row-driver">
          <span class="lbl">Professional chauffeur</span>
          <span class="val">LKR <span id="sum-driver">0</span></span>
        </div>
        <div class="bk-break__row">
          <span class="lbl">Insurance</span>
          <span class="val">LKR <span id="sum-insurance">0</span></span>
        </div>
        <div class="bk-break__row">
          <span class="lbl">Delivery (Kandy &amp; Colombo)</span>
          <span class="val">LKR <span id="sum-delivery">1,500</span></span>
        </div>
      </div>

      <div class="bk-total">
        <div>
          <div class="lbl">Total</div>
        </div>
        <div class="val"><sup>LKR</sup><span id="sum-total">0</span></div>
      </div>
      <div class="bk-total__deposit">
        + LKR 25,000 refundable deposit (held at pickup)
      </div>

      <div class="bk-note">
        <i class="ti ti-info-circle"></i>
        <div>Payment is collected after the reservation is confirmed by the host. No paperwork at pickup &mdash; just your ID and the deposit.</div>
      </div>
    </div>
  </aside>

</div>

<script>
  // ── Server-side fee constants (mirror BookingServlet) ──────────────
  var FEE_DRIVER_PER_DAY    = 4500;
  var FEE_INSURANCE_PER_DAY = 1200;
  var FEE_DELIVERY          = 1500;

  // Surcharge tier ladder — mirrors InstantBooking.surchargeFor(today).
  // daysAhead → surcharge rate. Keep in sync with InstantBooking constants.
  function surchargeFor(startDateStr) {
    if (!startDateStr) return { rate: 0, label: '' };
    var today = new Date(); today.setHours(0, 0, 0, 0);
    var start = new Date(startDateStr); start.setHours(0, 0, 0, 0);
    var daysAhead = Math.round((start - today) / 86400000);
    if (daysAhead === 0)                       return { rate: 0.25, label: 'Same-day surcharge (+25%)' };
    if (daysAhead >= 1 && daysAhead <= 3)      return { rate: 0.10, label: 'Short-notice surcharge (+10%)' };
    if (daysAhead >= 4 && daysAhead <= 6)      return { rate: 0.05, label: 'Instant surcharge (+5%)' };
    return { rate: 0, label: '' };  // Advance (7+) or invalid
  }

  // Type label for the meta strip ('sum-type').
  function classifyLabel(startDateStr) {
    if (!startDateStr) return 'Instant';
    var today = new Date(); today.setHours(0, 0, 0, 0);
    var start = new Date(startDateStr); start.setHours(0, 0, 0, 0);
    var daysAhead = Math.round((start - today) / 86400000);
    if (daysAhead < 0)    return 'Invalid date';
    if (daysAhead === 0)  return 'Instant — Same-day';
    if (daysAhead <= 6)   return 'Instant';
    return 'Advance';
  }

  function fmt(n) {
    return n.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  }

  function onVehicleChange() {
    var sel = document.getElementById('vehicleId');
    var opt = sel.options[sel.selectedIndex];
    var rate = opt ? opt.getAttribute('data-rate') : '';
    if (rate) document.getElementById('dailyRate').value = rate;
    updateSummary();
  }

  function updateSummary() {
    var sel       = document.getElementById('vehicleId');
    var duration  = parseInt(document.getElementById('duration').value) || 0;
    var rate      = parseFloat(document.getElementById('dailyRate').value) || 0;
    var start     = document.getElementById('startDate').value;
    var hasDriver = document.getElementById('withDriver').checked;

    var tier      = surchargeFor(start);

    // Meta strip
    var vehicleLabel = (sel.selectedIndex > 0)
        ? sel.options[sel.selectedIndex].text.replace(/—.*$/, '').trim()
        : '—';
    document.getElementById('sum-vehicle').textContent  = vehicleLabel;
    document.getElementById('sum-duration').textContent = duration ? duration + ' day(s)' : '— days';
    document.getElementById('sum-start').textContent    = start || 'Today';
    document.getElementById('sum-type').textContent     = classifyLabel(start);

    // Breakdown computation (mirrors InstantBooking.calculateBaseCost + tier).
    var baseRental = duration * rate;
    var surcharge  = baseRental * tier.rate;
    var driverFee  = hasDriver ? duration * FEE_DRIVER_PER_DAY : 0;
    var insurance  = duration * FEE_INSURANCE_PER_DAY;
    var delivery   = FEE_DELIVERY;
    var total      = baseRental + surcharge + driverFee + insurance + delivery;

    document.getElementById('sum-base').textContent      = fmt(baseRental);
    document.getElementById('sum-rate-info').textContent = 'LKR ' + fmt(rate) + ' \xd7 ' + duration + ' day(s)';
    document.getElementById('sum-surcharge').textContent = fmt(surcharge);
    document.getElementById('sum-driver').textContent    = fmt(driverFee);
    document.getElementById('sum-insurance').textContent = fmt(insurance);
    document.getElementById('sum-delivery').textContent  = fmt(delivery);
    document.getElementById('sum-total').textContent     = fmt(total);

    // Update the surcharge row's label + visibility.
    document.getElementById('surcharge-label').textContent = tier.label;
    document.getElementById('row-surcharge').classList.toggle('is-hidden', tier.rate === 0);
    document.getElementById('row-driver').classList.toggle('is-hidden',    !hasDriver);
  }

  document.getElementById('startDate').addEventListener('change', updateSummary);
  document.getElementById('duration').addEventListener('input', updateSummary);

  // Carry ?withDriver=true from search/detail page into the form
  (function() {
    var urlDriver = new URLSearchParams(window.location.search).get('withDriver');
    if (urlDriver === 'true') {
      document.getElementById('withDriver').checked = true;
    }
  })();

  window.addEventListener('DOMContentLoaded', function() {
    // Default the start date to today so the user sees a sensible initial breakdown.
    var startInput = document.getElementById('startDate');
    if (!startInput.value) {
      var today = new Date();
      var iso = today.getFullYear() + '-'
              + String(today.getMonth() + 1).padStart(2, '0') + '-'
              + String(today.getDate()).padStart(2, '0');
      startInput.value = iso;
    }
    onVehicleChange();   // also calls updateSummary
  });
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
