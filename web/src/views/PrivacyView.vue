<template>
  <div class="relative z-10 py-12 lg:py-16">
    <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
      
      <!-- Top Header Breadcrumb & Status -->
      <div class="flex flex-wrap items-center justify-between gap-4 mb-8 pb-6 border-b border-slate-800/80">
        <div>
          <div class="flex items-center gap-2 text-xs font-mono text-cyan-400 uppercase tracking-widest mb-1">
            <router-link to="/" class="hover:underline">TXA STUDIO</router-link>
            <span>/</span>
            <span>LEGAL & PRIVACY COMPLIANCE</span>
          </div>
          <h1 class="text-2xl sm:text-4xl font-display font-black text-white">
            {{ isEn ? 'Privacy Policy' : 'Chính Sách Quyền Riêng Tư' }}
          </h1>
        </div>

        <!-- Live Sync Badge -->
        <div class="flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-cyan-500/10 border border-cyan-500/30 font-mono text-xs text-cyan-400">
          <span class="w-2 h-2 rounded-full bg-cyan-400 animate-pulse"></span>
          <span>SUPABASE SYNC: {{ game.slug.toUpperCase() }}</span>
        </div>
      </div>

      <!-- Game Target Info Banner -->
      <div class="glass-panel rounded-2xl p-6 mb-10 border border-cyan-500/20 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-6">
        <div class="flex items-center gap-4">
          <div class="w-14 h-14 rounded-2xl bg-gradient-to-tr from-cyan-400 via-sky-500 to-pink-500 p-[2px] shadow-lg shadow-cyan-500/20 shrink-0">
            <img src="/logo_master.png" alt="Icon" class="w-full h-full rounded-[14px] object-cover bg-slate-950" />
          </div>
          <div>
            <div class="flex items-center gap-2">
              <h2 class="font-display font-bold text-lg text-white">{{ game.title }}</h2>
              <span class="text-[10px] font-mono px-2 py-0.5 rounded bg-slate-800 text-slate-300">
                {{ game.package_id }}
              </span>
            </div>
            <div class="text-xs text-slate-400 font-mono mt-0.5">
              {{ isEn ? 'Developer' : 'Nhà phát triển' }}: {{ game.developer_name }} • 
              {{ isEn ? 'Contact' : 'Email hỗ trợ' }}: <a :href="'mailto:' + game.support_email" class="text-cyan-400 hover:underline">{{ game.support_email }}</a>
            </div>
          </div>
        </div>

        <!-- Sleek Button to Data Erasure Portal -->
        <router-link
          :to="deletionRoute"
          class="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-gradient-to-r from-pink-500/20 to-purple-500/20 border border-pink-500/40 text-pink-300 hover:text-white hover:border-pink-400 hover:shadow-neon-pink font-display font-bold text-xs uppercase tracking-wider transition-all shrink-0"
        >
          <svg class="w-4 h-4 text-pink-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
          </svg>
          <span>{{ isEn ? 'Data Erasure Terminal' : 'Cổng Xóa Dữ Liệu' }}</span>
        </router-link>
      </div>

      <!-- Quick Summary Matrix Cards -->
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-10">
        <div class="glass-card p-4 rounded-xl border border-cyan-500/20">
          <div class="text-xs font-mono text-cyan-400 uppercase tracking-wider mb-1">
            {{ isEn ? 'DATA COLLECTION' : 'DỮ LIỆU THU THẬP' }}
          </div>
          <div class="text-sm font-bold text-white">
            {{ isEn ? 'Strict Minimalist (Zero PII)' : 'Tối giản (Không định danh)' }}
          </div>
          <div class="text-xs text-slate-400 mt-1">
            {{ isEn ? 'No name, phone, address or contacts collected.' : 'Không thu thập danh bạ, vị trí hay số điện thoại.' }}
          </div>
        </div>

        <div class="glass-card p-4 rounded-xl border border-pink-500/20">
          <div class="text-xs font-mono text-pink-400 uppercase tracking-wider mb-1">
            {{ isEn ? 'ADVERTISING & ADS' : 'QUẢNG CÁO' }}
          </div>
          <div class="text-sm font-bold text-white">
            {{ isEn ? 'Google AdMob Certified' : 'Google AdMob Chuẩn' }}
          </div>
          <div class="text-xs text-slate-400 mt-1">
            {{ isEn ? 'Non-intrusive rewarded & interstitial throttled.' : 'Tuân thủ giới hạn tần suất, không spam video.' }}
          </div>
        </div>

        <div class="glass-card p-4 rounded-xl border border-emerald-500/20">
          <div class="text-xs font-mono text-emerald-400 uppercase tracking-wider mb-1">
            {{ isEn ? 'DATA RETENTION & RIGHTS' : 'LƯU TRỮ & QUYỀN LỢI' }}
          </div>
          <div class="text-sm font-bold text-white">
            {{ isEn ? 'Full Erasure on Demand' : 'Xóa sạch khi có yêu cầu' }}
          </div>
          <div class="text-xs text-slate-400 mt-1">
            {{ isEn ? 'Self-service deletion processed in < 48h.' : 'Tự động gửi yêu cầu, xử lý dưới 48 giờ.' }}
          </div>
        </div>
      </div>

      <!-- Policy Content Clauses -->
      <div class="glass-panel rounded-2xl p-6 sm:p-10 border border-slate-800 space-y-10 text-slate-300 text-sm leading-relaxed">
        
        <!-- Section 1 -->
        <section class="space-y-3">
          <h3 class="text-lg sm:text-xl font-display font-bold text-white flex items-center gap-2">
            <span class="text-cyan-400 font-mono text-base">01.</span>
            {{ isEn ? 'Introduction & Scope' : 'Giới Thiệu & Phạm Vi Áp Dụng' }}
          </h3>
          <p>
            {{ isEn 
              ? 'This Privacy Policy describes how TXA Studio ("we", "us", or "our") collects, uses, and safeguards information when you play ' + game.title + ' on Android (Google Play) and other supported operating systems.' 
              : 'Chính sách Quyền riêng tư này mô tả cách TXA Studio ("chúng tôi") thu thập, sử dụng và bảo vệ thông tin khi bạn trải nghiệm tựa game ' + game.title + ' trên nền tảng Android (Google Play) cũng như các nền tảng liên quan.' }}
          </p>
          <p>
            {{ isEn
              ? 'By downloading or using the game, you agree to the collection and use of information in accordance with this policy.'
              : 'Bằng việc cài đặt và khởi chạy trò chơi, bạn đồng ý với các quy định thu thập và xử lý thông tin được nêu chi tiết tại tài liệu này.' }}
          </p>
        </section>

        <!-- Section 2 -->
        <section class="space-y-3">
          <h3 class="text-lg sm:text-xl font-display font-bold text-white flex items-center gap-2">
            <span class="text-cyan-400 font-mono text-base">02.</span>
            {{ isEn ? 'Information We Collect' : 'Thông Tin Chúng Tôi Thu Thập' }}
          </h3>
          <p>
            {{ isEn 
              ? 'We prioritize offline-first and minimalist data practices. The only data processed includes:' 
              : 'Chúng tôi hoạt động trên nguyên tắc ưu tiên Offline-First và tối giản dữ liệu. Các thông tin duy nhất có thể được xử lý bao gồm:' }}
          </p>
          <ul class="list-disc pl-5 space-y-2 text-slate-300">
            <li>
              <strong class="text-white">{{ isEn ? 'Anonymous Player Identifier (UUID):' : 'Định danh ẩn danh (UUID người chơi):' }}</strong>
              {{ isEn 
                ? ' A randomly generated unique key created on your device upon initial install, used exclusively to sync high scores, endless stats, and ghost replays to our Supabase database.' 
                : ' Chuỗi ký tự ngẫu nhiên được sinh cục bộ trên thiết bị khi cài game, chỉ dùng để đồng bộ điểm cao, bảng xếp hạng và bước đi bóng ma (Ghost Replay) trên Supabase.' }}
            </li>
            <li>
              <strong class="text-white">{{ isEn ? 'Gameplay Statistics:' : 'Thống kê kết quả ván chơi:' }}</strong>
              {{ isEn 
                ? ' Level ID, moves count, completion time, combo multiplier, and puzzle seed.' 
                : ' Cấp độ, số bước đi, thời gian hoàn thành, hệ số combo và mã hạt giống ma trận (puzzle seed).' }}
            </li>
            <li>
              <strong class="text-white">{{ isEn ? 'Diagnostics & Crash Reports:' : 'Dữ liệu chẩn đoán kỹ thuật:' }}</strong>
              {{ isEn 
                ? ' Device model, operating system version, and anonymous crash stack traces to fix game performance bugs.' 
                : ' Đời máy, phiên bản hệ điều hành và nhật ký lỗi crash ẩn danh nhằm tối ưu hóa hiệu năng 120 FPS.' }}
            </li>
          </ul>
        </section>

        <!-- Section 3 -->
        <section class="space-y-3">
          <h3 class="text-lg sm:text-xl font-display font-bold text-white flex items-center gap-2">
            <span class="text-cyan-400 font-mono text-base">03.</span>
            {{ isEn ? 'Third-Party Services & Google AdMob' : 'Dịch Vụ Bên Thứ Ba & Quảng Cáo Google AdMob' }}
          </h3>
          <p>
            {{ isEn 
              ? 'The app utilizes official Google Mobile Ads SDK (AdMob) to display non-intrusive banner and rewarded ads. Google AdMob may use standard advertising identifiers (GAID) in accordance with Google Play Developer Policies.' 
              : 'Ứng dụng tích hợp SDK chính thức Google Mobile Ads (AdMob) để cung cấp quảng cáo Banner và Rewarded Video (tùy chọn nhận gợi ý giải đố). Google AdMob có thể sử dụng Mã nhận dạng quảng cáo (GAID) tuân theo chính sách nhà phát triển của Google Play.' }}
          </p>
          <p>
            {{ isEn 
              ? 'For detailed information on how Google processes advertising data, please refer to Google’s Privacy & Terms: https://policies.google.com/technologies/ads.' 
              : 'Để tìm hiểu chi tiết cách Google xử lý dữ liệu quảng cáo, bạn có thể tham khảo tại Chính sách quyền riêng tư của Google: https://policies.google.com/technologies/ads.' }}
          </p>
        </section>

        <!-- Section 4: Sleek Interactive Deletion Card -->
        <section class="space-y-4">
          <h3 class="text-lg sm:text-xl font-display font-bold text-white flex items-center gap-2">
            <span class="text-pink-400 font-mono text-base">04.</span>
            {{ isEn ? 'User Rights & Account Deletion Protocol' : 'Quyền Của Người Dùng & Cơ Chế Xóa Dữ Liệu' }}
          </h3>
          <p>
            {{ isEn 
              ? 'Under Google Play Data Safety standards, all players possess the right to permanently purge their account, leaderboard scores, and cloud statistics.' 
              : 'Tuân thủ nghiêm ngặt tiêu chuẩn An toàn Dữ liệu (Data Safety) của Google Play, mọi người chơi đều có quyền yêu cầu xóa vĩnh viễn dữ liệu điểm số, tài khoản và lịch sử đấu khỏi máy chủ của chúng tôi.' }}
          </p>
          
          <!-- Elegant Action Card -->
          <div class="glass-card p-6 rounded-2xl border border-pink-500/30 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
            <div class="space-y-1">
              <div class="font-display font-bold text-base text-white flex items-center gap-2">
                <span class="w-2 h-2 rounded-full bg-pink-400 animate-pulse"></span>
                <span>{{ isEn ? 'Self-Service Data Erasure Portal' : 'Cổng Yêu Cầu Xóa Dữ Liệu Tự Động' }}</span>
              </div>
              <p class="text-xs text-slate-400">
                {{ isEn 
                  ? 'Access the secure terminal to submit an automated request and receive an instant tracking ticket.' 
                  : 'Truy cập cổng bảo mật để gửi yêu cầu thanh lọc dữ liệu và nhận mã Ticket theo dõi tiến độ.' }}
              </p>
            </div>
            
            <router-link 
              :to="deletionRoute" 
              class="px-5 py-3 rounded-xl bg-pink-500 hover:bg-pink-400 text-slate-950 font-display font-bold text-xs uppercase tracking-wider shadow-neon-pink transition-all shrink-0 flex items-center gap-2"
            >
              <span>{{ isEn ? 'Open Terminal' : 'Mở Giao Diện Xóa' }}</span>
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
              </svg>
            </router-link>
          </div>
        </section>

        <!-- Section 5 -->
        <section class="space-y-3">
          <h3 class="text-lg sm:text-xl font-display font-bold text-white flex items-center gap-2">
            <span class="text-cyan-400 font-mono text-base">05.</span>
            {{ isEn ? 'Contact Developer' : 'Thông Tin Liên Hệ Nhà Phát Triển' }}
          </h3>
          <p>
            {{ isEn 
              ? 'If you have any questions, compliance requests, or inquiries regarding your personal data, feel free to email our engineering desk directly at:' 
              : 'Nếu bạn có bất kỳ câu hỏi, thắc mắc hoặc yêu cầu nào liên quan đến dữ liệu cá nhân, vui lòng liên hệ trực tiếp với bộ phận kỹ thuật của chúng tôi qua:' }}
          </p>
          <div class="font-mono text-sm text-cyan-400 bg-slate-900/90 p-3.5 rounded-xl border border-slate-800">
            Email: <a :href="'mailto:' + game.support_email" class="underline">{{ game.support_email }}</a><br />
            Studio: {{ game.developer_name }}<br />
            Domain: txastudio.click
          </div>
        </section>

      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, computed, inject, onMounted, watch } from 'vue';
import { useRoute } from 'vue-router';
import { getGameInfo, DEFAULT_GAME } from '../services/supabase.js';

const route = useRoute();
const currentLang = inject('currentLang', ref('vi'));
const isEn = computed(() => currentLang.value === 'en');

const game = ref({ ...DEFAULT_GAME });

const currentSlug = computed(() => {
  return route.params.gameSlug || route.query.game || 'quantumshift';
});

const deletionRoute = computed(() => {
  return `/delete-account/${currentSlug.value}`;
});

async function loadGame() {
  game.value = await getGameInfo(currentSlug.value);
}

onMounted(loadGame);
watch(() => route.params.gameSlug, loadGame);
watch(() => route.query.game, loadGame);
</script>
