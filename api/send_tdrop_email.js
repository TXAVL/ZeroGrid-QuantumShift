/**
 * Vercel Serverless Function: Gửi Email Tự Động Bản Quyền T-Drop
 * Hỗ trợ Resend API, Brevo API, hoặc SMTP Relay
 */

export default async function handler(req, res) {
  // CORS Headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    return res.status(204).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' });
  }

  try {
    let body = req.body;
    if (typeof body === 'string') {
      try {
        body = JSON.parse(body);
      } catch (e) {}
    }

    const { email, orderCode, licenseKey, role, machineId } = body || {};

    if (!email || !licenseKey) {
      return res.status(400).json({ error: 'Email và License Key là bắt buộc' });
    }

    const durationDays = role === 'PREMIUM' ? 60 : 30;
    const cleanRole = role || 'VIP';

    // Nội dung Email HTML Chuẩn Cyberpunk TXA Studio
    const htmlContent = `
    <!DOCTYPE html>
    <html lang="vi">
    <head>
      <meta charset="UTF-8">
      <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #070b16; color: #e2e8f0; margin: 0; padding: 24px 12px; }
        .container { max-width: 580px; margin: 0 auto; background: #0c1224; border: 1px solid #1e293b; border-radius: 20px; overflow: hidden; box-shadow: 0 10px 40px rgba(0,0,0,0.5); }
        .header { background: linear-gradient(135deg, #090d24 0%, #171b3e 100%); padding: 32px 24px; text-align: center; border-bottom: 1px solid #1e293b; }
        .logo-title { font-size: 22px; font-weight: 900; color: #ffffff; letter-spacing: 1px; margin-top: 12px; }
        .sub-title { font-size: 12px; color: #38bdf8; text-transform: uppercase; letter-spacing: 2px; font-family: monospace; }
        .content { padding: 32px 24px; line-height: 1.6; font-size: 14px; }
        .greeting { font-size: 16px; font-weight: bold; color: #ffffff; margin-bottom: 12px; }
        .card { background: #070a14; border: 1px solid #1e293b; border-radius: 14px; padding: 18px; margin: 20px 0; }
        .key-badge { font-family: monospace; font-size: 20px; font-weight: bold; color: #34d399; background: rgba(16, 185, 129, 0.12); border: 1px dashed #10b981; padding: 12px; border-radius: 10px; text-align: center; letter-spacing: 1.5px; word-break: break-all; margin: 12px 0 6px 0; }
        .info-row { display: flex; justify-content: space-between; padding: 6px 0; font-size: 13px; border-bottom: 1px solid #131b2e; font-family: monospace; }
        .info-label { color: #64748b; }
        .info-value { color: #f1f5f9; font-weight: bold; }
        .steps { background: #0e1629; border-left: 3px solid #38bdf8; padding: 16px; border-radius: 0 12px 12px 0; margin: 20px 0; font-size: 13px; }
        .steps ol { margin: 0; padding-left: 18px; }
        .steps li { margin-bottom: 8px; color: #cbd5e1; }
        .footer { background: #080c18; padding: 20px; text-align: center; font-size: 12px; color: #64748b; border-top: 1px solid #131b2e; font-family: monospace; }
        .btn { display: inline-block; background: linear-gradient(135deg, #00f3ff, #6366f1); color: #070b16 !important; font-weight: 800; text-decoration: none; padding: 12px 28px; border-radius: 12px; font-size: 13px; text-transform: uppercase; letter-spacing: 1px; margin-top: 14px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <div style="font-size: 38px;">💧</div>
          <div class="sub-title">TXA STUDIO // SYSTEM LICENSE ISSUED</div>
          <div class="logo-title">KÍCH HOẠT BẢN QUYỀN T-DROP</div>
        </div>

        <div class="content">
          <div class="greeting">Xin chào bạn,</div>
          <p style="color: #94a3b8; margin: 0 0 16px 0;">
            Đơn hàng thanh toán VietQR của bạn đã được đối soát và phê duyệt thành công! TXA Studio xin gửi bạn mã kích hoạt bản quyền chính thức cho ứng dụng <strong>T-Drop (AI Clipboard & Smart OCR Desktop)</strong>.
          </p>

          <div class="card">
            <div style="font-size: 11px; color: #94a3b8; text-transform: uppercase; font-family: monospace; text-align: center;">MÃ BẢN QUYỀN CỦA BẠN (LICENSE KEY)</div>
            <div class="key-badge">${licenseKey}</div>
            
            <div style="margin-top: 14px;">
              <div class="info-row">
                <span class="info-label">Gói bản quyền:</span>
                <span class="info-value" style="color: #38bdf8;">${cleanRole} (${durationDays} Ngày)</span>
              </div>
              <div class="info-row">
                <span class="info-label">Mã đơn hàng:</span>
                <span class="info-value">${orderCode || 'VietQR'}</span>
              </div>
              <div class="info-row">
                <span class="info-label">Mã máy kích hoạt:</span>
                <span class="info-value" style="color: #f472b6;">${machineId || 'Thiết bị của bạn'}</span>
              </div>
            </div>
          </div>

          <div class="steps">
            <div style="font-weight: bold; color: #38bdf8; margin-bottom: 8px;">🚀 HƯỚNG DẪN KÍCH HOẠT NHANH (3 BƯỚC):</div>
            <ol>
              <li>Mở phần mềm <strong>T-Drop</strong> trên máy tính của bạn.</li>
              <li>Nhấp vào biểu tượng <strong>Cài Đặt (Settings)</strong> ➔ chọn mục <strong>Bản Quyền / License</strong>.</li>
              <li>Dán mã key <code style="color: #34d399; font-weight: bold;">${licenseKey}</code> vào ô nhập rồi bấm <strong>"Kích Hoạt"</strong>.</li>
            </ol>
          </div>

          <p style="font-size: 12px; color: #64748b; margin-top: 20px;">
            * Lưu ý: Mã key được gắn cố định với mã phần cứng thiết bị của bạn. Nếu cần chuyển đổi thiết bị hoặc gặp bất kỳ sự cố nào, bạn vui lòng liên hệ email hỗ trợ bên dưới để được hỗ trợ ưu tiên.
          </p>
        </div>

        <div class="footer">
          <div>TXA STUDIO • HIGH-PERFORMANCE GAMES & SOFTWARE</div>
          <div style="margin-top: 4px;">Website: <a href="https://txastudio.click" style="color: #38bdf8; text-decoration: none;">https://txastudio.click</a> | Hỗ trợ: <a href="mailto:txasoftdev@gmail.com" style="color: #38bdf8; text-decoration: none;">txasoftdev@gmail.com</a></div>
        </div>
      </div>
    </body>
    </html>
    `;

    // 1. Kiểm tra Resend API Key (Khuyên dùng)
    const RESEND_KEY = process.env.RESEND_API_KEY;
    if (RESEND_KEY) {
      const resendRes = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${RESEND_KEY}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          from: process.env.RESEND_FROM || 'TXA Studio <onboarding@resend.dev>',
          to: [email],
          subject: `[TXA Studio - T-Drop] Kích Hoạt Bản Quyền ${cleanRole} - Mã Key Của Bạn`,
          html: htmlContent
        })
      });

      const resendData = await resendRes.json();
      if (resendRes.ok) {
        return res.status(200).json({ success: true, provider: 'resend', id: resendData.id });
      } else {
        return res.status(500).json({ success: false, error: resendData.message || 'Resend error' });
      }
    }

    // 2. Kiểm tra Brevo API Key (Gửi SMTP REST)
    const BREVO_KEY = process.env.BREVO_API_KEY;
    if (BREVO_KEY) {
      const brevoRes = await fetch('https://api.brevo.com/v3/smtp/email', {
        method: 'POST',
        headers: {
          'api-key': BREVO_KEY,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          sender: { name: 'TXA Studio', email: process.env.BREVO_FROM || 'txasoftdev@gmail.com' },
          to: [{ email }],
          subject: `[TXA Studio - T-Drop] Kích Hoạt Bản Quyền ${cleanRole} - Mã Key Của Bạn`,
          htmlContent: htmlContent
        })
      });

      const brevoData = await brevoRes.json();
      if (brevoRes.ok) {
        return res.status(200).json({ success: true, provider: 'brevo', messageId: brevoData.messageId });
      } else {
        return res.status(500).json({ success: false, error: brevoData.message || 'Brevo error' });
      }
    }

    // Nếu chưa cấu hình Key môi trường trên Vercel:
    return res.status(200).json({
      success: false,
      not_configured: true,
      message: 'Chưa cấu hình RESEND_API_KEY hoặc BREVO_API_KEY trên Vercel Environment Variables. Vui lòng thêm RESEND_API_KEY vào Vercel Settings để gửi thư tự động 100% không cần mailto.'
    });

  } catch (err) {
    return res.status(500).json({ success: false, error: err.message });
  }
}
