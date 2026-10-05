<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core"      %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"       %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="pageTitle"   value="Home" scope="request"/>
<c:set var="activePage"  value="home" scope="request"/>
<%@ include file="/WEB-INF/views/common/marketing-header.jsp" %>

<!-- ═══════════════════════════════════════════════════════
     HERO — Premium Kandy/Sri Lanka positioning with chauffeur toggle
     ═══════════════════════════════════════════════════════ -->
<section class="mkt-hero mkt-hero--premium">
  <div class="mkt-hero__inner">

    <div class="reveal">
      <span class="mkt-hero__eyebrow">Kandy · Sri Lanka · Est. 2019</span>
      <h1 class="mkt-hero__title">Rent first class.<br/><em>Pay economy.</em></h1>
      <p class="mkt-hero__lede">
        Self-Drive &nbsp;·&nbsp; Professional Chauffeur &nbsp;·&nbsp; Airport Transfers &nbsp;·&nbsp; Island-Wide Delivery
        <br/>
        <span class="mkt-hero__lede-sub">
          Hand-picked hybrids, SUVs and luxury vans &mdash; transparently priced in LKR,
          delivered to your hotel in under sixty minutes.
        </span>
      </p>

      <!-- Subtle CTAs in hero (search now lives in floating glass strip on scroll) -->
      <div class="mkt-hero__ctas reveal">
        <a href="${pageContext.request.contextPath}/search" class="btn btn-primary btn-lg" data-antigravity>
          Browse the fleet
          <span class="ico-pill"><i class="ti ti-arrow-right"></i></span>
        </a>
        <a href="#how" class="btn btn-glass btn-lg">
          How it works
          <i class="ti ti-arrow-down"></i>
        </a>
      </div>

      <span class="mkt-hero__scroll-hint" aria-hidden="true">
        <i class="ti ti-chevron-down"></i> Scroll to search
      </span>
    </div>

  </div>
</section>

<!-- ═══════════════════════════════════════════════════════
     TRUST BAR — instant credibility for Sri Lanka tourist market
     ═══════════════════════════════════════════════════════ -->
<section class="mkt-trustbar reveal">
  <div class="mkt-trustbar__inner">
    <div class="mkt-trustbar__item">
      <span class="mkt-trustbar__icon"><i class="ti ti-shield-check"></i></span>
      <div>
        <strong>Licensed by DMT</strong>
        <small>Department of Motor Traffic, Sri Lanka</small>
      </div>
    </div>
    <div class="mkt-trustbar__sep"></div>
    <div class="mkt-trustbar__item">
      <span class="mkt-trustbar__icon"><i class="ti ti-umbrella"></i></span>
      <div>
        <strong>Fully Insured</strong>
        <small>Comprehensive cover · zero excess option</small>
      </div>
    </div>
    <div class="mkt-trustbar__sep"></div>
    <div class="mkt-trustbar__item">
      <span class="mkt-trustbar__icon"><i class="ti ti-headset"></i></span>
      <div>
        <strong>24/7 Roadside</strong>
        <small>Avg. callback under 4 min, island-wide</small>
      </div>
    </div>
    <div class="mkt-trustbar__sep"></div>
    <div class="mkt-trustbar__item">
      <span class="mkt-trustbar__icon"><i class="ti ti-users-group"></i></span>
      <div>
        <strong>500+ Happy Travelers</strong>
        <small>4.8 / 5 verified rating, since 2019</small>
      </div>
    </div>
  </div>
</section>

<!-- ═══════════════════════════════════════════════════════
     CHAUFFEUR PACKAGES — Sri Lanka tourist market reality
     ═══════════════════════════════════════════════════════ -->
