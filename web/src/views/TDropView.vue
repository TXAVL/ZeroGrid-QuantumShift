<template>
  <div class="relative z-10">
    
    <!-- ================================================================= -->
    <!-- 1. T-DROP HERO SECTION -->
    <!-- ================================================================= -->
    <section class="relative pt-12 pb-20 lg:pt-20 lg:pb-28 overflow-hidden">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-8 items-center">
          
          <!-- Left Column: Intro & Actions -->
          <div class="lg:col-span-7 space-y-7 text-center lg:text-left">
            
            <!-- Neon Pill Badge -->
            <div class="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-indigo-500/10 border border-indigo-500/30 shadow-lg shadow-indigo-500/20">
              <span class="w-2 h-2 rounded-full bg-cyan-400 animate-ping"></span>
              <span class="text-xs font-mono font-bold tracking-widest text-cyan-300 uppercase">
                WINDOWS & MACOS // AI OCR WORKSPACE
              </span>
            </div>

            <!-- Main Heading -->
            <h1 class="text-4xl sm:text-6xl lg:text-7xl font-display font-black tracking-tight leading-[1.05] text-white">
              T-DROP <br />
              <span class="bg-gradient-to-r from-cyan-400 via-sky-400 to-indigo-400 bg-clip-text text-transparent">AI CLIPBOARD</span>
            </h1>

            <!-- Subtitle -->
            <p class="text-base sm:text-lg text-slate-300 max-w-2xl mx-auto lg:mx-0 leading-relaxed font-normal">
              {{ isEn 
                ? 'High-speed desktop clipboard manager with instantaneous AI OCR text extraction, infinite history vault, and seamless VietQR automatic VIP licensing for Windows & macOS.'
                : 'Trợ lý quản lý bộ nhớ tạm (Clipboard History) vô tận và trích xuất chữ từ hình ảnh AI OCR siêu tốc độ. Tích hợp thanh toán VietQR tự động cấp phát bản quyền VIP & PREMIUM cho Windows & macOS.' }}
            </p>

            <!-- CTA Buttons -->
            <div class="flex flex-wrap items-center justify-center lg:justify-start gap-4 pt-2">
              <a 
                href="https://github.com/TXAVL/T-Drop/releases"
                target="_blank"
                rel="noopener noreferrer"
                class="inline-flex items-center gap-3 px-6 py-3.5 rounded-2xl bg-gradient-to-r from-cyan-400 via-sky-500 to-indigo-600 text-slate-950 font-display font-black text-sm uppercase tracking-wider shadow-lg shadow-cyan-500/30 hover:shadow-cyan-400/50 hover:scale-[1.03] active:scale-95 transition-all"
                @mouseenter="sound.playHover()"
                @click="sound.playClick()"
              >
                <span>💾</span>
                <span>{{ isEn ? 'DOWNLOAD T-DROP (DESKTOP)' : 'TẢI T-DROP CHO MÁY TÍNH' }}</span>
              </a>

              <a 
                href="https://github.com/TXAVL/T-Drop" 
                target="_blank" 
                rel="noopener noreferrer"
                class="inline-flex items-center gap-2 px-6 py-3.5 rounded-2xl bg-slate-900/90 hover:bg-slate-800 border border-slate-700 text-slate-300 hover:text-white font-medium text-sm transition-all hover:scale-[1.02] active:scale-95"
                @mouseenter="sound.playHover()"
                @click="sound.playClick()"
              >
                <span>🐙</span>
                <span>{{ isEn ? 'View on GitHub' : 'Kho Mã Nguồn GitHub' }}</span>
              </a>

              <router-link
                to="/privacy?game=tdrop" 
                class="inline-flex items-center gap-2 px-6 py-3.5 rounded-2xl glass-panel border border-slate-700 hover:border-cyan-400 text-white font-medium text-sm hover:text-cyan-300 transition-all hover:scale-[1.02] active:scale-95"
                @mouseenter="sound.playHover()"
                @click="sound.playClick()"
              >
                <span>🛡️</span>
                <span>{{ isEn ? 'Privacy Policy' : 'Chính Sách Bảo Mật' }}</span>
              </router-link>
            </div>

            <!-- Platform Availability Indicator Pills -->
            <div class="flex flex-wrap items-center justify-center lg:justify-start gap-2.5 pt-2 text-xs font-mono">
              <div class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-cyan-500/10 border border-cyan-500/30 text-cyan-300">
                <span class="w-1.5 h-1.5 rounded-full bg-cyan-400 animate-pulse"></span>
                <span>Windows 10 / 11: 64-bit Ready</span>
              </div>
              <div class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-indigo-500/10 border border-indigo-500/30 text-indigo-300">
                <span class="w-1.5 h-1.5 rounded-full bg-indigo-400"></span>
                <span>macOS: Apple Silicon & Intel</span>
              </div>
              <div class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-300">
                <span class="w-1.5 h-1.5 rounded-full bg-emerald-400"></span>
                <span>VietQR 1-Click VIP Auto Activation</span>
              </div>
            </div>

            <!-- Mini Spec Badges -->
            <div class="grid grid-cols-3 gap-3 pt-6 border-t border-slate-800/80 max-w-lg mx-auto lg:mx-0">
              <div class="text-center lg:text-left">
                <div class="text-2xl sm:text-3xl font-display font-black text-cyan-400">&lt; 15MS</div>
                <div class="text-xs text-slate-400 font-mono">Hotkey Reaction</div>
              </div>
              <div class="text-center lg:text-left">
                <div class="text-2xl sm:text-3xl font-display font-black text-indigo-400">AI OCR</div>
                <div class="text-xs text-slate-400 font-mono">Image-to-Text</div>
              </div>
              <div class="text-center lg:text-left">
                <div class="text-2xl sm:text-3xl font-display font-black text-emerald-400">VIETQR</div>
                <div class="text-xs text-slate-400 font-mono">Instant Licensing</div>
              </div>
            </div>

          </div>

          <!-- Right Column: Visual Product Showcase Card -->
          <div class="lg:col-span-5 flex justify-center">
            <div class="relative w-full max-w-md">
              <!-- Cyber Ambient Glow -->
              <div class="absolute -inset-1 bg-gradient-to-r from-cyan-500 to-indigo-600 rounded-3xl blur-2xl opacity-30 animate-pulse"></div>
              
              <div class="relative glass-panel rounded-3xl p-6 sm:p-8 border border-indigo-500/30 space-y-6">
                <!-- App Header in Card -->
                <div class="flex items-center justify-between">
                  <div class="flex items-center gap-3">
                    <div class="w-14 h-14 rounded-2xl bg-black/60 border border-indigo-500/40 p-2 flex items-center justify-center shadow-lg shadow-indigo-500/20">
                      <img src="/tdrop.png" alt="T-Drop Logo" class="w-full h-full object-contain" />
                    </div>
                    <div>
                      <h3 class="font-display font-black text-white text-lg">T-Drop Desktop</h3>
                      <p class="text-xs font-mono text-cyan-400">{{ tdropVersion }} • TXA Studio</p>
                    </div>
                  </div>
                  <span class="px-2.5 py-1 rounded-full text-[10px] font-mono font-bold uppercase bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">
                    LIVE
                  </span>
                </div>

                <!-- Simulated Clipboard History Items -->
                <div class="space-y-2.5 font-mono text-xs">
                  <div class="p-3 rounded-xl bg-black/60 border border-slate-800 space-y-1">
                    <div class="flex items-center justify-between text-[10px] text-slate-500">
                      <span class="text-cyan-400 font-bold">📋 CODE SNIPPET (Copied 2m ago)</span>
                      <span>#1</span>
                    </div>
                    <div class="text-slate-200 truncate">npm run build && git push origin main</div>
                  </div>

                  <div class="p-3 rounded-xl bg-indigo-950/40 border border-indigo-500/30 space-y-1">
                    <div class="flex items-center justify-between text-[10px] text-indigo-400">
                      <span class="font-bold">👁️ AI OCR EXTRACTED TEXT</span>
                      <span>#2</span>
                    </div>
                    <div class="text-indigo-200 text-[11px] leading-relaxed">
                      "TXA Studio - Nâng tầm năng suất làm việc với bộ tiện ích thông minh."
                    </div>
                  </div>

                  <div class="p-3 rounded-xl bg-black/60 border border-slate-800 space-y-1">
                    <div class="flex items-center justify-between text-[10px] text-slate-500">
                      <span class="text-emerald-400 font-bold">🎨 COLOR PALETTE / HEX</span>
                      <span>#3</span>
                    </div>
                    <div class="text-emerald-300 font-bold">#00F5FF • rgb(0, 245, 255)</div>
                  </div>
                </div>

                <!-- Feature checklist in card -->
                <div class="p-4 rounded-2xl bg-black/40 border border-slate-800 space-y-2 text-xs font-mono text-slate-300">
                  <div class="flex items-center gap-2">
                    <span class="text-emerald-400 font-bold">✓</span>
                    <span>Phím tắt toàn cục mở nhanh (Global Hotkey)</span>
                  </div>
                  <div class="flex items-center gap-2">
                    <span class="text-emerald-400 font-bold">✓</span>
                    <span>Hỗ trợ nhận diện chữ tiếng Việt & tiếng Anh</span>
                  </div>
                  <div class="flex items-center gap-2">
                    <span class="text-emerald-400 font-bold">✓</span>
                    <span>Bảo mật tuyệt đối, dữ liệu lưu cục bộ</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

        </div>
      </div>
    </section>

    <!-- ================================================================= -->
    <!-- 2. DETAILED FEATURES GRID -->
    <!-- ================================================================= -->
    <section class="py-20 border-t border-slate-800/80 relative">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        <div class="text-center max-w-3xl mx-auto mb-16 space-y-4">
          <div class="inline-block text-xs font-mono font-bold tracking-widest text-cyan-400 uppercase bg-cyan-500/10 px-3.5 py-1 rounded-full border border-cyan-500/20">
            NEXT-GEN DESKTOP UTILITY
          </div>
          <h2 class="text-3xl sm:text-5xl font-display font-black text-white tracking-tight">
            TÍNH NĂNG ĐỘT PHÁ <span class="bg-gradient-to-r from-cyan-400 to-indigo-400 bg-clip-text text-transparent">CỦA T-DROP</span>
          </h2>
          <p class="text-slate-400 text-sm sm:text-base leading-relaxed">
            Được xây dựng tối ưu cho lập trình viên, designer, người làm nội dung và nhân viên văn phòng cần tốc độ thao tác tối thượng.
          </p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          
          <div class="glass-card p-6 rounded-2xl space-y-4 border border-cyan-500/20">
            <div class="w-12 h-12 rounded-xl bg-cyan-500/10 border border-cyan-500/30 flex items-center justify-center text-cyan-400 text-2xl font-bold">
              📋
            </div>
            <h3 class="font-display font-bold text-lg text-white">
              {{ isEn ? 'Infinite Clipboard Vault' : 'Lịch Sử Copy Không Giới Hạn' }}
            </h3>
            <p class="text-slate-400 text-xs sm:text-sm leading-relaxed">
              {{ isEn 
                ? 'Never lose a copied text, link, code snippet, or color hex. Instant fuzzy search across thousands of historical clips.' 
                : 'Lưu trữ tự động mọi đoạn văn bản, đường link, mã màu hay đoạn code bạn từng copy. Tìm kiếm mờ (fuzzy search) tức thời chỉ trong tích tắc.' }}
            </p>
          </div>

          <div class="glass-card p-6 rounded-2xl space-y-4 border border-indigo-500/20">
            <div class="w-12 h-12 rounded-xl bg-indigo-500/10 border border-indigo-500/30 flex items-center justify-center text-indigo-400 text-2xl font-bold">
              👁️
            </div>
            <h3 class="font-display font-bold text-lg text-white">
              {{ isEn ? 'Smart AI OCR Text Extractor' : 'OCR Trích Xuất Ảnh Thành Chữ' }}
            </h3>
            <p class="text-slate-400 text-xs sm:text-sm leading-relaxed">
              {{ isEn 
                ? 'Capture any screen region to extract clean text instantly with specialized Vietnamese & English language recognition models.' 
                : 'Bóc tách văn bản từ ảnh chụp màn hình cực nhạy. Không cần gõ lại chữ từ hình ảnh hay tài liệu scan, hỗ trợ trọn vẹn dấu tiếng Việt.' }}
            </p>
          </div>

          <div class="glass-card p-6 rounded-2xl space-y-4 border border-emerald-500/20">
            <div class="w-12 h-12 rounded-xl bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400 text-2xl font-bold">
              💳
            </div>
            <h3 class="font-display font-bold text-lg text-white">
              {{ isEn ? 'VietQR Auto VIP Activation' : 'Tự Động Kích Hoạt VietQR' }}
            </h3>
            <p class="text-slate-400 text-xs sm:text-sm leading-relaxed">
              {{ isEn 
                ? 'Scan VietQR with any mobile banking app. License keys are issued automatically, securely bound to your machine hardware ID.' 
                : 'Quét mã VietQR chuyển khoản ngân hàng tự động. Hệ thống duyệt đơn và cấp mã bản quyền VIP hoặc PREMIUM gắn liền mã máy an toàn.' }}
            </p>
          </div>

          <div class="glass-card p-6 rounded-2xl space-y-4 border border-purple-500/20">
            <div class="w-12 h-12 rounded-xl bg-purple-500/10 border border-purple-500/30 flex items-center justify-center text-purple-400 text-2xl font-bold">
              🔒
            </div>
            <h3 class="font-display font-bold text-lg text-white">
              {{ isEn ? 'Local-First Privacy' : 'Bảo Mật Quyền Riêng Tư 100%' }}
            </h3>
            <p class="text-slate-400 text-xs sm:text-sm leading-relaxed">
              {{ isEn 
                ? 'All clipboard contents are encrypted and stored locally on your machine. Zero telemetry, zero external tracking.' 
                : 'Dữ liệu clipboard của bạn nằm trọn vẹn trong ổ cứng máy tính cá nhân. Cam kết không gửi lịch sử copy lên bất kỳ máy chủ bên thứ ba nào.' }}
            </p>
          </div>

        </div>

      </div>
    </section>

    <!-- ================================================================= -->
    <!-- 3. PRICING & LICENSES (VIETQR AUTOMATION) -->
    <!-- ================================================================= -->
    <section class="py-20 border-t border-slate-800/80 relative">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        <div class="text-center max-w-3xl mx-auto mb-16 space-y-4">
          <div class="inline-block text-xs font-mono font-bold tracking-widest text-emerald-400 uppercase bg-emerald-500/10 px-3.5 py-1 rounded-full border border-emerald-500/20">
            TRANSPARENT LICENSING
          </div>
          <h2 class="text-3xl sm:text-5xl font-display font-black text-white tracking-tight">
            CÁC GÓI BẢN QUYỀN <span class="text-emerald-400">VIETQR</span>
          </h2>
          <p class="text-slate-400 text-sm sm:text-base leading-relaxed">
            Giá ưu đãi hỗ trợ phát triển sản phẩm phần mềm tiện ích Việt.
          </p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-4xl mx-auto">
          
          <!-- VIP Plan -->
          <div class="p-8 rounded-3xl glass-panel border border-cyan-500/40 space-y-6 flex flex-col justify-between relative overflow-hidden group">
            <div class="space-y-4">
              <div class="flex items-center justify-between">
                <span class="px-3 py-1 rounded-full text-xs font-mono font-bold uppercase bg-cyan-500/20 text-cyan-300 border border-cyan-500/40">
                  GÓI VIP
                </span>
                <span class="text-xs font-mono text-slate-400">Thời hạn: 30 Ngày</span>
              </div>
              <div>
                <div class="text-4xl font-display font-black text-white">29.000 <span class="text-lg text-cyan-400">VNĐ</span></div>
                <div class="text-xs font-mono text-slate-400 mt-1">Chỉ ~900đ / ngày làm việc hiệu quả</div>
              </div>
              <ul class="space-y-2.5 text-xs font-mono text-slate-300 pt-2 border-t border-slate-800">
                <li class="flex items-center gap-2"><span class="text-cyan-400">✓</span> Lịch sử Clipboard không giới hạn 30 ngày</li>
                <li class="flex items-center gap-2"><span class="text-cyan-400">✓</span> Nhận diện ảnh thành chữ AI OCR không giới hạn</li>
                <li class="flex items-center gap-2"><span class="text-cyan-400">✓</span> Phím tắt toàn cục tùy biến theo ý thích</li>
                <li class="flex items-center gap-2"><span class="text-cyan-400">✓</span> Tự động kích hoạt qua quét mã VietQR</li>
              </ul>
            </div>
            <a 
              href="https://github.com/TXAVL/T-Drop/releases" 
              target="_blank" 
              class="w-full py-3.5 px-6 rounded-2xl bg-cyan-500/20 hover:bg-cyan-500/30 border border-cyan-500/50 text-cyan-300 font-display font-black text-xs uppercase tracking-wider text-center transition-all"
            >
              Tải App & Trải Nghiệm Ngay
            </a>
          </div>

          <!-- PREMIUM Plan -->
          <div class="p-8 rounded-3xl glass-panel border-2 border-indigo-500/60 shadow-xl shadow-indigo-950/50 space-y-6 flex flex-col justify-between relative overflow-hidden group">
            <div class="absolute top-0 right-0 bg-gradient-to-l from-indigo-500 to-purple-600 text-white text-[10px] font-mono font-bold px-4 py-1 rounded-bl-xl uppercase tracking-wider">
              PHỔ BIẾN NHẤT
            </div>
            <div class="space-y-4">
              <div class="flex items-center justify-between">
                <span class="px-3 py-1 rounded-full text-xs font-mono font-bold uppercase bg-indigo-500/20 text-indigo-300 border border-indigo-500/40">
                  GÓI PREMIUM
                </span>
                <span class="text-xs font-mono text-slate-400">Thời hạn: 60 Ngày</span>
              </div>
              <div>
                <div class="text-4xl font-display font-black text-white">49.000 <span class="text-lg text-indigo-400">VNĐ</span></div>
                <div class="text-xs font-mono text-slate-400 mt-1">Tiết kiệm 18% so với gia hạn từng tháng</div>
              </div>
              <ul class="space-y-2.5 text-xs font-mono text-slate-300 pt-2 border-t border-slate-800">
                <li class="flex items-center gap-2"><span class="text-indigo-400">✓</span> Toàn bộ đặc quyền của gói VIP</li>
                <li class="flex items-center gap-2"><span class="text-indigo-400">✓</span> Hạn dùng nhân đôi: trọn vẹn 60 ngày</li>
                <li class="flex items-center gap-2"><span class="text-indigo-400">✓</span> Ưu tiên hỗ trợ kỹ thuật từ TXA Studio Dev Team</li>
                <li class="flex items-center gap-2"><span class="text-indigo-400">✓</span> Cập nhật các bản cập nhật tính năng mới nhất</li>
              </ul>
            </div>
            <a 
              href="https://github.com/TXAVL/T-Drop/releases" 
              target="_blank" 
              class="w-full py-3.5 px-6 rounded-2xl bg-gradient-to-r from-cyan-400 via-sky-500 to-indigo-600 text-slate-950 font-display font-black text-xs uppercase tracking-wider text-center shadow-lg shadow-indigo-500/30 hover:scale-[1.02] active:scale-95 transition-all"
            >
              Tải App & Quét VietQR Mua Ngay
            </a>
          </div>

        </div>

      </div>
    </section>

  </div>
</template>

<script setup>
import { inject, ref, computed, onMounted } from 'vue';
import { sound } from '../services/sound.js';
import { getTDropLatestVersion } from '../services/github.js';

const currentLang = inject('currentLang', ref('vi'));
const isEn = computed(() => currentLang.value === 'en');
const tdropVersion = ref('v0.1.6');

onMounted(async () => {
  tdropVersion.value = await getTDropLatestVersion();
});
</script>
