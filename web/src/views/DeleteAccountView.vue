<template>
  <div class="relative z-10 py-12 lg:py-16">
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
      
      <!-- Top Title & Mode Tabs -->
      <div class="mb-8 text-center sm:text-left flex flex-col sm:flex-row sm:items-end justify-between gap-6 pb-6 border-b border-slate-800/80">
        <div>
          <div class="inline-flex items-center gap-2 text-xs font-mono text-pink-400 uppercase tracking-widest mb-1.5">
            <span class="w-2 h-2 rounded-full bg-pink-500 animate-pulse"></span>
            <span>GOOGLE PLAY DATA COMPLIANCE TERMINAL</span>
          </div>
          <h1 class="text-3xl sm:text-4xl font-display font-black text-white">
            {{ isEn ? 'Data & Account Erasure' : 'Cổng Xóa Dữ Liệu & Tài Khoản' }}
          </h1>
          <p class="text-slate-400 text-xs sm:text-sm mt-1">
            {{ isEn 
              ? 'Self-service request to permanently purge player cloud statistics and scores.' 
              : 'Gửi yêu cầu tự động xóa vĩnh viễn dữ liệu người chơi, điểm số và thứ hạng khỏi máy chủ.' }}
          </p>
        </div>

        <!-- Mode Toggle: Submit / Track -->
        <div class="inline-flex p-1 rounded-xl bg-slate-900/90 border border-slate-800 self-center sm:self-auto font-mono text-xs">
          <button 
            @click="activeTab = 'submit'; sound.playClick()"
            class="px-4 py-2 rounded-lg transition-all"
            :class="activeTab === 'submit' ? 'bg-pink-500 text-slate-950 font-bold shadow-neon-pink' : 'text-slate-400 hover:text-white'"
          >
            {{ isEn ? 'Submit Request' : 'Gửi Yêu Cầu Xóa' }}
          </button>
          <button 
            @click="activeTab = 'track'; sound.playClick()"
            class="px-4 py-2 rounded-lg transition-all"
            :class="activeTab === 'track' ? 'bg-cyan-500 text-slate-950 font-bold shadow-neon-cyan' : 'text-slate-400 hover:text-white'"
          >
            {{ isEn ? 'Track Status' : 'Tra Cứu Tiến Độ' }}
          </button>
        </div>
      </div>

      <!-- Sleek Game Identity Badge (Thay vì lộ liễu hay thô kệch) -->
      <div class="glass-panel p-4 rounded-2xl border border-slate-800 mb-6 flex items-center justify-between">
        <div class="flex items-center gap-3.5">
          <div class="w-10 h-10 rounded-xl bg-gradient-to-tr from-cyan-400 via-sky-500 to-pink-500 p-[2px] shrink-0">
            <img src="/logo_master.png" alt="Logo" class="w-full h-full rounded-[10px] object-cover bg-slate-950" />
          </div>
          <div>
            <div class="flex items-center gap-2">
              <span class="font-display font-bold text-sm text-white">{{ currentGame.title }}</span>
              <span class="text-[10px] font-mono px-2 py-0.5 rounded-full bg-cyan-500/10 text-cyan-300 border border-cyan-500/20">
                ACTIVE TARGET
              </span>
            </div>
            <div class="text-[11px] text-slate-400 font-mono">
              {{ currentGame.package_id }}
            </div>
          </div>
        </div>

        <!-- Privacy link back -->
        <router-link 
          :to="'/privacy/' + currentSlug" 
          class="text-xs text-slate-400 hover:text-cyan-400 font-mono transition-colors hidden sm:flex items-center gap-1"
        >
          <span>{{ isEn ? 'View Privacy Policy' : 'Xem Chính Sách' }}</span>
          <span>→</span>
        </router-link>
      </div>

      <!-- ============================================================= -->
      <!-- TAB 1: SUBMIT FORM -->
      <!-- ============================================================= -->
      <div v-if="activeTab === 'submit'" class="space-y-6">
        
        <!-- Success Banner -->
        <div v-if="ticketCreated" class="glass-panel p-8 rounded-3xl border-2 border-emerald-500/50 shadow-neon-green space-y-5">
          <div class="flex items-center gap-3 text-emerald-400">
            <div class="w-10 h-10 rounded-xl bg-emerald-500/20 border border-emerald-500/40 flex items-center justify-center font-bold text-lg">
              ✓
            </div>
            <div>
              <h3 class="font-display font-bold text-lg text-white">
                {{ isEn ? 'Request Queued Successfully' : 'Đã Tiếp Nhận Yêu Cầu Xóa Dữ Liệu' }}
              </h3>
              <p class="text-xs text-slate-400 font-mono">
                {{ isEn ? 'Dữ liệu dự kiến được thanh lọc trong vòng 48 giờ.' : 'Dữ liệu dự kiến được thanh lọc trong vòng 48 giờ.' }}
              </p>
            </div>
          </div>

          <!-- Ticket Box -->
          <div class="bg-slate-950/80 p-4 rounded-2xl border border-emerald-500/30 flex items-center justify-between font-mono">
            <div>
              <div class="text-[10px] text-slate-500 uppercase tracking-widest">MÃ TICKET TRA CỨU</div>
              <div class="text-xl sm:text-2xl font-black text-emerald-400">{{ ticketCreated }}</div>
            </div>
            <button 
              @click="copyTicket"
              class="px-4 py-2 rounded-xl bg-emerald-500/20 hover:bg-emerald-500/30 text-emerald-300 text-xs font-bold border border-emerald-500/30 transition-all"
            >
              <span>{{ copied ? 'ĐÃ SAO CHÉP!' : 'SAO CHÉP' }}</span>
            </button>
          </div>

          <div class="text-xs text-slate-400 leading-relaxed">
            {{ isEn 
              ? 'Please keep this code to track your request status anytime.' 
              : 'Vui lòng lưu lại mã Ticket trên để tra cứu tiến độ xử lý bất cứ lúc nào.' }}
          </div>

          <button 
            @click="ticketCreated = null; resetForm()"
            class="text-xs text-cyan-400 hover:underline font-mono"
          >
            ← {{ isEn ? 'Submit another request' : 'Gửi yêu cầu khác' }}
          </button>
        </div>

        <!-- Form Card -->
        <form v-else @submit.prevent="handleSubmit" class="glass-panel p-6 sm:p-10 rounded-3xl border border-slate-800 space-y-6">
          
          <!-- Email Address -->
          <div class="space-y-2">
            <div class="flex items-center justify-between">
              <label class="block text-xs font-mono uppercase tracking-wider text-slate-400 font-bold">
                {{ isEn ? 'Your Email Address' : 'Địa Chỉ Email Của Bạn' }} <span class="text-pink-500">*</span>
              </label>
              <span v-if="emailTouched && !isEmailValid" class="text-[11px] text-pink-400 font-mono">
                {{ isEn ? 'Invalid email format' : 'Email không đúng định dạng' }}
              </span>
            </div>
            <input 
              v-model="form.email"
              type="email"
              placeholder="player@example.com"
              required
              @blur="emailTouched = true"
              class="w-full px-4 py-3 rounded-xl bg-slate-900/90 border text-white text-sm outline-none font-mono transition-all"
              :class="emailTouched && !isEmailValid ? 'border-pink-500 focus:border-pink-400' : 'border-slate-700 focus:border-cyan-400'"
            />
            <p class="text-[11px] text-slate-500 font-mono">
              {{ isEn ? 'Used solely to send completion notice.' : 'Chỉ dùng để gửi thông báo xác nhận khi hoàn tất.' }}
            </p>
          </div>

          <!-- Player ID / User ID -->
          <div class="space-y-2">
            <div class="flex items-center justify-between">
              <label class="block text-xs font-mono uppercase tracking-wider text-slate-400 font-bold">
                {{ isEn ? 'Player ID / UUID' : 'ID Người Chơi / UUID Ẩn Danh' }} <span class="text-pink-500">*</span>
              </label>
              <span v-if="userIdTouched && !isUserIdValid" class="text-[11px] text-pink-400 font-mono">
                {{ isEn ? 'Minimum 4 characters' : 'Tối thiểu 4 ký tự' }}
              </span>
            </div>
            <input 
              v-model="form.userId"
              type="text"
              placeholder="Ví dụ: USER-8841 hoặc UUID trong mục Cài Đặt Game"
              required
              @blur="userIdTouched = true"
              class="w-full px-4 py-3 rounded-xl bg-slate-900/90 border text-white text-sm outline-none font-mono transition-all"
              :class="userIdTouched && !isUserIdValid ? 'border-pink-500 focus:border-pink-400' : 'border-slate-700 focus:border-cyan-400'"
            />
          </div>

          <!-- Scope of Deletion -->
          <div class="space-y-2">
            <label class="block text-xs font-mono uppercase tracking-wider text-slate-400 font-bold">
              {{ isEn ? 'Scope of Erasure' : 'Phạm Vi Xóa Dữ Liệu' }} <span class="text-pink-500">*</span>
            </label>
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 font-mono text-xs">
              <label 
                class="p-3.5 rounded-xl border cursor-pointer transition-all flex flex-col justify-between gap-2"
                :class="form.scope === 'all' ? 'border-pink-500/80 bg-pink-500/10 text-white' : 'border-slate-800 bg-slate-900/60 text-slate-400 hover:border-slate-700'"
              >
                <div class="flex items-center justify-between">
                  <span class="font-bold text-pink-400">{{ isEn ? 'FULL PURGE' : 'XÓA TOÀN BỘ' }}</span>
                  <input type="radio" v-model="form.scope" value="all" class="accent-pink-500" />
                </div>
                <div class="text-[10px] text-slate-400 leading-normal">
                  {{ isEn ? 'Purge all cloud scores & stats.' : 'Xóa toàn bộ điểm số, ghost replay và thống kê.' }}
                </div>
              </label>

              <label 
                class="p-3.5 rounded-xl border cursor-pointer transition-all flex flex-col justify-between gap-2"
                :class="form.scope === 'leaderboard' ? 'border-cyan-500/80 bg-cyan-500/10 text-white' : 'border-slate-800 bg-slate-900/60 text-slate-400 hover:border-slate-700'"
              >
                <div class="flex items-center justify-between">
                  <span class="font-bold text-cyan-400">{{ isEn ? 'LEADERBOARD ONLY' : 'CHỈ BẢNG ĐIỂM' }}</span>
                  <input type="radio" v-model="form.scope" value="leaderboard" class="accent-cyan-500" />
                </div>
                <div class="text-[10px] text-slate-400 leading-normal">
                  {{ isEn ? 'Reset ranking, keep local save.' : 'Chỉ xóa thứ hạng công khai, giữ lại dữ liệu máy.' }}
                </div>
              </label>

              <label 
                class="p-3.5 rounded-xl border cursor-pointer transition-all flex flex-col justify-between gap-2"
                :class="form.scope === 'auth' ? 'border-purple-500/80 bg-purple-500/10 text-white' : 'border-slate-800 bg-slate-900/60 text-slate-400 hover:border-slate-700'"
              >
                <div class="flex items-center justify-between">
                  <span class="font-bold text-purple-400">{{ isEn ? 'REVOKE CLOUD' : 'RÚT LƯU CLOUD' }}</span>
                  <input type="radio" v-model="form.scope" value="auth" class="accent-purple-500" />
                </div>
                <div class="text-[10px] text-slate-400 leading-normal">
                  {{ isEn ? 'Stop future cloud sync.' : 'Hủy liên kết tài khoản khỏi Cloud.' }}
                </div>
              </label>
            </div>
          </div>

          <!-- Reason (Optional) -->
          <div class="space-y-2">
            <label class="block text-xs font-mono uppercase tracking-wider text-slate-400 font-bold">
              {{ isEn ? 'Reason (Optional)' : 'Lý Do Xóa (Không Bắt Buộc)' }}
            </label>
            <textarea 
              v-model="form.reason"
              rows="2"
              placeholder="Chia sẻ lý do giúp TXA Studio nâng cấp chất lượng game..."
              class="w-full px-4 py-3 rounded-xl bg-slate-900/90 border border-slate-700 focus:border-cyan-400 text-white text-sm outline-none transition-all"
            ></textarea>
          </div>

          <!-- Confirm Checkbox -->
          <div class="flex items-start gap-3 pt-2">
            <input 
              id="confirm-purge"
              type="checkbox" 
              v-model="form.confirmed"
              required
              class="mt-1 w-4 h-4 rounded border-slate-700 bg-slate-900 accent-pink-500"
            />
            <label for="confirm-purge" class="text-xs text-slate-400 leading-relaxed cursor-pointer">
              {{ isEn 
                ? 'I confirm this data erasure action is permanent and irreversible.' 
                : 'Tôi hiểu rằng hành động xóa dữ liệu này mang tính vĩnh viễn và không thể khôi phục.' }}
            </label>
          </div>

          <!-- Friendly Diagnostic Notification Card -->
          <div v-if="submitNotice" class="p-4 sm:p-5 rounded-2xl border transition-all text-xs"
            :class="submitNotice.type === 'error' 
              ? 'bg-rose-950/40 border-rose-500/40 text-rose-200' 
              : 'bg-emerald-950/40 border-emerald-500/40 text-emerald-200'"
          >
            <div class="flex items-start gap-3">
              <!-- Diagnostic Icon -->
              <div class="p-2 rounded-xl shrink-0"
                :class="submitNotice.type === 'error' ? 'bg-rose-500/20 text-rose-400' : 'bg-emerald-500/20 text-emerald-400'"
              >
                <!-- Offline / Network -->
                <svg v-if="submitNotice.diagType === 'offline'" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18.364 5.636a9 9 0 010 12.728m0 0l-2.829-2.829m2.829 2.829L21 21M15.536 8.464a5 5 0 010 7.072m0 0l-2.829-2.829m-4.243 4.243a9 9 0 01-12.728 0M1.636 1.636l20.728 20.728" />
                </svg>
                <!-- Timeout -->
                <svg v-else-if="submitNotice.diagType === 'timeout'" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <!-- Server maintenance -->
                <svg v-else-if="submitNotice.diagType === 'server'" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 12h14M5 12a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v4a2 2 0 01-2 2M5 12a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2" />
                </svg>
                <!-- General Error -->
                <svg v-else-if="submitNotice.type === 'error'" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                </svg>
                <!-- Success -->
                <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                </svg>
              </div>

              <!-- Content -->
              <div class="flex-1 space-y-1.5">
                <div v-if="submitNotice.title" class="font-display font-bold text-sm tracking-wide"
                  :class="submitNotice.type === 'error' ? 'text-rose-300' : 'text-emerald-300'"
                >
                  {{ submitNotice.title }}
                </div>
                <p class="text-xs sm:text-sm text-slate-300 leading-relaxed font-normal">
                  {{ submitNotice.text }}
                </p>

                <!-- Actions: Retry button & Support Email -->
                <div v-if="submitNotice.type === 'error'" class="pt-2 flex flex-wrap items-center gap-2">
                  <button 
                    v-if="submitNotice.canRetry"
                    type="button"
                    @click="handleSubmit"
                    class="px-3.5 py-1.5 rounded-xl bg-rose-500/20 hover:bg-rose-500/30 text-rose-300 border border-rose-500/40 font-mono font-bold text-xs flex items-center gap-1.5 transition-all"
                  >
                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                    </svg>
                    <span>{{ isEn ? 'Retry Now' : 'Thử Lại Ngay' }}</span>
                  </button>

                  <a 
                    :href="'mailto:txasoftdev@gmail.com?subject=' + encodeURIComponent('[Hỗ Trợ Xóa Tài Khoản] Báo lỗi: ' + (submitNotice.code || '')) + '&body=' + encodeURIComponent('Chào TXA Studio,\nTôi gặp sự cố khi gửi yêu cầu xóa tài khoản cho game ' + currentSlug + '.\nEmail của tôi: ' + form.email + '\nMã chẩn đoán: ' + (submitNotice.code || ''))"
                    class="px-3.5 py-1.5 rounded-xl bg-slate-900 hover:bg-slate-800 text-slate-300 border border-slate-700 font-mono text-xs flex items-center gap-1.5 transition-all"
                  >
                    <span>✉ txasoftdev@gmail.com</span>
                  </a>

                  <span v-if="submitNotice.code" class="text-[10px] font-mono text-slate-500 ml-auto py-1">
                    {{ submitNotice.code }}
                  </span>
                </div>
              </div>
            </div>
          </div>

          <!-- Submit Button -->
          <button 
            type="submit"
            :disabled="isSubmitting || !isFormValid"
            class="w-full py-4 rounded-2xl bg-gradient-to-r from-pink-500 via-rose-500 to-cyan-500 text-slate-950 font-display font-black text-sm uppercase tracking-wider hover:opacity-95 shadow-lg shadow-pink-500/25 transition-all disabled:opacity-40 disabled:cursor-not-allowed flex items-center justify-center gap-2"
          >
            <span v-if="isSubmitting">{{ isEn ? 'PROCESSING REQUEST...' : 'ĐANG GỬI YÊU CẦU...' }}</span>
            <span v-else>{{ isEn ? 'SUBMIT ERASURE REQUEST' : 'XÁC NHẬN GỬI YÊU CẦU XÓA' }}</span>
          </button>

        </form>

      </div>


      <!-- ============================================================= -->
      <!-- TAB 2: TRACK TICKET STATUS -->
      <!-- ============================================================= -->
      <div v-else class="space-y-6">
        <div class="glass-panel p-6 sm:p-10 rounded-3xl border border-slate-800 space-y-6">
          <div class="space-y-2">
            <label class="block text-xs font-mono uppercase tracking-wider text-slate-400 font-bold">
              {{ isEn ? 'Enter Ticket Identifier' : 'Nhập Mã Ticket Cần Kiểm Tra' }}
            </label>
            <div class="flex gap-3">
              <input 
                v-model="trackQuery"
                type="text"
                placeholder="DEL-XXXXXX"
                class="flex-grow px-4 py-3 rounded-xl bg-slate-900/90 border border-slate-700 focus:border-cyan-400 text-white font-mono text-base outline-none uppercase"
                @keyup.enter="handleTrack"
              />
              <button 
                @click="handleTrack"
                :disabled="isTrackLoading || !trackQuery.trim()"
                class="px-6 py-3 rounded-xl bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-display font-bold text-sm transition-all disabled:opacity-40"
              >
                {{ isTrackLoading ? '...' : (isEn ? 'LOOKUP' : 'TRA CỨU') }}
              </button>
            </div>
          </div>

          <!-- Friendly Status Notification for Tracking -->
          <div v-if="trackNotice" class="p-4 sm:p-5 rounded-2xl border text-xs transition-all"
            :class="trackNotice.type === 'error' 
              ? 'bg-rose-950/40 border-rose-500/40 text-rose-200' 
              : 'bg-slate-900 border-slate-700 text-slate-300'"
          >
            <div class="flex items-start gap-3">
              <div class="p-2 rounded-xl shrink-0"
                :class="trackNotice.type === 'error' ? 'bg-rose-500/20 text-rose-400' : 'bg-slate-800 text-slate-400'"
              >
                <!-- Offline / Network -->
                <svg v-if="trackNotice.diagType === 'offline'" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18.364 5.636a9 9 0 010 12.728m0 0l-2.829-2.829m2.829 2.829L21 21M15.536 8.464a5 5 0 010 7.072m0 0l-2.829-2.829m-4.243 4.243a9 9 0 01-12.728 0M1.636 1.636l20.728 20.728" />
                </svg>
                <!-- Timeout -->
                <svg v-else-if="trackNotice.diagType === 'timeout'" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <!-- Not Found -->
                <svg v-else-if="trackNotice.diagType === 'not_found'" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
                <!-- General Error -->
                <svg v-else-if="trackNotice.type === 'error'" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                </svg>
                <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>

              <div class="flex-1 space-y-1.5">
                <div v-if="trackNotice.title" class="font-display font-bold text-sm tracking-wide"
                  :class="trackNotice.type === 'error' ? 'text-rose-300' : 'text-white'"
                >
                  {{ trackNotice.title }}
                </div>
                <p class="text-xs sm:text-sm text-slate-300 leading-relaxed font-normal">
                  {{ trackNotice.text }}
                </p>

                <!-- Actions if error -->
                <div v-if="trackNotice.type === 'error'" class="pt-2 flex flex-wrap items-center gap-2">
                  <button 
                    v-if="trackNotice.canRetry"
                    type="button"
                    @click="handleTrack"
                    class="px-3.5 py-1.5 rounded-xl bg-rose-500/20 hover:bg-rose-500/30 text-rose-300 border border-rose-500/40 font-mono font-bold text-xs flex items-center gap-1.5 transition-all"
                  >
                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                    </svg>
                    <span>{{ isEn ? 'Retry Lookup' : 'Tra Cứu Lại' }}</span>
                  </button>

                  <a 
                    :href="'mailto:txasoftdev@gmail.com?subject=' + encodeURIComponent('[Hỗ Trợ Tra Cứu Ticket] Mã: ' + trackQuery)"
                    class="px-3.5 py-1.5 rounded-xl bg-slate-900 hover:bg-slate-800 text-slate-300 border border-slate-700 font-mono text-xs flex items-center gap-1.5 transition-all"
                  >
                    <span>✉ txasoftdev@gmail.com</span>
                  </a>

                  <span v-if="trackNotice.code" class="text-[10px] font-mono text-slate-500 ml-auto py-1">
                    {{ trackNotice.code }}
                  </span>
                </div>
              </div>
            </div>
          </div>

          <!-- Lookup Result Card -->
          <div v-if="trackResult" class="p-6 rounded-2xl bg-slate-900/80 border border-slate-700 space-y-4">
            <div class="flex items-center justify-between pb-3 border-b border-slate-800">
              <div>
                <span class="text-xs font-mono text-slate-400">MÃ TICKET:</span>
                <span class="font-mono font-bold text-white ml-2">{{ trackResult.ticket_id }}</span>
              </div>
              
              <!-- Status Badge -->
              <div class="flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-mono font-bold uppercase"
                :class="{
                  'bg-yellow-500/10 text-yellow-400 border border-yellow-500/30': trackResult.status === 'pending',
                  'bg-blue-500/10 text-blue-400 border border-blue-500/30': trackResult.status === 'processing',
                  'bg-emerald-500/10 text-emerald-400 border border-emerald-500/30': trackResult.status === 'completed',
                  'bg-red-500/10 text-red-400 border border-red-500/30': trackResult.status === 'rejected',
                }"
              >
                <span class="w-2 h-2 rounded-full"
                  :class="{
                    'bg-yellow-400 animate-ping': trackResult.status === 'pending',
                    'bg-blue-400 animate-pulse': trackResult.status === 'processing',
                    'bg-emerald-400': trackResult.status === 'completed',
                    'bg-red-400': trackResult.status === 'rejected',
                  }"
                ></span>
                <span>{{ formatStatus(trackResult.status) }}</span>
              </div>
            </div>

            <!-- Details Grid -->
            <div class="grid grid-cols-2 gap-4 text-xs font-mono">
              <div>
                <div class="text-slate-500">TỰA GAME:</div>
                <div class="text-slate-300 font-bold">{{ trackResult.game_slug }}</div>
              </div>
              <div>
                <div class="text-slate-500">PHẠM VI:</div>
                <div class="text-slate-300 font-bold uppercase">{{ formatScope(trackResult.scope) }}</div>
              </div>
              <div>
                <div class="text-slate-500">THỜI ĐIỂM GỬI:</div>
                <div class="text-slate-300">{{ new Date(trackResult.created_at).toLocaleString() }}</div>
              </div>
              <div>
                <div class="text-slate-500">TIẾN ĐỘ:</div>
                <div class="text-slate-300">{{ trackResult.processed_at ? new Date(trackResult.processed_at).toLocaleString() : 'Đang trong hàng đợi xử lý' }}</div>
              </div>
            </div>
          </div>

        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, computed, inject, reactive, onMounted, watch } from 'vue';
