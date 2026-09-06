<template>
  <div class="min-h-screen py-12 px-4 sm:px-6 flex items-center justify-center relative overflow-hidden bg-[#05070f] text-slate-100">
    <!-- Ambient Cyberpunk FX -->
    <div class="absolute top-10 left-1/2 -translate-x-1/2 w-[500px] h-[500px] bg-cyan-500/10 rounded-full blur-3xl pointer-events-none"></div>
    <div class="absolute bottom-10 right-10 w-96 h-96 bg-pink-500/10 rounded-full blur-3xl pointer-events-none"></div>

    <div class="relative w-full max-w-lg rounded-3xl border border-slate-800 bg-[#090d1a]/95 backdrop-blur-2xl p-6 sm:p-8 shadow-2xl shadow-cyan-950/40">

      <!-- =================================================================== -->
      <!-- STATE 1: ERROR - SESSION EXPIRED (QUÁ 5 PHÚT)                       -->
      <!-- =================================================================== -->
      <div v-if="errorState === 'TXA_ERR_SESSION_EXPIRED'" class="space-y-6 text-center py-4">
        <!-- Expired Clock Badge -->
        <div class="inline-flex p-4 rounded-3xl bg-amber-500/10 border border-amber-500/30 text-amber-400 shadow-xl shadow-amber-500/10">
          <svg class="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>

        <div class="space-y-2">
          <span class="px-3 py-1 rounded-full text-[10px] font-mono font-bold uppercase tracking-widest bg-amber-500/20 text-amber-300 border border-amber-500/30">
            SESSION EXPIRED // 00:00
          </span>
          <h2 class="text-xl sm:text-2xl font-display font-black text-white">
            {{ isEn ? 'Authorization Request Expired' : 'Yêu Cầu Ủy Quyền Đã Hết Hạn' }}
          </h2>
          <p class="text-xs sm:text-sm text-slate-300 leading-relaxed font-normal max-w-md mx-auto">
            {{ isEn 
              ? `This authorization request has exceeded the ${expiryDurationLabel} security limit since the app requested it. Your account was protected and no permissions were granted.` 
              : `Phiên ủy quyền này đã vượt quá thời hạn ${expiryDurationLabel} kể từ khi ứng dụng gửi yêu cầu nhằm bảo vệ an toàn cho tài khoản TXA Studio của bạn.` }}
          </p>
        </div>

        <!-- Action Button -->
        <div class="pt-2 space-y-3">
          <button 
            @click="handleRetryFromApp"
            class="w-full py-3.5 px-6 rounded-2xl bg-gradient-to-r from-amber-500 via-orange-500 to-amber-600 text-slate-950 font-display font-black text-xs uppercase tracking-wider shadow-lg shadow-amber-500/30 hover:shadow-amber-400/50 hover:scale-[1.02] active:scale-95 transition-all"
          >
            {{ isEn ? 'OPEN NEW REQUEST FROM APP' : 'MỞ LẠI YÊU CẦU TỪ ỨNG DỤNG' }}
          </button>
          
          <router-link to="/" class="inline-block text-xs font-mono text-slate-500 hover:text-slate-300 underline">
            ← {{ isEn ? 'Return to Home Portal' : 'Quay về trang chủ TXA Studio' }}
          </router-link>
        </div>
      </div>

      <!-- =================================================================== -->
      <!-- STATE 2: ERROR - INVALID REQUEST / CLIENT NOT FOUND                 -->
      <!-- =================================================================== -->
      <div v-else-if="errorState === 'TXA_ERR_INVALID_CLIENT_OR_PARAMS'" class="space-y-6 text-center py-4">
        <div class="inline-flex p-4 rounded-3xl bg-rose-500/10 border border-rose-500/30 text-rose-400 shadow-xl shadow-rose-500/10">
          <svg class="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
          </svg>
        </div>

        <div class="space-y-2">
          <span class="px-3 py-1 rounded-full text-[10px] font-mono font-bold uppercase tracking-widest bg-rose-500/20 text-rose-300 border border-rose-500/30">
            SECURITY ALERT // INVALID PARAMS
          </span>
          <h2 class="text-xl sm:text-2xl font-display font-black text-white">
            {{ isEn ? 'Invalid Authorization Request' : 'Yêu Cầu Ủy Quyền Không Hợp Lệ' }}
          </h2>
          <p class="text-xs sm:text-sm text-slate-300 leading-relaxed font-normal max-w-md mx-auto">
            {{ isEn 
              ? 'The client application is not recognized in the TXA Studio ecosystem, or the authorization parameters are missing or corrupted.' 
              : 'Ứng dụng gửi yêu cầu (client_id) không tồn tại trên hệ sinh thái TXA Studio hoặc các tham số ủy quyền bị thiếu/sai định dạng.' }}
          </p>
        </div>

        <div class="pt-2 space-y-3">
          <router-link 
            to="/" 
            class="block w-full py-3.5 px-6 rounded-2xl bg-gradient-to-r from-rose-500 to-pink-600 text-white font-display font-black text-xs uppercase tracking-wider shadow-lg shadow-rose-500/30 hover:scale-[1.02] active:scale-95 transition-all text-center"
          >
            {{ isEn ? 'RETURN TO TXA STUDIO HOME' : 'QUAY VỀ TRANG CHỦ TXA STUDIO' }}
          </router-link>
          
          <p class="text-[11px] font-mono text-slate-500">
            {{ isEn ? 'Need help? Contact txasoftdev@gmail.com' : 'Hỗ trợ kỹ thuật: txasoftdev@gmail.com' }}
          </p>
        </div>
      </div>

      <!-- =================================================================== -->
      <!-- STATE 3: ERROR - CODE ALREADY CONSUMED (REPLAY ATTACK PREVENTION)   -->
      <!-- =================================================================== -->
      <div v-else-if="errorState === 'TXA_ERR_CODE_ALREADY_USED'" class="space-y-6 text-center py-4">
        <div class="inline-flex p-4 rounded-3xl bg-purple-500/10 border border-purple-500/30 text-purple-400 shadow-xl shadow-purple-500/10">
          <svg class="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
          </svg>
        </div>

        <div class="space-y-2">
          <span class="px-3 py-1 rounded-full text-[10px] font-mono font-bold uppercase tracking-widest bg-purple-500/20 text-purple-300 border border-purple-500/30">
            SESSION CONSUMED // SINGLE USE
          </span>
          <h2 class="text-xl sm:text-2xl font-display font-black text-white">
            {{ isEn ? 'Session Already Consumed' : 'Mã Phiên Đã Được Xác Nhận Trước Đó' }}
          </h2>
          <p class="text-xs sm:text-sm text-slate-300 leading-relaxed font-normal max-w-md mx-auto">
            {{ isEn 
              ? 'This authorization request has already been granted and consumed to prevent replay attacks. Each session can only be used once.' 
              : 'Yêu cầu ủy quyền này đã được hoàn tất trước đó và đã bị vô hiệu hóa để chống tấn công phát lại (Replay Attack). Mỗi phiên chỉ được cấp quyền một lần duy nhất.' }}
          </p>
        </div>

        <div class="pt-2">
          <button 
            @click="handleRetryFromApp"
            class="w-full py-3.5 px-6 rounded-2xl bg-gradient-to-r from-purple-500 to-indigo-600 text-white font-display font-black text-xs uppercase tracking-wider shadow-lg shadow-purple-500/30 hover:scale-[1.02] active:scale-95 transition-all"
          >
            {{ isEn ? 'OPEN YOUR APP' : 'MỞ LẠI ỨNG DỤNG CỦA BẠN' }}
          </button>
        </div>
      </div>

      <!-- =================================================================== -->
      <!-- STATE 4: SUCCESS - AUTHORIZATION GRANTED                            -->
      <!-- =================================================================== -->
      <div v-else-if="grantedAuthCode" class="space-y-6 text-center py-4">
        <div class="inline-flex p-4 rounded-3xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-400 shadow-xl shadow-emerald-500/10">
          <svg class="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>

        <div class="space-y-2">
          <span class="px-3 py-1 rounded-full text-[10px] font-mono font-bold uppercase tracking-widest bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">
            AUTHORIZED // CONNECTED
          </span>
          <h2 class="text-xl sm:text-2xl font-display font-black text-white">
            {{ isEn ? 'Authorization Successful!' : 'Ủy Quyền Thành Công!' }}
          </h2>
          <p class="text-xs text-slate-300 font-mono">
            {{ isEn ? 'Redirecting back to your app...' : 'Đang tự động chuyển hướng về ứng dụng...' }}
          </p>
        </div>

        <!-- 1-Click Copy Code Fallback -->
        <div class="p-4 rounded-2xl bg-slate-900/90 border border-slate-700/80 text-left space-y-2">
          <div class="flex items-center justify-between text-[11px] font-mono text-slate-400">
            <span>{{ isEn ? 'Fallback Code (If app did not open):' : 'Mã dự phòng (Nếu ứng dụng chưa tự mở):' }}</span>
            <span class="text-emerald-400 font-bold">txa_code_...</span>
          </div>
          <div class="flex items-center gap-2">
            <input 
              type="text" 
              readonly 
              :value="grantedAuthCode" 
              class="flex-1 px-3 py-2 rounded-xl bg-black/60 border border-slate-800 text-cyan-300 font-mono text-xs select-all outline-none"
            />
            <button 
              @click="copyCode"
              class="px-4 py-2 rounded-xl bg-cyan-500/20 hover:bg-cyan-500/30 border border-cyan-500/40 text-cyan-300 text-xs font-mono font-bold transition-all"
            >
              {{ codeCopied ? (isEn ? 'COPIED!' : 'ĐÃ CHÉP!') : (isEn ? 'COPY' : 'SAO CHÉP') }}
            </button>
          </div>
        </div>

        <div>
          <button 
            @click="triggerDeepLink"
            class="w-full py-3.5 px-6 rounded-2xl bg-gradient-to-r from-cyan-400 via-sky-500 to-pink-500 text-slate-950 font-display font-black text-xs uppercase tracking-wider shadow-lg shadow-cyan-500/30 hover:scale-[1.02] active:scale-95 transition-all"
          >
            {{ isEn ? 'TAP HERE TO RETURN TO APP' : 'BẤM VÀO ĐÂY ĐỂ VỀ LẠI ỨNG DỤNG' }}
          </button>
        </div>
      </div>

      <!-- =================================================================== -->
      <!-- STATE 5: GOOGLE-STYLE CONSENT SCREEN                                -->
      <!-- =================================================================== -->
      <div v-else-if="appInfo" class="space-y-6">

        <!-- Top User Identity Bar & Switch Account -->
        <div class="flex items-center justify-between gap-3 p-3.5 rounded-2xl border border-slate-800/80 bg-slate-900/60 text-xs">
          <div class="flex items-center gap-2.5 overflow-hidden">
            <div class="w-8 h-8 rounded-xl bg-gradient-to-tr from-cyan-500 to-pink-500 flex items-center justify-center font-display font-black text-slate-950 shrink-0">
              {{ (currentUser?.display_name || currentUser?.email || 'U')[0].toUpperCase() }}
            </div>
            <div class="truncate">
              <div class="font-bold text-white truncate">{{ currentUser?.display_name || 'Player' }}</div>
              <div class="text-[11px] font-mono text-slate-400 truncate">{{ currentUser?.email }}</div>
            </div>
          </div>

          <button 
            @click="switchAccount"
            class="px-3 py-1.5 rounded-xl border border-slate-700 bg-slate-800/80 hover:bg-slate-700 text-slate-300 hover:text-white font-mono text-[11px] transition-all shrink-0"
          >
            {{ isEn ? 'Switch' : 'Đổi tài khoản' }}
          </button>
        </div>

        <!-- 2-Digit Live Countdown Badge (MM:SS) -->
        <div class="flex items-center justify-center">
          <div 
            class="inline-flex items-center gap-2 px-4 py-1.5 rounded-full border text-xs font-mono font-bold tracking-wider transition-all"
            :class="countdownBadgeClass"
          >
            <span class="w-2 h-2 rounded-full" :class="countdownDotClass"></span>
            <span>{{ isEn ? 'EXPIRES IN:' : 'HẾT HẠN TRONG:' }}</span>
            <span class="text-sm font-black">{{ formattedCountdown }}</span>
          </div>
        </div>

        <!-- App Identification & Verified Badge -->
        <div class="text-center space-y-3 pt-2">
          <div class="inline-flex items-center justify-center w-20 h-20 rounded-3xl border border-cyan-400/40 bg-slate-900/90 shadow-xl shadow-cyan-500/20 p-2 mx-auto">
            <img 
              :src="appInfo.logo_url || '/icons/Icon-512.png'" 
              :alt="appInfo.name" 
              class="w-full h-full object-contain rounded-2xl" 
            />
          </div>

          <div>
            <h1 class="text-xl sm:text-2xl font-display font-black text-white">
              {{ appInfo.name }}
            </h1>
            <p class="text-xs text-slate-400 mt-0.5">
              {{ isEn ? 'wants to access your TXA Studio account' : 'yêu cầu liên kết với tài khoản TXA Studio của bạn' }}
            </p>
          </div>

          <!-- Auto-Granted Verified Badge -->
          <div v-if="appInfo.is_verified" class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/30 text-emerald-400 text-xs font-mono font-bold">
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
            </svg>
            <span>✓ TXA Studio Verified App</span>
          </div>
          <div v-else class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-amber-500/10 border border-amber-500/30 text-amber-400 text-xs font-mono">
            <span>⚠️ App Chưa Qua Kiểm Duyệt</span>
          </div>
        </div>

        <!-- Permission Scopes List -->
        <div class="space-y-3 pt-2">
          <div class="text-[11px] font-mono uppercase tracking-widest text-slate-400 font-bold">
            {{ isEn ? 'This app will be granted:' : 'Quyền hạn ứng dụng yêu cầu:' }}
          </div>

          <div class="space-y-2 text-xs">
            <div class="flex items-start gap-3 p-3 rounded-2xl border border-slate-800 bg-slate-900/40">
              <span class="text-cyan-400 font-bold text-base leading-none">✓</span>
              <div>
                <div class="font-bold text-slate-200">{{ isEn ? 'View Basic Profile' : 'Xem hồ sơ cơ bản' }}</div>
                <div class="text-[11px] text-slate-400">{{ isEn ? 'Display name, avatar, and player identifier.' : 'Tên hiển thị, avatar đại diện và ID người chơi.' }}</div>
              </div>
            </div>

            <div class="flex items-start gap-3 p-3 rounded-2xl border border-slate-800 bg-slate-900/40">
              <span class="text-cyan-400 font-bold text-base leading-none">✓</span>
              <div>
                <div class="font-bold text-slate-200">{{ isEn ? 'Global Leaderboard Sync' : 'Đồng bộ bảng xếp hạng toàn cầu' }}</div>
                <div class="text-[11px] text-slate-400">{{ isEn ? 'Record scores, moves, speed, and star ratings.' : 'Ghi nhận điểm số, số bước đi, thời gian giải và sao chiến thắng.' }}</div>
              </div>
            </div>

            <div class="flex items-start gap-3 p-3 rounded-2xl border border-slate-800 bg-slate-900/40">
              <span class="text-cyan-400 font-bold text-base leading-none">✓</span>
              <div>
                <div class="font-bold text-slate-200">{{ isEn ? 'Cloud Game Save' : 'Lưu trữ tiến trình chơi trên Cloud' }}</div>
                <div class="text-[11px] text-slate-400">{{ isEn ? 'Safely restore puzzles and campaign progress across devices.' : 'Khôi phục màn chơi và mở khóa chiến dịch khi đổi điện thoại.' }}</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Legal Links (Auto-linked from website) -->
        <div class="pt-1 text-center text-[11px] font-mono text-slate-400 space-x-2">
          <span>{{ isEn ? 'By authorizing, you agree to the' : 'Bằng việc xác nhận, bạn đồng ý với' }}</span>
          <a :href="appInfo.privacy_policy_url" target="_blank" class="text-cyan-400 hover:underline">
            {{ isEn ? 'Privacy Policy' : 'Chính Sách Bảo Mật' }}
          </a>
          <span>&</span>
          <a :href="appInfo.terms_url" target="_blank" class="text-cyan-400 hover:underline">
            {{ isEn ? 'Terms of Service' : 'Điều Khoản Game' }}
          </a>
        </div>

        <!-- Action Buttons -->
        <div class="flex items-center gap-3 pt-2">
          <button 
            @click="handleCancel" 
            class="flex-1 py-3.5 px-4 rounded-2xl border border-slate-700 bg-slate-900/80 hover:bg-slate-800 text-slate-300 font-mono text-xs font-bold transition-all"
          >
            {{ isEn ? 'Cancel' : 'Hủy Bỏ' }}
          </button>

          <button 
            @click="handleAuthorize" 
            :disabled="isSubmitting || countdownSeconds <= 0"
            class="flex-2 py-3.5 px-6 rounded-2xl bg-gradient-to-r from-cyan-400 via-sky-500 to-pink-500 text-slate-950 font-display font-black text-xs uppercase tracking-wider shadow-lg shadow-cyan-500/30 hover:shadow-cyan-400/50 hover:scale-[1.02] active:scale-95 transition-all disabled:opacity-50 disabled:pointer-events-none flex items-center justify-center gap-2"
          >
            <span v-if="isSubmitting" class="w-4 h-4 border-2 border-slate-950 border-t-transparent rounded-full animate-spin"></span>
            <span>{{ isSubmitting ? (isEn ? 'AUTHORIZING...' : 'ĐANG XỬ LÝ...') : (isEn ? 'AUTHORIZE ACCESS' : 'XÁC NHẬN ỦY QUYỀN') }}</span>
          </button>
        </div>

      </div>

      <!-- LOADING STATE -->
      <div v-else class="py-16 text-center space-y-4">
        <div class="w-10 h-10 border-3 border-cyan-400 border-t-transparent rounded-full animate-spin mx-auto"></div>
        <p class="text-xs font-mono text-slate-400 tracking-wider">
          {{ isEn ? 'INITIALIZING SECURE SESSION...' : 'ĐANG KHỞI TẠO PHIÊN BẢO MẬT...' }}
        </p>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, inject } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { 
  getCurrentWebUser, 
  clearCurrentWebUser, 
  getOAuthAppInfo, 
  generateOAuthCode,
  getSystemConfigs,
  formatSecondsToHumanLabel
} from '../services/supabase.js';
import { sound } from '../services/sound.js';

