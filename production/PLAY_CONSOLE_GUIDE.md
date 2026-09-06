# 🎮 Google Play Console Listing & Keystore Signing Guide — Zero Grid: Quantum Shift

Tài liệu cấu hình chính thức, thông tin store listing hai ngôn ngữ (Việt - Anh) và **thông tin Keystore ký số đã được tạo sẵn** để xuất bản game **Zero Grid: Quantum Shift** lên **Google Play Console**.

---

## 🔑 1. Thông Tin Keystore Ký Số Đã Tạo Sẵn (Release Signing)

File Keystore ký số thật đã được tạo thành công trong dự án tại `android/app/zerogrid_upload_key.jks` và đã được liên kết tự động trong `android/app/build.gradle.kts` qua `android/key.properties`.

| Thuộc tính | Giá trị cấu hình |
| :--- | :--- |
| **Đường dẫn Keystore** | `android/app/zerogrid_upload_key.jks` |
| **Alias** | `zerogrid_key` |
| **Mật khẩu Keystore (Store Password)** | `23112006` |
| **Mật khẩu Key (Key Password)** | `23112006` |
| **Thời hạn chứng chỉ (Validity)** | 10.000 ngày (~27 năm, đến năm 2054) |
| **Mã vân tay SHA-1 (Dùng cho Play Games / Firebase)** | `22:07:3D:66:E5:A3:EF:0E:DA:22:0E:F9:10:E0:BC:BB:12:0E:D0:19` |
| **Mã vân tay SHA-256 (Dùng cho Play App Signing)** | `2F:DE:1C:0F:E1:C0:87:9C:D3:64:03:C5:98:29:11:91:78:EC:74:AC:86:AD:AC:01:44:82:45:CD:D0:5F:02:82` |

> [!TIP]
> Khi cần build file `.aab` có ký số hoàn chỉnh để up lên Store, bạn chỉ cần chạy lệnh:
> ```powershell
> flutter build appbundle --release
> ```
> File `.aab` xuất ra tại `build/app/outputs/bundle/release/app-release.aab` đã được ký số tự động!

---

## 📌 2. Thông Tin Cơ Bản (Store Listing Metadata)

| Trường thông tin | Tiếng Việt (Default) 🇻🇳 | English (US) 🇺🇸 |
| :--- | :--- | :--- |
| **Tên Ứng Dụng (App Title)** | `Zero Grid: Quantum Shift` (25/30 ký tự) | `Zero Grid: Quantum Shift` (25/30 ký tự) |
| **Mô tả ngắn (Short Description)** | `Puzzle giải đố Lights Out phân rã số học đỉnh cao. 100% có nghiệm, 120 FPS!` (77/80 ký tự) | `Minimalist math & Lights Out puzzle. Dynamic combos & 100% solvable levels!` (75/80 ký tự) |
| **Package Name (Application ID)** | `txa.zerogrid.quantumshift` | `txa.zerogrid.quantumshift` |
| **Loại ứng dụng (App Type)** | `Trò chơi` (Game) | `Game` |
| **Danh mục (Category)** | `Câu đố` (Puzzle) / `Trí tuệ` (Brain Games) | `Puzzle` / `Brain Games` |
| **Thẻ phân loại (Tags - Chọn 5 thẻ)** | `Câu đố`, `Toán học`, `Trí tuệ`, `Tối giản`, `Ngoại tuyến` | `Puzzle`, `Math`, `Brain`, `Minimalist`, `Offline` |

---

## 📝 3. Mô Tả Chi Tiết (Full Description)

