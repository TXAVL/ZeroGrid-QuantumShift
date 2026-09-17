<template>
  <div class="relative z-10 py-12 lg:py-16">
    <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
      
      <!-- Top Header Breadcrumb & Status -->
      <div class="flex flex-wrap items-center justify-between gap-4 mb-6 pb-6 border-b border-slate-800/80">
        <div>
          <div class="flex items-center gap-2 text-xs font-mono text-cyan-400 uppercase tracking-widest mb-1">
            <router-link to="/" class="hover:underline">TXA STUDIO</router-link>
            <span>/</span>
            <span>LEGAL & PRIVACY COMPLIANCE</span>
          </div>
          <h1 class="text-2xl sm:text-4xl font-display font-black text-white">
            {{ isEn ? 'Privacy Policy' : 'Chính Sách Quyền Riêng Tư' }}
          </h1>
        </div>

        <!-- Live Sync Badge -->
        <div class="flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-cyan-500/10 border border-cyan-500/30 font-mono text-xs text-cyan-400">
          <span class="w-2 h-2 rounded-full bg-cyan-400 animate-pulse"></span>
          <span>COMPLIANCE: {{ currentProduct.slug.toUpperCase() }}</span>
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
          {{ isEn ? 'Select a product to view specific policy clauses' : 'Chọn sản phẩm để xem chính sách chi tiết' }}
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
              {{ isEn ? 'Contact' : 'Email hỗ trợ' }}: <a :href="'mailto:' + currentProduct.support_email" class="text-cyan-400 hover:underline">{{ currentProduct.support_email }}</a>
            </div>
          </div>
        </div>

        <!-- Actions: Terms & Data Erasure Portal -->
        <div class="flex items-center gap-2 shrink-0">
          <router-link
            :to="'/terms/' + currentSlug"
            class="inline-flex items-center gap-1.5 px-4 py-2.5 rounded-xl bg-slate-900 hover:bg-slate-800 border border-slate-700 text-slate-300 hover:text-white font-mono text-xs transition-all"
          >
            <span>📜</span>
            <span>{{ isEn ? 'Terms of Service' : 'Điều Khoản Dịch Vụ' }}</span>
          </router-link>
          <router-link
            :to="deletionRoute"
            class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-gradient-to-r from-pink-500/20 to-purple-500/20 border border-pink-500/40 text-pink-300 hover:text-white hover:border-pink-400 hover:shadow-neon-pink font-display font-bold text-xs uppercase tracking-wider transition-all"
          >
            <svg class="w-4 h-4 text-pink-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
            </svg>
            <span>{{ isEn ? 'Data Erasure' : 'Cổng Xóa Dữ Liệu' }}</span>
          </router-link>
        </div>
      </div>

      <!-- Quick Summary Matrix Cards (Dynamic per product type) -->
      <div v-if="!isExtension" class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-10">
        <div class="glass-card p-4 rounded-xl border border-cyan-500/20">
          <div class="text-xs font-mono text-cyan-400 uppercase tracking-wider mb-1">
            {{ isEn ? 'DATA COLLECTION' : 'DỮ LIỆU THU THẬP' }}
          </div>
          <div class="text-sm font-bold text-white">
            {{ isEn ? 'Strict Minimalist (Zero PII)' : 'Tối giản (Không định danh)' }}
          </div>
          <div class="text-xs text-slate-400 mt-1">
            {{ isEn ? 'No name, phone, address or contacts collected.' : 'Không thu thập danh bạ, vị trí hay số điện thoại.' }}
          </div>
        </div>

        <div class="glass-card p-4 rounded-xl border border-pink-500/20">
          <div class="text-xs font-mono text-pink-400 uppercase tracking-wider mb-1">
            {{ isEn ? 'ADVERTISING & ADS' : 'QUẢNG CÁO' }}
          </div>
          <div class="text-sm font-bold text-white">
            {{ isEn ? 'Google AdMob Certified' : 'Google AdMob Chuẩn' }}
          </div>
          <div class="text-xs text-slate-400 mt-1">
            {{ isEn ? 'Non-intrusive rewarded & interstitial throttled.' : 'Tuân thủ giới hạn tần suất, không spam video.' }}
          </div>
        </div>

        <div class="glass-card p-4 rounded-xl border border-emerald-500/20">
          <div class="text-xs font-mono text-emerald-400 uppercase tracking-wider mb-1">
            {{ isEn ? 'DATA RETENTION & RIGHTS' : 'LƯU TRỮ & QUYỀN LỢI' }}
          </div>
          <div class="text-sm font-bold text-white">
            {{ isEn ? 'Full Erasure on Demand' : 'Xóa sạch khi có yêu cầu' }}
          </div>
          <div class="text-xs text-slate-400 mt-1">
            {{ isEn ? 'Self-service deletion processed in < 48h.' : 'Tự động gửi yêu cầu, xử lý dưới 48 giờ.' }}
          </div>
        </div>
      </div>

      <div v-else class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-10">
        <div class="glass-card p-4 rounded-xl border border-cyan-500/20">
          <div class="text-xs font-mono text-cyan-400 uppercase tracking-wider mb-1">
            {{ isEn ? 'DATA COLLECTION' : 'DỮ LIỆU THU THẬP' }}
          </div>
          <div class="text-sm font-bold text-white">
            {{ isEn ? 'Zero Telemetry & No Logs' : 'Không Thu Thập Lịch Sử' }}
          </div>
          <div class="text-xs text-slate-400 mt-1">
            {{ isEn ? 'No browsing history, URLs, search queries, or form inputs collected.' : 'Không ghi nhận lịch sử duyệt web, URL hay nội dung biểu mẫu.' }}
          </div>
        </div>

        <div class="glass-card p-4 rounded-xl border border-pink-500/20">
          <div class="text-xs font-mono text-pink-400 uppercase tracking-wider mb-1">
            {{ isEn ? 'CONTENT FILTERING' : 'CƠ CHẾ LỌC NỘI DUNG' }}
          </div>
          <div class="text-sm font-bold text-white">
            {{ isEn ? 'Local Engine & declarativeNetRequest' : 'Xử Lý Cục Bộ Trên Trình Duyệt' }}
          </div>
          <div class="text-xs text-slate-400 mt-1">
            {{ isEn ? 'Fast on-device rule matching. Zero VPN tunneling or proxy redirection.' : 'So khớp bộ lọc trực tiếp trong trình duyệt, không qua proxy/VPN trung gian.' }}
          </div>
        </div>

        <div class="glass-card p-4 rounded-xl border border-emerald-500/20">
          <div class="text-xs font-mono text-emerald-400 uppercase tracking-wider mb-1">
            {{ isEn ? 'CLOUD SYNC & PRIVACY' : 'ĐỒNG BỘ ĐÁM MÂY' }}
          </div>
          <div class="text-sm font-bold text-white">
            {{ isEn ? 'Optional TXA Studio ID' : 'Tùy Chọn TXA Studio ID' }}
          </div>
          <div class="text-xs text-slate-400 mt-1">
            {{ isEn ? 'Syncs only user custom rules & whitelist. Full erasure anytime.' : 'Chỉ đồng bộ danh sách quy tắc tùy biến & whitelist. Xóa sạch tức thì khi yêu cầu.' }}
          </div>
        </div>
      </div>

      <!-- Policy Content Clauses: GAME (Zero Grid) -->
      <div v-if="!isExtension" class="glass-panel rounded-2xl p-6 sm:p-10 border border-slate-800 space-y-10 text-slate-300 text-sm leading-relaxed">
        
        <!-- Section 1 -->
        <section class="space-y-3">
          <h3 class="text-lg sm:text-xl font-display font-bold text-white flex items-center gap-2">
            <span class="text-cyan-400 font-mono text-base">01.</span>
            {{ isEn ? 'Introduction & Scope' : 'Giới Thiệu & Phạm Vi Áp Dụng' }}
          </h3>
          <p>
            {{ isEn 
              ? 'This Privacy Policy describes how TXA Studio ("we", "us", or "our") collects, uses, and safeguards information when you play ' + currentProduct.title + ' on Android (Google Play) and other supported operating systems.' 
              : 'Chính sách Quyền riêng tư này mô tả cách TXA Studio ("chúng tôi") thu thập, sử dụng và bảo vệ thông tin khi bạn trải nghiệm tựa game ' + currentProduct.title + ' trên nền tảng Android (Google Play) cũng như các nền tảng liên quan.' }}
          </p>
          <p>
            {{ isEn
              ? 'By downloading or using the game, you agree to the collection and use of information in accordance with this policy.'
              : 'Bằng việc cài đặt và khởi chạy trò chơi, bạn đồng ý với các quy định thu thập và xử lý thông tin được nêu chi tiết tại tài liệu này.' }}
          </p>
        </section>

        <!-- Section 2 -->
        <section class="space-y-3">
          <h3 class="text-lg sm:text-xl font-display font-bold text-white flex items-center gap-2">
            <span class="text-cyan-400 font-mono text-base">02.</span>
            {{ isEn ? 'Information We Collect' : 'Thông Tin Chúng Tôi Thu Thập' }}
          </h3>
          <p>
            {{ isEn 
              ? 'We prioritize offline-first and minimalist data practices. The only data processed includes:' 
              : 'Chúng tôi hoạt động trên nguyên tắc ưu tiên Offline-First và tối giản dữ liệu. Các thông tin duy nhất có thể được xử lý bao gồm:' }}
          </p>
          <ul class="list-disc pl-5 space-y-2 text-slate-300">
            <li>
              <strong class="text-white">{{ isEn ? 'Anonymous Player Identifier (UUID):' : 'Định danh ẩn danh (UUID người chơi):' }}</strong>
              {{ isEn 
                ? ' A randomly generated unique key created on your device upon initial install, used exclusively to sync high scores, endless stats, and ghost replays to our Supabase database.' 
                : ' Chuỗi ký tự ngẫu nhiên được sinh cục bộ trên thiết bị khi cài game, chỉ dùng để đồng bộ điểm cao, bảng xếp hạng và bước đi bóng ma (Ghost Replay) trên Supabase.' }}
            </li>
            <li>
              <strong class="text-white">{{ isEn ? 'Gameplay Statistics:' : 'Thống kê kết quả ván chơi:' }}</strong>
              {{ isEn 
                ? ' Level ID, moves count, completion time, combo multiplier, and puzzle seed.' 
                : ' Cấp độ, số bước đi, thời gian hoàn thành, hệ số combo và mã hạt giống ma trận (puzzle seed).' }}
            </li>
            <li>
              <strong class="text-white">{{ isEn ? 'Diagnostics & Crash Reports:' : 'Dữ liệu chẩn đoán kỹ thuật:' }}</strong>
              {{ isEn 
                ? ' Device model, operating system version, and anonymous crash stack traces to fix game performance bugs.' 
                : ' Đời máy, phiên bản hệ điều hành và nhật ký lỗi crash ẩn danh nhằm tối ưu hóa hiệu năng 120 FPS.' }}
            </li>
          </ul>
        </section>

        <!-- Section 3 -->
        <section class="space-y-3">
          <h3 class="text-lg sm:text-xl font-display font-bold text-white flex items-center gap-2">
            <span class="text-cyan-400 font-mono text-base">03.</span>
            {{ isEn ? 'Third-Party Services & Google AdMob' : 'Dịch Vụ Bên Thứ Ba & Quảng Cáo Google AdMob' }}
          </h3>
          <p>
            {{ isEn 
              ? 'The app utilizes official Google Mobile Ads SDK (AdMob) to display non-intrusive banner and rewarded ads. Google AdMob may use standard advertising identifiers (GAID) in accordance with Google Play Developer Policies.' 
              : 'Ứng dụng tích hợp SDK chính thức Google Mobile Ads (AdMob) để cung cấp quảng cáo Banner và Rewarded Video (tùy chọn nhận gợi ý giải đố). Google AdMob có thể sử dụng Mã nhận dạng quảng cáo (GAID) tuân theo chính sách nhà phát triển của Google Play.' }}
          </p>
          <p>
            {{ isEn 
              ? 'For detailed information on how Google processes advertising data, please refer to Google’s Privacy & Terms: https://policies.google.com/technologies/ads.' 
              : 'Để tìm hiểu chi tiết cách Google xử lý dữ liệu quảng cáo, bạn có thể tham khảo tại Chính sách quyền riêng tư của Google: https://policies.google.com/technologies/ads.' }}
          </p>
        </section>

        <!-- Section 4 -->
        <section class="space-y-4">
          <h3 class="text-lg sm:text-xl font-display font-bold text-white flex items-center gap-2">
            <span class="text-pink-400 font-mono text-base">04.</span>
            {{ isEn ? 'User Rights & Account Deletion Protocol' : 'Quyền Của Người Dùng & Cơ Chế Xóa Dữ Liệu' }}
          </h3>
          <p>
            {{ isEn 
              ? 'Under Google Play Data Safety standards, all players possess the right to permanently purge their account, leaderboard scores, and cloud statistics.' 
              : 'Tuân thủ nghiêm ngặt tiêu chuẩn An toàn Dữ liệu (Data Safety) của Google Play, mọi người chơi đều có quyền yêu cầu xóa vĩnh viễn dữ liệu điểm số, tài khoản và lịch sử đấu khỏi máy chủ của chúng tôi.' }}
          </p>
          
          <div class="glass-card p-6 rounded-2xl border border-pink-500/30 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
            <div class="space-y-1">
              <div class="font-display font-bold text-base text-white flex items-center gap-2">
                <span class="w-2 h-2 rounded-full bg-pink-400 animate-pulse"></span>
                <span>{{ isEn ? 'Self-Service Data Erasure Portal' : 'Cổng Yêu Cầu Xóa Dữ Liệu Tự Động' }}</span>
              </div>
              <p class="text-xs text-slate-400">
                {{ isEn 
                  ? 'Access the secure terminal to submit an automated request and receive an instant tracking ticket.' 
                  : 'Truy cập cổng bảo mật để gửi yêu cầu thanh lọc dữ liệu và nhận mã Ticket theo dõi tiến độ.' }}
              </p>
            </div>
            
            <router-link 
              :to="deletionRoute" 
              class="px-5 py-3 rounded-xl bg-pink-500 hover:bg-pink-400 text-slate-950 font-display font-bold text-xs uppercase tracking-wider shadow-neon-pink transition-all shrink-0 flex items-center gap-2"
            >
              <span>{{ isEn ? 'Open Terminal' : 'Mở Giao Diện Xóa' }}</span>
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
              </svg>
            </router-link>
          </div>
        </section>

        <!-- Section 5 -->
        <section class="space-y-3">
          <h3 class="text-lg sm:text-xl font-display font-bold text-white flex items-center gap-2">
            <span class="text-cyan-400 font-mono text-base">05.</span>
            {{ isEn ? 'Contact Developer' : 'Thông Tin Liên Hệ Nhà Phát Triển' }}
          </h3>
          <p>
            {{ isEn 
              ? 'If you have any questions, compliance requests, or inquiries regarding your personal data, feel free to email our engineering desk directly at:' 
              : 'Nếu bạn có bất kỳ câu hỏi, thắc mắc hoặc yêu cầu nào liên quan đến dữ liệu cá nhân, vui lòng liên hệ trực tiếp với bộ phận kỹ thuật của chúng tôi qua:' }}
          </p>
          <div class="font-mono text-sm text-cyan-400 bg-slate-900/90 p-3.5 rounded-xl border border-slate-800">
            Email: <a :href="'mailto:' + currentProduct.support_email" class="underline">{{ currentProduct.support_email }}</a><br />
            Studio: {{ currentProduct.developer_name }}<br />
            Domain: txastudio.click
          </div>
        </section>

      </div>

      <!-- Policy Content Clauses: EXTENSION (ShieldBlock) -->
      <div v-else class="glass-panel rounded-2xl p-6 sm:p-10 border border-slate-800 space-y-10 text-slate-300 text-sm leading-relaxed">
        
        <!-- Section 1 -->
        <section class="space-y-3">
          <h3 class="text-lg sm:text-xl font-display font-bold text-white flex items-center gap-2">
            <span class="text-pink-400 font-mono text-base">01.</span>
            {{ isEn ? 'Introduction & Extension Scope' : 'Giới Thiệu & Phạm Vi Tiện Ích' }}
          </h3>
          <p>
            {{ isEn 
              ? 'This Privacy Policy explains the operational and privacy commitments for ShieldBlock - Ad & Tracker Blocker Pro ("ShieldBlock", "we", "us", or "our"), distributed via the Chrome Web Store and Chromium-compatible ecosystems.' 
              : 'Chính sách Quyền riêng tư này giải thích các cam kết vận hành và bảo mật của tiện ích ShieldBlock - Ad & Tracker Blocker Pro ("ShieldBlock", "chúng tôi"), được phát hành trên Chrome Web Store và các trình duyệt nền tảng Chromium.' }}
          </p>
          <p>
            {{ isEn
              ? 'ShieldBlock is engineered from the ground up as a zero-telemetry, client-side utility. We do not monitor, record, harvest, or monetize your web browsing habits.'
              : 'ShieldBlock được phát triển trên tôn chỉ Không Thu Thập Dữ Liệu (Zero-Telemetry) và xử lý 100% tại máy khách. Chúng tôi tuyệt đối không theo dõi, ghi lại, thu thập hoặc kiếm tiền từ lịch sử duyệt web của bạn.' }}
          </p>
        </section>

        <!-- Section 2 -->
        <section class="space-y-3">
          <h3 class="text-lg sm:text-xl font-display font-bold text-white flex items-center gap-2">
            <span class="text-pink-400 font-mono text-base">02.</span>
            {{ isEn ? 'What Data We Process & What We NEVER Collect' : 'Dữ Liệu Được Xử Lý & Cam Kết KHÔNG Thu Thập' }}
          </h3>
          <p>
            {{ isEn 
              ? 'ShieldBlock operates locally on your machine. The only information processed includes:' 
              : 'ShieldBlock hoạt động hoàn toàn cục bộ trên máy tính của bạn. Dữ liệu duy nhất được xử lý bao gồm:' }}
          </p>
          <ul class="list-disc pl-5 space-y-2 text-slate-300">
            <li>
              <strong class="text-white">{{ isEn ? 'Local Configuration & Filter Rules:' : 'Cấu hình cục bộ & Quy tắc lọc:' }}</strong>
              {{ isEn 
                ? ' User-toggled settings, custom cosmetic filter rules, and site whitelists stored locally via chrome.storage.local.' 
                : ' Các cài đặt tùy chỉnh, danh sách tên miền tin cậy (whitelist) và các quy tắc tự thêm được lưu trữ cục bộ trong trình duyệt qua chrome.storage.local.' }}
            </li>
            <li>
              <strong class="text-white">{{ isEn ? 'Optional Cloud Sync (TXA Studio ID):' : 'Đồng bộ Cloud Tùy chọn (TXA Studio ID):' }}</strong>
              {{ isEn 
                ? ' If you log into TXA Studio ID, your custom whitelist and rules are synchronized via encrypted REST APIs to Supabase to enable multi-device sync.' 
                : ' Nếu bạn chủ động đăng nhập TXA Studio ID, danh sách quy tắc tùy biến và whitelist sẽ được sao lưu đám mây an toàn qua Supabase để đồng bộ nhiều thiết bị.' }}
            </li>
            <li>
              <strong class="text-rose-400">{{ isEn ? 'NEVER COLLECTED (Strict Zero Log):' : 'TUYỆT ĐỐI KHÔNG THU THẬP:' }}</strong>
              {{ isEn 
                ? ' We do NOT track or store URLs, web page content, search queries, IP addresses, form inputs, cookies, passwords, or personal identity.' 
                : ' Chúng tôi KHÔNG BAO GIỜ theo dõi hay lưu trữ địa chỉ web (URL), nội dung trang web, từ khóa tìm kiếm, địa chỉ IP, biểu mẫu, cookie hay mật khẩu của bạn.' }}
            </li>
          </ul>
        </section>

        <!-- Section 3 -->
        <section class="space-y-3">
          <h3 class="text-lg sm:text-xl font-display font-bold text-white flex items-center gap-2">
            <span class="text-pink-400 font-mono text-base">03.</span>
            {{ isEn ? 'Browser Permissions Transparency (Manifest V3)' : 'Minh Bạch Quyền Trình Duyệt (Manifest V3)' }}
          </h3>
          <p>
            {{ isEn 
              ? 'In compliance with the Chrome Web Store Developer Program Policies, ShieldBlock utilizes only the minimum permissions necessary:' 
              : 'Tuân thủ nghiêm ngặt Chính sách Dành cho Nhà phát triển của Chrome Web Store, ShieldBlock chỉ sử dụng các quyền hạn tối thiểu cần thiết:' }}
          </p>
          <div class="space-y-3 font-mono text-xs">
            <div class="p-3.5 rounded-xl bg-slate-900 border border-slate-800">
              <span class="text-cyan-400 font-bold">declarativeNetRequest:</span>
              <p class="text-slate-400 font-sans mt-1">
                {{ isEn 
                  ? 'Used to evaluate and block network requests to known ad and tracker domains at the browser engine level before network packets leave your computer.' 
                  : 'Dùng để chặn các yêu cầu mạng đến máy chủ quảng cáo và mã theo dõi ngay tại tầng nhân trình duyệt mà không làm chậm tốc độ load web.' }}
              </p>
            </div>
            <div class="p-3.5 rounded-xl bg-slate-900 border border-slate-800">
              <span class="text-pink-400 font-bold">storage:</span>
              <p class="text-slate-400 font-sans mt-1">
                {{ isEn 
                  ? 'Used to save your local extension toggles, whitelist domains, and anti-adblock trap preferences on your local browser profile.' 
                  : 'Dùng để lưu trạng thái bật/tắt tiện ích, danh sách trắng tên miền và cài đặt chống bẫy quảng cáo trong profile trình duyệt của bạn.' }}
              </p>
            </div>
            <div class="p-3.5 rounded-xl bg-slate-900 border border-slate-800">
              <span class="text-purple-400 font-bold">scripting / &lt;all_urls&gt; (Content Script):</span>
              <p class="text-slate-400 font-sans mt-1">
                {{ isEn 
                  ? 'Used strictly to inject cosmetic CSS rules to hide blank ad containers and neutralize aggressive anti-adblock trap scripts. No web data is harvested.' 
                  : 'Dùng riêng cho việc chèn CSS ẩn khoảng trống quảng cáo thừa và vô hiệu hóa các mã bẫy anti-adblock. Không trích xuất bất kỳ dữ liệu cá nhân nào.' }}
              </p>
            </div>
          </div>
        </section>

        <!-- Section 4 -->
        <section class="space-y-4">
          <h3 class="text-lg sm:text-xl font-display font-bold text-white flex items-center gap-2">
            <span class="text-pink-400 font-mono text-base">04.</span>
            {{ isEn ? 'Data Erasure & Cloud Purge Protocol' : 'Quyền Xóa Bỏ Dữ Liệu & Hủy Đồng Bộ Đám Mây' }}
          </h3>
          <p>
            {{ isEn 
              ? 'You have complete sovereignty over your data. You can delete cloud-synced rules anytime through our self-service portal, or simply remove the extension to instantly delete all local data.' 
              : 'Bạn nắm toàn quyền kiểm soát dữ liệu của mình. Bạn có thể xóa toàn bộ dữ liệu đồng bộ đám mây qua cổng trực tuyến, hoặc gỡ cài đặt tiện ích khỏi trình duyệt để xóa sạch dữ liệu trên máy.' }}
          </p>
          
          <div class="glass-card p-6 rounded-2xl border border-pink-500/30 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
            <div class="space-y-1">
              <div class="font-display font-bold text-base text-white flex items-center gap-2">
                <span class="w-2 h-2 rounded-full bg-pink-400 animate-pulse"></span>
                <span>{{ isEn ? 'ShieldBlock Cloud Erasure Terminal' : 'Cổng Xóa Dữ Liệu Đồng Bộ ShieldBlock' }}</span>
              </div>
              <p class="text-xs text-slate-400">
                {{ isEn 
                  ? 'Submit an instant request to delete your cloud sync records and unlink your extension profile.' 
                  : 'Gửi yêu cầu thanh lọc toàn bộ dữ liệu đồng bộ đám mây và hủy liên kết tiện ích khỏi hệ thống.' }}
              </p>
            </div>
            
            <router-link 
              :to="deletionRoute" 
              class="px-5 py-3 rounded-xl bg-pink-500 hover:bg-pink-400 text-slate-950 font-display font-bold text-xs uppercase tracking-wider shadow-neon-pink transition-all shrink-0 flex items-center gap-2"
            >
              <span>{{ isEn ? 'Open Terminal' : 'Mở Giao Diện Xóa' }}</span>
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
              </svg>
            </router-link>
          </div>
        </section>

        <!-- Section 5 -->
        <section class="space-y-3">
          <h3 class="text-lg sm:text-xl font-display font-bold text-white flex items-center gap-2">
            <span class="text-pink-400 font-mono text-base">05.</span>
            {{ isEn ? 'Non-Monetization Pledge & Developer Contact' : 'Cam Kết Không Thương Mại Hóa Dữ Liệu & Liên Hệ' }}
          </h3>
          <p>
            {{ isEn 
              ? 'ShieldBlock does NOT accept payment to whitelist specific ad companies, does NOT inject affiliate tags, and will NEVER sell telemetry. For inquiries or audit questions, reach our team at:' 
              : 'ShieldBlock KHÔNG nhận tiền để mở khóa quảng cáo (không tham gia chương trình Acceptable Ads trả phí), KHÔNG chèn mã tiếp thị liên kết và KHÔNG BAO GIỜ bán dữ liệu. Mọi thắc mắc xin liên hệ:' }}
          </p>
          <div class="font-mono text-sm text-pink-400 bg-slate-900/90 p-3.5 rounded-xl border border-slate-800">
            Email: <a :href="'mailto:' + currentProduct.support_email" class="underline">{{ currentProduct.support_email }}</a><br />
            Studio: {{ currentProduct.developer_name }}<br />
            CWS ID: {{ currentProduct.package_id }}
          </div>
        </section>

      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, computed, inject, onMounted, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { getGameInfo, KNOWN_PRODUCTS, DEFAULT_GAME } from '../services/supabase.js';
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

const deletionRoute = computed(() => {
  return `/delete-account/${currentSlug.value}`;
});

function switchProduct(slug) {
  sound.playClick();
  router.push({ path: `/privacy/${slug}` });
}

async function loadProduct() {
  currentProduct.value = await getGameInfo(currentSlug.value);
}

onMounted(loadProduct);
watch(() => route.params.gameSlug, loadProduct);
watch(() => route.query.game, loadProduct);
watch(() => route.query.app, loadProduct);
</script>
