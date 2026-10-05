<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>${pageTitle != null ? pageTitle : 'RideLanka FleetHire'} — Vehicle Rental</title>
  <link rel="preconnect" href="https://fonts.googleapis.com"/>
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Bebas+Neue&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/vrms-theme.css"/>
</head>
<body>
<div class="mkt-shell">

  <!-- ═══ Boxcar-style horizontal navbar ═══ -->
  <nav class="mkt-nav">
    <div class="mkt-nav__inner">
      <a href="${pageContext.request.contextPath}/" class="mkt-brand" aria-label="RideLanka FleetHire home">
        <img src="${pageContext.request.contextPath}/images/vrms-logo.png"
             alt="RideLanka FleetHire — Vehicle Rental" class="mkt-brand__img"/>
        <span class="mkt-brand__text">
          <span class="brand">RideLanka FleetHire</span>
          <small>&mdash; Vehicle Rental &mdash;</small>
        </span>
      </a>

      <div class="mkt-nav__links">
        <a href="${pageContext.request.contextPath}/" class="mkt-nav__link ${activePage == 'home' ? 'active' : ''}">Home</a>
        <a href="${pageContext.request.contextPath}/search" class="mkt-nav__link ${activePage == 'fleet' ? 'active' : ''}">Search Vehicle</a>
        <a href="${pageContext.request.contextPath}/booking?action=form" class="mkt-nav__link ${activePage == 'reservations' ? 'active' : ''}">Reservations</a>
        <a href="${pageContext.request.contextPath}/policies" class="mkt-nav__link ${activePage == 'policies' ? 'active' : ''}">Policies</a>
        <a href="${pageContext.request.contextPath}/#contact" class="mkt-nav__link">Contact</a>
      </div>

      <div class="mkt-nav__cta">
        <%@ include file="/WEB-INF/views/common/notification-bell.jsp" %>
        <c:choose>
          <c:when test="${not empty sessionScope.loggedUser}">
            <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-ghost btn-sm">Dashboard</a>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-primary btn-sm">
              Sign out
              <span class="ico-pill"><i class="ti ti-logout"></i></span>
            </a>
          </c:when>
          <c:otherwise>
            <a href="${pageContext.request.contextPath}/login" class="btn btn-ghost btn-sm">Sign in</a>
            <a href="${pageContext.request.contextPath}/register" class="btn btn-primary btn-sm">
              Get started
              <span class="ico-pill"><i class="ti ti-arrow-up-right"></i></span>
            </a>
          </c:otherwise>
        </c:choose>
        <button class="mkt-nav__hamburger" aria-label="Open menu" onclick="document.body.classList.toggle('mkt-menu-open')">
          <i class="ti ti-menu-2"></i>
        </button>
      </div>
    </div>
  </nav>

  <!-- ═══ Floating Liquid Glass search strip — slides in on scroll ═══ -->
  <div class="mkt-floatsearch" id="mktFloatSearch" role="search" aria-hidden="true">
    <form class="mkt-floatsearch__form" action="${pageContext.request.contextPath}/search" method="get">
      <div class="mkt-floatsearch__row">
        <label class="mkt-floatsearch__field">
          <i class="ti ti-map-pin"></i>
          <select name="location" aria-label="Pickup city">
            <option value="">Any city</option>
            <option value="Colombo">Colombo</option>
            <option value="Kandy">Kandy</option>
          </select>
        </label>
        <span class="mkt-floatsearch__sep"></span>
        <label class="mkt-floatsearch__field">
          <i class="ti ti-car"></i>
          <select name="vehicleType" aria-label="Vehicle type">
            <option value="">All vehicles</option>
            <option value="sedan">Sedan</option>
            <option value="hybrid">Hybrid</option>
            <option value="suv">SUV</option>
            <option value="hatchback">Hatchback</option>
            <option value="electric">Electric</option>
            <option value="van">Van</option>
            
          </select>
        </label>
        <span class="mkt-floatsearch__sep"></span>
        <label class="mkt-floatsearch__field">
          <i class="ti ti-gas-station"></i>
          <select name="fuelType" aria-label="Fuel">
            <option value="">Any fuel</option>
            <option value="Hybrid">Hybrid</option>
            <option value="Petrol">Petrol</option>
            <option value="Diesel">Diesel</option>
            <option value="Electric">Electric</option>
          </select>
        </label>
        <span class="mkt-floatsearch__sep"></span>
        <label class="mkt-floatsearch__field mkt-floatsearch__field--toggle">
          <input type="checkbox" name="withDriver" value="true" id="floatWithDriver"/>
          <span class="mkt-floatsearch__dot"></span>
          <span>With driver</span>
        </label>
        <button type="submit" class="mkt-floatsearch__cta" data-antigravity>
          <i class="ti ti-search"></i> Search
        </button>
      </div>
    </form>
  </div>

  <!-- ═══ Floating WhatsApp launcher — sitewide, glass pill, bottom-right ═══ -->
  <a class="mkt-whatsapp" id="mktWhatsapp"
     href="https://wa.me/94778119913?text=Hi%20RideLanka FleetHire%20%E2%80%94%20I%27m%20looking%20to%20book%20a%20vehicle"
     target="_blank" rel="noopener"
     aria-label="Chat with us on WhatsApp"
     data-antigravity>
    <span class="mkt-whatsapp__icon"><i class="ti ti-brand-whatsapp"></i></span>
    <span class="mkt-whatsapp__text">
      <span class="mkt-whatsapp__lbl">Chat on WhatsApp</span>
      <span class="mkt-whatsapp__num">+94 77 811 9913</span>
    </span>
    <span class="mkt-whatsapp__pulse" aria-hidden="true"></span>
  </a>

  <main>
