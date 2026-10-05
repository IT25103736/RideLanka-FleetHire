<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">

<head>

  <meta charset="UTF-8"/>

  <meta name="viewport"
        content="width=device-width, initial-scale=1.0"/>

  <title>
    Create your RideLanka account — RideLanka FleetHire
  </title>


  <!-- Fonts -->
  <link rel="preconnect"
        href="https://fonts.googleapis.com"/>

  <link rel="preconnect"
        href="https://fonts.gstatic.com"
        crossorigin/>

  <link
          href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@500;600;700&family=Space+Grotesk:wght@500;600;700&family=Bebas+Neue&family=JetBrains+Mono:wght@400;500&display=swap"
          rel="stylesheet"/>


  <!-- Icons -->
  <link
          rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css"/>


  <!-- Main RideLanka theme -->
  <link
          rel="stylesheet"
          href="${pageContext.request.contextPath}/css/vrms-theme.css"/>


  <style>

    body {
      background: var(--bx-night);
    }


    /* ====================================================== */
    /* SPLIT SCREEN                                           */
    /* ====================================================== */

    .auth-split {
      display: grid;
      grid-template-columns: 1.05fr 1fr;
      min-height: 100dvh;
    }


    /* ====================================================== */
    /* LEFT POSTER                                            */
    /* ====================================================== */

    .auth-poster {

      position: relative;

      padding: 48px 56px;

      background:
              linear-gradient(
                      180deg,
                      rgba(5, 9, 18, 0.55) 0%,
                      rgba(5, 9, 18, 0.92) 100%
              ),
              url('${pageContext.request.contextPath}/images/hero-sunset-drive.png')
              center / cover no-repeat,
              var(--bx-night);

      color: #fff;

      display: flex;

      flex-direction: column;

      justify-content: space-between;

      overflow: hidden;
    }


    .auth-poster::after {

      content: "";

      position: absolute;

      inset: 0;

      pointer-events: none;

      background:
              radial-gradient(
                      50% 50% at 90% 10%,
                      rgba(111, 203, 163, 0.18) 0%,
                      transparent 60%
              );
    }


    /* ====================================================== */
    /* BRAND                                                  */
    /* ====================================================== */

    .auth-brand {

      display: flex;

      align-items: center;

      gap: 14px;

      position: relative;

      z-index: 1;
    }


    .auth-brand img {

      height: 52px;

      width: auto;

      border-radius: 14px;
    }


    .auth-brand__text {

      line-height: 1;

      display: flex;

      flex-direction: column;

      align-items: center;
    }


    .auth-brand__text .brand {

      font-family:
              'Space Grotesk',
              var(--font-sans);

      font-weight: 700;

      font-size: 22px;

      letter-spacing: 0.04em;

      color: #fff;
    }


    .auth-brand__text small {

      margin-top: 4px;

      font-family:
              'Space Grotesk',
              var(--font-sans);

      font-size: 9px;

      font-weight: 500;

      letter-spacing: 0.10em;

      text-transform: uppercase;

      color: var(--bx-primary);
    }


    /* ====================================================== */
    /* LEFT CONTENT                                           */
    /* ====================================================== */

    .auth-quote {

      position: relative;

      z-index: 1;

      margin-top: 36px;
    }


    .auth-eyebrow {

      display: inline-flex;

      align-items: center;

      gap: 8px;

      padding: 6px 14px;

      border-radius: 999px;

      background:
              rgba(111, 203, 163, 0.10);

      border:
              1px solid
              rgba(111, 203, 163, 0.24);

      font-size: 11px;

      font-weight: 600;

      letter-spacing: 0.18em;

      text-transform: uppercase;

      color: var(--bx-primary);

      margin-bottom: 22px;
    }


    .auth-quote h1 {

      font-family:
              'Manrope',
              var(--font-sans);

      font-size:
              clamp(
                      34px,
                      4.2vw,
                      56px
              );

      font-weight: 600;

      letter-spacing: -0.035em;

      line-height: 1.04;

      color: #fff;

      max-width: 14ch;
    }


    .auth-quote h1 em {

      font-style: normal;

      color: var(--bx-primary);
    }


    .auth-quote p {

      font-size: 15px;

      line-height: 1.7;

      color:
              rgba(
                      255,
                      255,
                      255,
                      0.70
              );

      margin-top: 22px;

      max-width: 40ch;
    }


    /* ====================================================== */
    /* PERKS                                                  */
    /* ====================================================== */

    .auth-perks {

      position: relative;

      z-index: 1;

      display: flex;

      flex-direction: column;

      gap: 12px;

      margin-top: 26px;
    }


    .auth-perks .perk {

      display: flex;

      align-items: center;

      gap: 12px;

      font-size: 14px;

      color:
              rgba(
                      255,
                      255,
                      255,
                      0.88
              );
    }


    .auth-perks .perk i {

      width: 30px;

      height: 30px;

      border-radius: 50%;

      background:
              rgba(
                      111,
                      203,
                      163,
                      0.18
              );

      border:
              1px solid
              rgba(
                      111,
                      203,
                      163,
                      0.32
              );

      display: inline-flex;

      align-items: center;

      justify-content: center;

      font-size: 14px;

      color: var(--bx-primary);

      flex-shrink: 0;
    }


    /* ====================================================== */
    /* POSTER FOOTER                                          */
    /* ====================================================== */

    .auth-foot {

      position: relative;

      z-index: 1;

      display: flex;

      justify-content: space-between;

      font-family: var(--font-mono);

      font-size: 11px;

      color:
              rgba(
                      255,
                      255,
                      255,
                      0.42
              );

      letter-spacing: 0.04em;

      border-top:
              1px solid
              rgba(
                      255,
                      255,
                      255,
                      0.10
              );

      padding-top: 18px;
    }


    /* ====================================================== */
    /* RIGHT COLUMN                                           */
    /* ====================================================== */

    .auth-form-col {

      display: flex;

      align-items: center;

      justify-content: center;

      padding: 48px 56px;

      background: var(--bx-night);
    }


    .auth-form-shell {

      width: 100%;

      max-width: 460px;
    }


    .auth-form-shell h2 {

      font-family:
              'Manrope',
              var(--font-sans);

      font-size: 38px;

      font-weight: 600;

      letter-spacing: -0.030em;

      line-height: 1.1;

      color: #fff;
    }


    .auth-form-shell h2 em {

      font-style: normal;

      color: var(--bx-primary);
    }


    .auth-form-shell .lede {

      font-size: 15px;

      color:
              rgba(
                      255,
                      255,
                      255,
                      0.65
              );

      margin-top: 12px;

      line-height: 1.6;
    }


    /* ====================================================== */
    /* GLASS FORM                                             */
    /* ====================================================== */

    .auth-form {

      margin-top: 28px;

      padding: 28px;

      background: var(--glass-bg);

      -webkit-backdrop-filter:
              blur(20px)
              saturate(180%);

      backdrop-filter:
              blur(20px)
              saturate(180%);

      border:
              1px solid
              var(--glass-border);

      border-radius:
              var(--r-shell);

      box-shadow:
              var(--glass-shadow);
    }


    /* ====================================================== */
    /* FORM FIELDS                                            */
    /* ====================================================== */

    .auth-fld {

      display: flex;

      flex-direction: column;

      gap: 6px;

      margin-bottom: 18px;
    }


    .auth-fld:last-of-type {

      margin-bottom: 26px;
    }


    .auth-fld__lbl {

      font-size: 10px;

      letter-spacing: 0.14em;

      text-transform: uppercase;

      font-weight: 600;

      color:
              rgba(
                      255,
                      255,
                      255,
                      0.55
              );
    }


    .auth-fld__lbl .req {

      color: var(--bx-danger);

      margin-left: 3px;
    }


    .auth-fld input {

      width: 100%;

      background:
              rgba(
                      255,
                      255,
                      255,
                      0.04
              );

      border:
              1px solid
              var(--glass-border);

      border-radius:
              var(--r-md);

      color: #fff;

      font-family:
              var(--font-sans);

      font-size: 14px;

      padding: 12px 14px;

      outline: none;

      transition:
              border-color var(--t-fast),
              background var(--t-fast),
              box-shadow var(--t-fast);
    }


    .auth-fld input:focus {

      border-color:
              var(--bx-primary);

      background:
              rgba(
                      111,
                      203,
                      163,
                      0.06
              );

      box-shadow:
              0 0 0 3px
              rgba(
                      111,
                      203,
                      163,
                      0.08
              );
    }


    .auth-fld input::placeholder {

      color:
              rgba(
                      255,
                      255,
                      255,
                      0.34
              );
    }


    /* Invalid only after user enters something */
    .auth-fld input:not(:placeholder-shown):invalid {

      border-color:
              rgba(
                      248,
                      113,
                      113,
                      0.72
              );
    }


    .auth-fld input:not(:placeholder-shown):valid {

      border-color:
              rgba(
                      111,
                      203,
                      163,
                      0.56
              );
    }


    .auth-fld__hint {

      font-size: 11px;

      color:
              rgba(
                      255,
                      255,
                      255,
                      0.50
              );

      margin-top: 4px;

      line-height: 1.5;
    }


    /* ====================================================== */
    /* PASSWORD FIELD                                         */
    /* ====================================================== */

    .password-wrap {

      position: relative;
    }


    .password-wrap input {

      padding-right: 54px;
    }


    .password-toggle {

      position: absolute;

      right: 10px;

      top: 50%;

      transform:
              translateY(-50%);

      width: 34px;

      height: 34px;

      border: none;

      border-radius: 50%;

      display: inline-flex;

      align-items: center;

      justify-content: center;

      background:
              rgba(
                      255,
                      255,
                      255,
                      0.06
              );

      color:
              rgba(
                      255,
                      255,
                      255,
                      0.64
              );

      cursor: pointer;
    }


    .password-toggle:hover {

      background:
              rgba(
                      111,
                      203,
                      163,
                      0.12
              );

      color: var(--bx-primary);
    }


    /* ====================================================== */
    /* BUTTON                                                 */
    /* ====================================================== */

    .auth-cta {

      width: 100%;

      justify-content: center;
    }


    /* ====================================================== */
    /* SWITCH LINK                                            */
    /* ====================================================== */

    .auth-switch {

      text-align: center;

      font-size: 14px;

      color:
              rgba(
                      255,
                      255,
                      255,
                      0.60
              );

      margin-top: 24px;
    }


    .auth-switch a {

      color: var(--bx-primary);

      font-weight: 600;

      text-decoration: none;

      border-bottom:
              1px solid
              rgba(
                      111,
                      203,
                      163,
                      0.32
              );

      transition:
              border-color
              var(--t-fast);
    }


    .auth-switch a:hover {

      border-color:
              var(--bx-primary);
    }


    /* ====================================================== */
    /* ALERTS                                                 */
    /* ====================================================== */

    .auth-alert {

      padding: 12px 14px;

      border-radius:
              var(--r-md);

      display: flex;

      gap: 10px;

      align-items: flex-start;

      font-size: 13px;

      margin-bottom: 18px;

      line-height: 1.5;
    }


    .auth-alert i {

      font-size: 18px;

      flex-shrink: 0;

      margin-top: 1px;
    }


    .auth-alert--err {

      background:
              rgba(
                      248,
                      113,
                      113,
                      0.10
              );

      border:
              1px solid
              rgba(
                      248,
                      113,
                      113,
                      0.32
              );

      color:
              rgba(
                      255,
                      255,
                      255,
                      0.85
              );
    }


    .auth-alert--err i {

      color: var(--bx-danger);
    }


    .auth-alert strong {

      color: #fff;
    }


    /* ====================================================== */
    /* RESPONSIVE                                             */
    /* ====================================================== */

    @media (max-width: 900px) {

      .auth-split {

        grid-template-columns: 1fr;
      }


      .auth-poster {

        padding: 36px 24px;

        min-height: 320px;
      }


      .auth-form-col {

        padding: 36px 24px;
      }


      .auth-quote {

        margin-top: 24px;
      }


      .auth-quote h1 {

        font-size: 32px;
      }


      .auth-form {

        padding: 22px;
      }

    }

  </style>

