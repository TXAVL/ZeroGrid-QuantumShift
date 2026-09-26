/**
 * Vercel Serverless Function: Xem danh sách Crash & Error Logs trên Server
 * Endpoint: https://api.txastudio.click/api/logs?secret=TXA_SECRET_LOGS_2026
 */

const { readLogs } = require('./logger');

const ADMIN_SECRET = process.env.LOGS_SECRET || "TXA_SECRET_LOGS_2026";

module.exports = (req, res) => {
    res.setHeader('Access-Control-Allow-Origin', '*');

    const secret = req.query.secret || '';
    if (secret !== ADMIN_SECRET) {
        return res.status(403).json({
            error: "Forbidden",
            message: "Bạn cần cung cấp secret key để xem log lỗi máy chủ (?secret=...)"
        });
    }

    const logs = readLogs();
    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    res.status(200).send(logs);
};
