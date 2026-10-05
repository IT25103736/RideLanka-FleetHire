<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"  %>
<c:set var="pageTitle"   value="${vehicle.brand} ${vehicle.model}" scope="request"/>
<c:set var="sectionName" value="Fleet"                              scope="request"/>
<c:set var="activePage"  value="search"                             scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  /* ════════════════════════════════════════════════════════════
     Vehicle Detail — Liquid Glass on dark, seafoam accents
     ════════════════════════════════════════════════════════════ */
  .vd-shell {
    display: grid;
    grid-template-columns: 1fr 380px;
    gap: 32px;
    align-items: flex-start;
  }
  @media (max-width: 1080px) { .vd-shell { grid-template-columns: 1fr; } }

  .vd-back {
    display: inline-flex; align-items: center; gap: 6px;
    color: rgba(255,255,255,0.6);
    font-size: 13px;
    text-decoration: none;
    margin-bottom: 18px;
    transition: color var(--t-fast);
  }
  .vd-back:hover { color: var(--bx-primary); }

  /* ── Gallery ── */
  .vd-gallery {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    overflow: hidden;
  }
  .vd-gallery__main {
    position: relative;
    aspect-ratio: 16/10;
    background: rgba(255,255,255,0.04);
    overflow: hidden;
  }
  .vd-gallery__main img {
    width: 100%; height: 100%; object-fit: cover; display: block;
    transition: opacity 280ms var(--ease-glide);
  }
  .vd-gallery__main img.is-fading { opacity: 0; }
  .vd-gallery__chip {
    position: absolute; top: 18px; left: 18px;
    display: inline-flex; align-items: center; gap: 6px;
    padding: 7px 14px;
    border-radius: var(--r-pill);
    font-size: 11px; font-weight: 600;
    background: rgba(111,203,163,0.18);
    color: var(--bx-primary);
    border: 1px solid rgba(111,203,163,0.32);
    -webkit-backdrop-filter: blur(14px);
            backdrop-filter: blur(14px);
    z-index: 2;
  }
  .vd-gallery__chip::before {
    content: ""; width: 7px; height: 7px; border-radius: 50%;
    background: var(--bx-primary);
    box-shadow: 0 0 0 3px rgba(111,203,163,0.32);
  }
  .vd-gallery__chip--unavail {
    background: rgba(248,113,113,0.18);
    color: var(--bx-danger);
    border-color: rgba(248,113,113,0.32);
  }
  .vd-gallery__chip--unavail::before { background: var(--bx-danger); box-shadow: 0 0 0 3px rgba(248,113,113,0.32); }

  .vd-gallery__thumbs {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 6px;
    padding: 6px;
  }
  .vd-gallery__thumb {
    aspect-ratio: 4/3;
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-md);
    overflow: hidden;
    cursor: pointer;
    position: relative;
    transition: border-color var(--t-fast), transform var(--t-fast);
  }
  .vd-gallery__thumb img { width:100%; height:100%; object-fit:cover; display:block; }
  .vd-gallery__thumb:hover { border-color: rgba(255,255,255,0.22); transform: translateY(-2px); }
  .vd-gallery__thumb.is-active {
    border-color: var(--bx-primary);
    box-shadow: 0 0 0 2px rgba(111,203,163,0.32);
  }

  /* ── Title block ── */
  .vd-title {
    margin: 24px 0 28px;
  }
  .vd-title__eyebrow {
    display: inline-flex; align-items: center; gap: 8px;
    padding: 5px 12px;
    background: rgba(255,255,255,0.06);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-pill);
    font-size: 11px; letter-spacing: 0.14em; text-transform: uppercase;
    color: rgba(255,255,255,0.7); font-weight: 600;
    margin-bottom: 14px;
  }
  .vd-title h1 {
    font-family: var(--font-sans);
    font-size: clamp(34px, 4vw, 48px);
    font-weight: 700;
    letter-spacing: -0.028em;
    line-height: 1.04;
    color: #fff;
  }
  .vd-title h1 em { font-style: normal; color: var(--bx-primary); }
  .vd-title__meta {
    margin-top: 10px;
    display: flex; flex-wrap: wrap; gap: 14px;
    color: rgba(255,255,255,0.6);
    font-size: 13px;
  }
  .vd-title__meta span { display: inline-flex; align-items: center; gap: 6px; }
  .vd-title__meta i { color: var(--bx-primary); font-size: 15px; }

  /* ── Section card (specs / features / perfect-for) ── */
  .vd-card {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    padding: 28px 32px;
    margin-bottom: 22px;
  }
  .vd-card h2 {
    font-family: var(--font-sans);
    font-size: 18px; font-weight: 600;
    letter-spacing: -0.012em;
    color: #fff;
    margin-bottom: 18px;
    display: inline-flex; align-items: center; gap: 10px;
  }
  .vd-card h2 i { color: var(--bx-primary); font-size: 20px; }

  /* ── Specs table ── */
  .vd-specs {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 0;
  }
  .vd-specs > div {
    display: flex; justify-content: space-between; align-items: center;
    padding: 14px 0;
    border-bottom: 1px solid var(--glass-border);
    font-size: 14px;
  }
  .vd-specs > div:last-child,
  .vd-specs > div:nth-last-child(2) { border-bottom: 0; }
  .vd-specs__lbl { color: rgba(255,255,255,0.6); }
  .vd-specs__val { color: #fff; font-weight: 500; }
  @media (max-width: 720px) { .vd-specs { grid-template-columns: 1fr; } }

  /* Make every other row visually paired */
  .vd-specs > div:nth-child(odd)  { padding-right: 24px; }
  .vd-specs > div:nth-child(even) { padding-left: 24px; }
  @media (max-width: 720px) {
    .vd-specs > div { padding: 14px 0 !important; border-bottom: 1px solid var(--glass-border) !important; }
    .vd-specs > div:last-child { border-bottom: 0 !important; }
  }

  /* ── Features grid ── */
  .vd-features {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(170px, 1fr));
    gap: 12px;
  }
  .vd-feature {
    display: flex; align-items: center; gap: 10px;
    padding: 11px 14px;
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-md);
    font-size: 13px;
    color: rgba(255,255,255,0.85);
  }
  .vd-feature i { color: var(--bx-primary); font-size: 16px; flex-shrink: 0; }

  /* ── Perfect-for tags ── */
  .vd-tags { display: flex; flex-wrap: wrap; gap: 8px; }
  .vd-tag {
    padding: 7px 14px;
    background: rgba(111,203,163,0.10);
    border: 1px solid rgba(111,203,163,0.24);
    color: var(--bx-primary);
    border-radius: var(--r-pill);
    font-size: 12px; font-weight: 500;
  }

  /* ════════════════════════════════════════════════════════════
     Sticky price rail
     ════════════════════════════════════════════════════════════ */
  .vd-rail {
    position: sticky; top: 80px;
  }
  @media (max-width: 1080px) { .vd-rail { position: static; } }
  .vd-price {
    background: var(--glass-bg-strong);
    -webkit-backdrop-filter: blur(28px) saturate(180%);
            backdrop-filter: blur(28px) saturate(180%);
    border: 1px solid var(--glass-border-top);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow-lg);
    padding: 28px;
    margin-bottom: 18px;
  }
  .vd-price__lbl {
    font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase;
    color: rgba(255,255,255,0.5); font-weight: 600;
  }
  .vd-price__main {
    margin-top: 6px;
    font-family: var(--font-sans);
    font-size: 38px; font-weight: 700;
    letter-spacing: -0.025em; line-height: 1.05;
    color: #fff;
  }
  .vd-price__main sup {
    font-size: 14px; color: var(--bx-primary);
    font-weight: 600; vertical-align: top;
    margin-right: 6px;
  }
  .vd-price__per {
    font-size: 13px; font-weight: 500;
    color: rgba(255,255,255,0.55);
    margin-left: 6px;
  }
  .vd-price__usd {
    font-family: var(--font-mono);
    font-size: 12px;
    color: rgba(255,255,255,0.45);
    margin-top: 6px;
    letter-spacing: 0.02em;
  }
  .vd-price__hr {
    height: 1px; background: var(--glass-border);
    margin: 22px -28px;
  }
  .vd-price__add {
    display: flex; align-items: center; gap: 14px;
    padding: 14px 16px;
    background: linear-gradient(135deg, rgba(111,203,163,0.10) 0%, rgba(111,203,163,0.02) 100%);
    border: 1px solid rgba(111,203,163,0.24);
    border-radius: var(--r-md);
    cursor: pointer;
    transition: background var(--t-fast), border-color var(--t-fast);
    user-select: none;
  }
  .vd-price__add:hover {
    background: linear-gradient(135deg, rgba(111,203,163,0.18) 0%, rgba(111,203,163,0.05) 100%);
    border-color: rgba(111,203,163,0.40);
  }
  .vd-price__add input { position: absolute; opacity: 0; pointer-events: none; }
  .vd-price__add-dot {
    width: 20px; height: 20px; flex-shrink: 0;
    border-radius: 50%;
    border: 2px solid var(--bx-primary);
    position: relative;
  }
  .vd-price__add-dot::after {
    content: ""; position: absolute; inset: 3px;
    border-radius: 50%;
    background: var(--bx-primary);
    transform: scale(0); transition: transform var(--t-fast);
  }
  .vd-price__add input:checked ~ .vd-price__add-dot::after { transform: scale(1); }
  .vd-price__add-text { display: flex; flex-direction: column; gap: 2px; line-height: 1.3; flex: 1; }
  .vd-price__add-text strong { font-size: 13px; color: #fff; font-weight: 600; }
  .vd-price__add-text small  { font-size: 11px; color: rgba(255,255,255,0.6); }
  .vd-price__add-fee {
    font-family: var(--font-mono);
    font-size: 12px;
    color: var(--bx-primary);
    font-weight: 600;
    white-space: nowrap;
  }

  .vd-price__total {
    margin-top: 20px;
    padding: 16px 18px;
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-md);
    display: flex; justify-content: space-between; align-items: center;
  }
  .vd-price__total-lbl {
    font-size: 11px; letter-spacing: 0.10em; text-transform: uppercase;
    color: rgba(255,255,255,0.6); font-weight: 600;
  }
  .vd-price__total-val {
    font-family: var(--font-sans);
    font-size: 22px; font-weight: 700;
    color: var(--bx-primary);
    letter-spacing: -0.02em;
  }
  .vd-price__total-val sup { font-size: 11px; color: rgba(255,255,255,0.55); margin-right: 4px; font-weight: 500; }

  .vd-price__cta {
    display: flex; align-items: center; justify-content: center; gap: 10px;
    width: 100%;
    margin-top: 16px;
    padding: 16px 22px;
    background: var(--bx-primary);
    color: var(--bx-night);
    border: 0;
    border-radius: var(--r-md);
    font-family: var(--font-sans);
    font-size: 15px; font-weight: 700;
    cursor: pointer;
    text-decoration: none;
    transition: background var(--t-fast), transform var(--t-fast), box-shadow var(--t-fast);
    box-shadow: inset 0 1px 0 rgba(255,255,255,0.32), 0 8px 22px -8px rgba(111,203,163,0.55);
  }
  .vd-price__cta:hover { background: var(--bx-primary-deep); }
  .vd-price__cta:active { transform: scale(0.98); }
  .vd-price__cta.is-disabled { opacity: 0.45; pointer-events: none; }

  .vd-price__note {
    margin-top: 12px;
    font-size: 11px;
    color: rgba(255,255,255,0.5);
    text-align: center;
  }

  /* Included / Requirements blocks in the rail */
  .vd-mini {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    padding: 22px;
    margin-bottom: 18px;
  }
  .vd-mini h3 {
    font-size: 12px; letter-spacing: 0.14em; text-transform: uppercase;
    color: rgba(255,255,255,0.55); font-weight: 700;
    margin-bottom: 14px;
    display: inline-flex; align-items: center; gap: 8px;
  }
  .vd-mini h3 i { color: var(--bx-primary); font-size: 14px; }
  .vd-mini ul { list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 10px; }
  .vd-mini li {
    display: flex; align-items: flex-start; gap: 10px;
    font-size: 13px;
    color: rgba(255,255,255,0.78);
  }
  .vd-mini li i { color: var(--bx-primary); margin-top: 2px; flex-shrink: 0; }
  .vd-mini__more {
    display: inline-flex; align-items: center; gap: 4px;
    margin-top: 14px;
    color: var(--bx-primary);
    font-size: 12px; font-weight: 600;
    text-decoration: none;
    transition: gap var(--t-fast);
  }
  .vd-mini__more:hover { gap: 8px; }