</head>


<body>


<div class="auth-split">


  <!-- ==================================================== -->
  <!-- LEFT POSTER                                          -->
  <!-- ==================================================== -->

  <aside class="auth-poster">


    <a
            href="${pageContext.request.contextPath}/"
            class="auth-brand"
            style="text-decoration:none;">


      <img
              src="${pageContext.request.contextPath}/images/vrms-logo.png"
              alt="RideLanka FleetHire"/>


      <div class="auth-brand__text">

        <span class="brand">
          RideLanka FleetHire
        </span>

        <small>
          &mdash; Vehicle Rental &mdash;
        </small>

      </div>

    </a>



    <div>


      <div class="auth-quote">

        <span class="auth-eyebrow">
          Complimentary membership
        </span>


        <h1>
          Join RideLanka,
          <br/>
          and start
          <em>your journey.</em>
        </h1>


        <p>

          Create your RideLanka account to manage
          reservations, payments and feedback from one place.

        </p>

      </div>



      <div class="auth-perks">


        <div class="perk">

          <i class="ti ti-check"></i>

          Book for any occasion

        </div>


        <div class="perk">

          <i class="ti ti-check"></i>

          Safe reservation history

        </div>


        <div class="perk">

          <i class="ti ti-check"></i>

          Choose your ride

        </div>


      </div>


    </div>



    <div class="auth-foot">

      <span>
        [ No card required ]
      </span>

      <span>
        v. 3.0 &mdash; Seafoam
      </span>

    </div>


  </aside>



  <!-- ==================================================== -->
  <!-- RIGHT FORM                                           -->
  <!-- ==================================================== -->

  <section class="auth-form-col">


    <div class="auth-form-shell">


      <h2>
        Open
        <em>an account.</em>
      </h2>


      <p class="lede">

        Create a customer account for reservations,
        payments and feedback.

      </p>



      <div class="auth-form">


        <!-- ============================================== -->
        <!-- ERROR MESSAGE - JSTL ONLY                     -->
        <!-- ============================================== -->

        <c:if test="${not empty param.error}">


          <div class="auth-alert auth-alert--err">


            <i class="ti ti-alert-circle"></i>


            <div>


              <strong>
                Account not created.
              </strong>

              <br/>


              <c:choose>


                <c:when test="${param.error == 'emailExists'}">

                  This email is already registered.
                  Try signing in instead.

                </c:when>


                <c:when test="${param.error == 'weakPassword'}">

                  Password must be at least 8 characters
                  and contain at least one letter and one number.

                </c:when>


                <c:when test="${param.error == 'invalidName'}">

                  Please enter a valid full name.

                </c:when>


                <c:when test="${param.error == 'invalidEmail'}">

                  Please enter a valid email address.

                </c:when>


                <c:when test="${param.error == 'invalidPhone'}">

                  Please enter a valid Sri Lankan mobile number,
                  for example 0771234567 or +94771234567.

                </c:when>


                <c:when test="${param.error == 'invalidLicense'}">

                  Please enter a valid driving licence / ID number.

                </c:when>


                <c:when test="${param.error == 'db'}">

                  The account could not be saved to MSSQL.
                  Check the application console for the database error.

                </c:when>


                <c:otherwise>

                  Registration could not be completed.
                  Please check the form and try again.

                </c:otherwise>


              </c:choose>


            </div>


          </div>


        </c:if>



        <!-- ============================================== -->
        <!-- REGISTRATION FORM                             -->
        <!-- ============================================== -->

        <form
                id="registerForm"
                action="${pageContext.request.contextPath}/user/register"
                method="post">


          <!-- ============================================ -->
          <!-- FULL NAME                                    -->
          <!-- ============================================ -->

          <div class="auth-fld">


            <label
                    class="auth-fld__lbl"
                    for="name">

              Full name

              <span class="req">*</span>

            </label>


            <input
                    type="text"
                    id="name"
                    name="name"
                    value="<c:out value='${param.name}'/>"
                    placeholder="e.g. Kamal Perera"
                    minlength="2"
                    maxlength="120"
                    autocomplete="name"
                    required
                    autofocus
            />


            <div class="auth-fld__hint">

              Enter your full name.
              Use 2–120 characters.

            </div>


          </div>



          <!-- ============================================ -->
          <!-- EMAIL                                        -->
          <!-- ============================================ -->

          <div class="auth-fld">


            <label
                    class="auth-fld__lbl"
                    for="email">

              Email address

              <span class="req">*</span>

            </label>


            <input
                    type="email"
                    id="email"
                    name="email"
                    value="<c:out value='${param.email}'/>"
                    placeholder="kamal@example.com"
                    maxlength="180"
                    autocomplete="email"
                    required
            />


            <div class="auth-fld__hint">

              Example: kamal@example.com

            </div>


          </div>



          <!-- ============================================ -->
          <!-- PHONE                                        -->
          <!-- ============================================ -->

          <div class="auth-fld">


            <label
                    class="auth-fld__lbl"
                    for="phone">

              Phone number

              <span class="req">*</span>

            </label>


            <input
                    type="tel"
                    id="phone"
                    name="phone"
                    value="<c:out value='${param.phone}'/>"
                    placeholder="077 123 4567"
                    maxlength="16"
                    pattern="(?:\+94|94|0)7[0-9](?:[ -]?[0-9]){7}"
                    title="Enter a valid Sri Lankan mobile number such as 0771234567 or +94771234567."
                    inputmode="tel"
                    autocomplete="tel"
                    required
            />


            <div class="auth-fld__hint">

              Accepted:
              0771234567,
              077 123 4567,
              +94771234567.

            </div>


          </div>



          <!-- ============================================ -->
          <!-- DRIVING LICENCE                              -->
          <!-- ============================================ -->

          <div class="auth-fld">


            <label
                    class="auth-fld__lbl"
                    for="licenseNo">

              Driving licence / ID

              <span class="req">*</span>

            </label>


            <input
                    type="text"
                    id="licenseNo"
                    name="licenseNo"
                    value="<c:out value='${param.licenseNo}'/>"
                    placeholder="B1234567"
                    minlength="3"
                    maxlength="80"
                    pattern="[A-Za-z0-9/ -]{3,80}"
                    title="Use 3 to 80 letters, numbers, spaces, hyphens or slashes."
                    autocomplete="off"
                    required
            />


            <div class="auth-fld__hint">

              Enter a valid driving licence
              or identification number.

            </div>


          </div>



          <!-- ============================================ -->
          <!-- PASSWORD                                     -->
          <!-- ============================================ -->

          <div class="auth-fld">


            <label
                    class="auth-fld__lbl"
                    for="password">

              Password

              <span class="req">*</span>

            </label>


            <div class="password-wrap">


              <input
                      type="password"
                      id="password"
                      name="password"
                      placeholder="Min. 8 characters, include a number"
                      minlength="8"
                      maxlength="128"
                      pattern="(?=.*[A-Za-z])(?=.*[0-9]).{8,128}"
                      title="Password must contain at least 8 characters, one letter and one number."
                      autocomplete="new-password"
                      required
              />


              <button
                      type="button"
                      id="passwordToggle"
                      class="password-toggle"
                      aria-label="Show or hide password">

                <i
                        id="passwordToggleIcon"
                        class="ti ti-eye">
                </i>

              </button>


            </div>


            <div class="auth-fld__hint">

              Choose something memorable &mdash;
              at least eight characters with at least
              one letter and one number.

            </div>


          </div>



          <!-- ============================================ -->
          <!-- CONFIRM PASSWORD                             -->
          <!-- ============================================ -->

          <div class="auth-fld">


            <label
                    class="auth-fld__lbl"
                    for="confirmPassword">

              Confirm password

              <span class="req">*</span>

            </label>


            <input
                    type="password"
                    id="confirmPassword"

                    placeholder="Enter password again"

                    minlength="8"
                    maxlength="128"

                    autocomplete="new-password"

                    required
            />


            <div class="auth-fld__hint">

              Re-enter the same password.

            </div>


          </div>



          <!-- ============================================ -->
          <!-- CREATE ACCOUNT                               -->
          <!-- ============================================ -->

          <button
                  type="submit"
                  class="btn btn-primary btn-lg auth-cta"
                  data-antigravity>

            Create account

            <span class="ico-pill">

              <i class="ti ti-arrow-right"></i>

            </span>

          </button>


        </form>



        <!-- ============================================== -->
        <!-- SIGN IN LINK                                   -->
        <!-- ============================================== -->

        <div class="auth-switch">

          Already a member?

          <a
                  href="${pageContext.request.contextPath}/login">

            Sign in instead

          </a>

        </div>


      </div>


    </div>


  </section>