<section class="mkt-section reveal" id="chauffeur">
  <div class="mkt-section-head">
    <div class="lead">
      <span class="eyebrow">Chauffeur packages</span>
      <h2>Sit back. <em>We'll drive.</em></h2>
      <p>
        English-speaking drivers with 5+ years of island-wide experience &mdash; ready for the
        airport run, a day trip up to Kandy, or a multi-day loop through the hill country.
      </p>
    </div>
    <a href="${pageContext.request.contextPath}/search?withDriver=true" class="btn btn-secondary btn-sm">
      All chauffeured rides <span class="ico-pill"><i class="ti ti-arrow-up-right"></i></span>
    </a>
  </div>

  <div class="chauf-grid">

    <article class="chauf-card" data-antigravity>
      <div class="chauf-card__media">
        <span class="chauf-card__chip"><i class="ti ti-plane-arrival"></i> Airport</span>
        <img src="https://images.pexels.com/photos/2920064/pexels-photo-2920064.jpeg?auto=compress&cs=tinysrgb&w=900" alt="Airport transfer" loading="lazy" decoding="async" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/images/vehicles/default-vehicle.jpg'"/>
      </div>
      <div class="chauf-card__body">
        <h3 class="chauf-card__title">Airport Transfer</h3>
        <p class="chauf-card__desc">
          Meet-and-greet at BIA, luggage handled, direct drop-off to your hotel
          anywhere from Colombo to Kandy.
        </p>
        <ul class="chauf-card__inc">
          <li><i class="ti ti-check"></i> Sedan or Hiace, driver included</li>
          <li><i class="ti ti-check"></i> Flight tracking &mdash; we wait if you're delayed</li>
          <li><i class="ti ti-check"></i> Bottled water, AC, 24/7 dispatch</li>
        </ul>
        <div class="chauf-card__foot">
          <div>
            <div class="chauf-card__price-lbl">From</div>
            <div class="chauf-card__price-val"><sup>LKR</sup>9,500</div>
          </div>
          <a href="${pageContext.request.contextPath}/search?withDriver=true&vehicleType=car"
             class="btn btn-primary btn-sm" data-antigravity>
            Book transfer <span class="ico-pill"><i class="ti ti-arrow-up-right"></i></span>
          </a>
        </div>
      </div>
    </article>

    <article class="chauf-card" data-antigravity>
      <div class="chauf-card__media">
        <span class="chauf-card__chip chauf-card__chip--accent"><i class="ti ti-mountain"></i> Day tour</span>
        <img src="https://images.pexels.com/photos/116675/pexels-photo-116675.jpeg?auto=compress&cs=tinysrgb&w=900" alt="Hill country day tour" loading="lazy" decoding="async" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/images/vehicles/default-vehicle.jpg'"/>
      </div>
      <div class="chauf-card__body">
        <h3 class="chauf-card__title">Hill Country Day Tour</h3>
        <p class="chauf-card__desc">
          12-hour curated drive &mdash; Kandy temple, Peradeniya gardens, tea factory visit,
          stops for the photos that matter.
        </p>
        <ul class="chauf-card__inc">
          <li><i class="ti ti-check"></i> Montero or HiAce, full-day chauffeur</li>
          <li><i class="ti ti-check"></i> 300 km included, fuel + tolls covered</li>
          <li><i class="ti ti-check"></i> Curated stop list, flexible on the day</li>
        </ul>
        <div class="chauf-card__foot">
          <div>
            <div class="chauf-card__price-lbl">From</div>
            <div class="chauf-card__price-val"><sup>LKR</sup>22,500</div>
          </div>
          <a href="${pageContext.request.contextPath}/search?withDriver=true&vehicleType=car&seats=7"
             class="btn btn-primary btn-sm" data-antigravity>
            Book tour <span class="ico-pill"><i class="ti ti-arrow-up-right"></i></span>
          </a>
        </div>
      </div>
    </article>

    <article class="chauf-card" data-antigravity>
      <div class="chauf-card__media">
        <span class="chauf-card__chip"><i class="ti ti-route"></i> Multi-day</span>
        <img src="https://images.pexels.com/photos/1429775/pexels-photo-1429775.jpeg?auto=compress&cs=tinysrgb&w=900" alt="Multi-day island tour" loading="lazy" decoding="async" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/images/vehicles/default-vehicle.jpg'"/>
      </div>
      <div class="chauf-card__body">
        <h3 class="chauf-card__title">5-Day Island Loop</h3>
        <p class="chauf-card__desc">
          Colombo &mdash; Sigiriya &mdash; Kandy &mdash; Ella &mdash; Galle &mdash; Colombo.
          Same driver, same vehicle, every kilometre covered.
        </p>
        <ul class="chauf-card__inc">
          <li><i class="ti ti-check"></i> Premium SUV, dedicated driver</li>
          <li><i class="ti ti-check"></i> Unlimited km, hotel handovers included</li>
          <li><i class="ti ti-check"></i> Custom itinerary &mdash; we suggest, you decide</li>
        </ul>
        <div class="chauf-card__foot">
          <div>
            <div class="chauf-card__price-lbl">From</div>
            <div class="chauf-card__price-val"><sup>LKR</sup>148,000</div>
          </div>
          <a href="${pageContext.request.contextPath}/search?withDriver=true"
             class="btn btn-primary btn-sm" data-antigravity>
            Plan the trip <span class="ico-pill"><i class="ti ti-arrow-up-right"></i></span>
          </a>
        </div>
      </div>
    </article>

  </div>

  <div class="chauf-note">
    <i class="ti ti-info-circle"></i>
    <div>
      <strong>Prefer to drive yourself?</strong>
      Every vehicle in our fleet is available self-drive too &mdash; just tick
      <em>"With Driver"</em> off when you book.
    </div>
  </div>