import { useRoute } from 'vue-router';
import { 
  submitDeletionRequest, 
  checkDeletionStatus, 
  getGameInfo, 
  getFriendlyErrorMessage, 
  verifyGamePlayer,
  DEFAULT_GAME 
} from '../services/supabase.js';
import { sound } from '../services/sound.js';

const route = useRoute();
const currentLang = inject('currentLang', ref('vi'));
const isEn = computed(() => currentLang.value === 'en');

const activeTab = ref(route.query.tab === 'status' ? 'track' : 'submit');

const currentSlug = computed(() => {
  return route.params.gameSlug || route.query.game || 'quantumshift';
});

const currentGame = ref({ ...DEFAULT_GAME });

const form = reactive({
  email: '',
  userId: '',
  scope: 'all',
  reason: '',
  confirmed: false
});

const emailTouched = ref(false);
const userIdTouched = ref(false);
const isSubmitting = ref(false);
const submitNotice = ref(null);
const ticketCreated = ref(null);
const copied = ref(false);

const trackQuery = ref('');
const isTrackLoading = ref(false);
const trackResult = ref(null);
const trackNotice = ref(null);

const isEmailValid = computed(() => {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email.trim());
});

const isUserIdValid = computed(() => {
  return form.userId.trim().length >= 4;
});

