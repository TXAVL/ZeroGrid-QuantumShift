<template>
  <div class="min-h-screen py-16 px-4 sm:px-6 flex items-center justify-center relative overflow-hidden">
    <!-- Cyberpunk background glow -->
    <div class="absolute top-1/4 left-1/2 -translate-x-1/2 w-96 h-96 bg-cyan-500/10 rounded-full blur-3xl pointer-events-none"></div>
    <div class="absolute bottom-10 right-10 w-80 h-80 bg-pink-500/10 rounded-full blur-3xl pointer-events-none"></div>

    <div class="relative w-full max-w-md rounded-3xl border border-slate-800 bg-[#090d1a]/95 backdrop-blur-xl p-6 sm:p-8 shadow-2xl shadow-cyan-950/40 text-slate-100">
      
      <!-- Studio Monogram Header -->
      <div class="text-center space-y-3 mb-8">
        <div class="inline-flex items-center justify-center w-16 h-16 rounded-2xl border border-cyan-400/40 bg-slate-900/90 shadow-lg shadow-cyan-500/20 p-2">
          <img src="/txa_logo.png" alt="TXA Studio" class="w-full h-full object-contain" />
        </div>
        <div>
          <span class="text-[10px] font-mono tracking-widest text-pink-400 uppercase font-bold">
            NEW PLAYER // IDENTITY ENROLLMENT
          </span>
          <h1 class="text-2xl sm:text-3xl font-display font-black text-white mt-1">
            {{ isEn ? 'Create TXA ID' : 'Đăng Ký TXA ID' }}
          </h1>
          <p class="text-xs text-slate-400 font-mono mt-1">
            {{ isEn ? 'Sync your ranks and progress across all TXA Studio games' : 'Đồng bộ điểm và xếp hạng trên toàn hệ sinh thái TXA Studio' }}
          </p>
        </div>
      </div>

      <!-- Notification Card -->
      <div v-if="notice" class="mb-6 p-4 rounded-2xl border text-xs font-mono"
        :class="notice.type === 'error' ? 'bg-rose-950/40 border-rose-500/40 text-rose-300' : 'bg-emerald-950/40 border-emerald-500/40 text-emerald-300'"
      >
        <div class="flex items-center gap-2 font-bold mb-1">
          <span v-if="notice.type === 'error'">⚠️ LỖI ĐĂNG KÝ:</span>
          <span v-else>✓ HOÀN TẤT:</span>
        </div>
        <p class="text-slate-300 leading-relaxed font-sans text-xs">{{ notice.text }}</p>
      </div>

      <!-- Form -->
      <form @submit.prevent="handleRegister" class="space-y-4">
        <div>
          <label class="block text-xs font-mono uppercase tracking-wider text-slate-400 font-bold mb-1.5">
            {{ isEn ? 'Display Name / Gamer Tag' : 'Tên Hiển Thị / Biệt Danh' }}
          </label>
          <input 
            type="text" 
            v-model="displayName" 
            required 
            placeholder="CyberRunner #99"
            class="w-full px-4 py-3 rounded-xl bg-slate-900/90 border border-slate-700 focus:border-cyan-400 text-white text-sm outline-none transition-all placeholder:text-slate-600"
          />
        </div>

        <div>
          <label class="block text-xs font-mono uppercase tracking-wider text-slate-400 font-bold mb-1.5">
            Email
          </label>
          <input 
            type="email" 
            v-model="email" 
            required 
            placeholder="player@example.com"
            class="w-full px-4 py-3 rounded-xl bg-slate-900/90 border border-slate-700 focus:border-cyan-400 text-white text-sm outline-none transition-all placeholder:text-slate-600"
          />
        </div>

        <div>
          <label class="block text-xs font-mono uppercase tracking-wider text-slate-400 font-bold mb-1.5">
            {{ isEn ? 'Password (At least 6 characters)' : 'Mật Khẩu (Tối thiểu 6 ký tự)' }}
          </label>
          <input 
            type="password" 
            v-model="password" 
            required 
            minlength="6"
            placeholder="••••••••"
            class="w-full px-4 py-3 rounded-xl bg-slate-900/90 border border-slate-700 focus:border-cyan-400 text-white text-sm outline-none transition-all placeholder:text-slate-600"
          />
        </div>

        <!-- Submit Button -->
        <button 
          type="submit" 
          :disabled="isLoading"
          class="w-full mt-2 py-3.5 px-6 rounded-2xl bg-gradient-to-r from-pink-500 via-purple-500 to-cyan-400 text-white font-display font-black text-xs uppercase tracking-wider shadow-lg shadow-pink-500/30 hover:shadow-pink-400/50 hover:scale-[1.02] active:scale-95 transition-all disabled:opacity-50 disabled:pointer-events-none flex items-center justify-center gap-2"
        >
          <span v-if="isLoading" class="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></span>
          <span>{{ isLoading ? (isEn ? 'CREATING ACCOUNT...' : 'ĐANG KHỞI TẠO...') : (isEn ? 'CREATE TXA ID' : 'ĐĂNG KÝ TÀI KHOẢN') }}</span>
        </button>
      </form>

      <!-- Already Have Account -->
      <div class="mt-6 pt-6 border-t border-slate-800/80 text-center space-y-3">
        <p class="text-xs text-slate-400">
          {{ isEn ? 'Already registered?' : 'Đã có tài khoản?' }}
          <router-link 
            :to="{ path: '/login', query: route.query }" 
            class="text-cyan-400 hover:text-cyan-300 font-bold ml-1 hover:underline"
          >
            {{ isEn ? 'Sign in' : 'Đăng nhập ngay' }}
          </router-link>
        </p>

        <div class="pt-2">
          <router-link to="/" class="text-xs font-mono text-slate-500 hover:text-slate-300 underline">
            ← {{ isEn ? 'Back to Home Portal' : 'Quay về trang chủ' }}
          </router-link>
        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, computed, inject } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { webRegister, webLogin } from '../services/supabase.js';
import { sound } from '../services/sound.js';

const route = useRoute();
const router = useRouter();

const currentLang = inject('currentLang', ref('vi'));
const isEn = computed(() => currentLang.value === 'en');

const displayName = ref('');
const email = ref('');
const password = ref('');
const isLoading = ref(false);
const notice = ref(null);

async function handleRegister() {
  sound.playClick();
  if (password.value.length < 6) {
    notice.value = {
      type: 'error',
      text: isEn.value ? 'Password must be at least 6 characters.' : 'Mật khẩu phải chứa ít nhất 6 ký tự.'
    };
    return;
  }

  isLoading.value = true;
  notice.value = null;

  try {
    const res = await webRegister(email.value, password.value, displayName.value);
    if (!res?.success) {
      sound.playClick();
      notice.value = {
        type: 'error',
        text: res?.error || (isEn.value ? 'Registration failed.' : 'Đăng ký không thành công.')
      };
      return;
    }

    // Auto login right after registration
    await webLogin(email.value, password.value);
    sound.playSuccess();
    notice.value = {
      type: 'success',
      text: isEn.value ? 'Account created successfully! Redirecting...' : 'Khởi tạo tài khoản thành công! Đang chuyển hướng...'
    };

    setTimeout(() => {
      if (route.query.redirect) {
        router.push(route.query.redirect);
      } else {
        router.push('/');
      }
    }, 900);

  } catch (err) {
    sound.playClick();
    notice.value = {
      type: 'error',
      text: err.message || (isEn.value ? 'Network error. Please try again.' : 'Lỗi kết nối. Vui lòng thử lại.')
    };
  } finally {
    isLoading.value = false;
  }
}
</script>