</section>

<!-- ═══════════════════════════════════════════════════════
     BROWSE BY TYPE
     ═══════════════════════════════════════════════════════ -->
<section class="mkt-section reveal">
  <div class="mkt-section-head">
    <div class="lead">
      <span class="eyebrow">Browse by type</span>
      <h2>Find your <em>vehicle class.</em></h2>
    </div>
    <a href="${pageContext.request.contextPath}/search" class="btn btn-secondary btn-sm">
      View all <span class="ico-pill"><i class="ti ti-arrow-up-right"></i></span>
    </a>
  </div>

  <div class="type-strip">
    <a href="${pageContext.request.contextPath}/search?vehicleType=car&seats=5" class="type-tile">
      <span class="type-tile__icon"><i class="ti ti-car"></i></span>
      <span class="type-tile__label">Sedan</span>
      <span class="type-tile__count">8 listings</span>
    </a>
    <a href="${pageContext.request.contextPath}/search?vehicleType=car&fuelType=Hybrid" class="type-tile">
      <span class="type-tile__icon"><i class="ti ti-battery-charging"></i></span>
      <span class="type-tile__label">Hybrid</span>
      <span class="type-tile__count">8 listings</span>
    </a>
    <a href="${pageContext.request.contextPath}/search?vehicleType=car&seats=7" class="type-tile">
      <span class="type-tile__icon"><i class="ti ti-car-suv"></i></span>
      <span class="type-tile__label">SUV</span>
      <span class="type-tile__count">6 listings</span>
    </a>
    <a href="${pageContext.request.contextPath}/search?vehicleType=van" class="type-tile">
      <span class="type-tile__icon"><i class="ti ti-truck-delivery"></i></span>
      <span class="type-tile__label">Van</span>
      <span class="type-tile__count">6 listings</span>
    </a>
    <a href="${pageContext.request.contextPath}/search?vehicleType=car&seats=4" class="type-tile">
      <span class="type-tile__icon"><i class="ti ti-car"></i></span>
      <span class="type-tile__label">Hatchback</span>
      <span class="type-tile__count">8 listings</span>
    </a>
    <a href="${pageContext.request.contextPath}/search?fuelType=Electric" class="type-tile">
      <span class="type-tile__icon"><i class="ti ti-plug"></i></span>
      <span class="type-tile__label">Electric</span>
      <span class="type-tile__count">6 listings</span>
    </a>
    <a href="${pageContext.request.contextPath}/search" class="type-tile">
      <span class="type-tile__icon"><i class="ti ti-grid-dots"></i></span>
      <span class="type-tile__label">All</span>
      <span class="type-tile__count">50 total</span>
    </a>
  </div>
