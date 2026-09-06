<template>
  <header class="sticky top-0 z-50 glass-panel border-b border-slate-800/80 transition-all duration-300">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-20 flex items-center justify-between">
      
      <!-- Brand Logo -->
      <router-link 
        to="/" 
        class="flex items-center space-x-3.5 group cursor-pointer"
        @click="sound.playClick()"
        @mouseenter="sound.playHover()"
      >
        <div class="relative w-11 h-11 rounded-xl bg-gradient-to-tr from-cyan-400 via-sky-500 to-pink-500 p-[2px] shadow-lg shadow-cyan-500/20 group-hover:shadow-cyan-400/40 group-hover:scale-105 transition-all duration-300">
          <div class="w-full h-full bg-[#070b16] rounded-[10px] flex items-center justify-center font-display font-black text-cyan-400 text-xl tracking-wider">
            T
          </div>
          <!-- Corner Cyber Blips -->
          <div class="absolute -top-1 -right-1 w-2 h-2 bg-pink-500 rounded-full animate-ping opacity-75"></div>
        </div>

        <div>
          <div class="flex items-center gap-2">
            <span class="font-display font-black tracking-wider text-lg text-white group-hover:text-cyan-400 transition-colors">
              TXA STUDIO
            </span>
            <span class="text-[9px] font-mono px-2 py-0.5 rounded-full bg-cyan-500/10 text-cyan-400 border border-cyan-500/30 uppercase tracking-widest">
              Live v1.5.0
            </span>
          </div>
          <div class="text-[11px] text-slate-400 font-mono tracking-tight flex items-center gap-1.5">
            <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse"></span>
            <span>SYSTEM ONLINE</span>
          </div>
        </div>
      </router-link>

      <!-- Desktop Navigation Menu -->
      <nav class="hidden md:flex items-center space-x-1 lg:space-x-2">
        <router-link 
          to="/" 
          class="px-3.5 py-2 rounded-lg text-sm font-medium transition-all duration-200"
          :class="$route.path === '/' ? 'text-cyan-400 bg-cyan-500/10 border border-cyan-500/30 shadow-neon-cyan' : 'text-slate-300 hover:text-white hover:bg-slate-800/50'"
          @mouseenter="sound.playHover()"
          @click="sound.playClick()"
        >
          {{ isEn ? 'Home' : 'Trang Chủ' }}
        </router-link>

        <a 
          href="/#showcase" 
          class="px-3.5 py-2 rounded-lg text-sm font-medium text-slate-300 hover:text-cyan-400 hover:bg-slate-800/50 transition-all duration-200 flex items-center gap-1.5"
          @mouseenter="sound.playHover()"
          @click="sound.playClick()"
        >
          <span class="w-2 h-2 rounded-full bg-pink-500"></span>
          <span>Zero Grid Game</span>
        </a>

        <router-link 
          to="/privacy" 
          class="px-3.5 py-2 rounded-lg text-sm font-medium transition-all duration-200"
          :class="$route.path.startsWith('/privacy') ? 'text-cyan-400 bg-cyan-500/10 border border-cyan-500/30' : 'text-slate-300 hover:text-white hover:bg-slate-800/50'"
          @mouseenter="sound.playHover()"
          @click="sound.playClick()"
        >
          {{ isEn ? 'Privacy Policy' : 'Quyền Riêng Tư' }}
        </router-link>

        <router-link 
          to="/delete-account" 
          class="px-3.5 py-2 rounded-lg text-sm font-medium transition-all duration-200"
          :class="$route.path.startsWith('/delete-account') ? 'text-pink-400 bg-pink-500/10 border border-pink-500/30 shadow-neon-pink' : 'text-slate-300 hover:text-pink-400 hover:bg-pink-500/10'"
          @mouseenter="sound.playHover()"
          @click="sound.playClick()"
        >
          {{ isEn ? 'Delete Account' : 'Xóa Tài Khoản' }}
        </router-link>

        <router-link 
          to="/terms" 
          class="px-3.5 py-2 rounded-lg text-sm font-medium transition-all duration-200"
          :class="$route.path.startsWith('/terms') ? 'text-cyan-400 bg-cyan-500/10 border border-cyan-500/30' : 'text-slate-300 hover:text-white hover:bg-slate-800/50'"
          @mouseenter="sound.playHover()"
          @click="sound.playClick()"
        >
          {{ isEn ? 'Terms' : 'Điều Khoản' }}
        </router-link>

        <!-- Unlock Promo / Mở Khóa Gói 10 Hints -->
        <router-link 
          to="/unlock" 
          class="px-3.5 py-2 rounded-xl text-sm font-medium transition-all duration-200 flex items-center gap-1.5 border"
          :class="$route.path.startsWith('/unlock') 
            ? 'text-emerald-300 bg-emerald-500/20 border-emerald-400 shadow-neon-green' 
            : 'text-emerald-400 border-emerald-500/30 bg-emerald-500/10 hover:bg-emerald-500/20 hover:border-emerald-400'"
          @mouseenter="sound.playHover()"
          @click="sound.playClick()"
        >
          <span>🎁</span>
          <span>{{ isEn ? 'Unlock 10 Hints' : 'Mở Khóa Gói' }}</span>
        </router-link>

        <!-- Admin Only Menu: Admin Dashboard & API Docs -->
        <template v-if="isAdmin">
          <router-link 
            to="/admin" 
            class="px-3 py-1.5 rounded-lg text-xs font-mono font-bold transition-all duration-200 border border-pink-500/40 bg-pink-500/10 text-pink-300 hover:bg-pink-500/20 flex items-center gap-1.5"
            :class="$route.path.startsWith('/admin') ? 'ring-1 ring-pink-400' : ''"
            @mouseenter="sound.playHover()"
            @click="sound.playClick()"
          >
            <span>🛡️ Admin</span>
          </router-link>

          <router-link 
            to="/docs" 
            class="px-3 py-1.5 rounded-lg text-xs font-mono font-bold transition-all duration-200 border"
            :class="$route.path.startsWith('/docs') ? 'text-cyan-300 bg-cyan-500/20 border-cyan-500/40' : 'text-slate-400 border-slate-800 hover:text-cyan-300 hover:border-slate-700'"
            @mouseenter="sound.playHover()"
            @click="sound.playClick()"
          >
            📖 API Docs
          </router-link>
        </template>

        <!-- Account Pill & Session Actions -->
        <div v-if="currentUser" class="flex items-center gap-2 pl-1">
          <div class="hidden xl:flex items-center gap-1.5 px-2.5 py-1 rounded-lg border border-slate-800 bg-slate-900/90 text-xs font-mono text-slate-300">
            <span class="w-1.5 h-1.5 rounded-full" :class="isAdmin ? 'bg-pink-400 animate-pulse' : 'bg-cyan-400'"></span>
            <span class="truncate max-w-[120px]">{{ currentUser.display_name || currentUser.email }}</span>
          </div>
          <button 
            @click="handleLogout"
            class="px-2.5 py-1.5 rounded-lg text-xs font-mono font-medium text-slate-400 hover:text-rose-400 hover:bg-rose-500/10 border border-slate-800 hover:border-rose-500/30 transition-all"
            title="Đăng xuất khỏi tài khoản"
          >
            {{ isEn ? 'Logout' : 'Thoát' }}
          </button>
        </div>

        <router-link 
          v-else
          to="/login" 
          class="px-3 py-1.5 rounded-lg text-xs font-mono font-bold transition-all duration-200 border border-cyan-500/40 bg-cyan-500/10 text-cyan-300 hover:bg-cyan-500/20"
          @mouseenter="sound.playHover()"
          @click="sound.playClick()"
        >
          TXA ID
        </router-link>
      </nav>

      <!-- Action Controls: Audio FX & Lang & CTA -->
      <div class="flex items-center space-x-2.5 sm:space-x-3">
        <!-- Audio Mute/Unmute Toggle -->
        <button 
          @click="toggleAudio"
          class="p-2.5 rounded-xl border transition-all text-xs flex items-center gap-1.5 font-mono"
          :class="isMuted ? 'border-slate-800 bg-slate-900/60 text-slate-500 hover:text-slate-300' : 'border-cyan-500/30 bg-cyan-500/10 text-cyan-400 shadow-neon-cyan'"
          title="Bật/Tắt hiệu ứng âm thanh Sci-Fi"
        >
          <svg v-if="!isMuted" class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.536 8.464a5 5 0 010 7.072m2.828-9.9a9 9 0 010 12.728M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" />
          </svg>
          <svg v-else class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z M17 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2" />
          </svg>
          <span class="hidden sm:inline text-[11px]">{{ isMuted ? 'MUTE' : 'SFX' }}</span>
        </button>

        <!-- Language Switcher -->
        <button 
          @click="toggleLanguage"
          @mouseenter="sound.playHover()"
          class="px-2.5 py-1.5 rounded-xl border border-slate-800 bg-slate-900/80 hover:border-cyan-500/40 text-xs font-mono font-bold text-slate-300 hover:text-white transition-all flex items-center gap-1.5"
        >
          <span :class="currentLang === 'vi' ? 'text-cyan-400 font-extrabold' : 'text-slate-500'">VI</span>
          <span class="text-slate-600">/</span>
          <span :class="currentLang === 'en' ? 'text-pink-400 font-extrabold' : 'text-slate-500'">EN</span>
        </button>

        <!-- Play Store / Platform Dispatch CTA -->
        <button 
          @click="openDownloadModal()"
          class="hidden sm:inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-gradient-to-r from-cyan-400 via-sky-500 to-pink-500 text-slate-950 font-display font-black text-xs uppercase tracking-wider hover:opacity-95 shadow-lg shadow-cyan-500/25 hover:shadow-cyan-500/40 hover:scale-[1.02] active:scale-95 transition-all"
          @mouseenter="sound.playHover()"
        >
          <GooglePlayIcon customClass="w-3.5 h-3.5" />
          <span>{{ isEn ? 'GET APP' : 'TẢI APP' }}</span>
        </button>

        <!-- Mobile Hamburger Toggle -->
        <button 
          @click="mobileMenuOpen = !mobileMenuOpen; sound.playClick()"
          class="md:hidden p-2.5 rounded-xl border border-slate-800 bg-slate-900 text-slate-400 hover:text-white"
        >
          <svg v-if="!mobileMenuOpen" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7" />
          </svg>
          <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

    </div>

    <!-- Mobile Navigation Drawer -->
    <div 
      v-if="mobileMenuOpen" 
      class="md:hidden border-t border-slate-800/80 bg-[#070b16]/95 backdrop-blur-2xl px-5 py-4 space-y-2.5"
    >
      <router-link 
        to="/" 
        @click="mobileMenuOpen = false; sound.playClick()"
        class="block px-3 py-2 rounded-lg text-base font-medium text-slate-200 hover:text-cyan-400 hover:bg-slate-800/50"
      >
        {{ isEn ? 'Home (Index)' : 'Trang Chủ (Index)' }}
      </router-link>
      <a 
        href="/#showcase" 
        @click="mobileMenuOpen = false; sound.playClick()"
        class="block px-3 py-2 rounded-lg text-base font-medium text-slate-200 hover:text-cyan-400 hover:bg-slate-800/50"
      >
        Zero Grid Game
      </a>
      <router-link 
        to="/privacy" 
        @click="mobileMenuOpen = false; sound.playClick()"
        class="block px-3 py-2 rounded-lg text-base font-medium text-slate-200 hover:text-cyan-400 hover:bg-slate-800/50"
      >
        {{ isEn ? 'Privacy Policy' : 'Chính Sách Quyền Riêng Tư' }}
      </router-link>
      <router-link 
        to="/delete-account" 
        @click="mobileMenuOpen = false; sound.playClick()"
        class="block px-3 py-2 rounded-lg text-base font-medium text-pink-400 bg-pink-500/10 rounded-lg"
      >
        {{ isEn ? 'Data Erasure / Delete Account' : 'Cổng Xóa Dữ Liệu / Tài Khoản' }}
      </router-link>
      <router-link 
        to="/terms" 
        @click="mobileMenuOpen = false; sound.playClick()"
        class="block px-3 py-2 rounded-lg text-base font-medium text-slate-200 hover:text-cyan-400 hover:bg-slate-800/50"
      >
        {{ isEn ? 'Terms of Service' : 'Điều Khoản Dịch Vụ' }}
      </router-link>
      <router-link 
        to="/unlock" 
        @click="mobileMenuOpen = false; sound.playClick()"
        class="block px-3 py-2 rounded-lg text-base font-medium text-emerald-300 bg-emerald-500/10 border border-emerald-500/30 flex items-center gap-2"
      >
        <span>🎁</span>
        <span>{{ isEn ? 'Unlock 10 Hints' : 'Mở Khóa Gói 10 Gợi Ý' }}</span>
      </router-link>
      <!-- Admin & API Docs for Mobile (Only shown if Admin) -->
      <template v-if="isAdmin">
        <router-link 
          to="/admin" 
          @click="mobileMenuOpen = false; sound.playClick()"
          class="block px-3 py-2 rounded-lg text-base font-medium text-pink-300 bg-pink-500/10 border border-pink-500/30 font-mono"
        >
          🛡️ {{ isEn ? 'Admin Management Terminal' : 'Quản Trị Hệ Thống Admin' }}
        </router-link>
        <router-link 
          to="/docs" 
          @click="mobileMenuOpen = false; sound.playClick()"
          class="block px-3 py-2 rounded-lg text-base font-medium text-cyan-300 hover:bg-cyan-500/10 font-mono"
        >
          📖 {{ isEn ? 'API & OAuth Docs' : 'Tài Liệu Kỹ Thuật & API' }}
        </router-link>
      </template>

      <!-- Account Session in Mobile -->
      <div v-if="currentUser" class="pt-2 border-t border-slate-800 flex items-center justify-between px-3">
        <div class="flex items-center gap-2">
          <span class="w-2 h-2 rounded-full" :class="isAdmin ? 'bg-pink-400 animate-pulse' : 'bg-cyan-400'"></span>
          <span class="text-xs font-mono text-slate-300">
            {{ currentUser.display_name || currentUser.email }}
          </span>
        </div>
        <button 
          @click="handleLogout"
          class="px-3 py-1.5 text-xs font-mono text-rose-400 border border-rose-500/30 bg-rose-500/10 rounded-lg"
        >
          {{ isEn ? 'Sign Out' : 'Đăng Xuất' }}
        </button>
      </div>

      <router-link 
        v-else
        to="/login" 
        @click="mobileMenuOpen = false; sound.playClick()"
        class="block px-3 py-2 rounded-lg text-base font-medium text-cyan-300 hover:bg-cyan-500/10 font-mono"
      >
        🆔 {{ isEn ? 'TXA Studio ID Account' : 'Tài Khoản TXA Studio ID' }}
      </router-link>

      <button 
        @click="mobileMenuOpen = false; openDownloadModal()"
        class="w-full flex items-center justify-center gap-2 px-4 py-3 rounded-xl bg-gradient-to-r from-cyan-400 via-sky-500 to-pink-500 text-slate-950 font-display font-black text-xs uppercase tracking-wider shadow-lg shadow-cyan-500/20"
      >
        <GooglePlayIcon customClass="w-4 h-4" />
        <span>{{ isEn ? 'App Availability & Platform Check' : 'Kiểm Thử Google Play / Nền Tảng' }}</span>
      </button>
    </div>
  </header>
