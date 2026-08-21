<!DOCTYPE html>
<html lang="ar" dir="rtl" data-theme="dark">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>تسجيل الدخول — لَفَّة</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans+Arabic:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="{{ asset('css/admin.css') }}">
    <style>
        body {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: #0f111a;
            background-image: url('{{ asset('images/login-bg.png') }}');
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            position: relative;
            overflow: hidden;
            font-family: 'IBM Plex Sans Arabic', sans-serif;
            margin: 0;
        }

        /* Dark overlay to ensure readability */
        body::before {
            content: '';
            position: absolute;
            inset: 0;
            background: linear-gradient(135deg, rgba(15, 17, 26, 0.8) 0%, rgba(15, 17, 26, 0.4) 100%);
            z-index: 0;
        }

        .login-container {
            width: 100%;
            max-width: 420px;
            padding: 20px;
            position: relative;
            z-index: 1;
            animation: fadeInUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) forwards;
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(30px) scale(0.95); }
            to   { opacity: 1; transform: translateY(0) scale(1); }
        }

        .login-card {
            /* 3D Glassmorphism Effect */
            background: rgba(20, 20, 30, 0.4);
            backdrop-filter: blur(24px);
            -webkit-backdrop-filter: blur(24px);
            border: 1px solid rgba(255, 255, 255, 0.15);
            border-top: 1px solid rgba(255, 255, 255, 0.25);
            border-left: 1px solid rgba(255, 255, 255, 0.25);
            border-radius: 28px;
            padding: 48px 40px;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.5), 
                        inset 0 0 0 1px rgba(255, 255, 255, 0.05);
        }

        .login-logo {
            text-align: center;
            margin-bottom: 36px;
        }

        .login-logo-icon {
            width: 80px;
            height: 80px;
            border-radius: 24px;
            display: block;
            margin: 0 auto 16px;
            object-fit: cover;
            /* 3D Logo Shadow */
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.5);
            border: 2px solid rgba(255, 255, 255, 0.15);
            background-color: white;
        }

        .login-title {
            font-size: 28px;
            font-weight: 700;
            color: #ffffff;
            margin-bottom: 6px;
            text-shadow: 0 2px 10px rgba(0,0,0,0.5);
        }

        .login-sub {
            font-size: 15px;
            color: rgba(255, 255, 255, 0.7);
        }

        .login-form .form-label {
            display: block;
            font-size: 14px;
            font-weight: 600;
            color: rgba(255, 255, 255, 0.9);
            margin-bottom: 10px;
            text-shadow: 0 1px 2px rgba(0,0,0,0.5);
        }

        .form-group {
            margin-bottom: 24px;
        }

        .login-form .form-control {
            width: 100%;
            height: 54px;
            font-size: 16px;
            border-radius: 16px;
            /* 3D Input Style */
            background: rgba(0, 0, 0, 0.3);
            border: 1px solid rgba(255, 255, 255, 0.1);
            color: white;
            padding: 0 16px;
            box-shadow: inset 0 3px 6px rgba(0,0,0,0.4);
            transition: all 0.3s ease;
            box-sizing: border-box;
            font-family: inherit;
        }

        .login-form .form-control::placeholder {
            color: rgba(255, 255, 255, 0.4);
        }

        .login-form .form-control:focus {
            outline: none;
            border-color: #FF9800;
            background: rgba(0, 0, 0, 0.5);
            box-shadow: inset 0 3px 6px rgba(0,0,0,0.4), 
                        0 0 0 4px rgba(255, 152, 0, 0.2);
        }

        .login-btn {
            width: 100%;
            height: 56px;
            /* 3D Glossy Button */
            background: linear-gradient(135deg, #FFB74D, #FF6D00);
            color: white;
            border: none;
            border-radius: 16px;
            font-size: 18px;
            font-weight: 700;
            font-family: inherit;
            cursor: pointer;
            transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            margin-top: 12px;
            box-shadow: 0 10px 25px rgba(255, 109, 0, 0.4),
                        inset 0 2px 0 rgba(255, 255, 255, 0.4),
                        inset 0 -4px 0 rgba(0, 0, 0, 0.2);
            text-shadow: 0 1px 2px rgba(0,0,0,0.3);
        }

        .login-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 35px rgba(255, 109, 0, 0.5),
                        inset 0 2px 0 rgba(255, 255, 255, 0.5),
                        inset 0 -4px 0 rgba(0, 0, 0, 0.2);
            background: linear-gradient(135deg, #FFCC80, #FF6D00);
        }

        .login-btn:active { 
            transform: translateY(2px);
            box-shadow: 0 5px 15px rgba(255, 109, 0, 0.3),
                        inset 0 2px 4px rgba(0, 0, 0, 0.2);
        }

        .error-msg {
            background: rgba(220, 38, 38, 0.2);
            color: #fecaca;
            padding: 14px 18px;
            border-radius: 14px;
            border: 1px solid rgba(239, 68, 68, 0.5);
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 12px;
            backdrop-filter: blur(12px);
            box-shadow: 0 4px 12px rgba(220, 38, 38, 0.2);
        }
        .error-msg svg {
            flex-shrink: 0;
            color: #ef4444;
        }

        /* Theme Toggle Button */
        .theme-toggle-login {
            position: fixed;
            top: 24px;
            left: 24px;
            background: rgba(20, 20, 30, 0.4);
            backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.15);
            border-radius: 12px;
            padding: 10px;
            cursor: pointer;
            color: white;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 10;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
        }
        .theme-toggle-login:hover {
            background: rgba(255, 255, 255, 0.1);
            transform: translateY(-2px);
        }

        /* Light Theme Overrides */
        [data-theme="light"] body::before {
            background: linear-gradient(135deg, rgba(255, 255, 255, 0.5) 0%, rgba(255, 255, 255, 0.2) 100%);
        }
        [data-theme="light"] .login-card {
            background: rgba(255, 255, 255, 0.75);
            backdrop-filter: blur(40px);
            -webkit-backdrop-filter: blur(40px);
            border: 1px solid rgba(255, 255, 255, 0.8);
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.1), 
                        inset 0 0 0 1px rgba(255, 255, 255, 1);
        }
        [data-theme="light"] .login-title {
            color: #111827;
            text-shadow: none;
            font-weight: 800;
        }
        [data-theme="light"] .login-sub,
        [data-theme="light"] .login-form .form-label {
            color: #374151;
            text-shadow: none;
            font-weight: 600;
        }
        [data-theme="light"] .login-form .form-control {
            background: rgba(255, 255, 255, 0.8);
            border: 1.5px solid rgba(200, 200, 200, 0.5);
            color: #111827;
            box-shadow: inset 0 2px 5px rgba(0,0,0,0.04);
        }
        [data-theme="light"] .login-form .form-control::placeholder {
            color: #9CA3AF;
        }
        [data-theme="light"] .login-form .form-control:focus {
            background: #ffffff;
            border-color: #FF9800;
            box-shadow: inset 0 2px 5px rgba(0,0,0,0.04), 
                        0 0 0 4px rgba(255, 152, 0, 0.15);
        }
        [data-theme="light"] .error-msg {
            background: #fef2f2;
            color: #991b1b;
            border: 1.5px solid #f87171;
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.12);
        }
        [data-theme="light"] .error-msg svg {
            color: #dc2626;
        }
        [data-theme="light"] .theme-toggle-login {
            background: rgba(255, 255, 255, 0.8);
            color: #111827;
            border-color: rgba(200, 200, 200, 0.5);
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
        }
        [data-theme="light"] .theme-toggle-login:hover {
            background: #ffffff;
            transform: translateY(-2px);
        }
        [data-theme="light"] .login-logo-icon {
            /* Makes the white background of the JPEG transparent in light mode */
            mix-blend-mode: multiply;
            box-shadow: none;
            border: none;
            background-color: transparent;
        }
    </style>
