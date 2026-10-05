<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle"   value="Rental Policies" scope="request"/>
<c:set var="activePage"  value="policies"        scope="request"/>
<%@ include file="/WEB-INF/views/common/marketing-header.jsp" %>

<style>
  /* ════════════════════════════════════════════════════════════
     Policies — Liquid Glass dark page, seafoam accents
     ════════════════════════════════════════════════════════════ */
  .pol-hero {
    padding: 120px 32px 60px;
    text-align: center;
    background:
      radial-gradient(70% 60% at 50% 0%, rgba(111,203,163,0.12) 0%, transparent 70%),
      var(--bx-night);
    border-bottom: 1px solid var(--glass-border);
  }
  .pol-hero__eyebrow {
    display: inline-flex; align-items: center; gap: 8px;
    padding: 6px 14px;
    border-radius: var(--r-pill);
    background: rgba(111,203,163,0.10);
    border: 1px solid rgba(111,203,163,0.24);
    color: var(--bx-primary);
    font-size: 11px; font-weight: 600;
    letter-spacing: 0.14em; text-transform: uppercase;
    margin-bottom: 22px;
  }
  .pol-hero__eyebrow::before {
    content: ""; width: 6px; height: 6px; border-radius: 50%;
    background: var(--bx-primary);
    box-shadow: 0 0 0 4px rgba(111,203,163,0.32);
  }
  .pol-hero h1 {
    font-family: 'Manrope', var(--font-sans);
    font-size: clamp(40px, 5vw, 64px);
    font-weight: 600;
    letter-spacing: -0.035em;
    line-height: 1.04;
    color: #fff;
    max-width: 18ch;
    margin: 0 auto;
  }
  .pol-hero h1 em { font-style: normal; color: var(--bx-primary); }
  .pol-hero p {
    margin: 22px auto 0;
    max-width: 64ch;
    font-size: 16px;
    color: rgba(255,255,255,0.7);
    line-height: 1.65;
  }
  .pol-hero__meta {
    margin-top: 28px;
    font-family: var(--font-mono);
    font-size: 11px;
    letter-spacing: 0.14em; text-transform: uppercase;
    color: rgba(255,255,255,0.4);
  }

  /* ── Body shell — 2-col with sticky help rail ── */
  .pol-shell {
    max-width: 1180px;
    margin: 0 auto;
    padding: 56px 32px 96px;
    display: grid;
    grid-template-columns: 1fr 340px;
    gap: 36px;
    align-items: flex-start;
  }
  @media (max-width: 1020px) { .pol-shell { grid-template-columns: 1fr; } }

  /* ── Quick-reference card (sits at top of left column) ── */
  .pol-quick {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    padding: 28px;
    margin-bottom: 24px;
  }
  .pol-quick h2 {
    font-size: 13px; letter-spacing: 0.14em; text-transform: uppercase;
    color: var(--bx-primary);
    font-weight: 700;
    margin-bottom: 18px;
    display: inline-flex; align-items: center; gap: 8px;
  }
  .pol-quick h2 i { font-size: 16px; }
  .pol-quick__grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 14px;
  }
  @media (max-width: 600px) { .pol-quick__grid { grid-template-columns: 1fr; } }
  .pol-quick__item {
    display: flex; align-items: flex-start; gap: 12px;
    padding: 12px 14px;
    background: rgba(255,255,255,0.03);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-md);
  }
  .pol-quick__item i {
    color: var(--bx-primary);
    font-size: 18px;
    margin-top: 1px;
    flex-shrink: 0;
  }
  .pol-quick__item strong {
    display: block;
    font-size: 13px;
    color: #fff;
    font-weight: 600;
    letter-spacing: -0.005em;
  }
  .pol-quick__item small {
    display: block;
    font-size: 12px;
    color: rgba(255,255,255,0.6);
    margin-top: 2px;
    line-height: 1.4;
  }

  /* ── Accordion sections ── */
  .pol-section {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    margin-bottom: 14px;
    overflow: hidden;
    transition: background var(--t-fast), border-color var(--t-fast);
  }
  .pol-section[open] {
    background: var(--glass-bg-strong);
    border-color: rgba(255,255,255,0.16);
  }
  .pol-section__head {
    display: flex; align-items: center; gap: 16px;
    padding: 22px 28px;
    cursor: pointer;
    list-style: none;
    user-select: none;
  }
  .pol-section__head::-webkit-details-marker { display: none; }
  .pol-section__icon {
    flex-shrink: 0;
    width: 42px; height: 42px;
    border-radius: 12px;
    background: linear-gradient(135deg, rgba(111,203,163,0.18) 0%, rgba(111,203,163,0.05) 100%);
    border: 1px solid rgba(111,203,163,0.28);
    color: var(--bx-primary);
    display: inline-flex; align-items: center; justify-content: center;
    font-size: 19px;
  }
  .pol-section__title {
    flex: 1;
    font-family: var(--font-sans);
    font-size: 17px; font-weight: 600;
    color: #fff;
    letter-spacing: -0.012em;
    line-height: 1.3;
  }
  .pol-section__title small {
    display: block;
    font-size: 12px;
    color: rgba(255,255,255,0.58);
    font-weight: 400;
    margin-top: 3px;
    letter-spacing: 0;
  }
  .pol-section__chev {
    color: rgba(255,255,255,0.5);
    font-size: 18px;
    transition: transform var(--t-fast), color var(--t-fast);
  }
  .pol-section[open] .pol-section__chev {
    transform: rotate(180deg);
    color: var(--bx-primary);
  }
  .pol-section__body {
    padding: 0 28px 26px 86px;
    color: rgba(255,255,255,0.78);
    font-size: 14px;
    line-height: 1.7;
  }
  .pol-section__body p { margin-bottom: 12px; }
  .pol-section__body p:last-child { margin-bottom: 0; }
  .pol-section__body strong { color: #fff; font-weight: 600; }
  .pol-section__body em { font-style: normal; color: var(--bx-primary); font-weight: 500; }
  .pol-section__body ul {
    list-style: none; padding: 0; margin: 8px 0 12px;
    display: flex; flex-direction: column; gap: 8px;
  }
  .pol-section__body li {
    display: flex; align-items: flex-start; gap: 10px;
    color: rgba(255,255,255,0.78);
  }
  .pol-section__body li i {
    color: var(--bx-primary);
    font-size: 16px;
    margin-top: 2px;
    flex-shrink: 0;
  }
  @media (max-width: 720px) {
    .pol-section__head { padding: 18px 20px; }
    .pol-section__body { padding: 0 20px 22px 20px; }
  }

  /* ── Cancellation tier table ── */
  .pol-tiers {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 10px;
    margin: 16px 0 6px;
  }
  @media (max-width: 720px) { .pol-tiers { grid-template-columns: 1fr 1fr; } }
  .pol-tier {
    padding: 14px 16px;
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-md);
    text-align: center;
  }
  .pol-tier__when {
    display: block;
    font-family: var(--font-mono);
    font-size: 10px; letter-spacing: 0.12em; text-transform: uppercase;
    color: rgba(255,255,255,0.55);
    margin-bottom: 6px;
  }
  .pol-tier__refund {
    display: block;
    font-family: var(--font-sans);
    font-size: 22px; font-weight: 700;
    color: var(--bx-primary);
    letter-spacing: -0.018em;
    line-height: 1.1;
  }
  .pol-tier__refund.is-medium { color: var(--bx-warning); }
  .pol-tier__refund.is-low    { color: var(--bx-danger); }
  .pol-tier__label {
    display: block;
    font-size: 11px;
    color: rgba(255,255,255,0.6);
    margin-top: 4px;
  }

  /* ── Right rail: help card + table of contents ── */
  .pol-rail { position: sticky; top: 96px; }
  @media (max-width: 1020px) { .pol-rail { position: static; } }
  .pol-toc {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    padding: 22px;
    margin-bottom: 16px;
  }
  .pol-toc h3 {
    font-size: 11px; letter-spacing: 0.14em; text-transform: uppercase;
    color: rgba(255,255,255,0.55); font-weight: 700;
    margin-bottom: 14px;
  }
  .pol-toc ol { list-style: none; padding: 0; margin: 0; counter-reset: tocCount; }
  .pol-toc li {
    counter-increment: tocCount;
    padding: 6px 0;
  }
  .pol-toc a {
    display: flex; align-items: center; gap: 10px;
    color: rgba(255,255,255,0.72);
    font-size: 13px;
    text-decoration: none;
    transition: color var(--t-fast);
  }
  .pol-toc a::before {
    content: counter(tocCount, decimal-leading-zero);
    font-family: var(--font-mono);
    font-size: 10px;
    color: rgba(255,255,255,0.4);
    width: 22px;
  }
  .pol-toc a:hover { color: var(--bx-primary); }
  .pol-toc a:hover::before { color: var(--bx-primary); }

  .pol-help {
    background: linear-gradient(135deg, rgba(111,203,163,0.10) 0%, rgba(111,203,163,0.02) 100%);
    border: 1px solid rgba(111,203,163,0.24);
    border-radius: var(--r-shell);
    padding: 26px;
    box-shadow: var(--glass-shadow);
  }
  .pol-help__icon {
    width: 44px; height: 44px;
    border-radius: 50%;
    background: var(--bx-primary);
    color: var(--bx-night);
    display: inline-flex; align-items: center; justify-content: center;
    font-size: 22px;
    margin-bottom: 14px;
  }
  .pol-help h3 {
    font-family: var(--font-sans);
    font-size: 18px; font-weight: 600;
    color: #fff;
    letter-spacing: -0.012em;
    margin-bottom: 8px;
  }
  .pol-help p {
    font-size: 13px;
    color: rgba(255,255,255,0.7);
    line-height: 1.55;
    margin-bottom: 16px;
  }
  .pol-help__row {
    display: flex; align-items: center; gap: 10px;
    padding: 11px 14px;
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-md);
    margin-bottom: 8px;
    font-size: 13px;
    color: rgba(255,255,255,0.85);
  }
  .pol-help__row i { color: var(--bx-primary); font-size: 16px; flex-shrink: 0; }
  .pol-help__row strong { color: #fff; font-weight: 600; }

  .pol-cta {
    margin-top: 56px;
    padding: 40px 32px;
    text-align: center;
    background: var(--glass-bg-strong);
    -webkit-backdrop-filter: blur(28px) saturate(180%);
            backdrop-filter: blur(28px) saturate(180%);
    border: 1px solid var(--glass-border-top);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow-lg);
  }
  .pol-cta h2 {
    font-family: 'Manrope', var(--font-sans);
    font-size: clamp(26px, 3vw, 36px);
    font-weight: 600;
    letter-spacing: -0.025em;
    color: #fff;
    margin-bottom: 10px;
  }
  .pol-cta h2 em { font-style: normal; color: var(--bx-primary); }
  .pol-cta p {
    color: rgba(255,255,255,0.65);
    font-size: 15px;
    margin-bottom: 22px;
    max-width: 58ch;
    margin-left: auto; margin-right: auto;
  }
  .pol-cta__row {
    display: flex; justify-content: center; gap: 12px; flex-wrap: wrap;
  }