</section>

<!-- ═══════════════════════════════════════════════════════
     FEATURED LISTINGS — Boxcar carousel with real photos
     ═══════════════════════════════════════════════════════ -->
<section class="mkt-section--alt reveal" id="locations">
  <div class="mkt-section-inner">
    <div class="mkt-section-head">
      <div class="lead">
        <span class="eyebrow">Featured listings</span>
        <h2>Currently <em>on the floor.</em></h2>
        <p>The most-reserved vehicles this week. Real photos, real prices, real availability.</p>
      </div>
      <div class="feat-tabs" id="featTabs">
        <button type="button" class="feat-tab is-active" data-filter="all">All</button>
        <button type="button" class="feat-tab" data-filter="new">New arrivals</button>
        <button type="button" class="feat-tab" data-filter="popular">Most reserved</button>
      </div>
    </div>

    <c:choose>
      <c:when test="${not empty featuredVehicles}">

        <div class="feat-rail" id="featRail">
          <c:forEach var="v" items="${featuredVehicles}" varStatus="loop">
            <c:set var="cat"    value="${v.displayCategory}"/>
            <c:set var="isNew"  value="${v.year ge 2023}"/>
            <c:set var="featFlags" value="all${isNew ? ' new' : ''}${loop.index lt 3 ? ' popular' : ''}"/>

            <article class="feat-card" data-feat="${featFlags}">
              <div class="feat-card__media">
                <c:choose>
                  <c:when test="${isNew}">
                    <span class="feat-card__chip">New arrival</span>
                  </c:when>
                  <c:when test="${cat eq 'Electric'}">
                    <span class="feat-card__chip feat-card__chip--clay">EV</span>
                  </c:when>
                  <c:when test="${cat eq 'Hybrid'}">
                    <span class="feat-card__chip feat-card__chip--clay">Hybrid pick</span>
                  </c:when>
                  <c:when test="${loop.index lt 3}">
                    <span class="feat-card__chip">Popular</span>
                  </c:when>
                </c:choose>
                <button class="feat-card__fav" aria-label="Save"><i class="ti ti-heart"></i></button>
                <img src="${v.imageUrl}" alt="${v.brand} ${v.model}" loading="lazy" decoding="async" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/images/vehicles/default-vehicle.jpg'"
                    />
              </div>
              <div class="feat-card__body">
                <h3 class="feat-card__title">${v.brand} ${v.model}</h3>
                <div class="feat-card__sub">${v.year} &middot; ${cat} &middot; Ref. ${v.vehicleId}</div>
                <div class="feat-card__specs">
                  <span class="feat-card__spec"><i class="ti ti-calendar"></i> ${v.year}</span>
                  <c:choose>
                    <c:when test="${v.vehicleType eq 'Van'}">
                      <span class="feat-card__spec"><i class="ti ti-box"></i> <fmt:formatNumber value="${v.extraField}" pattern="#,##0"/> kg</span>
                      <span class="feat-card__spec"><i class="ti ti-truck-delivery"></i> ${cat}</span>
                    </c:when>
                    <c:otherwise>
                      <span class="feat-card__spec"><i class="ti ti-users"></i> ${v.extraField} seats</span>
                      <c:choose>
                        <c:when test="${cat eq 'Electric'}">
                          <span class="feat-card__spec"><i class="ti ti-plug"></i> Electric</span>
                        </c:when>
                        <c:when test="${cat eq 'Hybrid'}">
                          <span class="feat-card__spec"><i class="ti ti-leaf"></i> Hybrid</span>
                        </c:when>
                        <c:otherwise>
                          <span class="feat-card__spec"><i class="ti ti-car"></i> ${cat}</span>
                        </c:otherwise>
                      </c:choose>
                    </c:otherwise>
                  </c:choose>
                </div>
                <div class="feat-card__foot">
                  <div>
                    <div class="feat-card__price-lbl">From</div>
                    <div class="feat-card__price-val"><sup>LKR</sup><fmt:formatNumber value="${v.rentalPricePerDay}" pattern="#,##0"/><span class="per">/day</span></div>
                  </div>
                  <a href="${pageContext.request.contextPath}/booking?action=form&vehicleId=${v.vehicleId}&dailyRate=${v.rentalPricePerDay}"
                     class="btn btn-secondary btn-sm">
                    Reserve <span class="ico-pill"><i class="ti ti-arrow-up-right"></i></span>
                  </a>
                </div>
              </div>
            </article>
          </c:forEach>
        </div>

        <div style="display:flex; justify-content:flex-end; gap:8px; margin-top:8px;">
          <button class="btn btn-secondary btn-icon" type="button"
                  aria-label="Scroll left"
                  onclick="document.getElementById('featRail').scrollBy({left: -348, behavior:'smooth'})">
            <i class="ti ti-arrow-left"></i>
          </button>
          <button class="btn btn-secondary btn-icon" type="button"
                  aria-label="Scroll right"
                  onclick="document.getElementById('featRail').scrollBy({left: 348, behavior:'smooth'})">
            <i class="ti ti-arrow-right"></i>
          </button>
        </div>

      </c:when>
      <c:otherwise>
        <!-- Defensive: if MSSQL vehicles is empty or unreadable, the rail collapses cleanly -->
        <div class="testi-empty" style="margin-top:24px;">
          <i class="ti ti-car-off"></i>
          <p>No vehicles on the floor right now &mdash; check back shortly.</p>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

  <script>
    /* Wire the All / New arrivals / Most reserved tabs to filter cards in-place.
       data-feat is a space-separated list of tags each card matches. */
    (function() {
      var tabs = document.querySelectorAll('#featTabs .feat-tab');
      var rail = document.getElementById('featRail');
      if (!rail) return;
      var cards = rail.querySelectorAll('.feat-card');
      tabs.forEach(function(tab) {
        tab.addEventListener('click', function() {
          var filter = tab.getAttribute('data-filter');
          tabs.forEach(function(t) { t.classList.remove('is-active'); });
          tab.classList.add('is-active');
          cards.forEach(function(card) {
            var flags = (card.getAttribute('data-feat') || '').split(/\s+/);
            card.style.display = flags.indexOf(filter) !== -1 ? '' : 'none';
          });
          rail.scrollTo({ left: 0, behavior: 'smooth' });
        });
      });
    })();
  </script>