### 🇻🇳 Tiếng Việt (Bản ngữ Store):
```markdown
🌌 ZERO GRID: QUANTUM SHIFT — NƠI TOÁN HỌC GIAO THOA CÙNG NGHỆ THUẬT PHÂN RÃ SỐ HỌC.

Bạn đã từng mê mẩn lối chơi cổ điển của Lights Out? Hãy sẵn sàng bước vào một kỷ nguyên giải đố hoàn toàn mới. Zero Grid: Quantum Shift nâng tầm thể loại puzzle tư duy bằng cơ chế ma trận phân rã số học modulo trên lưới không gian đa chiều.

Mục tiêu duy nhất của bạn: Chuyển toàn bộ bàn cờ về trạng thái năng lượng gốc "0" (Zero State) bằng số lượt di chuyển tối ưu nhất!

✨ CÁC TÍNH NĂNG ĐỘT PHÁ & KHÁC BIỆT:

🔢 1. CƠ CHẾ PHÂN RÃ SỐ HỌC MODULO (VON NEUMANN CASCADE)
- Mỗi cú chạm vào một ô sẽ làm giảm giá trị của chính nó và 4 ô lân cận (trên, dưới, trái, phải).
- Khi ô chạm mốc 0, nó sẽ phân rã và chuyển sang trạng thái tĩnh.
- 100% bàn cờ sinh ra được chứng minh toán học luôn tồn tại nghiệm tối ưu (Reverse Generation Algorithm).

⚡ 2. DYNAMIC COMBO & SCORING HẤP DẪN
- Kích hoạt chuỗi Combo bùng nổ khi đưa từ 2, 3 đến 5 ô về 0 cùng một lượt chạm!
- Hệ thống đánh giá 1-3 sao chuẩn xác dựa trên tỷ lệ số bước đi thực tế vs số bước tối thiểu.
- Thưởng điểm tốc độ (Time Bonus) dành cho những bộ óc phản xạ siêu tốc.

📼 3. GHOST REPLAY TIMELAPSE
- Lưu lại chuỗi nước đi hoàn hảo nhất của bạn.
- Phát lại toàn bộ ván đấu dưới dạng hoạt ảnh tua nhanh (timelapse) mượt mà để chiêm ngưỡng chiến thuật đỉnh cao của chính mình.

🧠 4. ADAPTIVE DIFFICULTY (ĐỘ KHÓ TỰ ĐỘNG THÍCH ỨNG)
- Chế độ Endless tự động phân tích tỷ lệ thắng và thời gian giải trung bình của bạn để cân chỉnh kích thước lưới (3x3, 4x4, 5x5) và số bước nghịch đảo M phù hợp nhất.

🌐 5. DAILY CHALLENGE & ASYNC SEED BATTLE
- Daily Challenge: Đề thi bàn cờ 4x4 đồng bộ theo giờ chuẩn quốc tế UTC. Toàn bộ người chơi trên thế giới giải cùng 1 đề để cạnh tranh công bằng trên Bảng xếp hạng Google Play & Supabase.
- Chia sẻ mã Seed ngắn để thách đố bạn bè xem ai giải ít bước hơn!

🎨 6. CYBERPUNK THEMES & CHẾ ĐỘ MÙ MÀU (ACCESSIBILITY)
- 4 bộ giao diện phát sáng neon cực chất: Cyber Neon, Magenta Shift, Monokai Dark và Quantum Gold.
- Hỗ trợ chế độ tương phản cao dành riêng cho người mù màu (Deuteranopia / Protanopia).
- Tùy chỉnh bật/tắt độc lập giữa hiệu ứng âm thanh SFX và phản hồi rung xúc giác (Haptics).

🚀 7. HIỆU NĂNG THUẦN NATIVE 120 FPS
- Xây dựng 100% bằng Flutter Native tối ưu hóa bộ nhớ (< 60MB RAM).
- Chơi mượt mà không giật lag ngay cả trên các dòng máy cấu hình thấp.
- Chơi offline hoàn toàn mọi lúc, mọi nơi!

Tải ngay Zero Grid: Quantum Shift và thử thách giới hạn tư duy của bạn!
```

