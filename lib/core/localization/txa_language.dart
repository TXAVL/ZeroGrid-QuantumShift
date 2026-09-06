import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/storage_service.dart';
import '../../services/service_providers.dart';

/// Lớp quản lý đa ngôn ngữ tập trung chuẩn TXA (TxaLanguage)
/// Toàn bộ chuỗi văn bản trong toàn bộ app được tập trung tại đây và gọi qua TxaLanguage.tr() hoặc TxaLanguage.instance.getText()
class TxaLanguage extends ChangeNotifier {
  static final TxaLanguage instance = TxaLanguage._internal();
  TxaLanguage._internal();

  static const List<({String code, String name, String flag})> supportedLanguages = [
    (code: 'system', name: 'Mặc định hệ thống', flag: '🌐'),
    (code: 'vi', name: 'Tiếng Việt', flag: '🇻🇳'),
    (code: 'en', name: 'English', flag: '🇺🇸'),
  ];

  String _currentLanguage = 'system';
  String get currentLanguage => _currentLanguage;

  void setLang(String code) {
    _currentLanguage = code;
    notifyListeners();
  }

  String getText(String key) {
    return tr(key, _currentLanguage);
  }

  static const Map<String, Map<String, String>> _translations = {
    'vi': {
      // Main Menu & General
      'app_title': 'ZERO GRID',
      'app_subtitle': 'QUANTUM SHIFT PUZZLE',
      'btn_start': 'BẮT ĐẦU CHƠI',
      'btn_start_subtitle': '100+ Sector & Thử thách UTC',
      'btn_how_to_play': 'HƯỚNG DẪN CÁCH CHƠI',
      'btn_how_to_play_sub': 'Quy tắc ma trận & cơ chế tính điểm',
      'btn_settings': 'CÀI ĐẶT TRÒ CHƠI',
      'btn_remove_ads': 'GỠ BỎ QUẢNG CÁO',
      'btn_ad_free_active': 'BẢN QUYỀN AD-FREE (PRO)',
      'btn_more_apps': 'CÁC GAME KHÁC (TXA STUDIO)',
      'more_apps_desc': 'Khám phá sản phẩm mới từ TXA Studio',
      'settings_subtitle': 'Ngôn ngữ, Âm thanh & Trợ năng',
      'remove_ads_desc': 'Xóa vĩnh viễn Banner & Interstitial',
      'ad_free_pro_desc': 'Đặc quyền Pro trọn đời',
      'ad_free_owned_msg': 'Bạn đã sở hữu phiên bản Không Quảng Cáo!',
      'sound_sfx': 'Âm thanh (SFX)',
      'sound_sfx_desc': 'Hiệu ứng âm thanh khi bấm ô & chiến thắng',
      'haptic_feedback': 'Rung phản hồi (Haptics)',
      'haptic_desc': 'Rung xúc giác mượt mà khi tương tác bàn cờ',
      'colorblind_mode': 'Chế độ mù màu (Colorblind Safe)',
      'colorblind_desc': 'Tối ưu độ tương phản cho người khiếm thị màu',
      'control_mode_label': 'Cơ chế điều khiển',
      'control_mode_tap': 'Chạm từng ô (Tap)',
      'control_mode_swipe': 'Vuốt lướt ngón tay (Swipe/Drag)',
      'control_mode_desc': 'Chọn phương thức tương tác lên bàn cờ',
      'swipe_unlocked_toast': '🎉 Đã mở khóa Cơ chế Vuốt lướt bàn cờ (Swipe Mode)!',
      'btn_language': 'Ngôn ngữ (Language)',
      'select_language': 'CHỌN NGÔN NGỮ',

      // Game Selection
      'select_game_title': 'CHỌN CHẾ ĐỘ CHƠI',
      'select_game_subtitle': 'Khám phá ma trận lượng tử phân rã số học',
      'mode_campaign_title': 'CHIẾN DỊCH',
      'mode_campaign_desc': '100+ Thử thách tuần tự tăng dần độ khó',
      'mode_daily_title': 'THỬ THÁCH NGÀY',
      'mode_daily_desc': 'Đề thi 4x4 UTC đồng bộ toàn cầu so tài mỗi ngày',
      'mode_endless_title': 'CHẾ ĐỘ BẤT TẬN',
      'mode_endless_desc': 'AI tự động thích ứng theo tỷ lệ thắng',
      'mode_async_title': 'ASYNC CHALLENGE',
      'mode_async_desc': 'So tài cùng bạn bè qua mã Seed bàn cờ',
      'mode_locked_need_level': 'Mở khóa sau Level %level%',
      'mode_locked_need_stars': 'Mở khóa sau %stars% sao',
      'level_locked': 'Màn chơi này đang bị khóa!',

      // Async Challenge Dialog
      'challenge_dialog_title': 'ASYNC CHALLENGE',
      'challenge_tab_enter': 'Nhập mã thách đấu',
      'challenge_tab_create': 'Tạo mã mới',
      'challenge_enter_desc': 'Nhập mã Challenge Code nhận được từ bạn bè:',
      'challenge_dialog_hint': 'Dán mã tại đây (Base64)...',
      'challenge_create_desc': 'Tùy chỉnh thông số bàn cờ để thách đấu bạn bè:',
      'challenge_grid_size': 'Kích cỡ bàn cờ:',
      'challenge_difficulty': 'Số bước xáo trộn:',
      'challenge_btn_generate': 'TẠO MÃ ĐỀ THI',
      'challenge_your_code': 'Mã thách đấu của bạn:',
      'challenge_btn_copy': 'Sao chép mã',
      'challenge_btn_share': 'Chia sẻ mã',
      'challenge_copied': 'Đã sao chép mã thách đấu vào clipboard!',
      'challenge_share_match_btn': 'Thách đấu ván này',
      'cancel': 'HỦY',
      'play_now': 'CHƠI NGAY',
      'invalid_code': 'Mã Challenge không hợp lệ!',

      // Settings Modal
      'settings_title': 'CÀI ĐẶT TRÒ CHƠI',
      'language_label': 'Ngôn ngữ (Language)',
      'sound_label': 'Âm thanh (SFX)',
      'haptic_label': 'Rung phản hồi (Haptics)',
      'colorblind_label': 'Chế độ mù màu (Colorblind Safe)',
      'restore_purchases': 'Khôi phục giao dịch',
      'restore_purchases_desc': 'Đồng bộ lại các gói đã mua trên Google Play',
      'restore_in_progress': 'Đang tiến hành khôi phục giao dịch từ Google Play...',
      'admin_dashboard_btn': 'BẢNG ĐIỀU KHIỂN ADMIN',
      'admin_dashboard_desc': 'Quản trị CSDL Supabase, Người chơi & Dev tools',
      'author_info': 'Phát triển bởi TXA Studio',

      // HUD & Game Controls
      'moves': 'NƯỚC ĐI',
      'time': 'THỜI GIAN',
      'score': 'ĐIỂM SỐ',
      'undo': 'Hoàn tác',
      'hint': 'Gợi ý',
      'reset': 'Chơi lại',
      'out_of_hints': 'Bạn đã hết gợi ý!',
      'get_free_hint': 'Xem video để nhận 1 gợi ý miễn phí',
      'watch_ad_btn': 'XEM QUẢNG CÁO',
      'no_ad_available': 'Hiện chưa có quảng cáo, vui lòng thử lại sau!',

      // Win Dialog
      'level_complete': 'HOÀN THÀNH VÁN ĐẤU',
      'total_score': 'Tổng điểm:',
      'moves_taken': 'Số bước:',
      'min_moves': 'Mục tiêu:',
      'play_duration': 'Thời gian:',
      'btn_next_level': 'MÀN TIẾP THEO',
      'btn_replay': 'CHƠI LẠI',
      'btn_menu': 'MENU CHÍNH',
      'btn_double_score': 'Nhân đôi điểm 2X',
      'btn_view_timelapse': 'Xem lại Replay ván đấu',

      // Leaderboard Screen
      'leaderboard_title': 'BẢNG XẾP HẠNG TOÀN CẦU',
      'tab_campaign': 'CHIẾN DỊCH',
      'tab_daily': 'THỬ THÁCH NGÀY',
      'tab_endless': 'BẤT TẬN',
      'rank_header': 'HẠNG',
      'player_header': 'NGƯỜI CHƠI',
      'score_header': 'ĐIỂM',
      'moves_header': 'BƯỚC',
      'time_header': 'THỜI GIAN',
      'no_leaderboard_data': 'Chưa có bản ghi xếp hạng nào.',
      'leaderboard_guest_banner': 'Bạn đang ở Chế độ Khách (Local). Đăng nhập để lưu tiến độ và leo Rank!',
      'leaderboard_require_login_title': 'YÊU CẦU ĐĂNG NHẬP',
      'leaderboard_require_login_desc': 'Bạn cần đăng nhập tài khoản Cloud hoặc Google để xem và tham gia Bảng xếp hạng toàn cầu!',
      'leaderboard_require_play_title': 'CHƯA ĐỦ ĐIỀU KIỆN XẾP HẠNG',
      'leaderboard_require_play_desc': 'Bạn cần hoàn thành tối thiểu 1 ván đấu để kích hoạt bảng xếp hạng và tính điểm phân hạng!',
      'leaderboard_you_badge': 'BẠN',
      'leaderboard_your_rank': 'HẠNG CỦA BẠN',
      'leaderboard_unranked_100': '100+',
      'leaderboard_top_1': 'QUÁN QUÂN',
      'leaderboard_top_2': 'Á QUÂN',
      'leaderboard_top_3': 'QUÝ QUÂN',
      'btn_play_first_game': 'CHƠI NGAY VÁN ĐẦU TIÊN',

      // Daily Challenge Screen
      'daily_screen_title': 'THỬ THÁCH NGÀY',
      'daily_challenge_title': 'THỬ THÁCH NGÀY',
      'daily_today_label': 'HÔM NAY',
      'daily_reset_in': 'Làm mới sau',
      'daily_reset_time_label': 'Giờ làm mới đề thi (Giờ máy của bạn)',
      'btn_start_daily': 'BẮT ĐẦU GIẢI ĐỀ THI',
      'daily_target': 'Mục tiêu: Đưa lưới 4x4 về 0 trong số bước tối ưu.',
      'daily_btn_play': 'BẮT ĐẦU GIẢI ĐỀ THI',
      'daily_already_solved': 'BẠN ĐÃ GIẢI THÀNH CÔNG HÔM NAY!',
      'daily_your_best': 'Kỷ lục hôm nay của bạn:',

      // Campaign Level Select
      'campaign_title': 'BẢN ĐỒ CHIẾN DỊCH',
      'sector_label': 'SECTOR',
      'level_locked_msg': 'Hãy vượt qua Sector trước để mở khóa màn này!',

      // Stats & Themes Screen
      'stats_title': 'THỐNG KÊ & THEMES',
      'stats_subtitle': 'Cửa hàng Themes & Chỉ số thực chiến',
      'stat_total_games': 'Tổng ván đã chơi',
      'stat_total_wins': 'Số trận thắng',
      'stat_win_rate': 'Tỷ lệ thắng',
      'stat_current_streak': 'Chuỗi thắng hiện tại',
      'stat_max_streak': 'Chuỗi thắng kỷ lục',
      'stat_total_stars': 'Tổng sao thu thập',
      'stat_endless_score': 'Kỷ lục Vô Tận',
      'stat_total_time': 'Tổng thời gian chơi',
      'themes_section': 'BỘ SƯU TẬP MÀU SẮC',
      'theme_active': 'ĐANG DÙNG',
      'theme_use': 'SỬ DỤNG',
      'theme_locked': 'CHƯA MỞ (PRO)',

      // Splash Screen
      'splash_sync_msg': 'Đang đồng bộ Google Play Games & Cloud...',
      'splash_ready_msg': 'Sẵn sàng!',
      'splash_offline_msg': 'Khởi tạo ma trận lượng tử...',

      // Account & Authentication
      'auth_title': 'HỒ SƠ & TÀI KHOẢN',
      'auth_guest_warning': 'Bạn đang ở chế độ Khách (Local). Tiến độ sẽ không lưu lên Cloud và không có trên Bảng xếp hạng. Đăng nhập ngay!',
      'btn_google_login': 'Đăng nhập bằng Google',
      'btn_guest_play': 'Tiếp tục chơi Local (Khách)',
      'btn_login': 'ĐĂNG NHẬP',
      'btn_register': 'ĐĂNG KÝ TÀI KHOẢN',
      'auth_username_hint': 'Tên tài khoản hoặc Tên hiển thị',
      'auth_password_hint': 'Mật khẩu',
      'auth_email_hint': 'Email (tùy chọn)',
      'device_attached': 'Thiết bị liên kết',
      'account_mode_guest': 'CHẾ ĐỘ KHÁCH (LOCAL)',
      'account_mode_cloud': 'ĐÃ LIÊN KẾT CLOUD',
      'btn_logout': 'Đăng xuất',
      'auth_fill_fields_warning': 'Vui lòng nhập đầy đủ tên và mật khẩu!',
      'auth_register_success': 'Đăng ký tài khoản thành công!',
      'auth_login_success': 'Đăng nhập thành công!',
      'auth_google_success': 'Đăng nhập Google thành công!',
      'auth_google_failed': 'Đăng nhập Google không thành công!',
      'auth_guest_toast': 'Tiếp tục ở Chế độ Khách (Local). Tiến độ sẽ không lưu lên Bảng xếp hạng!',
      'auth_sign_in_title': 'ĐĂNG NHẬP CLOUD',
      'auth_create_account_title': 'ĐĂNG KÝ TÀI KHOẢN',
      'auth_or_use_zero_grid': 'HOẶC DÙNG TÀI KHOẢN ZERO GRID',
      'auth_already_have_acc': 'Đã có tài khoản? Đăng nhập ngay',
      'auth_dont_have_acc': 'Chưa có tài khoản? Đăng ký ngay',

      // TXA Studio ID OAuth & Auth Service
      'oauth_btn_login': 'ĐĂNG NHẬP BẰNG TXA STUDIO ID',
      'oauth_portal_opened_notice': 'Đã mở cổng xác thực web (hiệu lực %time%)',
      'oauth_paste_code_hint': 'Dán mã txa_code_... vào đây',
      'oauth_btn_confirm_code': 'XÁC NHẬN MÃ ĐĂNG NHẬP',
      'oauth_toast_paste_prompt': 'Vui lòng dán mã txa_code_... từ trang web!',
      'oauth_toast_login_success': 'Đăng nhập TXA Studio ID thành công!',
      'oauth_toast_login_failed': 'Xác thực mã thất bại!',
      'oauth_err_invalid_format': 'Mã không đúng định dạng (phải bắt đầu bằng txa_code_)!',
      'oauth_err_invalid_or_expired': 'Mã ủy quyền không hợp lệ hoặc đã hết hạn!',
      'oauth_err_server_status': 'Lỗi máy chủ (%code%)!',
      'oauth_err_browser_launch': 'Không thể mở trình duyệt. Vui lòng mở thủ công https://txastudio.click',
      'profile_name_updated': 'Đã đổi tên thành công!',
      'profile_saved_locally': 'Đã lưu tên trên máy!',
      'profile_id_copied': 'Đã sao chép Player ID!',
      'profile_btn_link_account': 'ĐĂNG NHẬP / LIÊN KẾT TÀI KHOẢN',
      'profile_btn_save_name': 'LƯU TÊN HIỂN THỊ',
      'profile_switched_guest': 'Đã chuyển về Chế độ Khách!',
      'profile_leaderboard_name_label': 'TÊN HIỂN THỊ TRÊN LEADERBOARD',
      'profile_name_input_hint': 'Nhập tên của bạn...',
      'profile_stat_stars': 'Tổng Sao',
      'profile_stat_wins': 'Trận Thắng',
      'profile_stat_high_score': 'Kỷ Lục',

      // How to play dialog
      'how_to_play_title': 'HƯỚNG DẪN CÁCH CHƠI',
      'rule_1_title': 'Mục Tiêu Trò Chơi (Zero Grid)',
      'rule_1_desc': 'Biến đổi toàn bộ các ô số trên bàn cờ về số 0. Khi tất cả ô đều bằng 0, bạn chiến thắng!',
      'rule_2_title': 'Quy Tắc Lan Tỏa (Cross Cascade)',
      'rule_2_desc': 'Mỗi lần bạn chạm vào 1 ô, giá trị của ô đó và 4 ô xung quanh (trên, dưới, trái, phải) sẽ tăng thêm +1 theo chu kỳ Mod K (0 ➔ 1 ➔ 2 ➔ ... ➔ 0).',
      'rule_3_title': 'Xếp Hạng & Số Sao',
      'rule_3_desc': '★ 3 Sao: Hoàn thành bằng hoặc ít hơn số bước tối ưu.\n★ Combo: Đi liên tiếp các nước chuẩn xác để x2, x3 điểm số.\n★ Gợi ý (Hint): Sử dụng khi bạn bị kẹt thế cờ.',
      'rule_4_title': '4 Chế Độ Chơi Hấp Dẫn',
      'rule_4_desc': '• Chiến dịch: 100 màn thử thách tăng dần.\n• Thử thách ngày: Cập nhật thế cờ mới toàn cầu mỗi ngày.\n• Vô tận: Giải liên tục nâng cao chuỗi thắng.\n• Thách đấu bạn bè: Tạo và chia sẻ mã màn chơi.',
      'how_to_play_got_it': 'ĐÃ HIỂU - VÀO CHƠI NGAY',

      // Achievements & Milestones
      'achievements_title': 'DANH HIỆU & THÀNH TỰU',
      'ach_tab_all': 'TẤT CẢ',
      'ach_tab_campaign': 'CHIẾN DỊCH',
      'ach_tab_stars': 'SAO',
      'ach_tab_streak': 'CHUỖI THẮNG',
      'ach_tab_skill': 'KỸ NĂNG',
      'ach_tab_leaderboard': 'BẢNG XẾP HẠNG',
      'ach_unlocked_progress': 'Tiến độ hoàn thành: %unlocked% / %total% (%percent%%)',
      'btn_open_play_games': 'MỞ GOOGLE PLAY GAMES / GAME CENTER',

      // Campaign Milestones
      'ach_sector_1_title': 'Bước Chân Đầu Tiên',
      'ach_sector_1_desc': 'Vượt qua Sector 1 trong Chiến dịch',
      'ach_sector_10_title': 'Học Viên Ma Trận',
      'ach_sector_10_desc': 'Hoàn thành 10 Sector đầu tiên',
      'ach_sector_25_title': 'Người Dẫn Đường Lượng Tử',
      'ach_sector_25_desc': 'Vượt qua 25 Sector Chiến dịch',
      'ach_sector_50_title': 'Nhà Tiên Phong Lưới Số',
      'ach_sector_50_desc': 'Giải quyết thành công 50 Sector',
      'ach_sector_75_title': 'Kiến Trúc Sư Thuật Toán',
      'ach_sector_75_desc': 'Vượt qua 75 Sector đầy thử thách',
      'ach_sector_100_title': 'Huyền Thoại Zero Grid',
      'ach_sector_100_desc': 'Chinh phục toàn bộ 100 Sector Campaign',

      // Star Collection Milestones
      'ach_stars_10_title': 'Ngôi Sao Sơ Khởi',
      'ach_stars_10_desc': 'Thu thập 10 Ngôi Sao Chiến dịch',
      'ach_stars_50_title': 'Nhà Thám Hiểm Ánh Sao',
      'ach_stars_50_desc': 'Tích lũy 50 Ngôi Sao vàng',
      'ach_stars_100_title': 'Nhà Thu Thập Vũ Trụ',
      'ach_stars_100_desc': 'Tích lũy 100 Ngôi Sao vàng',
      'ach_stars_200_title': 'Thiên Tài Siêu Tân Tinh',
      'ach_stars_200_desc': 'Tích lũy 200 Ngôi Sao vàng',
      'ach_stars_300_title': 'Bậc Thầy Hoàn Hảo 300★',
      'ach_stars_300_desc': 'Thu thập trọn vẹn 300/300 Sao tuyệt đối',
      'ach_perfectionist_title': 'Bậc Thầy Nước Đi Tối Ưu',
      'ach_perfectionist_desc': 'Đạt 3 sao tại màn 20 trở lên với số bước tối thiểu',

      // Win Streak & Dedication Milestones
      'ach_streak_3_title': 'Đang Vào Phom',
      'ach_streak_3_desc': 'Đạt chuỗi 3 trận thắng liên tiếp',
      'ach_streak_5_title': 'Chuỗi Thắng Bất Bại',
      'ach_streak_5_desc': 'Đạt chuỗi 5 trận thắng liên tiếp',
      'ach_streak_10_title': 'Bất Khả Chiến Bại',
      'ach_streak_10_desc': 'Đạt chuỗi 10 trận thắng liên tiếp không sẩy chân',
      'ach_wins_10_title': 'Nhà Chiến Thuật Trẻ',
      'ach_wins_10_desc': 'Chiến thắng tổng cộng 10 ván chơi',
      'ach_wins_50_title': 'Kỳ Thủ Dày Dạn',
      'ach_wins_50_desc': 'Chiến thắng tổng cộng 50 ván chơi',
      'ach_wins_100_title': 'Huyền Thoại Bách Chiến',
      'ach_wins_100_desc': 'Chiến thắng tổng cộng 100 ván chơi',

      // Combo & Skill Milestones
      'ach_combo_3_title': 'Phản Ứng Dây Chuyền x3',
      'ach_combo_3_desc': 'Kích hoạt combo 3 số 0 cùng lúc',
      'ach_combo_5_title': 'Bão Lượng Tử x5',
      'ach_combo_5_desc': 'Kích hoạt combo 5 số 0 trong một nước đi',
      'ach_combo_8_title': 'Xuyên Thủng Không Gian x8',
      'ach_combo_8_desc': 'Kích hoạt siêu combo 8 số 0 cùng lúc',
      'ach_speed_demon_title': 'Tốc Biến 4x4',
      'ach_speed_demon_desc': 'Giải bàn 4x4 trong dưới 30 giây',
      'ach_no_hint_title': 'Trí Tuệ Thuần Khiết',
      'ach_no_hint_desc': 'Vượt qua màn 50+ mà không dùng bất kỳ gợi ý nào',

      // Endless & Daily Milestones
      'ach_endless_100_title': 'Vô Tận Lượng Tử 100',
      'ach_endless_100_desc': 'Đạt 100+ điểm trong Chế độ Bất Tận',
      'ach_endless_500_title': 'Du Hành Bất Tận 500',
      'ach_endless_500_desc': 'Đạt 500+ điểm trong Chế độ Bất Tận',
      'ach_endless_1000_title': 'Vị Thần Vô Tận 1000',
      'ach_endless_1000_desc': 'Đạt mốc kỷ lục 1.000+ điểm Chế độ Bất Tận',
      'ach_daily_1_title': 'Khởi Động Ngày Mới',
      'ach_daily_1_desc': 'Hoàn thành Thử thách ngày UTC đầu tiên',
      'ach_daily_3_title': 'Tập Trung Bền Bỉ',
      'ach_daily_3_desc': 'Vượt qua 3 màn Thử thách ngày',
      'ach_daily_7_title': 'Bậc Thầy Tuần Lượng Tử',
      'ach_daily_7_desc': 'Vượt qua 7 màn Thử thách ngày',

      // Leaderboard Milestones
      'ach_lb_submit_title': 'Ghi Danh Toàn Cầu',
      'ach_lb_submit_desc': 'Lần đầu tiên nộp điểm và có tên trên Bảng xếp hạng',
      'ach_lb_top100_title': 'Thợ Săn Top 100',
      'ach_lb_top100_desc': 'Lọt vào Top 100 Bảng xếp hạng toàn cầu',
      'ach_lb_top50_title': 'Kỳ Thủ Top 50',
      'ach_lb_top50_desc': 'Vươn tới Top 50 Bảng xếp hạng toàn cầu',
      'ach_lb_top10_title': 'Huyền Thoại Top 10',
      'ach_lb_top10_desc': 'Chạm tới Top 10 Bảng xếp hạng danh giá',
      'ach_lb_top1_title': 'Nhà Vô Địch Thế Giới #1',
      'ach_lb_top1_desc': 'Đạt ngôi vị Quán quân Top 1 Bảng xếp hạng toàn cầu',
      'ach_lb_daily_podium_title': 'Bục Vinh Quang Ngày (Top 3)',
      'ach_lb_daily_podium_desc': 'Lọt vào Top 3 Thử thách ngày UTC',
      'ach_lb_score_50k_title': 'Chiến Thần Tích Lũy 50K',
      'ach_lb_score_50k_desc': 'Tích lũy tổng cộng 50.000+ điểm số',

      // Weekly League Tournament Keys
      'tab_league': 'GIẢI ĐẤU',
      'league_division_title': 'GIẢI ĐẤU PHÂN HẠNG TUẦN (UTC)',
      'league_reset_timer': 'Reset 00h00 UTC Thứ 2 (%time%)',
      'league_login_required': 'Vui lòng Đăng nhập tài khoản để tham gia Bảng Đấu Tuần!',
      'league_play_1_required': 'Hãy hoàn thành ít nhất 1 ván trong tuần này để ghi danh vào Bảng Đấu!',
      'zone_promotion': 'VÙNG THĂNG HẠNG (TOP 1 - 4) 🚀',
      'zone_retention': 'VÙNG AN TOÀN / TRỤ HẠNG (TOP 5 - 14) 🛡️',
      'zone_demotion': 'VÙNG NGUY HIỂM / RỚT HẠNG (TOP 15 - 30) ⚠️',
      'tier_bronze': 'Đồng',
      'tier_silver': 'Bạc',
      'tier_gold': 'Vàng',
      'tier_platinum': 'Bạch Kim',
      'tier_diamond': 'Kim Cương',
      'tier_master': 'Huyền Thoại',
      'tournament_promoted_title': 'XUẤT SẮC! THĂNG HẠNG THÀNH CÔNG 🎉',
      'tournament_promoted_desc': 'Bạn xuất sắc cán đích ở vị trí #%rank% tuần trước và đã được thăng lên Bậc %tier%!',
      'tournament_retained_title': 'TRỤ HẠNG THÀNH CÔNG 😅',
      'tournament_retained_desc': 'Bạn cán đích ở vị trí #%rank%. Thoát hiểm an toàn và giữ nguyên Bậc %tier%!',
      'tournament_demoted_title': 'CẢNH BÁO: BỊ RỚT HẠNG 😭',
      'tournament_demoted_desc': 'Bạn rơi vào Vùng Nguy Hiểm (Hạng #%rank%) và đã bị tụt xuống Bậc %tier%!',
      'btn_continue_to_league': 'VÀO BẢNG ĐẤU TUẦN MỚI',
      'tournament_autoclose_timer': 'Tự động chuyển tiếp sau %seconds%s...',

      // Crash Screen Keys
      'crash_title': 'ỨNG DỤNG GẶP SỰ CỐ BẤT NGỜ',
      'crash_subtitle': 'Đã bắt ngoại lệ an toàn để tránh văng app. Bạn có thể sao chép nhật ký lỗi hoặc khởi động lại.',
      'crash_log_header': 'NHẬT KÝ LỖI (CRASH LOG)',
      'crash_restart_app': 'Khởi động lại ứng dụng',
      'crash_clear_cache': 'Xóa Cache & Khởi động lại',
      'crash_copy_log': 'Sao chép nhật ký lỗi',
      'crash_toast_cleared': 'Đã xóa toàn bộ bộ nhớ đệm ứng dụng!',
      'crash_toast_copied': 'Đã sao chép thông tin lỗi vào bộ nhớ tạm!',
      'crash_no_stacktrace': 'Không có StackTrace khả dụng',

      // TXALogger & Diagnostics Keys
      'system_logs_title': 'NHẬT KÝ HỆ THỐNG (LOGS)',
      'tab_all': 'TẤT CẢ',
      'tab_app': 'APP',
      'tab_api': 'API',
      'tab_crash': 'CRASH',
      'tab_services': 'SERVICES',
      'log_empty': 'Chưa có dữ liệu nhật ký cho mục này.',
      'log_sharing_prep': 'Đang chuẩn bị file nhật ký để chia sẻ...',
      'log_cleared': 'Đã xóa toàn bộ nhật ký hệ thống!',
      'log_copied': 'Đã sao chép dòng log và thông số máy!',
      'log_copy_failed': 'Sao chép thất bại: %error%',
      'log_details_label': 'CHI TIẾT DÒNG LOG:',
      'log_raw_label': 'RAW LOG LINE:',
      'diag_title': 'THÔNG SỐ CHẨN ĐOÁN THIẾT BỊ',
      'diag_log_type': 'Loại nhật ký',
      'diag_recorded_time': 'Thời gian ghi nhận',
      'diag_status': 'Trạng thái',
      'diag_device_hardware': 'PHẦN CỨNG & HỆ THỐNG',
      'diag_root_jb': 'Trạng thái Root/Jailbreak',
      'diag_root_warning': '⚠️ ĐÃ ROOT / JAILBREAK (Không an toàn)',
      'diag_root_safe': '✅ AN TOÀN (Nguyên bản)',
      'diag_screen': 'Màn hình',
      'diag_timezone': 'Múi giờ',
      'diag_locale': 'Ngôn ngữ máy',
      'diag_cpu_cores': 'Vi xử lý',
      'diag_battery': 'Mức pin',
      'diag_battery_charging': 'Đang sạc',
      'diag_battery_discharging': 'Không sạc',
      'diag_battery_na': 'N/A',
      'diag_platform_os': 'Hệ điều hành',
      'diag_device': 'Thiết bị / Model',
      'diag_brand': 'Thương hiệu',
      'diag_board_hw': 'Bo mạch / Phần cứng',
      'diag_build_id': 'Build ID',
      'diag_device_type': 'Loại máy',
      'diag_physical_device': 'Thiết bị thật',
      'diag_emulator': 'Máy ảo (Emulator)',
      'diag_ram': 'Bộ nhớ RAM',
      'diag_app_name': 'Tên ứng dụng',
      'diag_app_version': 'Phiên bản',
      'diag_build_code': 'Mã Build',
      'diag_full_version': 'Bản dựng đầy đủ',
      'diag_release_date': 'Ngày phát hành',
      'diag_collect_error': 'Lỗi thu thập thông số',

      // Banned Dialog
      'banned_dialog_title': 'TÀI KHOẢN BỊ KHÓA',
      'banned_dialog_desc': 'Tài khoản của bạn đã bị Quản trị viên khóa do phát hiện dấu hiệu gian lận hoặc vi phạm tiêu chuẩn cộng đồng.',
      'banned_username_label': 'Tên tài khoản',
      'banned_btn_logout': 'ĐĂNG XUẤT TÀI KHOẢN',
      'banned_logout_toast': 'Đã đăng xuất khỏi tài khoản bị khóa.',

      // Replay Viewer
      'replay_viewer_title': 'GHOST REPLAY',
      'replay_step_label': 'Bước',
      'replay_no_data': 'Chưa có dữ liệu Replay cho màn này!',

      // Skip Level & HUD
      'skip_level_title': 'BỎ QUA MÀN CHƠI',
      'skip_level_desc': 'Xem một đoạn quảng cáo ngắn để vượt qua màn chơi khó này?',
      'skip_level_tooltip': 'Xem Ad để bỏ qua màn này',
      'score_doubled_toast': '🎉 Đã nhân đôi điểm số thành công!',
      'stat_max_combo': 'Combo Tối Đa',

      // Mode Locked Toasts
      'mode_locked_daily_toast': 'Hoàn thành màn %level% để mở khóa Thử thách ngày!',
      'mode_locked_endless_toast': 'Hoàn thành màn %level% để mở khóa Chế độ Bất tận!',
      'mode_locked_async_toast': 'Hoàn thành màn %level% để mở khóa Async Challenge!',
      'challenge_steps_count': 'bước',

      // Daily Challenge
      'daily_reset_at': 'Làm mới lúc %time%',

      // Stats, Themes & IAP
      'theme_pro_locked_toast': 'Theme này nằm trong gói Pro Cyber Themes!',
      'iap_section_title': 'GÓI MUA IN-APP (IAP)',
      'iap_hints_10_title': '10 Gợi Ý Ma Trận (Hints)',
      'iap_hints_10_desc': 'Gói 10 gợi ý tối ưu thế cờ',
      'iap_pro_themes_title': 'Pro Cyber Themes',
      'iap_pro_themes_desc': 'Mở khóa toàn bộ 4 màu Neon Cyberpunk',
      'iap_owned': 'ĐÃ SỞ HỮU',

      // System Logs
      'system_logs_desc': 'Xem nhật ký hệ thống',
      'log_refresh_tooltip': 'Làm mới',
      'log_share_tooltip': 'Chia sẻ log',
      'log_clear_tooltip': 'Xóa toàn bộ log',

      // Admin Dashboard
      'admin_title': 'BẢNG ĐIỀU KHIỂN ADMIN',
      'admin_auth_title': 'XÁC THỰC QUẢN TRỊ VIÊN',
      'admin_pin_subtitle': 'Nhập mã PIN bí mật của TXA Studio để truy cập',
      'admin_unlock_btn': 'MỞ KHÓA ADMIN',
      'admin_tab_overview': 'TỔNG QUAN',
      'admin_tab_users': 'NGƯỜI CHƠI',
      'admin_tab_devtools': 'DEV TOOLS',
      'admin_pin_incorrect': 'Mã PIN Admin không chính xác!',
      'admin_user_detail_title': 'CHI TIẾT NGƯỜI CHƠI & MÁY',
      'admin_device_hardware_title': 'THÔNG TIN PHẦN CỨNG & HỆ THỐNG MÁY',
      'admin_no_device_data': 'Không có dữ liệu thiết bị chi tiết.',
      'admin_btn_unban': 'MỞ KHÓA TÀI KHOẢN NÀY (UNBAN)',
      'admin_btn_ban': 'KHÓA TÀI KHOẢN NÀY (BAN & XÓA RANK)',
      'admin_toast_unbanned': 'Đã mở khóa %name%',
      'admin_toast_banned': 'Đã cấm %name%',
      'admin_copied_toast': 'Đã sao chép %label%!',
      'admin_no_users': 'Chưa có người chơi nào.',
      'admin_growth_analytics': 'CHỈ SỐ TĂNG TRƯỞNG & ANALYTICS (DAU / MAU)',
      'admin_gameplay_stats': 'DỮ LIỆU GAMEPLAY & THỜI GIAN CHƠI THỰC TẾ',
      'admin_metric_dau': 'DAU (24H)',
      'admin_metric_wau': 'WAU (7 NGÀY)',
      'admin_metric_mau': 'MAU (30 NGÀY)',
      'admin_metric_total_users': 'TỔNG NGƯỜI CHƠI',
      'admin_metric_total_games': 'TỔNG SỐ VÁN',
      'admin_metric_daily_utc': 'LƯỢT DAILY UTC',
      'admin_metric_high_score': 'ĐIỂM CAO NHẤT',
      'admin_metric_total_hours': 'TỔNG GIỜ CHƠI',
      'admin_metric_avg_minutes': 'TB / NGƯỜI CHƠI',
      'admin_metric_total_accumulated': 'TỔNG THỜI GIAN TÍCH LŨY TOÀN BỘ MÁY',
      'admin_dev_tools_title': 'CÔNG CỤ TEST & GIAN LẬN DEVELOPER',
      'admin_tool_unlock_100_title': 'Mở Khóa Toàn Bộ 100 Màn Campaign',
      'admin_tool_unlock_100_desc': 'Cho phép nhảy thẳng vào bất kỳ màn nào từ 1 đến 100',
      'admin_tool_unlock_100_toast': 'Đã mở khóa toàn bộ 100 Level!',
      'admin_tool_hints_title': 'Tặng +50 Lượt Gợi Ý (Hints)',
      'admin_tool_hints_desc': 'Cộng thêm 50 Smart Hints vào tài khoản test',
      'admin_tool_hints_toast': 'Đã cộng +50 Gợi Ý!',
      'admin_tool_themes_title': 'Mở Khóa Toàn Bộ Cyber Themes',
      'admin_tool_themes_desc': 'Kích hoạt ngay trọn bộ 4 màu Neon Cyberpunk',
      'admin_tool_themes_toast': 'Đã mở khóa toàn bộ Cyber Themes!',
      'admin_tool_adfree_title': 'Kích Hoạt Chế Độ Không Quảng Cáo (Ad-Free)',
      'admin_tool_adfree_desc': 'Gỡ toàn bộ Banner & Interstitial Ads vĩnh viễn',
      'admin_tool_adfree_toast': 'Đã kích hoạt bản quyền Ad-Free!',
      'admin_tool_logger_title': 'Nhật Ký Hệ Thống (TXALogger)',
      'admin_tool_logger_desc': 'Xem, sao chép và chia sẻ file log chẩn đoán toàn diện',
      'admin_tool_reset_title': 'Reset Toàn Bộ Tiến Trình Test',
      'admin_tool_reset_desc': 'Đưa Campaign về Level 1 và xóa sạch sao tích lũy',
      'admin_tool_reset_toast': 'Đã reset tiến trình Campaign về Level 1!',
      'admin_btn_execute': 'THỰC HIỆN',

      // Endless Wave Mode
      'endless_wave_badge': 'SÓNG',
      'endless_best': 'Kỷ lục',
      'endless_moves_left': 'LƯỢT ĐI',
      'endless_game_over_title': 'CẠN LƯỢT ĐI!',
      'endless_new_record_badge': 'KỶ LỤC MỚI!',
      'endless_final_score': 'Tổng điểm đạt được',
      'endless_wave_reached': 'Vượt qua',
      'endless_revive_btn': 'Hồi sinh (+5 lượt) [Xem Ad]',
      'endless_revived_toast': 'Đã hồi sinh thành công! Tiếp tục vượt sóng!',
      'endless_play_again': 'CHƠI VÁN MỚI',
      'home': 'Trang chủ',

      // Time relative
      'time_just_now': 'Vừa xong',
      'time_mins_ago': 'phút trước',
      'time_hours_ago': 'giờ trước',
      'time_days_ago': 'ngày trước',
    },
    'en': {
      // Main Menu & General
      'app_title': 'ZERO GRID',
      'app_subtitle': 'QUANTUM SHIFT PUZZLE',
      'btn_start': 'START GAME',
      'btn_start_subtitle': '100+ Sectors & UTC Challenge',
      'btn_how_to_play': 'HOW TO PLAY GUIDE',
      'btn_how_to_play_sub': 'Grid rules & score mechanics',
      'btn_settings': 'GAME SETTINGS',
      'btn_remove_ads': 'REMOVE ADS',
      'btn_ad_free_active': 'AD-FREE ACTIVE (PRO)',
      'btn_more_apps': 'MORE APPS (TXA STUDIO)',
      'more_apps_desc': 'Discover new games by TXA Studio',
      'settings_subtitle': 'Language, Audio SFX & Accessibility',
      'remove_ads_desc': 'Permanently removes Banner & Interstitials',
      'ad_free_pro_desc': 'Lifetime Pro Status',
      'ad_free_owned_msg': 'You already own the Ad-Free version!',
      'sound_sfx': 'Sound Effects (SFX)',
      'sound_sfx_desc': 'Audio feedback on tap & stage completion',
      'haptic_feedback': 'Tactile Haptics',
      'haptic_desc': 'Smooth vibration feedback during matrix interactions',
      'colorblind_mode': 'Colorblind-Safe Mode',
      'colorblind_desc': 'Enhanced contrast palette for accessibility',
      'control_mode_label': 'Control Scheme',
      'control_mode_tap': 'Discrete Tap',
      'control_mode_swipe': 'Gesture Trace / Swipe',
      'control_mode_desc': 'Choose how you interact with the puzzle grid',
      'swipe_unlocked_toast': '🎉 Swipe / Gesture Trace control scheme unlocked!',
      'btn_language': 'Language',
      'select_language': 'SELECT LANGUAGE',

      // Game Selection
      'select_game_title': 'SELECT GAME MODE',
      'select_game_subtitle': 'Explore quantum matrix modulo arithmetic decay',
      'mode_campaign_title': 'CAMPAIGN SECTOR',
      'mode_campaign_desc': '100+ Progressive logical puzzle sectors',
      'mode_daily_title': 'DAILY CHALLENGE',
      'mode_daily_desc': 'Global synchronous UTC 4x4 puzzle competition',
      'mode_endless_title': 'ENDLESS QUANTUM',
      'mode_endless_desc': 'Adaptive AI adjusts difficulty dynamically',
      'mode_async_title': 'ASYNC CHALLENGE',
      'mode_async_desc': 'Battle friends via custom board Seed codes',
      'mode_locked_need_level': 'Unlocks after Level %level%',
      'mode_locked_need_stars': 'Unlocks after %stars% stars',
      'level_locked': 'This sector is locked!',

      // Async Challenge Dialog
      'challenge_dialog_title': 'ASYNC CHALLENGE',
      'challenge_tab_enter': 'Enter Code',
      'challenge_tab_create': 'Create Challenge',
      'challenge_enter_desc': 'Enter Challenge Code received from your friend:',
      'challenge_dialog_hint': 'Paste Base64 challenge code here...',
      'challenge_create_desc': 'Customize puzzle parameters to challenge friends:',
      'challenge_grid_size': 'Grid Dimension:',
      'challenge_difficulty': 'Scramble Steps:',
      'challenge_btn_generate': 'GENERATE CHALLENGE CODE',
      'challenge_your_code': 'Your Challenge Code:',
      'challenge_btn_copy': 'Copy Code',
      'challenge_btn_share': 'Share Code',
      'challenge_copied': 'Challenge code copied to clipboard!',
      'challenge_share_match_btn': 'Challenge This Match',
      'cancel': 'CANCEL',
      'play_now': 'PLAY NOW',
      'invalid_code': 'Invalid Challenge Code!',

      // Settings Modal
      'settings_title': 'GAME SETTINGS',
      'language_label': 'Language',
      'sound_label': 'Sound Effects (SFX)',
      'haptic_label': 'Tactile Haptics',
      'colorblind_label': 'Colorblind-Safe Mode',
      'restore_purchases': 'Restore Purchases',
      'restore_purchases_desc': 'Synchronize prior purchases from Google Play',
      'restore_in_progress': 'Restoring purchases from Google Play...',
      'admin_dashboard_btn': 'ADMIN DASHBOARD',
      'admin_dashboard_desc': 'Manage Supabase DB, Players & Dev Tools',
      'author_info': 'Developed by TXA Studio',

      // HUD & Game Controls
      'moves': 'MOVES',
      'time': 'TIME',
      'score': 'SCORE',
      'undo': 'Undo',
      'hint': 'Hint',
      'reset': 'Reset',
      'out_of_hints': 'You are out of hints!',
      'get_free_hint': 'Watch a quick video to get 1 free hint',
      'watch_ad_btn': 'WATCH AD',
      'no_ad_available': 'No ads available right now. Please try again later!',

      // Win Dialog
      'level_complete': 'QUANTUM SHIFT COMPLETE',
      'total_score': 'Total Score:',
      'moves_taken': 'Moves Taken:',
      'min_moves': 'Target:',
      'play_duration': 'Time:',
      'btn_next_level': 'NEXT SECTOR',
      'btn_replay': 'PLAY AGAIN',
      'btn_menu': 'MAIN MENU',
      'btn_double_score': 'Double Score 2X',
      'btn_view_timelapse': 'Watch Match Replay',

      // Leaderboard Screen
      'leaderboard_title': 'GLOBAL LEADERBOARDS',
      'tab_campaign': 'CAMPAIGN',
      'tab_daily': 'DAILY UTC',
      'tab_endless': 'ENDLESS',
      'rank_header': 'RANK',
      'player_header': 'PLAYER',
      'score_header': 'SCORE',
      'moves_header': 'MOVES',
      'time_header': 'TIME',
      'no_leaderboard_data': 'No leaderboard entries found yet.',
      'leaderboard_guest_banner': 'Guest mode: Sign in to sync progress and join Leaderboards!',
      'leaderboard_require_login_title': 'AUTHENTICATION REQUIRED',
      'leaderboard_require_login_desc': 'You must sign in with a Cloud or Google account to access and compete on Global Leaderboards!',
      'leaderboard_require_play_title': 'RANKING REQUIREMENT',
      'leaderboard_require_play_desc': 'You must complete at least 1 match to activate rankings and receive your placement!',
      'leaderboard_you_badge': 'YOU',
      'leaderboard_your_rank': 'YOUR RANK',
      'leaderboard_unranked_100': '100+',
      'leaderboard_top_1': 'CHAMPION',
      'leaderboard_top_2': 'RUNNER-UP',
      'leaderboard_top_3': '3RD PLACE',
      'btn_play_first_game': 'PLAY YOUR FIRST MATCH',

      // Daily Challenge Screen
      'daily_screen_title': 'DAILY CHALLENGE',
      'daily_challenge_title': 'DAILY CHALLENGE',
      'daily_today_label': 'TODAY',
      'daily_reset_in': 'Resets in',
      'daily_reset_time_label': 'Challenge Refresh Time (Your Local Time)',
      'btn_start_daily': 'START CHALLENGE',
      'daily_target': 'Objective: Clear 4x4 matrix to 0 in optimal moves.',
      'daily_btn_play': 'START CHALLENGE',
      'daily_already_solved': 'SOLVED SUCCESSFULLY TODAY!',
      'daily_your_best': 'Your Daily Record:',

      // Campaign Level Select
      'campaign_title': 'CAMPAIGN SECTORS',
      'sector_label': 'SECTOR',
      'level_locked_msg': 'Complete the previous Sector to unlock this stage!',

      // Stats & Themes Screen
      'stats_title': 'STATS & THEMES',
      'stats_subtitle': 'Themes Shop & Combat Stats',
      'stat_total_games': 'Total Games Played',
      'stat_total_wins': 'Total Victories',
      'stat_win_rate': 'Win Rate',
      'stat_current_streak': 'Current Win Streak',
      'stat_max_streak': 'Best Win Streak',
      'stat_total_stars': 'Total Stars Earned',
      'stat_endless_score': 'Endless High Score',
      'stat_total_time': 'Total Play Time',
      'themes_section': 'COLOR THEMES',
      'theme_active': 'ACTIVE',
      'theme_use': 'APPLY',
      'theme_locked': 'LOCKED (PRO)',

      // Splash Screen
      'splash_sync_msg': 'Syncing Google Play Games & Cloud...',
      'splash_ready_msg': 'Ready!',
      'splash_offline_msg': 'Initializing quantum matrix...',

      // Account & Authentication
      'auth_title': 'PROFILE & ACCOUNT',
      'auth_guest_warning': 'You are playing in Guest mode. Progress will not sync to Cloud and Leaderboards are disabled. Login now!',
      'btn_google_login': 'Sign in with Google',
      'btn_guest_play': 'Continue as Guest (Local)',
      'btn_login': 'SIGN IN',
      'btn_register': 'CREATE ACCOUNT',
      'auth_username_hint': 'Username or Display Name',
      'auth_password_hint': 'Password',
      'auth_email_hint': 'Email (optional)',
      'device_attached': 'Linked Device',
      'account_mode_guest': 'GUEST MODE (LOCAL)',
      'account_mode_cloud': 'CLOUD CONNECTED',
      'btn_logout': 'Sign Out',
      'auth_fill_fields_warning': 'Please enter username and password!',
      'auth_register_success': 'Account created successfully!',
      'auth_login_success': 'Signed in successfully!',
      'auth_google_success': 'Signed in with Google!',
      'auth_google_failed': 'Google sign-in cancelled or failed!',
      'auth_guest_toast': 'Continuing as Guest (Local). Leaderboard is disabled!',
      'auth_sign_in_title': 'SIGN IN',
      'auth_create_account_title': 'CREATE ACCOUNT',
      'auth_or_use_zero_grid': 'OR USE ZERO GRID ACCOUNT',
      'auth_already_have_acc': 'Already have an account? Sign In',
      'auth_dont_have_acc': "Don't have an account? Register",

      // TXA Studio ID OAuth & Auth Service
      'oauth_btn_login': 'SIGN IN WITH TXA STUDIO ID',
      'oauth_portal_opened_notice': 'Web auth portal opened (TTL: %time%)',
      'oauth_paste_code_hint': 'Paste txa_code_... here',
      'oauth_btn_confirm_code': 'CONFIRM AUTH CODE',
      'oauth_toast_paste_prompt': 'Please paste the txa_code_... from web portal!',
      'oauth_toast_login_success': 'Signed in with TXA Studio ID successfully!',
      'oauth_toast_login_failed': 'Auth code verification failed!',
      'oauth_err_invalid_format': 'Invalid code format (must start with txa_code_)!',
      'oauth_err_invalid_or_expired': 'Invalid or expired authorization code!',
      'oauth_err_server_status': 'Server error (%code%)!',
      'oauth_err_browser_launch': 'Could not launch browser. Please visit https://txastudio.click manually',
      'profile_name_updated': 'Username updated!',
      'profile_saved_locally': 'Saved locally!',
      'profile_id_copied': 'Player ID copied!',
      'profile_btn_link_account': 'SIGN IN / LINK ACCOUNT',
      'profile_btn_save_name': 'SAVE NAME',
      'profile_switched_guest': 'Switched to Guest mode!',
      'profile_leaderboard_name_label': 'LEADERBOARD DISPLAY NAME',
      'profile_name_input_hint': 'Enter your name...',
      'profile_stat_stars': 'Stars',
      'profile_stat_wins': 'Wins',
      'profile_stat_high_score': 'High Score',

      // How to play dialog
      'how_to_play_title': 'HOW TO PLAY',
      'rule_1_title': 'Objective: Zero Grid',
      'rule_1_desc': 'Transform all numbers on the grid into 0. When every cell becomes 0, you WIN!',
      'rule_2_title': 'Cross Cascade Ripple',
      'rule_2_desc': 'Tap any cell to increment its value and its 4 adjacent neighbors (Top, Bottom, Left, Right) by +1 modulo K (0 ➔ 1 ➔ 2 ➔ ... ➔ 0).',
      'rule_3_title': 'Stars & Scoring System',
      'rule_3_desc': '★ 3 Stars: Clear within or equal to optimal moves target.\n★ Combo: Chain optimal moves for x2, x3 score multipliers.\n★ Hint: Use when you are stuck to highlight the best move.',
      'rule_4_title': '4 Exciting Game Modes',
      'rule_4_desc': '• Campaign: 100 progressive puzzle sectors.\n• Daily UTC: Global daily challenge synced worldwide.\n• Endless: Consecutive stages to build streaks.\n• Async Challenge: Generate and share challenge codes.',
      'how_to_play_got_it': 'GOT IT - PLAY NOW',

      // Achievements & Milestones
      'achievements_title': 'TITLES & ACHIEVEMENTS',
      'ach_tab_all': 'ALL',
      'ach_tab_campaign': 'CAMPAIGN',
      'ach_tab_stars': 'STARS',
      'ach_tab_streak': 'STREAKS',
      'ach_tab_skill': 'SKILLS',
      'ach_tab_leaderboard': 'LEADERBOARD',
      'ach_unlocked_progress': 'Total Unlocked: %unlocked% / %total% (%percent%%)',
      'btn_open_play_games': 'OPEN PLAY GAMES / GAME CENTER',

      // Campaign Milestones
      'ach_sector_1_title': 'First Step',
      'ach_sector_1_desc': 'Complete Sector 1 in Campaign mode',
      'ach_sector_10_title': 'Matrix Apprentice',
      'ach_sector_10_desc': 'Clear the first 10 Campaign Sectors',
      'ach_sector_25_title': 'Quantum Pathfinder',
      'ach_sector_25_desc': 'Reach and conquer 25 Campaign Sectors',
      'ach_sector_50_title': 'Grid Pioneer',
      'ach_sector_50_desc': 'Successfully solve 50 Campaign Sectors',
      'ach_sector_75_title': 'Algorithm Architect',
      'ach_sector_75_desc': 'Conquer 75 challenging Campaign Sectors',
      'ach_sector_100_title': 'Zero Grid Legend',
      'ach_sector_100_desc': 'Conquer all 100 Campaign Sectors',

      // Star Collection Milestones
      'ach_stars_10_title': 'Novice Starlight',
      'ach_stars_10_desc': 'Collect 10 Campaign Gold Stars',
      'ach_stars_50_title': 'Starlight Explorer',
      'ach_stars_50_desc': 'Accumulate 50 Campaign Gold Stars',
      'ach_stars_100_title': 'Cosmic Collector',
      'ach_stars_100_desc': 'Accumulate 100 Campaign Gold Stars',
      'ach_stars_200_title': 'Supernova Prodigy',
      'ach_stars_200_desc': 'Accumulate 200 Campaign Gold Stars',
      'ach_stars_300_title': 'Perfect Grandmaster 300★',
      'ach_stars_300_desc': 'Collect all 300/300 perfect Stars',
      'ach_perfectionist_title': 'Optimal Move Virtuoso',
      'ach_perfectionist_desc': 'Achieve 3 stars on Sector 20+ with min moves',

      // Win Streak & Dedication Milestones
      'ach_streak_3_title': 'On Fire',
      'ach_streak_3_desc': 'Win 3 consecutive matches without failing',
      'ach_streak_5_title': 'Streak Master',
      'ach_streak_5_desc': 'Win 5 consecutive matches without failing',
      'ach_streak_10_title': 'Invincible Mind',
      'ach_streak_10_desc': 'Achieve an incredible 10-win streak',
      'ach_wins_10_title': 'Young Tactician',
      'ach_wins_10_desc': 'Win 10 matches across all game modes',
      'ach_wins_50_title': 'Veteran Solver',
      'ach_wins_50_desc': 'Win 50 matches across all game modes',
      'ach_wins_100_title': 'Legendary Centurion',
      'ach_wins_100_desc': 'Win 100 matches across all game modes',

      // Combo & Skill Milestones
      'ach_combo_3_title': 'Chain Reaction x3',
      'ach_combo_3_desc': 'Zero out 3 cells in a single move',
      'ach_combo_5_title': 'Quantum Storm x5',
      'ach_combo_5_desc': 'Zero out 5 cells in a single move',
      'ach_combo_8_title': 'Reality Warp x8',
      'ach_combo_8_desc': 'Zero out 8 cells simultaneously in one move',
      'ach_speed_demon_title': 'Speed Demon 4x4',
      'ach_speed_demon_desc': 'Solve a 4x4 matrix in under 30 seconds',
      'ach_no_hint_title': 'Pure Intellect',
      'ach_no_hint_desc': 'Clear Sector 50+ without using any hints',

      // Endless & Daily Milestones
      'ach_endless_100_title': 'Endless Century',
      'ach_endless_100_desc': 'Score 100+ points in Endless Quantum mode',
      'ach_endless_500_title': 'Quantum Voyager 500',
      'ach_endless_500_desc': 'Score 500+ points in Endless Quantum mode',
      'ach_endless_1000_title': 'Infinity God 1000',
      'ach_endless_1000_desc': 'Score 1,000+ points in Endless Quantum mode',
      'ach_daily_1_title': 'Daily Initiate',
      'ach_daily_1_desc': 'Complete your first Daily UTC Challenge',
      'ach_daily_3_title': 'Consistent Solver',
      'ach_daily_3_desc': 'Complete 3 Daily UTC Challenges',
      'ach_daily_7_title': 'Weekly Master',
      'ach_daily_7_desc': 'Complete 7 Daily UTC Challenges',

      // Leaderboard Milestones
      'ach_lb_submit_title': 'Global Contender',
      'ach_lb_submit_desc': 'First time submitting a score to the Global Leaderboard',
      'ach_lb_top100_title': 'Top 100 Hunter',
      'ach_lb_top100_desc': 'Reach Top 100 on the Global Leaderboard',
      'ach_lb_top50_title': 'Top 50 Elite',
      'ach_lb_top50_desc': 'Climb into the Top 50 Global Leaderboard',
      'ach_lb_top10_title': 'Top 10 Quantum Master',
      'ach_lb_top10_desc': 'Ascend into the Top 10 World Leaderboard',
      'ach_lb_top1_title': 'World Champion #1',
      'ach_lb_top1_desc': 'Claim the #1 Rank on the Global Leaderboard',
      'ach_lb_daily_podium_title': 'Daily Podium (Top 3)',
      'ach_lb_daily_podium_desc': 'Finish on the Top 3 Podium in the Daily UTC Challenge',
      'ach_lb_score_50k_title': 'Score Colossus 50K',
      'ach_lb_score_50k_desc': 'Accumulate 50,000+ total leaderboard score points',

      // Weekly League Tournament Keys
      'tab_league': 'LEAGUE',
      'league_division_title': 'WEEKLY DIVISION TOURNAMENT (UTC)',
      'league_reset_timer': 'Resets Monday 00:00 UTC (%time%)',
      'league_login_required': 'Please sign in to enter the Weekly League Tournament!',
      'league_play_1_required': 'Complete at least 1 match this week to enter the Tournament!',
      'zone_promotion': 'PROMOTION ZONE (TOP 1 - 4) 🚀',
      'zone_retention': 'SAFE / RETENTION ZONE (TOP 5 - 14) 🛡️',
      'zone_demotion': 'DEMOTION ZONE (TOP 15 - 30) ⚠️',
      'tier_bronze': 'Bronze',
      'tier_silver': 'Silver',
      'tier_gold': 'Gold',
      'tier_platinum': 'Platinum',
      'tier_diamond': 'Diamond',
      'tier_master': 'Quantum Master',
      'tournament_promoted_title': 'EXCELLENT! PROMOTED TO NEXT DIVISION 🎉',
      'tournament_promoted_desc': 'You finished at #%rank% last week and earned a promotion to %tier% Division!',
      'tournament_retained_title': 'SAFE! DIVISION RETAINED 😅',
      'tournament_retained_desc': 'You finished at #%rank%. Safe in the middle and retained %tier% Division!',
      'tournament_demoted_title': 'WARNING: DEMOTED TO LOWER DIVISION 😭',
      'tournament_demoted_desc': 'You fell into the Demotion Zone (Rank #%rank%) and dropped to %tier% Division!',
      'btn_continue_to_league': 'ENTER NEW TOURNAMENT',
      'tournament_autoclose_timer': 'Auto closing in %seconds%s...',

      // Crash Screen Keys
      'crash_title': 'UNEXPECTED APPLICATION ERROR',
      'crash_subtitle': 'An exception was captured safely to prevent OS termination. You can copy the diagnostic logs or restart.',
      'crash_log_header': 'CRASH DIAGNOSTIC LOG',
      'crash_restart_app': 'Restart Application',
      'crash_clear_cache': 'Clear Cache & Restart',
      'crash_copy_log': 'Copy Error Log',
      'crash_toast_cleared': 'All application caches cleared successfully!',
      'crash_toast_copied': 'Crash diagnostic details copied to clipboard!',
      'crash_no_stacktrace': 'No StackTrace Available',

      // TXALogger & Diagnostics Keys
      'system_logs_title': 'SYSTEM DIAGNOSTIC LOGS',
      'tab_all': 'ALL',
      'tab_app': 'APP',
      'tab_api': 'API',
      'tab_crash': 'CRASH',
      'tab_services': 'SERVICES',
      'log_empty': 'No logs recorded for this category yet.',
      'log_sharing_prep': 'Preparing log file for sharing...',
      'log_cleared': 'All local log files cleared successfully!',
      'log_copied': 'Log line and device header copied!',
      'log_copy_failed': 'Copy failed: %error%',
      'log_details_label': 'LOG MESSAGE DETAILS:',
      'log_raw_label': 'RAW LOG LINE:',
      'diag_title': 'HARDWARE DIAGNOSTIC SPECIFICATIONS',
      'diag_log_type': 'Log Type',
      'diag_recorded_time': 'Recorded Timestamp',
      'diag_status': 'Status',
      'diag_device_hardware': 'HARDWARE & SYSTEM SPECIFICATIONS',
      'diag_root_jb': 'Root / Jailbreak Status',
      'diag_root_warning': '⚠️ ROOTED / JAILBROKEN (Insecure)',
      'diag_root_safe': '✅ SECURE (Stock Firmware)',
      'diag_screen': 'Screen Resolution',
      'diag_timezone': 'Timezone',
      'diag_locale': 'System Locale',
      'diag_cpu_cores': 'CPU Processors',
      'diag_battery': 'Battery Level',
      'diag_battery_charging': 'Charging',
      'diag_battery_discharging': 'Discharging',
      'diag_battery_na': 'N/A',
      'diag_platform_os': 'Operating System',
      'diag_device': 'Device Model',
      'diag_brand': 'Brand',
      'diag_board_hw': 'Board / Hardware',
      'diag_build_id': 'Display Build ID',
      'diag_device_type': 'Device Type',
      'diag_physical_device': 'Physical Device',
      'diag_emulator': 'Virtual Emulator',
      'diag_ram': 'System RAM',
      'diag_app_name': 'Application Name',
      'diag_app_version': 'Version',
      'diag_build_code': 'Build Code',
      'diag_full_version': 'Full Build String',
      'diag_release_date': 'Release Date',
      'diag_collect_error': 'Diagnostic Collection Error',

      // Banned Dialog
      'banned_dialog_title': 'ACCOUNT SUSPENDED',
      'banned_dialog_desc': 'Your account has been suspended by the administrator due to fraudulent activity or policy violations.',
      'banned_username_label': 'Username',
      'banned_btn_logout': 'SIGN OUT ACCOUNT',
      'banned_logout_toast': 'Signed out of suspended account.',

      // Replay Viewer
      'replay_viewer_title': 'GHOST REPLAY',
      'replay_step_label': 'Step',
      'replay_no_data': 'No replay data available for this stage!',

      // Skip Level & HUD
      'skip_level_title': 'SKIP STAGE',
      'skip_level_desc': 'Watch a short video ad to skip this challenging stage?',
      'skip_level_tooltip': 'Watch Ad to skip this stage',
      'score_doubled_toast': '🎉 Score doubled successfully!',
      'stat_max_combo': 'Max Combo',

      // Mode Locked Toasts
      'mode_locked_daily_toast': 'Complete Sector %level% to unlock Daily Challenge!',
      'mode_locked_endless_toast': 'Complete Sector %level% to unlock Endless Mode!',
      'mode_locked_async_toast': 'Complete Sector %level% to unlock Async Challenge!',
      'challenge_steps_count': 'steps',

      // Daily Challenge
      'daily_reset_at': 'Resets at %time%',

      // Stats, Themes & IAP
      'theme_pro_locked_toast': 'This theme requires Pro Cyber Themes pack!',
      'iap_section_title': 'IN-APP PURCHASES',
      'iap_hints_10_title': '10 Smart Hints',
      'iap_hints_10_desc': 'Pack of 10 optimal matrix hints',
      'iap_pro_themes_title': 'Pro Cyber Themes',
      'iap_pro_themes_desc': 'Unlock all 4 Neon Cyberpunk palettes',
      'iap_owned': 'OWNED',

      // System Logs
      'system_logs_desc': 'View system logs',
      'log_refresh_tooltip': 'Refresh',
      'log_share_tooltip': 'Share log',
      'log_clear_tooltip': 'Clear all logs',

      // Admin Dashboard
      'admin_title': 'ADMIN CONTROL PANEL',
      'admin_auth_title': 'ADMIN AUTHENTICATION',
      'admin_pin_subtitle': 'Enter secret TXA Studio PIN to access',
      'admin_unlock_btn': 'UNLOCK ADMIN',
      'admin_tab_overview': 'OVERVIEW',
      'admin_tab_users': 'PLAYERS',
      'admin_tab_devtools': 'DEV TOOLS',
      'admin_pin_incorrect': 'Incorrect Admin PIN!',
      'admin_user_detail_title': 'PLAYER & DEVICE DETAILS',
      'admin_device_hardware_title': 'HARDWARE & SYSTEM SPECIFICATIONS',
      'admin_no_device_data': 'No detailed device data available.',
      'admin_btn_unban': 'UNBAN THIS ACCOUNT',
      'admin_btn_ban': 'BAN THIS ACCOUNT & REMOVE RANK',
      'admin_toast_unbanned': 'Unbanned %name%',
      'admin_toast_banned': 'Banned %name%',
      'admin_copied_toast': 'Copied %label%!',
      'admin_no_users': 'No players found.',
      'admin_growth_analytics': 'GROWTH METRICS & ANALYTICS (DAU / MAU)',
      'admin_gameplay_stats': 'GAMEPLAY STATS & ACTUAL PLAYTIME',
      'admin_metric_dau': 'DAU (24H)',
      'admin_metric_wau': 'WAU (7 DAYS)',
      'admin_metric_mau': 'MAU (30 DAYS)',
      'admin_metric_total_users': 'TOTAL PLAYERS',
      'admin_metric_total_games': 'TOTAL GAMES',
      'admin_metric_daily_utc': 'DAILY UTC PLAYS',
      'admin_metric_high_score': 'HIGH SCORE',
      'admin_metric_total_hours': 'TOTAL PLAY HOURS',
      'admin_metric_avg_minutes': 'AVG / PLAYER',
      'admin_metric_total_accumulated': 'TOTAL TIME ACCUMULATED ALL DEVICES',
      'admin_dev_tools_title': 'DEVELOPER TESTING & CHEAT TOOLS',
      'admin_tool_unlock_100_title': 'Unlock All 100 Campaign Sectors',
      'admin_tool_unlock_100_desc': 'Instantly access any sector from 1 to 100',
      'admin_tool_unlock_100_toast': 'Unlocked all 100 Levels!',
      'admin_tool_hints_title': 'Grant +50 Smart Hints',
      'admin_tool_hints_desc': 'Add 50 Smart Hints to test account',
      'admin_tool_hints_toast': 'Added +50 Hints!',
      'admin_tool_themes_title': 'Unlock All Cyber Themes',
      'admin_tool_themes_desc': 'Activate all 4 Neon Cyberpunk palettes',
      'admin_tool_themes_toast': 'Unlocked all Cyber Themes!',
      'admin_tool_adfree_title': 'Activate Ad-Free Lifetime Status',
      'admin_tool_adfree_desc': 'Permanently remove Banner & Interstitial Ads',
      'admin_tool_adfree_toast': 'Activated Ad-Free License!',
      'admin_tool_logger_title': 'System Diagnostic Logs (TXALogger)',
      'admin_tool_logger_desc': 'View, copy, and share full diagnostic logs',
      'admin_tool_reset_title': 'Reset All Test Progress',
      'admin_tool_reset_desc': 'Reset Campaign to Level 1 and wipe all stars',
      'admin_tool_reset_toast': 'Reset Campaign progress to Level 1!',
      'admin_btn_execute': 'EXECUTE',

      // Endless Wave Mode
      'endless_wave_badge': 'WAVE',
      'endless_best': 'Best',
      'endless_moves_left': 'MOVES',
      'endless_game_over_title': 'RUN TERMINATED!',
      'endless_new_record_badge': 'NEW RECORD!',
      'endless_final_score': 'Final Run Score',
      'endless_wave_reached': 'Waves Cleared',
      'endless_revive_btn': 'Revive (+5 moves) [Ad]',
      'endless_revived_toast': 'Successfully revived! Keep going!',
      'endless_play_again': 'PLAY AGAIN',
      'home': 'Home',

      // Time relative
      'time_just_now': 'Just now',
      'time_mins_ago': 'mins ago',
      'time_hours_ago': 'hours ago',
      'time_days_ago': 'days ago',
    },
  };