</style>

<a href="javascript:history.back()" class="vd-back"><i class="ti ti-arrow-left"></i> Back to results</a>

<div class="vd-shell">

  <!-- ═══ LEFT COLUMN — gallery + content sections ═══ -->
  <div>

    <div class="vd-gallery reveal">
      <div class="vd-gallery__main">
        <c:choose>
          <c:when test="${vehicle.available}">
            <span class="vd-gallery__chip">Available</span>
          </c:when>
          <c:otherwise>
            <span class="vd-gallery__chip vd-gallery__chip--unavail">Currently Unavailable</span>
          </c:otherwise>
        </c:choose>
        <c:choose>
          <c:when test="${not empty vehicle.imageUrl}">
            <img id="vdHero" src="${vehicle.imageUrl}" alt="${vehicle.brand} ${vehicle.model}" decoding="async" fetchpriority="high" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/images/vehicles/default-vehicle.jpg'"/>
          </c:when>
          <c:otherwise>
            <div style="height:100%;min-height:420px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:10px;background:linear-gradient(135deg,#182331,#0b1118);color:rgba(255,255,255,.62)">
              <i class="ti ti-car" style="font-size:64px;color:var(--bx-primary)"></i>
              <strong>No vehicle photo uploaded</strong>
              <span style="font-size:12px">Vehicle Management can add a verified image URL for this exact vehicle.</span>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
      <c:if test="${not empty vehicle.imageUrl}">
        <div class="vd-gallery__thumbs"><div class="vd-gallery__thumb is-active" data-src="${vehicle.imageUrl}"><img src="${vehicle.imageUrl}" alt="${vehicle.brand} ${vehicle.model}" loading="lazy" decoding="async" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/images/vehicles/default-vehicle.jpg'"/></div></div>
      </c:if>
    </div>

    <div class="vd-title reveal">
      <span class="vd-title__eyebrow">${vehicle.vehicleType} &nbsp;·&nbsp; Ref. ${vehicle.vehicleId}</span>
      <h1>${vehicle.brand} <em>${vehicle.model}</em></h1>
      <div class="vd-title__meta">
        <span><i class="ti ti-calendar"></i> ${vehicle.year}</span>
        <c:choose>
          <c:when test="${vehicle.vehicleType == 'Car'}">
            <span><i class="ti ti-users"></i> ${vehicle.extraField} seats</span>
          </c:when>
          <c:when test="${vehicle.vehicleType == 'Van'}">
            <span><i class="ti ti-users"></i> ${vehicle.extraField} passenger seats</span>
          </c:when>
        </c:choose>
        <span><i class="ti ti-gas-station"></i> ${vehicleRecord.fuelType}</span>
        <span><i class="ti ti-settings"></i> ${vehicleRecord.transmission}</span>
        <span><i class="ti ti-map-pin"></i> ${vehicleRecord.branchName}</span>
      </div>
    </div>

    <!-- Specs -->
    <section class="vd-card reveal">
      <h2><i class="ti ti-clipboard-list"></i> Vehicle specifications</h2>
      <div class="vd-specs">
        <div><span class="vd-specs__lbl">Make</span><span class="vd-specs__val">${vehicle.brand}</span></div>
        <div><span class="vd-specs__lbl">Model</span><span class="vd-specs__val">${vehicle.model}</span></div>
        <div><span class="vd-specs__lbl">Year</span><span class="vd-specs__val">${vehicle.year}</span></div>
        <div><span class="vd-specs__lbl">Type</span><span class="vd-specs__val">${vehicle.vehicleType}</span></div>
        <div><span class="vd-specs__lbl">Fuel</span><span class="vd-specs__val">${vehicleRecord.fuelType}</span></div>
        <div><span class="vd-specs__lbl">Transmission</span><span class="vd-specs__val">${vehicleRecord.transmission}</span></div>
        <c:choose>
          <c:when test="${vehicle.vehicleType == 'Car'}">
            <div><span class="vd-specs__lbl">Seats</span><span class="vd-specs__val">${vehicle.extraField}</span></div>
            <div><span class="vd-specs__lbl">Recorded mileage</span><span class="vd-specs__val">${vehicleRecord.mileage} km</span></div>
          </c:when>
          <c:when test="${vehicle.vehicleType == 'Van'}">
            <div><span class="vd-specs__lbl">Passenger seats</span><span class="vd-specs__val">${vehicle.extraField}</span></div>
            <div><span class="vd-specs__lbl">Recorded mileage</span><span class="vd-specs__val">${vehicleRecord.mileage} km</span></div>
          </c:when>
        </c:choose>
        <div><span class="vd-specs__lbl">Branch</span><span class="vd-specs__val">${vehicleRecord.branchName}</span></div>
        <div><span class="vd-specs__lbl">Insurance expiry</span><span class="vd-specs__val">${not empty vehicleRecord.insuranceExpiry ? vehicleRecord.insuranceExpiry : 'Not recorded'}</span></div>
      </div>
    </section>

    <!-- Features -->
    <section class="vd-card reveal">
      <h2><i class="ti ti-sparkles"></i> Features &amp; comfort</h2>
      <div class="vd-features">
        <div class="vd-feature"><i class="ti ti-snowflake"></i> Air conditioning</div>
        <div class="vd-feature"><i class="ti ti-bluetooth"></i> Bluetooth audio</div>
        <div class="vd-feature"><i class="ti ti-usb"></i> USB charging</div>
        <div class="vd-feature"><i class="ti ti-gps"></i> GPS navigation</div>
        <div class="vd-feature"><i class="ti ti-shield-check"></i> ABS &amp; airbags</div>
        <div class="vd-feature"><i class="ti ti-key"></i> Keyless entry</div>
        <c:if test="${vehicle.vehicleType == 'Car' or vehicle.vehicleType == 'Van'}">
          <div class="vd-feature"><i class="ti ti-armchair"></i> Leather seats</div>
          <div class="vd-feature"><i class="ti ti-camera"></i> Reverse camera</div>
        </c:if>
      </div>
    </section>

    <!-- Perfect for -->
    <section class="vd-card reveal">
      <h2><i class="ti ti-route"></i> Perfect for</h2>
      <div class="vd-tags">
        <c:choose>
          <c:when test="${vehicle.vehicleType == 'Car'}">
            <span class="vd-tag">Family travel</span>
            <span class="vd-tag">City commute</span>
            <span class="vd-tag">Weekend escape</span>
            <span class="vd-tag">Weddings</span>
            <span class="vd-tag">Airport transfers</span>
            <span class="vd-tag">Hill-country drives</span>
          </c:when>
          <c:when test="${vehicle.vehicleType == 'Van'}">
            <span class="vd-tag">Group tours</span>
            <span class="vd-tag">Airport transfers</span>
            <span class="vd-tag">Multi-day island loops</span>
            <span class="vd-tag">Wedding parties</span>
            <span class="vd-tag">Cargo runs</span>
          </c:when>
        </c:choose>
      </div>
    </section>

  </div>

  <!-- ═══ RIGHT COLUMN — sticky price rail ═══ -->
  <aside class="vd-rail reveal">

    <div class="vd-price">
      <div class="vd-price__lbl">From</div>
      <div class="vd-price__main">
        <sup>LKR</sup><span id="vdBasePrice"><fmt:formatNumber value="${vehicle.rentalPricePerDay}" pattern="#,##0.00"/></span>
        <span class="vd-price__per">/day</span>
      </div>
      <div class="vd-price__usd">
        &asymp; USD <fmt:formatNumber value="${vehicle.rentalPricePerDay / lkrPerUsd}" pattern="#,##0"/> &nbsp;·&nbsp; no booking fee
      </div>

      <div class="vd-price__hr"></div>

      <label class="vd-price__add">
        <input type="checkbox" id="vdDriver"/>
        <span class="vd-price__add-dot"></span>
        <span class="vd-price__add-text">
          <strong>With Professional Chauffeur</strong>
          <small>English-speaking, 5+ years island-wide experience</small>
        </span>
        <span class="vd-price__add-fee">+ LKR <fmt:formatNumber value="${driverFeeLkr}" pattern="#,##0.00"/></span>
      </label>

      <div class="vd-price__total">
        <span class="vd-price__total-lbl">Total / day</span>
        <span class="vd-price__total-val">
          <sup>LKR</sup><span id="vdTotal"><fmt:formatNumber value="${vehicle.rentalPricePerDay}" pattern="#,##0.00"/></span>
        </span>
      </div>

      <c:choose>
        <c:when test="${vehicle.available}">
          <a id="vdBookCta"
             href="${pageContext.request.contextPath}/booking?action=form&vehicleId=${vehicle.vehicleId}&dailyRate=${vehicle.rentalPricePerDay}"
             class="vd-price__cta" data-antigravity>
            <i class="ti ti-calendar-plus"></i> Book this vehicle
          </a>
        </c:when>
        <c:otherwise>
          <span class="vd-price__cta is-disabled">
            <i class="ti ti-calendar-off"></i> Currently unavailable
          </span>
        </c:otherwise>
      </c:choose>

      <div class="vd-price__note">Pay after the trip &middot; cancel free up to 24h before pickup</div>
    </div>

    <!-- What's Included -->
    <div class="vd-mini">
      <h3><i class="ti ti-circle-check"></i> What's included</h3>
      <ul>
        <li><i class="ti ti-check"></i> Comprehensive insurance, zero excess option</li>
        <li><i class="ti ti-check"></i> 24/7 roadside assistance, island-wide</li>
        <li><i class="ti ti-check"></i> Free delivery within Kandy &amp; Colombo city limits</li>
        <li><i class="ti ti-check"></i> Full-to-full fuel policy &mdash; no surprises</li>
        <li><i class="ti ti-check"></i> Unlimited city kilometres on rentals 3+ days</li>
      </ul>
    </div>

    <!-- Requirements -->
    <div class="vd-mini">
      <h3><i class="ti ti-list-check"></i> Driver requirements</h3>
      <ul>
        <li><i class="ti ti-id"></i> Valid IDP + temporary permit from the DMT</li>
        <li><i class="ti ti-user-check"></i> Minimum age 23 with 2+ years of experience</li>
        <li><i class="ti ti-credit-card"></i> Refundable security deposit (LKR 25,000)</li>
        <li><i class="ti ti-passport"></i> Passport or NIC for verification</li>
      </ul>
      <a href="${pageContext.request.contextPath}/policies" class="vd-mini__more">
        Full rental policies <i class="ti ti-arrow-right"></i>
      </a>
    </div>

  </aside>