const isFormValid = computed(() => {
  return isEmailValid.value && isUserIdValid.value && form.confirmed;
});

async function loadGame() {
  currentGame.value = await getGameInfo(currentSlug.value);
}

onMounted(async () => {
  await loadGame();
  if (route.query.ticket) {
    activeTab.value = 'track';
    trackQuery.value = route.query.ticket;
    handleTrack();
  }
});

watch(() => route.params.gameSlug, loadGame);
watch(() => route.query.game, loadGame);

function resetForm() {
  form.email = '';
  form.userId = '';
  form.scope = 'all';
  form.reason = '';
  form.confirmed = false;
  emailTouched.value = false;
  userIdTouched.value = false;
  submitNotice.value = null;
}

function formatStatus(status) {
  const map = {
    pending: isEn.value ? 'In Queue (Pending)' : 'Đã tiếp nhận (Đang chờ)',
    processing: isEn.value ? 'Processing Purge' : 'Đang xử lý xóa',
    completed: isEn.value ? 'Purged (Completed)' : 'Đã hoàn tất xóa sạch',
    rejected: isEn.value ? 'Rejected' : 'Từ chối / Không khớp',
  };
  return map[status] || status;
}

function formatScope(scope) {
  const map = {
    all: isEn.value ? 'Full Account Purge' : 'Xóa toàn bộ tài khoản',
    leaderboard: isEn.value ? 'Leaderboard Only' : 'Chỉ bảng điểm',
    auth: isEn.value ? 'Revoke Cloud Sync' : 'Hủy liên kết Cloud',
  };
  return map[scope] || scope;
}

