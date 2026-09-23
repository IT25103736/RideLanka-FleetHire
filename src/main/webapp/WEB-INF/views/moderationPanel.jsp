<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle"   value="Review Moderation" scope="request"/>
<c:set var="sectionName" value="Admin"              scope="request"/>
<c:set var="activePage"  value="moderation"          scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  .md-tabs {
    display: flex; gap: 4px; padding: 6px;
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-pill);
    margin-bottom: 22px; width: fit-content;
  }
  .md-tab {
    display: inline-flex; align-items: center; gap: 8px;
    padding: 8px 18px; border-radius: var(--r-pill);
    font-size: 13px; font-weight: 500;
    color: rgba(255,255,255,0.65);
    text-decoration: none;
    transition: background var(--t-fast), color var(--t-fast);
  }
  .md-tab:hover { color: #fff; background: rgba(255,255,255,0.04); }
  .md-tab.is-active { background: var(--bx-primary); color: var(--bx-night); font-weight: 600; }
  .md-tab__count {
    padding: 2px 8px; background: rgba(0,0,0,0.18); color: inherit;
    border-radius: var(--r-pill); font-size: 11px; font-weight: 700;
  }
  .md-tab:not(.is-active) .md-tab__count { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.75); }
  .md-tab.tab-flagged.is-active { background: var(--bx-danger); color: #fff; }

  .md-card {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell); box-shadow: var(--glass-shadow); overflow: hidden;
  }
  .md-card__head {
    display: flex; align-items: center; justify-content: space-between;
    padding: 16px 22px; border-bottom: 1px solid var(--glass-border);
  }
  .md-card__head h3 {
    font-family: var(--font-sans); font-size: 14px; font-weight: 600; color: #fff;
    display: inline-flex; align-items: center; gap: 8px;
  }
  .md-card__head h3 i { color: var(--bx-primary); }

  .md-table { width: 100%; border-collapse: collapse; }
  .md-table thead th {
    text-align: left; padding: 12px 20px;
    font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase;
    color: rgba(255,255,255,0.5); font-weight: 700;
    border-bottom: 1px solid var(--glass-border);
  }
  .md-table thead th:last-child { text-align: right; }
  .md-table tbody td {
    padding: 14px 20px; font-size: 13px; color: rgba(255,255,255,0.78);
    border-bottom: 1px solid rgba(255,255,255,0.04); vertical-align: middle;
  }
  .md-table tbody tr:last-child td { border-bottom: 0; }
  .md-table tbody tr:hover { background: rgba(255,255,255,0.03); }

  .md-mono { font-family: var(--font-mono); }
  .md-stars { font-size: 14px; color: var(--bx-warning); letter-spacing: 2px; }
  .md-stars-sub { font-size: 11px; color: rgba(255,255,255,0.45); margin-left: 4px; }
  .md-comment { max-width: 220px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-size: 11px; color: rgba(255,255,255,0.55); }

  .md-badge {
    display: inline-flex; align-items: center; gap: 5px;
    padding: 3px 10px; border-radius: var(--r-pill);
    font-size: 11px; font-weight: 600; border: 1px solid;
  }
  .md-badge--ok   { background: rgba(111,203,163,0.14); color: var(--bx-primary); border-color: rgba(111,203,163,0.32); }
  .md-badge--warn { background: rgba(251,191,36,0.14); color: var(--bx-warning); border-color: rgba(251,191,36,0.28); }
  .md-badge--err  { background: rgba(248,113,113,0.14); color: var(--bx-danger); border-color: rgba(248,113,113,0.32); }
  .md-badge--info { background: rgba(125,211,252,0.10); color: var(--bx-info); border-color: rgba(125,211,252,0.24); }
  .md-badge--gray { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.65); border-color: var(--glass-border); }

  .md-actions { display: inline-flex; gap: 6px; justify-content: flex-end; width: 100%; }
  .md-action {
    display: inline-flex; align-items: center; justify-content: center;
    width: 32px; height: 32px; border-radius: 8px;
    background: rgba(255,255,255,0.04); border: 1px solid var(--glass-border);
    color: rgba(255,255,255,0.75); cursor: pointer;
    transition: background var(--t-fast), color var(--t-fast), border-color var(--t-fast);
  }
  .md-action--ok:hover     { color: var(--bx-primary); border-color: rgba(111,203,163,0.32); background: rgba(111,203,163,0.08); }
  .md-action--warn:hover   { color: var(--bx-warning); border-color: rgba(251,191,36,0.32); background: rgba(251,191,36,0.08); }
  .md-action--danger:hover { color: var(--bx-danger); border-color: rgba(248,113,113,0.32); background: rgba(248,113,113,0.08); }

  .md-empty { text-align: center; padding: 56px 24px; color: rgba(255,255,255,0.55); }
  .md-empty i { font-size: 36px; color: var(--bx-primary); display: block; margin-bottom: 10px; }

  .md-overlay {
    display: none; position: fixed; inset: 0;
    background: rgba(0,0,0,0.7);
    -webkit-backdrop-filter: blur(8px); backdrop-filter: blur(8px);
    z-index: 200; align-items: center; justify-content: center;
  }
  .md-modal {
    background: var(--glass-bg-strong);
    -webkit-backdrop-filter: blur(28px) saturate(180%); backdrop-filter: blur(28px) saturate(180%);
    border: 1px solid var(--glass-border-top); border-radius: var(--r-shell);
    padding: 26px; max-width: 520px; width: 90%; box-shadow: var(--glass-shadow-lg);
  }
  .md-modal__head { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
  .md-modal__head h3 {
    font-family: var(--font-sans); font-size: 14px; font-weight: 600; color: #fff;
    display: inline-flex; align-items: center; gap: 8px;
  }
  .md-modal__head h3 i { color: var(--bx-primary); }
  .md-modal__close {
    width: 32px; height: 32px; border-radius: 8px;
    background: rgba(255,255,255,0.04); border: 1px solid var(--glass-border);
    color: rgba(255,255,255,0.75); cursor: pointer;
  }
  .md-modal__close:hover { color: #fff; background: rgba(255,255,255,0.08); }
  .md-modal__text { font-size: 14px; color: rgba(255,255,255,0.82); line-height: 1.7; }
</style>

<div class="page-header-row reveal">
  <div class="page-header" style="margin-bottom:0;">
    <span class="eyebrow">Admin</span>
    <h1>Review <em>moderation.</em></h1>
    <p>Flag or delete reviews. All reviews are auto-approved on submission.</p>
  </div>
  <span class="md-badge md-badge--err" style="font-size:12px; padding:6px 14px;">
    <i class="ti ti-flag"></i> ${not empty flaggedCount ? flaggedCount : 0} flagged
  </span>
</div>

<!-- Tabs -->
<div class="md-tabs reveal">
  <a href="?tab=approved"
     class="md-tab ${empty param.tab || param.tab == 'approved' ? 'is-active' : ''}">
    Approved
    <span class="md-tab__count">${approvedCount}</span>
  </a>
  <a href="?tab=flagged"
     class="md-tab tab-flagged ${param.tab == 'flagged' ? 'is-active' : ''}">
    Flagged
    <span class="md-tab__count">${flaggedCount}</span>
  </a>
</div>

<div class="md-card reveal">
  <div class="md-card__head">
    <h3><i class="ti ti-shield"></i>
      ${empty param.tab || param.tab == 'approved' ? 'Approved reviews' : 'Flagged reviews'}
    </h3>
  </div>

  <c:choose>
    <c:when test="${not empty reviews}">
      <table class="md-table">
        <thead>
          <tr>
            <th>Review ID</th>
            <th>User</th>
            <th>Vehicle</th>
            <th>Rating</th>
            <th>Type</th>
            <th>Date</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="r" items="${reviews}">
            <tr>
              <td class="md-mono" style="color:#fff;">${r.reviewId}</td>
              <td>
                <div style="font-weight:500; color:#fff;">${r.username}</div>
                <div class="md-comment">${r.comment}</div>
              </td>
              <td class="md-mono" style="color:rgba(255,255,255,0.6);">${r.vehicleId}</td>
              <td>
                <span class="md-stars">${r.starString}</span>
                <span class="md-stars-sub">(${r.rating}/5)</span>
              </td>
              <td>
                <c:choose>
                  <c:when test="${r.reviewType == 'verified'}">
                    <span class="md-badge md-badge--info"><i class="ti ti-badge-check"></i> Verified</span>
                  </c:when>
                  <c:otherwise>
                    <span class="md-badge md-badge--gray">Public</span>
                  </c:otherwise>
                </c:choose>
              </td>
              <td class="md-mono" style="color:rgba(255,255,255,0.55);">${r.reviewDate}</td>
              <td>
                <c:choose>
                  <c:when test="${r.status == 'approved'}"><span class="md-badge md-badge--ok">Approved</span></c:when>
                  <c:when test="${r.status == 'flagged'}"><span class="md-badge md-badge--err">Flagged</span></c:when>
                  <c:otherwise><span class="md-badge md-badge--warn">Pending</span></c:otherwise>
                </c:choose>
              </td>
              <td style="text-align:right;">
                <div class="md-actions">
                  <%-- Preview --%>
                  <button class="md-action" title="Preview comment"
                          onclick="showPreview('${r.reviewId}','${r.comment}')">
                    <i class="ti ti-eye"></i>
                  </button>
                  <%-- Flag (shown on approved tab) --%>
                  <c:if test="${r.status == 'approved'}">
                    <form action="${pageContext.request.contextPath}/review/flag"
                          method="post" style="display:inline;">
                      <input type="hidden" name="reviewId" value="${r.reviewId}"/>
                      <button type="submit" class="md-action md-action--warn" title="Flag this review">
                        <i class="ti ti-flag"></i>
                      </button>
                    </form>
                  </c:if>
                  <%-- Unflag (shown on flagged tab) --%>
                  <c:if test="${r.status == 'flagged'}">
                    <form action="${pageContext.request.contextPath}/review/unflag"
                          method="post" style="display:inline;">
                      <input type="hidden" name="reviewId" value="${r.reviewId}"/>
                      <button type="submit" class="md-action md-action--ok" title="Restore to approved">
                        <i class="ti ti-check"></i>
                      </button>
                    </form>
                  </c:if>
                  <%-- Delete --%>
                  <form action="${pageContext.request.contextPath}/review/delete"
                        method="post" style="display:inline;"
                        onsubmit="return confirm('Delete this review permanently?');">
                    <input type="hidden" name="reviewId" value="${r.reviewId}"/>
                    <input type="hidden" name="tab"      value="${param.tab}"/>
                    <button type="submit" class="md-action md-action--danger" title="Delete">
                      <i class="ti ti-trash"></i>
                    </button>
                  </form>
                </div>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </c:when>
    <c:otherwise>
      <div class="md-empty">
        <i class="ti ti-mood-happy"></i>
        <p>No reviews in this category.</p>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<!-- Preview modal -->
<div id="preview-overlay" class="md-overlay">
  <div class="md-modal">
    <div class="md-modal__head">
      <h3><i class="ti ti-quote"></i> Review comment</h3>
      <button onclick="closePreview()" class="md-modal__close" aria-label="Close">
        <i class="ti ti-x"></i>
      </button>
    </div>
    <p id="preview-text" class="md-modal__text"></p>
  </div>
</div>

<script>
  function showPreview(id, comment) {
    document.getElementById('preview-text').textContent = comment || '(No comment)';
    document.getElementById('preview-overlay').style.display = 'flex';
  }
  function closePreview() {
    document.getElementById('preview-overlay').style.display = 'none';
  }
  document.getElementById('preview-overlay').addEventListener('click', function(e) {
    if (e.target === this) closePreview();
  });
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>