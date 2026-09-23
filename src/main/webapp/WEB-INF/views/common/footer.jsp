    </main>
  </div><!-- end vrms-main -->
</div><!-- end vrms-shell -->

<script>
  // Highlight active nav item based on current path
  (function() {
    var path = window.location.pathname;
    document.querySelectorAll('.nav-item').forEach(function(el) {
      var href = el.getAttribute('href');
      if (href && path.startsWith(href) && href !== '/') {
        el.classList.add('active');
      }
    });
  })();

  // Scroll-reveal — premium IntersectionObserver pattern, no library
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
    }, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });
    document.querySelectorAll('.reveal').forEach(function(el) { io.observe(el); });
  })();
</script>

</body>
</html>
