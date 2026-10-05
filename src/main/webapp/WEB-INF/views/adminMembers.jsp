<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>User Management | RideLanka FleetHire</title>

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

        /* ================================================= */
        /* RESET / PAGE SAFETY                               */
        /* ================================================= */

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
                            rgba(111, 203, 163, 0.10),
                            transparent 34%
                    ),
                    radial-gradient(
                            circle at 95% 20%,
                            rgba(70, 120, 255, 0.07),
                            transparent 32%
                    ),
                    var(--bx-night, #070b12);

            color: #ffffff;
            overflow-x: hidden;
        }

        button,
        input,
        select {
            font: inherit;
        }

        input,
        select {
            max-width: 100%;
        }


        /* ================================================= */
        /* PAGE SHELL                                        */
        /* ================================================= */

        .admin-shell {
            width: min(1500px, calc(100% - 40px));
            margin: 0 auto;
            padding: 30px 0 60px;
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

        .admin-brand {
            display: flex;
            align-items: center;
            gap: 14px;
            min-width: 0;
        }

        .admin-brand img {
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
            gap: 10px;
            flex-wrap: wrap;
            justify-content: flex-end;
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
            margin: 12px 0 0;
            max-width: 700px;

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
        /* GLASS CARDS                                       */
        /* ================================================= */

        .glass-card {
            min-width: 0;

            padding: 24px;

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
            align-items: center;
            justify-content: space-between;
            gap: 18px;
            margin-bottom: 22px;
        }

        .card-title-wrap {
            min-width: 0;
        }

        .card-kicker {
            font-size: 10px;
            font-weight: 700;
            letter-spacing: 0.14em;
            text-transform: uppercase;

            color:
                    var(--bx-primary, #6fcba3);

            margin-bottom: 5px;
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
            margin: 6px 0 0;

            color:
                    rgba(
                            255,
                            255,
                            255,
                            0.50
                    );

            font-size: 13px;
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

        .alert:last-child {
            margin-bottom: 0;
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
        /* CREATE FORM                                       */
        /* ================================================= */

        .create-form-grid {
            display: grid;
            grid-template-columns:
                    repeat(
                            3,
                            minmax(0, 1fr)
                    );

            gap: 18px;
        }

        .form-group {
            min-width: 0;
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

        .form-group input,
        .form-group select {
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

        .form-group select {
            cursor: pointer;
        }

        .form-group select option {
            color: #111827;
            background: #ffffff;
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

        .form-group input:focus,
        .form-group select:focus {
            border-color:
                    var(--bx-primary, #6fcba3);

            background:
                    rgba(111, 203, 163, 0.05);

            box-shadow:
                    0 0 0 3px
                    rgba(111, 203, 163, 0.08);
        }

        .form-group small {
            display: block;

            margin-top: 6px;

            font-size: 11px;
            line-height: 1.45;

            color:
                    rgba(
                            255,
                            255,
                            255,
                            0.42
                    );
        }

        .span-2 {
            grid-column: span 2;
        }

        .form-actions {
            grid-column: 1 / -1;

            display: flex;
            align-items: center;
            justify-content: flex-end;

            gap: 10px;

            margin-top: 4px;
        }


        /* ================================================= */
        /* BUTTONS                                           */
        /* ================================================= */

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;

            min-height: 41px;

            padding: 10px 15px;

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

        .btn-primary:hover {
            opacity: 0.92;
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

        .btn-secondary:hover {
            background:
                    rgba(255, 255, 255, 0.08);
        }

        .btn-danger {
            background:
                    rgba(248, 113, 113, 0.08);

            color: #fca5a5;

            border-color:
                    rgba(248, 113, 113, 0.26);
        }

        .btn-sm {
            min-height: 34px;
            padding: 7px 11px;
            font-size: 12px;
        }


        /* ================================================= */
        /* SECTIONS                                          */
        /* ================================================= */

        .content-grid {
            display: grid;
            gap: 22px;
        }


        /* ================================================= */
        /* TABLE                                             */
        /* ================================================= */

        .table-shell {
            width: 100%;
            max-width: 100%;

            overflow-x: auto;
            overflow-y: hidden;

            border:
                    1px solid
                    rgba(255, 255, 255, 0.08);

            border-radius: 14px;
        }

        .user-table {
            width: 100%;
            min-width: 1260px;

            border-collapse: collapse;

            background:
                    rgba(0, 0, 0, 0.10);
        }

        .user-table th {
            padding: 13px 14px;

            text-align: left;

            font-size: 9px;
            font-weight: 700;

            letter-spacing: 0.13em;
            text-transform: uppercase;

            color:
                    rgba(
                            255,
                            255,
                            255,
                            0.43
                    );

            background:
                    rgba(255, 255, 255, 0.03);

            border-bottom:
                    1px solid
                    rgba(255, 255, 255, 0.08);
        }

        .user-table td {
            padding: 14px;

            border-bottom:
                    1px solid
                    rgba(255, 255, 255, 0.065);

            color:
                    rgba(
                            255,
                            255,
                            255,
                            0.78
                    );

            font-size: 13px;

            vertical-align: middle;
        }

        .user-table tbody tr {
            transition:
                    background 0.15s ease;
        }

        .user-table tbody tr:hover {
            background:
                    rgba(111, 203, 163, 0.04);
        }

        .user-table tbody tr:last-child td {
            border-bottom: none;
        }

        .cell-id {
            font-family:
                    'JetBrains Mono',
                    monospace;

            color:
                    var(--bx-primary, #6fcba3) !important;
        }

        .cell-wrap {
            max-width: 230px;

            overflow-wrap: anywhere;
            word-break: break-word;
        }

        .cell-muted {
            color:
                    rgba(
                            255,
                            255,
                            255,
                            0.48
                    ) !important;
        }


        /* ================================================= */
        /* BADGES                                            */
        /* ================================================= */

        .badge {
            display: inline-flex;
            align-items: center;

            max-width: 100%;

            padding: 5px 9px;

            border-radius: 999px;

            font-size: 10px;
            font-weight: 700;

            letter-spacing: 0.055em;

            white-space: nowrap;
        }

        .badge-role {
            background:
                    rgba(96, 165, 250, 0.09);

            border:
                    1px solid
                    rgba(96, 165, 250, 0.22);

            color: #93c5fd;
        }

        .badge-active {
            background:
                    rgba(111, 203, 163, 0.09);

            border:
                    1px solid
                    rgba(111, 203, 163, 0.24);

            color:
                    var(--bx-primary, #6fcba3);
        }

        .badge-suspended {
            background:
                    rgba(251, 191, 36, 0.09);

            border:
                    1px solid
                    rgba(251, 191, 36, 0.24);

            color: #fcd34d;
        }

        .badge-deactivated {
            background:
                    rgba(248, 113, 113, 0.09);

            border:
                    1px solid
                    rgba(248, 113, 113, 0.24);

            color: #fca5a5;
        }


        .verification-form { display:flex;align-items:center;gap:7px;min-width:190px; }
        .verification-form select { min-width:118px;max-width:140px;padding:7px 8px;border-radius:9px;border:1px solid rgba(255,255,255,.12);background:rgba(255,255,255,.05);color:#fff;font-size:11px; }
        .verification-form select option { background:#17221f;color:#fff; }
        .verification-na { color:rgba(255,255,255,.35); }

        /* ================================================= */
        /* EMPTY STATE                                       */
        /* ================================================= */

        .empty-state {
            padding: 44px 20px;

            text-align: center;

            border:
                    1px dashed
                    rgba(255, 255, 255, 0.12);

            border-radius: 14px;

            color:
                    rgba(
                            255,
                            255,
                            255,
                            0.48
                    );
        }

        .empty-state i {
            display: block;
            margin-bottom: 12px;

            font-size: 34px;

            color:
                    var(--bx-primary, #6fcba3);
        }


        /* ================================================= */
        /* MODAL                                             */
        /* ================================================= */

        .modal {
            position: fixed;

            inset: 0;

            z-index: 9999;

            display: none;

            align-items: center;
            justify-content: center;

            padding: 24px;

            background:
                    rgba(0, 0, 0, 0.72);

            backdrop-filter:
                    blur(9px);

            -webkit-backdrop-filter:
                    blur(9px);

            overflow-y: auto;
        }

        .modal.open {
            display: flex;
        }

        .modal-card {
            width: min(720px, 100%);
            max-width: 100%;

            max-height:
                    calc(
                            100dvh - 48px
                    );

            display: flex;
            flex-direction: column;

            overflow: hidden;

            border:
                    1px solid
                    rgba(255, 255, 255, 0.12);

            border-radius: 20px;

            background:
                    rgba(13, 19, 29, 0.97);

            box-shadow:
                    0 30px 100px
                    rgba(0, 0, 0, 0.52);
        }

        .modal-head {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;

            gap: 18px;

            flex-shrink: 0;

            padding: 20px 22px;

            border-bottom:
                    1px solid
                    rgba(255, 255, 255, 0.08);
        }

        .modal-head h2 {
            margin: 0;

            font-family:
                    'Manrope',
                    sans-serif;

            font-size: 22px;
            font-weight: 600;
        }

        .modal-head p {
            margin: 6px 0 0;

            color:
                    rgba(
                            255,
                            255,
                            255,
                            0.45
                    );

            font-size: 12px;
        }

        .modal-close {
            width: 38px;
            height: 38px;

            flex-shrink: 0;

            display: inline-flex;
            align-items: center;
            justify-content: center;

            border-radius: 50%;

            border:
                    1px solid
                    rgba(255, 255, 255, 0.10);

            background:
                    rgba(255, 255, 255, 0.04);

            color:
                    rgba(
                            255,
                            255,
                            255,
                            0.72
                    );

            cursor: pointer;
        }

        .modal-close:hover {
            background:
                    rgba(255, 255, 255, 0.08);
        }

        .modal-body {
            min-width: 0;

            padding: 22px;

            overflow-x: hidden;
            overflow-y: auto;

            overscroll-behavior: contain;
        }

        .edit-grid {
            width: 100%;

            display: grid;

            grid-template-columns:
                    repeat(
                            2,
                            minmax(0, 1fr)
                    );

            gap: 17px;
        }

        .edit-grid > * {
            min-width: 0;
        }

        .edit-grid .form-group input,
        .edit-grid .form-group select {
            width: 100%;
            min-width: 0;
            max-width: 100%;
        }

        .modal-actions {
            grid-column: 1 / -1;

            display: flex;
            justify-content: flex-end;
            gap: 10px;

            padding-top: 5px;
        }


        /* ================================================= */
        /* MOBILE                                            */
        /* ================================================= */

        @media (max-width: 1050px) {

            .create-form-grid {
                grid-template-columns:
                        repeat(
                                2,
                                minmax(0, 1fr)
                        );
            }

        }


        @media (max-width: 760px) {

            .admin-shell {
                width:
                        min(
                                100% - 24px,
                                1500px
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

            .create-form-grid,
            .edit-grid {
                grid-template-columns: 1fr;
            }

            .span-2 {
                grid-column: auto;
            }

            .form-actions,
            .modal-actions {
                grid-column: auto;
                width: 100%;

                flex-direction: column;
            }

            .form-actions .btn,
            .modal-actions .btn {
                width: 100%;
            }

            .modal {
                align-items: flex-start;
                padding: 12px;
            }

            .modal-card {
                width: 100%;
                max-height:
                        calc(
                                100dvh - 24px
                        );

                border-radius: 16px;
            }

            .modal-head,
            .modal-body {
                padding: 18px;
            }

        }

        /* Shared application shell: keeps User Management consistent with the rest of RideLanka. */
        .admin-page-main {
            min-width: 0;
            width: 100%;
        }

        .admin-page-main .admin-shell {
            position: relative;
        }

        @media (max-width: 768px) {
            .admin-page-main .admin-shell {
                width: min(100% - 24px, 1500px);
                padding-top: 20px;
            }
        }

    </style>

</head>


<body>


<div class="vrms-shell">

    <aside class="vrms-sidebar">
        <a href="${pageContext.request.contextPath}/" class="sidebar-logo"
           style="text-decoration:none; color:inherit;"
           aria-label="RideLanka FleetHire home">
            <img src="${pageContext.request.contextPath}/images/vrms-logo.png"
                 alt="RideLanka FleetHire — Vehicle Rental" class="sidebar-logo__img"/>
            <div class="logo-text">
                <span class="brand">RideLanka FleetHire</span>
                <small>&mdash; Vehicle Rental &mdash;</small>
            </div>
        </a>

        <div class="nav-section">Browse</div>

        <a href="${pageContext.request.contextPath}/" class="nav-item">
            <i class="ti ti-home" aria-hidden="true"></i> Home
        </a>

        <a href="${pageContext.request.contextPath}/dashboard" class="nav-item">
            <i class="ti ti-layout-grid" aria-hidden="true"></i> Dashboard
        </a>

        <a href="${pageContext.request.contextPath}/search" class="nav-item">
            <i class="ti ti-zoom-in" aria-hidden="true"></i> Search Vehicle
        </a>

        <a href="${pageContext.request.contextPath}/booking?action=form" class="nav-item">
            <i class="ti ti-calendar-event" aria-hidden="true"></i> New Reservation
        </a>

        <div class="nav-section">Account</div>

        <a href="${pageContext.request.contextPath}/profile" class="nav-item">
            <i class="ti ti-user-circle" aria-hidden="true"></i> Profile
        </a>

        <div class="nav-section">Operations</div>

        <a href="${pageContext.request.contextPath}/vehicle?action=list" class="nav-item">
            <i class="ti ti-car" aria-hidden="true"></i> Vehicle Management
        </a>

        <a href="${pageContext.request.contextPath}/fleet" class="nav-item">
            <i class="ti ti-tool" aria-hidden="true"></i> Fleet &amp; Maintenance
        </a>

        <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-item">
            <i class="ti ti-shield-lock" aria-hidden="true"></i> Admin Control Center
        </a>

        <a href="${pageContext.request.contextPath}/admin/members" class="nav-item active">
            <i class="ti ti-users" aria-hidden="true"></i> User Management
        </a>

        <a href="${pageContext.request.contextPath}/admin/revenue" class="nav-item">
            <i class="ti ti-trending-up" aria-hidden="true"></i> Revenue
        </a>

        <a href="${pageContext.request.contextPath}/review/moderate" class="nav-item">
            <i class="ti ti-shield" aria-hidden="true"></i> Moderation
        </a>

        <a href="${pageContext.request.contextPath}/payment/list" class="nav-item">
            <i class="ti ti-receipt" aria-hidden="true"></i> Payment Log
        </a>

        <div class="sidebar-footer">
            <div class="user-pill">
                <div class="user-avatar">
                    ${not empty sessionScope.loggedUser ? sessionScope.loggedUser.name.substring(0,1).toUpperCase() : 'A'}
                </div>
                <div class="user-info">
                    <span><c:out value="${not empty sessionScope.loggedUser ? sessionScope.loggedUser.name : 'Administrator'}"/></span>
                    <small><c:out value="${not empty sessionScope.loggedUser ? sessionScope.loggedUser.role : 'ADMIN'}"/></small>
                </div>
            </div>
        </div>
    </aside>

    <div class="vrms-main admin-page-main">

<div class="admin-shell">


    <!-- ================================================= -->
    <!-- TOP BAR                                           -->
    <!-- ================================================= -->

    <header class="topbar">


        <a href="${pageContext.request.contextPath}/"
           class="admin-brand"
           style="text-decoration:none;">


            <img
                    src="${pageContext.request.contextPath}/images/vrms-logo.png"
                    alt="RideLanka FleetHire">


            <div class="brand-copy">

                <div class="brand-name">
                    RideLanka FleetHire
                </div>

                <div class="brand-sub">
                    Administration Console
                </div>

            </div>


        </a>


        <div class="top-actions">


            <a
                    href="${pageContext.request.contextPath}/admin/dashboard"
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

                <i class="ti ti-users"></i>

                Administration

            </div>


            <h1>
                User
                <em>Management.</em>
            </h1>


            <p class="page-description">

                Create staff and customer accounts,
                update access roles and manage account
                status across RideLanka FleetHire.

            </p>


        </div>


    </section>



    <!-- ================================================= -->
    <!-- ALERTS                                            -->
    <!-- ================================================= -->

    <div class="alerts">


        <c:if test="${param.msg == 'created'}">

            <div class="alert alert-success">

                <i class="ti ti-circle-check"></i>

                <div>
                    User created successfully.
                </div>

            </div>

        </c:if>


        <c:if test="${param.msg == 'updated'}">

            <div class="alert alert-success">

                <i class="ti ti-circle-check"></i>

                <div>
                    User updated successfully.
                </div>

            </div>

        </c:if>


        <c:if test="${param.msg == 'status'}">

            <div class="alert alert-success">

                <i class="ti ti-circle-check"></i>

                <div>
                    User status updated successfully.
                </div>

            </div>

        </c:if>

        <c:if test="${param.msg == 'verification'}">
            <div class="alert alert-success">
                <i class="ti ti-rosette-discount-check"></i>
                <div>Customer verification status updated successfully.</div>
            </div>
        </c:if>


        <c:if test="${not empty param.error}">

            <div class="alert alert-danger">

                <i class="ti ti-alert-circle"></i>

                <div>

                    <c:choose>


                        <c:when test="${param.error == 'invalidName'}">
                            Please enter a valid user name.
                        </c:when>


                        <c:when test="${param.error == 'invalidEmail'}">
                            Please enter a valid email address.
                        </c:when>


                        <c:when test="${param.error == 'invalidPhone'}">
                            Invalid Sri Lankan mobile number.
                            Use a number such as 0771234567.
                        </c:when>


                        <c:when test="${param.error == 'invalidLicense'}">
                            Invalid driving licence / ID number.
                        </c:when>


                        <c:when test="${param.error == 'weakPassword'}">
                            Password must contain at least
                            8 characters, including one
                            letter and one number.
                        </c:when>


                        <c:when test="${param.error == 'invalidRole'}">
                            Invalid user role.
                        </c:when>


                        <c:when test="${param.error == 'invalidStatus'}">
                            Invalid account status.
                        </c:when>


                        <c:when test="${param.error == 'emailExists'}">
                            This email address already belongs
                            to another user.
                        </c:when>


                        <c:when test="${param.error == 'cannotDemoteSelf'}">
                            You cannot remove your own
                            administrator access or deactivate
                            your own administrator account.
                        </c:when>


                        <c:when test="${param.error == 'cannotSuspendSelf'}">
                            You cannot suspend or deactivate
                            your own account.
                        </c:when>


                        <c:when test="${param.error == 'invalidVerification'}">
                            Invalid customer verification status.
                        </c:when>

                        <c:when test="${param.error == 'db'}">
                            A database error occurred.
                            Please try again.
                        </c:when>


                        <c:otherwise>
                            The request could not be completed.
                            Please check the entered information.
                        </c:otherwise>


                    </c:choose>

                </div>

            </div>

        </c:if>


    </div>



    <main class="content-grid">


        <!-- ============================================= -->
        <!-- CREATE USER                                   -->
        <!-- ============================================= -->

        <section class="glass-card">


            <div class="card-head">


                <div class="card-title-wrap">

                    <div class="card-kicker">
                        New account
                    </div>

                    <h2>
                        Create New User
                    </h2>

                    <p class="card-description">
                        Add a customer or operational staff account.
                    </p>

                </div>


                <i
                        class="ti ti-user-plus"
                        style="
                            font-size:30px;
                            color:var(--bx-primary,#6fcba3);
                        ">
                </i>


            </div>



            <form
                    action="${pageContext.request.contextPath}/admin/users/create"
                    method="post"
                    id="createUserForm">


                <div class="create-form-grid">


                    <!-- NAME -->

                    <div class="form-group">


                        <label for="createName">

                            Full Name

                            <span class="required">
                                *
                            </span>

                        </label>


                        <input
                                type="text"
                                id="createName"
                                name="name"
                                value="<c:out value='${param.name}'/>"

                                minlength="2"
                                maxlength="120"

                                placeholder="Kamal Perera"

                                autocomplete="name"

                                required>


                    </div>



                    <!-- EMAIL -->

                    <div class="form-group">


                        <label for="createEmail">

                            Email

                            <span class="required">
                                *
                            </span>

                        </label>


                        <input
                                type="email"
                                id="createEmail"
                                name="email"
                                value="<c:out value='${param.email}'/>"

                                maxlength="180"

                                placeholder="kamal@example.com"

                                autocomplete="email"

                                required>


                    </div>



                    <!-- PHONE -->

                    <div class="form-group">


                        <label for="createPhone">
                            Mobile Number
                        </label>


                        <input
                                type="tel"
                                id="createPhone"
                                name="phone"
                                value="<c:out value='${param.phone}'/>"

                                maxlength="16"

                                placeholder="0771234567"

                                pattern="(?:\+94|94|0)7[0-9](?:[ -]?[0-9]){7}"

                                title="Enter a valid Sri Lankan mobile number such as 0771234567."

                                inputmode="tel"

                                autocomplete="tel">


                        <small>
                            Optional. Example: 0771234567
                        </small>


                    </div>



                    <!-- LICENCE -->

                    <div class="form-group">


                        <label for="createLicense">
                            Driving Licence / ID
                        </label>


                        <input
                                type="text"
                                id="createLicense"
                                name="licenseNo"
                                value="<c:out value='${param.licenseNo}'/>"

                                minlength="3"
                                maxlength="80"

                                pattern="[A-Za-z0-9/ -]{3,80}"

                                title="Use letters, numbers, spaces, hyphens or slashes."

                                placeholder="B1234567">


                        <small>
                            Required for customers where applicable.
                        </small>


                    </div>



                    <!-- ROLE -->

                    <div class="form-group">


                        <label for="createRole">

                            Role

                            <span class="required">
                                *
                            </span>

                        </label>


                        <select
                                id="createRole"
                                name="role"
                                required>


                            <option value="">
                                -- Select Role --
                            </option>

                            <option value="CUSTOMER" ${param.role == 'CUSTOMER' ? 'selected' : ''}>
                                Customer
                            </option>

                            <option value="BRANCH_STAFF" ${param.role == 'BRANCH_STAFF' ? 'selected' : ''}>
                                Branch Staff
                            </option>

                            <option value="VEHICLE" ${param.role == 'VEHICLE' ? 'selected' : ''}>
                                Vehicle Management
                            </option>

                            <option value="FINANCE" ${param.role == 'FINANCE' ? 'selected' : ''}>
                                Finance
                            </option>

                            <option value="MAINTENANCE" ${param.role == 'MAINTENANCE' ? 'selected' : ''}>
                                Maintenance
                            </option>

                            <option value="FLEET" ${param.role == 'FLEET' ? 'selected' : ''}>
                                Fleet Management
                            </option>

                            <option value="ADMIN" ${param.role == 'ADMIN' ? 'selected' : ''}>
                                Administrator
                            </option>


                        </select>


                    </div>



                    <!-- PASSWORD -->

                    <div class="form-group">


                        <label for="createPassword">

                            Password

                            <span class="required">
                                *
                            </span>

                        </label>


                        <input
                                type="password"
                                id="createPassword"
                                name="password"

                                minlength="8"
                                maxlength="128"

                                pattern="(?=.*[A-Za-z])(?=.*[0-9]).{8,128}"

                                title="Password must contain at least 8 characters, one letter and one number."

                                placeholder="Min. 8 chars + number"

                                autocomplete="new-password"

                                required>


                        <small>
                            At least 8 characters with
                            one letter and one number.
                        </small>


                    </div>



                    <div class="form-actions">


                        <button
                                type="submit"
                                class="btn btn-primary">

                            <i class="ti ti-user-plus"></i>

                            Create User

                        </button>


                    </div>


                </div>


            </form>


        </section>



        <!-- ============================================= -->
        <!-- EXISTING USERS                                -->
        <!-- ============================================= -->

        <section class="glass-card">


            <div class="card-head">


                <div class="card-title-wrap">

                    <div class="card-kicker">
                        Directory
                    </div>

                    <h2>
                        Existing Users
                    </h2>

                    <p class="card-description">
                        Review account details, roles and status.
                    </p>

                </div>


                <i
                        class="ti ti-address-book"
                        style="
                            font-size:30px;
                            color:var(--bx-primary,#6fcba3);
                        ">
                </i>


            </div>



            <c:choose>


                <c:when test="${empty users}">


                    <div class="empty-state">

                        <i class="ti ti-users-off"></i>

                        No users are currently available.

                    </div>


                </c:when>



                <c:otherwise>


                    <div class="table-shell">


                        <table class="user-table">


                            <thead>


                            <tr>

                                <th>User ID</th>

                                <th>Name</th>

                                <th>Email</th>

                                <th>Phone</th>

                                <th>Licence / ID</th>

                                <th>Role</th>

                                <th>Status</th>

                                <th>Verification</th>

                                <th>Actions</th>

                            </tr>


                            </thead>



                            <tbody>


                            <c:forEach
                                    var="user"
                                    items="${users}">


                                <tr>


                                    <td class="cell-id">
                                        <c:out value="${user.id}"/>
                                    </td>


                                    <td class="cell-wrap">
                                        <c:out value="${user.name}"/>
                                    </td>


                                    <td class="cell-wrap">
                                        <c:out value="${user.email}"/>
                                    </td>


                                    <td class="cell-muted">
                                        <c:out value="${user.phone}"/>
                                    </td>


                                    <td class="cell-wrap cell-muted">
                                        <c:out value="${user.licenseNo}"/>
                                    </td>


                                    <td>

                                        <span class="badge badge-role">
                                            <c:out value="${user.role}"/>
                                        </span>

                                    </td>


                                    <td>


                                        <c:choose>


                                            <c:when test="${user.status == 'ACTIVE'}">

                                                <span class="badge badge-active">
                                                    ACTIVE
                                                </span>

                                            </c:when>


                                            <c:when test="${user.status == 'SUSPENDED'}">

                                                <span class="badge badge-suspended">
                                                    SUSPENDED
                                                </span>

                                            </c:when>


                                            <c:otherwise>

                                                <span class="badge badge-deactivated">
                                                    <c:out value="${user.status}"/>
                                                </span>

                                            </c:otherwise>


                                        </c:choose>


                                    </td>

                                    <td>
                                        <c:choose>
                                            <c:when test="${user.role == 'CUSTOMER' && not empty customerProfiles[user.id]}">
                                                <form class="verification-form" action="${pageContext.request.contextPath}/admin/users/verification" method="post">
                                                    <input type="hidden" name="id" value="<c:out value='${user.id}'/>">
                                                    <select name="verificationStatus" aria-label="Customer verification status">
                                                        <option value="PENDING" ${customerProfiles[user.id].verificationStatus == 'PENDING' ? 'selected' : ''}>Pending</option>
                                                        <option value="VERIFIED" ${customerProfiles[user.id].verificationStatus == 'VERIFIED' ? 'selected' : ''}>Verified</option>
                                                        <option value="REJECTED" ${customerProfiles[user.id].verificationStatus == 'REJECTED' ? 'selected' : ''}>Rejected</option>
                                                    </select>
                                                    <button class="btn btn-secondary btn-sm" type="submit" title="Save verification status">
                                                        <i class="ti ti-check"></i>
                                                    </button>
                                                </form>
                                            </c:when>
                                            <c:otherwise><span class="verification-na">—</span></c:otherwise>
                                        </c:choose>
                                    </td>

                                    <td>


                                        <button
                                                type="button"
                                                class="btn btn-secondary btn-sm edit-user-btn"

                                                data-id="<c:out value='${user.id}'/>"
                                                data-name="<c:out value='${user.name}'/>"
                                                data-email="<c:out value='${user.email}'/>"
                                                data-phone="<c:out value='${user.phone}'/>"
                                                data-license="<c:out value='${user.licenseNo}'/>"
                                                data-role="<c:out value='${user.role}'/>"
                                                data-status="<c:out value='${user.status}'/>">

                                            <i class="ti ti-pencil"></i>

                                            Edit

                                        </button>


                                    </td>


                                </tr>


                            </c:forEach>


                            </tbody>


                        </table>


                    </div>


                </c:otherwise>


            </c:choose>


        </section>


    </main>


</div>



<!-- ===================================================== -->
<!-- EDIT USER MODAL                                       -->
<!-- ===================================================== -->

<div
        id="editModal"
        class="modal"
        role="dialog"
        aria-modal="true"
        aria-labelledby="editModalTitle">


    <div class="modal-card">


        <div class="modal-head">


            <div>


                <h2 id="editModalTitle">
                    Edit User
                </h2>


                <p>
                    Update account information, role and status.
                </p>


            </div>



            <button
                    type="button"
                    class="modal-close"
                    id="modalCloseButton"
                    aria-label="Close edit user dialog">

                <i class="ti ti-x"></i>

            </button>


        </div>



        <div class="modal-body">


            <form
                    action="${pageContext.request.contextPath}/admin/users/update"
                    method="post"
                    id="editUserForm">


                <input
                        type="hidden"
                        id="editId"
                        name="id">



                <div class="edit-grid">


                    <!-- NAME -->

                    <div class="form-group">


                        <label for="editName">

                            Full Name

                            <span class="required">
                                *
                            </span>

                        </label>


                        <input
                                type="text"
                                id="editName"
                                name="name"

                                minlength="2"
                                maxlength="120"

                                required>


                    </div>



                    <!-- EMAIL -->

                    <div class="form-group">


                        <label for="editEmail">

                            Email

                            <span class="required">
                                *
                            </span>

                        </label>


                        <input
                                type="email"
                                id="editEmail"
                                name="email"

                                maxlength="180"

                                required>


                    </div>



                    <!-- PHONE -->

                    <div class="form-group">


                        <label for="editPhone">
                            Mobile Number
                        </label>


                        <input
                                type="tel"
                                id="editPhone"
                                name="phone"

                                maxlength="16"

                                pattern="(?:\+94|94|0)7[0-9](?:[ -]?[0-9]){7}"

                                title="Enter a valid Sri Lankan mobile number such as 0771234567."

                                inputmode="tel">


                        <small>
                            Example: 0771234567
                        </small>


                    </div>



                    <!-- LICENCE -->

                    <div class="form-group">


                        <label for="editLicense">
                            Driving Licence / ID
                        </label>


                        <input
                                type="text"
                                id="editLicense"
                                name="licenseNo"

                                minlength="3"
                                maxlength="80"

                                pattern="[A-Za-z0-9/ -]{3,80}"

                                title="Use letters, numbers, spaces, hyphens or slashes.">


                    </div>



                    <!-- ROLE -->

                    <div class="form-group">


                        <label for="editRole">

                            Role

                            <span class="required">
                                *
                            </span>

                        </label>


                        <select
                                id="editRole"
                                name="role"
                                required>


                            <option value="CUSTOMER">
                                Customer
                            </option>

                            <option value="BRANCH_STAFF">
                                Branch Staff
                            </option>

                            <option value="VEHICLE">
                                Vehicle Management
                            </option>

                            <option value="FINANCE">
                                Finance
                            </option>

                            <option value="MAINTENANCE">
                                Maintenance
                            </option>

                            <option value="FLEET">
                                Fleet Management
                            </option>

                            <option value="ADMIN">
                                Administrator
                            </option>


                        </select>


                    </div>



                    <!-- STATUS -->

                    <div class="form-group">


                        <label for="editStatus">

                            Status

                            <span class="required">
                                *
                            </span>

                        </label>


                        <select
                                id="editStatus"
                                name="status"
                                required>


                            <option value="ACTIVE">
                                Active
                            </option>

                            <option value="SUSPENDED">
                                Suspended
                            </option>

                            <option value="DEACTIVATED">
                                Deactivated
                            </option>


                        </select>


                    </div>



                    <div class="modal-actions">


                        <button
                                type="button"
                                class="btn btn-secondary"
                                id="modalCancelButton">

                            Cancel

                        </button>


                        <button
                                type="submit"
                                class="btn btn-primary">

                            <i class="ti ti-device-floppy"></i>

                            Save Changes

                        </button>


                    </div>


                </div>


            </form>


        </div>


    </div>


</div>



<!-- ===================================================== -->
<!-- JAVASCRIPT                                            -->
<!-- ===================================================== -->

<script>

    document.addEventListener(
        "DOMContentLoaded",
        function () {


            const modal =
                document.getElementById(
                    "editModal"
                );


            const closeButton =
                document.getElementById(
                    "modalCloseButton"
                );


            const cancelButton =
                document.getElementById(
                    "modalCancelButton"
                );


            const createForm =
                document.getElementById(
                    "createUserForm"
                );


            const editForm =
                document.getElementById(
                    "editUserForm"
                );


            const createPhone =
                document.getElementById(
                    "createPhone"
                );


            const editPhone =
                document.getElementById(
                    "editPhone"
                );



            /* ============================================= */
            /* SAFE MODAL OPEN                              */
            /* ============================================= */

            function openEditModal(button) {


                document.getElementById("editId").value =
                    button.dataset.id || "";


                document.getElementById("editName").value =
                    button.dataset.name || "";


                document.getElementById("editEmail").value =
                    button.dataset.email || "";


                document.getElementById("editPhone").value =
                    button.dataset.phone || "";


                document.getElementById("editLicense").value =
                    button.dataset.license || "";


                document.getElementById("editRole").value =
                    button.dataset.role || "CUSTOMER";


                document.getElementById("editStatus").value =
                    button.dataset.status || "ACTIVE";


                modal.classList.add("open");


                document.body.style.overflow =
                    "hidden";


                document.getElementById(
                    "editName"
                ).focus();


            }



            /* ============================================= */
            /* MODAL CLOSE                                  */
            /* ============================================= */

            function closeEditModal() {


                modal.classList.remove("open");


                document.body.style.overflow =
                    "";


            }



            document
                .querySelectorAll(
                    ".edit-user-btn"
                )
                .forEach(
                    function (button) {


                        button.addEventListener(
                            "click",
                            function () {

                                openEditModal(
                                    button
                                );

                            }
                        );


                    }
                );



            closeButton.addEventListener(
                "click",
                closeEditModal
            );


            cancelButton.addEventListener(
                "click",
                closeEditModal
            );



            /* Close only when actual dark backdrop clicked */

            modal.addEventListener(
                "click",
                function (event) {


                    if (event.target === modal) {

                        closeEditModal();

                    }


                }
            );



            /* Escape closes modal */

            document.addEventListener(
                "keydown",
                function (event) {


                    if (
                        event.key === "Escape"
                        &&
                        modal.classList.contains("open")
                    ) {

                        closeEditModal();

                    }


                }
            );



            /* ============================================= */
            /* INPUT TRIMMING                               */
            /* ============================================= */

            function trimForm(form) {


                if (!form) {
                    return;
                }


                const fields =
                    form.querySelectorAll(
                        "input[type='text'], input[type='email'], input[type='tel']"
                    );


                fields.forEach(
                    function (field) {

                        field.value =
                            field.value.trim();

                    }
                );


            }



            /* ============================================= */
            /* PHONE VALIDATION                             */
            /* ============================================= */

            function configurePhoneValidation(phone) {


                if (!phone) {
                    return;
                }


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


            }



            configurePhoneValidation(
                createPhone
            );


            configurePhoneValidation(
                editPhone
            );



            /* ============================================= */
            /* FORM SUBMISSION                              */
            /* ============================================= */

            if (createForm) {


                createForm.addEventListener(
                    "submit",
                    function (event) {


                        trimForm(
                            createForm
                        );


                        if (
                            !createForm.checkValidity()
                        ) {

                            event.preventDefault();

                            createForm.reportValidity();

                        }


                    }
                );


            }



            if (editForm) {


                editForm.addEventListener(
                    "submit",
                    function (event) {


                        trimForm(
                            editForm
                        );


                        if (
                            !editForm.checkValidity()
                        ) {

                            event.preventDefault();

                            editForm.reportValidity();

                        }


                    }
                );


            }


        }
    );

</script>


    </div><!-- /.vrms-main -->
</div><!-- /.vrms-shell -->

</body>
</html>