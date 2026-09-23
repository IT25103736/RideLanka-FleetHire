<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle"   value="Promotions &amp; Loyalty" scope="request"/>
<c:set var="sectionName" value="Payments"                  scope="request"/>
<c:set var="activePage"  value="payment"                   scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  /* ════════════════════════════════════════════════════════════
     Promotions & loyalty — seafoam banner, glass promo grid
     ════════════════════════════════════════════════════════════ */
  .pm-banner {
    position: relative;
    padding: 28px 32px;
    margin-bottom: 22px;
    background:
      radial-gradient(50% 80% at 90% 10%, rgba(111,203,163,0.32) 0%, transparent 70%),
      linear-gradient(135deg, var(--bx-paper) 0%, var(--bx-night-2) 100%);
    border: 1px solid var(--glass-border-top);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow-lg);
    display: flex; align-items: center; justify-content: space-between;
    overflow: hidden;
  }
  .pm-banner__lbl {
    font-size: 11px; letter-spacing: 0.18em; text-transform: uppercase;
    color: rgba(255,255,255,0.55); font-weight: 600;
  }
  .pm-banner__val {
    font-family: 'Space Grotesk', var(--font-sans);
    font-size: 44px; font-weight: 700;
    color: var(--bx-primary);
    letter-spacing: -0.025em;
    line-height: 1.05;
    margin: 4px 0 6px;
  }
  .pm-banner__val span {
    font-family: var(--font-sans); font-size: 16px;
    color: rgba(255,255,255,0.55); font-weight: 500; margin-left: 8px;
  }
  .pm-banner__sub {
    font-size: 12px; color: rgba(255,255,255,0.62);
  }
  .pm-banner__icon {
    width: 80px; height: 80px;
    border-radius: 50%;
    background: linear-gradient(135deg, rgba(111,203,163,0.32) 0%, rgba(111,203,163,0.08) 100%);
    border: 1px solid rgba(111,203,163,0.45);
    color: var(--bx-primary);
    display: inline-flex; align-items: center; justify-content: center;
    font-size: 38px;
    box-shadow: inset 0 1px 0 rgba(255,255,255,0.18), 0 12px 36px -16px rgba(111,203,163,0.55);
  }

  .pm-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 18px;
  }
  @media (max-width: 800px) { .pm-grid { grid-template-columns: 1fr; } }

  .pm-card {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    overflow: hidden;
  }
  .pm-card__head {
    display: flex; align-items: center; justify-content: space-between;
    padding: 18px 22px;
    border-bottom: 1px solid var(--glass-border);
  }
  .pm-card__head h3 {
    font-family: var(--font-sans);
    font-size: 14px; font-weight: 600; color: #fff;
    display: inline-flex; align-items: center; gap: 8px;
  }
  .pm-card__head h3 i { color: var(--bx-primary); font-size: 16px; }
  .pm-card--gift .pm-card__head h3 i { color: var(--bx-warning); }
  .pm-card__body { padding: 22px; }

  .pm-fld { display: flex; flex-direction: column; gap: 6px; margin-bottom: 14px; }
  .pm-fld__lbl {
    font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase;
    font-weight: 600; color: rgba(255,255,255,0.55);
  }
  .pm-fld input {
    width: 100%;
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-md);
    color: #fff;
    font-family: var(--font-sans);
    font-size: 14px;
    padding: 12px 14px;
    outline: none;
    transition: border-color var(--t-fast), background var(--t-fast);
    text-transform: none;
  }
  .pm-fld input:focus {
    border-color: var(--bx-primary);
    background: rgba(111,203,163,0.06);
  }
  .pm-fld input::placeholder { color: rgba(255,255,255,0.34); }
  .pm-fld input.uppercase { text-transform: uppercase; }
  .pm-fld__hint { font-size: 11px; color: rgba(255,255,255,0.5); margin-top: 4px; }

  .pm-promo-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: 14px;
  }
  .pm-promo {
    border: 1px dashed rgba(111,203,163,0.45);
    border-radius: var(--r-md);
    padding: 16px;
    background: rgba(111,203,163,0.06);
  }
  .pm-promo__head {
    display: flex; justify-content: space-between; align-items: center;
    margin-bottom: 10px;
  }
  .pm-promo__code {
    font-family: var(--font-mono);
    font-size: 16px; font-weight: 700;
    color: var(--bx-primary);
    letter-spacing: 0.04em;
  }
  .pm-promo__discount {
    display: inline-flex; align-items: center; gap: 5px;
    padding: 3px 10px;
    background: rgba(111,203,163,0.18);
    color: var(--bx-primary);
    border: 1px solid rgba(111,203,163,0.32);
    border-radius: var(--r-pill);
    font-size: 11px; font-weight: 600;
  }
  .pm-promo__desc { font-size: 13px; color: rgba(255,255,255,0.78); line-height: 1.5; }
  .pm-promo__expiry { font-size: 11px; color: rgba(255,255,255,0.5); margin-top: 10px; font-family: var(--font-mono); }

  /* Alerts */
  .pm-alert {
    margin-top: 14px;
    padding: 12px 16px;
    border-radius: var(--r-md);
    display: flex; gap: 10px; align-items: flex-start;
    font-size: 13px;
  }
  .pm-alert i { font-size: 17px; margin-top: 1px; flex-shrink: 0; }
  .pm-alert--ok  { background: rgba(111,203,163,0.10); border: 1px solid rgba(111,203,163,0.32); color: rgba(255,255,255,0.85); }
  .pm-alert--ok  i { color: var(--bx-primary); }
  .pm-alert--err { background: rgba(248,113,113,0.10); border: 1px solid rgba(248,113,113,0.32); color: rgba(255,255,255,0.85); }
  .pm-alert--err i { color: var(--bx-danger); }

  .pm-cta { width: 100%; justify-content: center; }
