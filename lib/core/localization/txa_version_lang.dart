import 'txa_language.dart';

/// Quản lý chuỗi đa ngôn ngữ (Tiếng Việt & English) cho Nhật Ký Cập Nhật Phiên Bản (TxaVersion)
/// Nội dung viết thân thiện, dễ hiểu, không dùng thuật ngữ kỹ thuật nâng cao để người dùng cuối dễ tiếp nhận.
class TxaVersionLang {
  static const Map<String, Map<String, String>> translations = {
    // =========================================================================
    // [VIETNAMESE] - Ngôn ngữ Tiếng Việt (vi)
    // =========================================================================
    'vi': {
      // -----------------------------------------------------------------------
      // [GENERAL] - Tiêu đề & Nút bấm chung của Modal
      // -----------------------------------------------------------------------
      'whats_new_title': 'CÓ GÌ MỚI Ở BẢN NÀY?',
      'whats_new_btn_continue': 'ĐÃ HIỂU & TIẾP TỤC',

      // -----------------------------------------------------------------------
      // [TXA_6] - Phiên bản v1.6.0 (Build 8) - Ngày: 2026-09-06
      // -----------------------------------------------------------------------
      'txa_6_title': 'Bản Nâng Cấp Dữ Liệu & Bảng Xếp Hạng 1.6.0',

      // [TXA_6_ITEM_1] - Dữ liệu game theo tài khoản
      'txa_6_item_1_title': 'Tiến Trình Chơi Đi Cùng Tài Khoản',
      'txa_6_item_1_desc': 'Tiến trình game, số màn đã vượt, số sao và điểm tích lũy nay gắn liền theo từng tài khoản riêng biệt. Khi đăng xuất hoặc chuyển đổi tài khoản, dữ liệu được chuyển đổi chính xác mà không lo bị lẫn lộn.',
      'txa_6_item_1_badge': 'ĐỘT PHÁ',

      // [TXA_6_ITEM_2] - Bảng xếp hạng 100% người chơi thực tế
      'txa_6_item_2_title': 'Bảng Xếp Hạng Người Chơi Thật',
      'txa_6_item_2_desc': 'Loại bỏ hoàn toàn người chơi ảo giả lập! Giờ đây toàn bộ thứ hạng trên Bảng Xếp Hạng Toàn Cầu và Bảng Đấu Tuần đều là những game thủ thật thi đấu và ghi điểm công bằng.',
      'txa_6_item_2_badge': 'CÔNG BẰNG',

      // [TXA_6_ITEM_3] - Đăng nhập Google khôi phục chuẩn xác
      'txa_6_item_3_title': 'Đăng Nhập Google Liền Mạch',
      'txa_6_item_3_desc': 'Hệ thống tự động nhận diện và khôi phục đúng tài khoản Google bạn đã từng chơi trước đây, đồng bộ ngay lập tức toàn bộ số sao và kỷ lục mà không tạo tài khoản trùng lặp.',
      'txa_6_item_3_badge': 'TIỆN LỢI',

      // [TXA_6_ITEM_4] - Đăng ký thông minh & Kiểm tra trực tiếp thời gian thực
      'txa_6_item_4_title': 'Đăng Ký Tài Khoản Trực Quan',
      'txa_6_item_4_desc': 'Giao diện đăng ký mới với viền màu báo hiệu trực tiếp thời gian thực: viền đỏ khi cần sửa, vàng khi đang kiểm tra tính khả dụng, và xanh neon khi sẵn sàng khởi tạo tài khoản an toàn.',
      'txa_6_item_4_badge': 'TRẢI NGHIỆM',

      // -----------------------------------------------------------------------
      // [TXA_5] - Phiên bản v1.5.0 (Build 7) - Ngày: 2026-09-06
      // -----------------------------------------------------------------------
      'txa_5_title': 'Bản Nâng Cấp Hệ Thống TXA Studio ID 1.5.0',

      // [TXA_5_ITEM_1] - Đăng nhập tài khoản TXA Studio ID
      'txa_5_item_1_title': 'Đăng Nhập TXA Studio ID Mới',
      'txa_5_item_1_desc': 'Dùng chung một tài khoản TXA Studio duy nhất để liên kết dữ liệu game. Đăng nhập tiện lợi, bảo mật qua trình duyệt chỉ với một chạm.',
      'txa_5_item_1_badge': 'MỚI CỰC ĐỈNH',

      // [TXA_5_ITEM_2] - Tự động quay lại ứng dụng khi cấp quyền
      'txa_5_item_2_title': 'Tự Động Mở Lại Game Siêu Tốc',
      'txa_5_item_2_desc': 'Sau khi xác nhận đăng nhập trên trình duyệt, ứng dụng sẽ tự động mở lại game ngay lập tức mà không cần bạn phải sao chép mã thủ công.',
      'txa_5_item_2_badge': 'TIỆN LỢI',

      // [TXA_5_ITEM_3] - Đa ngôn ngữ đồng bộ toàn diện
      'txa_5_item_3_title': 'Đa Ngôn Ngữ Đồng Bộ Toàn Diện',
      'txa_5_item_3_desc': 'Toàn bộ thông báo đăng nhập, hướng dẫn kết nối và trạng thái tài khoản đều hiển thị chuẩn xác theo ngôn ngữ Tiếng Việt hoặc Tiếng Anh bạn đã chọn.',
      'txa_5_item_3_badge': 'ĐA NGÔN NGỮ',

      // [TXA_5_ITEM_4] - Lưu trữ đám mây & Bảo vệ tài khoản
      'txa_5_item_4_title': 'Lưu Trữ Đám Mây An Toàn',
      'txa_5_item_4_desc': 'Hồ sơ và điểm kỷ lục của bạn được lưu an toàn trên máy chủ TXA Studio, an tâm tiếp tục màn chơi trên bất kỳ thiết bị nào.',
      'txa_5_item_4_badge': 'BẢO MẬT',

      // -----------------------------------------------------------------------
      // [TXA_4] - Phiên bản v1.4.0 (Build 6) - Ngày: 2026-09-05
      // -----------------------------------------------------------------------
      'txa_4_title': 'Bản Cập Nhật Điểm Số Real-Time 1.4.0',

      // [TXA_4_ITEM_1] - Điểm số nhảy tức thì Real-time
      'txa_4_item_1_title': 'Điểm Số Trực Tiếp Theo Từng Nước Đi',
      'txa_4_item_1_desc': 'Ô điểm số viền Neon nổi bật ngay tại trung tâm thanh thông số. Điểm thưởng combo và số ô 0 tạo ra được cộng dồn theo thời gian thực sau mỗi cú chạm thay vì phải đợi hết trận.',
      'txa_4_item_1_badge': 'MỚI CỰC ĐỈNH',

      // [TXA_4_ITEM_2] - Hoàn tác hoàn hảo khôi phục điểm
      'txa_4_item_2_title': 'Hoàn Tác (Undo) Khôi Phục Điểm Chuẩn Xác',
      'txa_4_item_2_desc': 'Tính năng Hoàn tác nay lưu vết và khôi phục chính xác cả điểm số và lượt đi còn lại về đúng trạng thái trước khi bạn bấm nước đi đó.',
      'txa_4_item_2_badge': 'NÂNG CẤP',

      // [TXA_4_ITEM_3] - Tối ưu giao diện HUD 3 cột cân đối
      'txa_4_item_3_title': 'Thanh Trạng Thái HUD Cân Đối & Thoáng Mắt',
      'txa_4_item_3_desc': 'Thiết kế lại HUD 3 cột cân xứng: Nước đi — Điểm số — Thời gian. Dời huy hiệu Combo xuống vị trí thông thoáng, giúp theo dõi trận đấu dễ dàng.',
      'txa_4_item_3_badge': 'GIAO DIỆN',

      // [TXA_4_ITEM_4] - Đồng bộ điểm số chiến thắng & 120 FPS
      'txa_4_item_4_title': 'Đồng Bộ Điểm Tuyệt Đối & 120 FPS',
      'txa_4_item_4_desc': 'Điểm số hiển thị trên popup chiến thắng khớp 100% với điểm số HUD khi kết thúc ván đấu. Tối ưu hiệu năng mượt mà chuẩn 120 khung hình/giây.',
      'txa_4_item_4_badge': 'MƯỢT HƠN',

      // -----------------------------------------------------------------------
      // [TXA_3] - Phiên bản v1.3.0 (Build 5) - Ngày: 2026-09-04
      // -----------------------------------------------------------------------
      'txa_3_title': 'Bản Cập Nhật Siêu Cấp 1.3.0',

      // [TXA_3_ITEM_1] - Gợi ý tìm đường ngắn nhất tuyệt đối
      'txa_3_item_1_title': 'Thuật Toán Gợi Ý Rút Ngắn Số Bước',
      'txa_3_item_1_desc': 'Hệ thống gợi ý được nâng cấp thuật toán BFS/IDA* tối ưu: tìm ra đường tắt ngắn nhất tuyệt đối từ thế cờ hiện tại, giúp bạn vượt màn với số bước ít hơn rõ rệt thay vì đi vòng vo.',
      'txa_3_item_1_badge': 'TỐI ƯU',

      // [TXA_3_ITEM_2] - Đại tu chế độ Endless Vượt Sóng
      'txa_3_item_2_title': 'Chế Độ Endless Vượt Sóng Sinh Tồn',
      'txa_3_item_2_desc': 'Đại tu chế độ Bất Tận: Vượt liên tục từng đợt sóng (Wave 1, 2, 3...) với ngân hàng lượt đi sinh tồn, tích lũy điểm kỷ lục không ngừng nghỉ và chuyển màn liền mạch siêu cuốn.',
      'txa_3_item_2_badge': 'MỚI CỰC ĐỈNH',

      // [TXA_3_ITEM_3] - Bàn cờ động & Preview gợi ý lan tỏa
      'txa_3_item_3_title': 'Bàn Cờ Sống Động & Preview Gợi Ý',
      'txa_3_item_3_desc': 'Hiệu ứng lan tỏa chữ thập khi chạm ô và xem trước phạm vi giảm số của các ô lân cận khi bật Gợi ý. Trải nghiệm giải đố trực quan và thỏa mãn giác quan hơn bao giờ hết.',
      'txa_3_item_3_badge': 'ĐỒ HỌA',

      // [TXA_3_ITEM_4] - HUD Endless chuyên biệt & Hồi sinh
      'txa_3_item_4_title': 'Giao Diện HUD Endless & Hồi Sinh',
      'txa_3_item_4_desc': 'HUD chuyên biệt hiển thị số Wave rực rỡ, thanh năng lượng lượt đi và điểm kỷ lục. Hỗ trợ xem video hồi sinh tiếp sức khi cạn lượt để kéo dài chuỗi kỷ lục của bạn.',
      'txa_3_item_4_badge': 'TÍNH NĂNG',

      // -----------------------------------------------------------------------
      // [TXA_2] - Phiên bản v1.2.1 (Build 4) - Ngày: 2026-09-03
      // -----------------------------------------------------------------------
      'txa_2_title': 'Bản Cập Nhật Zero Grid 1.2.1',

      // [TXA_2_ITEM_1] - Khắc phục sự cố đóng ứng dụng
      'txa_2_item_1_title': 'Khắc Phục Sự Cố Đóng Ứng Dụng',
      'txa_2_item_1_desc': 'Sửa dứt điểm lỗi ứng dụng bị tự động đóng hoặc văng ra màn hình báo lỗi khi chuyển đổi giữa các màn hình, giúp trải nghiệm chơi game luôn mượt mà và ổn định.',
      'txa_2_item_1_badge': 'SỬA LỖI',

      // [TXA_2_ITEM_2] - Khôi phục giao dịch trực quan
      'txa_2_item_2_title': 'Khôi Phục Giao Dịch Rõ Ràng',
      'txa_2_item_2_desc': 'Cập nhật cửa sổ thông báo trực quan khi khôi phục gói đã mua. Bạn sẽ thấy ngay tiến trình kiểm tra và danh sách cụ thể các gói đã kích hoạt lại trên tài khoản của mình.',
      'txa_2_item_2_badge': 'CẢI TIẾN',

      // [TXA_2_ITEM_3] - Tối ưu quảng cáo không làm phiền
      'txa_2_item_3_title': 'Tối Ưu Hiển Thị Banner Quảng Cáo',
      'txa_2_item_3_desc': 'Nâng cấp hệ thống hiển thị quảng cáo biểu ngữ dưới chân màn hình, loại bỏ giật lag và đảm bảo không làm gián đoạn những màn giải đố đỉnh cao của bạn.',
      'txa_2_item_3_badge': 'MƯỢT HƠN',

      // [TXA_2_ITEM_4] - Báo lỗi & hỗ trợ thuận tiện
      'txa_2_item_4_title': 'Hỗ Trợ Báo Lỗi Thuận Tiện',
      'txa_2_item_4_desc': 'Tính năng sao chép thông tin sự cố kèm nhật ký hoạt động gần nhất chỉ với 1 chạm, giúp đội ngũ hỗ trợ nhanh chóng giải quyết vấn đề khi bạn cần trợ giúp.',
      'txa_2_item_4_badge': 'TIỆN ÍCH',

      // [TXA_2_ITEM_5] - Nâng cấp gợi ý thông minh tối ưu
      'txa_2_item_5_title': 'Gợi Ý Nước Đi Tuyệt Đối Tối Ưu',
      'txa_2_item_5_desc': 'Hệ thống gợi ý được nâng cấp toàn diện: không bao giờ gợi ý lại ô vừa mới bấm, luôn chỉ ra nước đi ngắn nhất để bạn chắc chắn qua màn đạt 3 sao hoàn hảo mà không lo tốn bước thừa.',
      'txa_2_item_5_badge': 'TỐI ƯU',

      // -----------------------------------------------------------------------
      // [TXA_1] - Phiên bản v1.2.0 (Build 3) - Ngày: 2026-09-02
      // -----------------------------------------------------------------------
      'txa_1_title': 'Bản Phát Hành Zero Grid 1.2.0',

      // [TXA_1_ITEM_1] - Thuật toán IDA* tìm đường đi tối ưu
      'txa_1_item_1_title': 'Gợi Ý Nước Đi Thông Minh',
      'txa_1_item_1_desc': 'Hệ thống gợi ý thông minh luôn chỉ ra nước đi ngắn nhất dẫn tới chiến thắng, giúp bạn chinh phục mọi thử thách với số bước tối ưu.',
      'txa_1_item_1_badge': 'TỐI ƯU',

      // [TXA_1_ITEM_2] - Bảng xếp hạng không trùng lặp & đếm ngược 1s
      'txa_1_item_2_title': 'Bảng Xếp Hạng & Đua Top Trực Tiếp',
      'txa_1_item_2_desc': 'Hệ thống xếp hạng loại bỏ trùng lặp tài khoản, hiển thị hàng chục đối thủ so tài sôi nổi và đồng hồ đếm ngược mùa giải theo từng giây.',
      'txa_1_item_2_badge': 'MỚI',

      // [TXA_1_ITEM_3] - Thử thách ngày 3 chặng
      'txa_1_item_3_title': 'Thử Thách Hằng Ngày Nhiều Cấp Độ',
      'txa_1_item_3_desc': 'Lưu lại tiến trình làm nhiệm vụ hôm nay, bổ sung 3 chặng đố từ dễ đến khó và cho phép chơi lại nhiều lần để tự phá kỷ lục của bản thân.',
      'txa_1_item_3_badge': 'NÂNG CẤP',

      // [TXA_1_ITEM_4] - Đồng hồ HUD độc lập
      'txa_1_item_4_title': 'Đồng Hồ Đo Thời Gian Tiện Lợi',
      'txa_1_item_4_desc': 'Đồng hồ tính giờ thi đấu luôn hiển thị rõ ràng bên cạnh chuỗi combo, tự động chuyển định dạng giờ phút giây khi chơi lâu.',
      'txa_1_item_4_badge': 'GIAO DIỆN',

      // [TXA_1_ITEM_5] - Đăng xuất sạch phiên cho Google & thủ công
      'txa_1_item_5_title': 'Đăng Xuất Tài Khoản Nhanh Chóng',
      'txa_1_item_5_desc': 'Dễ dàng chuyển đổi tài khoản hoặc đăng xuất an toàn trên cả Google lẫn tài khoản tạo tay chỉ với một nút bấm.',
      'txa_1_item_5_badge': 'BẢO MẬT',

      // [TXA_1_ITEM_6] - Khôi phục giao dịch
      'txa_1_item_6_title': 'Bảo Vệ Quyền Lợi Mua Sắm',
      'txa_1_item_6_desc': 'Hỗ trợ khôi phục các gói đã mua bất cứ khi nào bạn đổi máy hoặc cài lại game mà không sợ bị mất dữ liệu.',
      'txa_1_item_6_badge': 'TIỆN ÍCH',
    },

    // =========================================================================
    // [ENGLISH] - English Language (en)
    // =========================================================================
    'en': {
      // -----------------------------------------------------------------------
      // [GENERAL] - General Modal Title & Action Button
      // -----------------------------------------------------------------------
      'whats_new_title': "WHAT'S NEW IN THIS VERSION?",
      'whats_new_btn_continue': 'GOT IT & CONTINUE',

      // -----------------------------------------------------------------------
      // [TXA_6] - Version v1.6.0 (Build 8) - Date: 2026-09-06
      // -----------------------------------------------------------------------
      'txa_6_title': 'Account Progress & Real Leaderboards 1.6.0',

      // [TXA_6_ITEM_1] - Account-Scoped Cloud Saves
      'txa_6_item_1_title': 'Account-Isolated Game Progress',
      'txa_6_item_1_desc': 'Your levels, stars, and records are now strictly tied to each individual account. Switching accounts automatically restores each player\'s own progress cleanly without overlap.',
      'txa_6_item_1_badge': 'BREAKTHROUGH',

      // [TXA_6_ITEM_2] - 100% Real Competitors
      'txa_6_item_2_title': '100% Real-Player Leaderboards',
      'txa_6_item_2_desc': 'All simulated bots have been removed! Every competitor you see on the Global and Weekly Tournament leaderboards is a real player competing honestly on the matrix.',
      'txa_6_item_2_badge': 'FAIR PLAY',

      // [TXA_6_ITEM_3] - Seamless Google Sign-In Restoration
      'txa_6_item_3_title': 'Seamless Google Account Recovery',
      'txa_6_item_3_desc': 'Google Sign-In now reliably detects and recovers your existing account profile and cloud saves with zero accidental duplicates or demo user names.',
      'txa_6_item_3_badge': 'SEAMLESS',

      // [TXA_6_ITEM_4] - Smart Registration with Real-Time Validation
      'txa_6_item_4_title': 'Smart & Reactive Registration',
      'txa_6_item_4_desc': 'Real-time responsive input borders and clear visual feedback: instant feedback on username availability, password strength, and account verification before submitting.',
      'txa_6_item_4_badge': 'POLISH',

      // -----------------------------------------------------------------------
      // [TXA_5] - Version v1.5.0 (Build 7) - Date: 2026-09-06
      // -----------------------------------------------------------------------
      'txa_5_title': 'TXA Studio ID Ecosystem Update 1.5.0',

      // [TXA_5_ITEM_1] - Brand new TXA Studio ID
      'txa_5_item_1_title': 'Brand-New TXA Studio ID Sign-In',
      'txa_5_item_1_desc': 'Use a single unified TXA Studio account to link all your game progress. Fast, secure web sign-in with just a single tap.',
      'txa_5_item_1_badge': 'BRAND NEW',

      // [TXA_5_ITEM_2] - Seamless Deep Link Return
      'txa_5_item_2_title': 'Instant Auto-Return to Game',
      'txa_5_item_2_desc': 'Once authorized in your browser, you are seamlessly brought straight back into the game without having to copy or paste any tokens manually.',
      'txa_5_item_2_badge': 'SEAMLESS',

      // [TXA_5_ITEM_3] - Fully Synced Multi-Language
      'txa_5_item_3_title': 'Comprehensive Bilingual Polish',
      'txa_5_item_3_desc': 'All authentication dialogues, status messages, and hints are fully localized in Vietnamese and English matching your in-game preference.',
      'txa_5_item_3_badge': 'LOCALIZED',

      // [TXA_5_ITEM_4] - Secure Cloud Profile & Sync
      'txa_5_item_4_title': 'Safe Cloud Sync & Security',
      'txa_5_item_4_desc': 'Your player data and high scores are securely preserved on the TXA Studio cloud, so you can safely play across different devices.',
      'txa_5_item_4_badge': 'SECURITY',

      // -----------------------------------------------------------------------
      // [TXA_4] - Version v1.4.0 (Build 6) - Date: 2026-09-05
      // -----------------------------------------------------------------------
      'txa_4_title': 'Zero Grid Real-Time Score Update 1.4.0',

      // [TXA_4_ITEM_1] - Live HUD Score Ticker
      'txa_4_item_1_title': 'Live Real-Time Score Tracking',
      'txa_4_item_1_desc': 'A vibrant Neon score display is now front-and-center on your match HUD. Points and combo bonuses update instantly on every move instead of waiting until the end.',
      'txa_4_item_1_badge': 'BRAND NEW',

      // [TXA_4_ITEM_2] - Full Undo Score Restoration
      'txa_4_item_2_title': 'Accurate Undo Score Restoration',
      'txa_4_item_2_desc': 'The Undo feature now tracks and restores your exact points and Endless move bank back to the precise state prior to the move.',
      'txa_4_item_2_badge': 'UPGRADE',

      // [TXA_4_ITEM_3] - Balanced 3-Column HUD
      'txa_4_item_3_title': 'Clean 3-Column Balanced HUD',
      'txa_4_item_3_desc': 'Redesigned top bar with balanced columns: Moves — Score — Time. Repositioned Combo badges for maximum visibility and clarity.',
      'txa_4_item_3_badge': 'UI',

      // [TXA_4_ITEM_4] - Flawless Win Sync & 120 FPS
      'txa_4_item_4_title': '100% Win Sync & 120 FPS Polish',
      'txa_4_item_4_desc': 'Score on the victory popup matches your live in-game HUD 100%. Ultra-smooth 120 FPS performance on high refresh rate displays.',
      'txa_4_item_4_badge': 'OPTIMIZED',

      // -----------------------------------------------------------------------
      // [TXA_3] - Version v1.3.0 (Build 5) - Date: 2026-09-04
      // -----------------------------------------------------------------------
      'txa_3_title': 'Zero Grid Major Update 1.3.0',

      // [TXA_3_ITEM_1] - Shortest-Path Optimal Hints
      'txa_3_item_1_title': 'Shortest-Path Hint Engine',
      'txa_3_item_1_desc': 'Upgraded hint engine with fast BFS/IDA* search: always discovers the absolute shortest winning sequence from the current board, drastically reducing required steps.',
      'txa_3_item_1_badge': 'OPTIMAL',

      // [TXA_3_ITEM_2] - Endless Wave Rush Overhaul
      'txa_3_item_2_title': 'Endless Wave Rush Survival',
      'txa_3_item_2_desc': 'Revamped Endless mode: non-stop wave progression (Wave 1, 2, 3...) with a reserve Move Bank, cumulative score rush, and seamless wave transitions.',
      'txa_3_item_2_badge': 'BRAND NEW',

      // [TXA_3_ITEM_3] - Dynamic Board & Hint Preview
      'txa_3_item_3_title': 'Dynamic Grid & Hint Previews',
      'txa_3_item_3_desc': 'Cross cascade ripple feedback on tap and intelligent neighbor preview when hints are active. Matrix puzzling feels punchier and more intuitive than ever.',
      'txa_3_item_3_badge': 'VISUALS',

      // [TXA_3_ITEM_4] - Dedicated Endless HUD & Revives
      'txa_3_item_4_title': 'Endless HUD & Run Revives',
      'txa_3_item_4_desc': 'Custom HUD displaying your active Wave, live score ticker, and move bank with low-move alerts. Includes optional Ad revive to keep high-score runs alive.',
      'txa_3_item_4_badge': 'FEATURE',

      // -----------------------------------------------------------------------
      // [TXA_2] - Version v1.2.1 (Build 4) - Date: 2026-09-03
      // -----------------------------------------------------------------------
      'txa_2_title': 'Zero Grid Update 1.2.1',

      // [TXA_2_ITEM_1] - App Stability & Crash Fix
      'txa_2_item_1_title': 'App Stability & Crash Fix',
      'txa_2_item_1_desc': 'Completely resolved an issue where the app could unexpectedly close or show an error screen when switching pages, keeping your puzzle sessions smooth and reliable.',
      'txa_2_item_1_badge': 'FIXED',

      // [TXA_2_ITEM_2] - Transparent Purchase Restore
      'txa_2_item_2_title': 'Clear Purchase Restoration',
      'txa_2_item_2_desc': 'Added a friendly status window when restoring your purchases. You can easily view checking progress and the exact items reactivated on your account.',
      'txa_2_item_2_badge': 'IMPROVED',

      // [TXA_2_ITEM_3] - Smoother Ad Performance
      'txa_2_item_3_title': 'Smoother Banner Ad Experience',
      'txa_2_item_3_desc': 'Upgraded bottom banner ads to eliminate lag and ensure gameplay remains responsive, light, and distraction-free at all times.',
      'txa_2_item_3_badge': 'OPTIMIZED',

      // [TXA_2_ITEM_4] - Easy Error Reporting
      'txa_2_item_4_title': 'Easy Support & Error Copying',
      'txa_2_item_4_desc': 'Copying error details now includes recent activity history with a single tap, allowing our team to assist and resolve any issues much faster.',
      'txa_2_item_4_badge': 'SUPPORT',

      // [TXA_2_ITEM_5] - Upgraded Smart Hints
      'txa_2_item_5_title': 'Guaranteed Optimal Hints',
      'txa_2_item_5_desc': 'Completely revamped hint system: never repeats recently tapped moves and always guides you through the shortest path for a guaranteed 3-star clear without wasted moves.',
      'txa_2_item_5_badge': 'SMART',

      // -----------------------------------------------------------------------
      // [TXA_1] - Version v1.2.0 (Build 3) - Date: 2026-09-02
      // -----------------------------------------------------------------------
      'txa_1_title': 'Zero Grid Release 1.2.0',

      // [TXA_1_ITEM_1] - Optimal IDA* Solver
      'txa_1_item_1_title': 'Smart Minimal Moves Hint',
      'txa_1_item_1_desc': 'Hints now calculate the absolute shortest path to victory, helping you solve puzzles with minimum moves.',
      'txa_1_item_1_badge': 'OPTIMAL',

      // [TXA_1_ITEM_2] - Deduplicated Leaderboards & Ticking Timer
      'txa_1_item_2_title': 'Live Leaderboards & Rival Pool',
      'txa_1_item_2_desc': 'Clean leaderboard without duplicate players, competing against dozens of rivals with real-time countdown clocks.',
      'txa_1_item_2_badge': 'NEW',

      // [TXA_1_ITEM_3] - Multi-stage Daily Challenge
      'txa_1_item_3_title': 'Daily Challenge Stages',
      'txa_1_item_3_desc': 'Saves daily mission progress, featuring 3 challenge stages from easy to master, replayable anytime to break your record.',
      'txa_1_item_3_badge': 'UPGRADE',

      // [TXA_1_ITEM_4] - Dual HUD & TxaFormat Timer
      'txa_1_item_4_title': 'Convenient Match Timer',
      'txa_1_item_4_desc': 'Always displays the game timer alongside your combo badge, automatically expanding to hours and minutes.',
      'txa_1_item_4_badge': 'UI',

      // [TXA_1_ITEM_5] - Clean Universal Logout
      'txa_1_item_5_title': 'Easy Account Logout',
      'txa_1_item_5_desc': 'Easily switch accounts or log out securely from Google or guest accounts with a single tap.',
      'txa_1_item_5_badge': 'AUTH',

      // [TXA_1_ITEM_6] - Restore Purchases & System Logs
      'txa_1_item_6_title': 'Purchase Protection',
      'txa_1_item_6_desc': 'Safely recover previously purchased passes whenever you change devices or reinstall the game.',
      'txa_1_item_6_badge': 'PURCHASE',
    },
  };

  /// Tra cứu bản dịch cho Changelog theo key và ngôn ngữ
  static String tr(String key, String langCode) {
    final effectiveLang = TxaLanguage.isVietnamese(langCode) ? 'vi' : 'en';
    final dict = translations[effectiveLang] ?? translations['en']!;
    return dict[key] ?? translations['en']![key] ?? key;
  }
}
