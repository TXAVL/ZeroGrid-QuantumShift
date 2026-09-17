<template>
  <aside 
    aria-label="TXA Studio Mascot"
    class="fixed bottom-6 right-6 z-[9990] select-none transition-all duration-300 pointer-events-auto"
    :class="{ 'opacity-90 hover:opacity-100': isMinimized }"
  >
    <!-- MINIMIZED BADGE -->
    <div 
      v-if="isMinimized"
      @click="isMinimized = false"
      class="group flex items-center gap-2 px-3.5 py-2 rounded-2xl bg-[#090d1a]/90 backdrop-blur-xl border border-cyan-500/40 shadow-xl shadow-cyan-950/50 hover:border-cyan-400 hover:scale-105 active:scale-95 transition-all cursor-pointer"
      title="Mở mascot TXA-Bot"
    >
      <div class="relative w-7 h-7 rounded-xl bg-gradient-to-tr from-cyan-500 to-pink-500 flex items-center justify-center text-sm shadow-md shadow-cyan-500/30 group-hover:rotate-12 transition-transform">
        🤖
        <span class="absolute -top-1 -right-1 w-2.5 h-2.5 rounded-full bg-emerald-400 border border-slate-950 animate-ping"></span>
        <span class="absolute -top-1 -right-1 w-2.5 h-2.5 rounded-full bg-emerald-400 border border-slate-950"></span>
      </div>
      <span class="text-xs font-mono font-bold text-cyan-300 group-hover:text-white">TXA-Bot</span>
    </div>

    <!-- EXPANDED FLOATING MASCOT -->
    <div 
      v-else 
      class="relative flex flex-col items-center"
      @mouseenter="onMascotHover"
      @mouseleave="onMascotLeave"
    >
      <!-- SPEECH BUBBLE -->
      <transition name="pop">
        <div 
          v-if="showSpeech"
          class="speech-bubble absolute -top-14 right-0 sm:right-2 px-4 py-2 rounded-2xl bg-[#0b1021]/95 border border-cyan-400/40 shadow-xl shadow-cyan-950/60 backdrop-blur-md max-w-[230px] text-xs font-medium text-slate-100 leading-snug z-20 pointer-events-none"
        >
          <div class="flex items-center gap-1.5 font-bold text-[10px] text-cyan-400 font-mono uppercase tracking-wider mb-0.5">
            <span>TXA-Bot</span>
            <span class="w-1.5 h-1.5 rounded-full bg-cyan-400 animate-pulse"></span>
          </div>
          <div>{{ currentSpeechText }}</div>
          <!-- Bubble tail -->
          <div class="bubble-tail absolute -bottom-1.5 right-8 w-3 h-3 bg-[#0b1021] border-r border-b border-cyan-400/40 rotate-45"></div>
        </div>
      </transition>

      <!-- FLOATING SPARKLES / HEARTS ON PET -->
      <div 
        v-for="spark in sparkles" 
        :key="spark.id"
        class="mascot-sparkle absolute pointer-events-none text-base font-bold"
        :style="{ left: `${spark.x}px`, top: `${spark.y}px` }"
      >
        {{ spark.icon }}
      </div>

      <!-- MASCOT BODY & HEAD CONTAINER WITH 3D TILT -->
      <div 
        ref="mascotHeadRef"
        @click="petMascot"
        class="mascot-robot relative cursor-pointer group"
        :style="{
          transform: `perspective(600px) rotateX(${tiltX}deg) rotateY(${tiltY}deg) translateY(${isBouncing ? '-12px' : '0px'})`
        }"
      >
        <!-- Top Antennas -->
        <div class="absolute -top-3.5 left-1/2 -translate-x-1/2 flex items-end justify-center gap-5 pointer-events-none">
          <!-- Left Antenna -->
          <div class="w-1.5 h-4 bg-gradient-to-t from-slate-700 to-cyan-400 rounded-full rotate-[-18deg] shadow-[0_0_8px_#00f0ff]">
            <div class="w-2.5 h-2.5 -ml-0.5 -mt-1 rounded-full bg-cyan-300 border border-slate-900 animate-pulse"></div>
          </div>
          <!-- Right Antenna -->
          <div class="w-1.5 h-4 bg-gradient-to-t from-slate-700 to-pink-500 rounded-full rotate-[18deg] shadow-[0_0_8px_#ff007f]">
            <div class="w-2.5 h-2.5 -ml-0.5 -mt-1 rounded-full bg-pink-400 border border-slate-900 animate-pulse"></div>
          </div>
        </div>

        <!-- Robot Main Head Chassis -->
        <div class="relative w-24 h-24 sm:w-28 sm:h-28 rounded-[28px] p-2 bg-gradient-to-b from-slate-800 via-[#0d1326] to-[#080c1a] border-2 border-cyan-500/40 shadow-[0_10px_30px_rgba(0,240,255,0.25)] group-hover:border-cyan-300 group-hover:shadow-[0_12px_36px_rgba(0,240,255,0.4)] transition-all duration-200">
          
          <!-- Visor Shield Screen -->
          <div class="relative w-full h-full rounded-[22px] bg-[#05070e] border border-slate-800/80 overflow-hidden flex items-center justify-center shadow-inner">
            
            <!-- Visor Gloss Highlight -->
            <div class="absolute top-0 left-0 right-0 h-1/2 bg-gradient-to-b from-white/10 to-transparent rounded-t-[22px] pointer-events-none"></div>

            <!-- Visor Scanlines -->
            <div class="absolute inset-0 bg-[linear-gradient(rgba(0,240,255,0.03)_1px,transparent_1px)] bg-[size:100%_3px] pointer-events-none"></div>

            <!-- EYES CONTAINER -->
            <div class="relative flex items-center justify-center gap-4 sm:gap-5 z-10">
              
              <!-- LEFT EYE -->
              <div class="relative w-6 h-6 sm:w-7 sm:h-7 flex items-center justify-center">
                <!-- 1. Tracking State -->
                <div 
                  v-if="eyeState === 'tracking'"
                  class="eye-socket relative w-full h-full rounded-full bg-cyan-950/60 border border-cyan-500/50 flex items-center justify-center shadow-[0_0_12px_rgba(0,240,255,0.3)] overflow-hidden"
                >
                  <!-- Pupil following cursor -->
                  <div 
                    class="pupil w-3.5 h-3.5 sm:w-4 sm:h-4 rounded-full bg-gradient-to-tr from-cyan-400 to-white shadow-[0_0_10px_#00f0ff] transition-transform duration-75 ease-out"
                    :style="{ transform: `translate3d(${pupilX}px, ${pupilY}px, 0)` }"
                  >
                    <!-- Inner pupil shine -->
                    <div class="w-1.5 h-1.5 bg-white rounded-full ml-1 mt-0.5 opacity-90"></div>
                  </div>
                </div>

                <!-- 2. Blinking State -->
                <div 
                  v-else-if="eyeState === 'blinking'"
                  class="w-5 h-1 bg-cyan-300 rounded-full shadow-[0_0_8px_#00f0ff]"
                ></div>

                <!-- 3. Happy State (^ ^) -->
                <div 
                  v-else-if="eyeState === 'happy'"
                  class="w-5 h-3.5 border-t-3 border-emerald-400 rounded-t-full shadow-[0_0_10px_#00ffa3] scale-110"
                ></div>

                <!-- 4. Surprised / Star State (★ ★) -->
                <div 
                  v-else-if="eyeState === 'surprised'"
                  class="text-pink-400 text-base sm:text-lg animate-spin"
                  style="animation-duration: 3s;"
                >
                  ★
                </div>
              </div>

              <!-- RIGHT EYE -->
              <div class="relative w-6 h-6 sm:w-7 sm:h-7 flex items-center justify-center">
                <!-- 1. Tracking State -->
                <div 
                  v-if="eyeState === 'tracking'"
                  class="eye-socket relative w-full h-full rounded-full bg-cyan-950/60 border border-cyan-500/50 flex items-center justify-center shadow-[0_0_12px_rgba(0,240,255,0.3)] overflow-hidden"
                >
                  <!-- Pupil following cursor -->
                  <div 
                    class="pupil w-3.5 h-3.5 sm:w-4 sm:h-4 rounded-full bg-gradient-to-tr from-cyan-400 to-white shadow-[0_0_10px_#00f0ff] transition-transform duration-75 ease-out"
                    :style="{ transform: `translate3d(${pupilX}px, ${pupilY}px, 0)` }"
                  >
                    <!-- Inner pupil shine -->
                    <div class="w-1.5 h-1.5 bg-white rounded-full ml-1 mt-0.5 opacity-90"></div>
                  </div>
                </div>

                <!-- 2. Blinking State -->
                <div 
                  v-else-if="eyeState === 'blinking'"
                  class="w-5 h-1 bg-cyan-300 rounded-full shadow-[0_0_8px_#00f0ff]"
                ></div>

                <!-- 3. Happy State (^ ^) -->
                <div 
                  v-else-if="eyeState === 'happy'"
                  class="w-5 h-3.5 border-t-3 border-emerald-400 rounded-t-full shadow-[0_0_10px_#00ffa3] scale-110"
                ></div>

                <!-- 4. Surprised / Star State (★ ★) -->
                <div 
                  v-else-if="eyeState === 'surprised'"
                  class="text-pink-400 text-base sm:text-lg animate-spin"
                  style="animation-duration: 3s;"
                >
                  ★
                </div>
              </div>

            </div>

            <!-- Cute Blushing Cheeks (shown on hover or happy) -->
            <div 
              v-if="eyeState === 'happy' || isHovered"
              class="absolute bottom-2.5 left-0 right-0 flex justify-between px-3 pointer-events-none"
            >
              <div class="w-2.5 h-1 bg-pink-500/70 rounded-full blur-[1px]"></div>
              <div class="w-2.5 h-1 bg-pink-500/70 rounded-full blur-[1px]"></div>
            </div>

          </div>

          <!-- Bottom Plasma Thruster Flame (Floating Effect) -->
          <div class="absolute -bottom-3 left-1/2 -translate-x-1/2 flex flex-col items-center pointer-events-none">
            <div class="w-6 h-1.5 rounded-full bg-slate-800 border border-cyan-500/50"></div>
            <div class="plasma-flame w-4 h-3.5 bg-gradient-to-b from-cyan-400 via-sky-500 to-transparent rounded-b-full blur-[1px]"></div>
          </div>

          <!-- Left & Right Floating Hands -->
          <div class="absolute -left-2 top-1/2 -translate-y-1/2 w-2.5 h-5 rounded-full bg-gradient-to-b from-slate-700 to-cyan-500/80 border border-slate-800 shadow-md group-hover:-translate-x-1 transition-transform"></div>
          <div class="absolute -right-2 top-1/2 -translate-y-1/2 w-2.5 h-5 rounded-full bg-gradient-to-b from-slate-700 to-pink-500/80 border border-slate-800 shadow-md group-hover:translate-x-1 transition-transform"></div>

        </div>

        <!-- Quick Minimize Tooltip Button -->
        <button 
          @click.stop="isMinimized = true"
          class="absolute -top-1.5 -right-1.5 w-5 h-5 rounded-full bg-slate-900 border border-slate-700 text-slate-400 hover:text-white hover:border-cyan-400 text-[10px] flex items-center justify-center opacity-0 group-hover:opacity-100 transition-all shadow-md z-30 cursor-pointer"
          title="Thu nhỏ mascot"
        >
          ✕
        </button>
      </div>

    </div>
  </aside>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, inject } from 'vue';
