/**
 * Vercel Serverless Function: API Check Version (ESM)
 * Endpoint: https://api.txastudio.click/version.php hoặc /api/version
 */

import { logErrorOrCrash } from './logger.js';

export default function handler(req, res) {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        return res.status(204).end();
    }

    try {
        res.status(200).json({
            version: "3.0.0",
            update_url: "https://txavl.github.io/Men1/install.sh",
            changelog: {
                "v3.0.0": "Hệ thống máy chủ API Vercel độc lập, phân tách Cloudflare Tunnel và tối ưu hóa hệ thống ghi log lỗi chi tiết"
            },
            maintenance_mode: false,
            announcement: "Hệ thống xác thực bản quyền TXA Studio trên txastudio.click đã sẵn sàng"
        });
    } catch (crashErr) {
        logErrorOrCrash('CRASH_ENDPOINT_VERSION', crashErr, req);
        res.status(500).json({ error: "Internal Error" });
    }
}
