  </main>

  <!-- ═══ Multi-column footer ═══ -->
  <footer class="mkt-foot" id="contact">
    <div class="mkt-foot__inner">

      <a href="${pageContext.request.contextPath}/" class="mkt-foot__brand"
         style="text-decoration:none; color:inherit;" aria-label="VRMS home">
        <img src="${pageContext.request.contextPath}/images/vrms-logo.png"
             alt="VRMS — Vehicle Rental" class="mkt-foot__brand-img"/>
        <div class="mkt-foot__brand-text">
          <span class="brand">VRMS</span>
          <small>&mdash; Vehicle Rental &mdash;</small>
        </div>
      </a>

      <div class="mkt-foot__cols">

        <div class="mkt-foot__col">
          <p class="mkt-foot__intro">
            A considered fleet,<br/>
            booked in <em>under a minute.</em>
          </p>
          <div class="mkt-foot__contact">
            <span><strong>Head office · Colombo 03</strong></span>
            <span>23 Sir Baron Jayatilaka Mawatha</span>
            <span style="margin-top:10px;">Mon &mdash; Sun · 06:00 to 22:00</span>
            <span class="mono" style="font-family:var(--font-mono); font-size:12px; margin-top:6px;">+94 77 811 9913</span>
          </div>
          <div class="mkt-foot__socials">
            <a href="#" aria-label="Instagram"><i class="ti ti-brand-instagram"></i></a>
            <a href="#" aria-label="X"><i class="ti ti-brand-x"></i></a>
            <a href="#" aria-label="LinkedIn"><i class="ti ti-brand-linkedin"></i></a>
            <a href="#" aria-label="Email"><i class="ti ti-mail"></i></a>
          </div>
        </div>

        <div class="mkt-foot__col">
          <h5>Useful Links</h5>
          <ul>
            <li><a href="#">About us</a></li>
            <li><a href="#">Careers</a></li>
            <li><a href="${pageContext.request.contextPath}/policies">Rental Policies</a></li>
            <li><a href="#">FAQs</a></li>
            <li><a href="#">Finance</a></li>
            <li><a href="#contact">Contact</a></li>
          </ul>
        </div>

        <div class="mkt-foot__col">
          <h5>Quick Links</h5>
          <ul>
            <li><a href="${pageContext.request.contextPath}/search">Browse inventory</a></li>
            <li><a href="${pageContext.request.contextPath}/booking?action=form">Reservations</a></li>
            <li><a href="${pageContext.request.contextPath}/booking?action=list">My bookings</a></li>
            <li><a href="${pageContext.request.contextPath}/review/submit">Reviews</a></li>
            <li><a href="#">Help center</a></li>
            <li><a href="#">Live chat</a></li>
          </ul>
        </div>

        <div class="mkt-foot__col">
          <h5>Vehicle Types</h5>
          <ul>
            <li><a href="${pageContext.request.contextPath}/search?vehicleType=car&fuelType=Hybrid">Hybrid</a></li>
            <li><a href="${pageContext.request.contextPath}/search?vehicleType=car&seats=5">Sedan</a></li>
            <li><a href="${pageContext.request.contextPath}/search?vehicleType=car&seats=7">SUV</a></li>
            <li><a href="${pageContext.request.contextPath}/search?vehicleType=van">Van &amp; MPV</a></li>
            
            <li><a href="${pageContext.request.contextPath}/search?fuelType=Electric">Electric</a></li>
          </ul>
        </div>

        <div class="mkt-foot__col">
          <h5>Pickup Cities</h5>
          <ul>
            <li><a href="#">Colombo</a></li>
            <li><a href="#">Kandy</a></li>
            <li><a href="#">Galle</a></li>
            <li><a href="#">Negombo</a></li>
            <li><a href="#">Nuwara Eliya</a></li>
            <li><a href="#">Ella</a></li>
          </ul>
        </div>

      </div>

      <div class="mkt-foot__bar">
        <span>© 2026 VRMS — Vehicle Rental Management System. All rights reserved.</span>
        <div>
          <a href="${pageContext.request.contextPath}/policies">Rental Policies</a>
          <a href="#">Terms &amp; Conditions</a>
          <a href="#">Privacy Notice</a>
          <a href="#">Cookies</a>
        </div>
      </div>

    </div>
  </footer>

</div><!-- /mkt-shell -->

<script>
  // Scroll-reveal — IntersectionObserver, no library
  (function() {
    if (!('IntersectionObserver' in window)) {
      document.querySelectorAll('.reveal').forEach(function(el) { el.classList.add('visible'); });
      return;
    }
    var io = new IntersectionObserver(function(entries) {
      entries.forEach(function(e) {
        if (e.isIntersecting) {
          e.target.classList.add('visible');
          io.unobserve(e.target);
        }
      });
    }, { threshold: 0.08, rootMargin: '0px 0px -40px 0px' });
    document.querySelectorAll('.reveal').forEach(function(el) { io.observe(el); });
  })();

  // Floating glass search-strip + glass-nav toggle — appears once user scrolls past hero
  (function() {
    var floatSearch = document.getElementById('mktFloatSearch');
    var nav = document.querySelector('.mkt-nav');
    if (!floatSearch && !nav) return;
    var trigger = 220; // px scrolled before strip/nav glass kicks in
    var ticking = false;
    function update() {
      var y = window.scrollY || window.pageYOffset;
      var on = y > trigger;
      if (floatSearch) {
        floatSearch.classList.toggle('is-visible', on);
        floatSearch.setAttribute('aria-hidden', on ? 'false' : 'true');
      }
      if (nav) nav.classList.toggle('is-scrolled', on);
      ticking = false;
    }
    window.addEventListener('scroll', function() {
      if (!ticking) { window.requestAnimationFrame(update); ticking = true; }
    }, { passive: true });
    update();
  })();
</script>

</body>
</html>