const route = useRoute();
const router = useRouter();

const currentLang = inject('currentLang', ref('vi'));
const isEn = computed(() => currentLang.value === 'en');

// In-memory OAuth parameters to prevent URL leakage
const clientId = ref('');
const redirectUri = ref('');
const stateParam = ref('');
const reqId = ref('');

const currentUser = ref(null);
const appInfo = ref(null);
const errorState = ref(null); // 'TXA_ERR_SESSION_EXPIRED', 'TXA_ERR_INVALID_CLIENT_OR_PARAMS', 'TXA_ERR_CODE_ALREADY_USED'
const isSubmitting = ref(false);
const grantedAuthCode = ref('');
const codeCopied = ref(false);

// Live Dynamic Countdown Timer (MM:SS) based on Admin Configured Seconds
const configuredSeconds = ref(300); // Default 300s (05:00)
const countdownSeconds = ref(300);
let timerInterval = null;

const expiryDurationLabel = computed(() => {
  return formatSecondsToHumanLabel(configuredSeconds.value, isEn.value);
});

const formattedCountdown = computed(() => {
  const m = Math.floor(countdownSeconds.value / 60);
  const s = countdownSeconds.value % 60;
  const mm = m < 10 ? '0' + m : '' + m;
  const ss = s < 10 ? '0' + s : '' + s;
  return `${mm}:${ss}`;
});

