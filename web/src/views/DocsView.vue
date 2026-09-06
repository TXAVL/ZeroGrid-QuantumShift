<template>
  <div class="min-h-screen bg-[#05070f] text-slate-200 py-8 px-4 sm:px-6 lg:px-8 relative">
    <!-- Ambient Cyber Glows -->
    <div class="fixed top-20 left-10 w-80 h-80 bg-cyan-500/10 rounded-full blur-3xl pointer-events-none"></div>
    <div class="fixed bottom-20 right-10 w-96 h-96 bg-pink-500/10 rounded-full blur-3xl pointer-events-none"></div>

    <div class="max-w-7xl mx-auto">
      
      <!-- Top Header & Breadcrumb -->
      <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 pb-8 mb-8 border-b border-slate-800">
        <div>
          <div class="flex items-center gap-2 mb-1">
            <span class="w-2 h-2 rounded-full bg-cyan-400 animate-ping"></span>
            <span class="text-[11px] font-mono tracking-widest text-cyan-400 font-bold uppercase">
              DEVELOPER SPECIFICATION // API REFERENCE
            </span>
          </div>
          <h1 class="text-2xl sm:text-3xl font-display font-black text-white">
            {{ isEn ? 'TXA Studio ID & OAuth 2.0 Docs' : 'Tài Liệu Kỹ Thuật TXA Studio ID & OAuth' }}
          </h1>
          <p class="text-xs sm:text-sm text-slate-400 font-mono mt-1">
            {{ isEn ? 'First-party authentication, client generation rules & integration guide' : 'Hệ thống định danh tập trung, quy chuẩn Client ID và hướng dẫn tích hợp game' }}
          </p>
        </div>

        <div class="flex items-center gap-3">
          <!-- Mobile TOC Drawer Toggle Button -->
          <button 
            @click="mobileTocOpen = !mobileTocOpen"
            class="lg:hidden px-4 py-2.5 rounded-xl border border-cyan-500/40 bg-cyan-500/10 text-cyan-300 font-mono text-xs font-bold flex items-center gap-2"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h7" />
            </svg>
            <span>{{ isEn ? 'Contents' : 'Mục Lục' }}</span>
          </button>

          <router-link 
            to="/admin" 
            class="px-4 py-2.5 rounded-xl border border-pink-500/40 bg-pink-500/10 hover:bg-pink-500/20 text-pink-300 font-mono text-xs font-bold transition-all flex items-center gap-2"
          >
            <span>🛡️ Admin Portal</span>
          </router-link>
        </div>
      </div>

      <!-- Main Layout: Sidebar TOC + Content Area -->
      <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        
        <!-- SIDEBAR TOC (DESKTOP) -->
        <aside 
          class="hidden lg:block lg:col-span-3 sticky top-8 space-y-4"
          :class="isSidebarCollapsed ? 'lg:col-span-1' : 'lg:col-span-3'"
        >
          <div class="p-5 rounded-3xl border border-slate-800 bg-[#090d1a]/90 backdrop-blur-xl shadow-xl">
            <div class="flex items-center justify-between pb-3 mb-3 border-b border-slate-800 text-xs font-mono font-bold text-slate-300">
              <span v-if="!isSidebarCollapsed">MỤC LỤC TÀI LIỆU</span>
              <button 
                @click="isSidebarCollapsed = !isSidebarCollapsed"
                class="p-1.5 rounded-lg text-slate-400 hover:text-white hover:bg-slate-800 transition-all ml-auto"
                :title="isSidebarCollapsed ? 'Mở rộng mục lục' : 'Thu gọn mục lục'"
              >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path v-if="!isSidebarCollapsed" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 19l-7-7 7-7m8 14l-7-7 7-7" />
                  <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5l7 7-7 7M5 5l7 7-7 7" />
                </svg>
              </button>
            </div>

            <nav v-if="!isSidebarCollapsed" class="space-y-1.5 text-xs font-mono">
              <a 
                v-for="item in tocItems" 
                :key="item.id"
                :href="'#' + item.id"
                @click="scrollTo(item.id)"
                class="block px-3 py-2 rounded-xl transition-all"
                :class="activeSection === item.id 
                  ? 'bg-cyan-500/10 text-cyan-300 border border-cyan-500/30 font-bold' 
                  : 'text-slate-400 hover:text-slate-200 hover:bg-slate-900/60'"
              >
                {{ item.title }}
              </a>
            </nav>
          </div>
        </aside>

        <!-- MOBILE TOC DRAWER MODAL -->
        <Teleport to="body">
          <div 
            v-if="mobileTocOpen" 
            class="fixed inset-0 z-50 bg-black/80 backdrop-blur-md flex justify-end"
            @click.self="mobileTocOpen = false"
          >
            <div class="w-72 bg-[#090d1a] border-l border-slate-800 h-full p-6 space-y-4 overflow-y-auto">
              <div class="flex items-center justify-between pb-3 border-b border-slate-800 text-xs font-mono font-bold text-slate-300">
                <span>MỤC LỤC TÀI LIỆU</span>
                <button @click="mobileTocOpen = false" class="p-1 rounded text-slate-400 hover:text-white">✕</button>
              </div>
              <nav class="space-y-2 text-xs font-mono">
                <a 
                  v-for="item in tocItems" 
                  :key="item.id"
                  :href="'#' + item.id"
                  @click="mobileTocOpen = false; scrollTo(item.id)"
                  class="block px-3 py-2.5 rounded-xl border border-slate-800 bg-slate-900/60 text-slate-300 hover:text-cyan-400"
                >
                  {{ item.title }}
                </a>
              </nav>
            </div>
          </div>
        </Teleport>

        <!-- MAIN DOCUMENT CONTENT -->
        <main 
          class="space-y-12"
          :class="isSidebarCollapsed ? 'lg:col-span-11' : 'lg:col-span-9'"
        >

          <!-- SECTION 1: OVERVIEW -->
          <section id="overview" class="p-6 sm:p-8 rounded-3xl border border-slate-800 bg-[#090d1a]/80 backdrop-blur-xl space-y-4">
            <div class="flex items-center gap-2 text-xs font-mono text-cyan-400 font-bold">
              <span>01 // ARCHITECTURE</span>
            </div>
            <h2 class="text-xl sm:text-2xl font-display font-black text-white">
              Tổng Quan Kiến Trúc TXA Studio ID
            </h2>
            <p class="text-sm text-slate-300 leading-relaxed">
              <strong>TXA Studio ID</strong> là hệ thống xác thực và ủy quyền tập trung (Single Sign-On / OAuth 2.0 First-Party) dành riêng cho hệ sinh thái các trò chơi và ứng dụng do TXA Studio phát hành. 
              Người chơi chỉ cần tạo <strong>một tài khoản duy nhất</strong> trên trang web để liên kết dữ liệu hồ sơ, lưu trữ đám mây (Cloud Save) và điểm số bảng xếp hạng (Global Leaderboards) qua tất cả các tựa game.
            </p>
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 pt-2 text-xs font-mono">
              <div class="p-3.5 rounded-2xl border border-cyan-500/30 bg-cyan-500/10 text-cyan-300">
                <div class="font-bold mb-1">✓ 1 Tài Khoản Duy Nhất</div>
                <div class="text-[11px] text-slate-400">Đăng nhập mọi game phát hành bởi Studio</div>
              </div>
              <div class="p-3.5 rounded-2xl border border-emerald-500/30 bg-emerald-500/10 text-emerald-300">
                <div class="font-bold mb-1">✓ Bảo Mật PKCE 5 Phút</div>
                <div class="text-[11px] text-slate-400">Chống tấn công phát lại & lộ khóa bí mật</div>
              </div>
              <div class="p-3.5 rounded-2xl border border-purple-500/30 bg-purple-500/10 text-purple-300">
                <div class="font-bold mb-1">✓ 100% First-Party</div>
                <div class="text-[11px] text-slate-400">Độc quyền Admin quản lý & tự động cấp quyền</div>
              </div>
            </div>
          </section>

          <!-- SECTION 2: CLIENT ID RULES & VERIFIED -->
          <section id="client-id-rules" class="p-6 sm:p-8 rounded-3xl border border-slate-800 bg-[#090d1a]/80 backdrop-blur-xl space-y-4">
            <div class="flex items-center gap-2 text-xs font-mono text-pink-400 font-bold">
              <span>02 // SPECIFICATION</span>
            </div>
            <h2 class="text-xl sm:text-2xl font-display font-black text-white">
              Quy Chuẩn Client ID & Tiêu Chuẩn Verified
            </h2>
            <p class="text-sm text-slate-300 leading-relaxed">
              Mã Client ID phải tuân thủ nghiêm ngặt cấu trúc gồm tiền tố, phân loại ứng dụng, tên viết tắt và chuỗi 16 ký tự chữ và số ngẫu nhiên:
            </p>

            <!-- Code Block with Copy -->
            <div class="relative p-4 rounded-2xl bg-black/60 border border-slate-800 font-mono text-xs text-cyan-300">
              <div class="flex items-center justify-between pb-2 mb-2 border-b border-slate-800 text-[11px] text-slate-500">
                <span>CLIENT ID SYNTAX</span>
                <button @click="copyText('txa_{loại}_{viết_tắt}_{16_ký_tự_chữ_và_số}')" class="text-cyan-400 hover:text-cyan-300">Copy</button>
              </div>
              <code>txa_{loại_app_hoặc_game}_{tên_viết_tắt_chữ_đầu}_{chuỗi_ngẫu_nhiên_16_ký_tự_chữ_và_số}</code>
            </div>

            <div class="text-xs font-mono space-y-1 text-slate-400">
              <div>• <code>txa_</code>: Tiền tố cố định của Studio.</div>
              <div>• <code>game</code> / <code>app</code>: Phân loại phần mềm.</div>
              <div>• <code>zgqs</code>: Tên viết tắt các chữ cái đầu (Zero Grid: Quantum Shift).</div>
              <div>• <code>9k2m7x8p4q1w3v5z</code>: Chuỗi ngẫu nhiên 16 ký tự chữ & số.</div>
            </div>

            <!-- Auto Verified Criteria -->
            <div class="p-4 rounded-2xl border border-emerald-500/30 bg-emerald-500/10 space-y-2 mt-4">
              <div class="font-bold text-emerald-300 text-xs font-mono flex items-center gap-2">
                <span>✓ TIÊU CHUẨN TỰ ĐỘNG CẤP HUY HIỆU "TXA STUDIO VERIFIED"</span>
              </div>
              <ul class="text-xs text-slate-300 space-y-1 font-normal list-disc list-inside">
                <li>Ứng dụng được tạo và cấp quyền bởi tài khoản Admin (<code>created_by_admin = true</code>).</li>
                <li>Gắn liền với Game ID hợp lệ trong bảng <code>txa_games</code>.</li>
                <li>Đã khai báo đầy đủ Chính sách quyền riêng tư hợp lệ (<code>privacy_policy_url</code>).</li>
                <li>Đã khai báo đầy đủ Điều khoản dịch vụ hợp lệ (<code>terms_url</code>).</li>
                <li>Trạng thái đang hoạt động (<code>status = 'active'</code>).</li>
              </ul>
            </div>
          </section>

          <!-- SECTION 3: OAUTH FLOW & URL CLOAKING -->
          <section id="oauth-flow" class="p-6 sm:p-8 rounded-3xl border border-slate-800 bg-[#090d1a]/80 backdrop-blur-xl space-y-4">
            <div class="flex items-center gap-2 text-xs font-mono text-cyan-400 font-bold">
              <span>03 // SECURITY PROTOCOL</span>
            </div>
            <h2 class="text-xl sm:text-2xl font-display font-black text-white">
              Luồng Ủy Quyền & Cơ Chế Ẩn URL (URL Cloaking)
            </h2>
            <p class="text-sm text-slate-300 leading-relaxed">
              Để bảo vệ người dùng khỏi việc lộ mã xác thực khi chụp màn hình hoặc lưu lịch sử trình duyệt, trang ủy quyền thực hiện cơ chế <strong>URL Cloaking</strong>:
            </p>

            <ol class="text-xs text-slate-300 space-y-2 list-decimal list-inside font-normal">
              <li>Ứng dụng game mở trình duyệt tới: <code>https://txastudio.click/oauth/authorize?client_id=...&redirect_uri=...</code></li>
              <li>Trang web đọc tham số vào bộ nhớ RAM rồi gọi ngay <code>window.history.replaceState</code> để xóa sạch thanh URL.</li>
              <li>Người dùng xác nhận ủy quyền.</li>
              <li>Hệ thống sinh mã có tiền tố <code>txa_code_...</code> và kích hoạt Deep Link: <code>txa.zerogrid.quantumshift://oauth/callback?code=txa_code_...</code></li>
            </ol>
          </section>

          <!-- SECTION 4: 5-MIN COUNTDOWN & ERROR CODES -->
          <section id="countdown-and-errors" class="p-6 sm:p-8 rounded-3xl border border-slate-800 bg-[#090d1a]/80 backdrop-blur-xl space-y-4">
            <div class="flex items-center gap-2 text-xs font-mono text-amber-400 font-bold">
              <span>04 // DIAGNOSTICS</span>
            </div>
            <h2 class="text-xl sm:text-2xl font-display font-black text-white">
              Đồng Hồ Đếm Ngược 5 Phút & Danh Mục Mã Lỗi
            </h2>
            <p class="text-sm text-slate-300 leading-relaxed">
              Mỗi phiên yêu cầu được giới hạn nghiêm ngặt <strong>5 phút</strong> hiển thị bằng Badge 2 chữ số (<code>MM:SS</code>). Hệ thống phân tách 3 màn hình lỗi riêng biệt:
            </p>

            <div class="space-y-3 pt-2 text-xs font-mono">
              <div class="p-4 rounded-2xl border border-amber-500/30 bg-amber-500/10 text-amber-200 space-y-1">
                <div class="font-bold text-amber-400">1. TXA_ERR_SESSION_EXPIRED</div>
                <div class="text-slate-300">Phiên yêu cầu quá thời hạn 5 phút. Màn hình hiển thị đồng hồ hết giờ và nút "Mở Lại Yêu Cầu Mới Từ Game".</div>
              </div>

              <div class="p-4 rounded-2xl border border-rose-500/30 bg-rose-500/10 text-rose-200 space-y-1">
                <div class="font-bold text-rose-400">2. TXA_ERR_INVALID_CLIENT_OR_PARAMS</div>
                <div class="text-slate-300">Client ID không tồn tại hoặc tham số sai định dạng. Hiển thị khiên an ninh đỏ và nút quay về trang chủ.</div>
              </div>

              <div class="p-4 rounded-2xl border border-purple-500/30 bg-purple-500/10 text-purple-200 space-y-1">
                <div class="font-bold text-purple-400">3. TXA_ERR_CODE_ALREADY_USED</div>
                <div class="text-slate-300">Mã phiên đã được sử dụng hoặc thu hồi trước đó (ngăn chặn tấn công Replay Attack).</div>
              </div>
            </div>
          </section>

          <!-- SECTION 5: FLUTTER INTEGRATION -->
          <section id="flutter-integration" class="p-6 sm:p-8 rounded-3xl border border-slate-800 bg-[#090d1a]/80 backdrop-blur-xl space-y-4">
            <div class="flex items-center gap-2 text-xs font-mono text-cyan-400 font-bold">
              <span>05 // FLUTTER INTEGRATION</span>
            </div>
            <h2 class="text-xl sm:text-2xl font-display font-black text-white">
              Cấu Hình Flutter Thông Qua txa_config.dart
            </h2>
            <p class="text-sm text-slate-300 leading-relaxed">
              Trong mã nguồn game, bạn tạo file <code>lib/core/config/txa_config.dart</code> để quản lý tập trung mã Client ID và Deep Link:
            </p>

            <!-- Code Block with Copy -->
            <div class="relative p-4 rounded-2xl bg-black/60 border border-slate-800 font-mono text-xs text-cyan-300">
              <div class="flex items-center justify-between pb-2 mb-2 border-b border-slate-800 text-[11px] text-slate-500">
                <span>lib/core/config/txa_config.dart</span>
                <button @click="copyText(flutterConfigCode)" class="text-cyan-400 hover:text-cyan-300 font-bold">Copy Code</button>
              </div>
              <pre class="overflow-x-auto text-[11px] text-slate-300"><code>{{ flutterConfigCode }}</code></pre>
            </div>
          </section>

          <!-- SECTION 6: API REFERENCE -->
          <section id="api-reference" class="p-6 sm:p-8 rounded-3xl border border-slate-800 bg-[#090d1a]/80 backdrop-blur-xl space-y-4">
            <div class="flex items-center gap-2 text-xs font-mono text-pink-400 font-bold">
              <span>06 // RPC ENDPOINTS</span>
            </div>
            <h2 class="text-xl sm:text-2xl font-display font-black text-white">
              Danh Mục RPC Endpoints Supabase
            </h2>
            <p class="text-sm text-slate-300 leading-relaxed">
              Các RPC functions được gọi qua giao thức HTTPS POST tới Supabase REST API:
            </p>

            <div class="space-y-3 pt-2 text-xs font-mono">
              <div class="p-3.5 rounded-xl border border-slate-800 bg-slate-900/60">
                <span class="px-2 py-0.5 rounded bg-cyan-500/20 text-cyan-400 font-bold mr-2">POST</span>
                <span class="text-white font-bold">/rpc/txa_verify_game_player</span>
                <p class="text-[11px] text-slate-400 mt-1">Xác minh mã người chơi (user_id / device_id / username) trong bảng zg_users.</p>
              </div>

              <div class="p-3.5 rounded-xl border border-slate-800 bg-slate-900/60">
                <span class="px-2 py-0.5 rounded bg-emerald-500/20 text-emerald-400 font-bold mr-2">POST</span>
                <span class="text-white font-bold">/rpc/txa_generate_oauth_code</span>
                <p class="text-[11px] text-slate-400 mt-1">Cấp mã ủy quyền txa_code_... với thời hạn 5 phút từ hệ thống cấu hình.</p>
              </div>

              <div class="p-3.5 rounded-xl border border-slate-800 bg-slate-900/60">
                <span class="px-2 py-0.5 rounded bg-purple-500/20 text-purple-400 font-bold mr-2">POST</span>
                <span class="text-white font-bold">/rpc/txa_exchange_oauth_code</span>
                <p class="text-[11px] text-slate-400 mt-1">Đổi mã txa_code_... lấy token truy cập txa_tok_... dành cho game.</p>
              </div>
            </div>
          </section>

        </main>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, inject } from 'vue';
