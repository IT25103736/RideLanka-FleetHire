<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="pageTitle"   value="Vehicle Reviews" scope="request"/>
<c:set var="sectionName" value="Reviews"          scope="request"/>
<c:set var="activePage"  value="review"            scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  .vr-filter {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    padding: 14px 18px;
    margin-bottom: 18px;
  }
  .vr-filter form {
    display: flex; gap: 12px; align-items: center; flex-wrap: wrap;
  }
  .vr-filter__search {
    display: flex; align-items: center; gap: 10px;
    flex: 1; min-width: 200px;
    padding: 10px 14px;
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-md);
  }
  .vr-filter__search i { color: rgba(255,255,255,0.55); font-size: 15px; }
  .vr-filter__search input {
    flex: 1; border: 0; background: transparent;
    color: #fff; font-family: var(--font-sans); font-size: 13px; outline: none;
  }
  .vr-filter__search input::placeholder { color: rgba(255,255,255,0.34); }
  .vr-filter input[type="text"], .vr-filter select {
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-md);
    color: #fff; font-family: var(--font-sans); font-size: 13px;
    padding: 10px 14px; outline: none;
    transition: border-color var(--t-fast);
    -webkit-appearance: none; appearance: none;
  }
  .vr-filter input[type="text"]:focus, .vr-filter select:focus { border-color: var(--bx-primary); }
  .vr-filter select option { background: var(--bx-paper); color: #fff; }
  .vr-filter input[type="text"] { width: 140px; }
  .vr-filter select { width: 150px; }

  .vr-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 18px;
  }

  .vr-card {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    padding: 20px;
    transition: transform var(--t-base), background var(--t-base), border-color var(--t-base);
  }
  .vr-card:hover {
    transform: translateY(-3px);
    background: var(--glass-bg-strong);
    border-color: rgba(255,255,255,0.18);
  }
  .vr-card__head {
    display: flex; justify-content: space-between; align-items: flex-start;
    margin-bottom: 12px;
  }
  .vr-author { display: flex; align-items: center; gap: 10px; }
  .vr-avatar {
    width: 38px; height: 38px; border-radius: 50%;
    background: linear-gradient(135deg, var(--bx-primary) 0%, var(--bx-primary-deep) 100%);
    color: var(--bx-night);
    display: flex; align-items: center; justify-content: center;
    font-family: 'Space Grotesk', var(--font-sans);
    font-weight: 700; font-size: 14px;
    box-shadow: inset 0 1px 0 rgba(255,255,255,0.32);
  }
  .vr-author__name { font-weight: 600; font-size: 13px; color: #fff; }
  .vr-author__date {
    font-size: 11px; color: rgba(255,255,255,0.5);
    font-family: var(--font-mono); margin-top: 2px;
  }
  .vr-badge {
    display: inline-flex; align-items: center; gap: 4px;
    padding: 3px 9px; border-radius: var(--r-pill);
    font-size: 10px; font-weight: 600; border: 1px solid;
  }
  .vr-badge--verified { background: rgba(111,203,163,0.14); color: var(--bx-primary); border-color: rgba(111,203,163,0.32); }
  .vr-badge--public   { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.65); border-color: var(--glass-border); }

  .vr-stars { font-size: 18px; color: var(--bx-warning); letter-spacing: 2px; margin-bottom: 10px; }
  .vr-comment { font-size: 14px; color: rgba(255,255,255,0.85); line-height: 1.6; margin-bottom: 14px; }
  .vr-foot {
    display: flex; align-items: center; gap: 8px;
    padding-top: 12px; border-top: 1px solid var(--glass-border);
    font-size: 12px; color: rgba(255,255,255,0.55);
  }
  .vr-foot i { font-size: 13px; color: var(--bx-primary); }
  .vr-foot .ref { margin-left: auto; font-family: var(--font-mono); font-size: 10px; color: rgba(255,255,255,0.42); }

  .vr-owner-actions {
    display: flex; gap: 8px;
    margin-top: 12px;
    padding-top: 12px;
    border-top: 1px solid var(--glass-border);
  }
  .btn-edit-review {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 6px 14px; border-radius: var(--r-pill);
    font-size: 12px; font-weight: 600;
    border: 1px solid rgba(111,203,163,0.4);
    background: rgba(111,203,163,0.1);
    color: var(--bx-primary);
    text-decoration: none;
    transition: background var(--t-fast), border-color var(--t-fast);
  }
  .btn-edit-review:hover {
    background: rgba(111,203,163,0.22);
    border-color: rgba(111,203,163,0.7);
  }
  .btn-delete-review {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 6px 14px; border-radius: var(--r-pill);
    font-size: 12px; font-weight: 600;
    border: 1px solid rgba(255,80,80,0.4);
    background: rgba(255,80,80,0.1);
    color: #ff6b6b; cursor: pointer;
    transition: background var(--t-fast), border-color var(--t-fast);
  }
  .btn-delete-review:hover {
    background: rgba(255,80,80,0.22);
    border-color: rgba(255,80,80,0.7);
  }

  .vr-empty {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    text-align: center; padding: 60px 24px;
  }
  .vr-empty i { font-size: 48px; color: var(--bx-primary); display: block; margin-bottom: 14px; }
  .vr-empty h3 {
    font-family: 'Manrope', var(--font-sans);
    font-size: 22px; font-weight: 600; color: #fff; margin-bottom: 8px;
  }
  .vr-empty p { color: rgba(255,255,255,0.6); font-size: 14px; margin-bottom: 18px; }
