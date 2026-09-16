<template>
  <div class="relative z-10">
    
    <!-- ================================================================= -->
    <!-- 1. ZERO GRID HERO SECTION -->
    <!-- ================================================================= -->
    <section class="relative pt-12 pb-24 lg:pt-20 lg:pb-32 overflow-hidden">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-8 items-center">
          
          <!-- Left Column: Studio Pitch & Actions -->
          <div class="lg:col-span-7 space-y-7 text-center lg:text-left">
            
            <!-- Neon Pill Badge -->
            <div class="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-pink-500/10 border border-pink-500/30 shadow-neon-pink">
              <span class="w-2 h-2 rounded-full bg-pink-400 animate-ping"></span>
              <span class="text-xs font-mono font-bold tracking-widest text-pink-300 uppercase">
                ZERO GRID: QUANTUM SHIFT // RELEASE 1.5.0
              </span>
            </div>

            <!-- Main Heading -->
            <h1 class="text-4xl sm:text-6xl lg:text-7xl font-display font-black tracking-tight leading-[1.05] text-white">
              BEYOND THE <br />
              <span class="text-cyber-gradient text-neon-cyan">QUANTUM</span>
              <span class="text-white"> MATRIX</span>
            </h1>

            <!-- Subtitle -->
            <p class="text-base sm:text-lg text-slate-300 max-w-2xl mx-auto lg:mx-0 leading-relaxed font-normal">
              {{ isEn 
                ? 'Engineered by TXA Studio. A high-octane minimalist cyber puzzle game powered by pure 120 FPS Flutter mechanics, guaranteed mathematical solvability, and absolute player privacy.'
                : 'Siêu phẩm giải đố trí tuệ phong cách Cyberpunk từ TXA Studio. Tối ưu 120 FPS với thuật toán toán học 100% có nghiệm, đua top Ghost Replay và tôn trọng quyền riêng tư tuyệt đối.' }}
            </p>

            <!-- CTA Buttons -->
            <div class="flex flex-wrap items-center justify-center lg:justify-start gap-4 pt-2">
              <!-- Play Store Button -->
              <button 
                @click="openDownloadModal()"
                class="inline-flex items-center gap-3 px-6 py-3.5 rounded-2xl bg-gradient-to-r from-pink-400 via-rose-500 to-amber-500 text-slate-950 font-display font-black text-sm uppercase tracking-wider shadow-lg shadow-pink-500/30 hover:shadow-pink-400/50 hover:scale-[1.03] active:scale-95 transition-all"
                @mouseenter="sound.playHover()"
              >
                <GooglePlayIcon customClass="w-5 h-5" />
                <span>{{ isEn ? 'GET ON GOOGLE PLAY' : 'TẢI TRÊN GOOGLE PLAY' }}</span>
              </button>

              <!-- Unlock Hints -->
              <router-link
                to="/unlock" 
                class="inline-flex items-center gap-2 px-6 py-3.5 rounded-2xl glass-panel border border-emerald-500/40 text-emerald-300 font-medium text-sm hover:border-emerald-400 hover:text-white transition-all hover:scale-[1.02] active:scale-95"
                @mouseenter="sound.playHover()"
                @click="sound.playClick()"
              >
                <span>🎁</span>
                <span>{{ isEn ? 'Unlock 10 Hints' : 'Mở Khóa 10 Gợi Ý' }}</span>
              </router-link>

              <!-- Legal & Delete Quick Access -->
              <router-link
                to="/delete-account?game=quantumshift"
                class="inline-flex items-center gap-1.5 px-4 py-3.5 rounded-2xl border border-pink-500/30 bg-pink-500/10 hover:bg-pink-500/20 text-pink-300 font-mono text-xs hover:text-white transition-all"
                @mouseenter="sound.playHover()"
                @click="sound.playClick()"
              >
                <span class="w-1.5 h-1.5 rounded-full bg-pink-400"></span>
                <span>Data Rights / Delete</span>
              </router-link>
            </div>

            <!-- Platform Availability Indicator Pills -->
            <div class="flex flex-wrap items-center justify-center lg:justify-start gap-2.5 pt-2 text-xs font-mono">
              <button 
                @click="openDownloadModal('android')"
                class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-amber-500/10 border border-amber-500/30 text-amber-300 hover:bg-amber-500/20 hover:border-amber-400 transition-all cursor-pointer"
                title="Xem tình trạng bản Android"
              >
                <span class="w-1.5 h-1.5 rounded-full bg-amber-400 animate-pulse"></span>
                <span>Android: {{ isEn ? 'Internal Testing' : 'Kiểm thử nội bộ' }}</span>
              </button>

              <button 
                @click="openDownloadModal('ios')"
                class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-sky-500/10 border border-sky-500/30 text-sky-300 hover:bg-sky-500/20 hover:border-sky-400 transition-all cursor-pointer"
                title="Xem tình trạng bản iOS"
              >
                <span class="w-1.5 h-1.5 rounded-full bg-sky-400"></span>
                <span>iOS: {{ isEn ? 'Coming Soon' : 'Chưa có ứng dụng' }}</span>
              </button>

              <button 
                @click="openDownloadModal('windows')"
                class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-rose-500/10 border border-rose-500/30 text-rose-300 hover:bg-rose-500/20 hover:border-rose-400 transition-all cursor-pointer"
                title="Xem tình trạng bản Windows"
              >
                <span class="w-1.5 h-1.5 rounded-full bg-rose-500"></span>
                <span>Windows: {{ isEn ? 'Not Supported' : 'Không khả dụng' }}</span>
              </button>
            </div>

            <!-- Mini Spec Badges -->
            <div class="grid grid-cols-3 gap-3 pt-6 border-t border-slate-800/80 max-w-lg mx-auto lg:mx-0">
              <div class="text-center lg:text-left">
                <div class="text-2xl sm:text-3xl font-display font-black text-cyan-400">120 FPS</div>
                <div class="text-xs text-slate-400 font-mono">Ultra Refresh Rate</div>
              </div>
              <div class="text-center lg:text-left">
                <div class="text-2xl sm:text-3xl font-display font-black text-pink-400">100%</div>
                <div class="text-xs text-slate-400 font-mono">Solvable Logic</div>
              </div>
              <div class="text-center lg:text-left">
                <div class="text-2xl sm:text-3xl font-display font-black text-emerald-400">0 NO-AD</div>
                <div class="text-xs text-slate-400 font-mono">No Pop-up Spam</div>
              </div>
            </div>

          </div>

          <!-- Right Column: 3D Holographic Showcase Graphic -->
          <div class="lg:col-span-5 relative flex justify-center">
            <div class="absolute inset-0 bg-gradient-to-tr from-pink-500/20 to-cyan-500/20 rounded-3xl blur-2xl transform rotate-3 scale-95 pointer-events-none"></div>

            <div class="relative w-full max-w-md rounded-3xl glass-panel p-4 border border-pink-500/30 shadow-2xl shadow-pink-950/60 transition-transform duration-500 hover:scale-[1.02]">
              
              <!-- Top Card Bar -->
              <div class="flex items-center justify-between pb-3 border-b border-slate-800/80 mb-3 text-xs font-mono text-slate-400">
                <div class="flex items-center gap-2">
                  <span class="w-2.5 h-2.5 rounded-full bg-red-500 inline-block"></span>
                  <span class="w-2.5 h-2.5 rounded-full bg-yellow-500 inline-block"></span>
                  <span class="w-2.5 h-2.5 rounded-full bg-emerald-500 inline-block"></span>
                </div>
                <span class="text-pink-400 font-bold">QUANTUM_CORE // v1.5</span>
              </div>

              <!-- Feature Graphic Image -->
              <div class="relative rounded-2xl overflow-hidden border border-slate-700/60 group">
                <img 
                  src="/playstore_feature_graphic.png" 
                  alt="Quantum Shift: Zero Grid" 
                  class="w-full h-auto object-cover transform group-hover:scale-105 transition-transform duration-700"
                />
                <div class="absolute inset-0 bg-gradient-to-t from-[#070b16] via-transparent to-transparent opacity-60"></div>
                
                <div class="absolute bottom-3 left-3 right-3 flex items-center justify-between">
                  <span class="px-2.5 py-1 rounded-lg bg-black/80 backdrop-blur-md text-[11px] font-mono text-cyan-300 border border-cyan-500/30">
                    CYBER MATRIX
                  </span>
                  <span class="px-2.5 py-1 rounded-lg bg-pink-500/80 backdrop-blur-md text-[11px] font-display font-bold text-white">
                    PURE FLUTTER
                  </span>
                </div>
              </div>

              <!-- Logo & Quick Tagline -->
              <div class="mt-4 flex items-center gap-3.5">
                <img src="/logo_master.png" alt="Logo" class="w-12 h-12 rounded-xl object-contain bg-slate-900/80 p-1 border border-pink-500/30" />
                <div>
                  <h3 class="font-display font-black text-white text-base tracking-wide">
                    Zero Grid: Quantum Shift
                  </h3>
                  <p class="text-xs text-slate-400 font-mono">
                    Published by TXA Studio • Google Play Internal Testing
                  </p>
                </div>
              </div>

            </div>
          </div>

        </div>
      </div>
    </section>

    <!-- ================================================================= -->
    <!-- 2. GAME SPECIFICATIONS & FEATURES DEEP DIVE -->
    <!-- ================================================================= -->
    <section class="py-20 border-t border-slate-800/80 relative">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        <div class="text-center max-w-3xl mx-auto mb-16 space-y-4">
          <div class="inline-block text-xs font-mono font-bold tracking-widest text-pink-400 uppercase bg-pink-500/10 px-3.5 py-1 rounded-full border border-pink-500/20">
            TECHNICAL MASTERY & GAME DESIGN
          </div>
          <h2 class="text-3xl sm:text-5xl font-display font-black text-white tracking-tight">
            ENGINEERED FOR <span class="text-cyber-gradient text-neon-cyan">PURE LOGIC</span>
          </h2>
          <p class="text-slate-400 text-sm sm:text-base leading-relaxed">
            {{ isEn 
              ? 'Zero Grid strips away the bloat of modern mobile gaming to deliver an immaculate, high-speed cerebral experience.' 
              : 'Zero Grid loại bỏ hoàn toàn các cơ chế gacha rác và quảng cáo phiền toái, mang lại trải nghiệm tư duy logic thuần khiết nhất.' }}
          </p>
        </div>

        <!-- 4 Cyber Feature Cards -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          
          <div class="glass-card p-6 rounded-2xl space-y-4">
            <div class="w-12 h-12 rounded-xl bg-cyan-500/10 border border-cyan-500/30 flex items-center justify-center text-cyan-400 font-mono text-xl font-bold shadow-neon-cyan">
              Ω
            </div>
            <h3 class="font-display font-bold text-lg text-white">
              {{ isEn ? '100% Solvable Logic' : 'Thuật Toán Sinh Ngược' }}
            </h3>
            <p class="text-slate-400 text-xs sm:text-sm leading-relaxed">
              {{ isEn 
                ? 'Every grid is generated backwards through verified inverse bit-flip permutations. No impossible dead-ends.' 
                : 'Mỗi ván chơi đều được tạo ngược từ trạng thái chiến thắng. Đảm bảo 100% ván đấu luôn có lời giải toán học logic.' }}
            </p>
          </div>

          <div class="glass-card p-6 rounded-2xl space-y-4">
            <div class="w-12 h-12 rounded-xl bg-pink-500/10 border border-pink-500/30 flex items-center justify-center text-pink-400 font-mono text-xl font-bold shadow-neon-pink">
              ⚡
            </div>
            <h3 class="font-display font-bold text-lg text-white">
              {{ isEn ? '120 FPS Minimal Engine' : 'Khung Hình 120 FPS' }}
            </h3>
            <p class="text-slate-400 text-xs sm:text-sm leading-relaxed">
              {{ isEn 
                ? 'CustomPainter canvas rendering bypassing heavy widget trees. Instant tactile feedback with sub-millisecond input lag.' 
                : 'Vẽ trực tiếp trên Canvas CustomPainter, loại bỏ widget tree cồng kềnh. Phản hồi xúc giác tức thì, mượt mà tối đa.' }}
            </p>
          </div>

          <div class="glass-card p-6 rounded-2xl space-y-4">
            <div class="w-12 h-12 rounded-xl bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400 font-mono text-xl font-bold shadow-neon-green">
              ☁
            </div>
            <h3 class="font-display font-bold text-lg text-white">
              {{ isEn ? 'Ghost Replay Cloud' : 'Đua Top Ghost Replay' }}
            </h3>
            <p class="text-slate-400 text-xs sm:text-sm leading-relaxed">
              {{ isEn 
                ? 'Compete on daily leaderboards and observe recorded ghost replays from top global speedrunners via Supabase Edge.' 
                : 'Lưu điểm và tái hiện bước đi bóng ma (Ghost Replay) của các cao thủ tốc độ toàn cầu qua hạ tầng Supabase Edge.' }}
            </p>
          </div>

          <div class="glass-card p-6 rounded-2xl space-y-4">
            <div class="w-12 h-12 rounded-xl bg-purple-500/10 border border-purple-500/30 flex items-center justify-center text-purple-400 font-mono text-xl font-bold">
              🛡
            </div>
            <h3 class="font-display font-bold text-lg text-white">
              {{ isEn ? 'Player Privacy First' : 'Tôn Trọng Dữ Liệu' }}
            </h3>
            <p class="text-slate-400 text-xs sm:text-sm leading-relaxed">
              {{ isEn 
                ? 'Zero third-party trackers, zero data harvesting. Pure offline play support with voluntary cloud saves.' 
                : 'Không chứa mã theo dõi ngầm hay thu thập dữ liệu bất minh. Hỗ trợ chơi offline hoàn toàn và đồng bộ tự nguyện.' }}
            </p>
          </div>

        </div>

        <div class="mt-12 text-center">
          <router-link 
            to="/" 
            class="text-xs font-mono text-slate-400 hover:text-cyan-400 underline"
          >
            ← {{ isEn ? 'Back to TXA Studio Portal' : 'Quay lại Trang Chủ TXA Studio' }}
          </router-link>
        </div>

      </div>
    </section>

  </div>
</template>

<script setup>
import { computed, inject, ref } from 'vue';
import GooglePlayIcon from '../components/GooglePlayIcon.vue';
import { sound } from '../services/sound.js';

const currentLang = inject('currentLang', ref('vi'));
const isEn = computed(() => currentLang.value === 'en');
const openDownloadModal = inject('openDownloadModal', () => {});
</script>
