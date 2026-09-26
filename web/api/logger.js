/**
 * ==============================================================================
 * TXA STUDIO HIGH-DETAIL ERROR & CRASH LOGGER FOR VERCEL
 * ==============================================================================
 * Bóc tách chi tiết thông tin thiết bị Termux Android thật:
 * - Hãng máy & Model (VD: Samsung Galaxy S23 Ultra, Xiaomi Redmi Note 12)
 * - Phiên bản Android, Kiến trúc chip CPU (aarch64), Kernel
 * - Mức % Pin thiết bị khi xảy ra sự cố
 * - IP thật, Headers, Stack trace, Payload
 * ==============================================================================
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

// Trên Vercel, thư mục có quyền ghi là /tmp
const LOG_FILE = process.env.VERCEL ? '/tmp/txa_crash_errors.json' : path.join(__dirname, '../logs/crash_errors.json');

try {
    const dir = path.dirname(LOG_FILE);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
} catch (e) {}

function getClientIp(req) {
    if (!req) return 'Unknown IP';
    const forwarded = req.headers['x-forwarded-for'];
    if (forwarded) return forwarded.split(',')[0].trim();
    return req.headers['cf-connecting-ip'] || 
           req.headers['x-real-ip'] || 
           req.connection?.remoteAddress || 
           req.socket?.remoteAddress || 
           '127.0.0.1';
}

function getVietnamTimeString() {
    return new Date().toLocaleString('vi-VN', { timeZone: 'Asia/Ho_Chi_Minh', hour12: false });
}

// Bóc tách thông số thiết bị Android gửi từ Termux qua Header hoặc Body
function extractDeviceInfo(req) {
    if (!req) return { model: 'N/A', brand: 'N/A', android: 'N/A', arch: 'N/A', battery: 'N/A' };
    
    // 1. Đọc từ Custom Headers
    const hModel = req.headers['x-device-model'];
    const hBrand = req.headers['x-device-brand'];
    const hAndroid = req.headers['x-device-android'];
    const hArch = req.headers['x-device-arch'];
    const hKernel = req.headers['x-device-kernel'];
    const hBattery = req.headers['x-device-battery'];

    // 2. Đọc từ Payload JSON nếu có
    const bDev = (req.body && typeof req.body === 'object' && req.body.device) ? req.body.device : {};

    return {
        brand: hBrand || bDev.brand || 'Android',
        model: hModel || bDev.model || req.headers['user-agent'] || 'Thiết bị Termux',
        androidVersion: hAndroid || bDev.android || 'Unknown',
        architecture: hArch || bDev.arch || 'arm64',
        kernel: hKernel || bDev.kernel || 'Unknown Kernel',
        battery: hBattery || bDev.battery || 'N/A'
    };
}

function loadLogList() {
    try {
        if (fs.existsSync(LOG_FILE)) {
            const raw = fs.readFileSync(LOG_FILE, 'utf8');
            return JSON.parse(raw);
        }
    } catch (e) {}
    return [];
}

function saveLogList(logs) {
    try {
        fs.writeFileSync(LOG_FILE, JSON.stringify(logs, null, 2), 'utf8');
    } catch (e) {}
}

/**
 * Ghi log chỉ khi là CRASH hoặc ERROR
 */
function logErrorOrCrash(type, err, req = null, extraData = {}) {
    const errorObj = typeof err === 'string' ? new Error(err) : err || new Error('Unknown Error');
    const vnTime = getVietnamTimeString();
    const isoTime = new Date().toISOString();
    const device = extractDeviceInfo(req);

    const logEntry = {
        id: 'ERR_' + Date.now() + '_' + Math.random().toString(36).substring(2, 6),
        level: type,
        timestamp_vn: vnTime,
        timestamp_iso: isoTime,
        device: {
            brand: device.brand,
            model: device.model,
            androidVersion: device.androidVersion,
            architecture: device.architecture,
            kernel: device.kernel,
            battery: device.battery
        },
        error: {
            name: errorObj.name || 'Error',
            message: errorObj.message,
            stack: errorObj.stack ? errorObj.stack.split('\n').map(s => s.trim()) : []
        },
        client: req ? {
            ip: getClientIp(req),
            method: req.method,
            url: req.url,
            payloadAttempted: req.body ? (typeof req.body === 'object' ? req.body : req.body.toString().slice(0, 500)) : null,
            headers: {
                host: req.headers['host'],
                userAgent: req.headers['user-agent']
            }
        } : null,
        environment: {
            platform: os.platform(),
            nodeVersion: process.version,
            memory: process.memoryUsage(),
            uptime: Math.floor(process.uptime()) + 's'
        },
        extra: extraData
    };

    // Xuất ra Vercel Runtime Console (Có màu đỏ cảnh báo)
    console.error(`\n🚨 [${type}] ${vnTime} - Thiết Bị: ${device.brand} ${device.model} (Android ${device.androidVersion}): ${errorObj.message}`);
    console.error(JSON.stringify(logEntry, null, 2));

    // Lưu vào file JSON trên server
    try {
        const logs = loadLogList();
        logs.unshift(logEntry);
        if (logs.length > 100) logs.pop(); // Giữ 100 log lỗi gần nhất
        saveLogList(logs);
    } catch (e) {}

    return logEntry;
}

function clearLogs() {
    try {
        saveLogList([]);
        return true;
    } catch (e) {
        return false;
    }
}

module.exports = {
    logErrorOrCrash,
    loadLogList,
    clearLogs,
    getClientIp,
    extractDeviceInfo
};