</style>

<div class="page-header reveal">
  <span class="eyebrow">Wallet</span>
  <h1>Promotions &amp; <em>loyalty points.</em></h1>
  <p>Manage your promo codes and track your loyalty reward balance.</p>
</div>

<!-- Loyalty banner -->
<div class="pm-banner reveal">
  <div>
    <div class="pm-banner__lbl">Your loyalty balance</div>
    <div class="pm-banner__val">
      ${not empty loyaltyPoints ? loyaltyPoints : 0}<span>points</span>
    </div>
    <div class="pm-banner__sub">1 point = LKR 1 discount on your next booking</div>
  </div>
  <div class="pm-banner__icon"><i class="ti ti-coin"></i></div>
</div>

<div class="pm-grid">

  <!-- Promo code check -->
  <div class="pm-card reveal">
    <div class="pm-card__head">
      <h3><i class="ti ti-tag"></i> Check a promo code</h3>
    </div>
    <div class="pm-card__body">
      <form action="${pageContext.request.contextPath}/payment/promo" method="post">
        <div class="pm-fld">
          <label class="pm-fld__lbl" for="promoCode">Promo code</label>
          <input type="text" id="promoCode" name="promoCode" class="uppercase"
                 placeholder="e.g. VRMS2025" value="${param.promoCode}"/>
        </div>
        <button type="submit" class="btn btn-primary pm-cta" data-antigravity>
          <i class="ti ti-check"></i> Validate code
        </button>
      </form>

      <c:if test="${not empty promoResult}">
        <div class="pm-alert pm-alert--${promoValid ? 'ok' : 'err'}">
          <i class="ti ti-${promoValid ? 'circle-check' : 'x'}"></i>
          <div>${promoResult}</div>
        </div>
      </c:if>
    </div>
  </div>

  <!-- Redeem points -->
  <div class="pm-card pm-card--gift reveal">
    <div class="pm-card__head">
      <h3><i class="ti ti-gift"></i> Redeem points</h3>
    </div>
    <div class="pm-card__body">
      <form action="${pageContext.request.contextPath}/payment/redeem" method="post">
        <div class="pm-fld">
          <label class="pm-fld__lbl" for="points">Points to redeem</label>
          <input type="number" id="points" name="points" min="1"
                 max="${not empty loyaltyPoints ? loyaltyPoints : 0}"
                 placeholder="e.g. 500"/>
          <span class="pm-fld__hint">Max available: ${not empty loyaltyPoints ? loyaltyPoints : 0} pts</span>
        </div>
        <div class="pm-fld">
          <label class="pm-fld__lbl" for="bookingId">Apply to booking ID</label>
          <input type="text" id="bookingId" name="bookingId" placeholder="e.g. B-0042"/>
        </div>
        <button type="submit" class="btn btn-secondary pm-cta">
          <i class="ti ti-coin"></i> Redeem points
        </button>
      </form>
    </div>
  </div>

  <!-- Active promotions -->
  <div class="pm-card reveal" style="grid-column: 1 / -1;">
    <div class="pm-card__head">
      <h3><i class="ti ti-speakerphone"></i> Active promotions</h3>
    </div>
    <div class="pm-card__body">
      <c:choose>
        <c:when test="${not empty promotions}">
          <div class="pm-promo-grid">
            <c:forEach var="p" items="${promotions}">
              <div class="pm-promo">
                <div class="pm-promo__head">
                  <span class="pm-promo__code">${p.code}</span>
                  <span class="pm-promo__discount">${p.discount}% off</span>
                </div>
                <div class="pm-promo__desc">${p.description}</div>
                <div class="pm-promo__expiry">Expires: ${p.expiryDate}</div>
              </div>
            </c:forEach>
          </div>
        </c:when>
        <c:otherwise>
          <div class="pm-promo-grid">
            <div class="pm-promo">
              <div class="pm-promo__head">
                <span class="pm-promo__code">VRMS2025</span>
                <span class="pm-promo__discount">10% off</span>
              </div>
              <div class="pm-promo__desc">New user discount &mdash; 10% off your first booking.</div>
              <div class="pm-promo__expiry">Expires: 31 Dec 2025</div>
            </div>
            <div class="pm-promo">
              <div class="pm-promo__head">
                <span class="pm-promo__code">WEEKEND20</span>
                <span class="pm-promo__discount">20% off</span>
              </div>
              <div class="pm-promo__desc">Weekend special &mdash; 20% off weekend bookings.</div>
              <div class="pm-promo__expiry">Expires: 30 Jun 2025</div>
            </div>
            <div class="pm-promo">
              <div class="pm-promo__head">
                <span class="pm-promo__code">AVURUDU</span>
                <span class="pm-promo__discount">15% off</span>
              </div>
              <div class="pm-promo__desc">Sinhala &amp; Tamil New Year &mdash; 15% off all hill country bookings.</div>
              <div class="pm-promo__expiry">Expires: 30 Apr 2026</div>
            </div>
          </div>
        </c:otherwise>
      </c:choose>
    </div>
  </div>

</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