</div>

<script>
  // ── Gallery thumb-swap ─────────────────────────────────────────────
  (function() {
    var hero = document.getElementById('vdHero');
    var thumbs = document.querySelectorAll('.vd-gallery__thumb');
    if (!hero || !thumbs.length) return;
    thumbs.forEach(function(t) {
      t.addEventListener('click', function() {
        var src = t.getAttribute('data-src');
        if (!src) return;
        hero.classList.add('is-fading');
        setTimeout(function() {
          hero.src = src;
          hero.classList.remove('is-fading');
        }, 180);
        thumbs.forEach(function(x) { x.classList.remove('is-active'); });
        t.classList.add('is-active');
      });
    });
  })();

  // ── Chauffeur add-on toggle: live total + carry into booking URL ──
  (function() {
    var base = ${vehicle.rentalPricePerDay};
    var fee  = ${driverFeeLkr};
    var driver = document.getElementById('vdDriver');
    var totalEl = document.getElementById('vdTotal');
    var cta = document.getElementById('vdBookCta');
    if (!driver || !totalEl) return;
    var baseHref = cta ? cta.getAttribute('href') : null;
    function fmt(n) { return n.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }); }
    function update() {
      var t = base + (driver.checked ? fee : 0);
      totalEl.textContent = fmt(t);
      if (cta && baseHref) {
        cta.setAttribute('href', baseHref + (driver.checked ? '&withDriver=true' : ''));
      }
    }
    driver.addEventListener('change', update);
    update();
  })();
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
