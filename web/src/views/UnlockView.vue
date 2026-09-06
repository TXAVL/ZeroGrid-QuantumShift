<template>
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-10 sm:py-16">
    
    <!-- Top Signal Lock Header -->
    <div class="mb-10 text-left">
      <div class="inline-flex items-center gap-2 text-xs font-mono tracking-widest text-cyan-400 uppercase mb-3">
        <span class="w-2 h-2 rounded-full bg-cyan-400 animate-ping"></span>
        <span>SIGNAL LOCK • PROMOTION CAMPAIGN</span>
      </div>
      <h1 class="text-3xl sm:text-4xl lg:text-5xl font-display font-black text-white tracking-tight leading-tight mb-4">
        {{ isEn ? 'One tap, and 10 Hints is yours for life' : 'Chạm một lần, nhận vĩnh viễn 10 Gợi Ý miễn phí' }}
      </h1>
      <p class="text-slate-400 text-sm sm:text-base max-w-2xl leading-relaxed">
        {{ isEn
          ? 'A playhead sweeps across the trace. Hit Lock while it sits inside the lit window and the page hands you a promo code for 10 Hints. Lifetime — the whole app, forever, no subscription. One round, one code, Android.'
          : 'Vạch quét sẽ chạy qua lại trên biểu đồ sóng lượng tử. Nhấn Lock đúng lúc vạch nằm trong khung sáng và hệ thống sẽ tặng bạn 1 mã kích hoạt gói 10 Gợi Ý trọn đời. Một lượt chơi, một mã, Google Play.'
        }}
      </p>
    </div>

    <!-- Login Gatekeeper: Chỉ khả dụng nếu đã đăng nhập -->
    <div v-if="!currentUser" class="glass-panel border border-cyan-500/30 rounded-3xl p-8 sm:p-12 text-center relative overflow-hidden shadow-2xl shadow-cyan-500/10 mb-12">
      <div class="absolute -top-24 -right-24 w-64 h-64 bg-cyan-500/10 rounded-full blur-3xl pointer-events-none"></div>
      <div class="w-16 h-16 mx-auto rounded-2xl bg-cyan-500/10 border border-cyan-500/30 flex items-center justify-center text-3xl mb-5 text-cyan-400">
        🔐
      </div>
      <h2 class="text-xl sm:text-2xl font-display font-bold text-white mb-2">
        {{ isEn ? 'TXA ID Login Required' : 'Yêu Cầu Đăng Nhập Tài Khoản TXA ID' }}
      </h2>
      <p class="text-slate-400 text-sm max-w-md mx-auto mb-6">
        {{ isEn 
          ? 'Please log in to your TXA ID account to participate in the Signal Lock challenge and claim your exclusive promo code.' 
          : 'Vui lòng đăng nhập tài khoản TXA ID của bạn để tham gia thử thách Signal Lock và nhận mã khuyến mãi độc quyền.' 
        }}
      </p>
      <div class="flex flex-col sm:flex-row items-center justify-center gap-3">
        <router-link
          to="/login?redirect=/unlock"
          class="w-full sm:w-auto px-6 py-3 rounded-xl bg-cyan-400 hover:bg-cyan-300 text-slate-950 font-bold text-sm transition-all shadow-lg shadow-cyan-400/20"
        >
          {{ isEn ? 'Sign in with TXA ID' : 'Đăng nhập ngay' }}
        </router-link>
        <router-link
          to="/register?redirect=/unlock"
          class="w-full sm:w-auto px-6 py-3 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-200 font-medium text-sm transition-all border border-slate-700"
        >
          {{ isEn ? 'Create free account' : 'Tạo tài khoản mới' }}
        </router-link>
      </div>
    </div>

    <!-- MAIN INTERACTIVE CONTAINER (When logged in) -->
    <div v-else class="glass-panel border border-slate-800 rounded-3xl p-6 sm:p-8 relative overflow-hidden shadow-2xl mb-12 bg-[#0a0f1d]/90">
      
      <!-- STAGE 1: SIGNAL LOCK MINI-GAME (Screenshot 1) -->
      <div v-if="stage === 1" class="space-y-6">
        <div class="flex items-center justify-between text-xs font-mono text-slate-400 border-b border-slate-800/80 pb-3">
          <span class="tracking-widest uppercase text-slate-500 font-bold">
            {{ isEn ? 'ONE ROUND' : 'LƯỢT THỬ THÁCH' }}
          </span>
          <span class="text-slate-400 flex items-center gap-1.5">
            <span class="hidden sm:inline">{{ isEn ? 'Tap the trace or press space' : 'Chạm vào khung sóng hoặc phím Space' }}</span>
            <kbd class="px-1.5 py-0.5 rounded bg-slate-800 text-[10px] text-slate-300 border border-slate-700">Space</kbd>
          </span>
        </div>

        <!-- Wave Canvas Area -->
        <div 
          class="relative w-full h-44 sm:h-52 bg-[#060913] rounded-2xl border border-slate-800/90 overflow-hidden cursor-crosshair select-none"
          @click="handleLockClick"
        >
          <canvas ref="canvasRef" class="w-full h-full block"></canvas>
          
          <!-- Hit Flash Effect -->
          <div 
            v-if="flashHit" 
            class="absolute inset-0 bg-cyan-400/20 pointer-events-none transition-opacity duration-300"
          ></div>
          <div 
            v-if="flashMiss" 
            class="absolute inset-0 bg-rose-500/20 pointer-events-none transition-opacity duration-300"
          ></div>
        </div>

        <!-- Status / Feedback line -->
        <div class="text-center min-h-[24px]">
          <p v-if="attemptCount === 0" class="text-xs sm:text-sm text-slate-400 font-mono">
            {{ isEn 
              ? 'The window is lit. Hit Lock when the playhead is inside it.' 
              : 'Khung sáng đã bật. Hãy bấm LOCK khi vạch quét chạy vào bên trong khung.' 
            }}
          </p>
          <p v-else class="text-xs sm:text-sm font-mono text-amber-400 animate-pulse">
            {{ isEn
              ? `Missed! Attempt #${attemptCount}. Window relocated — try again!`
              : `Chưa trúng! Lần thử thứ #${attemptCount}. Khung sáng đã đổi vị trí — hãy canh lại!`
            }}
          </p>
        </div>

        <!-- Big Lock Button -->
        <button
          @click="handleLockClick"
          class="w-full py-3.5 sm:py-4 rounded-2xl bg-white hover:bg-slate-100 text-slate-950 font-display font-black text-sm sm:text-base uppercase tracking-widest transition-all duration-150 hover:scale-[1.01] active:scale-95 shadow-xl shadow-white/10 flex items-center justify-center gap-2"
        >
          <span>LOCK</span>
        </button>
      </div>

      <!-- STAGE 2: PLATFORM SELECTION (Screenshot 2) -->
      <div v-else-if="stage === 2" class="space-y-6 py-4">
        <div>
          <h2 class="text-xl sm:text-2xl font-display font-bold text-white mb-2">
            {{ isEn ? 'Locked. Where do you use Zero Grid?' : 'Đã khóa tín hiệu! Bạn chơi Zero Grid trên nền tảng nào?' }}
          </h2>
          <p class="text-slate-400 text-xs sm:text-sm">
            {{ isEn 
              ? 'The two stores use completely different codes, so pick the one you actually installed the app from.' 
              : 'Hai kho ứng dụng dùng định dạng mã hoàn toàn khác nhau, hãy chọn đúng kho ứng dụng bạn đã cài đặt game.' 
            }}
          </p>
        </div>

        <!-- Platform Cards Grid -->
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          
          <!-- App Store Card (Coming Soon) -->
          <div 
            class="relative rounded-2xl border border-slate-800 bg-slate-900/40 p-5 opacity-60 cursor-not-allowed select-none transition-all flex flex-col justify-between"
          >
            <div class="flex items-start justify-between mb-6">
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-xl bg-slate-800 flex items-center justify-center text-white text-xl">
                  
                </div>
                <div>
                  <h3 class="text-white font-bold text-base">App Store</h3>
                  <p class="text-slate-400 text-xs font-mono">iPhone • iPad</p>
                </div>
              </div>
              <span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-amber-500/10 text-amber-400 border border-amber-500/30 uppercase tracking-wide">
                {{ isEn ? 'COMING SOON' : 'SẮP RA MẮT' }}
              </span>
            </div>
            <p class="text-[11px] text-slate-500 font-mono">
              {{ isEn ? 'iOS version is currently in final App Store review.' : 'Bản iOS đang trong giai đoạn duyệt cuối trên App Store.' }}
            </p>
          </div>

          <!-- Google Play Card (Active) -->
          <button 
            @click="selectPlatform('android')"
            class="group text-left rounded-2xl border border-cyan-500/40 hover:border-cyan-400 bg-cyan-500/5 hover:bg-cyan-500/10 p-5 cursor-pointer transition-all duration-200 hover:scale-[1.02] active:scale-95 shadow-lg shadow-cyan-500/10 hover:shadow-cyan-500/20 flex flex-col justify-between"
          >
            <div class="flex items-start justify-between mb-6">
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-xl bg-gradient-to-tr from-cyan-500 to-emerald-400 flex items-center justify-center text-slate-950 font-black text-xl shadow-md">
                  ▶
                </div>
                <div>
                  <h3 class="text-white group-hover:text-cyan-400 font-bold text-base transition-colors">
                    Google Play
                  </h3>
                  <p class="text-slate-400 text-xs font-mono">Android & PC</p>
                </div>
              </div>
              <span class="px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-emerald-500/10 text-emerald-400 border border-emerald-500/30 uppercase tracking-wide">
                {{ isEn ? 'AVAILABLE' : 'KHẢ DỤNG' }}
              </span>
            </div>
            <div class="flex items-center justify-between text-xs font-mono text-cyan-400 font-bold">
              <span>{{ isEn ? 'Claim Promo Code' : 'Nhận Mã Ngay' }}</span>
              <span class="group-hover:translate-x-1 transition-transform">→</span>
            </div>
          </button>

        </div>
      </div>

      <!-- STAGE 3: CODE PRESENTATION (Screenshot 3) -->
      <div v-else-if="stage === 3" class="space-y-6 text-center py-2">
        <div class="text-xs font-mono tracking-widest uppercase text-slate-400">
          GOOGLE PLAY • ANDROID
        </div>
        <h2 class="text-2xl sm:text-3xl font-display font-black text-white">
          {{ isEn ? 'Zero Grid: 10 Hints, on us.' : 'Zero Grid: 10 Gợi Ý miễn phí từ chúng tôi.' }}
        </h2>

        <!-- Code Box Container -->
        <div class="rounded-2xl border border-dashed border-cyan-500/40 bg-slate-950/80 p-6 sm:p-8 relative">
          <!-- Loading State -->
          <div v-if="isLoadingCode" class="py-6 flex flex-col items-center justify-center gap-3">
            <div class="w-8 h-8 border-2 border-cyan-400 border-t-transparent rounded-full animate-spin"></div>
            <span class="text-xs font-mono text-cyan-400">
              {{ isEn ? 'Contacting vault & acquiring unique token...' : 'Đang kết nối kho mã & cấp token độc nhất...' }}
            </span>
          </div>

          <!-- Error / Out of Codes -->
          <div v-else-if="promoError" class="py-4 text-rose-400 font-mono text-sm">
            <p class="font-bold mb-1">⚠️ {{ promoError }}</p>
            <p class="text-xs text-slate-400">
              {{ isEn ? 'All 20 codes of this batch have been claimed.' : 'Toàn bộ 20 mã đợt này đã được phát hết. Hãy theo dõi các đợt tặng tiếp theo!' }}
            </p>
          </div>

          <!-- Active Code Display -->
          <div v-else class="space-y-3">
            <div class="font-mono text-xl sm:text-2xl lg:text-3xl font-black text-cyan-300 tracking-wider select-all break-all">
              {{ claimedCode }}
            </div>
            <div v-if="isReclaimed" class="text-[11px] font-mono text-amber-400/90">
              {{ isEn 
                ? 'ℹ️ You already claimed this code previously. Returning your assigned token.' 
                : 'ℹ️ Bạn đã nhận mã này trước đó. Hệ thống hiển thị lại đúng mã của bạn.' 
              }}
            </div>
          </div>
        </div>

        <!-- Buttons: Copy & Open Store -->
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <button
            @click="copyCode"
            :disabled="!claimedCode || isLoadingCode"
            class="py-3.5 rounded-xl font-display font-black text-xs sm:text-sm uppercase tracking-wider transition-all duration-150 flex items-center justify-center gap-2"
            :class="isCopied 
              ? 'bg-emerald-400 text-slate-950 shadow-lg shadow-emerald-400/30' 
              : 'bg-white hover:bg-slate-100 text-slate-950 shadow-lg shadow-white/10 active:scale-95'"
          >
            <span>{{ isCopied ? '✓' : '📋' }}</span>
            <span>{{ isCopied ? (isEn ? 'COPIED TO CLIPBOARD' : 'ĐÃ SAO CHÉP MÃ') : (isEn ? 'COPY CODE' : 'SAO CHÉP MÃ') }}</span>
          </button>

          <a
            :href="redeemUrl"
            target="_blank"
            rel="noopener noreferrer"
            class="py-3.5 rounded-xl border border-slate-700 hover:border-slate-500 bg-slate-900/80 hover:bg-slate-800 text-white font-display font-black text-xs sm:text-sm uppercase tracking-wider transition-all duration-150 flex items-center justify-center gap-2 active:scale-95"
          >
            <span>▶</span>
            <span>{{ isEn ? 'OPEN THE STORE' : 'KÍCH HOẠT TRÊN GOOGLE PLAY' }}</span>
          </a>
        </div>

        <!-- Connection Notice & Re-roll / Reset Code Option -->
        <div class="pt-2 text-xs font-mono text-slate-500 space-y-2">
          <p>
            {{ isEn
              ? 'This connection has already taken its codes. Let someone else have a turn.'
              : 'Thiết bị & tài khoản này đã được gán mã thành công.'
            }}
          </p>

          <!-- Re-roll option: Nếu người dùng muốn xin cấp lại mã mới -->
          <div v-if="claimedCode && !isLoadingCode" class="pt-2">
            <button
              @click="handleReRollCode"
              class="text-[11px] text-slate-400 hover:text-cyan-400 underline underline-offset-4 transition-colors"
            >
              {{ isEn ? 'Need to re-roll a new code?' : 'Mã gặp sự cố? Bấm vào đây để xin cấp lại mã mới' }}
            </button>
          </div>
        </div>

        <!-- Return to platform selection -->
        <div class="pt-4">
          <button
            @click="stage = 2"
            class="px-4 py-2 rounded-full border border-slate-800 hover:border-slate-700 bg-slate-900/60 hover:bg-slate-800 text-xs font-mono text-slate-400 hover:text-white transition-all"
          >
            {{ isEn ? 'I need the other store' : 'Chọn nền tảng khác' }}
          </button>
        </div>
      </div>

    </div>

    <!-- THE FINE PRINT (Screenshot 4) -->
    <div class="border-t border-slate-800/80 pt-8 mt-12 text-left space-y-4">
      <h3 class="text-xl sm:text-2xl font-display font-bold text-white tracking-tight">
        The fine print
      </h3>
      <p class="text-xs sm:text-sm text-slate-400 leading-relaxed font-sans">
        {{ isEn
          ? 'The Android code is single-use and yours alone — the server takes one off the top of the pile, writes down that it is gone, and never hands it out twice. Play it again and you get the same code back, not a second one. The iPhone code is a single shared offer code, so it is the same string for everybody; it stops working when the offer runs out.'
          : 'Mã Android là loại sử dụng một lần và thuộc về riêng bạn — máy chủ chọn ngẫu nhiên một mã từ kho, ghi nhận và không bao giờ phát lại cho người khác. Nếu bạn quay lại trang này, hệ thống sẽ trả lại đúng mã bạn đã nhận. Mã iPhone sẽ được cập nhật khi game ra mắt chính thức trên App Store.'
        }}
      </p>
      <p class="text-xs sm:text-sm text-slate-400 leading-relaxed font-sans">
        {{ isEn
          ? 'Nothing about this page is a lottery. The window is wide enough that a second or third try clears it, and losing costs you nothing but another sweep of the playhead.'
          : 'Trò chơi này không phải là trò may rủi hay xổ số. Khung sáng đủ rộng để bạn có thể canh trúng sau 1 hoặc 2 lượt thử, và nếu trượt bạn chỉ cần đợi vạch quét đi qua thêm một vòng.'
        }}
      </p>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, inject, onMounted, onUnmounted, nextTick } from 'vue';
