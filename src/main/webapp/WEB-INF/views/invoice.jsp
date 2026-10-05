<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Invoice" scope="request"/>
<c:set var="sectionName" value="Payments" scope="request"/>
<c:set var="activePage" value="payment" scope="request"/>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  /* ════════════════════════════════════════════════════════════
     RideLanka FleetHire Invoice
     Dark glass screen layout + clean print layout
     ════════════════════════════════════════════════════════════ */

  .iv-shell {
    max-width: 720px;
    margin: 0 auto;
  }

  .iv-card {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
    backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    overflow: hidden;
  }

  .iv-head {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    padding: 24px 28px 20px;
    border-bottom: 1px solid var(--glass-border);
  }

  .iv-head__brand {
    display: flex;
    align-items: center;
    gap: 14px;
  }

  .iv-head__brand img {
    height: 44px;
    width: auto;
    border-radius: 12px;
  }

  .iv-head__brand-text {
    line-height: 1.2;
  }

  .iv-head__brand-text .name {
    font-family: 'Space Grotesk', var(--font-sans);
    font-size: 20px;
    font-weight: 700;
    letter-spacing: 0.04em;
    color: #fff;
  }

  .iv-head__brand-text .addr {
    font-size: 12px;
    color: rgba(255,255,255,0.55);
    margin-top: 4px;
  }

  .iv-head__ref {
    text-align: right;
  }

  .iv-head__lbl {
    font-size: 10px;
    letter-spacing: 0.18em;
    text-transform: uppercase;
    color: rgba(255,255,255,0.5);
    font-weight: 700;
  }

  .iv-head__no {
    font-family: var(--font-mono);
    font-size: 22px;
    font-weight: 700;
    color: var(--bx-primary);
    margin-top: 4px;
    letter-spacing: 0.02em;
  }

  .iv-head__date {
    font-size: 12px;
    color: rgba(255,255,255,0.55);
    margin-top: 4px;
    font-family: var(--font-mono);
  }

  .iv-paid {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 4px 10px;
    margin-top: 10px;
    border-radius: var(--r-pill);
    background: rgba(111,203,163,0.14);
    color: var(--bx-primary);
    border: 1px solid rgba(111,203,163,0.32);
    font-size: 11px;
    font-weight: 600;
  }

  .iv-paid i {
    font-size: 12px;
  }

  /* Billing */

  .iv-bill {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 24px;
    padding: 20px 28px;
    border-bottom: 1px solid var(--glass-border);
  }

  .iv-bill__lbl {
    font-size: 10px;
    letter-spacing: 0.14em;
    text-transform: uppercase;
    color: rgba(255,255,255,0.5);
    font-weight: 700;
    margin-bottom: 8px;
  }

  .iv-bill__val {
    font-weight: 600;
    color: #fff;
  }

  .iv-bill__sub {
    font-size: 13px;
    color: rgba(255,255,255,0.65);
    margin-top: 4px;
  }

  .iv-bill strong {
    color: #fff;
  }

  /* Table */

  .iv-table {
    width: 100%;
    border-collapse: collapse;
  }

  .iv-table thead th {
    text-align: left;
    padding: 12px 28px;
    font-size: 10px;
    letter-spacing: 0.14em;
    text-transform: uppercase;
    color: rgba(255,255,255,0.5);
    font-weight: 700;
    background: rgba(255,255,255,0.02);
    border-bottom: 1px solid var(--glass-border);
  }

  .iv-table tbody td {
    padding: 14px 28px;
    font-size: 13px;
    color: rgba(255,255,255,0.78);
    border-bottom: 1px solid rgba(255,255,255,0.04);
  }

  .iv-table tbody tr:last-child td {
    border-bottom: 0;
  }

  .iv-mono {
    font-family: var(--font-mono);
  }

  .iv-discount {
    color: var(--bx-primary) !important;
  }

  .iv-promo-code {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 4px 9px;
    margin-left: 6px;
    border-radius: var(--r-pill);
    border: 1px solid rgba(111,203,163,0.28);
    background: rgba(111,203,163,0.08);
    color: var(--bx-primary);
    font-family: var(--font-mono);
    font-size: 11px;
    font-weight: 700;
  }

  /* Price summary */

  .iv-summary {
    padding: 16px 28px;
    border-top: 1px solid var(--glass-border);
  }

  .iv-summary__row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 20px;
    padding: 6px 0;
    font-size: 13px;
  }

  .iv-summary__label {
    color: rgba(255,255,255,0.6);
  }

  .iv-summary__value {
    color: #fff;
    font-family: var(--font-mono);
  }

  .iv-summary__row.is-discount .iv-summary__label,
  .iv-summary__row.is-discount .iv-summary__value {
    color: var(--bx-primary);
  }

  /* Total */

  .iv-total {
    display: flex;
    justify-content: flex-end;
    gap: 48px;
    padding: 22px 28px;
    background: rgba(111,203,163,0.06);
    border-top: 1px solid var(--glass-border);
    align-items: baseline;
  }

  .iv-total__lbl {
    font-size: 11px;
    letter-spacing: 0.18em;
    text-transform: uppercase;
    color: rgba(255,255,255,0.65);
    font-weight: 700;
  }

  .iv-total__val {
    font-family: var(--font-mono);
    font-size: 28px;
    font-weight: 700;
    color: var(--bx-primary);
    letter-spacing: -0.02em;
  }

  .iv-foot {
    padding: 16px 28px;
    border-top: 1px solid var(--glass-border);
    text-align: center;
    font-size: 12px;
    color: rgba(255,255,255,0.5);
  }

  @media (max-width: 640px) {
    .iv-head {
      flex-direction: column;
      gap: 18px;
    }

    .iv-head__ref {
      text-align: left;
    }

    .iv-bill {
      grid-template-columns: 1fr;
    }

    .iv-table {
      font-size: 12px;
    }

    .iv-table thead th,
    .iv-table tbody td {
      padding-left: 14px;
      padding-right: 14px;
    }

    .iv-total {
      justify-content: space-between;
      gap: 15px;
    }
  }

  /* Print */

  @media print {
    body {
      background: #fff !important;
      color: #000 !important;
    }

    .vrms-sidebar,
    .vrms-topbar,
    .page-header-row > div:last-child {
      display: none !important;
    }

    .vrms-main,
    .vrms-content {
      margin: 0 !important;
      padding: 0 !important;
      background: #fff !important;
    }

    .iv-card {
      background: #fff !important;
      border: 1px solid #ddd !important;
      box-shadow: none !important;
      backdrop-filter: none !important;
    }

    .iv-head,
    .iv-bill,
    .iv-table thead th,
    .iv-table tbody td,
    .iv-summary,
    .iv-total,
    .iv-foot {
      border-color: #ddd !important;
    }

    .iv-head__brand-text .name {
      color: #000 !important;
    }

    .iv-head__brand-text .addr,
    .iv-head__lbl,
    .iv-bill__lbl,
    .iv-bill__sub,
    .iv-table thead th,
    .iv-table tbody td,
    .iv-summary__label,
    .iv-foot {
      color: #444 !important;
    }

    .iv-bill__val,
    .iv-bill strong,
    .iv-summary__value {
      color: #000 !important;
    }

    .iv-head__no,
    .iv-total__val,
    .iv-discount {
      color: #2D5F4C !important;
    }

    .iv-total {
      background: #f3f7f5 !important;
    }

    .iv-paid,
    .iv-promo-code {
      background: #f3f7f5 !important;
      border-color: #c5e2d4 !important;
      color: #2D5F4C !important;
    }
  }