</section>

<!-- ═══════════════════════════════════════════════════════
     PREMIUM BRANDS
     ═══════════════════════════════════════════════════════ -->
<section class="mkt-section reveal">
  <div class="mkt-section-head">
    <div class="lead">
      <span class="eyebrow">Marques on the floor</span>
      <h2>Premium <em>brands.</em></h2>
      <p>From every-day workhorses to weekend touring &mdash; nine marques curated and serviced in-house.</p>
    </div>
    <span class="meta">[ 9 / 9 ]</span>
  </div>

  <div class="brand-grid">
    <a href="${pageContext.request.contextPath}/search?keyword=Toyota" class="brand-cell">
      <span class="brand-name">Toyota</span>
      <span class="brand-meta">Aqua · Prius · Land Cruiser · HiAce</span>
    </a>
    <a href="${pageContext.request.contextPath}/search?keyword=Honda" class="brand-cell">
      <span class="brand-name">Honda</span>
      <span class="brand-meta">Vezel · Civic · Fit · CB150R</span>
    </a>
    <a href="${pageContext.request.contextPath}/search?keyword=Mitsubishi" class="brand-cell">
      <span class="brand-name">Mitsubishi</span>
      <span class="brand-meta">Montero · Pajero Sport · Rosa</span>
    </a>
    <a href="${pageContext.request.contextPath}/search?keyword=Suzuki" class="brand-cell">
      <span class="brand-name">Suzuki</span>
      <span class="brand-meta">Wagon R · Swift · Alto</span>
    </a>
    <a href="${pageContext.request.contextPath}/search?keyword=Nissan" class="brand-cell">
      <span class="brand-name">Nissan</span>
      <span class="brand-meta">Sunny · Leaf · Caravan</span>
    </a>
    <a href="${pageContext.request.contextPath}/search?keyword=Mercedes" class="brand-cell">
      <span class="brand-name">Mercedes</span>
      <span class="brand-meta">C-Class · Sprinter</span>
    </a>
    <a href="${pageContext.request.contextPath}/search?keyword=Hyundai" class="brand-cell">
      <span class="brand-name">Hyundai</span>
      <span class="brand-meta">Santa Fe · Kona EV · Grand i10</span>
    </a>
    <a href="${pageContext.request.contextPath}/search?keyword=Yamaha" class="brand-cell">
      <span class="brand-name">Yamaha</span>
      <span class="brand-meta">FZ · R15</span>
    </a>
    <a href="${pageContext.request.contextPath}/search" class="brand-cell">
      <span class="brand-name" style="color:var(--bx-primary);">All marques &rarr;</span>
      <span class="brand-meta">View the full roster</span>
    </a>
  </div>