import { sound } from '../services/sound.js';

const currentLang = inject('currentLang', ref('vi'));
const isEn = computed(() => currentLang.value === 'en');

const isMinimized = ref(false);
const mascotHeadRef = ref(null);
const isHovered = ref(false);
const isBouncing = ref(false);

// Eye States: 'tracking' | 'blinking' | 'happy' | 'surprised'
const eyeState = ref('tracking');

// 3D Head Tilt & Pupil Tracking Coordinates
const pupilX = ref(0);
const pupilY = ref(0);
const tiltX = ref(0);
const tiltY = ref(0);

// Speech Bubble & Dialogues
const showSpeech = ref(false);
const currentSpeechIndex = ref(0);
let speechTimer = null;
let blinkInterval = null;

const sparkles = ref([]);
let sparkleCount = 0;

const dialoguesVi = [
  "Chào bạn! Tôi là TXA-Bot 🤖",
  "Đang theo dõi chuột của bạn nè! 👀",
  "Bạn đã thử ZeroGrid & QuantumShift chưa? 🎮",
  "ShieldBlock Pro bảo vệ bạn khỏi ads siêu đỉnh! 🛡️",
  "TXA Cloud Sync sao lưu dữ liệu thần tốc! ☁️",
  "Nhấp vào tôi để nhận năng lượng vui vẻ nào! ✨"
];