const countdownBadgeClass = computed(() => {
  if (countdownSeconds.value > 120) {
    return 'bg-cyan-500/10 text-cyan-300 border-cyan-500/30';
  } else if (countdownSeconds.value > 60) {
    return 'bg-amber-500/10 text-amber-300 border-amber-500/30';
  } else {
    return 'bg-rose-500/20 text-rose-300 border-rose-500/50 animate-pulse';
  }
});

const countdownDotClass = computed(() => {
  if (countdownSeconds.value > 120) {
    return 'bg-cyan-400 animate-ping';
  } else if (countdownSeconds.value > 60) {
    return 'bg-amber-400 animate-ping';
  } else {
    return 'bg-rose-500 animate-ping';
  }
});

function startCountdown() {
  stopCountdown();
  timerInterval = setInterval(() => {
    if (countdownSeconds.value > 0) {
      countdownSeconds.value--;
    } else {
      stopCountdown();
      errorState.value = 'TXA_ERR_SESSION_EXPIRED';
      sound.playClick();
    }
  }, 1000);
}

function stopCountdown() {
  if (timerInterval) {
    clearInterval(timerInterval);
    timerInterval = null;
  }
}

onMounted(async () => {
  // 1. Read query parameters into local memory
  clientId.value = (route.query.client_id || '').toString();
  redirectUri.value = (route.query.redirect_uri || '').toString();
  stateParam.value = (route.query.state || '').toString();
  reqId.value = (route.query.req_id || '').toString();

  // 2. URL CLOAKING: Immediately wipe query parameters from browser address bar
  try {
    window.history.replaceState({}, document.title, window.location.pathname);
  } catch (e) {}

  // 3. Validate user authentication
  currentUser.value = getCurrentWebUser();
  if (!currentUser.value) {
    // If not logged in, redirect to login page while preserving original query params
    router.replace({
      path: '/login',
      query: {
        redirect: `/oauth/authorize?client_id=${encodeURIComponent(clientId.value)}&redirect_uri=${encodeURIComponent(redirectUri.value)}&state=${encodeURIComponent(stateParam.value)}`
      }
    });
    return;
  }

  // 4. Validate client_id existence
  if (!clientId.value) {
    errorState.value = 'TXA_ERR_INVALID_CLIENT_OR_PARAMS';
    return;
  }

  try {
    const [app, configs] = await Promise.all([
      getOAuthAppInfo(clientId.value),
      getSystemConfigs()
    ]);

    if (!app) {
      errorState.value = 'TXA_ERR_INVALID_CLIENT_OR_PARAMS';
      return;
    }
    appInfo.value = app;

    // Read dynamic expiry seconds configured by admin (e.g. 360s = 06:00)
    const rawSeconds = configs['oauth_expiry_seconds'] || (configs['oauth_expiry_minutes'] ? configs['oauth_expiry_minutes'] * 60 : 300);
    const parsedSeconds = parseInt(rawSeconds, 10);
    if (!isNaN(parsedSeconds) && parsedSeconds > 0) {
      configuredSeconds.value = parsedSeconds;
      countdownSeconds.value = parsedSeconds;
    }

    // Start the live countdown!
    startCountdown();
  } catch (err) {
    errorState.value = 'TXA_ERR_INVALID_CLIENT_OR_PARAMS';
  }
});

