<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle"   value="Edit Review"  scope="request"/>
<c:set var="sectionName" value="Reviews"       scope="request"/>
<c:set var="activePage"  value="review"         scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  .sr-grid {
    display: grid;
    grid-template-columns: 1fr 320px;
    gap: 22px;
    align-items: start;
    max-width: 1000px;
  }
  @media (max-width: 900px) { .sr-grid { grid-template-columns: 1fr; } }

  .sr-card {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    overflow: hidden;
  }
  .sr-card__head {
    display: flex; align-items: center; justify-content: space-between;
    padding: 18px 24px;
    border-bottom: 1px solid var(--glass-border);
  }
  .sr-card__head h3 {
    font-family: var(--font-sans);
    font-size: 14px; font-weight: 600; color: #fff;
    display: inline-flex; align-items: center; gap: 8px;
  }
  .sr-card__head h3 i { color: var(--bx-warning); }
  .sr-card__body { padding: 24px; }

  .sr-grid-fields { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; }
  .sr-full { grid-column: 1 / -1; }
  @media (max-width: 600px) { .sr-grid-fields { grid-template-columns: 1fr; } }

  .sr-fld { display: flex; flex-direction: column; gap: 6px; }
  .sr-fld__lbl {
    font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase;
    font-weight: 600; color: rgba(255,255,255,0.55);
  }
  .sr-fld input, .sr-fld textarea {
    width: 100%;
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-md);
    color: #fff; font-family: var(--font-sans); font-size: 14px;
    padding: 12px 14px; outline: none;
    transition: border-color var(--t-fast), background var(--t-fast);
  }
  .sr-fld textarea { resize: vertical; min-height: 120px; }
  .sr-fld input:focus, .sr-fld textarea:focus {
    border-color: var(--bx-primary);
    background: rgba(111,203,163,0.06);
  }
  .sr-fld input::placeholder, .sr-fld textarea::placeholder { color: rgba(255,255,255,0.34); }
  .sr-fld input[readonly] { opacity: 0.5; cursor: not-allowed; }

  .sr-type { display: flex; gap: 12px; }
  .sr-type label {
    flex: 1; min-width: 0;
    display: flex; align-items: center; gap: 10px;
    padding: 12px 14px;
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-md);
    cursor: pointer; font-size: 13px; color: rgba(255,255,255,0.85);
    transition: border-color var(--t-fast), background var(--t-fast);
  }
  .sr-type label:hover { border-color: rgba(111,203,163,0.32); }
  .sr-type input { position: absolute; opacity: 0; pointer-events: none; }
  .sr-type__dot {
    width: 16px; height: 16px; border-radius: 50%;
    border: 2px solid var(--bx-primary);
    position: relative; flex-shrink: 0;
  }
  .sr-type__dot::after {
    content: ""; position: absolute; inset: 2px; border-radius: 50%;
    background: var(--bx-primary);
    transform: scale(0); transition: transform var(--t-fast);
  }
  .sr-type input:checked ~ .sr-type__dot::after { transform: scale(1); }

  .sr-stars {
    display: flex; gap: 6px; align-items: center;
    padding: 14px 16px;
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-md);
  }
  .sr-star {
    cursor: pointer; font-size: 30px;
    color: rgba(255,255,255,0.18);
    transition: color var(--t-fast), transform var(--t-fast);
    user-select: none;
  }
  .sr-star:hover { transform: scale(1.1); }
  .sr-star.is-on { color: var(--bx-warning); }
  .sr-rating-text { font-size: 12px; color: rgba(255,255,255,0.6); margin-left: auto; font-weight: 500; }

  .sr-actions {
    display: flex; gap: 10px; justify-content: flex-end;
    margin-top: 22px; padding-top: 20px;
    border-top: 1px solid var(--glass-border);
  }

  .sr-info {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    padding: 22px;
  }
  .sr-info h4 {
    font-size: 11px; letter-spacing: 0.14em; text-transform: uppercase;
    color: rgba(255,255,255,0.55); font-weight: 700; margin-bottom: 14px;
    display: inline-flex; align-items: center; gap: 8px;
  }
  .sr-info h4 i { color: var(--bx-primary); font-size: 14px; }
  .sr-info-row {
    display: flex; flex-direction: column; gap: 12px;
    font-size: 13px; color: rgba(255,255,255,0.75);
  }
  .sr-info-row span { color: rgba(255,255,255,0.45); font-size: 11px; display: block; margin-bottom: 2px; }

  .sr-alert {
    padding: 14px 18px; border-radius: var(--r-md);
    display: flex; gap: 12px; align-items: flex-start;
    font-size: 13px; margin-bottom: 18px;
  }
  .sr-alert i { font-size: 18px; margin-top: 1px; flex-shrink: 0; }
  .sr-alert--ok  { background: rgba(111,203,163,0.10); border: 1px solid rgba(111,203,163,0.32); color: rgba(255,255,255,0.85); }
  .sr-alert--ok  i { color: var(--bx-primary); }
  .sr-alert--err { background: rgba(248,113,113,0.10); border: 1px solid rgba(248,113,113,0.32); color: rgba(255,255,255,0.85); }
  .sr-alert--err i { color: var(--bx-danger); }
