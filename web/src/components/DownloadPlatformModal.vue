<template>
  <Teleport to="body">
    <transition name="modal-fade">
      <div 
        v-if="isOpen" 
        class="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6 overflow-y-auto bg-slate-950/80 backdrop-blur-xl"
        @click.self="close"
      >
        <!-- Modal Dialog Container -->
        <div 
          class="relative w-full max-w-2xl rounded-3xl border border-slate-700/80 bg-[#090d1a] shadow-2xl shadow-cyan-950/50 p-6 sm:p-8 overflow-hidden text-slate-100"
          role="dialog"
          aria-modal="true"
        >
          <!-- Background Glow FX -->
          <div class="absolute -top-24 -right-24 w-60 h-60 bg-cyan-500/10 rounded-full blur-3xl pointer-events-none"></div>
          <div class="absolute -bottom-24 -left-24 w-60 h-60 bg-pink-500/10 rounded-full blur-3xl pointer-events-none"></div>

          <!-- Header -->
          <div class="flex items-start justify-between gap-4 border-b border-slate-800 pb-5 mb-6 relative">
            <div>
              <div class="flex items-center gap-2 mb-1">
                <span class="w-2 h-2 rounded-full bg-cyan-400 animate-ping"></span>
                <span class="text-[11px] font-mono tracking-widest uppercase text-cyan-400 font-bold">
                  PLATFORM DISPATCH // ACCESS TERMINAL
                </span>
              </div>
              <h2 class="text-xl sm:text-2xl font-display font-black text-white">
                {{ isEn ? 'Game Release & Platform Availability' : 'Tình Trạng Bản Cài & Nền Tảng Khả Dụng' }}
              </h2>
            </div>

            <!-- Close Button -->
            <button 
              @click="close"
              class="p-2 rounded-xl border border-slate-800 bg-slate-900/80 text-slate-400 hover:text-white hover:border-slate-600 transition-all"
              aria-label="Close modal"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          <!-- Detected Device Banner -->
          <div class="mb-6 p-3.5 rounded-2xl border border-slate-800/80 bg-slate-900/60 flex items-center justify-between flex-wrap gap-2 text-xs font-mono">
            <div class="flex items-center gap-2">
              <span class="text-slate-400">{{ isEn ? 'Detected Device:' : 'Thiết bị phát hiện:' }}</span>
              <span class="px-2.5 py-0.5 rounded-md font-bold uppercase tracking-wide" :class="detectedPlatformBadgeClass">
                {{ detectedPlatformLabel }}
              </span>
            </div>
            <div class="text-slate-400 flex items-center gap-1.5 text-[11px]">
              <span class="w-1.5 h-1.5 rounded-full" :class="activePlatformStatusDot"></span>
              <span>{{ activePlatformSummary }}</span>
            </div>
          </div>

          <!-- Platform Navigation Tabs -->
          <div class="grid grid-cols-3 gap-2 p-1.5 bg-slate-950/80 rounded-2xl border border-slate-800 mb-6">
            <!-- Android Tab -->
            <button 
              @click="selectTab('android')"
              class="flex flex-col items-center justify-center py-2.5 px-2 rounded-xl text-xs font-mono font-bold transition-all gap-1 relative"
              :class="activeTab === 'android' 
                ? 'bg-gradient-to-b from-amber-500/20 to-amber-600/10 text-amber-300 border border-amber-500/40 shadow-lg shadow-amber-500/10' 
                : 'text-slate-400 hover:text-slate-200 hover:bg-slate-900/60'"
            >
              <div class="flex items-center gap-1.5">
                <GooglePlayIcon customClass="w-3.5 h-3.5" />
                <span>Android</span>
              </div>
              <span class="text-[9px] px-1.5 py-0.2 rounded bg-amber-500/20 text-amber-300">
                {{ isEn ? 'INTERNAL TEST' : 'KIỂM THỬ NỘI BỘ' }}
              </span>
            </button>

            <!-- iOS Tab -->
            <button 
              @click="selectTab('ios')"
              class="flex flex-col items-center justify-center py-2.5 px-2 rounded-xl text-xs font-mono font-bold transition-all gap-1 relative"
              :class="activeTab === 'ios' 
                ? 'bg-gradient-to-b from-sky-500/20 to-sky-600/10 text-sky-300 border border-sky-500/40 shadow-lg shadow-sky-500/10' 
                : 'text-slate-400 hover:text-slate-200 hover:bg-slate-900/60'"
            >
              <div class="flex items-center gap-1.5">
                <svg class="w-3.5 h-3.5 fill-current" viewBox="0 0 24 24">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M15.97 6.37c.61-.75 1.04-1.8 0.92-2.87-.9.04-2 .6-2.65 1.35-.57.65-1.07 1.73-.93 2.76 1.01.08 2.05-.49 2.66-1.24z"/>
                </svg>
                <span>Apple iOS</span>
              </div>
              <span class="text-[9px] px-1.5 py-0.2 rounded bg-sky-500/20 text-sky-300">
                {{ isEn ? 'COMING SOON' : 'CHƯA CÓ APP' }}
              </span>
            </button>

            <!-- Windows Tab -->
            <button 
              @click="selectTab('windows')"
              class="flex flex-col items-center justify-center py-2.5 px-2 rounded-xl text-xs font-mono font-bold transition-all gap-1 relative"
              :class="activeTab === 'windows' 
                ? 'bg-gradient-to-b from-rose-500/20 to-rose-600/10 text-rose-300 border border-rose-500/40 shadow-lg shadow-rose-500/10' 
                : 'text-slate-400 hover:text-slate-200 hover:bg-slate-900/60'"
            >
              <div class="flex items-center gap-1.5">
                <svg class="w-3.5 h-3.5 fill-current" viewBox="0 0 24 24">
                  <path d="M0 3.449L9.75 2.1v9.451H0m10.949-9.602L24 0v11.4H10.949M0 12.6h9.75v9.451L0 20.699M10.949 12.6H24V24l-12.949-1.801"/>
                </svg>
                <span>Windows / PC</span>
              </div>
              <span class="text-[9px] px-1.5 py-0.2 rounded bg-rose-500/20 text-rose-300">
                {{ isEn ? 'NOT SUPPORTED' : 'KHÔNG KHẢ DỤNG' }}
              </span>
            </button>
          </div>

          <!-- TAB 1: ANDROID (INTERNAL TESTING) -->
          <div v-if="activeTab === 'android'" class="space-y-5">
            <div class="p-4 rounded-2xl border border-amber-500/30 bg-amber-500/10 text-amber-200 text-sm">
              <div class="flex items-center gap-2 font-display font-bold text-amber-300 mb-1.5">
                <svg class="w-5 h-5 text-amber-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                </svg>
                <span>{{ isEn ? 'Google Play: Internal Testing Track Only' : 'Google Play: Đang Trong Giai Đoạn Kiểm Thử Nội Bộ' }}</span>
              </div>
              <p class="text-xs sm:text-sm text-slate-300 leading-relaxed font-normal">
                {{ isEn 
                  ? 'The game is NOT yet publicly launched on Google Play. It is restricted to pre-registered Internal Testers on Google Play Console.' 
                  : 'Trò chơi hiện CHƯA PHÁT HÀNH CÔNG KHAI trên Google Play mà đang được triển khai thử nghiệm nội bộ (Internal Testing Track). Chỉ những tài khoản Google được thêm vào danh sách Tester của TXA Studio mới có thể mở liên kết tải về.' }}
              </p>
              <div class="mt-2 text-[11px] font-mono text-amber-400/90 bg-black/40 p-2 rounded-xl border border-amber-500/20">
                ⚠️ {{ isEn 
                  ? 'If your Google account is NOT on the tester whitelist, Google Play will display "Item not found" or "Not available in your country".' 
                  : 'Lưu ý: Nếu tài khoản của bạn chưa được cấp quyền Tester, trang Google Play sẽ hiển thị "Mục này không có sẵn trong quốc gia của bạn" hoặc "Không tìm thấy URL".' }}
              </div>
            </div>

            <!-- Actions -->
            <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-3 pt-2">
              <!-- Open Play Store Link -->
              <a 
                href="https://play.google.com/store/apps/details?id=txa.zerogrid.quantumshift" 
                target="_blank" 
                rel="noopener"
                @mouseenter="sound.playHover()"
                @click="sound.playSuccess()"
                class="flex-1 inline-flex items-center justify-center gap-3 px-5 py-3.5 rounded-2xl bg-gradient-to-r from-cyan-400 via-sky-500 to-pink-500 text-slate-950 font-display font-black text-xs uppercase tracking-wider shadow-lg shadow-cyan-500/30 hover:shadow-cyan-400/50 hover:scale-[1.02] active:scale-95 transition-all"
              >
                <GooglePlayIcon customClass="w-5 h-5" />
                <span>{{ isEn ? 'OPEN PLAY STORE (TESTERS)' : 'VÀO GOOGLE PLAY (TESTER ĐÃ DUYỆT)' }}</span>
              </a>

              <!-- Request Tester Access via Email -->
              <button 
                @click="requestTesterAccess"
                @mouseenter="sound.playHover()"
                class="inline-flex items-center justify-center gap-2 px-5 py-3.5 rounded-2xl border border-amber-500/40 bg-amber-500/10 hover:bg-amber-500/20 text-amber-300 font-mono text-xs font-bold transition-all"
              >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                </svg>
                <span>{{ isEn ? 'Request Tester Access' : 'Đăng Ký Làm Tester' }}</span>
              </button>
            </div>
          </div>

          <!-- TAB 2: iOS (NOT YET RELEASED) -->
          <div v-if="activeTab === 'ios'" class="space-y-5">
            <div class="p-5 rounded-2xl border border-sky-500/30 bg-sky-500/10 text-sky-200">
              <div class="flex items-center gap-2 font-display font-bold text-sky-300 text-base mb-2">
                <svg class="w-5 h-5 text-sky-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span>{{ isEn ? 'iOS Version: In Development (Coming Soon)' : 'Phiên Bản Apple iOS: Hiện Chưa Có Ứng Dụng' }}</span>
              </div>
              <p class="text-xs sm:text-sm text-slate-300 leading-relaxed">
                {{ isEn 
                  ? 'Zero Grid: Quantum Shift is currently being optimized for Apple iOS (Metal graphics & 120Hz ProMotion). There is currently NO version available on the Apple App Store or public TestFlight.' 
                  : 'Tựa game Zero Grid: Quantum Shift hiện CHƯA CÓ ỨNG DỤNG trên nền tảng iOS (iPhone / iPad). Đội ngũ phát triển đang trong quá trình tối ưu hóa động cơ Flutter Metal 120Hz trước khi gửi xét duyệt lên TestFlight và Apple App Store.' }}
              </p>
              <div class="mt-3 p-3 rounded-xl bg-black/40 border border-sky-500/20 text-xs font-mono text-slate-400">
                💡 {{ isEn 
                  ? 'Recommendation: Please use an Android phone to participate in the early testing program.' 
                  : 'Khuyến nghị: Bạn vui lòng sử dụng thiết bị chạy Android để trải nghiệm sớm bản kiểm thử của chúng tôi.' }}
              </div>
            </div>

            <div class="flex items-center gap-3">
              <a 
                href="mailto:txasoftdev@gmail.com?subject=[iOS TestFlight Waitlist] Zero Grid: Quantum Shift"
                @mouseenter="sound.playHover()"
                @click="sound.playSuccess()"
                class="inline-flex items-center gap-2 px-5 py-3 rounded-2xl border border-sky-500/40 bg-sky-500/10 hover:bg-sky-500/20 text-sky-300 font-mono text-xs font-bold transition-all"
              >
                <span>✉ {{ isEn ? 'Join iOS Waitlist via Email' : 'Đăng Ký Nhận Thông Báo Bản iOS' }}</span>
              </a>
            </div>
          </div>

          <!-- TAB 3: WINDOWS (NOT AVAILABLE & NOT SUPPORTED) -->
          <div v-if="activeTab === 'windows'" class="space-y-5">
            <div class="p-5 rounded-2xl border border-rose-500/30 bg-rose-500/10 text-rose-200">
              <div class="flex items-center gap-2 font-display font-bold text-rose-300 text-base mb-2">
                <svg class="w-5 h-5 text-rose-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636" />
                </svg>
                <span>{{ isEn ? 'Windows / PC: Not Supported & Not Available' : 'Windows / PC: Không Có và Không Khả Dụng' }}</span>
              </div>
              <p class="text-xs sm:text-sm text-slate-300 leading-relaxed font-normal">
                {{ isEn 
                  ? 'Zero Grid is engineered strictly for mobile touchscreen devices. There is NO executable, installer, or web simulator available for Windows, macOS, or desktop platforms.' 
                  : 'Tựa game Zero Grid: Quantum Shift KHÔNG CÓ và KHÔNG KHẢ DỤNG trên Windows hay các hệ điều hành máy tính (PC / Laptop). Toàn bộ cơ chế giải đố logic và thao tác vuốt trượt siêu tốc được thiết kế đặc thù dành riêng cho màn hình cảm ứng di động.' }}
              </p>
              <div class="mt-3 p-3 rounded-xl bg-black/40 border border-rose-500/20 text-xs font-mono text-rose-300/90">
                🚫 {{ isEn 
                  ? 'No .exe or desktop builds exist. To play the game, please open this link on an Android mobile device.' 
                  : 'Không có tệp cài đặt .exe hay giả lập máy tính. Để trải nghiệm, bạn vui lòng truy cập trang web này trên điện thoại di động Android.' }}
              </div>
            </div>

            <!-- Copy Link for Mobile Button -->
            <div class="flex flex-wrap items-center gap-3 pt-1">
              <button 
                @click="copyPortalUrl"
                @mouseenter="sound.playHover()"
                class="inline-flex items-center gap-2 px-5 py-3 rounded-2xl bg-cyan-500/10 border border-cyan-500/40 text-cyan-300 hover:bg-cyan-500/20 font-mono text-xs font-bold transition-all"
              >
                <svg v-if="!copied" class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 5H6a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2v-1M8 5a2 2 0 002 2h2a2 2 0 002-2M8 5a2 2 0 012-2h2a2 2 0 012 2m0 0h2a2 2 0 012 2v3m2 4H10m0 0l3-3m-3 3l3 3" />
                </svg>
                <svg v-else class="w-4 h-4 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                </svg>
                <span>{{ copied ? (isEn ? 'Link Copied to Clipboard!' : 'Đã Sao Chép Link Web!') : (isEn ? 'Copy Portal Link to Send to Phone' : 'Sao Chép Link Để Gửi Sang Điện Thoại') }}</span>
              </button>
            </div>
          </div>

          <!-- Studio Support Contact Footer -->
          <div class="mt-8 pt-4 border-t border-slate-800/80 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs font-mono text-slate-400">
            <div>
              {{ isEn ? 'Support & Tester Hotline:' : 'Hỗ Trợ & Đăng Ký Tester:' }}
              <a href="mailto:txasoftdev@gmail.com" class="text-cyan-400 hover:underline font-bold ml-1">
                txasoftdev@gmail.com
              </a>
            </div>
            <button 
              @click="close"
              class="text-xs text-slate-500 hover:text-slate-300 underline font-mono"
            >
              {{ isEn ? 'Dismiss Terminal [ESC]' : 'Đóng Bảng Thông Báo [ESC]' }}
            </button>
          </div>

        </div>
      </div>
    </transition>
  </Teleport>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, inject } from 'vue';
