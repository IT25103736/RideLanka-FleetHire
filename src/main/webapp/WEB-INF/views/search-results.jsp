<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"  %>
<c:set var="pageTitle"   value="Search Results" scope="request"/>
<c:set var="sectionName" value="Fleet"           scope="request"/>
<c:set var="activePage"  value="search"          scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  /* ════════════════════════════════════════════════════════════
     Listing — Liquid Glass card grid (dark + seafoam)
     ════════════════════════════════════════════════════════════ */
  .results-bar {
    display: flex; align-items: center; justify-content: space-between;
    gap: 20px; flex-wrap: wrap;
    padding: 18px 22px;
    margin: 0 0 22px;
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
  }
  .results-bar__count {
    font-family: var(--font-sans);
    font-size: 15px;
    color: rgba(255,255,255,0.78);
  }
  .results-bar__count strong {
    font-size: 22px; font-weight: 700;
    color: var(--bx-primary);
    letter-spacing: -0.02em;
    margin-right: 6px;
  }
  .results-bar__chips {
    display: flex; gap: 6px; flex-wrap: wrap;
    margin-top: 6px;
  }
  .results-bar__chip {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 4px 10px;
    font-size: 11px; font-weight: 500;
    color: rgba(255,255,255,0.78);
    background: rgba(255,255,255,0.06);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-pill);
  }
  .results-bar__chip i { color: var(--bx-primary); font-size: 12px; }
  .results-bar__sort {
    display: flex; align-items: center; gap: 10px;
    margin-left: auto;
  }
  .results-bar__sort label {
    font-size: 11px; letter-spacing: 0.14em; text-transform: uppercase;
    color: rgba(255,255,255,0.5); font-weight: 600;
  }
  .results-bar__sort select {
    -webkit-appearance: none;
            appearance: none;
    background: rgba(255,255,255,0.05);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-pill);
    color: #fff;
    font-family: var(--font-sans);
    font-size: 13px; font-weight: 500;
    padding: 9px 36px 9px 16px;
    cursor: pointer;
    background-image:
      linear-gradient(45deg, transparent 50%, var(--bx-primary) 50%),
      linear-gradient(135deg, var(--bx-primary) 50%, transparent 50%);
    background-position: calc(100% - 18px) 50%, calc(100% - 14px) 50%;
    background-size: 5px 5px;
    background-repeat: no-repeat;
  }
  .results-bar__sort select option { background: var(--bx-paper); color: #fff; }

  /* ── Card grid ── */
  .gallery {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(360px, 1fr));
    gap: 22px;
  }
  .veh-card {
    position: relative;
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    overflow: hidden;
    display: flex; flex-direction: column;
    transition: transform var(--t-base), background var(--t-base), border-color var(--t-base), box-shadow var(--t-base);
  }
  .veh-card:hover {
    transform: translateY(-4px);
    background: var(--glass-bg-strong);
    border-color: rgba(255,255,255,0.18);
    box-shadow: var(--glass-shadow-lg);
  }
  .veh-card__media {
    position: relative;
    aspect-ratio: 4/3;
    overflow: hidden;
    background: rgba(255,255,255,0.04);
  }
  .veh-card__media img {
    width: 100%; height: 100%; object-fit: cover; display: block;
    transition: transform var(--t-slow);
  }
  .veh-card:hover .veh-card__media img { transform: scale(1.06); }
  .veh-card__media::after {
    content: ""; position: absolute; inset: 0;
    background: linear-gradient(180deg, transparent 55%, rgba(5,9,18,0.4) 100%);
    pointer-events: none;
  }

  /* Top-left chip — Available / Unavailable */
  .veh-card__chip {
    position: absolute; top: 14px; left: 14px;
    display: inline-flex; align-items: center; gap: 6px;
    padding: 6px 12px;
    border-radius: var(--r-pill);
    font-size: 11px; font-weight: 600;
    letter-spacing: 0.02em;
    z-index: 2;
    -webkit-backdrop-filter: blur(14px) saturate(180%);
            backdrop-filter: blur(14px) saturate(180%);
  }
  .veh-card__chip--available {
    background: rgba(111,203,163,0.18);
    color: var(--bx-primary);
    border: 1px solid rgba(111,203,163,0.32);
  }
  .veh-card__chip--available::before {
    content: ""; width: 7px; height: 7px; border-radius: 50%;
    background: var(--bx-primary);
    box-shadow: 0 0 0 3px rgba(111,203,163,0.32);
  }
  .veh-card__chip--unavailable {
    background: rgba(248,113,113,0.18);
    color: var(--bx-danger);
    border: 1px solid rgba(248,113,113,0.32);
  }
  .veh-card__chip--type {
    top: auto; bottom: 14px; left: 14px;
    background: rgba(0,0,0,0.5);
    color: #fff;
    border: 1px solid rgba(255,255,255,0.14);
  }

  .veh-card__fav {
    position: absolute; top: 14px; right: 14px;
    width: 36px; height: 36px;
    border-radius: 50%;
    background: rgba(0,0,0,0.5);
    border: 1px solid var(--glass-border);
    -webkit-backdrop-filter: blur(14px);
            backdrop-filter: blur(14px);
    display: inline-flex; align-items: center; justify-content: center;
    color: rgba(255,255,255,0.85);
    cursor: pointer;
    transition: color var(--t-fast), background var(--t-fast);
    z-index: 2;
  }
  .veh-card__fav:hover { color: var(--bx-danger); background: rgba(0,0,0,0.7); }

  .veh-card__body { padding: 18px 22px 22px; display: flex; flex-direction: column; gap: 12px; }
  .veh-card__head {
    display: flex; justify-content: space-between; align-items: flex-start;
    gap: 10px;
  }
  .veh-card__title {
    font-family: var(--font-sans);
    font-size: 19px; font-weight: 600;
    letter-spacing: -0.018em;
    line-height: 1.2;
    color: #fff;
  }
  .veh-card__sub {
    font-size: 12px;
    color: rgba(255,255,255,0.55);
    margin-top: 3px;
    letter-spacing: 0.02em;
  }
  .veh-card__desc {
    font-size: 13px;
    color: rgba(255,255,255,0.7);
    line-height: 1.5;
    margin-top: -2px;
  }
  .veh-card__desc em {
    font-style: normal;
    color: var(--bx-primary);
    font-weight: 500;
  }

  .veh-card__specs {
    display: flex; gap: 16px; flex-wrap: wrap;
    padding: 12px 0;
    border-top: 1px solid var(--glass-border);
    border-bottom: 1px solid var(--glass-border);
  }
  .veh-card__spec {
    display: flex; align-items: center; gap: 6px;
    font-size: 11.5px;
    color: rgba(255,255,255,0.7);
    letter-spacing: 0.01em;
  }
  .veh-card__spec i { font-size: 14px; color: var(--bx-primary); }

  .veh-card__foot {
    display: flex; align-items: flex-end; justify-content: space-between;
    gap: 12px;
  }
  .veh-card__price-lbl {
    font-size: 10px; letter-spacing: 0.10em; text-transform: uppercase;
    color: rgba(255,255,255,0.5); font-weight: 600;
  }
  .veh-card__price-val {
    font-family: var(--font-sans);
    font-size: 24px; font-weight: 700;
    letter-spacing: -0.022em;
    line-height: 1.1;
    color: #fff;
    margin-top: 3px;
  }
  .veh-card__price-val sup {
    font-size: 11px; color: var(--bx-primary);
    margin-right: 4px; font-weight: 600;
    vertical-align: middle;
  }
  .veh-card__price-val .per {
    font-size: 11px;
    color: rgba(255,255,255,0.55);
    font-weight: 500;
    margin-left: 4px;
  }
  .veh-card__price-usd {
    font-family: var(--font-mono);
    font-size: 11px;
    color: rgba(255,255,255,0.45);
    margin-top: 4px;
    letter-spacing: 0.02em;
  }

  /* ── Empty state ── */
  .empty-state {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    padding: 80px 24px;
    text-align: center;
    box-shadow: var(--glass-shadow);
  }
  .empty-state__icon {
    width: 72px; height: 72px;
    border-radius: 50%;
    background: rgba(111,203,163,0.14);
    color: var(--bx-primary);
    border: 1px solid rgba(111,203,163,0.24);
    display: inline-flex; align-items: center; justify-content: center;
    font-size: 32px;
    margin: 0 auto 18px;
  }
  .empty-state h3 {
    font-family: var(--font-sans);
    font-size: 26px; font-weight: 700;
    letter-spacing: -0.022em;
    color: #fff;
  }
  .empty-state h3 em { font-style: normal; color: var(--bx-primary); }
  .empty-state p {
    color: rgba(255,255,255,0.6);
    font-size: 14px;
    margin: 14px auto 26px; max-width: 42ch;
  }