</div>



<!-- ====================================================== -->
<!-- FORM VALIDATION                                        -->
<!-- ====================================================== -->

<script>

  document.addEventListener(
          "DOMContentLoaded",
          function () {


            const form =
                    document.getElementById(
                            "registerForm"
                    );


            const nameInput =
                    document.getElementById(
                            "name"
                    );


            const emailInput =
                    document.getElementById(
                            "email"
                    );


            const phoneInput =
                    document.getElementById(
                            "phone"
                    );


            const licenseInput =
                    document.getElementById(
                            "licenseNo"
                    );


            const passwordInput =
                    document.getElementById(
                            "password"
                    );


            const confirmPasswordInput =
                    document.getElementById(
                            "confirmPassword"
                    );


            const passwordToggle =
                    document.getElementById(
                            "passwordToggle"
                    );


            const passwordToggleIcon =
                    document.getElementById(
                            "passwordToggleIcon"
                    );



            /* ========================================== */
            /* PHONE                                      */
            /* ========================================== */

            phoneInput.addEventListener(
                    "input",
                    function () {


                      phoneInput.setCustomValidity("");


                      if (
                              phoneInput.value.trim() !== ""
                              &&
                              !phoneInput.validity.valid
                      ) {

                        phoneInput.setCustomValidity(
                                "Enter a valid Sri Lankan mobile number, for example 0771234567."
                        );

                      }


                    }
            );



            /* ========================================== */
            /* PASSWORD MATCH                             */
            /* ========================================== */

            function validatePasswordMatch() {


              confirmPasswordInput.setCustomValidity("");


              if (
                      confirmPasswordInput.value !== ""
                      &&
                      passwordInput.value
                      !==
                      confirmPasswordInput.value
              ) {

                confirmPasswordInput.setCustomValidity(
                        "Passwords do not match."
                );

              }


            }


            passwordInput.addEventListener(
                    "input",
                    validatePasswordMatch
            );


            confirmPasswordInput.addEventListener(
                    "input",
                    validatePasswordMatch
            );



            /* ========================================== */
            /* PASSWORD SHOW / HIDE                       */
            /* ========================================== */

            passwordToggle.addEventListener(
                    "click",
                    function () {


                      if (
                              passwordInput.type
                              ===
                              "password"
                      ) {

                        passwordInput.type =
                                "text";


                        passwordToggleIcon.className =
                                "ti ti-eye-off";

                      }

                      else {

                        passwordInput.type =
                                "password";


                        passwordToggleIcon.className =
                                "ti ti-eye";

                      }


                    }
            );



            /* ========================================== */
            /* SUBMIT                                     */
            /* ========================================== */

            form.addEventListener(
                    "submit",
                    function (event) {


                      nameInput.value =
                              nameInput.value.trim();


                      emailInput.value =
                              emailInput.value.trim();


                      phoneInput.value =
                              phoneInput.value.trim();


                      licenseInput.value =
                              licenseInput.value.trim();


                      validatePasswordMatch();


                      /*
                       * Re-check after trimming because
                       * validation must apply to final values.
                       */
                      if (!form.checkValidity()) {

                        event.preventDefault();

                        form.reportValidity();

                      }


                    }
            );


          }
  );

</script>


</body>

</html>