import { getCurrentWebUser, claimPromotionCode, resetClaimedPromotionCode } from '../services/supabase.js';

const currentLang = inject('currentLang', ref('vi'));
const isEn = computed(() => currentLang.value === 'en');

const currentUser = ref(getCurrentWebUser());

// Stages: 1 = Mini-game, 2 = Platform Selection, 3 = Code Presentation
const stage = ref(1);

// Mini-game State
const canvasRef = ref(null);
let animationFrameId = null;

let playheadPos = 0.0; // 0.0 to 1.0
let playheadSpeed = 0.007; // Speed of horizontal sweeping
let direction = 1;

// Lit window boundaries (0.0 to 1.0)
let windowStart = 0.35;
let windowWidth = 0.22;

const flashHit = ref(false);
const flashMiss = ref(false);
const attemptCount = ref(0);

// Code State
const selectedPlatform = ref('android');
const isLoadingCode = ref(false);
const claimedCode = ref('');
const isReclaimed = ref(false);
const promoError = ref('');
const isCopied = ref(false);

const redeemUrl = computed(() => {
  if (!claimedCode.value) return 'https://play.google.com/store/apps/details?id=txa.zerogrid.quantumshift';
  return `https://play.google.com/redeem?code=${encodeURIComponent(claimedCode.value)}`;
});