</style>


<c:set var="ivVehicleId"
       value="${not empty vehicleId
           ? vehicleId
           : (not empty param.vehicleId ? param.vehicleId : '—')}"/>

<c:set var="ivStartDate"
       value="${not empty startDate
           ? startDate
           : (not empty param.startDate ? param.startDate : '—')}"/>

<c:set var="ivEndDate"
       value="${not empty endDate
           ? endDate
           : (not empty param.endDate ? param.endDate : '—')}"/>

<c:set var="ivDuration"
       value="${not empty duration
           ? duration
           : (not empty param.duration ? param.duration : 1)}"/>

<c:set var="ivSubtotal"
       value="${not empty invoiceRecord
           ? invoiceRecord.subtotal
           : (not empty payment.amount ? payment.amount : 0)}"/>

<c:set var="ivDiscount"
       value="${not empty invoiceRecord
           ? invoiceRecord.discountAmount
           : 0}"/>

<c:set var="ivTax"
       value="${not empty invoiceRecord
           ? invoiceRecord.taxAmount
           : 0}"/>

<c:set var="ivAdditional"
       value="${not empty invoiceRecord
           ? invoiceRecord.additionalCharges
           : 0}"/>

<c:set var="ivAmount"
       value="${not empty invoiceRecord
           ? invoiceRecord.totalAmount
           : (not empty payment.amount ? payment.amount : 0)}"/>