</section>

<!-- ═══════════════════════════════════════════════════════
     WHY US — features grid + stats strip
     ═══════════════════════════════════════════════════════ -->
<section class="mkt-section--alt reveal">
  <div class="mkt-section-inner">
    <div class="mkt-section-head">
      <div class="lead">
        <span class="eyebrow">Why RideLanka FleetHire</span>
        <h2>We're <em>big</em> on what matters to you.</h2>
        <p>Three quiet promises &mdash; engineered into every reservation, on and off the road.</p>
      </div>
      <span class="meta">[ 01 / 02 / 03 ]</span>
    </div>

    <div class="feat-grid">

      <div class="feat-block feat-block--lg">
        <span class="feat-block__icon"><i class="ti ti-bolt"></i></span>
        <span class="feat-block__num">01 — Speed</span>
        <h3 class="feat-block__title">Confirmed in under <em>sixty seconds.</em></h3>
        <p class="feat-block__desc">
          Real-time availability across the entire fleet. Every reservation
          lands instantly with the host &mdash; no callback, no morning-after
          surprises.
        </p>
        <div style="margin-top:18px;">
          <a href="${pageContext.request.contextPath}/search" class="btn btn-primary btn-sm">
            See the live fleet
            <span class="ico-pill"><i class="ti ti-arrow-up-right"></i></span>
          </a>
        </div>
      </div>

      <div class="feat-block">
        <span class="feat-block__icon" style="background:var(--bx-success-soft); color:var(--bx-success-ink);">
          <i class="ti ti-coin"></i>
        </span>
        <span class="feat-block__num">02 — Pricing</span>
        <h3 class="feat-block__title">Transparent <em>in LKR.</em></h3>
        <p class="feat-block__desc">
          Daily rates are posted up front, and eligible promo codes are validated at checkout against the database.
        </p>
      </div>

      <div class="feat-block">
        <span class="feat-block__icon" style="background:var(--bx-warning-soft); color:var(--bx-warning-ink);">
          <i class="ti ti-shield-check"></i>
        </span>
        <span class="feat-block__num">03 — Trust</span>
        <h3 class="feat-block__title">Verified <em>signal only.</em></h3>
        <p class="feat-block__desc">
          Every review is tethered to a completed booking. No fake stars
          &mdash; only voices from drivers who finished the trip.
        </p>
      </div>

    </div>

    <div class="mkt-stats">
      <div class="mkt-stat">
        <div class="mkt-stat__val">50</div>
        <div class="mkt-stat__lbl">Vehicles on the floor</div>
        <div class="mkt-stat__sub">sedan · hybrid · SUV · hatchback · electric · van</div>
      </div>
      <div class="mkt-stat">
        <div class="mkt-stat__val">8</div>
        <div class="mkt-stat__lbl">Pickup cities</div>
        <div class="mkt-stat__sub">Colombo · Galle · Kandy · Ella…</div>
      </div>
      <div class="mkt-stat">
        <div class="mkt-stat__val">24<sup>/7</sup></div>
        <div class="mkt-stat__lbl">Roadside support</div>
        <div class="mkt-stat__sub">avg. callback under 4 min</div>
      </div>
      <div class="mkt-stat">
        <div class="mkt-stat__val">4.8</div>
        <div class="mkt-stat__lbl">Verified rating</div>
        <div class="mkt-stat__sub">2,470 finished reviews</div>
      </div>
    </div>
  </div>