### 🇺🇸 English (US Listing):
```markdown
🌌 ZERO GRID: QUANTUM SHIFT — WHERE MATHEMATICS MEETS THE ART OF LOGIC MATRIX DECAY.

Loved classic Lights Out puzzles? Prepare for a revolution! Zero Grid: Quantum Shift redefines brain puzzles with an arithmetic modulo decay cascade on an N×N quantum grid.

Your ultimate objective: Collapse every single cell to the quantum ground value "0" in the fewest moves possible!

✨ KEY FEATURES & GAMEPLAY HIGHLIGHTS:

🔢 1. MODULO DECAY MATRIX (VON NEUMANN CASCADE)
- Tapping a cell reduces its value and cascades to its 4 orthogonal neighbors.
- 100% solvable puzzles generated mathematically from the zero-state via Reverse Generation.

⚡ 2. DYNAMIC COMBO SYSTEM
- Trigger massive score multipliers when 2, 3, or 5 cells hit zero simultaneously!
- Accurate 1-3 star rating based on your move efficiency ratio.
- Speed bonus rewards rapid problem-solving reflexes.

📼 3. GHOST REPLAY TIMELAPSE
- Automatically records your best move sequences.
- Watch your optimal solution replay in an ultra-smooth visual timelapse.

🧠 4. ADAPTIVE DIFFICULTY ENGINE
- In Endless Mode, the engine dynamically adjusts board dimensions (3x3, 4x4, 5x5) and inverse complexity (M steps) based on your real-time win rate.

🌐 5. GLOBAL DAILY CHALLENGE & SEED SHARING
- Solve the universal UTC Daily Board and compete on global Google Play & Supabase Leaderboards.
- Generate and share custom Seed codes to challenge friends asynchronously.

🎨 6. CYBERPUNK NEON THEMES & ACCESSIBILITY
- 4 stunning futuristic palettes: Cyber Neon, Magenta Shift, Monokai Dark, and Zen Gold.
- Full Colorblind-Safe mode with high-contrast geometric palettes.
- Independent tactile Haptic feedback controls.

🚀 7. 60–120 FPS PURE NATIVE PERFORMANCE
- Ultra-lightweight memory footprint (< 60MB RAM).
- Fully playable offline without internet connection.

Download Zero Grid: Quantum Shift today and master the grid!
```

---

## 🎨 4. Danh Mục Graphic Assets Đã Tạo Sẵn (Google Play Specs)

Toàn bộ đồ họa chuẩn Store đã được render sẵn trong thư mục `google_play_assets/`:

| Tên File | Kích thước | Mục đích trong Google Play Console |
| :--- | :--- | :--- |
| `google_play_assets/icon-512x512.png` | `512 x 512 px` (PNG 32-bit) | **Biểu tượng ứng dụng (App Icon)** |
| `google_play_assets/feature-graphic-1024x500.png` | `1024 x 500 px` (PNG) | **Đồ họa tính năng (Feature Graphic)** |
| `google_play_assets/phone/phone_1_gameplay.png` | `1080 x 1920 px` | **Ảnh chụp màn hình điện thoại 1** (Core Gameplay & Math Logic) |
| `google_play_assets/phone/phone_2_combo.png` | `1080 x 1920 px` | **Ảnh chụp màn hình điện thoại 2** (Combo x5 & Star Rating) |
| `google_play_assets/phone/phone_3_modes.png` | `1080 x 1920 px` | **Ảnh chụp màn hình điện thoại 3** (Campaign 100+ & Daily UTC) |
| `google_play_assets/phone/phone_4_replay.png` | `1080 x 1920 px` | **Ảnh chụp màn hình điện thoại 4** (Ghost Replay Timelapse) |
| `google_play_assets/phone/phone_5_themes.png` | `1080 x 1920 px` | **Ảnh chụp màn hình điện thoại 5** (Cyber Themes & Colorblind Mode) |
| `google_play_assets/tablet_7in/*.png` | `1200 x 1920 px` | **Ảnh chụp màn hình Máy tính bảng 7 inch** |
| `google_play_assets/tablet_10in/*.png` | `1600 x 2560 px` | **Ảnh chụp màn hình Máy tính bảng 10 inch** |

---

## 💎 5. Cấu Hình In-App Purchases (IAP) Trên Play Console

Vào mục **Monetize** -> **In-app products** -> **Create product**:

