<template>
  <div class="relative z-10">
    
    <!-- ================================================================= -->
    <!-- 1. SHIELDBLOCK HERO SECTION -->
    <!-- ================================================================= -->
    <section class="relative pt-12 pb-24 lg:pt-20 lg:pb-32 overflow-hidden">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-8 items-center">
          
          <!-- Left Column: ShieldBlock Intro & Actions -->
          <div class="lg:col-span-7 space-y-7 text-center lg:text-left">
            
            <!-- Neon Pill Badge -->
            <div class="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-emerald-500/10 border border-emerald-500/30 shadow-neon-green">
              <span class="w-2 h-2 rounded-full bg-emerald-400 animate-ping"></span>
              <span class="text-xs font-mono font-bold tracking-widest text-emerald-300 uppercase">
                OFFICIAL CHROME STORE // RELEASE 1.1.0
              </span>
            </div>

            <!-- Main Heading -->
            <h1 class="text-4xl sm:text-6xl lg:text-7xl font-display font-black tracking-tight leading-[1.05] text-white">
              SHIELDBLOCK <br />
              <span class="text-emerald-400">PRO BLOCKER</span>
            </h1>

            <!-- Subtitle -->
            <p class="text-base sm:text-lg text-slate-300 max-w-2xl mx-auto lg:mx-0 leading-relaxed font-normal">
              {{ isEn 
                ? 'Official Chromium Manifest V3 extension approved by Google. High-speed ad and tracker blocker featuring an Anti-Trap Engine, Smart Video Player Guard, and TXA Studio Cloud Sync.'
                : 'Tiện ích chặn quảng cáo và bẫy lừa đảo thế hệ mới đã được Google kiểm duyệt và phát hành chính thức trên Chrome Web Store. Tích hợp bộ máy chống clickjacking, bảo vệ video player và đồng bộ đám mây qua TXA Studio ID.' }}
            </p>

            <!-- CTA Buttons -->
            <div class="flex flex-wrap items-center justify-center lg:justify-start gap-4 pt-2">
              <a 
                href="https://chromewebstore.google.com/detail/shieldblock-ad-tracker-bl/neajkofkkadimcabbhekjcgdbbkfpfll"
                target="_blank"
                rel="noopener noreferrer"
                class="inline-flex items-center gap-3 px-6 py-3.5 rounded-2xl bg-gradient-to-r from-emerald-400 via-teal-500 to-cyan-500 text-slate-950 font-display font-black text-sm uppercase tracking-wider shadow-lg shadow-emerald-500/30 hover:shadow-emerald-400/50 hover:scale-[1.03] active:scale-95 transition-all"
                @mouseenter="sound.playHover()"
                @click="sound.playClick()"
              >
                <ChromeStoreIcon customClass="w-5 h-5" />
                <span>{{ isEn ? 'GET ON CHROME STORE' : 'CÀI TRÊN CHROME STORE' }}</span>
              </a>

              <a 
                href="https://t.me/dongmephim_channel" 
                target="_blank" 
                rel="noopener noreferrer"
                class="inline-flex items-center gap-2 px-6 py-3.5 rounded-2xl bg-cyan-500/10 hover:bg-cyan-500/20 border border-cyan-500/30 text-cyan-300 hover:text-white font-medium text-sm transition-all hover:scale-[1.02] active:scale-95"
                @mouseenter="sound.playHover()"
                @click="sound.playClick()"
              >
                <span>🎬</span>
                <span>{{ isEn ? 'Telegram Community' : 'Kênh Động Mê Phim' }}</span>
              </a>

              <router-link
                to="/privacy?app=shieldblock" 
                class="inline-flex items-center gap-2 px-6 py-3.5 rounded-2xl glass-panel border border-slate-700 hover:border-emerald-400 text-white font-medium text-sm hover:text-emerald-300 transition-all hover:scale-[1.02] active:scale-95"
                @mouseenter="sound.playHover()"
                @click="sound.playClick()"
              >
                <span>🛡️</span>
                <span>{{ isEn ? 'Privacy Policy' : 'Chính Sách Bảo Mật' }}</span>
              </router-link>
            </div>

            <!-- Platform Availability Indicator Pills -->
            <div class="flex flex-wrap items-center justify-center lg:justify-start gap-2.5 pt-2 text-xs font-mono">
              <div class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-300">
                <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse"></span>
                <span>Google Chrome: Live on Store</span>
              </div>
              <div class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-sky-500/10 border border-sky-500/30 text-sky-300">
                <span class="w-1.5 h-1.5 rounded-full bg-sky-400"></span>
                <span>Microsoft Edge: Supported</span>
              </div>
              <div class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-purple-500/10 border border-purple-500/30 text-purple-300">
                <span class="w-1.5 h-1.5 rounded-full bg-purple-400"></span>
                <span>Brave / Opera: Compatible</span>
              </div>
            </div>

            <!-- Mini Spec Badges -->
            <div class="grid grid-cols-3 gap-3 pt-6 border-t border-slate-800/80 max-w-lg mx-auto lg:mx-0">
              <div class="text-center lg:text-left">
                <div class="text-2xl sm:text-3xl font-display font-black text-emerald-400">0 TELEM</div>
                <div class="text-xs text-slate-400 font-mono">No History Tracking</div>
              </div>
              <div class="text-center lg:text-left">
                <div class="text-2xl sm:text-3xl font-display font-black text-cyan-400">MV3</div>
                <div class="text-xs text-slate-400 font-mono">High Efficiency</div>
              </div>
              <div class="text-center lg:text-left">
                <div class="text-2xl sm:text-3xl font-display font-black text-purple-400">CLOUD</div>
                <div class="text-xs text-slate-400 font-mono">TXA Studio Sync</div>
              </div>
            </div>

          </div>

          <!-- Right Column: 3D Holographic Showcase Graphic -->
          <div class="lg:col-span-5 relative flex justify-center">
            <div class="absolute inset-0 bg-gradient-to-tr from-emerald-500/20 to-cyan-500/20 rounded-3xl blur-2xl transform rotate-3 scale-95 pointer-events-none"></div>

            <div class="relative w-full max-w-md rounded-3xl glass-panel p-6 border border-emerald-500/30 shadow-2xl shadow-emerald-950/60 transition-transform duration-500 hover:scale-[1.02] flex flex-col items-center text-center">
              
              <div class="w-32 h-32 rounded-3xl bg-slate-900 border border-emerald-500/40 p-6 flex items-center justify-center shadow-xl shadow-emerald-500/20 mb-6">
                <img src="/shieldblock.svg" alt="ShieldBlock Pro" class="w-full h-full object-contain" />
              </div>

              <h3 class="font-display font-black text-white text-2xl tracking-wide">
                ShieldBlock Pro v1.1.0
              </h3>
              <p class="text-xs text-emerald-400 font-mono mt-1">
                Ad & Tracker Blocker Pro
              </p>
              <p class="text-xs text-slate-400 font-sans mt-3 leading-relaxed">
                Được phê duyệt bởi Google Chrome Web Store. Độc quyền tính năng chống bẫy chuyển hướng ngầm và đồng bộ dữ liệu bảo vệ qua tài khoản TXA Studio.
              </p>

              <div class="mt-6 w-full pt-4 border-t border-slate-800 flex items-center justify-between text-xs font-mono text-slate-400">
                <span>Developer: TXA Studio</span>
                <span class="text-emerald-400">Status: Verified</span>
              </div>
            </div>
          </div>

        </div>
      </div>
    </section>

    <!-- ================================================================= -->
    <!-- 2. FEATURES DEEP DIVE -->
    <!-- ================================================================= -->
    <section class="py-20 border-t border-slate-800/80 relative">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        <div class="text-center max-w-3xl mx-auto mb-16 space-y-4">
          <div class="inline-block text-xs font-mono font-bold tracking-widest text-emerald-400 uppercase bg-emerald-500/10 px-3.5 py-1 rounded-full border border-emerald-500/20">
            ADVANCED BROWSER DEFENSE
          </div>
          <h2 class="text-3xl sm:text-5xl font-display font-black text-white tracking-tight">
            BUILT FOR <span class="text-emerald-400">SPEED & SECURITY</span>
          </h2>
          <p class="text-slate-400 text-sm sm:text-base leading-relaxed">
            {{ isEn 
              ? 'ShieldBlock Pro eliminates intrusive traps, malicious clickjacking layers, and annoying video ads without degrading system resources.' 
              : 'ShieldBlock Pro triệt tiêu các bẫy pop-up ngầm, lớp overlay cướp thao tác và quảng cáo video phiền toái mà không gây hao pin hay lag máy.' }}
          </p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <div class="glass-card p-6 rounded-2xl space-y-4 border border-emerald-500/20">
            <div class="w-12 h-12 rounded-xl bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400 text-2xl font-bold">
              🛡️
            </div>
            <h3 class="font-display font-bold text-lg text-white">
              {{ isEn ? 'Anti-Clickjacking' : 'Chống Bẫy Click Tàng Hình' }}
            </h3>
            <p class="text-slate-400 text-xs sm:text-sm leading-relaxed">
              {{ isEn 
                ? 'Neutralizes invisible transparent divs covering websites to steal user clicks.' 
                : 'Tự động bóc tách các lớp thẻ div vô hình che phủ màn hình nhằm cướp click mở pop-up.' }}
            </p>
          </div>

          <div class="glass-card p-6 rounded-2xl space-y-4 border border-emerald-500/20">
            <div class="w-12 h-12 rounded-xl bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400 text-2xl font-bold">
              🎬
            </div>
            <h3 class="font-display font-bold text-lg text-white">
              {{ isEn ? 'Smart Player Guard' : 'Bảo Vệ Video Player' }}
            </h3>
            <p class="text-slate-400 text-xs sm:text-sm leading-relaxed">
              {{ isEn 
                ? 'Safeguards streaming video frames, allowing immediate play without unwanted redirects.' 
                : 'Bảo vệ khung phát phim/streaming, gỡ bỏ lớp bẫy đè nút Play/Pause mà không đơ player.' }}
            </p>
          </div>

          <div class="glass-card p-6 rounded-2xl space-y-4 border border-purple-500/20">
            <div class="w-12 h-12 rounded-xl bg-purple-500/10 border border-purple-500/30 flex items-center justify-center text-purple-400 text-2xl font-bold">
              ☁️
            </div>
            <h3 class="font-display font-bold text-lg text-white">
              {{ isEn ? 'TXA Studio Cloud' : 'Đồng Bộ TXA Studio ID' }}
            </h3>
            <p class="text-slate-400 text-xs sm:text-sm leading-relaxed">
              {{ isEn 
                ? 'Direct integration with TXA Studio central identity and cloud storage via Supabase.' 
                : 'Đăng nhập TXA Studio ID để sao lưu và đồng bộ danh sách trắng, luật tuỳ chỉnh tức thì.' }}
            </p>
          </div>

          <div class="glass-card p-6 rounded-2xl space-y-4 border border-cyan-500/20">
            <div class="w-12 h-12 rounded-xl bg-cyan-500/10 border border-cyan-500/30 flex items-center justify-center text-cyan-400 text-2xl font-bold">
              ⚡
            </div>
            <h3 class="font-display font-bold text-lg text-white">
              {{ isEn ? 'Zero Telemetry' : 'Tuyệt Đối Không Ghi Dữ Liệu' }}
            </h3>
            <p class="text-slate-400 text-xs sm:text-sm leading-relaxed">
              {{ isEn 
                ? 'Complete privacy. No browsing history or personal web requests are stored or tracked.' 
                : 'Tôn trọng quyền riêng tư 100%. Không bao giờ thu thập hay ghi lại lịch sử lướt web của bạn.' }}
            </p>
          </div>
        </div>

        <div class="mt-12 text-center">
          <router-link 
            to="/" 
            class="text-xs font-mono text-slate-400 hover:text-cyan-400 underline"
          >
            ← {{ isEn ? 'Back to TXA Studio Portal' : 'Quay lại Trang Chủ TXA Studio' }}
          </router-link>
        </div>

      </div>
    </section>

  </div>
</template>

<script setup>
import { computed, inject, ref } from 'vue';
import ChromeStoreIcon from '../components/ChromeStoreIcon.vue';
import { sound } from '../services/sound.js';

const currentLang = inject('currentLang', ref('vi'));
const isEn = computed(() => currentLang.value === 'en');
</script>