<c:set var="ivPromoCode"
       value="${not empty invoiceRecord
           ? invoiceRecord.promoCode
           : ''}"/>

<c:set var="ivUnitRate"
       value="${ivDuration > 0 ? ivSubtotal / ivDuration : ivSubtotal}"/>


<div class="page-header-row reveal">

  <div class="page-header" style="margin-bottom:0;">
    <span class="eyebrow">Settlement receipt</span>
    <h1>Invoice<em>.</em></h1>
    <p>
      Payment receipt for your booking.
      Use the print button for a paper copy.
    </p>
  </div>

  <div style="display:flex; gap:8px;">

    <button
        type="button"
        onclick="window.print()"
        class="btn btn-secondary">
      <i class="ti ti-printer"></i>
      Print
    </button>

    <a
        href="${pageContext.request.contextPath}/booking?action=list"
        class="btn btn-primary"
        data-antigravity>

      <i class="ti ti-list-check"></i>
      My bookings
    </a>

  </div>
</div>


<div class="iv-shell">

  <div class="iv-card reveal">

    <!-- HEADER -->

    <div class="iv-head">

      <div class="iv-head__brand">

        <img
            src="${pageContext.request.contextPath}/images/vrms-logo.png"
            alt="RideLanka FleetHire"/>

        <div class="iv-head__brand-text">

          <span class="name">
            RideLanka FleetHire
          </span>

          <div class="addr">
            RideLanka FleetHire<br/>
            Colombo, Sri Lanka
          </div>

        </div>
      </div>


      <div class="iv-head__ref">

        <div class="iv-head__lbl">
          Invoice
        </div>

        <div class="iv-head__no">
          #
          <c:choose>
            <c:when test="${not empty invoiceRecord.invoiceId}">
              <c:out value="${invoiceRecord.invoiceId}"/>
            </c:when>

            <c:when test="${not empty payment.paymentId}">
              <c:out value="${payment.paymentId}"/>
            </c:when>

            <c:otherwise>
              INV-0000
            </c:otherwise>
          </c:choose>
        </div>

        <div class="iv-head__date">
          Date:
          <c:choose>
            <c:when test="${not empty invoiceRecord.invoiceDate}">
              <c:out value="${invoiceRecord.invoiceDate}"/>
            </c:when>

            <c:when test="${not empty payment.date}">
              <c:out value="${payment.date}"/>
            </c:when>

            <c:otherwise>
              —
            </c:otherwise>
          </c:choose>
        </div>

        <span class="iv-paid">
          <i class="ti ti-circle-check"></i>
          Paid
        </span>

      </div>
    </div>


    <!-- BILLING INFO -->

    <div class="iv-bill">

      <div>

        <div class="iv-bill__lbl">
          Billed to
        </div>

        <div class="iv-bill__val">
          <c:out value="${not empty payment.customerName
              ? payment.customerName
              : '—'}"/>
        </div>

      </div>


      <div>

        <div class="iv-bill__lbl">
          Booking details
        </div>

        <div class="iv-bill__sub">
          Booking ID:
          <strong class="iv-mono">
            <c:out value="${not empty bookingId
                ? bookingId
                : (not empty param.bookingId
                    ? param.bookingId
                    : '—')}"/>
          </strong>
        </div>

        <div class="iv-bill__sub"
             style="margin-top:4px;">

          Payment Method:

          <strong>
            <c:out value="${not empty paymentMethod
                ? paymentMethod
                : (not empty payment.paymentMethod
                    ? payment.paymentMethod
                    : '—')}"/>
          </strong>

        </div>

      </div>
    </div>


    <!-- RENTAL LINE -->

    <table class="iv-table">

      <thead>
        <tr>
          <th>Description</th>
          <th style="text-align:center;">
            Qty / Days
          </th>
          <th style="text-align:right;">
            Unit Rate
          </th>
          <th style="text-align:right;">
            Amount
          </th>
        </tr>
      </thead>

      <tbody>

        <tr>

          <td>

            <div style="font-weight:600; color:#fff;">
              Vehicle Rental —
              <c:out value="${ivVehicleId}"/>
            </div>

            <div style="
                font-size:11px;
                color:rgba(255,255,255,0.5);
                margin-top:2px;">

              <c:out value="${ivStartDate}"/>
              to
              <c:out value="${ivEndDate}"/>

            </div>

          </td>


          <td style="text-align:center;">
            <c:out value="${ivDuration}"/>
          </td>


          <td
              style="text-align:right;"
              class="iv-mono">

            LKR
            <fmt:formatNumber
                value="${ivUnitRate}"
                pattern="#,##0.00"/>

          </td>


          <td
              style="text-align:right;"
              class="iv-mono">

            LKR
            <fmt:formatNumber
                value="${ivSubtotal}"
                pattern="#,##0.00"/>

          </td>

        </tr>


        <!-- PROMO ROW -->

        <c:if test="${ivDiscount > 0}">

          <tr>

            <td colspan="3"
                style="text-align:right;"
                class="iv-discount">

              Promo Discount

              <c:if test="${not empty ivPromoCode}">
                <span class="iv-promo-code">
                  <i class="ti ti-tag"></i>
                  <c:out value="${ivPromoCode}"/>
                </span>
              </c:if>

            </td>


            <td
                style="text-align:right;"
                class="iv-mono iv-discount">

              - LKR
              <fmt:formatNumber
                  value="${ivDiscount}"
                  pattern="#,##0.00"/>

            </td>

          </tr>

        </c:if>

      </tbody>
    </table>


    <!-- PRICE BREAKDOWN -->

    <div class="iv-summary">

      <div class="iv-summary__row">

        <span class="iv-summary__label">
          Rental subtotal
        </span>

        <span class="iv-summary__value">
          LKR
          <fmt:formatNumber
              value="${ivSubtotal}"
              pattern="#,##0.00"/>
        </span>

      </div>


      <c:if test="${ivDiscount > 0}">

        <div class="iv-summary__row is-discount">

          <span class="iv-summary__label">

            Promo discount

            <c:if test="${not empty ivPromoCode}">
              (<c:out value="${ivPromoCode}"/>)
            </c:if>

          </span>


          <span class="iv-summary__value">

            - LKR
            <fmt:formatNumber
                value="${ivDiscount}"
                pattern="#,##0.00"/>

          </span>

        </div>

      </c:if>


      <c:if test="${ivTax > 0}">

        <div class="iv-summary__row">

          <span class="iv-summary__label">
            Tax
          </span>

          <span class="iv-summary__value">

            LKR
            <fmt:formatNumber
                value="${ivTax}"
                pattern="#,##0.00"/>

          </span>

        </div>

      </c:if>


      <c:if test="${ivAdditional > 0}">

        <div class="iv-summary__row">

          <span class="iv-summary__label">
            Additional charges
          </span>

          <span class="iv-summary__value">

            LKR
            <fmt:formatNumber
                value="${ivAdditional}"
                pattern="#,##0.00"/>

          </span>

        </div>

      </c:if>

    </div>


    <!-- FINAL TOTAL -->

    <div class="iv-total">

      <span class="iv-total__lbl">
        Total Paid
      </span>

      <span class="iv-total__val">

        LKR
        <fmt:formatNumber
            value="${ivAmount}"
            pattern="#,##0.00"/>

      </span>

    </div>


    <div class="iv-foot">

      Thank you for choosing
      RideLanka FleetHire.

      This is a computer-generated invoice.

    </div>

  </div>
</div>


<%@ include file="/WEB-INF/views/common/footer.jsp" %>