  /// Tra cứu bản dịch theo key và mã ngôn ngữ (Hỗ trợ fallback sang thiết bị)
  static String tr(String key, String langCode) {
    String effectiveLang = langCode;

    if (effectiveLang == 'system') {
      final deviceLocale = ui.PlatformDispatcher.instance.locale.languageCode.toLowerCase();
      effectiveLang = deviceLocale == 'vi' ? 'vi' : 'en';
    }

    if (effectiveLang != 'vi' && effectiveLang != 'en') {
      effectiveLang = 'en';
    }

    final langDict = _translations[effectiveLang] ?? _translations['en']!;
    return langDict[key] ?? _translations['en']![key] ?? key;
  }

  /// Tra cứu bản dịch kèm thay thế tham số định dạng
  static String trWithParams(String key, String langCode, [Map<String, String>? params]) {
    String text = tr(key, langCode);
    if (params != null) {
      params.forEach((k, v) {
        text = text.replaceAll('%$k%', v);
      });
    }
    return text;
  }

  static bool isVietnamese(String langCode) {
    if (langCode == 'vi') return true;
    if (langCode == 'system') {
      return ui.PlatformDispatcher.instance.locale.languageCode.toLowerCase() == 'vi';
    }
    return false;
  }

  static String getCurrentLanguageName(String langCode) {
    for (final lang in supportedLanguages) {
      if (lang.code == langCode) return lang.name;
    }
    return 'Mặc định';
  }
}

/// Quản lý trạng thái ngôn ngữ với Riverpod
class LanguageNotifier extends StateNotifier<String> {
  final StorageService _storage;

  LanguageNotifier(this._storage) : super(_storage.languageCode) {
    TxaLanguage.instance.setLang(_storage.languageCode);
  }

  void setLanguage(String code) {
    _storage.languageCode = code;
    TxaLanguage.instance.setLang(code);
    state = code;
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return LanguageNotifier(storage);
});