</style>

<!-- ═══ Hero ═══ -->
<section class="pol-hero reveal">
  <span class="pol-hero__eyebrow">Trust &amp; Compliance</span>
  <h1>Honest policies, <em>plainly explained.</em></h1>
  <p>
    Every rental at RideLanka FleetHire is governed by transparent, Sri Lanka-compliant policies.
    Read this before you book &mdash; or any time after &mdash; and contact us if anything
    needs clarifying.
  </p>
  <div class="pol-hero__meta">Last reviewed · 12 May 2026 &nbsp;·&nbsp; v 3.1</div>
</section>

<div class="pol-shell">

  <!-- ═══ LEFT COLUMN — quick ref + accordion sections ═══ -->
  <div>

    <!-- Quick-reference summary -->
    <div class="pol-quick reveal">
      <h2><i class="ti ti-bolt"></i> At a glance</h2>
      <div class="pol-quick__grid">
        <div class="pol-quick__item">
          <i class="ti ti-id"></i>
          <div><strong>IDP + DMT permit required</strong><small>Plus your home-country licence in English</small></div>
        </div>
        <div class="pol-quick__item">
          <i class="ti ti-user-check"></i>
          <div><strong>Age 23+, 2 years' experience</strong><small>Minimum, regardless of vehicle type</small></div>
        </div>
        <div class="pol-quick__item">
          <i class="ti ti-credit-card"></i>
          <div><strong>LKR 25,000 deposit</strong><small>Refunded within 5 working days post-trip</small></div>
        </div>
        <div class="pol-quick__item">
          <i class="ti ti-umbrella"></i>
          <div><strong>Comprehensive insurance</strong><small>Zero-excess add-on available at checkout</small></div>
        </div>
        <div class="pol-quick__item">
          <i class="ti ti-gas-station"></i>
          <div><strong>Full-to-full fuel policy</strong><small>Return with the same level you collected</small></div>
        </div>
        <div class="pol-quick__item">
          <i class="ti ti-clock"></i>
          <div><strong>Free cancellation 24h+ out</strong><small>Tiered refund schedule beyond that</small></div>
        </div>
      </div>
    </div>

    <!-- 1. License Requirements -->
    <details class="pol-section reveal" id="license" open>
      <summary class="pol-section__head">
        <span class="pol-section__icon"><i class="ti ti-id"></i></span>
        <span class="pol-section__title">
          Driving licence requirements
          <small>IDP + Temporary Permit issued by the DMT</small>
        </span>
        <i class="ti ti-chevron-down pol-section__chev"></i>
      </summary>
      <div class="pol-section__body">
        <p>To drive any vehicle in Sri Lanka, foreign visitors must carry <strong>three documents</strong> at all times:</p>
        <ul>
          <li><i class="ti ti-circle-check"></i> A valid driving licence issued in your home country</li>
          <li><i class="ti ti-circle-check"></i> An <em>International Driving Permit (IDP)</em> &mdash; obtained in your home country before travel</li>
          <li><i class="ti ti-circle-check"></i> A <em>Sri Lankan Temporary Permit</em> &mdash; issued by the Department of Motor Traffic (DMT) at Werahera, Colombo, or via authorised agents (LKR 2,000, same-day)</li>
        </ul>
        <p>RideLanka FleetHire can arrange the temporary DMT permit on your behalf for an LKR 1,500 service fee &mdash; just tick the option at checkout and we'll handle the paperwork at pickup.</p>
        <p><strong>Sri Lankan citizens</strong> need only their original NIC and full local licence (probationary licences are not accepted).</p>
      </div>
    </details>

    <!-- 2. Age & Experience -->
    <details class="pol-section reveal" id="age">
      <summary class="pol-section__head">
        <span class="pol-section__icon"><i class="ti ti-user-check"></i></span>
        <span class="pol-section__title">
          Age &amp; experience requirements
          <small>Minimum 23 years old with 2+ years on a full licence</small>
        </span>
        <i class="ti ti-chevron-down pol-section__chev"></i>
      </summary>
      <div class="pol-section__body">
        <p>To rent any vehicle in our fleet you must be at least <strong>23 years old</strong> and hold a <strong>full driving licence for two consecutive years</strong>.</p>
        <p>For SUVs, luxury sedans and 12+ seat vans we ask for <strong>5 years of experience</strong> and an age minimum of 25 &mdash; this is an insurance requirement, not a RideLanka FleetHire preference.</p>
        <p>If you'd rather skip the criteria entirely, our <em>Professional Chauffeur</em> service (+LKR 4,500/day) places an experienced English-speaking driver behind the wheel and removes the age/experience check.</p>
      </div>
    </details>

    <!-- 3. Security Deposit & Refund -->
    <details class="pol-section reveal" id="deposit">
      <summary class="pol-section__head">
        <span class="pol-section__icon"><i class="ti ti-credit-card"></i></span>
        <span class="pol-section__title">
          Security deposit &amp; refund
          <small>LKR 25,000 held against damage, refunded in 5 working days</small>
        </span>
        <i class="ti ti-chevron-down pol-section__chev"></i>
      </summary>
      <div class="pol-section__body">
        <p>A refundable security deposit of <strong>LKR 25,000</strong> is collected at vehicle pickup. It is held against damage, traffic fines or fuel shortfall during your rental period.</p>
        <p>Payment options: cash (LKR or USD at the day's rate), bank transfer, or pre-authorisation on Visa / Mastercard.</p>
        <p>Post-return, the deposit is released within <strong>5 working days</strong> via the original payment method. Any deductions are itemised in writing with photo evidence.</p>
        <p>Security-deposit requirements are shown during booking and confirmation; no automatic deposit waiver is applied.</p>
      </div>
    </details>

    <!-- 4. Insurance -->
    <details class="pol-section reveal" id="insurance">
      <summary class="pol-section__head">
        <span class="pol-section__icon"><i class="ti ti-umbrella"></i></span>
        <span class="pol-section__title">
          Insurance &amp; liability
          <small>Comprehensive baseline, zero-excess add-on optional</small>
        </span>
        <i class="ti ti-chevron-down pol-section__chev"></i>
      </summary>
      <div class="pol-section__body">
        <p>Every vehicle is covered by a <strong>comprehensive insurance policy</strong> against accidental damage, theft and third-party liability, underwritten by Sri Lanka Insurance Corporation.</p>
        <p>Standard cover carries an excess of <strong>LKR 75,000</strong> per claim. You can reduce this to zero by adding our <em>Damage Liability Waiver</em> at checkout for LKR 1,200 / day.</p>
        <p>Not covered: damage from off-road driving, driving under the influence, unauthorised drivers, and tyre/rim damage from kerbing &mdash; same exclusions you'd see anywhere in the world.</p>
      </div>
    </details>

    <!-- 5. Fuel Policy -->
    <details class="pol-section reveal" id="fuel">
      <summary class="pol-section__head">
        <span class="pol-section__icon"><i class="ti ti-gas-station"></i></span>
        <span class="pol-section__title">
          Fuel policy
          <small>Full-to-full &mdash; no markup, no surprises</small>
        </span>
        <i class="ti ti-chevron-down pol-section__chev"></i>
      </summary>
      <div class="pol-section__body">
        <p>All vehicles are delivered with a <strong>full fuel tank</strong>. You return them with the same level you collected &mdash; full.</p>
        <p>Returned short? We charge the missing fuel at the day's <em>retail pump price</em> (no markup) plus a flat LKR 500 refuelling service charge.</p>
        <p>Keep your fuel receipts &mdash; we'll reimburse if you over-fill on a final top-up within 20 km of return.</p>
      </div>
    </details>

    <!-- 6. Cancellation (tiered) -->
    <details class="pol-section reveal" id="cancellation">
      <summary class="pol-section__head">
        <span class="pol-section__icon"><i class="ti ti-calendar-x"></i></span>
        <span class="pol-section__title">
          Cancellation policy
          <small>Tiered refund schedule based on notice period</small>
        </span>
        <i class="ti ti-chevron-down pol-section__chev"></i>
      </summary>
      <div class="pol-section__body">
        <p>Plans change. We keep the refund schedule simple, public, and tiered:</p>
        <div class="pol-tiers">
          <div class="pol-tier">
            <span class="pol-tier__when">24h+ out</span>
            <span class="pol-tier__refund">100%</span>
            <span class="pol-tier__label">Full refund</span>
          </div>
          <div class="pol-tier">
            <span class="pol-tier__when">12&ndash;24h</span>
            <span class="pol-tier__refund">75%</span>
            <span class="pol-tier__label">Most of it back</span>
          </div>
          <div class="pol-tier">
            <span class="pol-tier__when">6&ndash;12h</span>
            <span class="pol-tier__refund is-medium">50%</span>
            <span class="pol-tier__label">Half refund</span>
          </div>
          <div class="pol-tier">
            <span class="pol-tier__when">&lt; 6h</span>
            <span class="pol-tier__refund is-low">0%</span>
            <span class="pol-tier__label">No refund</span>
          </div>
        </div>
        <p>Tier is calculated against the <strong>start of your scheduled pickup window</strong>. Force-majeure events (weather warnings, civil disturbance, family emergencies with proof) override the schedule &mdash; we issue a full refund or free reschedule.</p>
      </div>
    </details>

    <!-- 7. Accident Procedure -->
    <details class="pol-section reveal" id="accident">
      <summary class="pol-section__head">
        <span class="pol-section__icon"><i class="ti ti-alert-triangle"></i></span>
        <span class="pol-section__title">
          Accident &amp; breakdown procedure
          <small>What to do in the first ten minutes</small>
        </span>
        <i class="ti ti-chevron-down pol-section__chev"></i>
      </summary>
      <div class="pol-section__body">
        <p>If you're in any incident &mdash; even minor &mdash; follow this order:</p>
        <ul>
          <li><i class="ti ti-number-1"></i> <strong>Move to safety</strong>. Switch on hazard lights, place the warning triangle 30 m behind the vehicle.</li>
          <li><i class="ti ti-number-2"></i> <strong>Check for injuries</strong>. Dial <em>119</em> (Sri Lanka Police) or <em>110</em> (Ambulance) if anyone needs medical attention.</li>
          <li><i class="ti ti-number-3"></i> <strong>Call RideLanka FleetHire 24/7</strong>: <em>+94 77 811 9913</em> &mdash; we dispatch a recovery vehicle and replacement within 90 minutes island-wide.</li>
          <li><i class="ti ti-number-4"></i> <strong>Document the scene</strong>: photos of all vehicles, plates, position, and damage. Do <em>not</em> admit fault on scene &mdash; let insurance assess.</li>
          <li><i class="ti ti-number-5"></i> <strong>File a police report</strong> within 24 hours at the nearest station for any insurance claim.</li>
        </ul>
        <p>For breakdowns (battery, tyre, mechanical) call the same number &mdash; we cover roadside assistance free of charge for the full rental period.</p>
      </div>
    </details>

    <!-- Bottom CTA -->
    <div class="pol-cta reveal">
      <h2>Ready to <em>book the trip?</em></h2>
      <p>You've read the fine print &mdash; that's more than most. The fleet's waiting.</p>
      <div class="pol-cta__row">
        <a href="${pageContext.request.contextPath}/search" class="btn btn-primary btn-lg" data-antigravity>
          Browse the fleet
          <span class="ico-pill"><i class="ti ti-arrow-up-right"></i></span>
        </a>
        <a href="#contact" class="btn btn-glass btn-lg">
          Contact us
          <i class="ti ti-message-circle"></i>
        </a>
      </div>
    </div>

  </div>

  <!-- ═══ RIGHT COLUMN — TOC + help card ═══ -->
  <aside class="pol-rail reveal">

    <div class="pol-toc">
      <h3>On this page</h3>
      <ol>
        <li><a href="#license">Licence requirements</a></li>
        <li><a href="#age">Age &amp; experience</a></li>
        <li><a href="#deposit">Security deposit</a></li>
        <li><a href="#insurance">Insurance &amp; liability</a></li>
        <li><a href="#fuel">Fuel policy</a></li>
        <li><a href="#cancellation">Cancellation</a></li>
        <li><a href="#accident">Accident procedure</a></li>
      </ol>
    </div>

    <div class="pol-help">
      <div class="pol-help__icon"><i class="ti ti-headset"></i></div>
      <h3>Need clarification?</h3>
      <p>Anything here that isn't obvious, or a clause that doesn't suit your trip? Reach out &mdash; we adjust where reasonable.</p>
      <div class="pol-help__row">
        <i class="ti ti-phone"></i>
        <span><strong>+94 77 811 9913</strong> &nbsp;<small style="color:rgba(255,255,255,0.5);">24/7</small></span>
      </div>
      <div class="pol-help__row">
        <i class="ti ti-brand-whatsapp"></i>
        <span><strong>+94 77 811 9913</strong> &nbsp;<small style="color:rgba(255,255,255,0.5);">WhatsApp</small></span>
      </div>
      <div class="pol-help__row">
        <i class="ti ti-mail"></i>
        <span><strong>hello@vrms.lk</strong></span>
      </div>
    </div>

  </aside>

</div>

<%@ include file="/WEB-INF/views/common/marketing-footer.jsp" %>