function randomizeWindow() {
  windowWidth = 0.20 + Math.random() * 0.08;
  windowStart = 0.12 + Math.random() * (0.88 - windowWidth);
}

function drawCanvas() {
  const canvas = canvasRef.value;
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  if (!ctx) return;

  const w = canvas.width;
  const h = canvas.height;

  // Clear
  ctx.fillStyle = '#060913';
  ctx.fillRect(0, 0, w, h);

  // Subtle grid lines
  ctx.strokeStyle = 'rgba(30, 41, 59, 0.4)';
  ctx.lineWidth = 1;
  for (let x = 0; x < w; x += 40) {
    ctx.beginPath();
    ctx.moveTo(x, 0);
    ctx.lineTo(x, h);
    ctx.stroke();
  }

  // Draw Lit Window Box
  const winX = windowStart * w;
  const winW = windowWidth * w;

  // Lit window background glow
  const gradient = ctx.createLinearGradient(winX, 0, winX + winW, 0);
  gradient.addColorStop(0, 'rgba(0, 229, 255, 0.05)');
  gradient.addColorStop(0.5, 'rgba(0, 229, 255, 0.16)');
  gradient.addColorStop(1, 'rgba(0, 229, 255, 0.05)');
  ctx.fillStyle = gradient;
  ctx.fillRect(winX, 0, winW, h);

  // Lit window dashed borders
  ctx.strokeStyle = 'rgba(0, 229, 255, 0.7)';
  ctx.lineWidth = 1.5;
  ctx.setLineDash([6, 6]);
  ctx.beginPath();
  ctx.moveTo(winX, 0);
  ctx.lineTo(winX, h);
  ctx.moveTo(winX + winW, 0);
  ctx.lineTo(winX + winW, h);
  ctx.stroke();
  ctx.setLineDash([]);

  // Draw Sine Wave Trace Curve
  ctx.strokeStyle = 'rgba(255, 255, 255, 0.45)';
  ctx.lineWidth = 2.0;
  ctx.beginPath();
  const centerY = h / 2;
  const amplitude = h * 0.28;
  const freq = (Math.PI * 3.5) / w;

  for (let x = 0; x <= w; x += 3) {
    const y = centerY + Math.sin(x * freq) * amplitude;
    if (x === 0) ctx.moveTo(x, y);
    else ctx.lineTo(x, y);
  }
  ctx.stroke();

  // Highlight wave inside lit window
  ctx.strokeStyle = 'rgba(0, 229, 255, 0.95)';
  ctx.lineWidth = 3.0;
  ctx.beginPath();
  let first = true;
  for (let x = Math.floor(winX); x <= Math.ceil(winX + winW); x += 2) {
    const y = centerY + Math.sin(x * freq) * amplitude;
    if (first) {
      ctx.moveTo(x, y);
      first = false;
    } else {
      ctx.lineTo(x, y);
    }
  }
  ctx.stroke();

  // Update playhead position (oscillate back and forth smoothly)
  playheadPos += playheadSpeed * direction;
  if (playheadPos >= 1.0) {
    playheadPos = 1.0;
    direction = -1;
  } else if (playheadPos <= 0.0) {
    playheadPos = 0.0;
    direction = 1;
  }

  // Draw Playhead vertical line & glowing dot
  const phX = playheadPos * w;
  const phY = centerY + Math.sin(phX * freq) * amplitude;

  // Playhead line
  ctx.strokeStyle = 'rgba(255, 255, 255, 0.9)';
  ctx.lineWidth = 1.5;
  ctx.beginPath();
  ctx.moveTo(phX, 0);
  ctx.lineTo(phX, h);
  ctx.stroke();

  // Playhead dot with glow
  ctx.shadowColor = '#00e5ff';
  ctx.shadowBlur = 14;
  ctx.fillStyle = '#ffffff';
  ctx.beginPath();
  ctx.arc(phX, phY, 5.5, 0, Math.PI * 2);
  ctx.fill();
  ctx.shadowBlur = 0; // reset

  animationFrameId = requestAnimationFrame(drawCanvas);
}

