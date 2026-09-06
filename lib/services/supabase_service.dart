import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/config/txa_config.dart';
import 'storage_service.dart';

/// Mô hình một dòng xếp hạng trong Leaderboard
class LeaderboardEntry {
  final int rank;
  final String userId;
  final String username;
  final int score;
  final int moves;
  final int durationSeconds;
  final int stars;
  final DateTime createdAt;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.score,
    required this.moves,
    required this.durationSeconds,
    required this.stars,
    required this.createdAt,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      userId: json['user_id'] as String? ?? '',
      username: json['username'] as String? ?? 'Quantum Player',
      score: (json['score'] as num?)?.toInt() ?? 0,
      moves: (json['moves'] as num?)?.toInt() ?? 0,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      stars: (json['stars'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// Dịch vụ kết nối trực tiếp Supabase Database & Real-time Ranking
class SupabaseService {
  final StorageService _storage;

  static const String supabaseUrl = TxaConfig.supabaseUrl;
  static final String supabaseAnonKey = TxaConfig.supabaseAnonKey;

  SupabaseService(this._storage);

  Map<String, String> get _headers => {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
      };

  String get userId => _storage.playerId;

  String get username => _storage.playerUsername;

  /// Đổi tên người chơi và đồng bộ lên Supabase
  Future<bool> updateUsername(String newName) async {
    _storage.playerUsername = newName;
    final url = Uri.parse('$supabaseUrl/rest/v1/zg_users?user_id=eq.$userId');
    try {
      final res = await http.patch(
        url,
        headers: _headers,
        body: jsonEncode({
          'username': newName,
          'last_active': DateTime.now().toUtc().toIso8601String(),
        }),
      );
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      debugPrint("Supabase updateUsername error: $e");
      return false;
    }
  }

  /// Kiểm tra xem Username đã tồn tại trên hệ thống chưa (phục vụ real-time validation)
  Future<bool> checkUsernameExists(String username) async {
    final clean = username.trim();
    if (clean.isEmpty) return false;
    final url = Uri.parse('$supabaseUrl/rest/v1/rpc/check_username_exists');
    try {
      final res = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({'p_username': clean}),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body) == true;
      }
    } catch (e) {
      debugPrint("Supabase checkUsernameExists error: $e");
    }
    return false;
  }

  /// Kiểm tra xem Email đã được đăng ký chưa (phục vụ real-time validation)
  Future<bool> checkEmailExists(String email) async {
    final clean = email.trim();
    if (clean.isEmpty) return false;
    final url = Uri.parse('$supabaseUrl/rest/v1/rpc/check_email_exists');
    try {
      final res = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({'p_email': clean}),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body) == true;
      }
    } catch (e) {
      debugPrint("Supabase checkEmailExists error: $e");
    }
    return false;
  }

  /// Đồng bộ toàn bộ tiến trình game (save_data) lên Supabase
  Future<bool> syncGameSave(Map<String, dynamic> saveData, {int? totalStars, int? endlessScore}) async {
    if (_storage.isGuestMode || userId.isEmpty) return false;
    final url = Uri.parse('$supabaseUrl/rest/v1/rpc/sync_game_save');
    try {
      final res = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'p_user_id': userId,
          'p_save_data': saveData,
          'p_total_stars': totalStars ?? _storage.totalCampaignStars,
          'p_endless_high_score': endlessScore ?? _storage.endlessHighScore,
        }),
      );
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      debugPrint("Supabase syncGameSave error: $e");
      return false;
    }
  }

  Future<bool> submitScore({
    required String mode,
    required String levelId,
    required int score,
    required int moves,
    required int durationSeconds,
    required int stars,
    required int comboMultiplier,
    String? seed,
    Map<String, dynamic>? ghostReplay,
    String? dateUtc,
  }) async {
    final url = Uri.parse('$supabaseUrl/rest/v1/rpc/submit_game_result');
    final body = jsonEncode({
      'p_user_id': userId,
      'p_username': username,
      'p_mode': mode,
      'p_level_id': levelId,
      'p_score': score,
      'p_moves': moves,
      'p_duration_seconds': durationSeconds,
      'p_stars': stars,
      'p_combo_multiplier': comboMultiplier,
      'p_seed': seed,
      'p_ghost_replay': ghostReplay,
      'p_date_utc': dateUtc,
    });

    try {
      final res = await http.post(url, headers: _headers, body: body);
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      debugPrint("Supabase submitScore error: $e");
      return false;
    }
  }

  /// Lấy danh sách xếp hạng Top theo chế độ (Tối đa 100 người)
  Future<List<LeaderboardEntry>> fetchLeaderboard(String mode, {int limit = 100}) async {
    final url = Uri.parse('$supabaseUrl/rest/v1/rpc/get_top_leaderboard');
    final body = jsonEncode({
      'p_mode': mode,
      'p_limit': limit,
    });

    try {
      final res = await http.post(url, headers: _headers, body: body);
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        final rawEntries = list.map((item) => LeaderboardEntry.fromJson(item)).toList();
        
        // Khử trùng lặp theo userId (giữ lại điểm cao nhất của mỗi user)
        final Map<String, LeaderboardEntry> uniqueUsers = {};
        for (final entry in rawEntries) {
          if (entry.userId.isEmpty) continue;
          if (!uniqueUsers.containsKey(entry.userId) || entry.score > uniqueUsers[entry.userId]!.score) {
            uniqueUsers[entry.userId] = entry;
          }
        }
        final sorted = uniqueUsers.values.toList()
          ..sort((a, b) => b.score.compareTo(a.score));
        return sorted;
      }
    } catch (e) {
      debugPrint("Supabase fetchLeaderboard error: $e");
    }
    return [];
  }

  /// Lấy danh sách xếp hạng Thử thách ngày (UTC) (Tối đa 100 người)
  Future<List<LeaderboardEntry>> fetchDailyLeaderboard(String dateUtc, {int limit = 100}) async {
    final url = Uri.parse('$supabaseUrl/rest/v1/rpc/get_daily_leaderboard');
    final body = jsonEncode({
      'p_date_utc': dateUtc,
      'p_limit': limit,
    });

    try {
      final res = await http.post(url, headers: _headers, body: body);
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        final rawEntries = list.map((item) => LeaderboardEntry.fromJson(item)).toList();
        
        // Khử trùng lặp theo userId
        final Map<String, LeaderboardEntry> uniqueUsers = {};
        for (final entry in rawEntries) {
          if (entry.userId.isEmpty) continue;
          if (!uniqueUsers.containsKey(entry.userId) || entry.score > uniqueUsers[entry.userId]!.score) {
            uniqueUsers[entry.userId] = entry;
          }
        }
        final sorted = uniqueUsers.values.toList()
          ..sort((a, b) => b.score.compareTo(a.score));
        return sorted;
      }
    } catch (e) {
      debugPrint("Supabase fetchDailyLeaderboard error: $e");
    }
    return [];
  }

  /// Nộp điểm tích lũy Giải Đấu Tuần (Weekly Tournament Division)
  Future<bool> submitWeeklyTournamentScore({
    required String weekKey,
    required int tier,
    required int score,
    required int gamesPlayed,
  }) async {
    final url = Uri.parse('$supabaseUrl/rest/v1/rpc/submit_weekly_tournament_score');
    final body = jsonEncode({
      'p_user_id': userId,
      'p_username': username,
      'p_week_key': weekKey,
      'p_tier': tier,
      'p_score': score,
      'p_games_played': gamesPlayed,
    });

    try {
      final res = await http.post(url, headers: _headers, body: body);
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      debugPrint("Supabase submitWeeklyTournamentScore error: $e");
      return false;
    }
  }

  /// Lấy danh sách Bảng Xếp Hạng Giải Đấu Tuần (Tối đa 30 người / Division Pool)
  Future<List<LeaderboardEntry>> fetchWeeklyTournamentLeaderboard({
    required String weekKey,
    required int tier,
    int limit = 30,
  }) async {
    final url = Uri.parse('$supabaseUrl/rest/v1/rpc/get_weekly_tournament_leaderboard');
    final body = jsonEncode({
      'p_week_key': weekKey,
      'p_tier': tier,
      'p_limit': limit,
    });

    try {
      final res = await http.post(url, headers: _headers, body: body);
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        if (list.isNotEmpty) {
          return list.map((item) => LeaderboardEntry.fromJson(item)).toList();
        }
      }
    } catch (e) {
      debugPrint("Supabase fetchWeeklyTournamentLeaderboard error: $e");
    }

    // Fallback: Tạo bảng giải đấu sinh động quanh điểm số của người chơi
    return [];
  }

  // ==========================================
  // ADMIN SYSTEM RPC APIS
  // ==========================================

  /// Lấy thống kê tổng quan hệ thống dành cho Admin
  Future<Map<String, dynamic>> getAdminDashboardStats() async {
    final url = Uri.parse('$supabaseUrl/rest/v1/rpc/get_admin_dashboard_stats');
    try {
      final res = await http.post(url, headers: _headers, body: '{}');
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint("Supabase getAdminDashboardStats error: $e");
    }
    return {
      'total_users': 0,
      'total_games': 0,
      'total_daily_entries': 0,
      'highest_score': 0,
      'total_play_time_seconds': 0,
    };
  }

  /// Lấy danh sách tất cả người chơi cho Admin
  Future<List<Map<String, dynamic>>> getAdminAllUsers({int limit = 100}) async {
    final url = Uri.parse('$supabaseUrl/rest/v1/zg_users?select=*&order=created_at.desc&limit=$limit');
    try {
      final res = await http.get(url, headers: _headers);
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(list);
      }
    } catch (e) {
      debugPrint("Supabase getAdminAllUsers error: $e");
    }
    return [];
  }

  /// Admin khóa hoặc mở khóa người chơi
  Future<bool> adminSetUserBan(String targetUserId, bool banned) async {
    final url = Uri.parse('$supabaseUrl/rest/v1/rpc/admin_set_user_ban');
    final body = jsonEncode({
      'p_user_id': targetUserId,
      'p_banned': banned,
    });
    try {
      final res = await http.post(url, headers: _headers, body: body);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint("Supabase adminSetUserBan error: $e");
      return false;
    }
  }

  /// Admin xóa lượt chơi bất thường
  Future<bool> adminDeleteLeaderboardEntry(int entryId) async {
    final url = Uri.parse('$supabaseUrl/rest/v1/rpc/admin_delete_leaderboard_entry');
    final body = jsonEncode({
      'p_entry_id': entryId,
    });
    try {
      final res = await http.post(url, headers: _headers, body: body);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint("Supabase adminDeleteLeaderboardEntry error: $e");
      return false;
    }
  }

  /// Kiểm tra xem tài khoản hiện tại có bị ban không
  Future<bool> checkUserBannedStatus(String uId) async {
    final url = Uri.parse('$supabaseUrl/rest/v1/zg_users?user_id=eq.$uId&select=is_banned');
    try {
      final res = await http.get(url, headers: _headers);
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        if (list.isNotEmpty) {
          return list.first['is_banned'] == true;
        }
      }
    } catch (e) {
      debugPrint("Supabase checkUserBannedStatus error: $e");
    }
    return false;
  }

  /// Lấy role và avatar mới nhất của user từ Supabase
  Future<Map<String, dynamic>?> fetchUserProfile(String uId) async {
    final url = Uri.parse('$supabaseUrl/rest/v1/zg_users?user_id=eq.$uId&select=role,avatar_url,username');
    try {
      final res = await http.get(url, headers: _headers);
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        if (list.isNotEmpty) {
          final data = list.first as Map<String, dynamic>;
          final role = data['role'] as String? ?? 'player';
          final avatar = data['avatar_url'] as String? ?? '';
          _storage.userRole = role;
          if (avatar.isNotEmpty) {
            _storage.avatarUrl = avatar;
          }
          return data;
        }
      }
    } catch (e) {
      debugPrint("Supabase fetchUserProfile error: $e");
    }
    return null;
  }
}