</style>

<div class="page-header-row reveal">
  <div class="page-header" style="margin-bottom:0;">
    <span class="eyebrow">Your voice</span>
    <h1>Edit your <em>review.</em></h1>
    <p>Update your rating or comment. Vehicle and booking cannot be changed.</p>
  </div>
  <a href="${pageContext.request.contextPath}/review/view" class="btn btn-secondary">
    <i class="ti ti-messages"></i> View all reviews
  </a>
</div>

<c:if test="${not empty successMsg}">
  <div class="sr-alert sr-alert--ok"><i class="ti ti-circle-check"></i><div>${successMsg}</div></div>
</c:if>
<c:if test="${not empty errorMsg}">
  <div class="sr-alert sr-alert--err"><i class="ti ti-alert-circle"></i><div>${errorMsg}</div></div>
</c:if>

<div class="sr-grid">

  <div class="sr-card reveal">
    <div class="sr-card__head">
      <h3><i class="ti ti-pencil"></i> Edit review</h3>
    </div>
    <div class="sr-card__body">
      <form action="${pageContext.request.contextPath}/review/edit" method="post">
        <input type="hidden" name="reviewId" value="${review.reviewId}"/>

        <div class="sr-grid-fields">

          <div class="sr-fld">
            <label class="sr-fld__lbl">Vehicle ID</label>
            <input type="text" value="${review.vehicleId}" readonly/>
          </div>

          <div class="sr-fld">
            <label class="sr-fld__lbl">Review ID</label>
            <input type="text" value="${review.reviewId}" readonly/>
          </div>

          <div class="sr-fld sr-full">
            <label class="sr-fld__lbl">Review type</label>
            <div class="sr-type">
              <label>
                <input type="radio" name="reviewType" value="public"
                       ${review.reviewType == 'public' ? 'checked' : ''}/>
                <span class="sr-type__dot"></span>
                <span>Public review</span>
              </label>
              <label>
                <input type="radio" name="reviewType" value="verified"
                       ${review.reviewType == 'verified' ? 'checked' : ''}/>
                <span class="sr-type__dot"></span>
                <span><i class="ti ti-badge-check" style="color:var(--bx-primary); font-size:14px; vertical-align:-1px;"></i> Verified renter</span>
              </label>
            </div>
          </div>

          <div class="sr-fld sr-full">
            <label class="sr-fld__lbl">Rating</label>
            <div class="sr-stars">
              <c:forEach begin="1" end="5" var="i">
                <span class="sr-star" id="star-lbl-${i}" onclick="setRating(${i})">★</span>
              </c:forEach>
              <input type="hidden" name="rating" id="ratingInput" value="${review.rating}"/>
              <span class="sr-rating-text" id="rating-text"></span>
            </div>
          </div>

          <div class="sr-fld sr-full">
            <label class="sr-fld__lbl" for="comment">Your comment</label>
            <textarea id="comment" name="comment" required>${review.comment}</textarea>
          </div>

        </div>

        <div class="sr-actions">
          <a href="${pageContext.request.contextPath}/review/view" class="btn btn-ghost">Cancel</a>
          <button type="submit" class="btn btn-primary" data-antigravity>
            <i class="ti ti-device-floppy"></i> Save changes
          </button>
        </div>
      </form>
    </div>
  </div>

  <!-- Info card -->
  <div class="sr-info reveal">
    <h4><i class="ti ti-info-circle"></i> Review info</h4>
    <div class="sr-info-row">
      <div><span>Submitted by</span>${review.username}</div>
      <div><span>Date</span>${review.reviewDate}</div>
      <div><span>Vehicle</span>${review.vehicleId}</div>
      <div><span>Status</span>${review.status}</div>
    </div>
  </div>

</div>

<script>
  var ratingLabels = ['','Poor','Fair','Good','Very Good','Excellent'];
  function setRating(n) {
    document.getElementById('ratingInput').value = n;
    document.getElementById('rating-text').textContent = ratingLabels[n] || '';
    for (var i = 1; i <= 5; i++) {
      document.getElementById('star-lbl-' + i).classList.toggle('is-on', i <= n);
    }
  }
  window.addEventListener('DOMContentLoaded', function() {
    setRating(parseInt('${review.rating}') || 5);
  });
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>