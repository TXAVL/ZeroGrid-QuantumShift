<template>
  <div class="relative z-10">
    
    <!-- ================================================================= -->
    <!-- 1. HERO SECTION -->
    <!-- ================================================================= -->
    <section class="relative pt-12 pb-20 lg:pt-20 lg:pb-28 overflow-hidden">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center max-w-4xl mx-auto space-y-6">
          
          <!-- Neon Pill Badge -->
          <div class="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-cyan-500/10 border border-cyan-500/30 shadow-neon-cyan">
            <span class="w-2 h-2 rounded-full bg-cyan-400 animate-ping"></span>
            <span class="text-xs font-mono font-bold tracking-widest text-cyan-300 uppercase">
              TXA STUDIO // DIGITAL INNOVATION LAB
            </span>
          </div>

          <!-- Main Heading -->
          <h1 class="text-4xl sm:text-6xl lg:text-7xl font-display font-black tracking-tight leading-[1.08] text-white">
            HIGH-PERFORMANCE <br />
            <span class="text-cyber-gradient text-neon-cyan">GAMES & SOFTWARE</span>
          </h1>

          <!-- Subtitle -->
          <p class="text-base sm:text-lg text-slate-300 max-w-3xl mx-auto leading-relaxed font-normal">
            {{ isEn 
              ? 'Welcome to TXA Studio. We engineer high-octane minimalist cyber puzzle games and privacy-first browser security extensions, powered by pure 120 FPS mechanics, clean architecture, and absolute user privacy.'
              : 'Chào mừng bạn đến với TXA Studio. Chúng tôi sáng tạo các tựa game giải đố trí tuệ phong cách Cyberpunk 120 FPS và các tiện ích bảo mật duyệt web riêng tư hàng đầu, tôn trọng trải nghiệm người dùng tuyệt đối.' }}
          </p>

          <!-- Quick Navigation Jump Pills -->
          <div class="flex flex-wrap items-center justify-center gap-3 pt-2">
            <a 
              href="#shieldblock"
              class="inline-flex items-center gap-2 px-5 py-2.5 rounded-2xl bg-emerald-500/15 border border-emerald-500/30 text-emerald-300 hover:bg-emerald-500/25 hover:border-emerald-400 font-mono text-xs uppercase tracking-wider transition-all hover:scale-105"
              @mouseenter="sound.playHover()"
              @click="sound.playClick()"
            >
              <span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
              <span>🛡️ ShieldBlock Pro (Chrome Store)</span>
            </a>

            <a 
              href="#showcase"
              class="inline-flex items-center gap-2 px-5 py-2.5 rounded-2xl bg-pink-500/15 border border-pink-500/30 text-pink-300 hover:bg-pink-500/25 hover:border-pink-400 font-mono text-xs uppercase tracking-wider transition-all hover:scale-105"
              @mouseenter="sound.playHover()"
              @click="sound.playClick()"
            >
              <span class="w-2 h-2 rounded-full bg-pink-400 animate-pulse"></span>
              <span>🎮 Zero Grid: Quantum Shift</span>
            </a>
          </div>

        </div>

        <!-- ============================================================= -->
        <!-- SPOTLIGHT: DUAL FLAGSHIP PROJECTS GRID -->
        <!-- ============================================================= -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mt-16">
          
          <!-- Spotlight Card 1: ShieldBlock Pro Extension -->
          <div class="relative rounded-3xl glass-panel p-6 sm:p-8 border border-emerald-500/30 shadow-2xl shadow-emerald-950/40 hover:border-emerald-400/60 transition-all duration-300 flex flex-col justify-between group">
            <div class="space-y-5">
              <!-- Top Row -->
              <div class="flex items-center justify-between">
                <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 font-mono text-xs font-bold">
                  <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-ping"></span>
                  <span>CHROME WEB STORE APPROVED</span>
                </div>
                <span class="text-xs font-mono text-slate-400">v1.1.0 Pro</span>
              </div>

              <!-- Logo & Title -->
              <div class="flex items-center gap-4">
                <div class="w-16 h-16 rounded-2xl bg-slate-900 border border-emerald-500/40 p-2.5 flex items-center justify-center shadow-lg shadow-emerald-500/20 group-hover:scale-105 transition-transform">
                  <img src="/shieldblock.svg" alt="ShieldBlock" class="w-full h-full object-contain" />
                </div>
                <div>
                  <h2 class="text-2xl font-display font-black text-white group-hover:text-emerald-300 transition-colors">
                    ShieldBlock Pro
                  </h2>
                  <p class="text-xs font-mono text-emerald-400">
                    Ad & Tracker Blocker • Anti-Trap Engine
                  </p>
                </div>
              </div>

              <!-- Description -->
              <p class="text-slate-300 text-sm leading-relaxed">
                {{ isEn 
                  ? 'Official Chromium Manifest V3 extension approved by Google. Neutralizes deceptive click overlays, tab-under redirects, spam popups, and protects streaming video players with TXA Studio Cloud Sync.'
                  : 'Tiện ích chặn quảng cáo và mã theo dõi thế hệ mới đã được Google kiểm duyệt và xuất bản chính thức trên Chrome Web Store. Tích hợp bộ máy chống bẫy chuyển hướng, bảo vệ Video Player và đồng bộ đám mây qua TXA Studio ID.' }}
              </p>

              <!-- Feature Highlights Pills -->
              <div class="grid grid-cols-2 gap-2 text-xs font-mono">
                <div class="px-3 py-2 rounded-xl bg-slate-900/80 border border-slate-800 text-slate-300 flex items-center gap-2">
                  <span class="text-emerald-400">⚡</span>
                  <span>Anti-Clickjacking</span>
                </div>
                <div class="px-3 py-2 rounded-xl bg-slate-900/80 border border-slate-800 text-slate-300 flex items-center gap-2">
                  <span class="text-emerald-400">🎬</span>
                  <span>Player Protection</span>
                </div>
                <div class="px-3 py-2 rounded-xl bg-slate-900/80 border border-slate-800 text-slate-300 flex items-center gap-2">
                  <span class="text-emerald-400">☁️</span>
                  <span>TXA Cloud Sync</span>
                </div>
                <div class="px-3 py-2 rounded-xl bg-slate-900/80 border border-slate-800 text-slate-300 flex items-center gap-2">
                  <span class="text-emerald-400">🛡️</span>
                  <span>Zero Data Logging</span>
                </div>
              </div>
            </div>

            <!-- Actions -->
            <div class="flex flex-wrap items-center gap-3 pt-6 mt-6 border-t border-slate-800/80">
              <a 
                href="https://chromewebstore.google.com/detail/shieldblock-ad-tracker-bl/neajkofkkadimcabbhekjcgdbbkfpfll"
                target="_blank"
                rel="noopener noreferrer"
                class="inline-flex items-center gap-2.5 px-6 py-3 rounded-2xl bg-gradient-to-r from-emerald-400 via-teal-500 to-cyan-500 text-slate-950 font-display font-black text-xs uppercase tracking-wider shadow-lg shadow-emerald-500/25 hover:shadow-emerald-400/40 hover:scale-[1.02] active:scale-95 transition-all"
                @mouseenter="sound.playHover()"
                @click="sound.playClick()"
              >
                <ChromeStoreIcon customClass="w-4 h-4" />
                <span>{{ isEn ? 'GET ON CHROME STORE' : 'CÀI TRÊN CHROME STORE' }}</span>
              </a>

              <a 
                href="#shieldblock"
                class="inline-flex items-center gap-1.5 px-4 py-3 rounded-2xl border border-slate-700 hover:border-emerald-400 text-slate-300 hover:text-white text-xs font-mono transition-all"
                @mouseenter="sound.playHover()"
                @click="sound.playClick()"
              >
                <span>Chi tiết tính năng →</span>
              </a>
            </div>
          </div>

          <!-- Spotlight Card 2: Zero Grid Game -->
          <div class="relative rounded-3xl glass-panel p-6 sm:p-8 border border-pink-500/30 shadow-2xl shadow-pink-950/40 hover:border-pink-400/60 transition-all duration-300 flex flex-col justify-between group">
            <div class="space-y-5">
              <!-- Top Row -->
              <div class="flex items-center justify-between">
                <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-pink-500/10 border border-pink-500/30 text-pink-300 font-mono text-xs font-bold">
                  <span class="w-1.5 h-1.5 rounded-full bg-pink-400 animate-ping"></span>
                  <span>GOOGLE PLAY // TESTING</span>
                </div>
                <span class="text-xs font-mono text-slate-400">v1.5.0</span>
              </div>

              <!-- Graphic / Logo & Title -->
              <div class="flex items-center gap-4">
                <div class="w-16 h-16 rounded-2xl bg-slate-900 border border-pink-500/40 p-2.5 flex items-center justify-center shadow-lg shadow-pink-500/20 group-hover:scale-105 transition-transform">
                  <img src="/logo_master.png" alt="Zero Grid" class="w-full h-full object-contain" />
                </div>
                <div>
                  <h2 class="text-2xl font-display font-black text-white group-hover:text-pink-300 transition-colors">
                    Zero Grid: Quantum Shift
                  </h2>
                  <p class="text-xs font-mono text-pink-400">
                    Cyber Roguelite Puzzle • Pure Flutter 120 FPS
                  </p>
                </div>
              </div>

              <!-- Description -->
              <p class="text-slate-300 text-sm leading-relaxed">
                {{ isEn 
                  ? 'High-Performance pure Flutter logic puzzle game. 100% mathematically solvable reverse generation algorithm, global ghost replay speedrunning, and zero spam mechanics.'
                  : 'Siêu phẩm giải đố Lights Out ma trận phân rã số học đỉnh cao. 100% có nghiệm toán học logic, khung hình 120 FPS mượt mà trên Canvas CustomPainter và lưu trữ bảng xếp hạng đám mây.' }}
              </p>

              <!-- Feature Highlights Pills -->
              <div class="grid grid-cols-2 gap-2 text-xs font-mono">
                <div class="px-3 py-2 rounded-xl bg-slate-900/80 border border-slate-800 text-slate-300 flex items-center gap-2">
                  <span class="text-pink-400">Ω</span>
                  <span>100% Solvable Logic</span>
                </div>
                <div class="px-3 py-2 rounded-xl bg-slate-900/80 border border-slate-800 text-slate-300 flex items-center gap-2">
                  <span class="text-pink-400">⚡</span>
                  <span>120 FPS Minimal Engine</span>
                </div>
                <div class="px-3 py-2 rounded-xl bg-slate-900/80 border border-slate-800 text-slate-300 flex items-center gap-2">
                  <span class="text-pink-400">☁️</span>
                  <span>Ghost Replay Cloud</span>
                </div>
                <div class="px-3 py-2 rounded-xl bg-slate-900/80 border border-slate-800 text-slate-300 flex items-center gap-2">
                  <span class="text-pink-400">0</span>
                  <span>No Pop-up Ads</span>
                </div>
              </div>
            </div>

            <!-- Actions -->
            <div class="flex flex-wrap items-center gap-3 pt-6 mt-6 border-t border-slate-800/80">
              <button 
                @click="openDownloadModal()"
                class="inline-flex items-center gap-2.5 px-6 py-3 rounded-2xl bg-gradient-to-r from-pink-400 via-rose-500 to-amber-500 text-slate-950 font-display font-black text-xs uppercase tracking-wider shadow-lg shadow-pink-500/25 hover:shadow-pink-400/40 hover:scale-[1.02] active:scale-95 transition-all"
                @mouseenter="sound.playHover()"
              >
                <GooglePlayIcon customClass="w-4 h-4" />
                <span>{{ isEn ? 'GET ON GOOGLE PLAY' : 'TẢI TRÊN GOOGLE PLAY' }}</span>
              </button>

              <a 
                href="#showcase"
                class="inline-flex items-center gap-1.5 px-4 py-3 rounded-2xl border border-slate-700 hover:border-pink-400 text-slate-300 hover:text-white text-xs font-mono transition-all"
                @mouseenter="sound.playHover()"
                @click="sound.playClick()"
              >
                <span>Chi tiết game →</span>
              </a>
            </div>
          </div>

        </div>

      </div>
    </section>


    <!-- ================================================================= -->
    <!-- 2. SHIELDBLOCK PRO DEEP DIVE (#shieldblock) -->
    <!-- ================================================================= -->
    <section id="shieldblock" class="py-20 border-t border-slate-800/80 relative">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        <div class="text-center max-w-3xl mx-auto mb-16 space-y-4">
          <div class="inline-block text-xs font-mono font-bold tracking-widest text-emerald-400 uppercase bg-emerald-500/10 px-3.5 py-1 rounded-full border border-emerald-500/20">
            BROWSER SECURITY & SMART ENGINE
          </div>
          <h2 class="text-3xl sm:text-5xl font-display font-black text-white tracking-tight">
            NEXT-GEN <span class="text-emerald-400">AD & TRACKER BLOCKER</span>
          </h2>
          <p class="text-slate-400 text-sm sm:text-base leading-relaxed">
            {{ isEn 
              ? 'ShieldBlock Pro combines the robust power of Chromium Manifest V3 with specialized anti-trap heuristics to give you an uncluttered, ultra-fast web experience.' 
              : 'ShieldBlock Pro kết hợp sức mạnh tối ưu chuẩn Manifest V3 cùng bộ nhận diện chống bẫy thông minh, mang lại trải nghiệm duyệt web siêu tốc và bảo vệ quyền riêng tư toàn diện.' }}
          </p>
        </div>

        <!-- 4 Cyber Feature Cards for ShieldBlock -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          
          <div class="glass-card p-6 rounded-2xl space-y-4 border border-emerald-500/20">
            <div class="w-12 h-12 rounded-xl bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400 text-2xl font-bold">
              🛡️
            </div>
            <h3 class="font-display font-bold text-lg text-white">
              {{ isEn ? 'Anti-Clickjacking Traps' : 'Chống Bẫy Click Tàng Hình' }}
            </h3>
            <p class="text-slate-400 text-xs sm:text-sm leading-relaxed">
              {{ isEn 
                ? 'Detects and neutralizes invisible full-page overlay traps designed to hijack your first click to open malicious popups.' 
                : 'Tự động quét và triệt tiêu các lớp thẻ div vô hình phủ kín trang web nhằm cướp thao tác click của bạn để mở pop-up quảng cáo.' }}
            </p>
          </div>

          <div class="glass-card p-6 rounded-2xl space-y-4 border border-emerald-500/20">
            <div class="w-12 h-12 rounded-xl bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400 text-2xl font-bold">
              🎬
            </div>
            <h3 class="font-display font-bold text-lg text-white">
              {{ isEn ? 'Smart Video Player Guard' : 'Bảo Vệ Video Player' }}
            </h3>
            <p class="text-slate-400 text-xs sm:text-sm leading-relaxed">
              {{ isEn 
                ? 'Protects video playback frames on streaming sites, clearing ad layers covering play buttons without breaking video controls.' 
                : 'Nhận diện khung phát video trên các trang xem phim, gỡ bỏ lớp bẫy đè lên nút Play/Pause mà không làm đơ hay lỗi trình phát.' }}
            </p>
          </div>

          <div class="glass-card p-6 rounded-2xl space-y-4 border border-emerald-500/20">
            <div class="w-12 h-12 rounded-xl bg-purple-500/10 border border-purple-500/30 flex items-center justify-center text-purple-400 text-2xl font-bold">
              ☁️
            </div>
            <h3 class="font-display font-bold text-lg text-white">
              {{ isEn ? 'TXA Studio Cloud Sync' : 'Đồng Bộ TXA Studio ID' }}
            </h3>
            <p class="text-slate-400 text-xs sm:text-sm leading-relaxed">
              {{ isEn 
                ? 'Seamlessly sync your custom filter rules, whitelists, and preferences across all devices via Supabase cloud infrastructure.' 
                : 'Đăng nhập bằng tài khoản TXA Studio ID để đồng bộ danh sách trắng, quy tắc cá nhân và thiết lập bảo vệ tức thì trên mọi máy tính.' }}
            </p>
          </div>

          <div class="glass-card p-6 rounded-2xl space-y-4 border border-cyan-500/20">
            <div class="w-12 h-12 rounded-xl bg-cyan-500/10 border border-cyan-500/30 flex items-center justify-center text-cyan-400 text-2xl font-bold">
              ⚡
            </div>
            <h3 class="font-display font-bold text-lg text-white">
              {{ isEn ? 'Chromium MV3 Speed' : 'Tối Ưu Chuẩn MV3' }}
            </h3>
            <p class="text-slate-400 text-xs sm:text-sm leading-relaxed">
              {{ isEn 
                ? 'Ultra-lean declarativeNetRequest rules engine. Consumes minimal memory and CPU with 0 background telemetry.' 
                : 'Tận dụng công nghệ declarativeNetRequest chạy ngầm trực tiếp ở tầng nhân trình duyệt. Tiết kiệm pin, nhẹ RAM và 0 thu thập dữ liệu.' }}
            </p>
          </div>

        </div>

        <div class="mt-10 text-center">
          <a 
            href="https://chromewebstore.google.com/detail/shieldblock-ad-tracker-bl/neajkofkkadimcabbhekjcgdbbkfpfll"
            target="_blank"
            rel="noopener noreferrer"
            class="inline-flex items-center gap-2 px-8 py-4 rounded-2xl bg-emerald-500/20 border border-emerald-400/50 text-emerald-300 hover:bg-emerald-500/30 font-display font-black text-sm uppercase tracking-wider shadow-lg shadow-emerald-500/20 transition-all hover:scale-105"
            @mouseenter="sound.playHover()"
            @click="sound.playClick()"
          >
            <ChromeStoreIcon customClass="w-5 h-5" />
            <span>{{ isEn ? 'INSTALL SHIELDBLOCK PRO ON CHROME WEB STORE' : 'CÀI ĐẶT SHIELDBLOCK PRO TRÊN CHROME WEB STORE' }}</span>
          </a>
        </div>

      </div>
    </section>


    <!-- ================================================================= -->
    <!-- 3. ZERO GRID SHOWCASE DEEP DIVE (#showcase) -->
    <!-- ================================================================= -->
    <section id="showcase" class="py-20 border-t border-slate-800/80 relative">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        <div class="text-center max-w-3xl mx-auto mb-16 space-y-4">
          <div class="inline-block text-xs font-mono font-bold tracking-widest text-pink-400 uppercase bg-pink-500/10 px-3.5 py-1 rounded-full border border-pink-500/20">
            TECHNICAL MASTERY & GAME DESIGN
          </div>
          <h2 class="text-3xl sm:text-5xl font-display font-black text-white tracking-tight">
            ENGINEERED FOR <span class="text-cyber-gradient text-neon-cyan">PURE LOGIC</span>
          </h2>
          <p class="text-slate-400 text-sm sm:text-base leading-relaxed">
            {{ isEn 
              ? 'Zero Grid strips away the bloat of modern mobile gaming to deliver an immaculate, high-speed cerebral experience.' 
              : 'Zero Grid loại bỏ hoàn toàn các cơ chế gacha rác và quảng cáo phiền toái, mang lại trải nghiệm tư duy logic thuần khiết nhất.' }}
          </p>
        </div>

        <!-- 4 Cyber Feature Cards for Zero Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          
          <div class="glass-card p-6 rounded-2xl space-y-4">
            <div class="w-12 h-12 rounded-xl bg-cyan-500/10 border border-cyan-500/30 flex items-center justify-center text-cyan-400 font-mono text-xl font-bold shadow-neon-cyan">
              Ω
            </div>
            <h3 class="font-display font-bold text-lg text-white">
              {{ isEn ? '100% Solvable Logic' : 'Thuật Toán Sinh Ngược' }}
            </h3>
            <p class="text-slate-400 text-xs sm:text-sm leading-relaxed">
              {{ isEn 
                ? 'Every grid is generated backwards through verified inverse bit-flip permutations. No impossible dead-ends.' 
                : 'Mỗi ván chơi đều được tạo ngược từ trạng thái chiến thắng. Đảm bảo 100% ván đấu luôn có lời giải toán học logic.' }}
            </p>
          </div>

          <div class="glass-card p-6 rounded-2xl space-y-4">
            <div class="w-12 h-12 rounded-xl bg-pink-500/10 border border-pink-500/30 flex items-center justify-center text-pink-400 font-mono text-xl font-bold shadow-neon-pink">
              ⚡
            </div>
            <h3 class="font-display font-bold text-lg text-white">
              {{ isEn ? '120 FPS Minimal Engine' : 'Khung Hình 120 FPS' }}
            </h3>
            <p class="text-slate-400 text-xs sm:text-sm leading-relaxed">
              {{ isEn 
                ? 'CustomPainter canvas rendering bypassing heavy widget trees. Instant tactile feedback with sub-millisecond input lag.' 
                : 'Vẽ trực tiếp trên Canvas CustomPainter, loại bỏ widget tree cồng kềnh. Phản hồi xúc giác tức thì, mượt mà tối đa.' }}
            </p>
          </div>

          <div class="glass-card p-6 rounded-2xl space-y-4">
            <div class="w-12 h-12 rounded-xl bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400 font-mono text-xl font-bold shadow-neon-green">
              ☁
            </div>
            <h3 class="font-display font-bold text-lg text-white">
              {{ isEn ? 'Ghost Replay Cloud' : 'Đua Top Ghost Replay' }}
            </h3>
            <p class="text-slate-400 text-xs sm:text-sm leading-relaxed">
              {{ isEn 
                ? 'Compete on daily leaderboards and observe recorded ghost replays from top global speedrunners via Supabase Edge.' 
                : 'Lưu điểm và tái hiện bước đi bóng ma (Ghost Replay) của các cao thủ tốc độ toàn cầu qua hạ tầng Supabase Edge.' }}
            </p>
          </div>

          <div class="glass-card p-6 rounded-2xl space-y-4">
            <div class="w-12 h-12 rounded-xl bg-purple-500/10 border border-purple-500/30 flex items-center justify-center text-purple-400 font-mono text-xl font-bold">
              🛡
            </div>
            <h3 class="font-display font-bold text-lg text-white">
              {{ isEn ? 'Privacy First (No-Ads)' : 'Không Quảng Cáo Rác' }}
            </h3>
            <p class="text-slate-400 text-xs sm:text-sm leading-relaxed">
              {{ isEn 
                ? 'Zero interstitial popup interruptions. Transparent data policy with automated self-service account erasure.' 
                : 'Tuyệt đối không chèn quảng cáo tràn màn hình gây ức chế khi đang suy nghĩ. Bạn toàn quyền kiểm soát dữ liệu cá nhân.' }}
            </p>
          </div>

        </div>

      </div>
    </section>


    <!-- ================================================================= -->
    <!-- 4. LEGAL & CENTRAL SERVICES DIRECTORY -->
    <!-- ================================================================= -->
    <section class="py-20 border-t border-slate-800/80 bg-[#050811]/60">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        <div class="text-center max-w-2xl mx-auto mb-12">
          <h2 class="text-2xl sm:text-3xl font-display font-black text-white">
            TXA STUDIO // CENTRAL PLATFORM SERVICES
          </h2>
          <p class="text-slate-400 text-xs sm:text-sm mt-2 font-mono">
            Hạ tầng tài khoản thống nhất & dịch vụ pháp lý minh bạch cho toàn bộ hệ sinh thái TXA Studio
          </p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          
          <!-- Card: Privacy Policy -->
          <router-link 
            to="/privacy"
            class="glass-panel p-8 rounded-2xl border border-slate-800 hover:border-cyan-400 transition-all group"
            @mouseenter="sound.playHover()"
            @click="sound.playClick()"
          >
            <div class="flex items-center justify-between mb-6">
              <span class="text-xs font-mono px-3 py-1 rounded-full bg-cyan-500/10 text-cyan-400 border border-cyan-500/20">
                DATA PRIVACY
              </span>
              <svg class="w-5 h-5 text-slate-500 group-hover:text-cyan-400 transform group-hover:translate-x-1 transition-all" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
              </svg>
            </div>
            <h3 class="font-display font-bold text-xl text-white group-hover:text-cyan-400 transition-colors mb-2">
              {{ isEn ? 'Privacy Policy' : 'Chính Sách Quyền Riêng Tư' }}
            </h3>
            <p class="text-slate-400 text-xs sm:text-sm leading-relaxed">
              {{ isEn 
                ? 'Full disclosures on data handling, permissions, offline storage for Zero Grid and ShieldBlock.' 
                : 'Khai báo chi tiết các loại dữ liệu xử lý, quyền ứng dụng và cam kết không lưu dữ liệu duyệt web.' }}
            </p>
          </router-link>

          <!-- Card: Delete Account Terminal -->
          <router-link 
            to="/delete-account"
            class="glass-panel p-8 rounded-2xl border border-pink-500/20 hover:border-pink-400 hover:shadow-neon-pink transition-all group relative overflow-hidden"
            @mouseenter="sound.playHover()"
            @click="sound.playClick()"
          >
            <div class="flex items-center justify-between mb-6">
              <span class="text-xs font-mono px-3 py-1 rounded-full bg-pink-500/10 text-pink-400 border border-pink-500/20">
                SELF-SERVICE
              </span>
              <svg class="w-5 h-5 text-slate-500 group-hover:text-pink-400 transform group-hover:translate-x-1 transition-all" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
              </svg>
            </div>
            <h3 class="font-display font-bold text-xl text-white group-hover:text-pink-400 transition-colors mb-2">
              {{ isEn ? 'Account Deletion Terminal' : 'Cổng Xóa Tài Khoản & Dữ Liệu' }}
            </h3>
            <p class="text-slate-400 text-xs sm:text-sm leading-relaxed">
              {{ isEn 
                ? 'Instant automated data erasure request with real-time ticket tracker code across all TXA apps.' 
                : 'Yêu cầu xóa toàn bộ tài khoản và dữ liệu cá nhân khỏi máy chủ TXA Studio với mã Ticket tra cứu tức thì.' }}
            </p>
          </router-link>

          <!-- Card: Terms of Service -->
          <router-link 
            to="/terms"
            class="glass-panel p-8 rounded-2xl border border-slate-800 hover:border-cyan-400 transition-all group"
            @mouseenter="sound.playHover()"
            @click="sound.playClick()"
          >
            <div class="flex items-center justify-between mb-6">
              <span class="text-xs font-mono px-3 py-1 rounded-full bg-slate-800 text-slate-300">
                FAIR PLAY
              </span>
              <svg class="w-5 h-5 text-slate-500 group-hover:text-cyan-400 transform group-hover:translate-x-1 transition-all" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
              </svg>
            </div>
            <h3 class="font-display font-bold text-xl text-white group-hover:text-cyan-400 transition-colors mb-2">
              {{ isEn ? 'Terms of Service' : 'Điều Khoản Dịch Vụ' }}
            </h3>
            <p class="text-slate-400 text-xs sm:text-sm leading-relaxed">
              {{ isEn 
                ? 'Rules on fair play, intellectual property rights, and community standards for software and games.' 
                : 'Quy định sử dụng công bằng, bảo hộ sở hữu trí tuệ và chuẩn mực an toàn cho game thủ & người dùng.' }}
            </p>
          </router-link>

        </div>

      </div>
    </section>

  </div>
</template>

<script setup>
import { computed, inject, ref } from 'vue';
import GooglePlayIcon from '../components/GooglePlayIcon.vue';
import ChromeStoreIcon from '../components/ChromeStoreIcon.vue';
import { sound } from '../services/sound.js';

const currentLang = inject('currentLang', ref('vi'));
const isEn = computed(() => currentLang.value === 'en');
const openDownloadModal = inject('openDownloadModal', () => {});
</script>