onUnmounted(() => {
  stopCountdown();
});

async function handleAuthorize() {
  if (!currentUser.value || !appInfo.value) return;
  sound.playClick();
  isSubmitting.value = true;

  try {
    const res = await generateOAuthCode(appInfo.value.client_id, currentUser.value.id);
    if (!res?.success) {
      if (res?.error_code === 'TXA_ERR_SESSION_EXPIRED') {
        errorState.value = 'TXA_ERR_SESSION_EXPIRED';
      } else {
        errorState.value = 'TXA_ERR_INVALID_CLIENT_OR_PARAMS';
      }
      return;
    }

    stopCountdown();
    grantedAuthCode.value = res.auth_code;
    sound.playSuccess();

    // Trigger deep link redirect to return to app/game
    triggerDeepLink();

  } catch (err) {
    sound.playClick();
    errorState.value = 'TXA_ERR_INVALID_CLIENT_OR_PARAMS';
  } finally {
    isSubmitting.value = false;
  }
}

function triggerDeepLink() {
  const targetUri = redirectUri.value || (appInfo.value?.redirect_uris?.[0]) || 'txa.zerogrid.quantumshift://oauth/callback';
  const sep = targetUri.includes('?') ? '&' : '?';
  const finalUrl = `${targetUri}${sep}code=${encodeURIComponent(grantedAuthCode.value)}&state=${encodeURIComponent(stateParam.value)}`;
  
  // Try redirecting via window.location.href
  window.location.href = finalUrl;
}

async function copyCode() {
  if (!grantedAuthCode.value) return;
  try {
    await navigator.clipboard.writeText(grantedAuthCode.value);
    codeCopied.value = true;
    sound.playClick();
    setTimeout(() => { codeCopied.value = false; }, 3000);
  } catch (e) {}
}

function switchAccount() {
  sound.playClick();
  clearCurrentWebUser();
  router.push({
    path: '/login',
    query: {
      redirect: `/oauth/authorize?client_id=${encodeURIComponent(clientId.value)}&redirect_uri=${encodeURIComponent(redirectUri.value)}&state=${encodeURIComponent(stateParam.value)}`
    }
  });
}

function handleCancel() {
  sound.playClick();
  router.push('/');
}

function handleRetryFromApp() {
  sound.playClick();
  const targetUri = redirectUri.value || (appInfo.value?.redirect_uris?.[0]);
  if (targetUri && targetUri.includes('://')) {
    const schemeBase = targetUri.split('://')[0] + '://';
    window.location.href = schemeBase;
  } else if (targetUri) {
    window.location.href = targetUri;
  } else {
    router.push('/');
  }
}
</script>
