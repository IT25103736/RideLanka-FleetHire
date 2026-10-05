<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle"   value="Top Vehicles" scope="request"/>
<c:set var="sectionName" value="Admin"        scope="request"/>
<c:set var="activePage"  value="revenue"      scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  .mp-card {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    overflow: hidden;
  }
  .mp-table { width: 100%; border-collapse: collapse; }
  .mp-table thead th {
    text-align: left;
    padding: 12px 22px;
    font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase;
    color: rgba(255,255,255,0.5); font-weight: 700;
    border-bottom: 1px solid var(--glass-border);
  }
  .mp-table tbody td {
    padding: 14px 22px;
    font-size: 13px;
    color: rgba(255,255,255,0.78);
    border-bottom: 1px solid rgba(255,255,255,0.04);
    vertical-align: middle;
  }
  .mp-table tbody tr:last-child td { border-bottom: 0; }
  .mp-table tbody tr:hover { background: rgba(255,255,255,0.03); }
  .mp-mono { font-family: var(--font-mono); }

  .mp-badge {
    display: inline-flex; align-items: center; gap: 5px;
    padding: 4px 10px;
    border-radius: var(--r-pill);
    font-size: 11px; font-weight: 600;
    border: 1px solid;
    background: rgba(255,255,255,0.06);
    color: rgba(255,255,255,0.78);
    border-color: var(--glass-border);
  }

  .tv-thumb {
    width: 56px; height: 36px;
    border-radius: 6px;
    object-fit: cover;
    background: rgba(0,0,0,0.4);
  }
  .tv-rank {
    font-family: 'Manrope', var(--font-sans);
    font-size: 20px; font-weight: 700;
    color: var(--bx-primary);
  }

  /* Kit §Trust §6 — empty state must explain + offer a next action. */
  .mp-empty {
    text-align: center;
    padding: 56px 24px;
    color: rgba(255,255,255,0.55);
  }
  .mp-empty i { font-size: 32px; color: var(--bx-primary); display: block; margin-bottom: 12px; }
  .mp-empty h4 { color: #fff; font-size: 15px; margin: 0 0 6px; }
  .mp-empty p { margin: 0 0 16px; font-size: 13px; }
</style>

<div class="page-header-row reveal">
  <div class="page-header" style="margin-bottom:0;">
    <span class="eyebrow">Admin</span>
    <h1>Top <em>vehicles.</em></h1>
    <p>Revenue leaderboard &mdash; ranked by non-cancelled rental count, with matched payment revenue and average trip length.</p>
  </div>
  <a href="${pageContext.request.contextPath}/admin/revenue" class="btn btn-secondary">
    <i class="ti ti-arrow-left"></i> Back to Revenue
  </a>
</div>

<div class="mp-card reveal">
  <c:choose>
    <c:when test="${not empty rows}">
  <table class="mp-table">
    <thead>
      <tr>
        <th style="width:60px;">Rank</th>
        <th>Vehicle</th>
        <th>Type</th>
        <th>Rentals</th>
        <th>Revenue</th>
        <th>Avg trip</th>
      </tr>
    </thead>
    <tbody>
      <c:forEach var="r" items="${rows}" varStatus="loop">
        <tr>
          <td><span class="tv-rank">#${loop.index + 1}</span></td>
          <td>
            <a href="${pageContext.request.contextPath}/vehicle?action=view&id=${r.vehicle.vehicleId}"
               style="text-decoration:none; color:inherit; display:flex; align-items:center; gap:12px;">
              <img class="tv-thumb" src="${not empty r.vehicle.imageUrl ? r.vehicle.imageUrl : ''}" alt="" loading="lazy" decoding="async" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/images/vehicles/default-vehicle.jpg'"/>
              <div>
                <div style="font-weight:600; color:#fff;">${r.vehicle.brand} ${r.vehicle.model}</div>
                <div class="mp-mono" style="font-size:11px; color:rgba(255,255,255,0.5);">${r.vehicle.vehicleId}</div>
              </div>
            </a>
          </td>
          <td><span class="mp-badge">${r.vehicle.vehicleType}</span></td>
          <td class="mp-mono">${r.rentals}</td>
          <td class="mp-mono">
            <span style="color:var(--bx-primary); font-weight:600;">LKR</span>
            <fmt:formatNumber value="${r.revenue}" pattern="#,##0.00"/>
          </td>
          <td class="mp-mono">
            <fmt:formatNumber value="${r.avgTripDays}" maxFractionDigits="1" minFractionDigits="1"/> days
          </td>
        </tr>
      </c:forEach>
    </tbody>
  </table>
    </c:when>
    <c:otherwise>
      <div class="mp-empty">
        <i class="ti ti-trophy-off"></i>
        <h4>No rentals yet to rank</h4>
        <p>Once members start booking vehicles, the leaderboard fills in by rental count and matched revenue.</p>
        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/admin/bookings">
          <i class="ti ti-calendar-event"></i> Open reservations
        </a>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