async function handleSubmit() {
  if (!isFormValid.value) {
    sound.playClick();
    submitNotice.value = {
      type: 'error',
      diagType: 'data',
      title: isEn.value ? 'Incomplete Form Details' : 'Thông Tin Chưa Điền Đầy Đủ',
      text: isEn.value 
        ? 'Please make sure your email address is valid, Player ID is at least 4 characters, and confirmation is checked.' 
        : 'Bạn vui lòng kiểm tra lại địa chỉ email, Mã người chơi (tối thiểu 4 ký tự) và tích chọn ô cam kết trước khi gửi nhé.',
      code: 'ERR_VALIDATION_INCOMPLETE',
      canRetry: false
    };
    return;
  }
  isSubmitting.value = true;
  submitNotice.value = null;

  try {
    // 1. Kiểm tra mã người chơi có thực tế tồn tại trong cơ sở dữ liệu game không
    const verifyRes = await verifyGamePlayer(form.userId);
    if (verifyRes && verifyRes.exists === false) {
      sound.playClick();
      submitNotice.value = {
        type: 'error',
        diagType: 'data',
        title: isEn.value ? 'Player ID Not Found in Database' : 'Mã Người Chơi Không Tồn Tại Trong Game',
        text: isEn.value
          ? `We could not find any active player account matching ID "${form.userId}" in the game database. Please open ${currentGame.value.title}, go to Settings, and copy your exact Player ID or Device UDID.`
          : `Hệ thống kiểm tra và không tìm thấy hồ sơ người chơi nào với mã "${form.userId}" trong cơ sở dữ liệu của game ${currentGame.value.title}. Bạn vui lòng mở game, vào mục Cài đặt để kiểm tra lại chính xác Mã người chơi hoặc UDID nhé.`,
        code: 'ERR_PLAYER_NOT_FOUND',
        canRetry: false
      };
      isSubmitting.value = false;
      return;
    }

    const { ticketId } = await submitDeletionRequest({
      gameSlug: currentSlug.value,
      email: form.email,
      userId: form.userId,
      scope: form.scope,
      reason: form.reason
    });
    ticketCreated.value = ticketId;
    sound.playSuccess();
  } catch (err) {
    sound.playClick();
    const diag = getFriendlyErrorMessage(err, isEn.value);
    submitNotice.value = {
      type: 'error',
      diagType: diag.type,
      title: diag.title,
      text: diag.message,
      code: diag.code,
      canRetry: diag.canRetry
    };
  } finally {
    isSubmitting.value = false;
  }
}

