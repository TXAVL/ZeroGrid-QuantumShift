-- =========================================================================
-- ZERO GRID: QUANTUM SHIFT - DATABASE SCHEMA & REAL-TIME RANKING SYSTEM
-- =========================================================================
-- Tác giả: TXA Studio
-- Mục đích: Lưu trữ toàn bộ dữ liệu người chơi, bảng xếp hạng Real-time, 
--           số bước di chuyển, và thời gian chơi (play duration) chi tiết.
-- =========================================================================

-- 1. BẢNG NGƯỜI CHƠI (zg_users)
CREATE TABLE IF NOT EXISTS public.zg_users (
    user_id TEXT PRIMARY KEY,
    username TEXT NOT NULL,
    display_name TEXT,
    avatar_url TEXT,
    device_id TEXT,
    platform TEXT DEFAULT 'android',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    last_active TIMESTAMPTZ DEFAULT NOW()
);

-- 2. BẢNG XẾP HẠNG TỔNG & CHI TIẾT LƯỢT CHƠI (zg_leaderboards)
CREATE TABLE IF NOT EXISTS public.zg_leaderboards (
    id BIGSERIAL PRIMARY KEY,
    user_id TEXT NOT NULL,
    username TEXT NOT NULL,
    mode TEXT NOT NULL, -- 'campaign', 'daily', 'endless', 'custom'
    level_id TEXT NOT NULL,
    score INT NOT NULL,
    moves INT NOT NULL,
    duration_seconds INT NOT NULL, -- Thời gian giải (giây)
    stars INT DEFAULT 0, -- 1 đến 3 sao
    combo_multiplier INT DEFAULT 1,
    seed TEXT,
    ghost_replay_data JSONB, -- Lưu chuỗi nước đi để xem lại replay
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. BẢNG XẾP HẠNG THỬ THÁCH NGÀY UTC (zg_daily_rankings)
CREATE TABLE IF NOT EXISTS public.zg_daily_rankings (
    id BIGSERIAL PRIMARY KEY,
    date_utc TEXT NOT NULL, -- Định dạng YYYY-MM-DD
    user_id TEXT NOT NULL,
    username TEXT NOT NULL,
    score INT NOT NULL,
    moves INT NOT NULL,
    duration_seconds INT NOT NULL, -- Thời gian giải chi tiết (giây)
    seed TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_user_daily UNIQUE (date_utc, user_id)
);

-- 4. BẢNG THỐNG KÊ TỔNG HỢP NGƯỜI CHƠI (zg_player_statistics)
CREATE TABLE IF NOT EXISTS public.zg_player_statistics (
    user_id TEXT PRIMARY KEY,
    username TEXT NOT NULL,
    total_games INT DEFAULT 0,
    total_wins INT DEFAULT 0,
    current_win_streak INT DEFAULT 0,
    max_win_streak INT DEFAULT 0,
    total_stars INT DEFAULT 0,
    endless_high_score INT DEFAULT 0,
    total_play_time_seconds INT DEFAULT 0, -- Tổng thời gian chơi tích lũy (giây)
    last_updated TIMESTAMPTZ DEFAULT NOW()
);

-- =========================================================================
-- INDEXES TỐI ƯU HÓA TRUY VẤN XẾP HẠNG THỜI GIAN THỰC (REAL-TIME)
-- =========================================================================
CREATE INDEX IF NOT EXISTS idx_zg_leaderboards_mode_score ON public.zg_leaderboards(mode, score DESC, duration_seconds ASC);
CREATE INDEX IF NOT EXISTS idx_zg_leaderboards_user ON public.zg_leaderboards(user_id);
CREATE INDEX IF NOT EXISTS idx_zg_daily_rankings_date_score ON public.zg_daily_rankings(date_utc, score DESC, duration_seconds ASC);
CREATE INDEX IF NOT EXISTS idx_zg_stats_stars ON public.zg_player_statistics(total_stars DESC);
CREATE INDEX IF NOT EXISTS idx_zg_stats_endless ON public.zg_player_statistics(endless_high_score DESC);

-- =========================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =========================================================================
ALTER TABLE public.zg_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.zg_leaderboards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.zg_daily_rankings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.zg_player_statistics ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read zg_users" ON public.zg_users;
CREATE POLICY "Public read zg_users" ON public.zg_users FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert/update zg_users" ON public.zg_users;
CREATE POLICY "Public insert/update zg_users" ON public.zg_users FOR ALL USING (true);

DROP POLICY IF EXISTS "Public read zg_leaderboards" ON public.zg_leaderboards;
CREATE POLICY "Public read zg_leaderboards" ON public.zg_leaderboards FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert zg_leaderboards" ON public.zg_leaderboards;
CREATE POLICY "Public insert zg_leaderboards" ON public.zg_leaderboards FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Public read zg_daily_rankings" ON public.zg_daily_rankings;
CREATE POLICY "Public read zg_daily_rankings" ON public.zg_daily_rankings FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert/update zg_daily_rankings" ON public.zg_daily_rankings;
CREATE POLICY "Public insert/update zg_daily_rankings" ON public.zg_daily_rankings FOR ALL USING (true);

DROP POLICY IF EXISTS "Public read zg_player_statistics" ON public.zg_player_statistics;
CREATE POLICY "Public read zg_player_statistics" ON public.zg_player_statistics FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert/update zg_player_statistics" ON public.zg_player_statistics;
CREATE POLICY "Public insert/update zg_player_statistics" ON public.zg_player_statistics FOR ALL USING (true);

-- =========================================================================
-- STORED PROCEDURES & RPC FUNCTIONS CHO APP CLIENT
-- =========================================================================

-- 1. Nộp kết quả ván đấu tự động cập nhật thống kê & xếp hạng
CREATE OR REPLACE FUNCTION public.submit_game_result(
    p_user_id TEXT,
    p_username TEXT,
    p_mode TEXT,
    p_level_id TEXT,
    p_score INT,
    p_moves INT,
    p_duration_seconds INT,
    p_stars INT,
    p_combo_multiplier INT,
    p_seed TEXT DEFAULT NULL,
    p_ghost_replay JSONB DEFAULT NULL,
    p_date_utc TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_record_id BIGINT;
    v_is_daily_updated BOOLEAN := FALSE;
BEGIN
    -- Ghi nhận user
    INSERT INTO public.zg_users (user_id, username, last_active)
    VALUES (p_user_id, p_username, NOW())
    ON CONFLICT (user_id) DO UPDATE
    SET username = EXCLUDED.username, last_active = NOW();

    -- Ghi nhận chi tiết ván đấu
    INSERT INTO public.zg_leaderboards (
        user_id, username, mode, level_id, score, moves, 
        duration_seconds, stars, combo_multiplier, seed, ghost_replay_data
    )
    VALUES (
        p_user_id, p_username, p_mode, p_level_id, p_score, p_moves, 
        p_duration_seconds, p_stars, p_combo_multiplier, p_seed, p_ghost_replay
    )
    RETURNING id INTO v_record_id;

    -- Cập nhật thống kê người chơi
    INSERT INTO public.zg_player_statistics (
        user_id, username, total_games, total_wins, current_win_streak, 
        max_win_streak, total_stars, endless_high_score, total_play_time_seconds, last_updated
    )
    VALUES (
        p_user_id, p_username, 1, 1, 1, 1, p_stars, 
        CASE WHEN p_mode = 'endless' THEN p_score ELSE 0 END, 
        p_duration_seconds, NOW()
    )
    ON CONFLICT (user_id) DO UPDATE
    SET 
        username = EXCLUDED.username,
        total_games = public.zg_player_statistics.total_games + 1,
        total_wins = public.zg_player_statistics.total_wins + 1,
        current_win_streak = public.zg_player_statistics.current_win_streak + 1,
        max_win_streak = GREATEST(public.zg_player_statistics.max_win_streak, public.zg_player_statistics.current_win_streak + 1),
        total_stars = public.zg_player_statistics.total_stars + p_stars,
        endless_high_score = GREATEST(public.zg_player_statistics.endless_high_score, CASE WHEN p_mode = 'endless' THEN p_score ELSE 0 END),
        total_play_time_seconds = public.zg_player_statistics.total_play_time_seconds + p_duration_seconds,
        last_updated = NOW();

    -- Nếu là Daily Challenge, cập nhật bảng xếp hạng ngày
    IF p_mode = 'daily' AND p_date_utc IS NOT NULL THEN
        INSERT INTO public.zg_daily_rankings (
            date_utc, user_id, username, score, moves, duration_seconds, seed
        )
        VALUES (
            p_date_utc, p_user_id, p_username, p_score, p_moves, p_duration_seconds, COALESCE(p_seed, '')
        )
        ON CONFLICT (date_utc, user_id) DO UPDATE
        SET 
            score = GREATEST(public.zg_daily_rankings.score, EXCLUDED.score),
            moves = LEAST(public.zg_daily_rankings.moves, EXCLUDED.moves),
            duration_seconds = LEAST(public.zg_daily_rankings.duration_seconds, EXCLUDED.duration_seconds);
        v_is_daily_updated := TRUE;
    END IF;

    RETURN jsonb_build_object(
        'success', true,
        'record_id', v_record_id,
        'daily_updated', v_is_daily_updated
    );
END;
$$;

-- 2. Lấy danh sách Top bảng xếp hạng theo chế độ (Mỗi người chơi 1 kỷ lục cao nhất)
CREATE OR REPLACE FUNCTION public.get_top_leaderboard(
    p_mode TEXT,
    p_limit INT DEFAULT 50
)
RETURNS TABLE (
    rank BIGINT,
    user_id TEXT,
    username TEXT,
    score INT,
    moves INT,
    duration_seconds INT,
    stars INT,
    created_at TIMESTAMPTZ
)
LANGUAGE sql
STABLE
AS $$
    WITH ranked_entries AS (
        SELECT DISTINCT ON (user_id)
            user_id,
            username,
            score,
            moves,
            duration_seconds,
            stars,
            created_at
        FROM public.zg_leaderboards
        WHERE mode = p_mode
        ORDER BY user_id, score DESC, duration_seconds ASC
    )
    SELECT 
        ROW_NUMBER() OVER(ORDER BY score DESC, duration_seconds ASC) as rank,
        user_id,
        username,
        score,
        moves,
        duration_seconds,
        stars,
        created_at
    FROM ranked_entries
    ORDER BY score DESC, duration_seconds ASC
    LIMIT p_limit;
$$;

-- 3. Lấy danh sách Top bảng xếp hạng Daily Challenge UTC
CREATE OR REPLACE FUNCTION public.get_daily_leaderboard(
    p_date_utc TEXT,
    p_limit INT DEFAULT 50
)
RETURNS TABLE (
    rank BIGINT,
    user_id TEXT,
    username TEXT,
    score INT,
    moves INT,
    duration_seconds INT,
    created_at TIMESTAMPTZ
)
LANGUAGE sql
STABLE
AS $$
    SELECT 
        ROW_NUMBER() OVER(ORDER BY score DESC, duration_seconds ASC) as rank,
        user_id,
        username,
        score,
        moves,
        duration_seconds,
        created_at
    FROM public.zg_daily_rankings
    WHERE date_utc = p_date_utc
    ORDER BY score DESC, duration_seconds ASC
    LIMIT p_limit;
$$;

-- 4. RPC Admin: Thống kê tổng quan hệ thống
CREATE OR REPLACE FUNCTION public.get_admin_dashboard_stats()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_total_users INT;
    v_total_games INT;
    v_total_daily_entries INT;
    v_highest_score INT;
    v_total_play_time BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_total_users FROM public.zg_users;
    SELECT COUNT(*) INTO v_total_games FROM public.zg_leaderboards;
    SELECT COUNT(*) INTO v_total_daily_entries FROM public.zg_daily_rankings;
    SELECT COALESCE(MAX(score), 0) INTO v_highest_score FROM public.zg_leaderboards;
    SELECT COALESCE(SUM(total_play_time_seconds), 0) INTO v_total_play_time FROM public.zg_player_statistics;

    RETURN jsonb_build_object(
        'total_users', v_total_users,
        'total_games', v_total_games,
        'total_daily_entries', v_total_daily_entries,
        'highest_score', v_highest_score,
        'total_play_time_seconds', v_total_play_time
    );
END;
$$;

-- 5. RPC Admin: Khóa / Mở khóa người chơi (Ban / Unban)
CREATE OR REPLACE FUNCTION public.admin_set_user_ban(p_user_id TEXT, p_banned BOOLEAN)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.zg_users SET is_banned = p_banned WHERE user_id = p_user_id;
    IF p_banned THEN
        DELETE FROM public.zg_leaderboards WHERE user_id = p_user_id;
        DELETE FROM public.zg_daily_rankings WHERE user_id = p_user_id;
    END IF;
    RETURN TRUE;
END;
$$;

-- 6. RPC Admin: Xóa bản ghi điểm số bất thường
CREATE OR REPLACE FUNCTION public.admin_delete_leaderboard_entry(p_entry_id BIGINT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    DELETE FROM public.zg_leaderboards WHERE id = p_entry_id;
    RETURN TRUE;
END;
$$;

-- =========================================================================
-- 7. BẢNG QUẢN LÝ DANH SÁCH GAME ĐỘNG (txa_games)
-- Phục vụ hiển thị chính sách, metadata đa ứng dụng qua dynamic URL (?game=...)
-- =========================================================================
CREATE TABLE IF NOT EXISTS public.txa_games (
    slug TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    package_id TEXT NOT NULL,
    description TEXT,
    short_description TEXT,
    developer_name TEXT DEFAULT 'TXA Studio',
    support_email TEXT DEFAULT 'support@txastudio.click',
    genre TEXT DEFAULT 'Puzzle / Brain Games',
    privacy_notes JSONB DEFAULT '{}'::jsonb,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =========================================================================
-- 8. BẢNG TIẾP NHẬN YÊU CẦU XÓA TÀI KHOẢN & DỮ LIỆU (txa_deletion_requests)
-- Tuân thủ chính sách bắt buộc của Google Play Console (Data Deletion Request)
-- =========================================================================
CREATE TABLE IF NOT EXISTS public.txa_deletion_requests (
    id BIGSERIAL PRIMARY KEY,
    ticket_id TEXT UNIQUE NOT NULL,
    game_slug TEXT NOT NULL,
    email TEXT NOT NULL,
    user_id TEXT NOT NULL,
    scope TEXT NOT NULL DEFAULT 'all', -- 'all', 'leaderboard', 'auth'
    reason TEXT,
    status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'processing', 'completed', 'rejected'
    created_at TIMESTAMPTZ DEFAULT NOW(),
    processed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_txa_deletion_ticket ON public.txa_deletion_requests(ticket_id);
CREATE INDEX IF NOT EXISTS idx_txa_deletion_email ON public.txa_deletion_requests(email);
CREATE INDEX IF NOT EXISTS idx_txa_deletion_game ON public.txa_deletion_requests(game_slug);

-- RLS Policies cho txa_games & txa_deletion_requests
ALTER TABLE public.txa_games ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.txa_deletion_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read txa_games" ON public.txa_games;
CREATE POLICY "Public read txa_games" ON public.txa_games FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public insert txa_deletion_requests" ON public.txa_deletion_requests;
CREATE POLICY "Public insert txa_deletion_requests" ON public.txa_deletion_requests FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Public read txa_deletion_requests" ON public.txa_deletion_requests;
CREATE POLICY "Public read txa_deletion_requests" ON public.txa_deletion_requests FOR SELECT USING (true);

-- Khởi tạo dữ liệu mẫu cho game Zero Grid: Quantum Shift
INSERT INTO public.txa_games (slug, title, package_id, description, short_description, developer_name, support_email, genre)
VALUES (
    'quantumshift',
    'Zero Grid: Quantum Shift',
    'txa.zerogrid.quantumshift',
    'High-Performance Pure Flutter Logic Puzzle Game. 100% Solvable Reverse Generation Algorithm, 120 FPS Minimalist Cyber Experience.',
    'Puzzle giải đố Lights Out phân rã số học đỉnh cao. 100% có nghiệm, 120 FPS!',
    'TXA Studio',
    'txasoftdev@gmail.com',
    'Puzzle / Brain Games'
)
ON CONFLICT (slug) DO UPDATE SET
    title = EXCLUDED.title,
    package_id = EXCLUDED.package_id,
    description = EXCLUDED.description,
    short_description = EXCLUDED.short_description,
    support_email = EXCLUDED.support_email,
    updated_at = NOW();