</style>

<div class="page-header-row reveal">
  <div class="page-header" style="margin-bottom:0;">
    <span class="eyebrow">In their words</span>
    <h1>Renter <em>reviews.</em></h1>
    <p>Verified stories from drivers who actually made the trip.</p>
  </div>
  <a href="${pageContext.request.contextPath}/review/submit" class="btn btn-primary" data-antigravity>
    <i class="ti ti-plus"></i> Write a review
  </a>
</div>

<!-- Filter bar -->
<div class="vr-filter reveal">
  <form method="get" action="${pageContext.request.contextPath}/review/view">
    <div class="vr-filter__search">
      <i class="ti ti-search"></i>
      <input type="text" name="search" placeholder="Search reviews..." value="${param.search}"/>
    </div>
    <input type="text" name="vehicleId" placeholder="Vehicle ID" value="${param.vehicleId}"/>
    <select name="rating">
      <option value="">All ratings</option>
      <option value="5" ${param.rating == '5' ? 'selected':''}>★★★★★ 5 only</option>
      <option value="4" ${param.rating == '4' ? 'selected':''}>★★★★ 4+</option>
      <option value="3" ${param.rating == '3' ? 'selected':''}>★★★ 3+</option>
    </select>
    <button type="submit" class="btn btn-secondary btn-sm">
      <i class="ti ti-filter"></i> Filter
    </button>
  </form>
</div>

<!-- Reviews grid -->
<c:choose>
  <c:when test="${not empty reviews}">
    <div class="vr-grid">
      <c:forEach var="r" items="${reviews}">
        <div class="vr-card reveal" data-antigravity>
          <div class="vr-card__head">
            <div class="vr-author">
              <div class="vr-avatar">${fn:toUpperCase(fn:substring(r.username, 0, 1))}</div>
              <div>
                <div class="vr-author__name">${r.username}</div>
                <div class="vr-author__date">${r.reviewDate}</div>
              </div>
            </div>
            <c:choose>
              <c:when test="${r.reviewType eq 'verified'}">
                <span class="vr-badge vr-badge--verified">
                  <i class="ti ti-badge-check" style="font-size:11px;"></i> Verified
                </span>
              </c:when>
              <c:otherwise>
                <span class="vr-badge vr-badge--public">Public</span>
              </c:otherwise>
            </c:choose>
          </div>

          <div class="vr-stars">${r.starString}</div>
          <p class="vr-comment">${r.comment}</p>

          <div class="vr-foot">
            <i class="ti ti-car"></i> ${r.vehicleId}
            <span class="ref">${r.reviewId}</span>
          </div>

          <%-- Edit & Delete for review owner or admin --%>
          <c:if test="${sessionUserId eq r.userId or sessionRole eq 'admin'}">
            <div class="vr-owner-actions">
              <a href="${pageContext.request.contextPath}/review/edit?reviewId=${r.reviewId}"
                 class="btn-edit-review">
                <i class="ti ti-pencil"></i> Edit
              </a>
              <form method="post"
                    action="${pageContext.request.contextPath}/review/delete"
                    onsubmit="return confirm('Delete this review?');"
                    style="margin:0;">
                <input type="hidden" name="reviewId" value="${r.reviewId}"/>
                <button type="submit" class="btn-delete-review">
                  <i class="ti ti-trash"></i> Delete
                </button>
              </form>
            </div>
          </c:if>

        </div>
      </c:forEach>
    </div>
  </c:when>
  <c:otherwise>
    <div class="vr-empty reveal">
      <i class="ti ti-star-off"></i>
      <h3>No reviews yet</h3>
      <p>Be the first to leave a review.</p>
      <a href="${pageContext.request.contextPath}/review/submit" class="btn btn-primary" data-antigravity>
        Write a review
        <span class="ico-pill"><i class="ti ti-arrow-right"></i></span>
      </a>
    </div>
  </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>