| Product ID (Định nghĩa trong TxaConfig) | Tên sản phẩm | Loại sản phẩm | Giá đề xuất (VNĐ) | Giá đề xuất (USD) |
| :--- | :--- | :--- | :--- | :--- |
| `zero_grid_remove_ads` | Gỡ bỏ hoàn toàn quảng cáo | Không tiêu hao (Non-consumable) | `29.000 VNĐ` | `$0.99` |
| `zero_grid_hints_10` | Gói 10 Gợi ý thông minh | Tiêu hao (Consumable) | `15.000 VNĐ` | `$0.49` |
| `zero_grid_hints_50` | Gói 50 Gợi ý thông minh | Tiêu hao (Consumable) | `49.000 VNĐ` | `$1.99` |
| `zero_grid_pro_themes` | Mở khóa toàn bộ Themes Pro | Không tiêu hao (Non-consumable) | `29.000 VNĐ` | `$0.99` |

---

## 🏆 6. Cấu Hình Google Play Games Services (GPGS)

Vào mục **Play Games Services** -> **Setup and management**:

### 6.1 Bảng xếp hạng (Leaderboards):
1. **Global Campaign Stars**:
   - ID: `CgkI_sample_global_stars` (Thay bằng ID thật khi liên kết GPGS)
   - Tên: `Tổng sao Campaign`
   - Định dạng: `Số nguyên lớn hơn là tốt hơn` (Larger is better)
2. **Daily Challenge High Score**:
   - ID: `CgkI_sample_daily_challenge`
   - Tên: `Thử thách ngày UTC`
   - Định dạng: `Điểm số số nguyên` (Points)
3. **Endless Mode Record**:
   - ID: `CgkI_sample_endless_high_score`
   - Tên: `Kỷ lục Endless Mode`
   - Định dạng: `Điểm số số nguyên` (Points)

### 6.2 Thành tựu (Achievements):
1. `CgkI_sample_first_clear`: **Bước Chuyển Đầu Tiên** (Hoàn thành Level 1 Campaign) - 500 XP
2. `CgkI_sample_perfectionist_20`: **Bậc Thầy Hoàn Hảo** (Đạt 3 sao trong 20 level liên tiếp) - 1,500 XP
3. `CgkI_sample_speed_demon_4x4`: **Tia Chớp Lượng Tử** (Giải bàn 4x4 dưới 15 giây) - 2,000 XP
4. `CgkI_sample_combo_master_x5`: **Chuỗi Phân Rã Bùng Nổ** (Đạt Combo x5 trong 1 nước đi) - 2,500 XP
5. `CgkI_sample_endless_100`: **Chiến Binh Bất Tận** (Vượt qua 100 vòng Endless liên tiếp) - 5,000 XP
6. `CgkI_sample_no_hint_run`: **Tư Duy Thuần Khiết** (Hoàn thành 50 level Campaign không dùng gợi ý) - 3,000 XP

---

## 🔒 7. Khai Báo Nội Dung Ứng Dụng (App Content Declarations)

### 7.1 An toàn dữ liệu (Data Safety Questionnaire):
- **Thu thập dữ liệu:** `KHÔNG` thu thập dữ liệu cá nhân nhạy cảm (Không vị trí, không danh bạ, không ảnh riêng tư).
- **Chia sẻ bên thứ ba:**
  - `Google AdMob`: Chia sẻ Advertising ID (ID quảng cáo) để hiển thị banner/rewarded ads.
  - `Supabase & Play Games Services`: Lưu trữ điểm xếp hạng và thành tựu công khai.
- **Bảo mật:** Dữ liệu được mã hóa trong quá trình truyền tải (Encrypted in transit qua HTTPS/TLS).

### 7.2 Đánh giá nội dung IARC (Content Rating):
- Chọn danh mục: `Trò chơi (Game)`.
- Trả lời: `Không` cho bạo lực, tình dục, cờ bạc, ngôn từ kích động.
- Kết quả xếp hạng: **PEGI 3** / **Everyone** (Phù hợp mọi lứa tuổi).

### 7.3 Quảng cáo (Ads Declaration):
- Chọn: `Có, ứng dụng của tôi có chứa quảng cáo` (Yes, it contains ads - AdMob).
