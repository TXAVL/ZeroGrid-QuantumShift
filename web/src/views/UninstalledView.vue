<template>
  <div class="relative z-10 py-12 lg:py-20">
    <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
      
      <!-- Top Title Badge -->
      <div class="text-center space-y-4 mb-10">
        <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-rose-500/10 border border-rose-500/30 text-rose-300 font-mono text-xs uppercase tracking-widest">
          <span class="w-2 h-2 rounded-full bg-rose-500"></span>
          <span>{{ isEn ? 'EXTENSION UNINSTALLED' : 'ĐÃ GỠ CÀI ĐẶT TIỆN ÍCH' }}</span>
        </div>

        <h1 class="text-3xl sm:text-5xl font-display font-black text-white tracking-tight">
          {{ isEn ? 'We Are Sorry to See You Go' : 'TXA Studio Rất Tiếc Khi Bạn Rời Đi' }}
        </h1>

        <p class="text-slate-400 text-xs sm:text-sm max-w-xl mx-auto leading-relaxed">
          {{ isEn 
            ? 'Thank you for trying ' + appName + '. Please take 30 seconds to share your feedback so our engineering team can improve future versions.' 
            : 'Cảm ơn bạn đã trải nghiệm ' + appName + '. Bạn vui lòng dành 30 giây chia sẻ lý do để đội ngũ kỹ sư cải thiện tốt hơn trong các bản cập nhật tới nhé.' }}
        </p>

        <div class="inline-flex items-center gap-2 text-[11px] font-mono text-slate-500 bg-slate-900/90 px-3 py-1.5 rounded-xl border border-slate-800">
          <span>App: {{ appName }}</span>
          <span>•</span>
          <span>Version: {{ appVersion }}</span>
        </div>
      </div>

      <!-- Success State Banner -->
      <div v-if="submitted" class="glass-panel p-8 sm:p-12 rounded-3xl border-2 border-emerald-500/50 shadow-neon-green text-center space-y-6 animate-fadeIn">
        <div class="w-16 h-16 rounded-3xl bg-emerald-500/20 text-emerald-400 border border-emerald-500/40 flex items-center justify-center text-3xl font-bold mx-auto">
          ✓
        </div>
        <div class="space-y-2">
          <h2 class="font-display font-black text-2xl text-white">
            {{ isEn ? 'Feedback Received! Thank You.' : 'Đã Gửi Ý Kiến Thành Công!' }}
          </h2>
          <p class="text-xs sm:text-sm text-slate-300 max-w-lg mx-auto leading-relaxed">
            {{ isEn 
              ? 'Your diagnostic feedback and device details have been logged for our core developers. We appreciate your contribution to open web privacy.' 
              : 'Ý kiến đóng góp cùng thông số kỹ thuật của bạn đã được ghi nhận vào hệ thống để kỹ sư phân tích khắc phục. Cảm ơn bạn rất nhiều!' }}
          </p>
        </div>

        <!-- Telegram Support Box in Success State -->
        <div class="p-5 rounded-2xl bg-cyan-950/30 border border-cyan-500/30 max-w-md mx-auto text-left flex items-center gap-4">
          <div class="text-3xl">🎬</div>
          <div class="space-y-1 flex-1">
            <div class="text-xs font-bold text-cyan-300 font-display">Động Mê Phim Channel</div>
            <div class="text-[11px] text-slate-400 leading-normal">
              {{ isEn ? 'Join Telegram for help, ad-free streaming tips and movie updates.' : 'Tham gia Telegram để giao lưu, nhận link phim mới và hỗ trợ kỹ thuật.' }}
            </div>
          </div>
          <a 
            href="https://t.me/dongmephim_channel" 
            target="_blank" 
            rel="noopener noreferrer"
            class="px-3.5 py-2 rounded-xl bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-display font-bold text-xs shrink-0"
          >
            Vào Kênh
          </a>
        </div>

        <div class="pt-4 flex flex-wrap items-center justify-center gap-4">
          <a 
            href="https://chromewebstore.google.com/detail/shieldblock-ad-tracker-bl/neajkofkkadimcabbhekjcgdbbkfpfll"
            target="_blank"
            rel="noopener noreferrer"
            class="px-6 py-3 rounded-xl bg-gradient-to-r from-emerald-400 to-cyan-500 text-slate-950 font-display font-bold text-xs uppercase tracking-wider hover:opacity-90 transition-all"
          >
            {{ isEn ? 'Reinstall ShieldBlock' : 'Cài Đặt Lại ShieldBlock' }}
          </a>
          <router-link 
            to="/" 
            class="px-6 py-3 rounded-xl bg-slate-900 hover:bg-slate-800 text-slate-300 font-mono text-xs border border-slate-700 transition-all"
          >
            {{ isEn ? 'Back to TXA Portal' : 'Về Trang Chủ TXA' }}
          </router-link>
        </div>
      </div>

      <!-- Feedback Survey Form -->
      <form v-else @submit.prevent="handleFeedbackSubmit" class="glass-panel p-6 sm:p-10 rounded-3xl border border-slate-800 space-y-8">
        
        <!-- Question 1: Reason Selection -->
        <div class="space-y-3">
          <label class="block text-xs font-mono uppercase tracking-wider text-slate-300 font-bold">
            {{ isEn ? '1. Why did you decide to uninstall?' : '1. Lý do chính bạn gỡ cài đặt tiện ích?' }} <span class="text-rose-500">*</span>
          </label>

          <div class="space-y-2.5">
            <label 
              v-for="item in reasonOptions" 
              :key="item.value"
              class="flex items-start gap-3 p-3.5 rounded-xl border cursor-pointer transition-all"
              :class="selectedReason === item.value 
                ? 'bg-rose-500/10 border-rose-500/60 text-white' 
                : 'bg-slate-900/60 border-slate-800 text-slate-300 hover:border-slate-700 hover:bg-slate-900/90'"
            >
              <input 
                type="radio" 
                name="reason" 
                :value="item.value" 
                v-model="selectedReason" 
                required
                class="mt-1 accent-rose-500 shrink-0" 
              />
              <div class="text-xs sm:text-sm leading-relaxed">
                <span class="font-medium">{{ isEn ? item.labelEn : item.labelVi }}</span>
              </div>
            </label>
          </div>
        </div>

        <!-- Question 2: Detail text -->
        <div class="space-y-2">
          <label class="block text-xs font-mono uppercase tracking-wider text-slate-300 font-bold">
            {{ isEn ? '2. Specific details or website URLs (Optional)' : '2. Mô tả chi tiết hoặc tên trang web bị lỗi (Không bắt buộc)' }}
          </label>
          <textarea 
            v-model="detailsText"
            rows="3"
            :placeholder="isEn 
              ? 'Tell us what happened (e.g. video player on example.com was blocked, specific popup bypassed...)' 
              : 'Chia sẻ cụ thể lỗi bạn gặp phải (ví dụ: bị vỡ player xem phim trên trang abc.com, không tắt được popup xyz...)'"
            class="w-full px-4 py-3 rounded-xl bg-slate-900/90 border border-slate-700 focus:border-cyan-400 text-white text-xs sm:text-sm outline-none transition-all"
          ></textarea>
        </div>

        <!-- Question 3: Optional Email -->
        <div class="space-y-2">
          <label class="block text-xs font-mono uppercase tracking-wider text-slate-300 font-bold">
            {{ isEn ? '3. Your Email Address (Optional)' : '3. Địa chỉ Email của bạn (Không bắt buộc)' }}
          </label>
          <input 
            v-model="userEmail"
            type="email"
            placeholder="your-email@example.com"
            class="w-full px-4 py-3 rounded-xl bg-slate-900/90 border border-slate-700 focus:border-cyan-400 text-white text-xs sm:text-sm outline-none font-mono transition-all"
          />
          <p class="text-[11px] text-slate-500 font-mono">
            {{ isEn ? 'Only used if you want our engineers to follow up on the bug fix.' : 'Chỉ dùng trong trường hợp bạn muốn nhận thông báo khi lỗi đã được sửa.' }}
          </p>
        </div>

        <!-- Diagnostic Telemetry Transparency Notice -->
        <div class="p-4 rounded-2xl bg-slate-900/80 border border-slate-800 text-[11px] text-slate-400 font-mono space-y-1.5">
          <div class="text-cyan-400 font-bold flex items-center gap-1.5">
            <span>ℹ️</span>
            <span>{{ isEn ? 'Diagnostic Environment Snapshot' : 'Thông Số Môi Trường Kỹ Thuật Tự Động' }}</span>
          </div>
          <p class="text-slate-400 font-sans text-xs leading-normal">
            {{ isEn 
              ? 'To reproduce and fix compatibility bugs, your anonymous device environment (Browser: ' + previewTelemetry.browser + ', OS: ' + previewTelemetry.os + ', Screen: ' + previewTelemetry.screen_resolution + ') will be safely included with this report.' 
              : 'Để kỹ sư tái lập và khắc phục lỗi chính xác, các thông số môi trường ẩn danh (Trình duyệt: ' + previewTelemetry.browser + ', HĐH: ' + previewTelemetry.os + ', Màn hình: ' + previewTelemetry.screen_resolution + ') sẽ được tự động gửi kèm báo cáo.' }}
          </p>
        </div>

        <!-- Error notification if failed -->
        <div v-if="errorMessage" class="p-4 rounded-xl bg-rose-500/10 border border-rose-500/30 text-rose-300 text-xs font-mono">
          {{ errorMessage }}
        </div>

        <!-- Submit Button -->
        <button 
          type="submit"
          :disabled="isSubmitting || !selectedReason"
          class="w-full py-4 rounded-2xl bg-gradient-to-r from-rose-500 via-pink-500 to-cyan-500 text-slate-950 font-display font-black text-sm uppercase tracking-wider hover:opacity-95 shadow-lg shadow-rose-500/25 transition-all disabled:opacity-40 disabled:cursor-not-allowed flex items-center justify-center gap-2"
        >
          <span v-if="isSubmitting">{{ isEn ? 'TRANSMITTING FEEDBACK...' : 'ĐANG GỬI Ý KIẾN...' }}</span>
          <span v-else>{{ isEn ? 'SUBMIT FEEDBACK & DIAGNOSTICS' : 'GỬI Ý KIẾN ĐÓNG GÓP' }}</span>
        </button>

      </form>

      <!-- Telegram Promo Footer Banner -->
      <div class="mt-10 p-6 rounded-2xl glass-panel border border-cyan-500/20 flex flex-col sm:flex-row items-center justify-between gap-4 text-center sm:text-left">
        <div class="flex items-center gap-3.5">
          <div class="w-10 h-10 rounded-xl bg-cyan-500/20 text-cyan-400 flex items-center justify-center text-xl shrink-0">
            🎬
          </div>
          <div>
            <div class="font-display font-bold text-sm text-white">Động Mê Phim Channel</div>
            <div class="text-xs text-slate-400">
              {{ isEn ? 'Movie group & direct extension support on Telegram' : 'Kênh chia sẻ phim chất lượng cao & hỗ trợ tiện ích trên Telegram' }}
            </div>
          </div>
        </div>

        <a 
          href="https://t.me/dongmephim_channel" 
          target="_blank" 
          rel="noopener noreferrer"
          class="px-4 py-2 rounded-xl bg-cyan-500/10 hover:bg-cyan-500/20 border border-cyan-500/30 text-cyan-300 hover:text-white font-mono text-xs transition-all shrink-0"
        >
          https://t.me/dongmephim_channel →
        </a>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, computed, inject, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { submitFeedback, collectDeviceTelemetry } from '../services/supabase.js';
