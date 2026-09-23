<%--
  Reusable notification bell — included by both the marketing header (public-facing)
  and the dashboard header (signed-in app shell). Renders nothing when the visitor
  is not logged in, so it is safe to drop into any layout.

  Required EL: ${pageContext.request.contextPath} (always present in JSP).
  Polls /notifications/unread-count every 30s; refetches the full list on open.
--%>
<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:if test="${not empty sessionScope.loggedUser}">
  <div class="vrms-bell" id="vrmsBell" data-ctx="${pageContext.request.contextPath}">
    <button class="vrms-bell__btn" type="button"
            aria-label="Notifications" aria-expanded="false"
            id="vrmsBellBtn">
      <i class="ti ti-bell"></i>
      <span class="vrms-bell__badge" id="vrmsBellBadge" hidden>0</span>
    </button>
    <div class="vrms-bell__panel" id="vrmsBellPanel" role="dialog" aria-label="Notifications" hidden>
      <div class="vrms-bell__head">
        <strong>Notifications</strong>
        <button type="button" class="vrms-bell__readall" id="vrmsBellReadAll">
          <i class="ti ti-checks"></i> Mark all read
        </button>
      </div>
      <div class="vrms-bell__list" id="vrmsBellList">
        <div class="vrms-bell__empty">
          <i class="ti ti-loader-2 vrms-bell__spin"></i> Loading...
        </div>
      </div>
    </div>
  </div>

  <script>
    /* Bell controller — vanilla JS, no framework. Polls unread count every 30s,
       refetches the full list when the user opens the dropdown. */
    (function () {
      var root  = document.getElementById('vrmsBell');
      if (!root || root.dataset.wired === '1') return;
      root.dataset.wired = '1';

      var ctx       = root.dataset.ctx || '';
      var btn       = document.getElementById('vrmsBellBtn');
      var panel     = document.getElementById('vrmsBellPanel');
      var badge     = document.getElementById('vrmsBellBadge');
      var list      = document.getElementById('vrmsBellList');
      var readAllBtn= document.getElementById('vrmsBellReadAll');

      function escapeHtml(s) {
        return String(s == null ? '' : s)
          .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
      }

      function setBadge(n) {
        if (n > 0) {
          badge.hidden = false;
          badge.textContent = n > 99 ? '99+' : String(n);
          btn.classList.add('has-unread');
        } else {
          badge.hidden = true;
          badge.textContent = '0';
          btn.classList.remove('has-unread');
        }
      }

      function renderList(rows) {
        if (!rows || rows.length === 0) {
          list.innerHTML = '<div class="vrms-bell__empty">'
            + '<i class="ti ti-mail-opened"></i><span>You are all caught up.</span>'
            + '</div>';
          return;
        }
        var html = '';
        for (var i = 0; i < rows.length; i++) {
          var r = rows[i];
          var cls = 'vrms-bell__item' + (r.read ? '' : ' is-unread');
          var href = r.href && r.href !== '#' ? ctx + r.href : '#';
          html += '<a class="' + cls + '" href="' + escapeHtml(href) + '" '
                + 'data-id="' + escapeHtml(r.id) + '" data-href="' + escapeHtml(href) + '">'
                + '<span class="vrms-bell__ico"><i class="' + escapeHtml(r.icon) + '"></i></span>'
                + '<span class="vrms-bell__body">'
                +   '<span class="vrms-bell__title">' + escapeHtml(r.title) + '</span>'
                +   '<span class="vrms-bell__msg">'   + escapeHtml(r.message) + '</span>'
                +   '<span class="vrms-bell__time">'  + escapeHtml(r.createdAt) + '</span>'
                + '</span>'
                + '</a>';
        }
        list.innerHTML = html;

        // Wire row clicks — mark read then navigate.
        list.querySelectorAll('.vrms-bell__item').forEach(function (a) {
          a.addEventListener('click', function (ev) {
            ev.preventDefault();
            var id = a.getAttribute('data-id');
            var href = a.getAttribute('data-href');
            fetch(ctx + '/notifications/read?id=' + encodeURIComponent(id), {
              method: 'POST',
              credentials: 'same-origin'
            }).finally(function () {
              if (href && href !== '#') {
                window.location.href = href;
              } else {
                a.classList.remove('is-unread');
                refreshCount();
              }
            });
          });
        });
      }

      function refreshList() {
        fetch(ctx + '/notifications', { credentials: 'same-origin' })
          .then(function (r) { return r.ok ? r.json() : null; })
          .then(function (data) {
            if (!data || data.unauthorized) { setBadge(0); list.innerHTML = ''; return; }
            setBadge(data.unreadCount || 0);
            renderList(data.notifications || []);
          })
          .catch(function () {
            list.innerHTML = '<div class="vrms-bell__empty">Could not load notifications.</div>';
          });
      }

      function refreshCount() {
        fetch(ctx + '/notifications/unread-count', { credentials: 'same-origin' })
          .then(function (r) { return r.ok ? r.json() : null; })
          .then(function (data) {
            if (!data) return;
            setBadge(data.unreadCount || 0);
          })
          .catch(function () { /* keep last value */ });
      }

      function togglePanel(forceClose) {
        var open = !panel.hidden && !forceClose;
        if (open) {
          panel.hidden = true;
          btn.setAttribute('aria-expanded', 'false');
        } else if (!forceClose) {
          panel.hidden = false;
          btn.setAttribute('aria-expanded', 'true');
          refreshList();
        }
      }

      btn.addEventListener('click', function (ev) {
        ev.stopPropagation();
        togglePanel(false);
      });

      // Click outside to close.
      document.addEventListener('click', function (ev) {
        if (panel.hidden) return;
        if (root.contains(ev.target)) return;
        panel.hidden = true;
        btn.setAttribute('aria-expanded', 'false');
      });

      // Esc to close.
      document.addEventListener('keydown', function (ev) {
        if (ev.key === 'Escape' && !panel.hidden) {
          panel.hidden = true;
          btn.setAttribute('aria-expanded', 'false');
          btn.focus();
        }
      });

      readAllBtn.addEventListener('click', function () {
        fetch(ctx + '/notifications/read-all', {
          method: 'POST',
          credentials: 'same-origin'
        }).finally(function () { refreshList(); });
      });

      // Initial badge + 30-second poll.
      refreshCount();
      setInterval(refreshCount, 30000);
    })();
  </script>
</c:if>
