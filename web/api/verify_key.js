/**
 * Vercel Serverless Function: API Verify Key (Dành cho install.sh)
 * Endpoint: https://api.txastudio.click/verify_key.php hoặc /api/verify_key
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
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');

    if (req.method === 'OPTIONS') {
        return res.status(204).end();
    }

    try {
        let key = (req.body && req.body.key) || (req.query && req.query.key) || '';
        key = String(key).trim();

        if (isValidKey(key)) {
            // Thành công: KHÔNG ghi log
            return res.status(200).send("Key is valid. Authorized by txastudio.click");
        }

        // Lỗi key không hợp lệ: Ghi log chi tiết
        logErrorOrCrash('INVALID_KEY_INSTALLER', `Xác thực installer thất bại với key: "${key}"`, req, { keyAttempted: key });
        return res.status(200).send("Key is invalid");

    } catch (crashErr) {
        logErrorOrCrash('CRASH_ENDPOINT_VERIFY_KEY', crashErr, req);
        return res.status(500).send("Internal Server Error: " + crashErr.message);
    }
};
