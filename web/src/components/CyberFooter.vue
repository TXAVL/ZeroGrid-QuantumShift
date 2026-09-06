<template>
  <footer class="relative z-10 border-t border-slate-800/80 bg-[#060812]/90 backdrop-blur-xl mt-24">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-14">
      <div class="grid grid-cols-1 md:grid-cols-4 gap-10">
        
        <!-- Col 1: Studio Identity -->
        <div class="md:col-span-2 space-y-4">
          <div class="flex items-center space-x-3">
            <div class="w-9 h-9 rounded-xl bg-gradient-to-tr from-cyan-400 via-sky-500 to-pink-500 p-[2px]">
              <div class="w-full h-full bg-slate-950 rounded-[10px] flex items-center justify-center font-display font-black text-cyan-400 text-lg">
                T
              </div>
            </div>
            <span class="font-display font-black tracking-wider text-xl text-white">
              TXA STUDIO
            </span>
          </div>

          <p class="text-slate-400 text-sm leading-relaxed max-w-md">
            {{ isEn 
              ? 'Pioneering pure logic, high-framerate sci-fi indie games. Zero invasive ads, offline-first architectures, and transparent data privacy.' 
              : 'Tiên phong phát triển các tựa game logic thuần túy, khung hình cao chuẩn Sci-Fi. Không quảng cáo gây khó chịu, ưu tiên offline và minh bạch dữ liệu tuyệt đối.' }}
          </p>

          <div class="flex items-center gap-3 pt-2">
            <div class="flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-mono">
              <span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
              <span>SUPABASE CDN: OPERATIONAL</span>
            </div>
            <div class="flex items-center gap-1.5 px-3 py-1 rounded-full bg-cyan-500/10 border border-cyan-500/20 text-cyan-400 text-xs font-mono">
              <span>PLAY CONSOLE READY</span>
            </div>
          </div>
        </div>

        <!-- Col 2: Games & Projects -->
        <div>
          <h3 class="text-xs font-mono uppercase tracking-widest text-slate-400 mb-4 font-bold flex items-center gap-2">
            <span class="w-1.5 h-1.5 bg-cyan-400 rounded-full"></span>
            {{ isEn ? 'GAMES & ECOSYSTEM' : 'DỰ ÁN & HỆ SINH THÁI' }}
          </h3>
          <ul class="space-y-2.5 text-sm">
            <li>
              <a href="/#showcase" class="text-slate-300 hover:text-cyan-400 transition-colors flex items-center justify-between">
                <span>Zero Grid: Quantum Shift</span>
                <span class="text-[10px] font-mono px-1.5 py-0.5 rounded bg-cyan-500/10 text-cyan-400">v1.4</span>
              </a>
            </li>
            <li>
              <span class="text-slate-500 flex items-center justify-between cursor-not-allowed">
                <span>Project Chrono (TBA)</span>
                <span class="text-[10px] font-mono px-1.5 py-0.5 rounded bg-slate-800 text-slate-500">2026 Q4</span>
              </span>
            </li>
            <li>
              <span class="text-slate-500 flex items-center justify-between cursor-not-allowed">
                <span>Zero Grid: Overdrive</span>
                <span class="text-[10px] font-mono px-1.5 py-0.5 rounded bg-slate-800 text-slate-500">IN DEV</span>
              </span>
            </li>
          </ul>
        </div>

        <!-- Col 3: Compliance & Legal -->
        <div>
          <h3 class="text-xs font-mono uppercase tracking-widest text-slate-400 mb-4 font-bold flex items-center gap-2">
            <span class="w-1.5 h-1.5 bg-pink-400 rounded-full"></span>
            {{ isEn ? 'LEGAL & COMPLIANCE' : 'PHÁP LÝ & BẢO VỆ' }}
          </h3>
          <ul class="space-y-2.5 text-sm">
            <li>
              <router-link to="/privacy?game=quantumshift" class="text-slate-300 hover:text-cyan-400 transition-colors">
                {{ isEn ? 'Privacy Policy' : 'Chính Sách Quyền Riêng Tư' }}
              </router-link>
            </li>
            <li>
              <router-link to="/delete-account?game=quantumshift" class="text-pink-400 hover:text-pink-300 transition-colors flex items-center gap-1.5 font-medium">
                <span>{{ isEn ? 'Delete Account / Data' : 'Xóa Tài Khoản / Dữ Liệu' }}</span>
                <span class="text-[9px] font-mono px-1 rounded bg-pink-500/20 text-pink-300">Google Play</span>
              </router-link>
            </li>
            <li>
              <router-link to="/terms?game=quantumshift" class="text-slate-300 hover:text-cyan-400 transition-colors">
                {{ isEn ? 'Terms of Service' : 'Điều Khoản Sử Dụng' }}
              </router-link>
            </li>
            <li>
              <a href="mailto:txasoftdev@gmail.com" class="text-slate-400 hover:text-slate-200 transition-colors font-mono text-xs flex items-center gap-1">
                <span>✉ txasoftdev@gmail.com</span>
              </a>
            </li>
          </ul>
        </div>

      </div>

      <!-- Bottom Bar -->
      <div class="border-t border-slate-800/60 mt-12 pt-8 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs font-mono text-slate-500">
        <div>
          &copy; {{ new Date().getFullYear() }} TXA STUDIO (txastudio.click). All rights reserved.
        </div>
        <div class="flex items-center gap-4">
          <span class="text-slate-400">Powered by Flutter, Supabase & Vercel Edge</span>
        </div>
      </div>

    </div>
  </footer>
</template>

<script setup>
import { computed, inject, ref } from 'vue';

const currentLang = inject('currentLang', ref('vi'));
const isEn = computed(() => currentLang.value === 'en');
</script>