function handleLockClick() {
  if (stage.value !== 1) return;

  const currentX = playheadPos;
  const winEnd = windowStart + windowWidth;

  if (currentX >= windowStart && currentX <= winEnd) {
    // SUCCESS!
    flashHit.value = true;
    setTimeout(() => {
      flashHit.value = false;
      stage.value = 2; // Move to platform selection
    }, 280);
  } else {
    // MISS!
    flashMiss.value = true;
    attemptCount.value++;
    randomizeWindow();
    setTimeout(() => {
      flashMiss.value = false;
    }, 280);
  }
}

function handleKeyDown(e) {
  if (stage.value === 1 && e.code === 'Space') {
    e.preventDefault();
    handleLockClick();
  }
}

async function selectPlatform(platform) {
  selectedPlatform.value = platform;
  stage.value = 3;
  await fetchPromoCode();
}

async function fetchPromoCode() {
  isLoadingCode.value = true;
  promoError.value = '';
  try {
    const user = currentUser.value;
    const res = await claimPromotionCode({
      campaign: '10_hints_free_1',
      platform: selectedPlatform.value,
      userId: user?.id || user?.user_id,
      email: user?.email
    });

    if (res?.success && res?.code) {
      claimedCode.value = res.code;
      isReclaimed.value = Boolean(res.is_reclaimed);
    } else {
      promoError.value = res?.message || 'Không thể lấy mã khuyến mãi.';
    }
  } catch (err) {
    promoError.value = err.message || 'Lỗi kết nối máy chủ.';
  } finally {
    isLoadingCode.value = false;
  }
}

