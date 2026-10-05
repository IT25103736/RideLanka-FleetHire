<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"  %>
<c:set var="pageTitle"   value="Browse the Fleet" scope="request"/>
<c:set var="sectionName" value="Fleet"             scope="request"/>
<c:set var="activePage"  value="search"            scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  .filter-shell { max-width: 920px; margin: 0 auto; }

  .filter-card {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(24px) saturate(180%);
            backdrop-filter: blur(24px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow-lg);
    overflow: hidden;
  }
  .filter-card__head {
    display: flex; align-items: center; justify-content: space-between;
    padding: 22px 28px;
    border-bottom: 1px solid var(--glass-border);
  }
  .filter-card__head h3 {
    font-family: var(--font-sans);
    font-size: 16px; font-weight: 600;
    color: #fff; letter-spacing: -0.01em;
  }
  .filter-card__body { padding: 28px; }

  .filter-grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 18px;
  }
  .filter-grid--full { grid-column: 1 / -1; }
  @media (max-width: 900px) { .filter-grid { grid-template-columns: 1fr 1fr; } }
  @media (max-width: 620px) { .filter-grid { grid-template-columns: 1fr; } }

  .fld {
    display: flex; flex-direction: column; gap: 6px;
  }
  .fld__lbl {
    font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase;
    font-weight: 600; color: rgba(255,255,255,0.5);
  }
  .fld input[type="text"],
  .fld input[type="number"],
  .fld select {
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
  .fld input::placeholder { color: rgba(255,255,255,0.34); }
  .fld input:focus,
  .fld select:focus {
    border-color: var(--bx-primary);
    background: rgba(111,203,163,0.06);
  }
  .fld select option { background: var(--bx-paper); color: #fff; }
  .fld--with-icon { position: relative; }
  .fld--with-icon i.fld__icon {
    position: absolute; left: 14px; bottom: 12px;
    color: rgba(255,255,255,0.45);
    font-size: 16px; pointer-events: none;
  }
  /* Match general .fld input[type="text"] specificity so padding-left wins */
  .fld--with-icon input[type="text"] { padding-left: 42px; }

  /* ── Dual-range price slider ── */
  .pricer { padding: 4px 4px 0; }
  .pricer__bar {
    position: relative; height: 6px;
    background: rgba(255,255,255,0.10);
    border-radius: 999px;
  }
  .pricer__fill {
    position: absolute; height: 100%;
    background: linear-gradient(90deg, var(--bx-primary) 0%, var(--bx-primary-deep) 100%);
    border-radius: 999px;
    top: 0;
  }
  .pricer input[type="range"] {
    position: absolute; top: -7px; left: 0;
    width: 100%; height: 20px;
    background: transparent;
    pointer-events: none;
    -webkit-appearance: none;
            appearance: none;
  }
  .pricer input[type="range"]::-webkit-slider-thumb {
    -webkit-appearance: none;
            appearance: none;
    pointer-events: auto;
    width: 20px; height: 20px;
    border-radius: 50%;
    background: #fff;
    border: 2px solid var(--bx-primary);
    box-shadow: 0 2px 8px rgba(0,0,0,0.45), 0 0 0 4px rgba(111,203,163,0.18);
    cursor: pointer;
  }
  .pricer input[type="range"]::-moz-range-thumb {
    pointer-events: auto;
    width: 20px; height: 20px; border-radius: 50%;
    background: #fff;
    border: 2px solid var(--bx-primary);
    box-shadow: 0 2px 8px rgba(0,0,0,0.45), 0 0 0 4px rgba(111,203,163,0.18);
    cursor: pointer;
  }
  .pricer__readout {
    display: flex; justify-content: space-between; align-items: center;
    margin-top: 18px;
    font-family: var(--font-mono);
    font-size: 12px;
    color: rgba(255,255,255,0.7);
  }
  .pricer__readout strong { color: var(--bx-primary); font-weight: 600; }

  /* ── With Driver toggle pill, sized for filter card ── */
  .fld--driver { grid-column: 1 / -1; }
  .driver-toggle {
    display: flex; align-items: center; gap: 14px;
    padding: 14px 18px;
    background: linear-gradient(135deg, rgba(111,203,163,0.10) 0%, rgba(111,203,163,0.02) 100%);
    border: 1px solid rgba(111,203,163,0.24);
    border-radius: var(--r-md);
    cursor: pointer;
    transition: background var(--t-fast), border-color var(--t-fast);
  }
  .driver-toggle:hover {
    background: linear-gradient(135deg, rgba(111,203,163,0.18) 0%, rgba(111,203,163,0.05) 100%);
    border-color: rgba(111,203,163,0.40);
  }
  .driver-toggle input { position: absolute; opacity: 0; pointer-events: none; }
  .driver-toggle__dot {
    flex-shrink: 0;
    width: 22px; height: 22px;
    border-radius: 50%;
    border: 2px solid var(--bx-primary);
    position: relative;
  }
  .driver-toggle__dot::after {
    content: ""; position: absolute; inset: 4px;
    border-radius: 50%;
    background: var(--bx-primary);
    transform: scale(0); transition: transform var(--t-fast);
  }
  .driver-toggle input:checked + .driver-toggle__dot::after { transform: scale(1); }
  .driver-toggle__text { display: flex; flex-direction: column; gap: 2px; line-height: 1.3; }
  .driver-toggle__text strong {
    font-size: 14px; font-weight: 600; color: #fff; letter-spacing: -0.01em;
  }
  .driver-toggle__text small { font-size: 12px; color: rgba(255,255,255,0.62); }
  .driver-toggle__badge {
    margin-left: auto;
    padding: 4px 10px;
    font-size: 10px; font-weight: 700;
    letter-spacing: 0.12em; text-transform: uppercase;
    color: var(--bx-primary);
    background: rgba(111,203,163,0.16);
    border-radius: var(--r-pill);
  }

  .filter-row {
    display: flex; gap: 12px; justify-content: space-between; align-items: center;
    margin-top: 32px;
    padding-top: 22px;
    border-top: 1px solid var(--glass-border);
  }
  .filter-row .hint {
    font-family: var(--font-mono);
    font-size: 11px;
    color: rgba(255,255,255,0.45);
    letter-spacing: 0.06em;
  }
  .filter-row .actions { display: flex; gap: 10px; }
</style>

<div class="page-header reveal" style="text-align:center;">
  <span class="eyebrow" style="margin-left:auto; margin-right:auto;">Catalogue · 50 listings</span>
  <h1 style="margin-top:14px;">Find your <em>drive.</em></h1>
  <p style="margin-left:auto; margin-right:auto;">
    Filter the fleet by type, transmission, daily rate, and chauffeur option.
    Every listing carries verified condition notes and a transparent LKR price.
  </p>
</div>

<div class="filter-shell">
  <div class="filter-card reveal">

    <div class="filter-card__head">
      <h3>Refine the catalogue</h3>
      <span class="badge badge-gray" style="background:rgba(255,255,255,0.06); color:rgba(255,255,255,0.7); border:1px solid var(--glass-border); padding:5px 11px; border-radius:var(--r-pill); font-size:11px;">
        <i class="ti ti-filter"></i> 0 filters set
      </span>
    </div>

    <div class="filter-card__body">
      <form method="get" action="${pageContext.request.contextPath}/search" onsubmit="return validateSearch()">

        <!-- Keyword + Location row (full width) -->
        <div class="filter-grid" style="grid-template-columns: 2fr 1fr; margin-bottom: 18px;">
          <div class="fld fld--with-icon">
            <span class="fld__lbl">Keyword</span>
            <i class="ti ti-zoom-in fld__icon"></i>
            <input type="text" name="keyword" maxlength="100"
                   placeholder="e.g. Aqua, Montero, HiAce…"
                   value="${param.keyword}"/>
          </div>
          <div class="fld">
            <span class="fld__lbl">Pickup city</span>
            <select name="location">
              <option value="">Any city</option>
              <option value="Colombo" ${param.location=='Colombo' ? 'selected':''}>Colombo</option>
              <option value="Kandy"   ${param.location=='Kandy'   ? 'selected':''}>Kandy</option>
            </select>
          </div>
        </div>

        <div class="filter-grid">

          <div class="fld">
            <span class="fld__lbl">Vehicle Type</span>
            <select name="vehicleType">
              <option value="">All types</option>
              <option value="sedan"     ${param.vehicleType=='sedan'     ? 'selected':''}>Sedan</option>
              <option value="hybrid"    ${param.vehicleType=='hybrid'    ? 'selected':''}>Hybrid</option>
              <option value="suv"       ${param.vehicleType=='suv'       ? 'selected':''}>SUV</option>
              <option value="hatchback" ${param.vehicleType=='hatchback' ? 'selected':''}>Hatchback</option>
              <option value="electric"  ${param.vehicleType=='electric'  ? 'selected':''}>Electric</option>
              <option value="van"       ${param.vehicleType=='van'       ? 'selected':''}>Van</option>
              
            </select>
          </div>

          <div class="fld">
            <span class="fld__lbl">Fuel</span>
            <select name="fuelType">
              <option value="">Any</option>
              <option value="Petrol"   ${param.fuelType=='Petrol'   ? 'selected':''}>Petrol</option>
              <option value="Diesel"   ${param.fuelType=='Diesel'   ? 'selected':''}>Diesel</option>
              <option value="Hybrid"   ${param.fuelType=='Hybrid'   ? 'selected':''}>Hybrid</option>
              <option value="Electric" ${param.fuelType=='Electric' ? 'selected':''}>Electric</option>
            </select>
          </div>

          <div class="fld">
            <span class="fld__lbl">Transmission</span>
            <select name="transmission">
              <option value="">Any</option>
              <option value="Automatic" ${param.transmission=='Automatic' ? 'selected':''}>Automatic</option>
              <option value="Manual"    ${param.transmission=='Manual'    ? 'selected':''}>Manual</option>
            </select>
          </div>

          <div class="fld">
            <span class="fld__lbl">Seats (Car)</span>
            <select name="seats">
              <option value="">Any seats</option>
              <c:forEach var="s" items="${availableCarSeats}">
                <option value="${s}" ${param.seats == s ? 'selected':''}>${s} seats</option>
              </c:forEach>
            </select>
          </div>
          <div class="fld">
            <span class="fld__lbl">Passenger seats (Van)</span>
            <select name="capacity">
              <option value="">Any seats</option>
              <c:forEach var="cap" items="${availableVanCapacities}">
                <option value="${cap}" ${param.capacity == cap ? 'selected':''}>
                  ${cap} seats
                </option>
              </c:forEach>
            </select>
          </div>

          <!-- Price range slider — spans full width -->
          <div class="fld filter-grid--full">
            <span class="fld__lbl">Daily rate — LKR / day</span>
            <div class="pricer">
              <div class="pricer__bar">
                <div class="pricer__fill" id="priceFill"></div>
                <input type="range" id="priceMinSlider" min="0" max="30000" step="500"
                       value="${empty param.minPrice ? 0 : param.minPrice}"/>
                <input type="range" id="priceMaxSlider" min="0" max="30000" step="500"
                       value="${empty param.maxPrice ? 30000 : param.maxPrice}"/>
              </div>
              <div class="pricer__readout">
                <span>Min &nbsp;<strong id="priceMinReadout">රු 0</strong></span>
                <span>Max &nbsp;<strong id="priceMaxReadout">රු 30,000</strong></span>
              </div>
              <input type="hidden" name="minPrice" id="minPrice" value="${param.minPrice}"/>
              <input type="hidden" name="maxPrice" id="maxPrice" value="${param.maxPrice}"/>
            </div>
          </div>

          <!-- With Driver toggle — full width -->
          <div class="fld fld--driver">
            <label class="driver-toggle">
              <input type="checkbox" name="withDriver" value="true"
                     ${param.withDriver=='true' ? 'checked':''}/>
              <span class="driver-toggle__dot"></span>
              <span class="driver-toggle__text">
                <strong>With Professional Chauffeur</strong>
                <small>+ LKR 4,500 / day &nbsp;·&nbsp; English-speaking, 5+ yrs island-wide experience</small>
              </span>
              <span class="driver-toggle__badge">Popular</span>
            </label>
          </div>

        </div>

        <div class="filter-row">
          <span class="hint">[ Filters apply on submit ]</span>
          <div class="actions">
            <a href="${pageContext.request.contextPath}/search" class="btn btn-ghost">
              <i class="ti ti-refresh"></i> Reset
            </a>
            <button type="submit" class="btn btn-primary" data-antigravity>
              Search the fleet
              <span class="ico-pill"><i class="ti ti-arrow-up-right"></i></span>
            </button>
          </div>
        </div>

      </form>

      <script>
        // ── Dual-range slider wiring ─────────────────────────────────────
        (function() {
          var minS = document.getElementById('priceMinSlider');
          var maxS = document.getElementById('priceMaxSlider');
          var fill = document.getElementById('priceFill');
          var minOut = document.getElementById('priceMinReadout');
          var maxOut = document.getElementById('priceMaxReadout');
          var minHidden = document.getElementById('minPrice');
          var maxHidden = document.getElementById('maxPrice');
          if (!minS || !maxS) return;

          function fmt(n) { return 'රු ' + Number(n).toLocaleString('en-US'); }

          function clampPair() {
            var lo = parseInt(minS.value, 10);
            var hi = parseInt(maxS.value, 10);
            if (lo > hi - 500) {
              // Push the one being moved
              if (this && this.id === 'priceMinSlider') { minS.value = (hi - 500); lo = hi - 500; }
              else                                       { maxS.value = (lo + 500); hi = lo + 500; }
            }
            var range = parseInt(minS.max, 10) - parseInt(minS.min, 10);
            var lp = ((lo - parseInt(minS.min, 10)) / range) * 100;
            var hp = ((hi - parseInt(minS.min, 10)) / range) * 100;
            fill.style.left  = lp + '%';
            fill.style.width = (hp - lp) + '%';
            minOut.textContent = fmt(lo);
            maxOut.textContent = fmt(hi);
            // Submit empty if at the range bounds (so URL stays clean for "no filter")
            minHidden.value = (lo === parseInt(minS.min, 10)) ? '' : lo;
            maxHidden.value = (hi === parseInt(maxS.max, 10)) ? '' : hi;
          }
          minS.addEventListener('input', clampPair);
          maxS.addEventListener('input', clampPair);
          clampPair.call(minS);
        })();

        function validateSearch() {
          var lo = document.getElementById('priceMinSlider').value;
          var hi = document.getElementById('priceMaxSlider').value;
          if (parseInt(lo,10) > parseInt(hi,10)) {
            alert('Min daily rate cannot be greater than Max.');
            return false;
          }
          return true;
        }
      </script>
    </div>
  </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
