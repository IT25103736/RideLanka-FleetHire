<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>${pageTitle != null ? pageTitle : 'VRMS'} — Vehicle Rental</title>

  <link rel="preconnect" href="https://fonts.googleapis.com"/>
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Bebas+Neue&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/vrms-theme.css"/>
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4"></script>
  <script>
    (function () {
      if (!window.Chart) return;
      Chart.defaults.color = 'rgba(255,255,255,0.65)';
      Chart.defaults.borderColor = 'rgba(255,255,255,0.08)';
      Chart.defaults.font.family = "'DM Sans', system-ui, sans-serif";
      window.VRMS_CHART = {
        primary: '#6FCBA3',
        primarySoft: 'rgba(111,203,163,0.18)',
        info: '#7DD3FC',
        warn: '#FBBF24',
        danger: '#F87171',
        gridColor: 'rgba(255,255,255,0.06)'
      };
    })();
  </script>
</head>
<body>
<div class="vrms-shell">

  <!-- ═══════════════════════════════════════════════════════
       SIDEBAR — Editorial Luxury (espresso plate)
       ═══════════════════════════════════════════════════════ -->
  <aside class="vrms-sidebar">

    <a href="${pageContext.request.contextPath}/" class="sidebar-logo"
       style="text-decoration:none; color:inherit;"
       aria-label="VRMS home">
      <img src="${pageContext.request.contextPath}/images/vrms-logo.png"
           alt="VRMS — Vehicle Rental" class="sidebar-logo__img"/>
      <div class="logo-text">
        <span class="brand">VRMS</span>
        <small>&mdash; Vehicle Rental &mdash;</small>
      </div>
    </a>

    <div class="nav-section">Browse</div>

    <a href="${pageContext.request.contextPath}/"
       class="nav-item ${activePage == 'home' ? 'active' : ''}">
      <i class="ti ti-home" aria-hidden="true"></i> Home
    </a>

    <a href="${pageContext.request.contextPath}/dashboard"
       class="nav-item ${activePage == 'dashboard' ? 'active' : ''}">
      <i class="ti ti-layout-grid" aria-hidden="true"></i> Dashboard
    </a>

    <a href="${pageContext.request.contextPath}/search"
       class="nav-item ${activePage == 'search' ? 'active' : ''}">
      <i class="ti ti-zoom-in" aria-hidden="true"></i> Search Vehicle
    </a>

    <a href="${pageContext.request.contextPath}/booking?action=form"
       class="nav-item ${activePage == 'booking' ? 'active' : ''}">
      <i class="ti ti-calendar-event" aria-hidden="true"></i> New Reservation
    </a>

    <c:if test="${not empty sessionScope.loggedUser}">
      <c:if test="${sessionScope.loggedUser.role == 'CUSTOMER'}">
        <a href="${pageContext.request.contextPath}/booking?action=list"
           class="nav-item ${activePage == 'mybookings' ? 'active' : ''}">
          <i class="ti ti-bookmark" aria-hidden="true"></i> My Bookings
        </a>
      </c:if>

      <div class="nav-section">Account</div>

      <a href="${pageContext.request.contextPath}/profile"
         class="nav-item ${activePage == 'profile' ? 'active' : ''}">
        <i class="ti ti-user-circle" aria-hidden="true"></i> Profile
      </a>

      <c:if test="${sessionScope.loggedUser.role == 'CUSTOMER'}">
        <a href="${pageContext.request.contextPath}/review/submit"
           class="nav-item ${activePage == 'review' ? 'active' : ''}">
          <i class="ti ti-star" aria-hidden="true"></i> Reviews
        </a>

        <a href="${pageContext.request.contextPath}/payment/history"
           class="nav-item ${activePage == 'payment' ? 'active' : ''}">
          <i class="ti ti-wallet" aria-hidden="true"></i> Payments
        </a>
      </c:if>
    </c:if>

    <c:if test="${not empty sessionScope.loggedUser && (sessionScope.loggedUser.role == 'ADMIN' || sessionScope.loggedUser.role == 'VEHICLE' || sessionScope.loggedUser.role == 'MAINTENANCE' || sessionScope.loggedUser.role == 'FLEET')}">
      <div class="nav-section">Operations</div>

      <c:if test="${sessionScope.loggedUser.role == 'ADMIN' || sessionScope.loggedUser.role == 'VEHICLE'}">
        <a href="${pageContext.request.contextPath}/vehicle?action=list"
           class="nav-item ${activePage == 'vehicles' ? 'active' : ''}">
          <i class="ti ti-car" aria-hidden="true"></i> Vehicle Management
        </a>
      </c:if>

      <c:if test="${sessionScope.loggedUser.role == 'ADMIN' || sessionScope.loggedUser.role == 'MAINTENANCE' || sessionScope.loggedUser.role == 'FLEET'}">
        <a href="${pageContext.request.contextPath}/fleet"
           class="nav-item ${activePage == 'fleet' ? 'active' : ''}">
          <i class="ti ti-tool" aria-hidden="true"></i> Fleet &amp; Maintenance
        </a>
      </c:if>

      <c:if test="${sessionScope.loggedUser.role == 'ADMIN'}">
      <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-item ${activePage == 'admin-dashboard' ? 'active' : ''}">
        <i class="ti ti-shield-lock" aria-hidden="true"></i> Admin Control Center
      </a>
      <a href="${pageContext.request.contextPath}/admin/members" class="nav-item ${activePage == 'members' ? 'active' : ''}">
        <i class="ti ti-users" aria-hidden="true"></i> User Management
      </a>
      <a href="${pageContext.request.contextPath}/admin/revenue"
         class="nav-item ${activePage == 'revenue' ? 'active' : ''}">
        <i class="ti ti-trending-up" aria-hidden="true"></i> Revenue
      </a>

      <a href="${pageContext.request.contextPath}/review/moderate"
         class="nav-item ${activePage == 'moderation' ? 'active' : ''}">
        <i class="ti ti-shield" aria-hidden="true"></i> Moderation
      </a>

      <a href="${pageContext.request.contextPath}/payment/list"
         class="nav-item ${activePage == 'paymentlist' ? 'active' : ''}">
        <i class="ti ti-receipt" aria-hidden="true"></i> Payment Log
      </a>
      </c:if>
    </c:if>

    <div class="sidebar-footer">
      <div class="user-pill">
        <div class="user-avatar">
          ${not empty sessionScope.loggedUser ? sessionScope.loggedUser.name.substring(0,1).toUpperCase() : 'G'}
        </div>
        <div class="user-info">
          <span>${not empty sessionScope.loggedUser ? sessionScope.loggedUser.name : 'Guest'}</span>
          <small>${not empty sessionScope.loggedUser ? sessionScope.loggedUser.role : 'Not signed in'}</small>
        </div>
      </div>
    </div>

  </aside>
  <!-- ═══ END SIDEBAR ═══ -->

  <!-- ═══════════════════════════════════════════════════════
       MAIN
       ═══════════════════════════════════════════════════════ -->
  <div class="vrms-main">

    <!-- Topbar — glass pill with editorial breadcrumb -->
    <header class="vrms-topbar">
      <div class="topbar-left">
        <span class="topbar-breadcrumb">
          ${sectionName != null ? sectionName : 'VRMS'}
          <span class="sep">·</span>
          <strong>${pageTitle != null ? pageTitle : 'Home'}</strong>
        </span>
      </div>
      <div class="topbar-right">
        <c:if test="${not empty successMsg}">
          <span class="badge badge-green"><i class="ti ti-circle-check"></i> ${successMsg}</span>
        </c:if>
        <c:if test="${not empty errorMsg}">
          <span class="badge badge-red"><i class="ti ti-alert-circle"></i> ${errorMsg}</span>
        </c:if>
        <%@ include file="/WEB-INF/views/common/notification-bell.jsp" %>
        <c:choose>
          <c:when test="${not empty sessionScope.loggedUser}">
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary btn-sm">
              Sign out
              <span class="ico-pill"><i class="ti ti-logout"></i></span>
            </a>
          </c:when>
          <c:otherwise>
            <a href="${pageContext.request.contextPath}/login" class="btn btn-primary btn-sm">
              Sign in
              <span class="ico-pill"><i class="ti ti-arrow-up-right"></i></span>
            </a>
          </c:otherwise>
        </c:choose>
      </div>
    </header>
    <!-- End Topbar -->

    <main class="vrms-content">
