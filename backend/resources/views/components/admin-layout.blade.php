<!DOCTYPE html>
<html lang="ar" dir="rtl" data-theme="dark">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>{{ $title ?? 'لوحة التحكم' }} — لَفَّة</title>

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans+Arabic:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <!-- Admin CSS -->
    <link rel="stylesheet" href="{{ asset('css/admin.css') }}?v={{ time() }}">

    <!-- Global Leaflet CSS & JS for Live Map -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin="" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>

    @livewireStyles
    {{ $styles ?? '' }}
</head>
<body>
    <div class="admin-wrapper">

        <!-- Sidebar Overlay (Mobile) -->
        <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

        <!-- ======== SIDEBAR ======== -->
        <aside class="admin-sidebar" id="adminSidebar">

            <!-- Logo -->
            <a href="{{ route('admin.dashboard') }}" class="sidebar-logo">
                <img src="{{ asset('logo.jpeg') }}" alt="شعار لفة" class="sidebar-logo-icon">
                <div>
                    <div class="sidebar-logo-text">لَفَّة</div>
                    <div class="sidebar-logo-sub">لوحة التحكم</div>
                </div>
            </a>

            <!-- Navigation -->
            <nav class="sidebar-nav">

                <div class="nav-group">
                    <div class="nav-group-label">نظرة عامة</div>
                    <a href="{{ route('admin.dashboard') }}"
                       class="nav-item {{ request()->routeIs('admin.dashboard') ? 'active' : '' }}">
                        <span class="nav-icon">
                            <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/>
                                <rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/>
                            </svg>
                        </span>
                        الرئيسية
                    </a>
                    <a href="{{ route('admin.live-map') }}"
                       class="nav-item {{ request()->routeIs('admin.live-map') ? 'active' : '' }}">
                        <span class="nav-icon">
                            <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle>
                            </svg>
                        </span>
                        الخريطة الحية
                    </a>
                </div>

                <div class="nav-group">
                    <div class="nav-group-label">العمليات اليومية</div>
                    <a href="{{ route('admin.trips') }}"
                       class="nav-item {{ request()->routeIs('admin.trips') ? 'active' : '' }}">
                        <span class="nav-icon">
                            <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path d="M3 12h18M3 6h18M3 18h18"/>
                            </svg>
                        </span>
                        سجل الرحلات
                    </a>
                    <a href="{{ route('admin.captains') }}"
                       class="nav-item {{ request()->routeIs('admin.captains') ? 'active' : '' }}">
                        <span class="nav-icon">
                            <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <circle cx="12" cy="12" r="10"/>
                                <path d="M12 8v4l3 3"/>
                            </svg>
                        </span>
                        الكباتن
                    </a>
                    <a href="{{ route('admin.users') }}"
                       class="nav-item {{ request()->routeIs('admin.users') ? 'active' : '' }}">
                        <span class="nav-icon">
                            <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/>
                                <path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                            </svg>
                        </span>
                        المستخدمين (الركاب)
                    </a>
                </div>

                <div class="nav-group">
                    <div class="nav-group-label">الشؤون المالية</div>
                    <a href="{{ route('admin.transactions') }}"
                       class="nav-item {{ request()->routeIs('admin.transactions') ? 'active' : '' }}">
                        <span class="nav-icon">
                            <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>
                            </svg>
                        </span>
                        المعاملات
                    </a>
                    <a href="{{ route('admin.withdrawals') }}"
                       class="nav-item {{ request()->routeIs('admin.withdrawals') ? 'active' : '' }}">
                        <span class="nav-icon">
                            <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <rect x="2" y="5" width="20" height="14" rx="2" ry="2"/>
                                <line x1="2" y1="10" x2="22" y2="10"/>
                            </svg>
                        </span>
                        طلبات السحب
                    </a>
                </div>

                <div class="nav-group">
                    <div class="nav-group-label">الإدارة والاتصال</div>
                    <a href="{{ route('admin.documents') }}"
                       class="nav-item {{ request()->routeIs('admin.documents') ? 'active' : '' }}">
                        <span class="nav-icon">
                            <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                                <polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/>
                                <line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/>
                            </svg>
                        </span>
                        مستندات الكباتن
                    </a>
                    <a href="{{ route('admin.notifications') }}"
                       class="nav-item {{ request()->routeIs('admin.notifications') ? 'active' : '' }}">
                        <span class="nav-icon">
                            <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path d="M22 17H2a3 3 0 0 0 3-3V9a7 7 0 0 1 14 0v5a3 3 0 0 0 3 3zm-8.27 4a2 2 0 0 1-3.46 0"></path>
                            </svg>
                        </span>
                        الإشعارات
                    </a>
                </div>

                <div class="nav-group">
                    <div class="nav-group-label">الإعدادات</div>
                    <a href="{{ route('admin.settings') }}"
                       class="nav-item {{ request()->routeIs('admin.settings') ? 'active' : '' }}">
                        <span class="nav-icon">
                            <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <circle cx="12" cy="12" r="3"/>
                                <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>
                            </svg>
                        </span>
                        الإعدادات
                    </a>

                </div>

            </nav>

            <!-- Sidebar Footer: User Info -->
            <div class="sidebar-footer">
                <div class="sidebar-user">
                    <div class="user-avatar">{{ substr(auth()->user()->name ?? 'A', 0, 1) }}</div>
                    <div class="user-info">
                        <div class="user-name">{{ auth()->user()->name ?? 'المدير' }}</div>
                        <div class="user-role">مدير النظام</div>
                    </div>
                    <form method="POST" action="{{ route('admin.logout') }}">
                        @csrf
                        <button type="submit" class="topbar-btn" title="تسجيل الخروج" style="border:none;">
                            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
                                <polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/>
                            </svg>
                        </button>
                    </form>
                </div>
            </div>

        </aside>

        <!-- ======== MAIN CONTENT ======== -->
        <div class="admin-main">

            <!-- Top Bar -->
            <header class="admin-topbar">
                <div style="display:flex;align-items:center;gap:12px;">
                    <button class="mobile-menu-btn" onclick="toggleSidebar()" id="menuToggle">
                        <svg width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/>
                        </svg>
                    </button>
                    <h1 class="topbar-title">{{ $title ?? 'لوحة التحكم' }}</h1>
                </div>
                <div class="topbar-actions">
                    <!-- Notifications Toggle -->
                    <button class="topbar-btn" onclick="toggleNotifications()" title="الإشعارات">
                        <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
                            <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
                        </svg>
                        <span style="position:absolute; top:-2px; right:-2px; width:8px; height:8px; background:var(--color-danger); border-radius:50%; border:2px solid var(--color-surface);"></span>
                    </button>
                    <!-- Theme Toggle -->
                    <button class="topbar-btn" onclick="toggleTheme()" id="themeToggle" title="تبديل المظهر">
                        <svg id="sunIcon" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <circle cx="12" cy="12" r="5"/>
                            <line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/>
                            <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/>
                            <line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/>
                            <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/>
                        </svg>
                        <svg id="moonIcon" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="display:none;">
                            <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>
                        </svg>
                    </button>
                </div>
            </header>

            <!-- Page Content -->
            <main class="page-content animate-in">
                {{ $slot }}
            </main>

        </div>
    </div>

    @livewireScripts

    <script>
        // ========= THEME TOGGLE =========
        function toggleTheme() {
            const html = document.documentElement;
            const current = html.getAttribute('data-theme');
            const next = current === 'dark' ? 'light' : 'dark';
            html.setAttribute('data-theme', next);
            localStorage.setItem('laffah-admin-theme', next);
            document.getElementById('sunIcon').style.display  = next === 'dark'  ? 'block' : 'none';
            document.getElementById('moonIcon').style.display = next === 'light' ? 'block' : 'none';
        }

        // Apply saved theme on load
        (function() {
            const saved = localStorage.getItem('laffah-admin-theme') || 'light';
            document.documentElement.setAttribute('data-theme', saved);
            if (saved === 'dark') {
                document.getElementById('sunIcon').style.display  = 'none';
                document.getElementById('moonIcon').style.display = 'block';
            }
        })();

        // ========= SIDEBAR TOGGLE (Mobile) =========
        function toggleSidebar() {
            const sidebar = document.getElementById('adminSidebar');
            const overlay = document.getElementById('sidebarOverlay');
            sidebar.classList.toggle('open');
            overlay.classList.toggle('show');
        }

        // ========= NOTIFICATION PANEL =========
        function toggleNotifications() {
            const panel = document.getElementById('notificationPanel');
            const overlay = document.getElementById('notifOverlay');
            panel.classList.toggle('open');
            overlay.classList.toggle('show');
        }
    </script>
    {{ $scripts ?? '' }}
    
    <!-- Notification Panel HTML -->
    <div class="notification-overlay" id="notifOverlay" onclick="toggleNotifications()"></div>
    <div class="notification-panel" id="notificationPanel">
        <div class="notif-header">
            <span class="notif-title">الإشعارات الحية</span>
            <button class="notif-close" onclick="toggleNotifications()">
                <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            </button>
        </div>
        <div class="notif-body">
            <!-- Sample Data for design -->
            <div class="notif-item">
                <div class="notif-icon" style="background:var(--color-info-bg);color:var(--color-info-text);">
                    🚗
                </div>
                <div class="notif-content">
                    <div class="notif-text">كابتن جديد (أحمد محمد) يطلب التوثيق</div>
                    <div class="notif-time">منذ 5 دقائق</div>
                </div>
            </div>
            
            <div class="notif-item">
                <div class="notif-icon" style="background:var(--color-danger-bg);color:var(--color-danger-text);">
                    ⚠️
                </div>
                <div class="notif-content">
                    <div class="notif-text">تم إلغاء الرحلة #1042 من قبل الراكب</div>
                    <div class="notif-time">منذ 12 دقيقة</div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
