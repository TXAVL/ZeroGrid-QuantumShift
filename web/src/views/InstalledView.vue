<template>
  <div class="relative z-10 py-12 lg:py-20">
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
      
      <!-- Top Success Badge -->
      <div class="text-center space-y-4 mb-12">
        <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 font-mono text-xs uppercase tracking-widest shadow-neon-green animate-bounce">
          <span class="w-2 h-2 rounded-full bg-emerald-400"></span>
          <span>{{ isEn ? 'INSTALLATION COMPLETE // SYSTEM READY' : 'CÀI ĐẶT THÀNH CÔNG // HỆ THỐNG ĐÃ KÍCH HOẠT' }}</span>
        </div>

        <h1 class="text-3xl sm:text-5xl lg:text-6xl font-display font-black text-white tracking-tight">
          {{ isEn ? 'Welcome to ' : 'Chào mừng bạn đến với ' }}
          <span class="text-transparent bg-clip-text bg-gradient-to-r from-emerald-400 via-teal-300 to-cyan-400">
            {{ appName }}
          </span>
        </h1>

        <p class="text-slate-300 text-sm sm:text-base max-w-2xl mx-auto leading-relaxed">
          {{ isEn 
            ? 'Your browser is now shielded with next-gen MV3 declarative filtering, anti-clickjacking trap detection, and zero-telemetry privacy.' 
            : 'Trình duyệt của bạn hiện đã được bảo vệ bởi công nghệ lọc Manifest V3 thế hệ mới, chống bẫy chuyển hướng lừa đảo và tuyệt đối không ghi dữ liệu duyệt web.' }}
        </p>
      </div>

      <!-- Telegram Promo Card (Động Mê Phim) - Featured! -->
      <div class="glass-panel p-6 sm:p-8 rounded-3xl border-2 border-cyan-500/40 shadow-2xl shadow-cyan-950/60 mb-12 relative overflow-hidden group">
        <div class="absolute -right-16 -top-16 w-60 h-60 bg-gradient-to-br from-cyan-500/20 to-blue-500/10 rounded-full blur-3xl pointer-events-none group-hover:scale-125 transition-transform duration-700"></div>

        <div class="flex flex-col md:flex-row items-center justify-between gap-6 relative z-10">
          <div class="flex items-center gap-5 text-center md:text-left flex-col md:flex-row">
            <div class="w-16 h-16 rounded-2xl bg-gradient-to-tr from-cyan-500 to-blue-600 p-[2px] shadow-lg shadow-cyan-500/30 shrink-0">
              <div class="w-full h-full bg-slate-950 rounded-[14px] flex items-center justify-center text-3xl">
                🎬
              </div>
            </div>
            <div class="space-y-1.5">
              <div class="flex items-center justify-center md:justify-start gap-2">
                <h3 class="font-display font-black text-xl text-white">
                  Động Mê Phim Channel
                </h3>
                <span class="text-[10px] font-mono px-2 py-0.5 rounded-full bg-cyan-500/20 text-cyan-300 border border-cyan-500/40">
                  OFFICIAL COMMUNITY
                </span>
              </div>
              <p class="text-xs sm:text-sm text-slate-300 max-w-xl leading-relaxed">
                {{ isEn 
                  ? 'Join our official Telegram community for daily movie recommendations, ad-free streaming tips, and instant support.' 
                  : 'Tham gia ngay kênh Telegram Động Mê Phim để cập nhật kho phim mới mỗi ngày, mẹo xem phim mượt không quảng cáo và nhận hỗ trợ kỹ thuật từ TXA Studio!' }}
              </p>
            </div>
          </div>

          <a 
            href="https://t.me/dongmephim_channel" 
            target="_blank" 
            rel="noopener noreferrer"
            class="px-6 py-3.5 rounded-2xl bg-gradient-to-r from-cyan-400 via-sky-500 to-blue-600 text-slate-950 font-display font-black text-xs uppercase tracking-wider shadow-lg shadow-cyan-500/30 hover:shadow-cyan-400/50 hover:scale-105 active:scale-95 transition-all shrink-0 flex items-center gap-2"
          >
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm4.64 6.8c-.15 1.58-.8 5.42-1.13 7.19-.14.75-.42 1-.68 1.03-.58.05-1.02-.38-1.58-.75-.88-.58-1.38-.94-2.23-1.5-.99-.65-.35-1.01.22-1.59.15-.15 2.71-2.48 2.76-2.69a.2.2 0 00-.05-.18c-.06-.05-.14-.03-.21-.02-.09.02-1.49.95-4.22 2.79-.4.27-.76.41-1.08.4-.36-.01-1.04-.2-1.55-.37-.63-.2-1.12-.31-1.08-.66.02-.18.27-.36.74-.55 2.92-1.27 4.86-2.11 5.83-2.51 2.78-1.16 3.35-1.36 3.73-1.36.08 0 .27.02.39.12.1.08.13.19.14.27-.01.06.01.24 0 .38z"/>
            </svg>
            <span>{{ isEn ? 'JOIN TELEGRAM CHANNEL' : 'THAM GIA KÊNH TELEGRAM' }}</span>
          </a>
        </div>
      </div>

      <!-- Quick 3-Step Setup Guide -->
      <div class="space-y-6 mb-12">
        <h2 class="text-center font-display font-black text-xl sm:text-2xl text-white">
          {{ isEn ? 'How to Pin & Use ShieldBlock in 3 Steps' : '3 Bước Ghim & Sử Dụng ShieldBlock' }}
        </h2>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <!-- Step 1 -->
          <div class="glass-panel p-6 rounded-2xl border border-slate-800 space-y-3 relative">
            <div class="w-8 h-8 rounded-xl bg-cyan-500/20 text-cyan-400 font-mono font-bold flex items-center justify-center text-sm border border-cyan-500/30">
              01
            </div>
            <h3 class="font-display font-bold text-white text-base">
              {{ isEn ? 'Open Extensions Menu' : 'Mở Menu Tiện Ích' }}
            </h3>
            <p class="text-slate-400 text-xs leading-relaxed">
              {{ isEn 
                ? 'Click the puzzle icon (🧩) on the top-right corner of your browser toolbar.' 
                : 'Bấm vào biểu tượng mảnh ghép (🧩) ở góc trên bên phải thanh công cụ trình duyệt.' }}
            </p>
          </div>

          <!-- Step 2 -->
          <div class="glass-panel p-6 rounded-2xl border border-slate-800 space-y-3 relative">
            <div class="w-8 h-8 rounded-xl bg-pink-500/20 text-pink-400 font-mono font-bold flex items-center justify-center text-sm border border-pink-500/30">
              02
            </div>
            <h3 class="font-display font-bold text-white text-base">
              {{ isEn ? 'Pin ShieldBlock Pro' : 'Ghim ShieldBlock Pro' }}
            </h3>
            <p class="text-slate-400 text-xs leading-relaxed">
              {{ isEn 
                ? 'Find ShieldBlock in the dropdown and click the Pin icon (📌) so it stays visible.' 
                : 'Tìm tên ShieldBlock trong danh sách rồi bấm vào nút Ghim (📌) để biểu tượng luôn xuất hiện.' }}
            </p>
          </div>

          <!-- Step 3 -->
          <div class="glass-panel p-6 rounded-2xl border border-slate-800 space-y-3 relative">
            <div class="w-8 h-8 rounded-xl bg-emerald-500/20 text-emerald-400 font-mono font-bold flex items-center justify-center text-sm border border-emerald-500/30">
              03
            </div>
            <h3 class="font-display font-bold text-white text-base">
              {{ isEn ? 'Browse with Freedom' : 'Tự Do Lướt Web' }}
            </h3>
            <p class="text-slate-400 text-xs leading-relaxed">
              {{ isEn 
                ? 'Ads and traps are automatically neutralized. Click the shield icon anytime to view stats or sync.' 
                : 'Mọi quảng cáo và bẫy đã được tự động chặn. Bấm vào khiên bất kỳ lúc nào để xem số lượng chặn hoặc đồng bộ cloud.' }}
            </p>
          </div>
        </div>
      </div>

      <!-- Feature Highlights Grid -->
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-12">
        <div class="p-5 rounded-2xl bg-slate-900/80 border border-slate-800 space-y-2">
          <div class="text-2xl">🚫</div>
          <div class="font-display font-bold text-sm text-white">{{ isEn ? 'Zero Ads & Traps' : 'Chặn Sạch Quảng Cáo' }}</div>
          <div class="text-xs text-slate-400">{{ isEn ? 'Popups, overlays & banners neutralized.' : 'Vô hiệu hóa popup, banner và quảng cáo che màn hình.' }}</div>
        </div>

        <div class="p-5 rounded-2xl bg-slate-900/80 border border-slate-800 space-y-2">
          <div class="text-2xl">🛡️</div>
          <div class="font-display font-bold text-sm text-white">{{ isEn ? 'Anti-Clickjacking' : 'Chống Bẫy Click Ẩn' }}</div>
          <div class="text-xs text-slate-400">{{ isEn ? 'Strips invisible click traps on streaming players.' : 'Tự động quét và xóa các lớp bẫy ẩn trên player video.' }}</div>
        </div>

        <div class="p-5 rounded-2xl bg-slate-900/80 border border-slate-800 space-y-2">
          <div class="text-2xl">🔒</div>
          <div class="font-display font-bold text-sm text-white">{{ isEn ? '100% Privacy' : 'Bảo Mật Tuyệt Đối' }}</div>
          <div class="text-xs text-slate-400">{{ isEn ? 'Zero browsing telemetry or URL harvest.' : 'Không theo dõi lịch sử, không lưu trữ địa chỉ web.' }}</div>
        </div>

        <div class="p-5 rounded-2xl bg-slate-900/80 border border-slate-800 space-y-2">
          <div class="text-2xl">☁️</div>
          <div class="font-display font-bold text-sm text-white">{{ isEn ? 'TXA Cloud Sync' : 'Đồng Bộ Đám Mây' }}</div>
          <div class="text-xs text-slate-400">{{ isEn ? 'Sync custom whitelist across devices.' : 'Đồng bộ danh sách quy tắc và whitelist qua TXA ID.' }}</div>
        </div>
      </div>

      <!-- Action Buttons -->
      <div class="flex flex-wrap items-center justify-center gap-4">
        <router-link 
          to="/shieldblock" 
          class="px-6 py-3.5 rounded-2xl bg-slate-900 hover:bg-slate-800 text-white font-display font-bold text-xs uppercase tracking-wider border border-slate-700 transition-all flex items-center gap-2"
        >
          <span>🛡️</span>
          <span>{{ isEn ? 'ShieldBlock Showcase' : 'Trang Giới Thiệu ShieldBlock' }}</span>
        </router-link>

        <router-link 
          to="/privacy?app=shieldblock" 
          class="px-6 py-3.5 rounded-2xl bg-slate-900 hover:bg-slate-800 text-slate-300 font-mono text-xs border border-slate-800 hover:border-slate-700 transition-all"
        >
          {{ isEn ? 'View Privacy Policy' : 'Chính Sách Bảo Mật' }}
        </router-link>
      </div>

    </div>
  </div>
</template>

<script setup>
import { computed, inject, ref } from 'vue';
import { useRoute } from 'vue-router';

const route = useRoute();
const currentLang = inject('currentLang', ref('vi'));
const isEn = computed(() => currentLang.value === 'en');

const appName = computed(() => {
  return route.query.name ? decodeURIComponent(route.query.name) : 'ShieldBlock Pro';
});

const appVersion = computed(() => {
  return route.query.version || '1.1.0';
});
</script>
