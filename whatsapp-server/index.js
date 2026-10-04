const express = require('express');
const { default: makeWASocket, useMultiFileAuthState, DisconnectReason, Browsers, delay } = require('@whiskeysockets/baileys');
const pino = require('pino');
const qrcodeTerminal = require('qrcode-terminal');
const QRCode = require('qrcode');
const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const PORT = process.env.PORT || 3000;
const AUTH_DIR = path.join(__dirname, 'auth_info_baileys');

// Database Configuration (TiDB Cloud MySQL)
const dbConfig = {
    host: process.env.DB_HOST || 'gateway01.eu-central-1.prod.aws.tidbcloud.com',
    port: parseInt(process.env.DB_PORT || '4000', 10),
    user: process.env.DB_USERNAME || '4LrCBJtar4EPAKf.root',
    password: process.env.DB_PASSWORD || 'ttszFzgj4i1Wcg7U',
    database: process.env.DB_DATABASE || 'test',
    ssl: { rejectUnauthorized: false },
    waitForConnections: true,
    connectionLimit: 5,
};

let dbPool = null;

// Initialize Database Pool
try {
    dbPool = mysql.createPool(dbConfig);
    console.log('✅ TiDB MySQL Pool initialized for session persistence');
} catch (e) {
    console.warn('⚠️ Warning: MySQL pool initialization failed:', e.message);
}

// Ensure database table exists
async function ensureSessionTable() {
    if (!dbPool) return;
    try {
        await dbPool.execute(`
            CREATE TABLE IF NOT EXISTS whatsapp_sessions (
                id VARCHAR(191) PRIMARY KEY,
                data LONGTEXT NOT NULL,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        `);
    } catch (e) {
        console.warn('⚠️ Could not verify whatsapp_sessions table:', e.message);
    }
}

// Restore session from DB to filesystem
async function restoreSessionFromDB() {
    if (!dbPool) return;
    try {
        if (!fs.existsSync(AUTH_DIR)) {
            fs.mkdirSync(AUTH_DIR, { recursive: true });
        }
        const [rows] = await dbPool.execute('SELECT id, data FROM whatsapp_sessions');
        for (const row of rows) {
            fs.writeFileSync(path.join(AUTH_DIR, row.id), row.data, 'utf-8');
        }
        if (rows.length > 0) {
            console.log(`📦 Restored ${rows.length} session credentials from cloud database.`);
        }
    } catch (e) {
        console.warn('⚠️ Could not restore session from DB:', e.message);
    }
}

// Backup session from filesystem to DB
async function backupSessionToDB() {
    if (!dbPool || !fs.existsSync(AUTH_DIR)) return;
    try {
        const files = fs.readdirSync(AUTH_DIR);
        for (const file of files) {
            if (file.endsWith('.json')) {
                const content = fs.readFileSync(path.join(AUTH_DIR, file), 'utf-8');
                await dbPool.execute(
                    'INSERT INTO whatsapp_sessions (id, data) VALUES (?, ?) ON DUPLICATE KEY UPDATE data = VALUES(data), updated_at = NOW()',
                    [file, content]
                );
            }
        }
    } catch (e) {
        console.warn('⚠️ Could not backup session to DB:', e.message);
    }
}

// Global WhatsApp State
let sock = null;
let currentQR = null;
let currentQRImage = null;
let connectionStatus = 'initializing'; // initializing, waiting_qr, connected, disconnected
let connectedPhone = null;
let isConnecting = false;