import GooglePlayIcon from './GooglePlayIcon.vue';
import { sound } from '../services/sound.js';

const isOpen = ref(false);
const activeTab = ref('android');
const copied = ref(false);

const currentLang = inject('currentLang', ref('vi'));
const isEn = computed(() => currentLang.value === 'en');

const detectedPlatform = ref('unknown');

function detectOS() {
  if (typeof window === 'undefined') return 'unknown';
  const ua = (navigator.userAgent || '').toLowerCase();
  const platform = (navigator.platform || '').toLowerCase();

  // 1. iOS detection
  if (/iphone|ipad|ipod/.test(ua) || (platform.includes('mac') && navigator.maxTouchPoints > 1)) {
    return 'ios';
  }
  // 2. Android detection
  if (/android/.test(ua)) {
    return 'android';
  }
  // 3. Windows detection
  if (platform.includes('win') || /windows/.test(ua)) {
    return 'windows';
  }
  // 4. Desktop / Mac / Linux fallback to desktop class
  if (platform.includes('mac') || platform.includes('linux') || /macintosh|linux/.test(ua)) {
    return 'windows';
  }
  return 'windows';
}

const detectedPlatformLabel = computed(() => {
  if (detectedPlatform.value === 'android') return 'Android Mobile';
  if (detectedPlatform.value === 'ios') return 'Apple iOS (iPhone/iPad)';
  if (detectedPlatform.value === 'windows') return 'Windows / PC Desktop';
  return 'Desktop / Other';
});