const dialoguesEn = [
  "Hello! I am TXA-Bot 🤖",
  "I am watching your cursor! 👀",
  "Have you played ZeroGrid & QuantumShift? 🎮",
  "ShieldBlock Pro keeps your browsing clean! 🛡️",
  "TXA Cloud Sync backups your stats fast! ☁️",
  "Click me for good vibes & energy! ✨"
];

const currentSpeechText = computed(() => {
  const list = isEn.value ? dialoguesEn : dialoguesVi;
  return list[currentSpeechIndex.value % list.length];
});

function triggerNextSpeech() {
  currentSpeechIndex.value++;
  showSpeech.value = true;
  if (speechTimer) clearTimeout(speechTimer);
  speechTimer = setTimeout(() => {
    showSpeech.value = false;
  }, 4500);
}

// Track mouse cursor relative to mascot head center
function handleMouseMove(e) {
  if (isMinimized.value || !mascotHeadRef.value) return;

  const rect = mascotHeadRef.value.getBoundingClientRect();
  const headCenterX = rect.left + rect.width / 2;
  const headCenterY = rect.top + rect.height / 2;

  const dx = e.clientX - headCenterX;
  const dy = e.clientY - headCenterY;
  const distance = Math.hypot(dx, dy);
  const angle = Math.atan2(dy, dx);

  // 1. Pupil Tracking (Max 6px radius)
  const maxPupilOffset = 6;
  const intensity = Math.min(distance / 50, maxPupilOffset);
  pupilX.value = Math.cos(angle) * intensity;
  pupilY.value = Math.sin(angle) * intensity;

  // 2. 3D Head Tilt
  const maxTilt = 18;
  const windowW = window.innerWidth || 1200;
  const windowH = window.innerHeight || 800;

  tiltY.value = Math.max(-maxTilt, Math.min(maxTilt, (dx / windowW) * 35));
  tiltX.value = Math.max(-maxTilt, Math.min(maxTilt, -(dy / windowH) * 30));
}