import { sound } from '../services/sound.js';

const route = useRoute();
const currentLang = inject('currentLang', ref('vi'));
const isEn = computed(() => currentLang.value === 'en');

const appName = computed(() => {
  return route.query.name ? decodeURIComponent(route.query.name) : 'ShieldBlock Pro';
});

const appVersion = computed(() => {
  return route.query.version || '1.1.0';
});

const appSlug = computed(() => {
  return route.query.app || 'shieldblock';
});

const reasonOptions = [
  {
    value: 'broken_site',
    labelVi: 'Bị chặn nhầm nội dung trên trang web tôi hay xem (vỡ giao diện, không load được video)',
    labelEn: 'Broke websites I regularly visit (broken layout, video streaming refused to load)'
  },
  {
    value: 'ads_not_blocked',
    labelVi: 'Không chặn được một số quảng cáo hoặc bẫy popup nhảy ra',
    labelEn: 'Failed to block ads, banners or intrusive popups on specific sites'
  },
  {
    value: 'slow_performance',
    labelVi: 'Làm chậm tốc độ tải trang web hoặc giật lag trình duyệt',
    labelEn: 'Slowed down web page loading or caused browser lagging'
  },
  {
    value: 'hard_to_use',
    labelVi: 'Giao diện khó hiểu, khó bật/tắt hoặc thiếu hướng dẫn chi tiết',
    labelEn: 'User interface was confusing or difficult to configure'
  },
  {
    value: 'switched_competitor',
    labelVi: 'Tôi chuyển sang tiện ích khác (uBlock Origin, AdGuard, Brave Shield...)',
    labelEn: 'Switched to a different ad blocker (uBlock Origin, AdGuard, Brave...)'
  },
  {
    value: 'temporary_use',
    labelVi: 'Tôi chỉ cài đặt để dùng thử hoặc kiểm tra tính năng tạm thời',
    labelEn: 'I only installed it temporarily for testing or trial purposes'
  },
  {
    value: 'other',
    labelVi: 'Lý do khác...',
    labelEn: 'Other reason...'
  }
];