const detectedPlatformBadgeClass = computed(() => {
  if (detectedPlatform.value === 'android') return 'bg-amber-500/20 text-amber-300 border border-amber-500/40';
  if (detectedPlatform.value === 'ios') return 'bg-sky-500/20 text-sky-300 border border-sky-500/40';
  return 'bg-rose-500/20 text-rose-300 border border-rose-500/40';
});

const activePlatformStatusDot = computed(() => {
  if (activeTab.value === 'android') return 'bg-amber-400';
  if (activeTab.value === 'ios') return 'bg-sky-400';
  return 'bg-rose-400';
});

const activePlatformSummary = computed(() => {
  if (activeTab.value === 'android') {
    return isEn.value ? 'Status: Internal Testing Only' : 'Trạng thái: Chỉ Thử Nghiệm Nội Bộ';
  }
  if (activeTab.value === 'ios') {
    return isEn.value ? 'Status: In Development (No App Yet)' : 'Trạng thái: Chưa Có Ứng Dụng';
  }
  return isEn.value ? 'Status: Not Supported on PC' : 'Trạng thái: Không Khả Dụng';
});

function open(preferredTab) {
  sound.playClick();
  const os = detectOS();
  detectedPlatform.value = os;

  if (typeof preferredTab === 'string' && ['android', 'ios', 'windows'].includes(preferredTab)) {
    activeTab.value = preferredTab;
  } else {
    // Automatically jump to the user's detected operating system!
    if (os === 'ios') {
      activeTab.value = 'ios';
    } else if (os === 'windows') {
      activeTab.value = 'windows';
    } else {
      activeTab.value = 'android';
    }
  }
  isOpen.value = true;
}

