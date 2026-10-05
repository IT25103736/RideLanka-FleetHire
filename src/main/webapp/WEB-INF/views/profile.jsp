
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>My Profile | RideLanka FleetHire</title>


    <!-- Fonts -->
    <link rel="preconnect"
          href="https://fonts.googleapis.com">

    <link rel="preconnect"
          href="https://fonts.gstatic.com"
          crossorigin>

    <link
            href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@500;600;700&family=Space+Grotesk:wght@500;600;700&family=JetBrains+Mono:wght@400;500&display=swap"
            rel="stylesheet">


    <!-- Icons -->
    <link
            rel="stylesheet"
            href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css">


    <!-- RideLanka shared theme -->
    <link
            rel="stylesheet"
            href="${pageContext.request.contextPath}/css/vrms-theme.css">


    <style>

        * {
            box-sizing: border-box;
        }

        html,
        body {
            margin: 0;
            min-height: 100%;
        }

        body {
            font-family: 'DM Sans', sans-serif;

            background:
                    radial-gradient(
                            circle at 10% 0%,
                            rgba(111, 203, 163, 0.11),
                            transparent 34%
                    ),
                    radial-gradient(
                            circle at 95% 20%,
                            rgba(66, 120, 255, 0.07),
                            transparent 32%
                    ),
                    var(--bx-night, #070b12);

            color: #ffffff;

            overflow-x: hidden;
        }

        button,
        input {
            font: inherit;
        }

        input {
            max-width: 100%;
        }


        /* ================================================= */
        /* PAGE SHELL                                        */
        /* ================================================= */

        .profile-shell {

            width:
                    min(
                            1180px,
                            calc(100% - 40px)
                    );

            margin: 0 auto;

            padding:
                    30px 0 60px;
        }


        /* ================================================= */
        /* TOP BAR                                           */
        /* ================================================= */

        .topbar {

            display: flex;

            align-items: center;

            justify-content: space-between;

            gap: 20px;

            padding: 18px 22px;

            margin-bottom: 28px;

            border:
                    1px solid
                    rgba(255, 255, 255, 0.10);

            border-radius: 18px;

            background:
                    rgba(255, 255, 255, 0.045);

            backdrop-filter:
                    blur(18px)
                    saturate(170%);

            -webkit-backdrop-filter:
                    blur(18px)
                    saturate(170%);

            box-shadow:
                    0 20px 45px
                    rgba(0, 0, 0, 0.20);
        }


        .brand {

            display: flex;

            align-items: center;

            gap: 14px;

            min-width: 0;

            text-decoration: none;
        }


        .brand img {

            width: 46px;

            height: 46px;

            object-fit: contain;

            border-radius: 13px;

            flex-shrink: 0;
        }


        .brand-copy {

            min-width: 0;
        }


        .brand-name {

            font-family:
                    'Space Grotesk',
                    sans-serif;

            font-size: 19px;

            font-weight: 700;

            letter-spacing: 0.02em;

            color: #ffffff;
        }


        .brand-sub {

            margin-top: 3px;

            font-size: 11px;

            color:
                    rgba(
                            255,
                            255,
                            255,
                            0.48
                    );
        }


        .top-actions {

            display: flex;

            align-items: center;

            justify-content: flex-end;

            gap: 10px;

            flex-wrap: wrap;
        }


        /* ================================================= */
        /* HERO                                              */
        /* ================================================= */

        .page-head {

            display: flex;

            align-items: flex-end;

            justify-content: space-between;

            gap: 24px;

            margin-bottom: 26px;
        }


        .eyebrow {

            display: inline-flex;

            align-items: center;

            gap: 8px;

            padding: 7px 12px;

            margin-bottom: 12px;

            border-radius: 999px;

            border:
                    1px solid
                    rgba(111, 203, 163, 0.24);

            background:
                    rgba(111, 203, 163, 0.09);

            color:
                    var(--bx-primary, #6fcba3);

            font-size: 10px;

            font-weight: 700;

            letter-spacing: 0.16em;

            text-transform: uppercase;
        }


        .page-head h1 {

            margin: 0;

            font-family:
                    'Manrope',
                    sans-serif;

            font-size:
                    clamp(
                            32px,
                            4vw,
                            52px
                    );

            font-weight: 600;

            line-height: 1.04;

            letter-spacing: -0.04em;
        }


        .page-head h1 em {

            font-style: normal;

            color:
                    var(--bx-primary, #6fcba3);
        }


        .page-description {

            margin:
                    12px 0 0;

            max-width: 680px;

            color:
                    rgba(
                            255,
                            255,
                            255,
                            0.58
                    );

            line-height: 1.65;

            font-size: 14px;
        }


        /* ================================================= */
        /* ALERTS                                            */
        /* ================================================= */

        .alerts {

            margin-bottom: 22px;
        }


        .alert {

            display: flex;

            align-items: flex-start;

            gap: 11px;

            padding: 13px 15px;

            margin-bottom: 10px;

            border-radius: 12px;

            font-size: 13px;

            line-height: 1.5;
        }


        .alert i {

            margin-top: 1px;

            font-size: 18px;

            flex-shrink: 0;
        }


        .alert-success {

            border:
                    1px solid
                    rgba(111, 203, 163, 0.30);

            background:
                    rgba(111, 203, 163, 0.09);

            color:
                    rgba(
                            255,
                            255,
                            255,
                            0.88
                    );
        }


        .alert-success i {

            color:
                    var(--bx-primary, #6fcba3);
        }


        .alert-danger {

            border:
                    1px solid
                    rgba(248, 113, 113, 0.30);

            background:
                    rgba(248, 113, 113, 0.09);

            color:
                    rgba(
                            255,
                            255,
                            255,
                            0.88
                    );
        }


        .alert-danger i {

            color: #f87171;
        }


        /* ================================================= */
        /* PROFILE LAYOUT                                    */
        /* ================================================= */

        .profile-grid {

            display: grid;

            grid-template-columns:
                    minmax(0, 2fr)
                    minmax(280px, 0.85fr);

            gap: 22px;

            align-items: start;
        }


        /* ================================================= */
        /* GLASS CARD                                        */
        /* ================================================= */

        .glass-card {

            min-width: 0;

            padding: 26px;

            border:
                    1px solid
                    rgba(255, 255, 255, 0.10);

            border-radius: 20px;

            background:
                    rgba(255, 255, 255, 0.045);

            backdrop-filter:
                    blur(20px)
                    saturate(175%);

            -webkit-backdrop-filter:
                    blur(20px)
                    saturate(175%);

            box-shadow:
                    0 20px 50px
                    rgba(0, 0, 0, 0.22);
        }


        .card-head {

            display: flex;

            align-items: flex-start;

            justify-content: space-between;

            gap: 18px;

            margin-bottom: 24px;
        }


        .card-kicker {

            margin-bottom: 5px;

            font-size: 10px;

            font-weight: 700;

            letter-spacing: 0.14em;

            text-transform: uppercase;

            color:
                    var(--bx-primary, #6fcba3);
        }


        .glass-card h2 {

            margin: 0;

            font-family:
                    'Manrope',
                    sans-serif;

            font-size: 22px;

            font-weight: 600;

            letter-spacing: -0.025em;
        }


        .card-description {

            margin:
                    7px 0 0;

            color:
                    rgba(
                            255,
                            255,
                            255,
                            0.50
                    );

            font-size: 13px;

            line-height: 1.55;
        }


        .card-icon {

            width: 46px;

            height: 46px;

            flex-shrink: 0;

            display: flex;

            align-items: center;

            justify-content: center;

            border-radius: 14px;

            background:
                    rgba(111, 203, 163, 0.10);

            border:
                    1px solid
                    rgba(111, 203, 163, 0.20);

            color:
                    var(--bx-primary, #6fcba3);

            font-size: 23px;
        }


        /* ================================================= */
        /* FORM                                              */
        /* ================================================= */

        .profile-form-grid {

            display: grid;

            grid-template-columns:
                    repeat(
                            2,
                            minmax(0, 1fr)
                    );

            gap: 18px;
        }


        .form-group {

            min-width: 0;
        }


        .form-group.full-width {

            grid-column: 1 / -1;
        }


        .form-group label {

            display: block;

            margin-bottom: 7px;

            font-size: 10px;

            font-weight: 700;

            letter-spacing: 0.13em;

            text-transform: uppercase;

            color:
                    rgba(
                            255,
                            255,
                            255,
                            0.56
                    );
        }


        .required {

            color: #f87171;
        }


        .form-group input {

            display: block;

            width: 100%;

            min-width: 0;

            max-width: 100%;

            padding: 12px 13px;

            border:
                    1px solid
                    rgba(255, 255, 255, 0.11);

            border-radius: 11px;

            outline: none;

            background:
                    rgba(255, 255, 255, 0.04);

            color: #ffffff;

            font-size: 14px;

            transition:
                    border-color 0.18s ease,
                    background 0.18s ease,
                    box-shadow 0.18s ease;
        }


        .form-group input::placeholder {

            color:
                    rgba(
                            255,
                            255,
                            255,
                            0.30
                    );
        }


        .form-group input:focus {

            border-color:
                    var(--bx-primary, #6fcba3);

            background:
                    rgba(111, 203, 163, 0.05);

            box-shadow:
                    0 0 0 3px
                    rgba(111, 203, 163, 0.08);
        }


        .form-group input:not(:placeholder-shown):invalid {

            border-color:
                    rgba(248, 113, 113, 0.70);
        }


        .form-group small {

            display: block;

            margin-top: 6px;

            color:
                    rgba(
                            255,
                            255,
                            255,
                            0.42
                    );

            font-size: 11px;

            line-height: 1.45;
        }


        .form-actions {

            grid-column: 1 / -1;

            display: flex;

            justify-content: flex-end;

            margin-top: 6px;
        }


        /* ================================================= */
        /* BUTTONS                                           */
        /* ================================================= */

        .btn {

            display: inline-flex;

            align-items: center;

            justify-content: center;

            gap: 8px;

            min-height: 42px;

            padding:
                    10px 15px;

            border-radius: 11px;

            border:
                    1px solid
                    transparent;

            text-decoration: none;

            cursor: pointer;

            font-size: 13px;

            font-weight: 700;

            transition:
                    transform 0.16s ease,
                    background 0.16s ease,
                    border-color 0.16s ease,
                    opacity 0.16s ease;
        }


        .btn:hover {

            transform:
                    translateY(-1px);
        }


        .btn-primary {

            background:
                    var(--bx-primary, #6fcba3);

            color: #07110d;

            border-color:
                    rgba(111, 203, 163, 0.75);
        }


        .btn-secondary {

            background:
                    rgba(255, 255, 255, 0.05);

            color:
                    rgba(
                            255,
                            255,
                            255,
                            0.82
                    );

            border-color:
                    rgba(255, 255, 255, 0.12);
        }


        .btn-danger {

            background:
                    rgba(248, 113, 113, 0.09);

            color: #fca5a5;

            border-color:
                    rgba(248, 113, 113, 0.27);
        }


        .btn-danger:hover {

            background:
                    rgba(248, 113, 113, 0.14);
        }


        /* ================================================= */
        /* ACCOUNT INFO CARD                                 */
        /* ================================================= */

        .profile-meta {

            display: flex;

            flex-direction: column;

            gap: 14px;
        }


        .meta-row {

            padding-bottom: 14px;

            border-bottom:
                    1px solid
                    rgba(255, 255, 255, 0.07);
        }


        .meta-row:last-child {

            border-bottom: none;

            padding-bottom: 0;
        }


        .meta-label {

            margin-bottom: 4px;

            font-size: 9px;

            font-weight: 700;

            letter-spacing: 0.13em;

            text-transform: uppercase;

            color:
                    rgba(
                            255,
                            255,
                            255,
                            0.38
                    );
        }


        .meta-value {

            font-size: 13px;

            color:
                    rgba(
                            255,
                            255,
                            255,
                            0.80
                    );

            overflow-wrap: anywhere;
        }


        .role-badge {

            display: inline-flex;

            align-items: center;

            padding: 5px 9px;

            border-radius: 999px;

            background:
                    rgba(111, 203, 163, 0.09);

            border:
                    1px solid
                    rgba(111, 203, 163, 0.22);

            color:
                    var(--bx-primary, #6fcba3);

            font-size: 10px;

            font-weight: 700;

            letter-spacing: 0.06em;
        }


        .verification-badge { display:inline-flex;align-items:center;gap:6px;padding:6px 10px;border-radius:999px;font-size:10px;font-weight:700;letter-spacing:.05em; }
        .verification-verified { color:var(--bx-primary,#6fcba3);background:rgba(111,203,163,.09);border:1px solid rgba(111,203,163,.24); }
        .verification-pending { color:#fcd34d;background:rgba(251,191,36,.09);border:1px solid rgba(251,191,36,.24); }
        .verification-rejected { color:#fca5a5;background:rgba(248,113,113,.09);border:1px solid rgba(248,113,113,.24); }

        .security-section {
            margin-top: 30px;
            padding-top: 26px;
            border-top: 1px solid rgba(255,255,255,0.08);
        }
        .security-section .security-head {
            display:flex; align-items:flex-start; justify-content:space-between; gap:16px; margin-bottom:20px;
        }
        .security-section .security-head h3 {
            margin:0; font:600 19px 'Manrope',sans-serif; letter-spacing:-0.02em;
        }
        .security-section .security-head p {
            margin:6px 0 0; color:rgba(255,255,255,.48); font-size:12px; line-height:1.55;
        }

        /* ================================================= */
        /* DANGER ZONE                                       */
        /* ================================================= */

        .danger-card {

            margin-top: 22px;

            border-color:
                    rgba(248, 113, 113, 0.16);
        }


        .danger-card .card-kicker {

            color: #fca5a5;
        }


        .danger-card .card-icon {

            background:
                    rgba(248, 113, 113, 0.08);

            border-color:
                    rgba(248, 113, 113, 0.20);

            color: #fca5a5;
        }


        .danger-note {

            padding: 14px;

            margin-top: 18px;

            border-radius: 12px;

            border:
                    1px solid
                    rgba(248, 113, 113, 0.18);

            background:
                    rgba(248, 113, 113, 0.06);

            color:
                    rgba(
                            255,
                            255,
                            255,
                            0.60
                    );

            font-size: 12px;

            line-height: 1.6;
        }


        /* ================================================= */
        /* RESPONSIVE                                        */
        /* ================================================= */

        @media (max-width: 900px) {

            .profile-grid {

                grid-template-columns: 1fr;
            }

        }


        @media (max-width: 700px) {

            .profile-shell {

                width:
                        min(
                                calc(100% - 24px),
                                1180px
                        );

                padding-top: 16px;
            }


            .topbar {

                align-items: flex-start;

                flex-direction: column;
            }


            .top-actions {

                width: 100%;

                justify-content: flex-start;
            }


            .page-head {

                align-items: flex-start;

                flex-direction: column;
            }


            .profile-form-grid {

                grid-template-columns: 1fr;
            }


            .form-group.full-width,
            .form-actions {

                grid-column: auto;
            }


            .form-actions {

                width: 100%;
            }


            .form-actions .btn {

                width: 100%;
            }


            .glass-card {

                padding: 20px;
            }

        }

    </style>

</head>


<body>


<div class="profile-shell">


    <!-- ================================================= -->
    <!-- TOP BAR                                           -->
    <!-- ================================================= -->

    <header class="topbar">


        <a href="${pageContext.request.contextPath}/"
           class="brand">


            <img
                    src="${pageContext.request.contextPath}/images/vrms-logo.png"
                    alt="RideLanka FleetHire">


            <div class="brand-copy">


                <div class="brand-name">
                    RideLanka FleetHire
                </div>


                <div class="brand-sub">
                    Customer Account
                </div>


            </div>


        </a>



        <div class="top-actions">


            <a
                    href="${pageContext.request.contextPath}${sessionScope.loggedUser.dashboardUrl}"
                    class="btn btn-secondary">

                <i class="ti ti-layout-dashboard"></i>

                Dashboard

            </a>


            <a
                    href="${pageContext.request.contextPath}/"
                    class="btn btn-secondary">

                <i class="ti ti-home"></i>

                Home

            </a>


        </div>


    </header>



    <!-- ================================================= -->
    <!-- PAGE HEADER                                       -->
    <!-- ================================================= -->

    <section class="page-head">


        <div>


            <div class="eyebrow">

                <i class="ti ti-user-circle"></i>

                Account Settings

            </div>


            <h1>
                My
                <em>Profile.</em>
            </h1>


            <p class="page-description">

                Keep your personal details up to date
                so your RideLanka reservations and account
                information remain accurate.

            </p>


        </div>


    </section>



    <!-- ================================================= -->
    <!-- MESSAGES                                          -->
    <!-- ================================================= -->

    <div class="alerts">


        <c:if test="${param.msg == 'updated'}">

            <div class="alert alert-success">

                <i class="ti ti-circle-check"></i>

                <div>
                    Profile updated successfully.
                </div>

            </div>

        </c:if>



        <c:if test="${not empty param.error}">


            <div class="alert alert-danger">


                <i class="ti ti-alert-circle"></i>


                <div>


                    <c:choose>


                        <c:when test="${param.error == 'invalidName'}">
                            Please enter a valid name between
                            2 and 120 characters.
                        </c:when>


                        <c:when test="${param.error == 'invalidEmail'}">
                            Please enter a valid email address.
                        </c:when>


                        <c:when test="${param.error == 'invalidPhone'}">
                            Please enter a valid Sri Lankan
                            mobile number, for example
                            0771234567 or +94771234567.
                        </c:when>


                        <c:when test="${param.error == 'invalidLicense'}">
                            Please enter a valid driving
                            licence / ID number.
                        </c:when>


                        <c:when test="${param.error == 'invalidDocument'}">
                            Please enter a valid NIC or passport number.
                            Use a 12-digit NIC, old NIC such as 901234567V,
                            or passport such as N1234567.
                        </c:when>

                        <c:when test="${param.error == 'invalidAddress'}">
                            Address must not exceed 220 characters.
                        </c:when>

                        <c:when test="${param.error == 'invalidCity'}">
                            Please enter a valid city name.
                        </c:when>

                        <c:when test="${param.error == 'invalidDob'}">
                            Please enter a valid date of birth.
                        </c:when>

                        <c:when test="${param.error == 'emailExists'}">
                            This email address is already being
                            used by another account.
                        </c:when>


                        <c:when test="${param.error == 'db'}">
                            A database error occurred.
                            Please try again.
                        </c:when>


                        <c:otherwise>
                            Profile update could not be completed.
                            Please check the entered information.
                        </c:otherwise>


                    </c:choose>


                </div>


            </div>


        </c:if>


    </div>



    <div class="profile-grid">


        <!-- ================================================= -->
        <!-- PROFILE FORM                                      -->
        <!-- ================================================= -->

        <section class="glass-card">


            <div class="card-head">


                <div>


                    <div class="card-kicker">
                        Personal details
                    </div>


                    <h2>
                        Edit Profile
                    </h2>


                    <p class="card-description">

                        Update your account information below.

                    </p>


                </div>


                <div class="card-icon">

                    <i class="ti ti-user-edit"></i>

                </div>


            </div>



            <form
                    action="${pageContext.request.contextPath}/user/update"
                    method="post"
                    id="profileForm">


                <div class="profile-form-grid">


                    <!-- NAME -->

                    <div class="form-group">


                        <label for="name">

                            Full Name

                            <span class="required">
                                *
                            </span>

                        </label>


                        <input
                                type="text"
                                id="name"
                                name="name"

                                value="<c:out value='${sessionScope.loggedUser.name}'/>"

                                minlength="2"
                                maxlength="120"

                                autocomplete="name"

                                required>


                        <small>
                            Enter your full name.
                        </small>


                    </div>



                    <!-- EMAIL -->

                    <div class="form-group">


                        <label for="email">

                            Email Address

                            <span class="required">
                                *
                            </span>

                        </label>


                        <input
                                type="email"
                                id="email"
                                name="email"

                                value="<c:out value='${sessionScope.loggedUser.email}'/>"

                                maxlength="180"

                                autocomplete="email"

                                required>


                        <small>
                            Example: customer@gmail.com
                        </small>


                    </div>



                    <!-- PHONE -->

                    <div class="form-group">


                        <label for="phone">

                            Mobile Number

                            <span class="required">
                                *
                            </span>

                        </label>


                        <input
                                type="tel"
                                id="phone"
                                name="phone"

                                value="<c:out value='${sessionScope.loggedUser.phone}'/>"

                                placeholder="0771234567"

                                maxlength="16"

                                pattern="(?:\+94|94|0)7[0-9](?:[ -]?[0-9]){7}"

                                title="Enter a valid Sri Lankan mobile number such as 0771234567 or +94771234567."

                                inputmode="tel"

                                autocomplete="tel"

                                required>


                        <small>
                            Accepted: 0771234567,
                            94771234567 or +94771234567.
                        </small>


                    </div>



                    <!-- LICENCE -->

                    <div class="form-group">


                        <label for="licenseNo">

                            Driving Licence / ID

                            <span class="required">
                                *
                            </span>

                        </label>


                        <input
                                type="text"
                                id="licenseNo"
                                name="licenseNo"

                                value="<c:out value='${sessionScope.loggedUser.licenseNo}'/>"

                                placeholder="B1234567"

                                minlength="3"
                                maxlength="80"

                                pattern="[A-Za-z0-9/ -]{3,80}"

                                title="Use 3 to 80 letters, numbers, spaces, hyphens or slashes."

                                autocomplete="off"

                                required>


                        <small>
                            Enter your driving licence or
                            identification number.
                        </small>


                    </div>



                    <c:if test="${sessionScope.loggedUser.role == 'CUSTOMER'}">

                        <div class="form-group">

                            <label for="idDocumentNo">
                                NIC / Passport Number
                            </label>

                            <input
                                    type="text"
                                    id="idDocumentNo"
                                    name="idDocumentNo"

                                    value="<c:out value='${customerProfile.idDocumentNo}'/>"

                                    minlength="8"
                                    maxlength="12"

                                    pattern="(?:[0-9]{12}|[0-9]{9}[VvXx]|[A-Za-z][0-9]{7})"

                                    placeholder="200012345678 / 901234567V / N1234567"

                                    title="Enter a valid NIC or passport number."

                                    autocomplete="off">

                            <small>
                                Accepted: 12-digit NIC, old NIC such as
                                901234567V, or passport such as N1234567.
                            </small>

                        </div>
                        </div>

                        <div class="form-group">
                            <label for="dateOfBirth">Date of Birth</label>
                            <input type="date" id="dateOfBirth" name="dateOfBirth"
                                   value="<c:out value='${customerProfile.dateOfBirth}'/>">
                            <small>Used only as part of your rental customer profile.</small>
                        </div>

                        <div class="form-group full-width">
                            <label for="addressLine">Residential Address</label>
                            <input type="text" id="addressLine" name="addressLine"
                                   value="<c:out value='${customerProfile.addressLine}'/>"
                                   maxlength="220" placeholder="House number, street and area">
                            <small>Maximum 220 characters.</small>
                        </div>

                        <div class="form-group">
                            <label for="city">City</label>
                            <input type="text" id="city" name="city"
                                   value="<c:out value='${customerProfile.city}'/>"
                                   minlength="2" maxlength="80" pattern="[A-Za-z0-9 .,'/-]{2,80}"
                                   placeholder="e.g. Kandy">
                        </div>

                    </c:if>

                    <!-- SUBMIT -->

                    <div class="form-actions">


                        <button
                                type="submit"
                                class="btn btn-primary">

                            <i class="ti ti-device-floppy"></i>

                            Update Profile

                        </button>


                    </div>


                </div>


            </form>

            <div class="security-section">
                <div class="security-head">
                    <div>
                        <div class="card-kicker">Security</div>
                        <h3>Change Password</h3>
                        <p>Confirm your current password before setting a new one.</p>
                    </div>
                    <div class="card-icon"><i class="ti ti-shield-lock"></i></div>
                </div>

                <c:if test="${param.passwordMsg == 'changed'}">
                    <div class="alert alert-success"><i class="ti ti-circle-check"></i><div>Password changed successfully. If email notifications are enabled, a security alert has been sent to your account email.</div></div>
                </c:if>

                <c:if test="${not empty param.passwordError}">
                    <div class="alert alert-danger"><i class="ti ti-alert-circle"></i><div><c:choose>
                        <c:when test="${param.passwordError == 'current'}">Your current password is incorrect.</c:when>
                        <c:when test="${param.passwordError == 'weak'}">New password must be 8–128 characters with at least one letter and one number.</c:when>
                        <c:when test="${param.passwordError == 'mismatch'}">The new password and confirmation do not match.</c:when>
                        <c:when test="${param.passwordError == 'same'}">Your new password must be different from your current password.</c:when>
                        <c:otherwise>Password could not be changed. Please try again.</c:otherwise>
                    </c:choose></div></div>
                </c:if>

                <form action="${pageContext.request.contextPath}/user/change-password" method="post" id="changePasswordForm">
                    <input type="hidden" name="email" value="">
                    <div class="profile-form-grid">
                        <div class="form-group full-width">
                            <label for="currentPassword">Current Password <span class="required">*</span></label>
                            <input type="password" id="currentPassword" name="currentPassword" maxlength="128" autocomplete="current-password" required>
                        </div>
                        <div class="form-group">
                            <label for="newPassword">New Password <span class="required">*</span></label>
                            <input type="password" id="newPassword" name="newPassword" minlength="8" maxlength="128" pattern="(?=.*[A-Za-z])(?=.*[0-9]).{8,128}" autocomplete="new-password" required>
                            <small>At least 8 characters, one letter and one number.</small>
                        </div>
                        <div class="form-group">
                            <label for="confirmPassword">Confirm New Password <span class="required">*</span></label>
                            <input type="password" id="confirmPassword" name="confirmPassword" minlength="8" maxlength="128" autocomplete="new-password" required>
                        </div>
                        <div class="form-actions">
                            <button type="submit" class="btn btn-primary"><i class="ti ti-key"></i> Change Password</button>
                        </div>
                    </div>
                </form>
            </div>

        </section>



        <!-- ================================================= -->
        <!-- ACCOUNT SUMMARY                                   -->
        <!-- ================================================= -->

        <aside>


            <section class="glass-card">


                <div class="card-head">


                    <div>


                        <div class="card-kicker">
                            Account
                        </div>


                        <h2>
                            Account Summary
                        </h2>


                    </div>


                    <div class="card-icon">

                        <i class="ti ti-id"></i>

                    </div>


                </div>



                <div class="profile-meta">


                    <div class="meta-row">


                        <div class="meta-label">
                            User ID
                        </div>


                        <div class="meta-value">
                            <c:out value="${sessionScope.loggedUser.id}"/>
                        </div>


                    </div>



                    <div class="meta-row">


                        <div class="meta-label">
                            Account Role
                        </div>


                        <div class="meta-value">

                            <span class="role-badge">
                                <c:out value="${sessionScope.loggedUser.role}"/>
                            </span>

                        </div>


                    </div>



                    <div class="meta-row">


                        <div class="meta-label">
                            Account Status
                        </div>


                        <div class="meta-value">
                            <c:out value="${sessionScope.loggedUser.status}"/>
                        </div>


                    </div>



                    <c:if test="${sessionScope.loggedUser.role == 'CUSTOMER'}">
                        <div class="meta-row">
                            <div class="meta-label">Profile Verification</div>
                            <div class="meta-value">
                                <c:choose>
                                    <c:when test="${customerProfile.verificationStatus == 'VERIFIED'}">
                                        <span class="verification-badge verification-verified"><i class="ti ti-rosette-discount-check"></i> Verified</span>
                                    </c:when>
                                    <c:when test="${customerProfile.verificationStatus == 'REJECTED'}">
                                        <span class="verification-badge verification-rejected"><i class="ti ti-alert-circle"></i> Rejected</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="verification-badge verification-pending"><i class="ti ti-clock"></i> Pending Verification</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:if>

                    <div class="meta-row">


                        <div class="meta-label">
                            Email
                        </div>


                        <div class="meta-value">
                            <c:out value="${sessionScope.loggedUser.email}"/>
                        </div>


                    </div>


                </div>


            </section>



            <!-- ============================================= -->
            <!-- DEACTIVATE ACCOUNT                            -->
            <!-- ============================================= -->

            <c:if test="${sessionScope.loggedUser.role == 'CUSTOMER'}">


                <section class="glass-card danger-card">


                    <div class="card-head">


                        <div>


                            <div class="card-kicker">
                                Danger Zone
                            </div>


                            <h2>
                                Deactivate Account
                            </h2>


                            <p class="card-description">

                                Deactivating your account prevents
                                future sign-ins.

                            </p>


                        </div>


                        <div class="card-icon">

                            <i class="ti ti-user-x"></i>

                        </div>


                    </div>



                    <div class="danger-note">

                        Your account will become unavailable for login.
                        Existing database information remains managed
                        by RideLanka FleetHire.

                    </div>



                    <form
                            action="${pageContext.request.contextPath}/user/delete"
                            method="post"
                            id="deactivateForm">


                        <button
                                type="submit"
                                class="btn btn-danger"
                                style="
                                    width:100%;
                                    margin-top:16px;
                                ">

                            <i class="ti ti-user-off"></i>

                            Deactivate Account

                        </button>


                    </form>


                </section>


            </c:if>


        </aside>


    </div>


</div>



<script>

    document.addEventListener(
        "DOMContentLoaded",
        function () {


            const form =
                document.getElementById(
                    "profileForm"
                );


            const phone =
                document.getElementById(
                    "phone"
                );


            const name =
                document.getElementById(
                    "name"
                );


            const email =
                document.getElementById(
                    "email"
                );


            const license =
                document.getElementById(
                    "licenseNo"
                );


            const idDocumentNo = document.getElementById("idDocumentNo");
            const addressLine = document.getElementById("addressLine");
            const city = document.getElementById("city");
            const dateOfBirth = document.getElementById("dateOfBirth");

            if (dateOfBirth) {
                const today = new Date();
                dateOfBirth.max = today.toISOString().split("T")[0];
            }

            const deactivateForm =
                document.getElementById(
                    "deactivateForm"
                );

            const changePasswordForm = document.getElementById("changePasswordForm");
            const newPassword = document.getElementById("newPassword");
            const confirmPassword = document.getElementById("confirmPassword");
            if (changePasswordForm && newPassword && confirmPassword) {
                const validatePasswordMatch = function () {
                    confirmPassword.setCustomValidity(
                        confirmPassword.value !== "" && newPassword.value !== confirmPassword.value
                            ? "Passwords do not match." : ""
                    );
                };
                newPassword.addEventListener("input", validatePasswordMatch);
                confirmPassword.addEventListener("input", validatePasswordMatch);
                changePasswordForm.addEventListener("submit", function (event) {
                    validatePasswordMatch();
                    if (!changePasswordForm.checkValidity()) {
                        event.preventDefault();
                        changePasswordForm.reportValidity();
                    }
                });
            }



            /* ============================================= */
            /* PHONE VALIDATION                              */
            /* ============================================= */

            phone.addEventListener(
                "input",
                function () {


                    phone.setCustomValidity("");


                    if (
                        phone.value.trim() !== ""
                        &&
                        !phone.validity.valid
                    ) {

                        phone.setCustomValidity(
                            "Enter a valid Sri Lankan mobile number. Example: 0771234567"
                        );

                    }


                }
            );



            /* ============================================= */
            /* PROFILE FORM                                  */
            /* ============================================= */

            form.addEventListener(
                "submit",
                function (event) {


                    name.value =
                        name.value.trim();


                    email.value =
                        email.value.trim();


                    phone.value =
                        phone.value.trim();


                    license.value =
                        license.value.trim();

                    if (idDocumentNo) idDocumentNo.value = idDocumentNo.value.trim();
                    if (addressLine) addressLine.value = addressLine.value.trim();
                    if (city) city.value = city.value.trim();



                    phone.setCustomValidity("");


                    if (
                        phone.value !== ""
                        &&
                        !phone.validity.valid
                    ) {

                        phone.setCustomValidity(
                            "Enter a valid Sri Lankan mobile number. Example: 0771234567"
                        );

                    }



                    if (!form.checkValidity()) {

                        event.preventDefault();

                        form.reportValidity();

                    }


                }
            );



            /* ============================================= */
            /* DEACTIVATE CONFIRMATION                       */
            /* ============================================= */

            if (deactivateForm) {


                deactivateForm.addEventListener(
                    "submit",
                    function (event) {


                        const confirmed =
                            window.confirm(
                                "Are you sure you want to deactivate your RideLanka FleetHire account?"
                            );


                        if (!confirmed) {

                            event.preventDefault();

                        }


                    }
                );


            }


        }
    );

</script>


</body>
</html>
