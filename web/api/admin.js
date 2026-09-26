/**
 * ==============================================================================
 * TXA STUDIO WEB ADMIN PANEL & ERROR LOG EXPLORER FOR VERCEL
 * Đường dẫn truy cập: https://txastudio.click/api/admin (hoặc /admin)
 * ==============================================================================
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { loadLogList, clearLogs } = require('./logger');

const ADMIN_PASS = process.env.ADMIN_PASSWORD || "txa_admin_2026";
const DATA_FILE = process.env.VERCEL ? '/tmp/txa_keys_db.json' : path.join(__dirname, '../keys.json');

const DEFAULT_KEYS = [
    { key: "TXA-MASTER-STUDIO-CLICK-2026", user: "Admin Master", role: "MASTER", status: "active", expires: "Vĩnh viễn", createdAt: "2026-01-01" },
    { key: "TXA-VIP-TXASTUDIO-CLICK", user: "TXA Partner VIP", role: "VIP", status: "active", expires: "2030-12-31", createdAt: "2026-01-01" },
    { key: "TXA-VIP-8A2F9C-5D1B8E20", user: "Khách Demo 1", role: "VIP", status: "active", expires: "Vĩnh viễn", createdAt: "2026-09-26" }
];

function loadKeys() {
    try {
        if (fs.existsSync(DATA_FILE)) {
            const raw = fs.readFileSync(DATA_FILE, 'utf8');
            const parsed = JSON.parse(raw);
            return parsed.keys || parsed;
        }
    } catch (e) {}
    return DEFAULT_KEYS;
}

function saveKeys(keys) {
    try {
        fs.writeFileSync(DATA_FILE, JSON.stringify({ keys }, null, 2), 'utf8');
    } catch (e) {}
}

module.exports = async (req, res) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    if (req.method === 'OPTIONS') return res.status(204).end();

    const action = req.query.action || '';
    const pass = req.headers['authorization'] || req.query.pass || '';

    // API: Kiểm tra mật khẩu đăng nhập
    if (action === 'check_auth') {
        if (pass === ADMIN_PASS) {
            return res.status(200).json({ success: true });
        }
        return res.status(401).json({ success: false, message: "Sai mật khẩu Admin" });
    }

    // API: Lấy danh sách key
    if (action === 'get_keys') {
        if (pass !== ADMIN_PASS) return res.status(401).json({ error: "Sai mật khẩu" });
        return res.status(200).json(loadKeys());
    }

    // API: Lấy danh sách Crash/Error Logs
    if (action === 'get_logs') {
        if (pass !== ADMIN_PASS) return res.status(401).json({ error: "Sai mật khẩu" });
        return res.status(200).json(loadLogList());
    }

    // API: Xóa log
    if (action === 'clear_logs' && req.method === 'POST') {
        if (pass !== ADMIN_PASS) return res.status(401).json({ error: "Sai mật khẩu" });
        clearLogs();
        return res.status(200).json({ success: true, message: "Đã xóa toàn bộ log lỗi" });
    }

    // API: Tạo key mới
    if (action === 'create_key' && req.method === 'POST') {
        if (pass !== ADMIN_PASS) return res.status(401).json({ error: "Sai mật khẩu" });
        const { user, role, expires } = req.body || {};
        const rand = crypto.randomBytes(3).toString('hex').toUpperCase();
        const hash = crypto.createHash('sha256').update(`TXA-${role || 'VIP'}-${rand}:TXA_STUDIO_CYBER_2026_CLICK`).digest('hex').substring(0, 8).toUpperCase();
        const newKeyStr = `TXA-${role || 'VIP'}-${rand}-${hash}`;

        const keys = loadKeys();
        const newObj = {
            key: newKeyStr,
            user: user || 'Khách hàng mới',
            role: role || 'VIP',
            status: 'active',
            expires: expires || 'Vĩnh viễn',
            createdAt: new Date().toISOString().split('T')[0]
        };
        keys.unshift(newObj);
        saveKeys(keys);
        return res.status(200).json({ success: true, key: newObj });
    }

    // API: Đổi trạng thái key (Khóa/Mở khóa)
    if (action === 'toggle_key' && req.method === 'POST') {
        if (pass !== ADMIN_PASS) return res.status(401).json({ error: "Sai mật khẩu" });
        const { targetKey } = req.body || {};
        const keys = loadKeys();
        const found = keys.find(k => k.key === targetKey);
        if (found) {
            found.status = found.status === 'active' ? 'blocked' : 'active';
            saveKeys(keys);
            return res.status(200).json({ success: true, status: found.status });
        }
        return res.status(404).json({ error: "Không tìm thấy key" });
    }

    // MẶC ĐỊNH: Trả về Giao diện Web Quản Trị Viên (Kèm Màn Hình Khóa Đăng Nhập)
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    return res.status(200).send(renderAdminHtml());
};

function renderAdminHtml() {
    return `<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TXA STUDIO | Trung Tâm Quản Trị Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@600;900&family=Rajdhani:wght@500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg: #070b14;
            --panel: rgba(15, 23, 42, 0.85);
            --cyan: #00f3ff;
            --magenta: #ff0055;
            --green: #00ff88;
            --yellow: #ffd000;
            --border: rgba(0, 243, 255, 0.25);
            --text: #e2e8f0;
            --text-dim: #8b9bb4;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            background-color: var(--bg);
            background-image: 
                radial-gradient(circle at 10% 20%, rgba(0, 243, 255, 0.08) 0%, transparent 40%),
                radial-gradient(circle at 90% 80%, rgba(255, 0, 85, 0.08) 0%, transparent 40%);
            color: var(--text);
            font-family: 'Rajdhani', sans-serif;
            padding: 20px;
            min-height: 100vh;
        }

        /* MÀN HÌNH KHÓA ĐĂNG NHẬP */
        #login-screen {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 80vh;
        }
        .login-box {
            background: var(--panel);
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 35px 30px;
            width: 100%;
            max-width: 420px;
            backdrop-filter: blur(16px);
            box-shadow: 0 0 35px rgba(0, 243, 255, 0.2);
            text-align: center;
            position: relative;
        }
        .login-box::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 2px;
            background: linear-gradient(90deg, transparent, var(--cyan), transparent);
        }
        .login-title {
            font-family: 'Orbitron', monospace;
            font-size: 1.25rem;
            color: var(--cyan);
            margin-bottom: 8px;
            text-shadow: 0 0 10px rgba(0, 243, 255, 0.4);
        }
        .login-sub {
            font-size: 0.85rem;
            color: var(--text-dim);
            margin-bottom: 25px;
        }

        /* GIAO DIỆN CHÍNH SAU KHI ĐĂNG NHẬP */
        #dashboard-screen {
            display: none;
        }
        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--border);
            padding-bottom: 15px;
            margin-bottom: 25px;
            flex-wrap: wrap;
            gap: 15px;
        }
        .logo { font-family: 'Orbitron', monospace; font-size: 1.35rem; color: var(--cyan); text-shadow: 0 0 10px rgba(0, 243, 255, 0.4); }
        .tabs { display: flex; gap: 10px; margin-bottom: 20px; }
        .tab-btn {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border);
            color: var(--text);
            padding: 10px 20px;
            border-radius: 6px;
            cursor: pointer;
            font-family: 'Rajdhani', sans-serif;
            font-size: 1rem;
            font-weight: 700;
            transition: all 0.2s;
        }
        .tab-btn.active {
            background: var(--cyan);
            color: #000;
            box-shadow: 0 0 15px rgba(0, 243, 255, 0.5);
        }
        .card {
            background: var(--panel);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 20px;
            backdrop-filter: blur(12px);
        }
        .card-title {
            font-family: 'Orbitron', sans-serif;
            color: var(--cyan);
            font-size: 1.05rem;
            margin-bottom: 15px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .form-row { display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 15px; }
        input, select {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.15);
            padding: 11px 14px;
            border-radius: 6px;
            color: #fff;
            font-family: inherit;
            outline: none;
            width: 100%;
        }
        input:focus { border-color: var(--cyan); box-shadow: 0 0 10px rgba(0, 243, 255, 0.3); }
        button {
            background: var(--cyan);
            color: #000;
            border: none;
            padding: 11px 20px;
            border-radius: 6px;
            font-weight: 700;
            cursor: pointer;
            font-family: inherit;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
        }
        button:hover { box-shadow: 0 0 15px rgba(0, 243, 255, 0.5); transform: translateY(-1px); }
        button.btn-danger { background: var(--magenta); color: #fff; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { text-align: left; padding: 12px; border-bottom: 1px solid rgba(255, 255, 255, 0.05); }
        th { color: var(--cyan); font-family: 'Orbitron', sans-serif; font-size: 0.8rem; }
        .key-text { font-family: monospace; color: var(--green); font-weight: 700; }
        .badge { padding: 3px 8px; border-radius: 4px; font-size: 0.8rem; font-weight: 700; }
        .badge-active { background: rgba(0, 255, 136, 0.15); color: var(--green); }
        .badge-blocked { background: rgba(255, 0, 85, 0.15); color: var(--magenta); }
        .device-tag {
            background: rgba(0, 243, 255, 0.1);
            border: 1px solid var(--cyan);
            color: var(--cyan);
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 0.85rem;
            display: inline-block;
        }
        .log-item {
            background: rgba(255, 255, 255, 0.02);
            border-left: 3px solid var(--magenta);
            padding: 15px;
            margin-bottom: 15px;
            border-radius: 0 8px 8px 0;
        }
        .stack-box {
            background: #04060a;
            border: 1px solid rgba(255, 0, 85, 0.3);
            color: #ff5577;
            font-family: monospace;
            padding: 10px;
            border-radius: 6px;
            margin-top: 10px;
            font-size: 0.8rem;
            max-height: 150px;
            overflow-y: auto;
            white-space: pre-wrap;
        }
        .error-msg { color: var(--magenta); font-size: 0.85rem; margin-top: 10px; display: none; }
    </style>
</head>
<body>

    <!-- 1. MÀN HÌNH KHÓA ĐĂNG NHẬP -->
    <div id="login-screen">
        <div class="login-box">
            <div style="font-size:2.5rem; margin-bottom:10px;">🔒</div>
            <div class="login-title">TXA STUDIO ADMIN GATEWAY</div>
            <div class="login-sub">Cổng Quản Trị Hệ Thống: <strong>txastudio.click/api/admin</strong></div>
            
            <form onsubmit="handleLogin(event)">
                <input type="password" id="pass-input" placeholder="Nhập Mật Khẩu Admin..." required autofocus>
                <button type="submit" style="width:100%; margin-top:15px;">🔓 MỞ KHÓA BẢNG ĐIỀU KHIỂN</button>
                <div class="error-msg" id="login-error">Mật khẩu không chính xác!</div>
            </form>
        </div>
    </div>

    <!-- 2. BẢNG ĐIỀU KHIỂN SAU KHI ĐĂNG NHẬP -->
    <div id="dashboard-screen">
        <header>
            <div>
                <div class="logo">⚡ TXA STUDIO ADMIN CONTROL</div>
                <div style="color:var(--text-dim); font-size:0.85rem;">Quản Lý Bản Quyền & Giám Sát Crash/Lỗi Máy Chủ: <strong>txastudio.click</strong></div>
            </div>
            <div style="display:flex; gap:10px;">
                <button onclick="refreshAll()" style="padding:6px 12px; font-size:0.85rem;">🔄 Làm Mới</button>
                <button onclick="handleLogout()" class="btn-danger" style="padding:6px 12px; font-size:0.85rem;">🔒 Đăng Xuất</button>
            </div>
        </header>

        <div class="tabs">
            <button class="tab-btn active" onclick="switchTab('keys')">🔑 Quản Lý Key Bản Quyền</button>
            <button class="tab-btn" onclick="switchTab('logs')">🚨 Báo Cáo Crash & Lỗi Chi Tiết</button>
        </div>

        <!-- TAB 1: QUẢN LÝ KEY -->
        <div id="tab-keys" class="tab-content">
            <div class="card">
                <div class="card-title">➕ TẠO MÃ KEY BẢN QUYỀN MỚI</div>
                <div class="form-row">
                    <input type="text" id="new-user" placeholder="Tên khách hàng / Ghi chú" style="flex:2;">
                    <select id="new-role" style="flex:1;">
                        <option value="VIP">Cấp độ VIP (Toàn quyền)</option>
                        <option value="PRO">Cấp độ PRO</option>
                        <option value="DEV">Cấp độ DEVELOPER</option>
                    </select>
                    <input type="text" id="new-expires" value="Vĩnh viễn" placeholder="Thời hạn (vd: Vĩnh viễn, 30 ngày)" style="flex:1;">
                    <button onclick="createKey()" style="flex:0 0 auto;">Tạo Key Mới</button>
                </div>
            </div>

            <div class="card">
                <div class="card-title">
                    <span>📋 DANH SÁCH KEY ĐANG QUẢN LÝ</span>
                    <span id="keys-count" style="font-size:0.85rem; color:var(--text-dim);">0 Keys</span>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>MÃ KEY</th>
                            <th>NGƯỜI DÙNG</th>
                            <th>CẤP ĐỘ</th>
                            <th>HẠN DÙNG</th>
                            <th>TRẠNG THÁI</th>
                            <th>HÀNH ĐỘNG</th>
                        </tr>
                    </thead>
                    <tbody id="keys-tbody">
                        <tr><td colspan="6" style="text-align:center; color:#888;">Đang tải dữ liệu...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- TAB 2: LOGS CRASH & LỖI -->
        <div id="tab-logs" class="tab-content" style="display:none;">
            <div class="card">
                <div class="card-title">
                    <span>🚨 DANH SÁCH VỤ CRASH & LỖI (BÓC TÁCH THIẾT BỊ THẬT)</span>
                    <button class="btn-danger" onclick="clearAllLogs()" style="font-size:0.8rem; padding:6px 12px;">🗑️ Xóa Sạch Log</button>
                </div>
                <p style="font-size:0.85rem; color:var(--text-dim); margin-bottom:15px;">
                    Chỉ lưu lại khi có lỗi máy chủ (500) hoặc người dùng nhập sai/giả mạo key. Không lưu log thành công để bảo đảm máy chủ sạch sẽ.
                </p>
                <div id="logs-container">Đang tải danh sách log lỗi...</div>
            </div>
        </div>
    </div>

    <script>
        let currentPass = sessionStorage.getItem('txa_admin_token') || '';

        async function handleLogin(e) {
            e.preventDefault();
            const pass = document.getElementById('pass-input').value.trim();
            const err = document.getElementById('login-error');
            err.style.display = 'none';

            try {
                const res = await fetch('/api/admin?action=check_auth&pass=' + encodeURIComponent(pass));
                const data = await res.json();
                if (data.success) {
                    currentPass = pass;
                    sessionStorage.setItem('txa_admin_token', pass);
                    showDashboard();
                } else {
                    err.innerText = 'Mật khẩu không chính xác!';
                    err.style.display = 'block';
                }
            } catch(e) {
                err.innerText = 'Lỗi kết nối máy chủ!';
                err.style.display = 'block';
            }
        }

        function handleLogout() {
            sessionStorage.removeItem('txa_admin_token');
            currentPass = '';
            document.getElementById('dashboard-screen').style.display = 'none';
            document.getElementById('login-screen').style.display = 'flex';
            document.getElementById('pass-input').value = '';
        }

        function showDashboard() {
            document.getElementById('login-screen').style.display = 'none';
            document.getElementById('dashboard-screen').style.display = 'block';
            loadKeys();
            loadLogs();
        }

        function switchTab(t) {
            document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
            document.querySelectorAll('.tab-content').forEach(c => c.style.display = 'none');
            if (t === 'keys') {
                event.target.classList.add('active');
                document.getElementById('tab-keys').style.display = 'block';
                loadKeys();
            } else {
                event.target.classList.add('active');
                document.getElementById('tab-logs').style.display = 'block';
                loadLogs();
            }
        }

        async function loadKeys() {
            try {
                const res = await fetch('/api/admin?action=get_keys&pass=' + encodeURIComponent(currentPass));
                const list = await res.json();
                if(list.error) return handleLogout();
                
                document.getElementById('keys-count').innerText = list.length + ' Keys';
                const tbody = document.getElementById('keys-tbody');
                tbody.innerHTML = list.map(k => \`
                    <tr>
                        <td class="key-text">\${k.key}</td>
                        <td><strong>\${k.user}</strong></td>
                        <td><span class="badge" style="background:rgba(0,243,255,0.15); color:var(--cyan);">\${k.role}</span></td>
                        <td>\${k.expires}</td>
                        <td><span class="badge \${k.status === 'active' ? 'badge-active' : 'badge-blocked'}">\${k.status.toUpperCase()}</span></td>
                        <td>
                            <button onclick="toggleKey('\${k.key}')" style="padding:4px 10px; font-size:0.8rem; background:\${k.status === 'active' ? 'rgba(255,0,85,0.2)' : 'rgba(0,255,136,0.2)'}; color:\${k.status === 'active' ? 'var(--magenta)' : 'var(--green)'};">
                                \${k.status === 'active' ? 'Khóa Key' : 'Mở Khóa'}
                            </button>
                        </td>
                    </tr>
                \`).join('');
            } catch(e) {}
        }

        async function createKey() {
            const user = document.getElementById('new-user').value;
            const role = document.getElementById('new-role').value;
            const expires = document.getElementById('new-expires').value;
            const res = await fetch('/api/admin?action=create_key&pass=' + encodeURIComponent(currentPass), {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({ user, role, expires })
            });
            const data = await res.json();
            if(data.success) {
                alert('Tạo key thành công: ' + data.key.key);
                document.getElementById('new-user').value = '';
                loadKeys();
            }
        }

        async function toggleKey(targetKey) {
            await fetch('/api/admin?action=toggle_key&pass=' + encodeURIComponent(currentPass), {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({ targetKey })
            });
            loadKeys();
        }

        async function loadLogs() {
            try {
                const res = await fetch('/api/admin?action=get_logs&pass=' + encodeURIComponent(currentPass));
                const list = await res.json();
                const container = document.getElementById('logs-container');
                if(!list.length) {
                    container.innerHTML = '<div style="color:var(--green); padding:20px; text-align:center;">✨ Không có lỗi hoặc crash nào! Hệ thống đang hoạt động trơn tru.</div>';
                    return;
                }

                container.innerHTML = list.map(l => \`
                    <div class="log-item">
                        <div style="display:flex; justify-content:space-between; flex-wrap:wrap; gap:10px; margin-bottom:8px;">
                            <div>
                                <span class="badge" style="background:var(--magenta); color:#fff;">\${l.level}</span>
                                <strong style="color:#ff5577; margin-left:8px;">\${l.error.message}</strong>
                            </div>
                            <div style="font-size:0.8rem; color:var(--text-dim);">🕒 \${l.timestamp_vn}</div>
                        </div>

                        <div style="display:flex; gap:8px; flex-wrap:wrap; margin-bottom:10px;">
                            <div class="device-tag">📱 Máy: <strong>\${l.device.brand} \${l.device.model}</strong></div>
                            <div class="device-tag">🤖 Android: <strong>\${l.device.androidVersion}</strong></div>
                            <div class="device-tag">⚙️ Chip: <strong>\${l.device.architecture}</strong></div>
                            <div class="device-tag">🔋 Pin: <strong>\${l.device.battery}</strong></div>
                            <div class="device-tag">🌐 IP: <strong>\${l.client ? l.client.ip : 'N/A'}</strong></div>
                        </div>

                        \${l.client && l.client.payloadAttempted ? \`
                            <div style="font-size:0.85rem; color:var(--yellow); margin-bottom:6px;">
                                🔑 Dữ liệu gửi lên: <code>\${JSON.stringify(l.client.payloadAttempted)}</code>
                            </div>
                        \` : ''}

                        \${l.error.stack && l.error.stack.length ? \`
                            <div class="stack-box">\${l.error.stack.slice(0, 6).join('\\n')}</div>
                        \` : ''}
                    </div>
                \`).join('');
            } catch(e) {}
        }

        async function clearAllLogs() {
            if(!confirm('Bạn có chắc muốn xóa sạch toàn bộ log lỗi?')) return;
            await fetch('/api/admin?action=clear_logs&pass=' + encodeURIComponent(currentPass), { method: 'POST' });
            loadLogs();
        }

        function refreshAll() { loadKeys(); loadLogs(); }

        // Tự động mở Dashboard nếu đã đăng nhập từ trước
        if (currentPass) {
            fetch('/api/admin?action=check_auth&pass=' + encodeURIComponent(currentPass))
                .then(r => r.json())
                .then(d => { if(d.success) showDashboard(); else handleLogout(); })
                .catch(() => handleLogout());
        }
    </script>
</body>
</html>`;
}