</section>

<!-- ═══════════════════════════════════════════════════════
     TESTIMONIALS — pulled live from MSSQL feedback
     ═══════════════════════════════════════════════════════ -->
<section class="mkt-section reveal" id="testimonials">
  <div class="mkt-section-head">
    <div class="lead">
      <span class="eyebrow">In their words</span>
      <h2>Drivers who <em>finished the trip.</em></h2>
      <p>Every quote here is tied to an approved review on a completed reservation &mdash; no invitations, no edits.</p>
    </div>
    <div class="testi-head">
      <div class="testi-rating">
        <fmt:formatNumber value="${avgRating > 0 ? avgRating : 4.8}" pattern="#0.0"/><sup>/5</sup>
      </div>
      <div class="testi-meta">
        <div class="stars">★★★★★</div>
        <div class="label">
          <c:choose>
            <c:when test="${reviewCount > 0}">${reviewCount} verified review${reviewCount == 1 ? '' : 's'}</c:when>
            <c:otherwise>2,470 verified reviews</c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>
  </div>

  <c:choose>
    <c:when test="${not empty featuredReviews}">

      <div class="testi-rail" id="testiRail">
        <c:forEach var="r" items="${featuredReviews}" varStatus="loop">
          <article class="testi-card" data-antigravity>
            <div class="testi-card__stars">${r.starString}</div>
            <p class="testi-card__body">${r.comment}</p>
            <div class="testi-card__author">
              <div class="testi-card__avatar">
                <span>${fn:toUpperCase(fn:substring(r.username, 0, 1))}</span>
              </div>
              <div>
                <div class="testi-card__name">${r.username}</div>
                <div class="testi-card__role">
                  <c:choose>
                    <c:when test="${r.reviewType == 'verified'}">
                      <i class="ti ti-circle-check" style="color:var(--bx-primary); font-size:13px; vertical-align:-1px;"></i>
                      Verified rental &middot; ${r.reviewDate}
                    </c:when>
                    <c:otherwise>${r.reviewDate}</c:otherwise>
                  </c:choose>
                </div>
              </div>
            </div>
          </article>
        </c:forEach>
      </div>

      <div style="display:flex; justify-content:flex-end; gap:8px; margin-top:14px;">
        <button class="btn btn-secondary btn-icon" type="button"
                aria-label="Previous review"
                onclick="document.getElementById('testiRail').scrollBy({left: -360, behavior:'smooth'})">
          <i class="ti ti-arrow-left"></i>
        </button>
        <button class="btn btn-secondary btn-icon" type="button"
                aria-label="Next review"
                onclick="document.getElementById('testiRail').scrollBy({left: 360, behavior:'smooth'})">
          <i class="ti ti-arrow-right"></i>
        </button>
      </div>

    </c:when>
    <c:otherwise>
      <!-- Fallback when no approved reviews exist yet -->
      <div class="testi-empty">
        <i class="ti ti-quote"></i>
        <p>Be the first to review a vehicle &mdash; verified reviews appear here automatically once approved.</p>
      </div>
    </c:otherwise>
  </c:choose>
</section>

<!-- ═══════════════════════════════════════════════════════
     STORIES — blog posts with real imagery
     ═══════════════════════════════════════════════════════ -->
