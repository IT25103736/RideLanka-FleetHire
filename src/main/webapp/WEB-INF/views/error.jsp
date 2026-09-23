<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle"   value="Something went wrong" scope="request"/>
<c:set var="activePage"  value="error"                 scope="request"/>
<%@ include file="/WEB-INF/views/common/marketing-header.jsp" %>

<style>
  .err-shell {
    max-width: 720px;
    margin: 80px auto;
    padding: 0 24px;
    text-align: center;
  }
  .err-icon {
    width: 88px; height: 88px;
    border-radius: 50%;
    background: linear-gradient(135deg, rgba(248,113,113,0.22) 0%, rgba(248,113,113,0.06) 100%);
    border: 1px solid rgba(248,113,113,0.32);
    color: var(--bx-danger);
    display: inline-flex; align-items: center; justify-content: center;
    font-size: 42px;
    margin-bottom: 22px;
    box-shadow: inset 0 1px 0 rgba(255,255,255,0.12), 0 12px 36px -16px rgba(248,113,113,0.5);
  }
  .err-eyebrow {
    display: inline-flex;
    padding: 5px 12px;
    border-radius: 999px;
    background: rgba(248,113,113,0.10);
    border: 1px solid rgba(248,113,113,0.24);
    font-size: 10px; letter-spacing: 0.22em; text-transform: uppercase;
    color: var(--bx-danger);
    font-weight: 700;
    margin-bottom: 14px;
  }
  .err-shell h1 {
    font-family: 'Manrope', var(--font-sans);
    font-size: clamp(34px, 4vw, 52px);
    font-weight: 600;
    letter-spacing: -0.030em;
    line-height: 1.05;
    color: #fff;
    margin: 0;
  }
  .err-shell p {
    font-size: 15px;
    color: rgba(255,255,255,0.7);
    margin: 18px auto 26px;
    max-width: 56ch;
    line-height: 1.65;
  }

  .err-card {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    padding: 22px 26px;
    margin: 28px 0;
    text-align: left;
  }
  .err-row {
    display: flex; justify-content: space-between; align-items: center;
    padding: 8px 0;
    font-size: 13px;
    border-bottom: 1px solid var(--glass-border);
  }
  .err-row:last-child { border-bottom: 0; }
  .err-row .lbl {
    color: rgba(255,255,255,0.5);
    font-size: 11px; letter-spacing: 0.12em; text-transform: uppercase;
    font-weight: 600;
  }
  .err-row .val {
    color: #fff;
    font-family: var(--font-mono);
    font-size: 12px;
  }

  .err-actions {
    display: flex; justify-content: center; gap: 10px;
    flex-wrap: wrap;
  }
</style>

<div class="err-shell reveal">
  <div class="err-icon"><i class="ti ti-alert-triangle"></i></div>
  <span class="err-eyebrow">Error</span>
  <h1>${not empty errorTitle ? errorTitle : 'Something went wrong.'}</h1>
  <p>${not empty errorDetail ? errorDetail : 'An unexpected error interrupted your request. Try again in a moment, or head back to the home page.'}</p>

  <c:if test="${not empty errorClass or not empty errorPath}">
    <div class="err-card">
      <c:if test="${not empty errorPath}">
        <div class="err-row">
          <span class="lbl">Request path</span>
          <span class="val">${errorPath}</span>
        </div>
      </c:if>
      <c:if test="${not empty errorClass}">
        <div class="err-row">
          <span class="lbl">Type</span>
          <span class="val">${errorClass}</span>
        </div>
      </c:if>
      <c:if test="${not empty status}">
        <div class="err-row">
          <span class="lbl">Status</span>
          <span class="val">${status}</span>
        </div>
      </c:if>
    </div>
  </c:if>

  <div class="err-actions">
    <a href="${pageContext.request.contextPath}/" class="btn btn-primary btn-lg" data-antigravity>
      <i class="ti ti-home"></i> Back to home
    </a>
    <a href="javascript:history.back()" class="btn btn-glass btn-lg">
      <i class="ti ti-arrow-back-up"></i> Go back
    </a>
  </div>
</div>

<%@ include file="/WEB-INF/views/common/marketing-footer.jsp" %>