async function connectToWhatsApp() {
    if (isConnecting) return;
    isConnecting = true;

    try {
        await ensureSessionTable();
        await restoreSessionFromDB();

        const { state, saveCreds } = await useMultiFileAuthState(AUTH_DIR);

        sock = makeWASocket({
            auth: state,
            printQRInTerminal: false,
            logger: pino({ level: 'silent' }),
            browser: Browsers.macOS('Desktop'),
            syncFullHistory: false,
        });

        sock.ev.on('connection.update', async (update) => {
            const { connection, lastDisconnect, qr } = update;

            if (qr) {
                currentQR = qr;
                connectionStatus = 'waiting_qr';
                try {
                    currentQRImage = await QRCode.toDataURL(qr);
                } catch (_) {}
                console.log('📱 SCAN QR CODE OR USE PAIRING CODE');
                qrcodeTerminal.generate(qr, { small: true });
            }

            if (connection === 'close') {
                const statusCode = lastDisconnect?.error?.output?.statusCode;
                const shouldReconnect = statusCode !== DisconnectReason.loggedOut;
                console.log(`Connection closed (status: ${statusCode}), reconnecting: ${shouldReconnect}`);
                
                connectionStatus = 'disconnected';
                currentQR = null;
                currentQRImage = null;
                connectedPhone = null;
                isConnecting = false;

                if (statusCode === DisconnectReason.loggedOut) {
                    console.log('User logged out. Clearing stored credentials...');
                    try {
                        if (fs.existsSync(AUTH_DIR)) {
                            fs.rmSync(AUTH_DIR, { recursive: true, force: true });
                        }
                        if (dbPool) {
                            await dbPool.execute('DELETE FROM whatsapp_sessions');
                        }
                    } catch (_) {}
                }

                if (shouldReconnect) {
                    setTimeout(connectToWhatsApp, 3000);
                }
            } else if (connection === 'open') {
                connectionStatus = 'connected';
                currentQR = null;
                currentQRImage = null;
                isConnecting = false;

                const rawId = sock.user?.id || '';
                connectedPhone = rawId.split(':')[0] || rawId.split('@')[0];
                console.log(`✅ WHATSAPP IS CONNECTED AS: +${connectedPhone}`);
                
                // Backup valid session to cloud database
                await backupSessionToDB();
            }
        });

        sock.ev.on('creds.update', async () => {
            await saveCreds();
            await backupSessionToDB();
        });

    } catch (err) {
        console.error('Error connecting to WhatsApp:', err);
        isConnecting = false;
        setTimeout(connectToWhatsApp, 5000);
    }
}

// ----------------------------------------------------
// API ROUTES
// ----------------------------------------------------

// 1. Health & Status JSON
app.get('/status', (req, res) => {
    res.json({
        status: connectionStatus,
        connected: connectionStatus === 'connected',
        phone: connectedPhone,
        hasQR: Boolean(currentQR),
    });
});

app.get('/health', (req, res) => {
    res.json({
        service: 'laffah-whatsapp',
        status: connectionStatus === 'connected' ? 'healthy' : 'ready',
        whatsappConnected: connectionStatus === 'connected',
        phone: connectedPhone,
    });
});

// 2. Dynamic QR Image
app.get('/qr-image', async (req, res) => {
    if (!currentQR) {
        return res.status(404).send('No active QR code. Server may already be connected or initializing.');
    }
    try {
        const qrBuffer = await QRCode.toBuffer(currentQR, { width: 320, margin: 2 });
        res.setHeader('Content-Type', 'image/png');
        res.send(qrBuffer);
    } catch (e) {
        res.status(500).send('Error generating QR image');
    }
});

// 3. Request Pairing Code (Link by Phone Number without QR scan)
app.post('/pair', async (req, res) => {
    try {
        let phone = req.body.phone || '967770291452';
        phone = phone.replace(/[^0-9]/g, '');

        if (!sock) {
            return res.status(503).json({ error: 'WhatsApp socket is not initialized' });
        }

        if (connectionStatus === 'connected') {
            return res.json({
                success: true,
                message: 'Already connected!',
                connectedPhone: connectedPhone
            });
        }

        // Wait slightly if socket was just started
        await delay(1000);

        const code = await sock.requestPairingCode(phone);
        console.log(`🔑 Pairing Code generated for +${phone}: ${code}`);
        
        return res.json({
            success: true,
            phone: phone,
            code: code,
            instructions: 'افتح واتساب في هاتفك > الإعدادات > الأجهزة المرتبطة > الربط برقم الهاتف > وأدخل هذا الكود.'
        });
    } catch (err) {
        console.error('Error requesting pairing code:', err);
        return res.status(500).json({ error: 'Failed to request pairing code', details: err.message });
    }
});

// 4. Send Message Endpoint (Called by Laravel Backend)
app.post('/send-message', async (req, res) => {
    try {
        const { phone, message } = req.body;

        if (!phone || !message) {
            return res.status(400).json({ error: 'Phone and message are required' });
        }

        if (!sock || !sock.user || connectionStatus !== 'connected') {
            return res.status(503).json({
                error: 'WhatsApp is not connected',
                status: connectionStatus,
                action: 'Please visit https://laffah-whatsapp.onrender.com to link your WhatsApp.'
            });
        }

        // Normalize phone number (Yemeni digits)
        let cleanPhone = String(phone).replace(/[^0-9]/g, '');
        if (cleanPhone.length === 9) {
            cleanPhone = '967' + cleanPhone;
        }

        const jid = `${cleanPhone}@s.whatsapp.net`;
        await sock.sendMessage(jid, { text: message });

        console.log(`✉️ Message sent successfully to +${cleanPhone}`);
        return res.json({ success: true, message: 'Message sent successfully', recipient: cleanPhone });
    } catch (error) {
        console.error('Error sending message:', error);
        return res.status(500).json({ error: 'Failed to send message', details: error.message });
    }
});