const selectedReason = ref('');
const detailsText = ref('');
const userEmail = ref('');
const isSubmitting = ref(false);
const submitted = ref(false);
const errorMessage = ref('');

const previewTelemetry = ref({
  browser: 'Detecting...',
  os: 'Detecting...',
  screen_resolution: '...'
});

onMounted(() => {
  try {
    const tel = collectDeviceTelemetry();
    previewTelemetry.value = tel;
  } catch (e) {}
});

async function handleFeedbackSubmit() {
  if (!selectedReason.value) return;
  isSubmitting.value = true;
  errorMessage.value = '';

  try {
    const fullTelemetry = collectDeviceTelemetry();
    await submitFeedback({
      appSlug: appSlug.value,
      appName: appName.value,
      appVersion: appVersion.value,
      reason: selectedReason.value,
      details: detailsText.value.trim(),
      email: userEmail.value.trim(),
      deviceInfo: fullTelemetry
    });

    submitted.value = true;
    sound.playSuccess();
  } catch (err) {
    sound.playClick();
    errorMessage.value = isEn.value 
      ? 'Failed to send feedback: ' + (err.message || 'Server busy. Please try again.') 
      : 'Không thể gửi ý kiến: ' + (err.message || 'Máy chủ đang bận, vui lòng thử lại.');
  } finally {
    isSubmitting.value = false;
  }
}
</script>