// React to global click on website
function handleGlobalClick() {
  if (isMinimized.value) return;

  // Temporarily switch to happy eye expression on click
  eyeState.value = 'happy';
  isBouncing.value = true;

  setTimeout(() => {
    isBouncing.value = false;
    if (eyeState.value === 'happy') {
      eyeState.value = 'tracking';
    }
  }, 400);
}

// Natural Blinking
function setupBlink() {
  blinkInterval = setInterval(() => {
    if (eyeState.value === 'tracking') {
      eyeState.value = 'blinking';
      setTimeout(() => {
        if (eyeState.value === 'blinking') {
          eyeState.value = 'tracking';
        }
      }, 160);
    }
  }, 3800 + Math.random() * 2500);
}

// Hover Mascot Event
function onMascotHover() {
  isHovered.value = true;
  eyeState.value = 'surprised';
  triggerNextSpeech();
}

function onMascotLeave() {
  isHovered.value = false;
  eyeState.value = 'tracking';
}

// Pet / Click directly on Mascot
function petMascot(e) {
  sound.playSuccess();
  eyeState.value = 'happy';
  isBouncing.value = true;
  triggerNextSpeech();

  // Spawn floating sparkles
  const icons = ['✨', '❤️', '⭐', '⚡', '🎉'];
  const icon = icons[Math.floor(Math.random() * icons.length)];
  const id = ++sparkleCount;
  const randX = (Math.random() - 0.5) * 60 + 20;
  const randY = (Math.random() - 0.5) * 40;

  sparkles.value.push({ id, icon, x: randX, y: randY });
  setTimeout(() => {
    sparkles.value = sparkles.value.filter(s => s.id !== id);
  }, 1000);

  setTimeout(() => {
    isBouncing.value = false;
    eyeState.value = 'tracking';
  }, 700);
}

onMounted(() => {
  window.addEventListener('mousemove', handleMouseMove, { passive: true });
  window.addEventListener('click', handleGlobalClick, { passive: true });
  setupBlink();

  // Initial friendly welcome speech
  setTimeout(() => {
    showSpeech.value = true;
    speechTimer = setTimeout(() => {
      showSpeech.value = false;
    }, 4500);
  }, 2000);
});

onUnmounted(() => {
  window.removeEventListener('mousemove', handleMouseMove);
  window.removeEventListener('click', handleGlobalClick);
  if (blinkInterval) clearInterval(blinkInterval);
  if (speechTimer) clearTimeout(speechTimer);
});
</script>

<style scoped>
.mascot-robot {
  animation: mascot-float 3.6s ease-in-out infinite;
  transform-style: preserve-3d;
  transition: transform 0.15s ease-out;
}

@keyframes mascot-float {
  0%, 100% {
    transform: translateY(0px);
  }
  50% {
    transform: translateY(-8px);
  }
}

.plasma-flame {
  animation: flame-pulse 1.2s ease-in-out infinite alternate;
}

@keyframes flame-pulse {
  0% {
    height: 10px;
    opacity: 0.7;
    filter: drop-shadow(0 0 4px #00f0ff);
  }
  100% {
    height: 16px;
    opacity: 1;
    filter: drop-shadow(0 0 10px #00f0ff);
  }
}

.mascot-sparkle {
  animation: sparkle-float-up 0.9s cubic-bezier(0.1, 0.8, 0.2, 1) forwards;
}

@keyframes sparkle-float-up {
  0% {
    opacity: 1;
    transform: translateY(0) scale(0.6);
  }
  50% {
    transform: translateY(-25px) scale(1.2);
  }
  100% {
    opacity: 0;
    transform: translateY(-50px) scale(0.8);
  }
}

/* Speech Bubble Transition */
.pop-enter-active,
.pop-leave-active {
  transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
}

.pop-enter-from,
.pop-leave-to {
  opacity: 0;
  transform: scale(0.85) translateY(8px);
}
</style>