</style>

<div class="page-header-row reveal">
  <div class="page-header" style="margin-bottom:0;">
    <span class="eyebrow">Catalogue results</span>
    <h1>Your <em>match.</em></h1>
    <p>
      Refined fleet, sorted to your preference. Every listing carries verified condition
      notes, transparent LKR pricing, and an optional professional chauffeur.
    </p>
  </div>
  <a href="${pageContext.request.contextPath}/search" class="btn btn-secondary">
    <i class="ti ti-arrow-left"></i> Refine
  </a>
</div>

<!-- ── Results header bar: count + active filter chips + sort dropdown ── -->
<div class="results-bar reveal">
  <div>
    <div class="results-bar__count">
      <strong>${not empty count ? count : 0}</strong>
      vehicle${(count == 1) ? '' : 's'} available
    </div>
    <div class="results-bar__chips">
      <c:if test="${not empty param.keyword}">
        <span class="results-bar__chip"><i class="ti ti-zoom-in"></i> "${param.keyword}"</span>
      </c:if>
      <c:if test="${not empty param.vehicleType}">
        <span class="results-bar__chip"><i class="ti ti-car"></i> ${param.vehicleType}</span>
      </c:if>
      <c:if test="${not empty param.location}">
        <span class="results-bar__chip"><i class="ti ti-map-pin"></i> ${param.location}</span>
      </c:if>
      <c:if test="${not empty param.fuelType}">
        <span class="results-bar__chip"><i class="ti ti-gas-station"></i> ${param.fuelType}</span>
      </c:if>
      <c:if test="${not empty param.transmission}">
        <span class="results-bar__chip"><i class="ti ti-settings"></i> ${param.transmission}</span>
      </c:if>
      <c:if test="${withDriver}">
        <span class="results-bar__chip" style="background:rgba(111,203,163,0.14); border-color:rgba(111,203,163,0.32); color:var(--bx-primary);">
          <i class="ti ti-steering-wheel"></i> With chauffeur
        </span>
      </c:if>
      <c:if test="${not empty param.minPrice or not empty param.maxPrice}">
        <span class="results-bar__chip">
          <i class="ti ti-coin"></i>
          රු ${empty param.minPrice ? '0' : param.minPrice} &mdash; රු ${empty param.maxPrice ? '30,000' : param.maxPrice}
        </span>
      </c:if>
    </div>
  </div>

  <form method="get" action="${pageContext.request.contextPath}/search" class="results-bar__sort" id="sortForm">
    <!-- carry every existing filter into the sort URL -->
    <input type="hidden" name="keyword"      value="${param.keyword}"/>
    <input type="hidden" name="vehicleType"  value="${param.vehicleType}"/>
    <input type="hidden" name="location"     value="${param.location}"/>
    <input type="hidden" name="fuelType"     value="${param.fuelType}"/>
    <input type="hidden" name="transmission" value="${param.transmission}"/>
    <input type="hidden" name="seats"        value="${param.seats}"/>
    <input type="hidden" name="capacity"     value="${param.capacity}"/>
    <input type="hidden" name="minPrice"     value="${param.minPrice}"/>
    <input type="hidden" name="maxPrice"     value="${param.maxPrice}"/>
    <input type="hidden" name="withDriver"   value="${param.withDriver}"/>

    <label for="sortSel">Sort by</label>
    <select id="sortSel" name="sort" onchange="document.getElementById('sortForm').submit()">
      <option value="recommended" ${(empty param.sort or param.sort=='recommended') ? 'selected':''}>Recommended</option>
      <option value="price-asc"   ${param.sort=='price-asc'   ? 'selected':''}>Price: Low to High</option>
      <option value="price-desc"  ${param.sort=='price-desc'  ? 'selected':''}>Price: High to Low</option>
      <option value="newest"      ${param.sort=='newest'      ? 'selected':''}>Newest first</option>
    </select>
  </form>
