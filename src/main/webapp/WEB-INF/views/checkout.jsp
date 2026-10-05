<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"  %>
<c:set var="pageTitle"   value="Checkout"  scope="request"/>
<c:set var="sectionName" value="Wallet"     scope="request"/>
<c:set var="activePage"  value="payment"    scope="request"/>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  /* ════════════════════════════════════════════════════════════
     Checkout — dark+glass payment flow
     ════════════════════════════════════════════════════════════ */
  .ck-grid {
    display: grid;
    grid-template-columns: 1fr 360px;
    gap: 22px;
    align-items: start;
  }
  @media (max-width: 980px) { .ck-grid { grid-template-columns: 1fr; } }

  /* Form card */
  .ck-card {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
            backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow);
    overflow: hidden;
  }
  .ck-card__head {
    display: flex; align-items: center; justify-content: space-between;
    padding: 18px 24px;
    border-bottom: 1px solid var(--glass-border);
  }
  .ck-card__head h3 {
    font-family: var(--font-sans);
    font-size: 14px; font-weight: 600; color: #fff;
    display: inline-flex; align-items: center; gap: 8px;
  }
  .ck-card__head h3 i { color: var(--bx-primary); font-size: 16px; }
  .ck-secure {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 4px 10px;
    background: rgba(111,203,163,0.14);
    color: var(--bx-primary);
    border: 1px solid rgba(111,203,163,0.32);
    border-radius: var(--r-pill);
    font-size: 11px; font-weight: 600;
  }
  .ck-card__body { padding: 24px; }

  /* Method picker */
  .ck-method { display: flex; gap: 12px; }
  .ck-method label {
    flex: 1; min-width: 0;
    display: flex; align-items: center; gap: 12px;
    padding: 14px 16px;
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-md);
    cursor: pointer;
    transition: border-color var(--t-fast), background var(--t-fast);
  }
  .ck-method label:hover {
    border-color: rgba(111,203,163,0.32);
    background: rgba(111,203,163,0.04);
  }
  .ck-method label.is-active {
    border-color: var(--bx-primary);
    background: rgba(111,203,163,0.10);
  }
  .ck-method input[type="radio"] { position: absolute; opacity: 0; pointer-events: none; }
  .ck-method .ico {
    width: 36px; height: 36px; flex-shrink: 0;
    border-radius: 10px;
    background: rgba(111,203,163,0.16);
    border: 1px solid rgba(111,203,163,0.24);
    color: var(--bx-primary);
    display: inline-flex; align-items: center; justify-content: center;
    font-size: 18px;
  }
  .ck-method label.is-active .ico { background: var(--bx-primary); color: var(--bx-night); border-color: transparent; }
  .ck-method .t { font-size: 13px; font-weight: 600; color: #fff; }
  .ck-method .s { font-size: 11px; color: rgba(255,255,255,0.55); margin-top: 2px; }

  /* Form fields */
  .ck-grid-fields {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
  }
  .ck-fld { display: flex; flex-direction: column; gap: 6px; }
  .ck-full { grid-column: 1 / -1; }
  .ck-fld__lbl {
    font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase;
    font-weight: 600; color: rgba(255,255,255,0.55);
  }
  .ck-fld__lbl .req { color: var(--bx-danger); margin-left: 3px; }
  .ck-fld input, .ck-fld select {
    width: 100%;
    background: rgba(255,255,255,0.04);
    border: 1px solid var(--glass-border);
    border-radius: var(--r-md);
    color: #fff;
    font-family: var(--font-sans);
    font-size: 14px;
    padding: 12px 14px;
    outline: none;
    transition: border-color var(--t-fast), background var(--t-fast);
    -webkit-appearance: none;
            appearance: none;
  }
  .ck-fld input:focus, .ck-fld select:focus {
    border-color: var(--bx-primary);
    background: rgba(111,203,163,0.06);
  }
  .ck-fld input::placeholder { color: rgba(255,255,255,0.34); }
  .ck-fld select option { background: var(--bx-paper); color: #fff; }

  .ck-divider {
    height: 1px;
    background: var(--glass-border);
    margin: 24px 0;
  }

  .ck-promo-row { display: flex; gap: 10px; }
  .ck-promo-row input { flex: 1; }
  .ck-promo-msg {
    font-size: 11px;
    color: var(--bx-primary);
    margin-top: 4px;
  }

  .ck-cta {
    width: 100%;
    justify-content: center;
  }

  .ck-secure-note {
    text-align: center;
    font-size: 11px;
    color: rgba(255,255,255,0.5);
    margin-top: 14px;
    letter-spacing: 0.04em;
  }

  /* Order summary postcard */
  .ck-stick {
    position: sticky;
    top: calc(var(--topbar-height) + 24px);
    display: flex; flex-direction: column; gap: 14px;
  }
  @media (max-width: 980px) { .ck-stick { position: static; } }

  .ck-order {
    background: var(--glass-bg-strong);
    -webkit-backdrop-filter: blur(28px) saturate(180%);
            backdrop-filter: blur(28px) saturate(180%);
    border: 1px solid var(--glass-border-top);
    border-radius: var(--r-shell);
    box-shadow: var(--glass-shadow-lg);
    padding: 26px;
  }
  .ck-order h3 {
    font-family: 'Manrope', var(--font-sans);
    font-size: 22px; font-weight: 600;
    color: #fff;
    letter-spacing: -0.018em;
  }
  .ck-order__meta {
    font-size: 11px; color: rgba(255,255,255,0.5);
    letter-spacing: 0.14em; text-transform: uppercase;
    margin-top: 4px;
  }
  .ck-order__row {
    display: flex; justify-content: space-between; align-items: center;
    padding: 10px 0; font-size: 13px;
    border-bottom: 1px solid var(--glass-border);
  }
  .ck-order__row:last-of-type { border-bottom: 0; }
  .ck-order__row .lbl { color: rgba(255,255,255,0.55); font-size: 11px; letter-spacing: 0.10em; text-transform: uppercase; font-weight: 600; }
  .ck-order__row .val { color: #fff; font-weight: 500; }
  .ck-order__row .mono { font-family: var(--font-mono); color: rgba(255,255,255,0.85); }

  .ck-total {
    margin-top: 18px;
    padding-top: 18px;
    border-top: 1px solid var(--glass-border);
  }
  .ck-total .lbl {
    font-size: 11px; color: rgba(255,255,255,0.55);
    letter-spacing: 0.18em; text-transform: uppercase; font-weight: 600;
  }
  .ck-total .val {
    font-family: var(--font-sans);
    font-size: 38px; font-weight: 700;
    line-height: 1;
    letter-spacing: -0.025em;
    color: var(--bx-primary);
    margin-top: 6px;
  }
  .ck-total .val sup {
    font-size: 13px; color: rgba(255,255,255,0.55);
    margin-right: 5px; font-weight: 500; vertical-align: top;
  }

  .ck-alert {
    padding: 14px 18px;
    border-radius: var(--r-md);
    display: flex; gap: 12px; align-items: flex-start;
    font-size: 13px;
    margin-bottom: 18px;
  }
  .ck-alert i { font-size: 18px; margin-top: 1px; flex-shrink: 0; }
  .ck-alert--err { background: rgba(248,113,113,0.10); border: 1px solid rgba(248,113,113,0.32); color: rgba(255,255,255,0.85); }
  .ck-alert--err i { color: var(--bx-danger); }
</style>

<div class="page-header reveal">
  <span class="eyebrow">Settlement</span>
  <h1>Checkout, <em>quietly secure.</em></h1>
  <p>Card, mobile wallet or bank transfer &mdash; payment details are validated server-side and sensitive card data is not stored.</p>
</div>

<c:if test="${not empty errorMsg}">
  <div class="ck-alert ck-alert--err"><i class="ti ti-alert-circle"></i><div>${errorMsg}</div></div>
</c:if>

<div class="ck-grid">

  <!-- Payment form -->
  <div class="ck-card reveal">
    <div class="ck-card__head">
      <h3><i class="ti ti-credit-card"></i> Payment method</h3>
      <span class="ck-secure"><i class="ti ti-shield-check"></i> Server validated</span>
    </div>
    <div class="ck-card__body">
      <%-- Checkout values come from MSSQL. Only bookingId is posted; amount and customer identity are revalidated server-side. --%>
      <c:set var="ckBookingId" value="${bookingId}"/>
      <c:set var="ckAmount" value="${amount}"/>
      <c:set var="ckCustomer" value="${customerName}"/>

      <form action="${pageContext.request.contextPath}/payment/process" method="post" id="paymentForm" onsubmit="return validatePayment()">
        <input type="hidden" name="bookingId" value="${ckBookingId}"/>

        <div class="ck-fld ck-full" style="margin-bottom:22px;">
          <label class="ck-fld__lbl">Select method<span class="req">*</span></label>
          <div class="ck-method">
            <label class="is-active" id="lbl-card">
              <input type="radio" name="paymentMethod" value="card" id="pay-card"
                     onchange="togglePayMethod()" checked/>
              <span class="ico"><i class="ti ti-credit-card"></i></span>
              <div>
                <div class="t">Credit / Debit Card</div>
                <div class="s">Visa, Mastercard</div>
              </div>
            </label>
            <label id="lbl-wallet">
              <input type="radio" name="paymentMethod" value="wallet" id="pay-wallet"
                     onchange="togglePayMethod()"/>
              <span class="ico"><i class="ti ti-wallet"></i></span>
              <div>
                <div class="t">Mobile Wallet</div>
                <div class="s">eZ Cash, FriMi</div>
              </div>
            </label>
            <label id="lbl-bank">
              <input type="radio" name="paymentMethod" value="bank_transfer" id="pay-bank" onchange="togglePayMethod()"/>
              <span class="ico"><i class="ti ti-building-bank"></i></span>
              <div><div class="t">Bank Transfer</div><div class="s">Finance verification</div></div>
            </label>
          </div>
        </div>

        <!-- Card fields -->
        <div id="card-fields">
          <div class="ck-grid-fields">
            <div class="ck-fld ck-full">
              <label class="ck-fld__lbl" for="cardHolderName">Card holder<span class="req">*</span></label>
              <input type="text" id="cardHolderName" name="cardHolderName"
                     placeholder="As printed on card" minlength="2" maxlength="80"
                     pattern="[A-Za-z .'-]{2,80}" autocomplete="cc-name"/>
            </div>
            <div class="ck-fld ck-full">
              <label class="ck-fld__lbl" for="cardNumber">Card number<span class="req">*</span></label>
              <input type="text" id="cardNumber" name="cardNumber"
                     placeholder="•••• •••• •••• ••••" maxlength="23" inputmode="numeric"
                     autocomplete="cc-number"
                     oninput="this.value=this.value.replace(/\D/g,'').slice(0,19).replace(/(\d{4})(?=\d)/g,'$1 ')"/>
            </div>
            <div class="ck-fld">
              <label class="ck-fld__lbl" for="expiryDate">Expiry<span class="req">*</span></label>
              <input type="month" id="expiryDate" name="expiryDate"
                     autocomplete="cc-exp"/>
            </div>
            <div class="ck-fld">
              <label class="ck-fld__lbl" for="cvv">CVV<span class="req">*</span></label>
              <input type="password" id="cvv" name="cvv"
                     placeholder="•••" minlength="3" maxlength="4" inputmode="numeric"
                     pattern="[0-9]{3,4}" autocomplete="cc-csc"/>
            </div>
          </div>
        </div>

        <!-- Wallet fields -->
        <div id="wallet-fields" style="display:none;">
          <div class="ck-grid-fields">
            <div class="ck-fld ck-full">
              <label class="ck-fld__lbl" for="walletType">Wallet provider<span class="req">*</span></label>
              <select id="walletType" name="walletType">
                <option value="">— Select wallet —</option>
                <option value="eZCash">eZ Cash</option>
                <option value="FriMi">FriMi</option>
                <option value="Genie">Genie</option>
              </select>
            </div>
            <div class="ck-fld">
              <label class="ck-fld__lbl" for="walletNumber">Wallet number<span class="req">*</span></label>
              <input type="tel" id="walletNumber" name="walletNumber"
                     placeholder="0771234567" maxlength="10" inputmode="numeric"
                     pattern="[0-9]*"
                     oninput="this.value=this.value.replace(/\D/g,'')"/>
            </div>

          </div>
        </div>

        <!-- Bank transfer fields -->
        <div id="bank-fields" style="display:none;">
          <div class="ck-grid-fields">
            <div class="ck-fld ck-full">
              <label class="ck-fld__lbl" for="transferReference">Transfer reference<span class="req">*</span></label>
              <input type="text" id="transferReference" name="transferReference" maxlength="100" placeholder="Bank receipt / transaction reference"/>
              <small style="font-size:11px;color:rgba(255,255,255,0.5);">The booking remains pending until Finance approves this reference.</small>
            </div>
          </div>
        </div>

        <div class="ck-divider"></div>

        <div class="ck-fld ck-full" id="promo-block" style="margin-bottom:24px;">
          <label class="ck-fld__lbl">Promo code <small style="font-weight:400;color:rgba(255,255,255,0.45);">(card/wallet)</small></label>
          <div class="ck-promo-row">
            <input type="text" name="promoCode" placeholder="Enter code…" maxlength="40"
                   value="${param.promoCode}"/>
            <button type="button" class="btn btn-secondary" onclick="applyPromo()">Apply</button>
          </div>
          <c:if test="${not empty promoMsg}">
            <span class="ck-promo-msg">${promoMsg}</span>
          </c:if>
        </div>

        <button type="submit" id="payBtn" class="btn btn-primary btn-lg ck-cta" data-antigravity>
          <i class="ti ti-lock" id="payIcon"></i>
          <span id="payText">Pay securely</span>
          <span class="ico-pill"><i class="ti ti-arrow-right"></i></span>
        </button>

        <p class="ck-secure-note">
          <i class="ti ti-shield-check"></i> The application never stores the full card number or CVV; MSSQL stores only the payment result/reference.
        </p>
      </form>
    </div>
  </div>

  <!-- Order summary -->
  <div class="ck-stick">
    <div class="ck-order reveal">
      <h3>Order</h3>
      <div class="ck-order__meta">Reference summary</div>

      <div style="margin-top:18px;">
        <div class="ck-order__row">
          <span class="lbl">Booking</span>
          <span class="mono">${not empty ckBookingId ? ckBookingId : '—'}</span>
        </div>
        <div class="ck-order__row">
          <span class="lbl">Member</span>
          <span class="val">${ckCustomer}</span>
        </div>
      </div>

      <div class="ck-total">
        <div class="lbl">Total due</div>
        <div class="val"><sup>LKR</sup><fmt:formatNumber value="${ckAmount}" pattern="#,##0.00"/></div>
      </div>
    </div>


  </div>

</div>

<script>
  function togglePayMethod() {
    var isCard = document.getElementById('pay-card').checked;
    var isWallet = document.getElementById('pay-wallet').checked;
    var isBank = document.getElementById('pay-bank').checked;
    document.getElementById('card-fields').style.display = isCard ? '' : 'none';
    document.getElementById('wallet-fields').style.display = isWallet ? '' : 'none';
    document.getElementById('bank-fields').style.display = isBank ? '' : 'none';
    document.getElementById('lbl-card').classList.toggle('is-active', isCard);
    document.getElementById('lbl-wallet').classList.toggle('is-active', isWallet);
    document.getElementById('lbl-bank').classList.toggle('is-active', isBank);
    document.getElementById('promo-block').style.opacity = isBank ? '0.55' : '1';
    document.querySelector('[name=promoCode]').disabled = isBank;
    document.getElementById('payText').innerText = isBank ? 'Submit transfer for verification' : 'Pay securely';

    // Keep browser validation aligned with the currently selected payment method.
    ['cardHolderName','cardNumber','expiryDate','cvv'].forEach(function(id){
      document.getElementById(id).required = isCard;
    });
    document.getElementById('walletType').required = isWallet;
    document.getElementById('walletNumber').required = isWallet;
    document.getElementById('transferReference').required = isBank;
  }

  function applyPromo() {
    if (document.getElementById('pay-bank').checked) {
      alert('Promo codes are applied to immediate card/wallet payments only.');
      return;
    }
    var code = document.querySelector('[name=promoCode]').value.trim();
    if (!code) { alert('Please enter a promo code.'); return; }
    alert('Promo code "' + code + '" will be validated server-side when payment is submitted.');
  }

  function validatePayment() {
    var isCard = document.getElementById('pay-card').checked;
    var isWallet = document.getElementById('pay-wallet').checked;
    var isBank = document.getElementById('pay-bank').checked;

    if (isCard) {
      var holder = document.getElementById('cardHolderName').value.trim();
      var cardNum = document.getElementById('cardNumber').value.replace(/\s/g, '');
      var expiry = document.getElementById('expiryDate').value.trim();
      var cvv = document.getElementById('cvv').value.trim();
      if (!/^[A-Za-z .'-]{2,80}$/.test(holder)) { alert('Please enter the cardholder name as printed on the card.'); return false; }
      if (!/^\d{13,19}$/.test(cardNum)) { alert('Please enter a valid 13–19 digit card number.'); return false; }
      if (!/^\d{4}-(0[1-9]|1[0-2])$/.test(expiry)) { alert('Please select a valid card expiry month.'); return false; }
      var expiryMonth = new Date(expiry + '-01T00:00:00');
      var now = new Date();
      var currentMonth = new Date(now.getFullYear(), now.getMonth(), 1);
      if (expiryMonth < currentMonth) { alert('The card has expired. Please choose a valid expiry month.'); return false; }
      if (!/^\d{3,4}$/.test(cvv)) { alert('Please enter a valid CVV.'); return false; }
    } else if (isWallet) {
      if (!document.getElementById('walletType').value) { alert('Please select a wallet provider.'); return false; }
      if (!/^(?:0)?7\d{8}$/.test(document.getElementById('walletNumber').value.trim())) { alert('Please enter a valid wallet mobile number.'); return false; }
    } else if (isBank) {
      if (!/^[A-Za-z0-9._\/-]{4,100}$/.test(document.getElementById('transferReference').value.trim())) {
        alert('Enter a valid bank transfer reference (4–100 letters/numbers).');
        return false;
      }
    }

    var btn = document.getElementById('payBtn');
    var icon = document.getElementById('payIcon');
    var text = document.getElementById('payText');
    btn.style.opacity = '0.85';
    btn.style.cursor = 'progress';
    icon.className = 'ti ti-loader';
    icon.style.animation = 'ridelanka-spin 1s linear infinite';
    text.innerText = isBank ? ' Submitting…' : ' Processing…';
    if (!document.getElementById('spinStyle')) {
      var style = document.createElement('style');
      style.id = 'spinStyle';
      style.innerHTML = '@keyframes ridelanka-spin { to { transform: rotate(360deg); } }';
      document.head.appendChild(style);
    }
    setTimeout(function() { btn.disabled = true; }, 50);
    return true;
  }

  (function configureExpiryMonth(){
    var expiry = document.getElementById('expiryDate');
    if (!expiry) return;
    var now = new Date();
    var yyyy = now.getFullYear();
    var mm = String(now.getMonth() + 1).padStart(2, '0');
    expiry.min = yyyy + '-' + mm;
    expiry.max = (yyyy + 20) + '-' + mm;
  })();

  togglePayMethod();
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