// 5. Logout / Disconnect Endpoint
app.post('/logout', async (req, res) => {
    try {
        if (sock) {
            await sock.logout();
        }
        if (fs.existsSync(AUTH_DIR)) {
            fs.rmSync(AUTH_DIR, { recursive: true, force: true });
        }
        if (dbPool) {
            await dbPool.execute('DELETE FROM whatsapp_sessions');
        }
        connectedPhone = null;
        connectionStatus = 'disconnected';
        setTimeout(connectToWhatsApp, 1500);
        res.json({ success: true, message: 'Logged out successfully. Reinitializing fresh session...' });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// 6. Interactive Web Dashboard at GET /
app.get('/', (req, res) => {
    const isConnected = connectionStatus === 'connected';

    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    res.send(`
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>لَفَّة • خادم إرسال رسائل واتساب</title>
    <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans+Arabic:wght@400;600;700;800&display=swap" rel="stylesheet">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'IBM Plex Sans Arabic', sans-serif; }
        body { background: #0A0D14; color: #E5E7EB; min-height: 100vh; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 20px; }
        .card { background: #131823; border: 1px solid rgba(255, 122, 0, 0.2); border-radius: 24px; padding: 32px; max-width: 520px; width: 100%; box-shadow: 0 20px 40px rgba(0,0,0,0.5); text-align: center; }
        .logo { font-size: 28px; font-weight: 800; color: #FF7A00; margin-bottom: 6px; }
        .subtitle { font-size: 13px; color: #9CA3AF; margin-bottom: 24px; }
        .badge { display: inline-flex; align-items: center; gap: 8px; padding: 8px 16px; border-radius: 20px; font-size: 13px; font-weight: 700; margin-bottom: 24px; }
        .badge-success { background: rgba(16, 185, 129, 0.15); color: #10B981; border: 1px solid rgba(16, 185, 129, 0.3); }
        .badge-warning { background: rgba(245, 158, 11, 0.15); color: #F59E0B; border: 1px solid rgba(245, 158, 11, 0.3); }
        .qr-box { background: white; padding: 16px; border-radius: 18px; display: inline-block; margin-bottom: 20px; box-shadow: 0 8px 24px rgba(0,0,0,0.3); }
        .qr-box img { display: block; width: 220px; height: 220px; }
        .pair-box { background: #1A2232; border: 1px dashed rgba(255, 122, 0, 0.4); border-radius: 18px; padding: 20px; margin-top: 20px; text-align: right; }
        .pair-title { font-size: 14px; font-weight: 700; color: #FF7A00; margin-bottom: 8px; }
        .pair-desc { font-size: 12px; color: #9CA3AF; line-height: 1.5; margin-bottom: 12px; }
        .input-group { display: flex; gap: 8px; margin-bottom: 12px; }
        input[type="text"] { flex: 1; background: #0F141F; border: 1px solid #374151; color: white; padding: 10px 14px; border-radius: 12px; font-size: 14px; direction: ltr; text-align: left; }
        button { background: #FF7A00; color: white; border: none; padding: 10px 18px; border-radius: 12px; font-weight: 700; cursor: pointer; transition: 0.2s; font-size: 13px; }
        button:hover { background: #E06900; }
        .code-display { background: #0F141F; border: 2px solid #10B981; border-radius: 14px; padding: 14px; text-align: center; font-size: 24px; font-weight: 800; letter-spacing: 4px; color: #10B981; margin-top: 10px; display: none; }
        .test-box { margin-top: 24px; text-align: right; background: #182030; padding: 18px; border-radius: 16px; }
        .footer { font-size: 11px; color: #6B7280; margin-top: 20px; }
    </style>
</head>
<body>
    <div class="card">
        <div class="logo">🚕 لَفَّة • Laffah</div>
        <div class="subtitle">بوابة إرسال رسائل التحقق (OTP) عبر واتساب</div>

        ${isConnected ? `
            <div class="badge badge-success">
                🟢 متصل بنجاح برقم: +${connectedPhone}
            </div>
            <p style="font-size: 13px; color: #D1D5DB; margin-bottom: 20px;">
                الخادم متصل وجاهز لإرسال رسائل OTP والتحقق لكافة مستخدمي التطبيق فوراً.
            </p>

            <div class="test-box">
                <div style="font-weight: 700; font-size: 13px; margin-bottom: 10px; color: #FF7A00;">إرسال رسالة تجريبية:</div>
                <input type="text" id="testPhone" placeholder="967770291452" style="width: 100%; margin-bottom: 8px;">
                <textarea id="testMsg" placeholder="نص الرسالة..." style="width: 100%; background: #0F141F; border: 1px solid #374151; color: white; padding: 10px; border-radius: 12px; font-size: 12px; margin-bottom: 10px; resize: none;" rows="2">تجربة إرسال رسالة من خادم لَفَّة واتساب بنجاح 🚕</textarea>
                <button onclick="sendTestMessage()" style="width: 100%;">إرسال الآن</button>
                <div id="testResult" style="font-size: 12px; margin-top: 8px;"></div>
            </div>

            <form action="/logout" method="POST" style="margin-top: 16px;">
                <button type="submit" style="background: transparent; color: #EF4444; border: 1px solid #EF4444; padding: 6px 14px; font-size: 11px;">قطع الاتصال وتغيير الرقم</button>
            </form>
        ` : `
            <div class="badge badge-warning">
                ⏳ بانتظار ربط حساب الواتساب
            </div>

            ${currentQRImage ? `
                <div class="qr-box">
                    <img src="${currentQRImage}" alt="WhatsApp QR Code">
                </div>
                <div style="font-size: 12px; color: #9CA3AF; margin-bottom: 16px;">
                    امسح رمز QR أعلاه بكاميرا واتساب من هاتفك (الأجهزة المرتبطة).
                </div>
            ` : `
                <p style="font-size: 13px; color: #9CA3AF; margin-bottom: 16px;">
                    جاري توليد رمز الاتصال... يُرجى الانتظار ثوانٍ أو استخدام كود الربط بالرقم أدناه.
                </p>
            `}

            <div class="pair-box">
                <div class="pair-title">⚡ الربط المباشر برقم الهاتف (بدون كاميرا)</div>
                <div class="pair-desc">
                    أدخل رقم الهاتف للحصول على كود الاقتران السريع المكون من 8 خانات:
                </div>
                <div class="input-group">
                    <input type="text" id="phoneInput" value="967770291452" placeholder="967770291452">
                    <button onclick="requestPairingCode()">طلب الكود</button>
                </div>
                <div id="codeDisplay" class="code-display"></div>
                <div id="codeInstructions" style="display: none; font-size: 11.5px; color: #D1D5DB; margin-top: 8px; line-height: 1.5;">
                    1. افتح واتساب في هاتفك <br>
                    2. الإعدادات ⚙️ > <b>الأجهزة المرتبطة</b> > <b>ربط جهاز</b> <br>
                    3. اختر <b>"الربط باستخدام رقم الهاتف بدلاً من ذلك"</b> <br>
                    4. أدخل الكود الموضح بالأعلى.
                </div>
            </div>
        `}

        <div class="footer">
            جلسة دائمة ومحفوظة سحابياً • Laffah Mobility Platform © 2026
        </div>
    </div>

    <script>
        async function requestPairingCode() {
            const phone = document.getElementById('phoneInput').value.trim();
            const display = document.getElementById('codeDisplay');
            const instructions = document.getElementById('codeInstructions');
            
            display.style.display = 'block';
            display.style.color = '#F59E0B';
            display.innerText = 'جاري طلب الكود...';

            try {
                const res = await fetch('/pair', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ phone: phone })
                });
                const data = await res.json();
                if(data.success && data.code) {
                    display.style.color = '#10B981';
                    display.innerText = data.code;
                    instructions.style.display = 'block';
                } else {
                    display.style.color = '#EF4444';
                    display.innerText = data.error || 'تعذر طلب الكود. حاول ثانية';
                }
            } catch(e) {
                display.style.color = '#EF4444';
                display.innerText = 'خطأ في الاتصال';
            }
        }

        async function sendTestMessage() {
            const phone = document.getElementById('testPhone').value.trim();
            const message = document.getElementById('testMsg').value.trim();
            const result = document.getElementById('testResult');

            result.innerHTML = '<span style="color:#F59E0B;">جاري الإرسال...</span>';
            try {
                const res = await fetch('/send-message', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ phone, message })
                });
                const data = await res.json();
                if(data.success) {
                    result.innerHTML = '<span style="color:#10B981;">✅ تم إرسال الرسالة بنجاح!</span>';
                } else {
                    result.innerHTML = '<span style="color:#EF4444;">❌ فشل الإرسال: ' + (data.error || 'خطأ غير معروف') + '</span>';
                }
            } catch(e) {
                result.innerHTML = '<span style="color:#EF4444;">❌ خطأ في الاتصال بالخادم</span>';
            }
        }

        // Auto refresh every 20s if not connected to update QR
        ${!isConnected ? `
            setTimeout(() => {
                window.location.reload();
            }, 20000);
        ` : ''}
    </script>
</body>
</html>
    `);
});

// Start Server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Laffah WhatsApp Gateway listening on port ${PORT}`);
    connectToWhatsApp();
});