function close() {
  sound.playClick();
  isOpen.value = false;
}

function selectTab(tab) {
  sound.playHover();
  activeTab.value = tab;
}

function requestTesterAccess() {
  sound.playSuccess();
  const subject = encodeURIComponent('[Tester Access] Đăng ký tham gia kiểm thử nội bộ Zero Grid: Quantum Shift');
  const body = encodeURIComponent('Chào TXA Studio,\n\nTôi muốn tham gia chương trình kiểm thử nội bộ (Internal Testing) cho tựa game Zero Grid: Quantum Shift.\n\nEmail tài khoản Google Play của tôi: [Điền email Gmail của bạn tại đây]\nThiết bị Android: [Ví dụ: Samsung S23, Xiaomi 13...]\n\nXin cảm ơn!');
  window.location.href = `mailto:txasoftdev@gmail.com?subject=${subject}&body=${body}`;
}

async function copyPortalUrl() {
  sound.playSuccess();
  try {
    await navigator.clipboard.writeText(window.location.origin);
    copied.value = true;
    setTimeout(() => {
      copied.value = false;
    }, 3000);
  } catch {
    // Fallback
    copied.value = true;
  }
}

function handleKeydown(e) {
  if (e.key === 'Escape' && isOpen.value) {
    close();
  }
}

onMounted(() => {
  detectedPlatform.value = detectOS();
  window.addEventListener('keydown', handleKeydown);
});

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown);
});

defineExpose({
  open,
  close
});
</script>

<style scoped>
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.25s ease, transform 0.25s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
  transform: scale(0.97);
}
</style>
