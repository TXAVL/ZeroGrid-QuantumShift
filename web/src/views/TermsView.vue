<template>
  <div class="relative z-10 py-12 lg:py-16">
    <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
      
      <!-- Top Title -->
      <div class="mb-8 pb-6 border-b border-slate-800/80">
        <div class="flex items-center gap-2 text-xs font-mono text-cyan-400 uppercase tracking-widest mb-1">
          <router-link to="/" class="hover:underline">TXA STUDIO</router-link>
          <span>/</span>
          <span>LEGAL</span>
        </div>
        <h1 class="text-2xl sm:text-4xl font-display font-black text-white">
          {{ isEn ? 'Terms of Service' : 'Điều Khoản Dịch Vụ' }}
        </h1>
        <p class="text-xs text-slate-400 font-mono mt-1">
          Last Updated: 2026-09-05 • Effective for Zero Grid: Quantum Shift and all TXA Studio games
        </p>
      </div>

      <!-- Terms Clauses Card -->
      <div class="glass-panel rounded-3xl p-6 sm:p-10 border border-slate-800 space-y-8 text-slate-300 text-sm leading-relaxed">
        
        <!-- Section 1 -->
        <section class="space-y-3">
          <h2 class="text-lg font-display font-bold text-white flex items-center gap-2">
            <span class="text-cyan-400 font-mono">01.</span>
            {{ isEn ? 'Acceptance of Terms' : 'Chấp Thuận Điều Khoản' }}
          </h2>
          <p>
            {{ isEn 
              ? 'By downloading, installing, or playing Zero Grid: Quantum Shift, you agree to be legally bound by these Terms of Service. If you do not agree with any provision, you must immediately uninstall and discontinue using the game.' 
              : 'Bằng việc tải, cài đặt hoặc tham gia chơi trò chơi Zero Grid: Quantum Shift, bạn đồng ý tuân thủ toàn bộ các điều khoản được quy định tại đây. Nếu không đồng ý với bất kỳ điều khoản nào, bạn có thể gỡ cài đặt và ngừng sử dụng trò chơi bất cứ lúc nào.' }}
          </p>
        </section>

        <!-- Section 2 -->
        <section class="space-y-3">
          <h2 class="text-lg font-display font-bold text-white flex items-center gap-2">
            <span class="text-cyan-400 font-mono">02.</span>
            {{ isEn ? 'Fair Play & Anti-Cheat Policy' : 'Chính Sách Chơi Công Bằng & Chống Gian Lận' }}
          </h2>
          <p>
            {{ isEn 
              ? 'TXA Studio upholds high standards of competitive integrity for all leaderboard puzzles. Any attempt to decompile, inject memory hacks, modify local game speed, or forge replay seeds to manipulate leaderboards will result in immediate disqualification and blacklisting from our cloud leaderboard.' 
              : 'TXA Studio đề cao tính cạnh tranh công bằng. Mọi hành vi can thiệp bộ nhớ (memory hack), chỉnh sửa tốc độ game, giả mạo gói tin seed hoặc giải mã ngược nhằm trục lợi điểm số bảng xếp hạng sẽ bị hủy kết quả và chặn quyền ghi điểm trên hệ thống máy chủ.' }}
          </p>
        </section>

        <!-- Section 3 -->
        <section class="space-y-3">
          <h2 class="text-lg font-display font-bold text-white flex items-center gap-2">
            <span class="text-cyan-400 font-mono">03.</span>
            {{ isEn ? 'Intellectual Property Rights' : 'Quyền Sở Hữu Trí Tuệ' }}
          </h2>
          <p>
            {{ isEn 
              ? 'All visual assets, code algorithms, inverse generation logic, sound effects, and trademarks associated with TXA Studio and Zero Grid: Quantum Shift are the exclusive intellectual property of TXA Studio. Unauthorized reproduction or commercial distribution is prohibited.' 
              : 'Toàn bộ đồ họa, thuật toán sinh ma trận ngược, mã nguồn, âm thanh và thương hiệu TXA Studio đều thuộc quyền sở hữu trí tuệ độc quyền của TXA Studio. Nghiêm cấm mọi hành vi sao chép, phân phối thương mại khi chưa có văn bản chấp thuận.' }}
          </p>
        </section>

        <!-- Section 4 -->
        <section class="space-y-3">
          <h2 class="text-lg font-display font-bold text-white flex items-center gap-2">
            <span class="text-cyan-400 font-mono">04.</span>
            {{ isEn ? 'Contact & Dispute Resolution' : 'Liên Hệ & Giải Quyết Khiếu Nại' }}
          </h2>
          <p>
            {{ isEn 
              ? 'For disputes, license queries, or player support, please contact our legal desk at: txasoftdev@gmail.com' 
              : 'Mọi thắc mắc hoặc yêu cầu hỗ trợ pháp lý, vui lòng gửi thư điện tử đến hòm thư chính thức: txasoftdev@gmail.com' }}
          </p>
        </section>

      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, computed, inject } from 'vue';

const currentLang = inject('currentLang', ref('vi'));
const isEn = computed(() => currentLang.value === 'en');
</script>
