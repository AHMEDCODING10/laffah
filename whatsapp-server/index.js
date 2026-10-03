const express = require('express');
const { default: makeWASocket, useMultiFileAuthState, DisconnectReason, Browsers } = require('@whiskeysockets/baileys');
const pino = require('pino');
const qrcode = require('qrcode-terminal');

const app = express();
app.use(express.json());

let sock;

async function connectToWhatsApp() {
    const { state, saveCreds } = await useMultiFileAuthState('auth_info_baileys');
    
    sock = makeWASocket({
        auth: state,
        printQRInTerminal: false,
        logger: pino({ level: 'silent' }),
        browser: Browsers.macOS('Desktop')
    });

    sock.ev.on('connection.update', (update) => {
        const { connection, lastDisconnect, qr } = update;
        
        if(qr) {
            console.log('SCAN THIS QR CODE WITH YOUR WHATSAPP (Linked Devices):');
            qrcode.generate(qr, {small: true});
        }

        if(connection === 'close') {
            const shouldReconnect = lastDisconnect.error?.output?.statusCode !== DisconnectReason.loggedOut;
            console.log('Connection closed due to ', lastDisconnect.error, ', reconnecting ', shouldReconnect);
            if(shouldReconnect) {
                connectToWhatsApp();
            }
        } else if(connection === 'open') {
            console.log('✅ WHATSAPP SERVER IS READY AND CONNECTED!');
        }
    });

    sock.ev.on('creds.update', saveCreds);
}

// Endpoint for Laravel to send messages
app.post('/send-message', async (req, res) => {
    try {
        const { phone, message } = req.body;
        
        if(!phone || !message) {
            return res.status(400).json({ error: 'Phone and message are required' });
        }

        // Format phone to JID
        const jid = `${phone}@s.whatsapp.net`;
        
        // Send message
        await sock.sendMessage(jid, { text: message });
        
        res.json({ success: true, message: 'Message sent successfully' });
    } catch (error) {
        console.error('Error sending message:', error);
        res.status(500).json({ error: 'Failed to send message', details: error.message });
    }
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`🚀 WhatsApp API Server running on port ${PORT}`);
    connectToWhatsApp();
});
