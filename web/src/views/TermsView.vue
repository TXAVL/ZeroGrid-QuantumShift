<template>
  <div class="relative z-10 py-12 lg:py-16">
    <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
      
      <!-- Top Title & Breadcrumb -->
      <div class="mb-6 pb-6 border-b border-slate-800/80 flex flex-wrap items-center justify-between gap-4">
        <div>
          <div class="flex items-center gap-2 text-xs font-mono text-cyan-400 uppercase tracking-widest mb-1">
            <router-link to="/" class="hover:underline">TXA STUDIO</router-link>
            <span>/</span>
            <span>LEGAL & COMPLIANCE</span>
          </div>
          <h1 class="text-2xl sm:text-4xl font-display font-black text-white">
            {{ isEn ? 'Terms of Service' : 'Điều Khoản Dịch Vụ' }}
          </h1>
          <p class="text-xs text-slate-400 font-mono mt-1">
            {{ isEn 
              ? 'Effective Date: September 2026 • Official Terms for TXA Studio Ecosystem' 
              : 'Có hiệu lực từ: Tháng 09/2026 • Điều khoản chính thức cho hệ sinh thái TXA Studio' }}
          </p>
        </div>

        <!-- Compliance Pill -->
        <div class="flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-cyan-500/10 border border-cyan-500/30 font-mono text-xs text-cyan-400">
          <span class="w-2 h-2 rounded-full bg-cyan-400 animate-pulse"></span>
          <span>TERMS: {{ currentProduct.slug.toUpperCase() }}</span>
        </div>
      </div>

      <!-- Interactive Product Switcher Tabs -->
      <div class="flex flex-wrap items-center justify-between gap-4 mb-8">
        <div class="inline-flex p-1 rounded-2xl bg-slate-900/90 border border-slate-800 font-mono text-xs">
          <button
            @click="switchProduct('quantumshift')"
            class="flex items-center gap-2 px-4 py-2.5 rounded-xl transition-all"
            :class="currentSlug === 'quantumshift' ? 'bg-cyan-500 text-slate-950 font-bold shadow-neon-cyan' : 'text-slate-400 hover:text-white'"
          >
            <span>🎮</span>
            <span>Zero Grid: Quantum Shift</span>
            <span class="text-[10px] opacity-80 font-normal">({{ isEn ? 'Game' : 'Game' }})</span>
          </button>
          <button
            @click="switchProduct('shieldblock')"
            class="flex items-center gap-2 px-4 py-2.5 rounded-xl transition-all"
            :class="currentSlug === 'shieldblock' ? 'bg-pink-500 text-slate-950 font-bold shadow-neon-pink' : 'text-slate-400 hover:text-white'"
          >
            <span>🛡️</span>
            <span>ShieldBlock Pro</span>
            <span class="text-[10px] opacity-80 font-normal">({{ isEn ? 'Extension' : 'Tiện ích' }})</span>
          </button>
        </div>

        <div class="text-xs text-slate-500 font-mono">
          {{ isEn ? 'Select a product to view specific terms' : 'Chọn sản phẩm để xem điều khoản tương ứng' }}
        </div>
      </div>

      <!-- Target Info Banner -->
      <div class="glass-panel rounded-2xl p-6 mb-10 border border-cyan-500/20 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-6">
        <div class="flex items-center gap-4">
          <div class="w-14 h-14 rounded-2xl bg-gradient-to-tr from-cyan-400 via-sky-500 to-pink-500 p-[2px] shadow-lg shadow-cyan-500/20 shrink-0">
            <img 
              :src="currentProduct.icon || (isExtension ? '/shieldblock.svg' : '/logo_master.png')" 
              :alt="currentProduct.title" 
              class="w-full h-full rounded-[14px] object-cover bg-slate-950 p-1" 
            />
          </div>
          <div>
            <div class="flex flex-wrap items-center gap-2">
              <h2 class="font-display font-bold text-lg text-white">{{ currentProduct.title }}</h2>
              <span class="text-[10px] font-mono px-2 py-0.5 rounded bg-slate-800 text-slate-300">
                {{ currentProduct.package_id }}
              </span>
              <span 
                class="text-[10px] font-mono px-2 py-0.5 rounded-full border"
                :class="isExtension ? 'bg-pink-500/10 text-pink-400 border-pink-500/30' : 'bg-cyan-500/10 text-cyan-400 border-cyan-500/30'"
              >
                {{ isExtension ? 'CHROMIUM EXTENSION' : 'GOOGLE PLAY GAME' }}
              </span>
            </div>
            <div class="text-xs text-slate-400 font-mono mt-0.5">
              {{ isEn ? 'Developer' : 'Nhà phát triển' }}: {{ currentProduct.developer_name }} • 
              {{ isEn ? 'Legal Contact' : 'Email pháp lý' }}: <a :href="'mailto:' + currentProduct.support_email" class="text-cyan-400 hover:underline">{{ currentProduct.support_email }}</a>
            </div>
          </div>
        </div>

        <!-- Quick Links: Privacy & Deletion -->
        <div class="flex items-center gap-2 shrink-0">
          <router-link
            :to="'/privacy/' + currentSlug"
            class="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-slate-900 hover:bg-slate-800 border border-slate-700 text-slate-300 hover:text-white font-mono text-xs transition-all"
          >
            <span>📜</span>
            <span>{{ isEn ? 'Privacy' : 'Quyền Riêng Tư' }}</span>
          </router-link>
          <router-link
            :to="'/delete-account/' + currentSlug"
            class="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-pink-500/10 hover:bg-pink-500/20 border border-pink-500/30 text-pink-300 hover:text-white font-mono text-xs transition-all"
          >
            <span>🗑️</span>
            <span>{{ isEn ? 'Data Erasure' : 'Xóa Dữ Liệu' }}</span>
          </router-link>
        </div>
      </div>

      <!-- ============================================================= -->
      <!-- TERMS CONTENT: GAME (Zero Grid) -->
      <!-- ============================================================= -->
      <div v-if="!isExtension" class="glass-panel rounded-3xl p-6 sm:p-10 border border-slate-800 space-y-8 text-slate-300 text-sm leading-relaxed">
        
        <!-- Section 1 -->
        <section class="space-y-3">
          <h2 class="text-lg font-display font-bold text-white flex items-center gap-2">
            <span class="text-cyan-400 font-mono">01.</span>
            {{ isEn ? 'Acceptance of Terms & Eligibility' : 'Chấp Thuận Điều Khoản & Tính Hợp Lệ' }}
          </h2>
          <p>
            {{ isEn 
              ? 'By downloading, installing, accessing, or playing Zero Grid: Quantum Shift, you confirm that you have read, understood, and agreed to be legally bound by these Terms of Service. If you do not agree, please uninstall and discontinue using the game.' 
              : 'Bằng việc tải, cài đặt hoặc trải nghiệm trò chơi Zero Grid: Quantum Shift, bạn xác nhận đã đọc, hiểu và đồng ý tuân thủ toàn bộ các điều khoản dịch vụ tại tài liệu này. Nếu không đồng ý với bất kỳ điều khoản nào, vui lòng gỡ cài đặt và ngừng sử dụng trò chơi.' }}
          </p>
        </section>

        <!-- Section 2 -->
        <section class="space-y-3">
          <h2 class="text-lg font-display font-bold text-white flex items-center gap-2">
            <span class="text-cyan-400 font-mono">02.</span>
            {{ isEn ? 'Fair Play, Competitive Integrity & Anti-Cheat' : 'Chính Sách Chơi Công Bằng & Chống Gian Lận' }}
          </h2>
          <p>
            {{ isEn 
              ? 'Zero Grid is designed as an intellectually challenging competitive puzzle matrix. We enforce strict anti-cheat policies. Any deliberate manipulation of local memory, clock speed manipulation (speed hacks), spoofing game seeds, or forging ghost replays to artificially climb leaderboards will result in immediate voiding of records and permanent hardware blacklisting.' 
              : 'Zero Grid được thiết kế như một đấu trường giải đố trí tuệ đề cao tính công bằng. Mọi hành vi can thiệp bộ nhớ (memory hack), ép xung tốc độ game (speed hack), giả mạo gói tin hạt giống ma trận hoặc làm sai lệch bước đi bóng ma (Ghost Replay) nhằm trục lợi bảng xếp hạng sẽ bị hủy kết quả và khóa vĩnh viễn quyền ghi điểm trên máy chủ.' }}
          </p>
        </section>

        <!-- Section 3 -->
        <section class="space-y-3">
          <h2 class="text-lg font-display font-bold text-white flex items-center gap-2">
            <span class="text-cyan-400 font-mono">03.</span>
            {{ isEn ? 'Virtual Items & Hint Credits' : 'Vật Phẩm Ảo & Điểm Gợi Ý' }}
          </h2>
          <p>
            {{ isEn 
              ? 'Hints, solution previews, and energy refills provided within Zero Grid are virtual gameplay utilities with zero monetary exchange value. They cannot be refunded, transferred, or exchanged for real currency. TXA Studio reserves the right to rebalance or update hint mechanics to maintain optimal puzzle balance.' 
              : 'Các lượt gợi ý giải thuật, bước đi mẫu và tài nguyên trong Zero Grid là vật phẩm ảo hỗ trợ giải đố, không có giá trị quy đổi thành tiền mặt hay chuyển nhượng. TXA Studio có toàn quyền cân bằng và tối ưu hóa cơ chế gợi ý để đảm bảo trải nghiệm chơi game tốt nhất.' }}
          </p>
        </section>

        <!-- Section 4 -->
        <section class="space-y-3">
          <h2 class="text-lg font-display font-bold text-white flex items-center gap-2">
            <span class="text-cyan-400 font-mono">04.</span>
            {{ isEn ? 'Intellectual Property Rights' : 'Quyền Sở Hữu Trí Tuệ' }}
          </h2>
          <p>
            {{ isEn 
              ? 'All algorithmic architectures (including the 100% Solvable Inverse Matrix Generator), audio assets, UI design tokens, brand identities, and trademarks belong exclusively to TXA Studio. Decompilation for commercial resale or unauthorized derivation is strictly prohibited.' 
              : 'Toàn bộ thuật toán (bao gồm Bộ sinh ma trận giải ngược 100% có nghiệm), hiệu ứng âm thanh Sci-Fi, phong cách thiết kế giao diện, logo và thương hiệu TXA Studio đều thuộc quyền sở hữu trí tuệ độc quyền của TXA Studio. Nghiêm cấm mọi hành vi dịch ngược nhằm mục đích thương mại khi chưa có sự đồng ý bằng văn bản.' }}
          </p>
        </section>

        <!-- Section 5 -->
        <section class="space-y-3">
          <h2 class="text-lg font-display font-bold text-white flex items-center gap-2">
            <span class="text-cyan-400 font-mono">05.</span>
            {{ isEn ? 'Contact & Dispute Resolution' : 'Liên Hệ Pháp Lý & Tranh Chấp' }}
          </h2>
          <p>
            {{ isEn 
              ? 'For disputes, inquiries, or licensing matters relating to Zero Grid, please contact our legal desk at: txasoftdev@gmail.com' 
              : 'Mọi khiếu nại, phản hồi hoặc yêu cầu cấp phép liên quan đến tựa game Zero Grid, vui lòng liên hệ bộ phận pháp lý của chúng tôi qua: txasoftdev@gmail.com' }}
          </p>
        </section>

      </div>

      <!-- ============================================================= -->
      <!-- TERMS CONTENT: EXTENSION (ShieldBlock) -->
      <!-- ============================================================= -->
      <div v-else class="glass-panel rounded-3xl p-6 sm:p-10 border border-slate-800 space-y-8 text-slate-300 text-sm leading-relaxed">
        
        <!-- Section 1 -->
        <section class="space-y-3">
          <h2 class="text-lg font-display font-bold text-white flex items-center gap-2">
            <span class="text-pink-400 font-mono">01.</span>
            {{ isEn ? 'Acceptance of Extension Terms' : 'Chấp Thuận Điều Khoản Tiện Ích' }}
          </h2>
          <p>
            {{ isEn 
              ? 'By installing, configuring, or using ShieldBlock - Ad & Tracker Blocker Pro from the Chrome Web Store or other authorized distribution channels, you agree to these Terms of Service and our Privacy Policy. If you disagree with any part of these terms, you should remove the extension immediately.' 
              : 'Bằng việc cài đặt, cấu hình hoặc sử dụng tiện ích ShieldBlock - Ad & Tracker Blocker Pro từ Chrome Web Store hoặc các kênh phân phối chính thức, bạn đồng ý chịu ràng buộc bởi các Điều Khoản Dịch Vụ này và Chính Sách Quyền Riêng Tư đi kèm. Nếu bạn không đồng ý, vui lòng gỡ cài đặt tiện ích khỏi trình duyệt.' }}
          </p>
        </section>

        <!-- Section 2 -->
        <section class="space-y-3">
          <h2 class="text-lg font-display font-bold text-white flex items-center gap-2">
            <span class="text-pink-400 font-mono">02.</span>
            {{ isEn ? 'Permitted Use & Content Filtering Philosophy' : 'Mục Đích Sử Dụng & Nguyên Tắc Lọc Nội Dung' }}
          </h2>
          <p>
            {{ isEn 
              ? 'ShieldBlock is engineered as a user-empowered privacy and security utility. It operates 100% locally on your browser using Chromium declarativeNetRequest and cosmetic element hiding to shield you against malvertising, tracking scripts, and intrusive traps. ShieldBlock does not intercept passwords, personal data, or private communication.' 
              : 'ShieldBlock được phát triển như một công cụ bảo vệ quyền riêng tư và an toàn thông tin do người dùng làm chủ. Tiện ích vận hành 100% cục bộ trên trình duyệt thông qua cơ chế declarativeNetRequest và bộ lọc thẩm mỹ nhằm ngăn chặn quảng cáo độc hại, mã theo dõi và các bẫy chuyển hướng lừa đảo. ShieldBlock không can thiệp mật khẩu, dữ liệu cá nhân hay thông tin mật.' }}
          </p>
          <p>
            {{ isEn
              ? 'You are granted a revocable, non-exclusive, royalty-free license to use the extension for personal or corporate web browsing.'
              : 'Bạn được cấp quyền sử dụng tiện ích miễn phí, không độc quyền cho nhu cầu duyệt web cá nhân hoặc doanh nghiệp.' }}
          </p>
        </section>

        <!-- Section 3 -->
        <section class="space-y-3">
          <h2 class="text-lg font-display font-bold text-white flex items-center gap-2">
            <span class="text-pink-400 font-mono">03.</span>
            {{ isEn ? 'Open-Source Compliance & Upstream Attribution' : 'Tuân Thủ Mã Nguồn Mở & Giấy Phép' }}
          </h2>
          <p>
            {{ isEn 
              ? 'ShieldBlock respects open-source community standards. Core filtering rule engines and syntax implementations comply with applicable open-source licenses (such as GPL-3.0 / MPL-2.0). Users are free to audit the source code, inspect rule definitions, and customize their filter lists.' 
              : 'ShieldBlock tôn trọng và tuân thủ các chuẩn mực cộng đồng nguồn mở. Các thuật toán khớp luật lọc tuân thủ nghiêm túc các giấy phép phần mềm nguồn mở tương ứng (GPL-3.0 / MPL-2.0). Người dùng có toàn quyền kiểm toán mã nguồn, kiểm tra cú pháp luật chặn và tùy biến danh sách lọc cá nhân.' }}
          </p>
        </section>

        <!-- Section 4 -->
        <section class="space-y-3">
          <h2 class="text-lg font-display font-bold text-white flex items-center gap-2">
            <span class="text-pink-400 font-mono">04.</span>
            {{ isEn ? 'TXA Studio ID Cloud Sync Services' : 'Dịch Vụ Đồng Bộ Đám Mây TXA Studio ID' }}
          </h2>
          <p>
            {{ isEn 
              ? 'Optional cloud synchronization allows you to back up custom whitelist entries and filter preferences to TXA Studio cloud servers powered by Supabase. You agree not to upload unlawful, harmful, or copyright-infringing content through the custom filter sync endpoints.' 
              : 'Tính năng đồng bộ đám mây tùy chọn cho phép bạn sao lưu danh sách trắng và quy tắc cá nhân lên máy chủ đám mây TXA Studio qua nền tảng Supabase. Bạn cam kết không lạm dụng dịch vụ đồng bộ đám mây để lưu trữ các đoạn mã độc hại hoặc vi phạm pháp luật.' }}
          </p>
        </section>

        <!-- Section 5 -->
        <section class="space-y-3">
          <h2 class="text-lg font-display font-bold text-white flex items-center gap-2">
            <span class="text-pink-400 font-mono">05.</span>
            {{ isEn ? 'Website Compatibility & Disclaimer of Warranties' : 'Tương Thích Trang Web & Miễn Trừ Trách Nhiệm' }}
          </h2>
          <p>
            {{ isEn 
              ? 'Because third-party websites frequently update their DOM structures, scripts, and anti-adblock detection routines, ShieldBlock is provided "AS IS" and "AS AVAILABLE". TXA Studio makes reasonable efforts to maintain high filter accuracy, but does not guarantee that every webpage will render flawlessly without disabling specific filters.' 
              : 'Do các trang web bên thứ ba liên tục thay đổi cấu trúc mã nguồn và các cơ chế chống chặn quảng cáo, ShieldBlock được cung cấp trên cơ sở "NGUYÊN TRẠNG" (AS IS). TXA Studio nỗ lực cập nhật bộ lọc để đạt hiệu quả cao nhất, nhưng không cam kết mọi website đều hiển thị nguyên vẹn 100% nếu không bật chế độ tạm ngưng lọc.' }}
          </p>
        </section>

        <!-- Section 6 -->
        <section class="space-y-3">
          <h2 class="text-lg font-display font-bold text-white flex items-center gap-2">
            <span class="text-pink-400 font-mono">06.</span>
            {{ isEn ? 'Legal Contact & Inquiries' : 'Liên Hệ Pháp Lý & Khiếu Nại' }}
          </h2>
          <p>
            {{ isEn 
              ? 'For licensing inquiries, bug reports, or legal questions concerning ShieldBlock, please reach out to: txasoftdev@gmail.com' 
              : 'Mọi thắc mắc về giấy phép, báo cáo lỗi hoặc vấn đề pháp lý liên quan đến ShieldBlock, vui lòng gửi email đến: txasoftdev@gmail.com' }}
          </p>
        </section>

      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, computed, inject, onMounted, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { getGameInfo, DEFAULT_GAME } from '../services/supabase.js';
import { sound } from '../services/sound.js';

const route = useRoute();
const router = useRouter();
const currentLang = inject('currentLang', ref('vi'));
const isEn = computed(() => currentLang.value === 'en');

const currentSlug = computed(() => {
  const p = route.params.gameSlug || route.query.app || route.query.game || '';
  const lower = p.toLowerCase();
  if (lower.includes('shield')) return 'shieldblock';
  if (lower.includes('zero') || lower.includes('quantum')) return 'quantumshift';
  return p ? lower : 'quantumshift';
});

const isExtension = computed(() => {
  return currentSlug.value === 'shieldblock' || currentProduct.value.type === 'extension';
});

const currentProduct = ref({ ...DEFAULT_GAME });

function switchProduct(slug) {
  sound.playClick();
  router.push({ path: `/terms/${slug}` });
}

async function loadProduct() {
  currentProduct.value = await getGameInfo(currentSlug.value);
}

onMounted(loadProduct);
watch(() => route.params.gameSlug, loadProduct);
watch(() => route.query.game, loadProduct);
watch(() => route.query.app, loadProduct);
</script>