</div>

<c:choose>
  <c:when test="${not empty results}">
    <div class="gallery">
      <c:forEach var="v" items="${results}" varStatus="loop">
        <div class="veh-card reveal" data-antigravity style="transition-delay:${loop.index * 60}ms;">

          <a class="veh-card__media" href="${pageContext.request.contextPath}/vehicle?action=view&id=${v.id}"
             style="text-decoration:none; color:inherit; display:block;">
            <c:choose>
              <c:when test="${v.available}">
                <span class="veh-card__chip veh-card__chip--available">Available</span>
              </c:when>
              <c:otherwise>
                <span class="veh-card__chip veh-card__chip--unavailable">Unavailable</span>
              </c:otherwise>
            </c:choose>
            <span class="veh-card__chip veh-card__chip--type">${v.type}</span>
            <c:choose>
              <c:when test="${not empty v.imageUrl}">
                <img src="${v.imageUrl}" alt="${v.brand} ${v.model}" loading="lazy" decoding="async" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/images/vehicles/default-vehicle.jpg'"/>
              </c:when>
              <c:otherwise>
                <div style="height:100%;min-height:210px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:8px;background:linear-gradient(135deg,#182331,#0b1118);color:rgba(255,255,255,.58)"><i class="ti ti-car" style="font-size:42px;color:var(--bx-primary)"></i><span>No vehicle photo uploaded</span></div>
              </c:otherwise>
            </c:choose>
          </a>
          <c:if test="${v.available}">
            <button class="veh-card__fav" aria-label="Save" style="position:absolute; top:14px; right:14px; z-index:3;"><i class="ti ti-heart"></i></button>
          </c:if>

          <div class="veh-card__body">
            <div class="veh-card__head">
              <div>
                <a href="${pageContext.request.contextPath}/vehicle?action=view&id=${v.id}"
                   style="text-decoration:none; color:inherit;">
                  <h3 class="veh-card__title">${v.brand} ${v.model}</h3>
                </a>
                <div class="veh-card__sub">${v.year} &nbsp;·&nbsp; Ref. ${v.id}</div>
              </div>
            </div>

            <p class="veh-card__desc">
              <c:choose>
                <c:when test="${v.type == 'Car'}">
                  Comfortable <em>${v.extraField}-seat</em> ride &mdash; perfect for family travel,
                  city commutes and weekend escapes upcountry.
                </c:when>
                <c:when test="${v.type == 'Van'}">
                  Spacious <em>${v.extraField}-passenger</em> van &mdash; group tours, airport
                  transfers, and multi-day island loops.
                </c:when>
                <c:otherwise>
                  Well-maintained ${v.type} &mdash; daily-rate transparent, paperwork minimal.
                </c:otherwise>
              </c:choose>
            </p>

            <div class="veh-card__specs">
              <c:choose>
                <c:when test="${v.type == 'Car'}">
                  <span class="veh-card__spec"><i class="ti ti-users"></i> ${v.extraField} seats</span>
                </c:when>
                <c:when test="${v.type == 'Van'}">
                  <span class="veh-card__spec"><i class="ti ti-truck-loading"></i> ${v.extraField} pax</span>
                </c:when>
              </c:choose>
              <span class="veh-card__spec"><i class="ti ti-gas-station"></i> ${v.fuelType}</span>
              <span class="veh-card__spec"><i class="ti ti-settings"></i> ${v.transmission}</span>
            </div>

            <div class="veh-card__foot">
              <div>
                <div class="veh-card__price-lbl">From</div>
                <div class="veh-card__price-val">
                  <sup>LKR</sup><fmt:formatNumber value="${v.pricePerDay}" pattern="#,##0.00"/>
                  <span class="per">/day</span>
                </div>
                <div class="veh-card__price-usd">&asymp; USD ${v.priceUsd} &nbsp;·&nbsp; no booking fee</div>
              </div>
              <c:choose>
                <c:when test="${v.available}">
                  <a href="${pageContext.request.contextPath}/booking?action=form&vehicleId=${v.id}&dailyRate=${v.pricePerDay}${withDriver ? '&withDriver=true' : ''}"
                     class="btn btn-primary btn-sm" data-antigravity>
                    Reserve
                    <span class="ico-pill"><i class="ti ti-arrow-up-right"></i></span>
                  </a>
                </c:when>
                <c:otherwise>
                  <button class="btn btn-secondary btn-sm" disabled style="opacity:0.5; cursor:not-allowed;">Unavailable</button>
                </c:otherwise>
              </c:choose>
            </div>
          </div>

        </div>
      </c:forEach>
    </div>
  </c:when>
  <c:otherwise>
    <div class="empty-state reveal">
      <div class="empty-state__icon"><i class="ti ti-car-off"></i></div>
      <h3>No vehicles matched <em>these filters.</em></h3>
      <p>Loosen a constraint or two &mdash; widen the price range, clear the keyword, or switch the vehicle type &mdash; and the fleet should reappear.</p>
      <a href="${pageContext.request.contextPath}/search" class="btn btn-primary" data-antigravity>
        Refine the search
        <span class="ico-pill"><i class="ti ti-arrow-right"></i></span>
      </a>
    </div>
  </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