</template>

<script setup>
import { ref, computed, inject, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';
import GooglePlayIcon from './GooglePlayIcon.vue';
import { sound } from '../services/sound.js';
import { getCurrentWebUser, clearCurrentWebUser } from '../services/supabase.js';

const router = useRouter();
const mobileMenuOpen = ref(false);
const isMuted = ref(sound.isMuted());

const currentUser = ref(getCurrentWebUser());
const isAdmin = computed(() => currentUser.value?.role === 'admin');

function syncUser() {
  currentUser.value = getCurrentWebUser();
}

function handleLogout() {
  sound.playClick();
  clearCurrentWebUser();
  currentUser.value = null;
  mobileMenuOpen.value = false;
  router.push('/');
}

onMounted(() => {
  window.addEventListener('storage', syncUser);
  window.addEventListener('txa-auth-change', syncUser);
});

onUnmounted(() => {
  window.removeEventListener('storage', syncUser);
  window.removeEventListener('txa-auth-change', syncUser);
});

const currentLang = inject('currentLang', ref('vi'));
const setLang = inject('setLang', () => {});
const openDownloadModal = inject('openDownloadModal', () => {});

const isEn = computed(() => currentLang.value === 'en');

function toggleAudio() {
  isMuted.value = sound.toggleMute();
}

function toggleLanguage() {
  sound.playClick();
  const next = currentLang.value === 'vi' ? 'en' : 'vi';
  setLang(next);
}
</script>