</head>
<body>

    <!-- Theme Toggle -->
    <button class="theme-toggle-login" onclick="toggleTheme()" title="تغيير المظهر">
        <svg id="sunIcon" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <circle cx="12" cy="12" r="5"/>
            <line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/>
            <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/>
            <line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/>
        </svg>
        <svg id="moonIcon" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" style="display:none;">
            <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>
        </svg>
    </button>

    <div class="login-container">
        <div class="login-card">

            <!-- Logo -->
            <div class="login-logo">
                <img src="{{ asset('logo.jpeg') }}" alt="شعار لفة" class="login-logo-icon">
                <div class="login-title">لَفَّة</div>
                <div class="login-sub">لوحة تحكم المدير</div>
            </div>

            <!-- Errors -->
            @if ($errors->any())
                <div class="error-msg">
                    <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                    {{ $errors->first() }}
                </div>
            @endif

            <!-- Login Form -->
            <form method="POST" action="{{ route('admin.login.post') }}" class="login-form">
                @csrf

                <div class="form-group">
                    <label for="name" class="form-label">اسم المستخدم</label>
                    <input
                        type="text"
                        id="name"
                        name="name"
                        class="form-control"
                        value="{{ old('name') }}"
                        placeholder="أدخل اسم المستخدم"
                        required
                        autofocus
                    >
                </div>

                <div class="form-group">
                    <label for="password" class="form-label">كلمة المرور</label>
                    <input
                        type="password"
                        id="password"
                        name="password"
                        class="form-control"
                        placeholder="أدخل كلمة المرور"
                        required
                    >
                </div>

                <button type="submit" class="login-btn">
                    تسجيل الدخول
                    <svg width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/>
                        <polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/>
                    </svg>
                </button>
            </form>

        </div>
    </div>

    <script>
        function toggleTheme() {
            const html = document.documentElement;
            const current = html.getAttribute('data-theme');
            const next = current === 'dark' ? 'light' : 'dark';
            html.setAttribute('data-theme', next);
            localStorage.setItem('laffah-admin-theme', next);
            document.getElementById('sunIcon').style.display  = next === 'dark'  ? 'block' : 'none';
            document.getElementById('moonIcon').style.display = next === 'light' ? 'block' : 'none';
        }
        (function() {
            const saved = localStorage.getItem('laffah-admin-theme') || 'dark';
            document.documentElement.setAttribute('data-theme', saved);
            if (saved === 'light') {
                document.getElementById('sunIcon').style.display  = 'none';
                document.getElementById('moonIcon').style.display = 'block';
            }
        })();
    </script>
</body>
</html>
