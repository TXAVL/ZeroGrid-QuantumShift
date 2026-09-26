/**
 * Vercel Serverless Function: API Xác thực Key
 * Endpoint: https://api.txastudio.click/api/validate_key hoặc https://txastudio.click/api/validate_key
 */

const crypto = require('crypto');
const { logErrorOrCrash } = require('./logger');

const SALT = "TXA_STUDIO_CYBER_2026_CLICK";

const MASTER_KEYS = [
    "TXA-MASTER-STUDIO-CLICK-2026",
    "TXA-VIP-TXASTUDIO-CLICK",
    "TXA-DEV-PASS-2026"
];

function isValidKey(key) {
    if (!key) return false;
    key = key.trim();
    if (MASTER_KEYS.includes(key)) return true;

    const parts = key.split('-');
    if (parts.length !== 4) return false;

    const [prefix, tier, randId, checksum] = parts;
    if (prefix !== 'TXA') return false;

    const payload = `TXA-${tier}-${randId}`;
    const expectedChecksum = crypto.createHash('sha256')
        .update(`${payload}:${SALT}`)
        .digest('hex')
        .substring(0, 8)
        .toUpperCase();

    return checksum.toUpperCase() === expectedChecksum;
}

module.exports = async (req, res) => {
    // CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        return res.status(204).end();
    }

    try {
        let key = '';
        if (req.body) {
            key = req.body.key || '';
        }
        if (!key && req.query) {
            key = req.query.key || '';
        }
        key = String(key).trim();

        const action = (req.query && req.query.action) || '';

        // 1. Hành động lấy thông tin người dùng
        if (action === 'get_user_info') {
            if (isValidKey(key)) {
                // Thành công: KHÔNG ghi log để tránh rác
                return res.status(200).json({
                    status: "success",
                    user: "TXA Studio VIP Member",
                    domain: "txastudio.click",
                    expires: "Vĩnh viễn",
                    valid: true
                });
            } else {
                // Key không hợp lệ: GHI LOG LỖI CHI TIẾT
                logErrorOrCrash('AUTH_FAILURE', `Yêu cầu thông tin với key không hợp lệ: "${key}"`, req, { keyAttempted: key });
                return res.status(403).json({ status: "error", message: "Key không hợp lệ" });
            }
        }

        // 2. Xác thực Key
        if (isValidKey(key)) {
            // Thành công: Trả về 200, KHÔNG ghi log
            return res.status(200).json({
                valid: true,
                role: "VIP",
                domain: "txastudio.click",
                message: "Key hợp lệ trên máy chủ txastudio.click"
            });
        }

        // Trường hợp Key sai hoặc rỗng: Ghi log chi tiết
        logErrorOrCrash('INVALID_KEY_ATTEMPT', `Xác thực thất bại với key: "${key}"`, req, { keyAttempted: key });

        return res.status(200).json({
            valid: false,
            message: "Key không hợp lệ hoặc đã hết hạn trên hệ thống txastudio.click"
        });

    } catch (crashErr) {
        // Ghi log Crash chi tiết tối đa
        logErrorOrCrash('CRASH_ENDPOINT_VALIDATE_KEY', crashErr, req);
        return res.status(500).json({
            error: "Internal Server Error",
            message: crashErr.message
        });
    }
};