async function handleReRollCode() {
  if (!confirm(isEn.value ? 'Are you sure you want to re-roll and get a new promo code?' : 'Bạn có chắc chắn muốn hủy mã cũ và xin cấp 1 mã mới ngẫu nhiên không?')) {
    return;
  }

  isLoadingCode.value = true;
  promoError.value = '';
  try {
    const user = currentUser.value;
    const res = await resetClaimedPromotionCode({
      campaign: '10_hints_free_1',
      platform: selectedPlatform.value,
      userId: user?.id || user?.user_id
    });

    if (res?.success && res?.code) {
      claimedCode.value = res.code;
      isReclaimed.value = false;
      alert(isEn.value ? 'New promo code successfully issued!' : 'Đã cấp mã khuyến mãi mới thành công!');
    } else {
      promoError.value = res?.message || 'Không thể cấp lại mã.';
    }
  } catch (err) {
    promoError.value = err.message || 'Lỗi kết nối máy chủ.';
  } finally {
    isLoadingCode.value = false;
  }
}

function copyCode() {
  if (!claimedCode.value) return;
  navigator.clipboard.writeText(claimedCode.value).then(() => {
    isCopied.value = true;
    setTimeout(() => {
      isCopied.value = false;
    }, 2500);
  }).catch(() => {
    // Fallback
    const input = document.createElement('input');
    input.value = claimedCode.value;
    document.body.appendChild(input);
    input.select();
    document.execCommand('copy');
    document.body.removeChild(input);
    isCopied.value = true;
    setTimeout(() => {
      isCopied.value = false;
    }, 2500);
  });
}

function initCanvas() {
  const canvas = canvasRef.value;
  if (!canvas) return;

  const rect = canvas.getBoundingClientRect();
  canvas.width = rect.width * (window.devicePixelRatio || 1);
  canvas.height = rect.height * (window.devicePixelRatio || 1);

  randomizeWindow();
  drawCanvas();
}

function onAuthChange() {
  currentUser.value = getCurrentWebUser();
}

onMounted(() => {
  window.addEventListener('txa-auth-change', onAuthChange);
  window.addEventListener('keydown', handleKeyDown);

  if (currentUser.value) {
    nextTick(() => {
      initCanvas();
    });
  }
});

onUnmounted(() => {
  window.removeEventListener('txa-auth-change', onAuthChange);
  window.removeEventListener('keydown', handleKeyDown);
  if (animationFrameId) {
    cancelAnimationFrame(animationFrameId);
  }
});
</script>

<style scoped>
.font-display {
  font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}
</style>