<section class="mkt-section--alt reveal" id="stories">
  <div class="mkt-section-inner">
    <div class="mkt-section-head">
      <div class="lead">
        <span class="eyebrow">Stories from the road</span>
        <h2>From the <em>RideLanka FleetHire blog.</em></h2>
        <p>Routes worth driving, vehicles worth booking, and what we've learned curating both.</p>
      </div>
      <a href="#" class="btn btn-secondary btn-sm">
        All stories <span class="ico-pill"><i class="ti ti-arrow-up-right"></i></span>
      </a>
    </div>

    <div class="story-grid">

      <a href="#" class="story-card">
        <div class="story-card__media">
          <img src="https://images.pexels.com/photos/1118447/pexels-photo-1118447.jpeg?auto=compress&cs=tinysrgb&w=800" alt="Mountain road" loading="lazy" decoding="async" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/images/vehicles/default-vehicle.jpg'"/>
        </div>
        <div class="story-card__body">
          <span class="story-card__cat">ROUTES</span>
          <span class="story-card__meta">M. de Silva &nbsp;·&nbsp; 12 May 2026</span>
          <h3 class="story-card__title">The five-day loop &mdash; Colombo to Ella, slowly.</h3>
        </div>
      </a>

      <a href="#" class="story-card">
        <div class="story-card__media">
          <img src="https://images.pexels.com/photos/3786091/pexels-photo-3786091.jpeg?auto=compress&cs=tinysrgb&w=800" alt="Hybrid car" loading="lazy" decoding="async" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/images/vehicles/default-vehicle.jpg'"/>
        </div>
        <div class="story-card__body">
          <span class="story-card__cat">HYBRID</span>
          <span class="story-card__meta">R. Pathirana &nbsp;·&nbsp; 03 May 2026</span>
          <h3 class="story-card__title">Aqua vs. Vezel &mdash; which hybrid for the wet zone?</h3>
        </div>
      </a>

      <a href="#" class="story-card">
        <div class="story-card__media">
          <img src="https://images.pexels.com/photos/210600/pexels-photo-210600.jpeg?auto=compress&cs=tinysrgb&w=800" alt="Promotions and savings" loading="lazy" decoding="async" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/images/vehicles/default-vehicle.jpg'"/>
        </div>
        <div class="story-card__body">
          <span class="story-card__cat">PROMOTIONS</span>
          <span class="story-card__meta">A. Kumarasinghe &nbsp;·&nbsp; 21 Apr 2026</span>
          <h3 class="story-card__title">How RideLanka FleetHire promotion codes work at checkout.</h3>
        </div>
      </a>

    </div>
  </div>
</section>

<!-- ═══════════════════════════════════════════════════════
     NEWSLETTER — split poster + form (Boxcar style)
     ═══════════════════════════════════════════════════════ -->
<section class="mkt-section reveal">
  <div class="news-split">

    <div class="news-poster">
      <span class="news-poster__eyebrow">RideLanka FleetHire Mailings</span>
      <div>
        <h2 class="news-poster__title">Quiet briefings,<br/><em>once a month.</em></h2>
        <p class="news-poster__sub">
          New arrivals, off-season offers, and routes worth driving.
          No pestering. Unsubscribe in one click.
        </p>
      </div>
      <div style="font-family:var(--font-mono); font-size:11px; color:rgba(255,255,255,0.45);">
        [ Avg. 1 email / month ]
      </div>
    </div>

    <div class="news-form">
      <h3>Subscribe &mdash;<br/><em>get on the list.</em></h3>
      <p>Pop your email below. We'll send the first briefing on the next pickup window.</p>
      <form onsubmit="event.preventDefault(); alert('Subscribed — thank you.');">
        <div class="news-input-wrap">
          <input type="email" placeholder="kamal@example.com" required/>
          <button type="submit" class="btn btn-primary">
            Subscribe
            <span class="ico-pill"><i class="ti ti-arrow-right"></i></span>
          </button>
        </div>
        <div class="news-foot">
          By subscribing you agree to our terms. No spam, ever.
        </div>
      </form>
    </div>

  </div>
</section>

<%@ include file="/WEB-INF/views/common/marketing-footer.jsp" %>