async function copyTicket() {
  if (!ticketCreated.value) return;
  try {
    await navigator.clipboard.writeText(ticketCreated.value);
    copied.value = true;
    sound.playClick();
    setTimeout(() => { copied.value = false; }, 2500);
  } catch (e) {}
}

async function handleTrack() {
  const query = trackQuery.value.trim().toUpperCase();
  if (!query) return;
  isTrackLoading.value = true;
  trackNotice.value = null;
  trackResult.value = null;

  try {
    const res = await checkDeletionStatus(query);
    if (!res) {
      sound.playClick();
      trackNotice.value = {
        type: 'error',
        diagType: 'not_found',
        title: isEn.value ? 'Ticket ID Not Found' : 'Không Tìm Thấy Mã Ticket',
        text: isEn.value 
          ? `We could not locate ticket record "${query}". Please check the spelling or ensure the deletion form was submitted.` 
          : `Hệ thống chưa tìm thấy dữ liệu cho mã "${query}". Bạn vui lòng kiểm tra lại từng ký tự hoặc đảm bảo yêu cầu xóa trước đó đã được xác nhận gửi nhé.`,
        code: 'ERR_TICKET_NOT_FOUND',
        canRetry: false
      };
    } else {
      trackResult.value = res;
      sound.playSuccess();
    }
  } catch (e) {
    sound.playClick();
    const diag = getFriendlyErrorMessage(e, isEn.value);
    trackNotice.value = {
      type: 'error',
      diagType: diag.type,
      title: diag.title,
      text: diag.message,
      code: diag.code,
      canRetry: diag.canRetry
    };
  } finally {
    isTrackLoading.value = false;
  }
}
</script>