import { sound } from '../services/sound.js';

const currentLang = inject('currentLang', ref('vi'));
const isEn = computed(() => currentLang.value === 'en');

const isSidebarCollapsed = ref(false);
const mobileTocOpen = ref(false);
const activeSection = ref('overview');

const tocItems = [
  { id: 'overview', title: '01. Tổng Quan Kiến Trúc' },
  { id: 'client-id-rules', title: '02. Quy Chuẩn Client ID' },
  { id: 'oauth-flow', title: '03. Luồng & Ẩn URL' },
  { id: 'countdown-and-errors', title: '04. Bộ Đếm 5 Phút & Mã Lỗi' },
  { id: 'flutter-integration', title: '05. Cấu Hình Flutter' },
  { id: 'api-reference', title: '06. RPC Endpoints' }
];

const flutterConfigCode = `class TxaConfig {
  static const String appType = 'game';
  static const String appAbbr = 'zgqs';
  static const String gameId = 'quantumshift';
  
  // Client ID chuẩn 16 ký tự chữ & số sinh từ trang Admin:
  static const String clientId = 'txa_game_zgqs_9k2m7x8p4q1w3v5z';
  
  // Deep Link Callback & Cổng OAuth:
  static const String redirectUri = 'txa.zerogrid.quantumshift://oauth/callback';
  static const String authEndpoint = 'https://txastudio.click/oauth/authorize';
  static const int sessionTimeoutMinutes = 5;
}`;

function scrollTo(id) {
  sound.playClick();
  activeSection.value = id;
  const el = document.getElementById(id);
  if (el) {
    el.scrollIntoView({ behavior: 'smooth' });
    history.replaceState(null, null, '#' + id);
  }
}

async function copyText(txt) {
  sound.playSuccess();
  try {
    await navigator.clipboard.writeText(txt);
  } catch (e) {}
}

onMounted(() => {
  if (window.location.hash) {
    const target = window.location.hash.replace('#', '');
    scrollTo(target);
  }
});
</script>
