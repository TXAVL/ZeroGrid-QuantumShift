<template>
  <div class="min-h-screen bg-[#05070f] text-slate-100 py-10 px-4 sm:px-6 lg:px-8 relative">
    <!-- Cyberpunk ambient background -->
    <div class="fixed top-1/4 left-1/2 -translate-x-1/2 w-[600px] h-[600px] bg-cyan-500/10 rounded-full blur-3xl pointer-events-none"></div>
    <div class="fixed bottom-10 right-10 w-96 h-96 bg-pink-500/10 rounded-full blur-3xl pointer-events-none"></div>

    <div class="max-w-6xl mx-auto space-y-8 relative">

      <!-- Admin Top Banner -->
      <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 p-6 rounded-3xl border border-slate-800 bg-[#090d1a]/95 backdrop-blur-xl shadow-2xl">
        <div class="flex items-center gap-4">
          <div class="w-12 h-12 rounded-2xl border border-pink-500/40 bg-pink-500/10 flex items-center justify-center text-pink-400 font-bold text-xl shadow-lg shadow-pink-500/20">
            🛡️
          </div>
          <div>
            <div class="flex items-center gap-2 mb-0.5">
              <span class="w-2 h-2 rounded-full bg-pink-400 animate-ping"></span>
              <span class="text-[10px] font-mono tracking-widest text-pink-400 uppercase font-bold">
                TXA STUDIO // SYSTEM CONTROL TERMINAL
              </span>
            </div>
            <h1 class="text-xl sm:text-2xl font-display font-black text-white">
              {{ isEn ? 'Master Admin Terminal' : 'Bảng Điều Khiển Quản Trị Trung Tâm' }}
            </h1>
          </div>
        </div>

          <!-- Admin info & Logout -->
          <div v-if="isAdmin" class="flex items-center gap-3">
            <div class="hidden sm:flex items-center gap-2 px-3 py-1.5 rounded-xl border border-pink-500/30 bg-pink-500/10 text-xs font-mono">
              <span class="w-2 h-2 rounded-full bg-pink-400 animate-pulse"></span>
              <span class="text-pink-300 font-bold">ADMIN: {{ currentUser?.display_name || currentUser?.email }}</span>
            </div>

            <!-- Link to Docs API -->
            <router-link 
              to="/docs" 
              class="px-4 py-2.5 rounded-xl border border-cyan-500/40 bg-cyan-500/10 hover:bg-cyan-500/20 text-cyan-300 font-mono text-xs font-bold transition-all flex items-center gap-2"
            >
              <span>📖</span>
              <span>{{ isEn ? 'API & Integration Docs' : 'Tài Liệu API & Hướng Dẫn' }}</span>
            </router-link>

            <button 
              @click="adminLogout" 
              class="px-3 py-2 rounded-xl border border-slate-700 bg-slate-800/80 hover:bg-slate-700 text-slate-300 hover:text-white font-mono text-xs transition-all"
            >
              {{ isEn ? 'Sign Out Admin' : 'Đăng Xuất Admin' }}
            </button>
          </div>
        </div>

      <!-- ADMIN TERMINAL CONTENT (Role: admin confirmed) -->
      <div v-if="isAdmin" class="space-y-6">
        
        <!-- Navigation Tabs -->
        <div class="flex items-center gap-2 border-b border-slate-800 pb-4 overflow-x-auto text-xs font-mono font-bold">
          <button 
            @click="activeTab = 'apps'"
            class="px-4 py-2.5 rounded-xl border transition-all flex items-center gap-2 shrink-0"
            :class="activeTab === 'apps' ? 'bg-cyan-500/10 text-cyan-300 border-cyan-500/40 shadow-lg shadow-cyan-500/10' : 'text-slate-400 border-slate-800 hover:text-white'"
          >
            <span>🎮 Quản Lý App/Game OAuth</span>
            <span class="px-1.5 py-0.2 rounded bg-cyan-500/20 text-cyan-300 text-[10px]">{{ appList.length }}</span>
          </button>

          <button 
            @click="activeTab = 'tdrop'"
            class="px-4 py-2.5 rounded-xl border transition-all flex items-center gap-2 shrink-0"
            :class="activeTab === 'tdrop' ? 'bg-gradient-to-r from-cyan-500/20 to-indigo-500/20 text-cyan-300 border-cyan-500/50 shadow-lg shadow-cyan-500/20' : 'text-slate-400 border-slate-800 hover:text-white'"
          >
            <span>💧 Quản Lý T-Drop</span>
            <span v-if="tdropPendingOrdersCount > 0" class="px-2 py-0.5 rounded-full bg-amber-500/20 text-amber-300 text-[10px] animate-pulse font-bold">
              ⚡ {{ tdropPendingOrdersCount }} Đơn Chờ
            </span>
            <span v-else class="px-1.5 py-0.2 rounded bg-cyan-500/20 text-cyan-300 text-[10px]">
              {{ tdropOrders.length }}
            </span>
          </button>

          <button 
            @click="activeTab = 'mycay'"
            class="px-4 py-2.5 rounded-xl border transition-all flex items-center gap-2 shrink-0"
            :class="activeTab === 'mycay' ? 'bg-gradient-to-r from-orange-500/20 to-red-500/20 text-orange-300 border-orange-500/50 shadow-lg shadow-orange-500/20' : 'text-slate-400 border-slate-800 hover:text-white'"
          >
            <span>🍜 Game Mỳ Cay</span>
            <span v-if="mycayPermanentBansCount > 0" class="px-2 py-0.5 rounded-full bg-red-500/20 text-red-300 text-[10px] font-bold border border-red-500/30">
              🚫 {{ mycayPermanentBansCount }} Ban
            </span>
            <span v-else class="px-1.5 py-0.2 rounded bg-orange-500/20 text-orange-300 text-[10px]">
              {{ mycayViews }} Views
            </span>
          </button>

          <button 
            @click="activeTab = 'deletions'"
            class="px-4 py-2.5 rounded-xl border transition-all flex items-center gap-2 shrink-0"
            :class="activeTab === 'deletions' ? 'bg-rose-500/10 text-rose-300 border-rose-500/40 shadow-lg shadow-rose-500/10' : 'text-slate-400 border-slate-800 hover:text-white'"
          >
            <span>🗑️ Duyệt Yêu Cầu Xóa Dữ Liệu</span>
            <span class="px-1.5 py-0.2 rounded bg-rose-500/20 text-rose-300 text-[10px]">{{ deletionList.length }}</span>
          </button>

          <button 
            @click="activeTab = 'feedbacks'"
            class="px-4 py-2.5 rounded-xl border transition-all flex items-center gap-2 shrink-0"
            :class="activeTab === 'feedbacks' ? 'bg-amber-500/10 text-amber-300 border-amber-500/40 shadow-lg shadow-amber-500/10' : 'text-slate-400 border-slate-800 hover:text-white'"
          >
            <span>💬 Ý Kiến & Gỡ Cài Đặt</span>
            <span class="px-1.5 py-0.2 rounded bg-amber-500/20 text-amber-300 text-[10px]">{{ feedbackList.length }}</span>
          </button>

          <button 
            @click="activeTab = 'settings'"
            class="px-4 py-2.5 rounded-xl border transition-all flex items-center gap-2 shrink-0"
            :class="activeTab === 'settings' ? 'bg-purple-500/10 text-purple-300 border-purple-500/40 shadow-lg shadow-purple-500/10' : 'text-slate-400 border-slate-800 hover:text-white'"
          >
            <span>⚙️ Cấu Hình Hệ Thống</span>
          </button>
        </div>

        <!-- ================================================================= -->
        <!-- TAB 1: OAUTH APPS REGISTRY                                        -->
        <!-- ================================================================= -->
        <div v-if="activeTab === 'apps'" class="space-y-6">
          <div class="flex items-center justify-between flex-wrap gap-4">
            <div>
              <h2 class="text-lg font-display font-black text-white">Danh Sách Ứng Dụng & Game Tích Hợp OAuth</h2>
              <p class="text-xs text-slate-400 font-mono">Chỉ Admin mới có quyền cấp phép và gắn kết Client ID với game.</p>
            </div>
            <button 
              @click="showCreateModal = true"
              class="px-4 py-2.5 rounded-xl bg-gradient-to-r from-cyan-400 to-pink-500 text-slate-950 font-display font-black text-xs uppercase tracking-wider shadow-lg shadow-cyan-500/20 hover:scale-[1.02] active:scale-95 transition-all"
            >
              + Tạo App OAuth Mới
            </button>
          </div>

          <!-- Apps Cards Grid -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div 
              v-for="app in appList" 
              :key="app.client_id"
              class="p-5 rounded-2xl border border-slate-800 bg-[#090d1a]/80 backdrop-blur-xl space-y-4 relative overflow-hidden"
            >
              <div class="flex items-start justify-between gap-3">
                <div class="flex items-center gap-3">
                  <div class="w-12 h-12 rounded-2xl border border-slate-700 bg-black/60 p-1 flex items-center justify-center shrink-0">
                    <img 
                      :src="app.logo_url || '/icons/Icon-512.png'" 
                      class="w-full h-full object-contain rounded-xl" 
                      @error="$event.target.src = '/icons/Icon-512.png'"
                    />
                  </div>
                  <div>
                    <h3 class="font-display font-bold text-white text-sm">{{ app.name }}</h3>
                    <div class="text-[11px] font-mono text-slate-400">Game: <span class="text-cyan-400">{{ app.game_slug }}</span></div>
                  </div>
                </div>

                <!-- Verified Badge -->
                <span 
                  class="px-2.5 py-0.5 rounded-full text-[10px] font-mono font-bold uppercase tracking-wide border"
                  :class="app.is_verified ? 'bg-emerald-500/10 text-emerald-300 border-emerald-500/30' : 'bg-amber-500/10 text-amber-300 border-amber-500/30'"
                >
                  {{ app.is_verified ? '✓ VERIFIED' : 'UNVERIFIED' }}
                </span>
              </div>

              <!-- Client ID Box -->
              <div class="p-3 rounded-xl bg-black/60 border border-slate-800/80 space-y-1 text-xs font-mono">
                <div class="flex items-center justify-between text-[10px] text-slate-500">
                  <span>MÃ CLIENT ID:</span>
                  <button @click="copy(app.client_id)" class="text-cyan-400 hover:text-cyan-300 font-bold">Copy</button>
                </div>
                <div class="text-cyan-300 font-bold truncate">{{ app.client_id }}</div>
              </div>

              <!-- Auto-generated Links -->
              <div class="space-y-1 text-[11px] font-mono text-slate-400">
                <div class="truncate">🔒 Privacy: <a :href="app.privacy_policy_url" target="_blank" class="text-cyan-400 hover:underline">{{ app.privacy_policy_url }}</a></div>
                <div class="truncate">📜 Terms: <a :href="app.terms_url" target="_blank" class="text-cyan-400 hover:underline">{{ app.terms_url }}</a></div>
                <div class="truncate">🗑️ Delete: <a :href="app.delete_account_url" target="_blank" class="text-pink-400 hover:underline">{{ app.delete_account_url }}</a></div>
              </div>

              <!-- Flutter Integration Snippet Button & Delete Button -->
              <div class="pt-2 border-t border-slate-800/80 flex items-center justify-between gap-2">
                <button 
                  @click="viewSnippet(app)"
                  class="text-xs font-mono text-cyan-400 hover:text-cyan-300 underline font-bold"
                >
                  📋 {{ isEn ? 'View Config Snippet' : 'Xem mã cấu hình' }}
                </button>
                <div class="flex items-center gap-3">
                  <span class="text-[10px] font-mono text-slate-500">Status: {{ app.status }}</span>
                  <button 
                    @click="handleDeleteApp(app)"
                    class="px-2.5 py-1 rounded-lg border border-rose-500/40 bg-rose-500/10 hover:bg-rose-500/20 text-rose-300 font-mono text-[11px] font-bold transition-all flex items-center gap-1"
                    title="Xóa vĩnh viễn App này"
                  >
                    <span>🗑️</span>
                    <span>{{ isEn ? 'Delete' : 'Xóa App' }}</span>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- ================================================================= -->
        <!-- TAB 2: DELETIONS MODERATION                                       -->
        <!-- ================================================================= -->
        <div v-if="activeTab === 'deletions'" class="space-y-6">
          <div class="flex items-center justify-between flex-wrap gap-4">
            <div>
              <h2 class="text-lg font-display font-black text-white">Quản Lý Duyệt Xóa Tài Khoản & Dữ Liệu</h2>
              <p class="text-xs text-slate-400 font-mono">Duyệt 1-click trực tiếp không cần mở Supabase Console.</p>
            </div>
            <button 
              @click="loadDeletions"
              class="px-3 py-2 rounded-xl border border-slate-700 bg-slate-800 text-xs font-mono text-slate-300 hover:text-white"
            >
              🔄 Làm Mới Danh Sách
            </button>
          </div>

          <div v-if="deletionList.length === 0" class="p-8 rounded-3xl border border-slate-800 bg-[#090d1a]/80 text-center font-mono text-xs text-slate-400">
            Hiện chưa có yêu cầu xóa tài khoản nào cần xử lý.
          </div>

          <!-- Deletion Requests Table -->
          <div v-else class="space-y-3">
            <div 
              v-for="req in deletionList" 
              :key="req.ticket_id"
              class="p-5 rounded-2xl border border-slate-800 bg-[#090d1a]/80 backdrop-blur-xl flex flex-col md:flex-row items-start md:items-center justify-between gap-4 text-xs font-mono"
            >
              <div class="space-y-1 flex-1">
                <div class="flex items-center gap-2">
                  <span class="font-bold text-white text-sm">{{ req.ticket_id }}</span>
                  <span 
                    class="px-2 py-0.5 rounded text-[10px] uppercase font-bold"
                    :class="req.status === 'completed' ? 'bg-emerald-500/20 text-emerald-300' : req.status === 'rejected' ? 'bg-rose-500/20 text-rose-300' : 'bg-amber-500/20 text-amber-300'"
                  >
                    {{ req.status }}
                  </span>
                </div>
                <div class="text-slate-400">
                  Game: <span class="text-cyan-400 font-bold">{{ req.game_slug }}</span> | Player ID: <span class="text-pink-400 font-bold">{{ req.user_id }}</span>
                </div>
                <div class="text-slate-500 text-[11px]">Email: {{ req.email }} | Ngày tạo: {{ new Date(req.created_at).toLocaleString() }}</div>
                <div v-if="req.reason" class="text-slate-300 text-[11px] italic">Lý do: "{{ req.reason }}"</div>
              </div>

              <!-- Action Buttons -->
              <div v-if="req.status === 'pending'" class="flex items-center gap-2 shrink-0">
                <button 
                  @click="updateDeletion(req.ticket_id, 'completed')"
                  class="px-4 py-2 rounded-xl bg-emerald-500/20 border border-emerald-500/40 hover:bg-emerald-500/30 text-emerald-300 font-bold transition-all"
                >
                  ✓ Duyệt Xóa
                </button>
                <button 
                  @click="updateDeletion(req.ticket_id, 'rejected')"
                  class="px-4 py-2 rounded-xl bg-rose-500/20 border border-rose-500/40 hover:bg-rose-500/30 text-rose-300 font-bold transition-all"
                >
                  ✕ Từ Chối
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- ================================================================= -->
        <!-- TAB 3: SYSTEM SETTINGS                                            -->
        <!-- ================================================================= -->
        <div v-if="activeTab === 'settings'" class="space-y-6 max-w-xl">
          <div class="p-6 rounded-3xl border border-slate-800 bg-[#090d1a]/80 backdrop-blur-xl space-y-5">
            <h2 class="text-lg font-display font-black text-white">Cấu Hình Thời Hạn OAuth & An Ninh</h2>

            <!-- Expiry Config in Seconds -->
            <div class="space-y-2">
              <label class="block text-xs font-mono uppercase tracking-wider text-slate-400 font-bold">
                Thời Hạn Phiên Yêu Cầu OAuth (Đơn Vị: GIÂY)
              </label>
              <div class="flex items-center gap-3 flex-wrap">
                <input 
                  type="number" 
                  min="10" 
                  max="86400"
                  v-model="expirySecondsInput" 
                  class="w-28 px-4 py-2.5 rounded-xl bg-black/60 border border-slate-700 text-cyan-300 font-mono text-sm outline-none focus:border-cyan-400 text-center font-bold"
                />
                <span class="text-xs text-slate-400 font-mono">giây</span>
                <span class="px-2.5 py-1 rounded-lg bg-cyan-500/10 border border-cyan-500/30 text-cyan-300 font-mono text-xs font-bold">
                  (= {{ previewExpiryLabel }})
                </span>
                <button 
                  @click="saveExpiryConfig"
                  class="px-4 py-2.5 rounded-xl bg-cyan-500/20 hover:bg-cyan-500/30 border border-cyan-500/40 text-cyan-300 text-xs font-mono font-bold transition-all ml-auto"
                >
                  Lưu Cấu Hình
                </button>
              </div>
              <p class="text-[11px] font-mono text-slate-500">
                Ví dụ: Nhập 360 giây → khi người chơi mở trang ủy quyền sẽ tự động hiển thị "{{ formatSecondsToHumanLabel(360) }}". Mặc định: 300 giây (05 phút).
              </p>
            </div>

            <!-- Promote User to Admin -->
            <div class="space-y-3 pt-4 border-t border-slate-800">
              <div>
                <h3 class="text-xs font-mono uppercase tracking-wider text-pink-400 font-bold">
                  Thăng Cấp Tài Khoản Lên Admin
                </h3>
                <p class="text-[11px] font-mono text-slate-500 mt-0.5">
                  Cấp vai trò "admin" cho tài khoản website khác để cùng quản trị hệ sinh thái.
                </p>
              </div>

              <div class="flex items-center gap-3">
                <input 
                  type="email" 
                  v-model="promoteEmailInput" 
                  placeholder="member@example.com"
                  class="flex-1 px-4 py-2.5 rounded-xl bg-black/60 border border-slate-700 text-pink-300 font-mono text-xs outline-none focus:border-pink-400"
                />
                <button 
                  @click="handlePromoteUser"
                  class="px-4 py-2.5 rounded-xl bg-pink-500/20 hover:bg-pink-500/30 border border-pink-500/40 text-pink-300 text-xs font-mono font-bold transition-all shrink-0"
                >
                  Thăng Cấp Admin
                </button>
              </div>

              <div v-if="promoteNotice" class="text-xs font-mono text-emerald-400">
                {{ promoteNotice }}
              </div>
            </div>

            <div v-if="settingsNotice" class="text-xs font-mono text-emerald-400 pt-2">
              {{ settingsNotice }}
            </div>
          </div>
        </div>

        <!-- ================================================================= -->
        <!-- TAB 4: UNINSTALL FEEDBACKS & DEVICE TELEMETRY                      -->
        <!-- ================================================================= -->
        <div v-if="activeTab === 'feedbacks'" class="space-y-6">
          <div class="flex items-center justify-between flex-wrap gap-4">
            <div>
              <h2 class="text-lg font-display font-black text-white">Danh Sách Ý Kiến Đóng Góp & Gỡ Cài Đặt Tiện Ích</h2>
              <p class="text-xs text-slate-400 font-mono">Báo cáo lý do người dùng gỡ cài đặt kèm thông số kỹ thuật thiết bị.</p>
            </div>
            <button 
              @click="loadFeedbacks" 
              class="px-4 py-2 rounded-xl bg-slate-900 hover:bg-slate-800 border border-slate-700 text-slate-300 text-xs font-mono transition-all flex items-center gap-2"
            >
              <span>🔄 Làm Mới</span>
            </button>
          </div>

          <div v-if="feedbackList.length === 0" class="p-8 rounded-2xl border border-slate-800 bg-[#090d1a]/60 text-center text-slate-500 font-mono text-xs">
            Chưa có phản hồi gỡ cài đặt nào được ghi nhận trong cơ sở dữ liệu.
          </div>

          <div v-else class="space-y-4">
            <div 
              v-for="fb in feedbackList" 
              :key="fb.id"
              class="p-5 rounded-2xl border border-slate-800 bg-[#090d1a]/80 backdrop-blur-xl space-y-3"
            >
              <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-2 border-b border-slate-800/60">
                <div class="flex items-center gap-2 flex-wrap">
                  <span class="px-2.5 py-1 rounded-lg bg-amber-500/10 border border-amber-500/30 text-amber-300 text-[11px] font-mono font-bold">
                    {{ formatFeedbackReason(fb.reason) }}
                  </span>
                  <span class="text-xs font-mono text-slate-400">
                    {{ fb.app_name }} v{{ fb.app_version }}
                  </span>
                </div>
                <div class="text-[11px] font-mono text-slate-500">
                  {{ new Date(fb.created_at).toLocaleString() }}
                </div>
              </div>

              <!-- Details & Email -->
              <div v-if="fb.details" class="text-xs sm:text-sm text-slate-200 bg-slate-900/60 p-3 rounded-xl border border-slate-800">
                "{{ fb.details }}"
              </div>

              <div class="flex flex-wrap items-center justify-between gap-3 text-xs font-mono pt-1">
                <div class="text-slate-400">
                  <span class="text-slate-500">Email:</span> 
                  <span class="text-white ml-1">{{ fb.email || 'Không để lại email' }}</span>
                </div>

                <!-- Device summary pill -->
                <div class="flex items-center gap-2">
                  <span class="text-[11px] px-2.5 py-1 rounded-lg bg-cyan-500/10 text-cyan-300 border border-cyan-500/20">
                    💻 {{ fb.device_info?.browser || 'Browser' }} • {{ fb.device_info?.os || 'OS' }}
                  </span>
                  <button 
                    @click="selectedFeedback = fb"
                    class="px-2.5 py-1 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-300 text-[11px] font-mono transition-colors"
                  >
                    Xem Chi Tiết Máy ⚙️
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- ================================================================= -->
        <!-- TAB 5: T-DROP CLIPBOARD & AI OCR DESKTOP MANAGER                   -->
        <!-- ================================================================= -->
        <div v-if="activeTab === 'tdrop'" class="space-y-6">
          
          <!-- Banner & Quick Controls -->
          <div class="p-6 rounded-3xl border border-indigo-500/30 bg-gradient-to-br from-[#090d24] via-[#0b102c] to-[#070a18] backdrop-blur-xl shadow-2xl space-y-5">
            <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
              <div class="flex items-center gap-4">
                <div class="w-14 h-14 rounded-2xl bg-indigo-950/80 border border-indigo-500/40 p-2 flex items-center justify-center shadow-lg shadow-indigo-500/20 shrink-0">
                  <img src="/tdrop.png" alt="T-Drop" class="w-full h-full object-contain" />
                </div>
                <div>
                  <div class="flex items-center gap-2 mb-1">
                    <span class="w-2 h-2 rounded-full bg-indigo-400 animate-ping"></span>
                    <span class="text-[10px] font-mono tracking-widest text-indigo-400 uppercase font-bold">
                      T-DROP ECOSYSTEM // DESKTOP CLIPBOARD & AI OCR
                    </span>
                  </div>
                  <h2 class="text-xl sm:text-2xl font-display font-black text-white">
                    Quản Lý Bản Quyền & Đơn Hàng VietQR T-Drop
                  </h2>
                  <p class="text-xs text-slate-400 font-mono">
                    Hệ thống tự động duyệt mã VietQR và cấp phát License Key VIP (30 ngày) / PREMIUM (60 ngày).
                  </p>
                </div>
              </div>

              <!-- Top Action Controls -->
              <div class="flex flex-wrap items-center gap-2.5">
                <button 
                  @click="loadTDropData"
                  :disabled="isTDropLoading"
                  class="px-3.5 py-2 rounded-xl bg-slate-800 hover:bg-slate-700 border border-slate-700 text-slate-300 hover:text-white text-xs font-mono font-bold flex items-center gap-1.5 transition-all"
                >
                  <span :class="isTDropLoading ? 'animate-spin' : ''">🔄</span>
                  <span>{{ isTDropLoading ? 'Đang tải...' : 'Làm Mới' }}</span>
                </button>

                <button 
                  @click="showManualLicenseModal = true"
                  class="px-4 py-2 rounded-xl bg-gradient-to-r from-cyan-400 via-sky-500 to-indigo-500 text-slate-950 font-display font-black text-xs uppercase tracking-wider shadow-lg shadow-cyan-500/20 hover:scale-[1.02] active:scale-95 transition-all flex items-center gap-1.5"
                >
                  <span>+</span>
                  <span>Tạo Key Thủ Công</span>
                </button>
              </div>
            </div>

            <!-- KPI Metric Cards -->
            <div class="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4 pt-2">
              <div class="p-4 rounded-2xl bg-black/40 border border-slate-800/80 space-y-1">
                <div class="text-[10px] font-mono text-slate-500 uppercase font-bold">Tổng Đơn VietQR</div>
                <div class="text-xl sm:text-2xl font-display font-black text-white">{{ tdropOrders.length }}</div>
                <div class="text-[10px] font-mono text-cyan-400">Giao dịch hệ thống</div>
              </div>

              <div class="p-4 rounded-2xl border space-y-1 transition-all"
                   :class="tdropPendingOrdersCount > 0 ? 'bg-amber-500/10 border-amber-500/40 shadow-lg shadow-amber-500/10' : 'bg-black/40 border-slate-800/80'">
                <div class="text-[10px] font-mono uppercase font-bold" :class="tdropPendingOrdersCount > 0 ? 'text-amber-400' : 'text-slate-500'">
                  Đơn Chờ Duyệt (Pending)
                </div>
                <div class="text-xl sm:text-2xl font-display font-black" :class="tdropPendingOrdersCount > 0 ? 'text-amber-300' : 'text-white'">
                  {{ tdropPendingOrdersCount }}
                </div>
                <div class="text-[10px] font-mono" :class="tdropPendingOrdersCount > 0 ? 'text-amber-400 font-bold' : 'text-slate-500'">
                  {{ tdropPendingOrdersCount > 0 ? '⚡ Cần duyệt cấp key ngay' : 'Không có đơn tồn' }}
                </div>
              </div>

              <div class="p-4 rounded-2xl bg-black/40 border border-slate-800/80 space-y-1">
                <div class="text-[10px] font-mono text-slate-500 uppercase font-bold">Doanh Thu Đã Duyệt</div>
                <div class="text-xl sm:text-2xl font-display font-black text-emerald-400">
                  {{ tdropTotalRevenue.toLocaleString('vi-VN') }} đ
                </div>
                <div class="text-[10px] font-mono text-slate-400">{{ tdropApprovedOrdersCount }} đơn đã duyệt</div>
              </div>

              <div class="p-4 rounded-2xl bg-black/40 border border-slate-800/80 space-y-1">
                <div class="text-[10px] font-mono text-slate-500 uppercase font-bold">License Đang Hoạt Động</div>
                <div class="text-xl sm:text-2xl font-display font-black text-indigo-400">{{ tdropActiveLicensesCount }}</div>
                <div class="text-[10px] font-mono text-slate-400">Tổng {{ tdropLicenses.length }} mã key</div>
              </div>
            </div>
          </div>

          <!-- Sub-Tab Navigation Bar -->
          <div class="flex items-center justify-between flex-wrap gap-3 border-b border-slate-800 pb-3">
            <div class="flex items-center gap-2">
              <button 
                @click="tdropActiveSubTab = 'orders'"
                class="px-4 py-2 rounded-xl text-xs font-mono font-bold transition-all flex items-center gap-2"
                :class="tdropActiveSubTab === 'orders' ? 'bg-cyan-500/20 text-cyan-300 border border-cyan-500/40 shadow-lg shadow-cyan-500/10' : 'text-slate-400 hover:text-white border border-transparent'"
              >
                <span>🧾 Đơn Hàng VietQR</span>
                <span class="px-2 py-0.5 rounded-full text-[10px]" :class="tdropPendingOrdersCount > 0 ? 'bg-amber-500 text-slate-950 font-black' : 'bg-slate-800 text-slate-400'">
                  {{ tdropOrders.length }}
                </span>
              </button>

              <button 
                @click="tdropActiveSubTab = 'licenses'"
                class="px-4 py-2 rounded-xl text-xs font-mono font-bold transition-all flex items-center gap-2"
                :class="tdropActiveSubTab === 'licenses' ? 'bg-indigo-500/20 text-indigo-300 border border-indigo-500/40 shadow-lg shadow-indigo-500/10' : 'text-slate-400 hover:text-white border border-transparent'"
              >
                <span>🔑 Quản Lý Bản Quyền (Licenses)</span>
                <span class="px-2 py-0.5 rounded-full bg-slate-800 text-slate-400 text-[10px]">
                  {{ tdropLicenses.length }}
                </span>
              </button>
            </div>

            <!-- Filters for active sub tab -->
            <div v-if="tdropActiveSubTab === 'orders'" class="flex items-center gap-2 text-xs font-mono">
              <span class="text-slate-500">Lọc đơn:</span>
              <select 
                v-model="tdropOrderFilter" 
                @change="loadTDropData"
                class="px-3 py-1.5 rounded-xl bg-slate-900 border border-slate-700 text-cyan-300 text-xs font-bold outline-none cursor-pointer"
              >
                <option value="all">Tất cả trạng thái</option>
                <option value="pending">⏳ Chờ duyệt (Pending)</option>
                <option value="approved">✓ Đã duyệt (Approved)</option>
                <option value="rejected">✕ Đã từ chối (Rejected)</option>
              </select>
            </div>

            <div v-if="tdropActiveSubTab === 'licenses'" class="flex items-center gap-2 flex-wrap text-xs font-mono">
              <input 
                type="text" 
                v-model="tdropLicenseSearch" 
                @input="debounceTDropSearch"
                placeholder="Tìm mã key, machine ID..." 
                class="px-3 py-1.5 rounded-xl bg-slate-900 border border-slate-700 text-white text-xs outline-none focus:border-indigo-400 w-48"
              />
              <select 
                v-model="tdropLicenseRoleFilter" 
                @change="loadTDropData"
                class="px-3 py-1.5 rounded-xl bg-slate-900 border border-slate-700 text-indigo-300 text-xs font-bold outline-none cursor-pointer"
              >
                <option value="all">Tất cả gói</option>
                <option value="VIP">VIP (30 ngày)</option>
                <option value="PREMIUM">PREMIUM (60 ngày)</option>
              </select>
            </div>
          </div>

          <!-- SUB-TAB 1: ORDERS LIST -->
          <div v-if="tdropActiveSubTab === 'orders'" class="space-y-4">
            <div v-if="filteredTDropOrders.length === 0" class="p-12 rounded-3xl border border-slate-800 bg-[#090d1a]/80 text-center font-mono text-xs text-slate-500 space-y-2">
              <div class="text-3xl">📭</div>
              <div>Không tìm thấy đơn hàng VietQR nào phù hợp với bộ lọc.</div>
            </div>

            <div v-else class="grid grid-cols-1 gap-4">
              <div 
                v-for="order in filteredTDropOrders" 
                :key="order.id || order.order_code"
                class="p-5 sm:p-6 rounded-2xl border bg-[#090d1a]/90 backdrop-blur-xl transition-all space-y-4"
                :class="order.status === 'pending' ? 'border-amber-500/40 shadow-xl shadow-amber-500/5' : 'border-slate-800'"
              >
                <!-- Order Top Line -->
                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-slate-800/80">
                  <div class="flex items-center gap-3 flex-wrap">
                    <span class="text-base font-display font-black text-white tracking-wide">
                      {{ order.order_code }}
                    </span>
                    <span 
                      class="px-2.5 py-0.5 rounded-full text-[10px] font-mono font-bold uppercase tracking-wider border"
                      :class="order.role === 'PREMIUM' ? 'bg-purple-500/20 text-purple-300 border-purple-500/40' : 'bg-cyan-500/20 text-cyan-300 border-cyan-500/40'"
                    >
                      ★ GÓI {{ order.role }} ({{ order.role === 'PREMIUM' ? '60 Ngày' : '30 Ngày' }})
                    </span>
                    <span 
                      class="px-2.5 py-0.5 rounded-full text-[10px] font-mono font-bold uppercase tracking-wider border"
                      :class="{
                        'bg-amber-500/20 text-amber-300 border-amber-500/40 animate-pulse': order.status === 'pending',
                        'bg-emerald-500/20 text-emerald-300 border-emerald-500/40': order.status === 'approved',
                        'bg-rose-500/20 text-rose-300 border-rose-500/40': order.status === 'rejected'
                      }"
                    >
                      {{ order.status === 'pending' ? '⏳ CHỜ DUYỆT' : order.status === 'approved' ? '✓ ĐÃ DUYỆT' : '✕ ĐÃ TỪ CHỐI' }}
                    </span>
                  </div>

                  <!-- Amount & Date -->
                  <div class="flex items-center gap-3 text-xs font-mono">
                    <span class="text-sm font-bold text-emerald-400">
                      {{ (Number(order.amount) || (order.role === 'PREMIUM' ? 49000 : 29000)).toLocaleString('vi-VN') }} VNĐ
                    </span>
                    <span class="text-slate-500 text-[11px]">
                      {{ new Date(order.created_at).toLocaleString('vi-VN') }}
                    </span>
                  </div>
                </div>

                <!-- Order Details Grid -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-3 text-xs font-mono">
                  <div class="p-3 rounded-xl bg-black/50 border border-slate-800 space-y-1">
                    <div class="text-[10px] text-slate-500 font-bold uppercase">MÃ MÁY KHÁCH HÀNG (MACHINE ID):</div>
                    <div class="flex items-center justify-between gap-2">
                      <span class="text-cyan-300 font-bold font-mono break-all">{{ order.machine_id }}</span>
                      <button @click="copy(order.machine_id)" class="text-cyan-400 hover:text-cyan-200 text-[11px] underline shrink-0 font-bold">Copy</button>
                    </div>
                  </div>

                  <div class="p-3 rounded-xl bg-black/50 border border-slate-800 space-y-1">
                    <div class="text-[10px] text-slate-500 font-bold uppercase">EMAIL NHẬN MÃ BẢN QUYỀN:</div>
                    <div class="flex items-center justify-between gap-2">
                      <span class="text-white font-mono break-all">{{ order.email }}</span>
                      <a :href="'mailto:' + order.email" class="text-pink-400 hover:text-pink-300 text-[11px] underline shrink-0 font-bold">Mail</a>
                    </div>
                  </div>
                </div>

                <!-- Transfer Content -->
                <div v-if="order.transfer_content" class="p-3 rounded-xl bg-slate-900/60 border border-slate-800 text-xs font-mono flex items-center justify-between gap-2">
                  <div class="truncate">
                    <span class="text-slate-500">Nội dung CK:</span> 
                    <span class="text-slate-200 ml-1.5">{{ order.transfer_content }}</span>
                  </div>
                  <button @click="copy(order.transfer_content)" class="text-slate-400 hover:text-slate-200 text-[10px] shrink-0">Copy ND</button>
                </div>

                <!-- License Key Generated Card (If Approved) -->
                <div v-if="order.license_key" class="p-3.5 rounded-xl bg-emerald-500/10 border border-emerald-500/30 flex flex-col sm:flex-row sm:items-center justify-between gap-2 text-xs font-mono">
                  <div class="flex items-center gap-2 flex-wrap">
                    <span class="text-emerald-400 font-bold">🔑 MÃ KEY ĐÃ CẤP:</span>
                    <span class="text-emerald-200 font-bold font-mono text-sm px-2 py-0.5 rounded bg-emerald-500/20 border border-emerald-500/40">
                      {{ order.license_key }}
                    </span>
                  </div>
                  <div class="flex items-center gap-2">
                    <button @click="copy(order.license_key)" class="px-3 py-1 rounded-lg bg-emerald-500/20 hover:bg-emerald-500/30 text-emerald-300 font-bold text-[11px] transition-all">
                      Sao Chép Key
                    </button>
                    <button @click="openMailtoClient(order)" class="px-3 py-1 rounded-lg bg-cyan-500/20 hover:bg-cyan-500/30 text-cyan-300 font-bold text-[11px] transition-all flex items-center gap-1">
                      <span>📧</span>
                      <span>Gửi Lại Email</span>
                    </button>
                  </div>
                </div>

                <!-- Action Footer -->
                <div class="flex items-center justify-between flex-wrap gap-3 pt-2">
                  <div class="text-[11px] font-mono text-slate-500">
                    <span v-if="order.approved_at">Duyệt lúc: {{ new Date(order.approved_at).toLocaleString('vi-VN') }}</span>
                    <span v-else>Đang chờ duyệt thanh toán VietQR</span>
                  </div>

                  <div class="flex items-center gap-2">
                    <!-- Approve Button -->
                    <button 
                      v-if="order.status === 'pending'"
                      @click="handleApproveTDropOrder(order)"
                      class="px-5 py-2.5 rounded-xl bg-gradient-to-r from-emerald-400 via-teal-500 to-cyan-500 text-slate-950 font-display font-black text-xs uppercase tracking-wider shadow-lg shadow-emerald-500/25 hover:scale-[1.02] active:scale-95 transition-all flex items-center gap-1.5"
                    >
                      <span>⚡</span>
                      <span>Duyệt & Cấp Key</span>
                    </button>

                    <!-- Auto Send & Mailto for Approved -->
                    <div v-if="order.status === 'approved'" class="flex items-center gap-2">
                      <button 
                        @click="sendAutoEmail(order)"
                        :disabled="sendingEmailOrderId === order.order_code"
                        class="px-4 py-2 rounded-xl bg-gradient-to-r from-emerald-500/20 via-teal-500/20 to-cyan-500/20 hover:from-emerald-500/30 hover:to-cyan-500/30 border border-emerald-500/40 text-emerald-300 font-mono text-xs font-bold transition-all flex items-center gap-1.5"
                      >
                        <span v-if="sendingEmailOrderId === order.order_code" class="animate-spin">⏳</span>
                        <span v-else>🚀</span>
                        <span>{{ sendingEmailOrderId === order.order_code ? 'Đang gửi email...' : 'Gửi Email Tự Động' }}</span>
                      </button>

                      <button 
                        @click="openMailtoClient(order)"
                        class="px-2.5 py-2 rounded-xl bg-slate-800/80 hover:bg-slate-700 text-slate-400 hover:text-white font-mono text-[11px] transition-all"
                        title="Mở ứng dụng email dự phòng (Mailto)"
                      >
                        Mailto
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- SUB-TAB 2: LICENSES LIST -->
          <div v-if="tdropActiveSubTab === 'licenses'" class="space-y-4">
            <div v-if="filteredTDropLicenses.length === 0" class="p-12 rounded-3xl border border-slate-800 bg-[#090d1a]/80 text-center font-mono text-xs text-slate-500 space-y-2">
              <div class="text-3xl">🔑</div>
              <div>Không tìm thấy mã bản quyền nào. Bạn có thể bấm "Tạo Key Thủ Công" để tạo mới.</div>
            </div>

            <!-- Licenses Table -->
            <div v-else class="overflow-x-auto rounded-2xl border border-slate-800 bg-[#090d1a]/80">
              <table class="w-full text-left text-xs font-mono">
                <thead class="bg-slate-900/90 text-slate-400 uppercase text-[10px] tracking-wider border-b border-slate-800">
                  <tr>
                    <th class="p-3.5">Mã Bản Quyền (License Key)</th>
                    <th class="p-3.5">Gói</th>
                    <th class="p-3.5">Machine ID</th>
                    <th class="p-3.5">Thiết Bị / Khách Hàng</th>
                    <th class="p-3.5">Hạn Dùng</th>
                    <th class="p-3.5">Trạng Thái</th>
                    <th class="p-3.5 text-right">Thao Tác</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60">
                  <tr v-for="lic in filteredTDropLicenses" :key="lic.id || lic.key" class="hover:bg-slate-800/20 transition-colors">
                    <td class="p-3.5">
                      <div class="flex items-center gap-2">
                        <span class="font-bold text-cyan-300 font-mono">{{ lic.key }}</span>
                        <button @click="copy(lic.key)" class="text-[10px] text-slate-500 hover:text-cyan-400 font-bold">Copy</button>
                      </div>
                      <div class="text-[10px] text-slate-500">{{ new Date(lic.created_at).toLocaleDateString('vi-VN') }}</div>
                    </td>
                    <td class="p-3.5">
                      <span 
                        class="px-2 py-0.5 rounded text-[10px] font-bold"
                        :class="lic.role === 'PREMIUM' ? 'bg-purple-500/20 text-purple-300 border border-purple-500/30' : 'bg-cyan-500/20 text-cyan-300 border border-cyan-500/30'"
                      >
                        {{ lic.role }}
                      </span>
                    </td>
                    <td class="p-3.5 max-w-[160px] truncate">
                      <span class="text-slate-300" :title="lic.hardware_id">{{ lic.hardware_id || 'Chưa gắn' }}</span>
                    </td>
                    <td class="p-3.5 max-w-[180px] truncate">
                      <div class="text-white">{{ lic.device_name || lic.user_name || 'Khách hàng' }}</div>
                      <div v-if="lic.note" class="text-[10px] text-slate-500 truncate" :title="lic.note">{{ lic.note }}</div>
                    </td>
                    <td class="p-3.5">
                      <span 
                        class="text-[11px] font-bold"
                        :class="calculateRemainingDays(lic.expires_at).includes('hết hạn') ? 'text-rose-400' : 'text-emerald-400'"
                      >
                        {{ calculateRemainingDays(lic.expires_at) }}
                      </span>
                    </td>
                    <td class="p-3.5">
                      <span 
                        class="px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider"
                        :class="lic.status === 'active' ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/30' : 'bg-rose-500/20 text-rose-300 border border-rose-500/30'"
                      >
                        {{ lic.status === 'active' ? 'ACTIVE' : 'REVOKED' }}
                      </span>
                    </td>
                    <td class="p-3.5 text-right">
                      <button 
                        v-if="lic.status === 'active'"
                        @click="handleRevokeTDropLicense(lic)"
                        class="px-2.5 py-1 rounded-lg border border-rose-500/30 bg-rose-500/10 hover:bg-rose-500/20 text-rose-300 text-[11px] font-bold transition-all"
                        title="Thu hồi bản quyền key này"
                      >
                        Thu Hồi
                      </button>
                      <span v-else class="text-slate-600 text-[11px] italic">Đã thu hồi</span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

        </div>

        <!-- ================================================================= -->
        <!-- ================================================================= -->
        <!-- TAB 6: GAME MỲ CAY - THỐNG KÊ LƯỢT XEM & BAN THIẾT BỊ VĨNH VIỄN    -->
        <!-- ================================================================= -->
        <div v-if="activeTab === 'mycay'" class="space-y-6">
          
          <!-- Banner & Quick Controls -->
          <div class="p-6 rounded-3xl border border-orange-500/30 bg-gradient-to-br from-[#1d0b0b] via-[#240e0e] to-[#0c0505] backdrop-blur-xl shadow-2xl space-y-5">
            <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
              <div class="flex items-center gap-4">
                <div class="w-14 h-14 rounded-2xl bg-orange-950/80 border border-orange-500/40 p-2 flex items-center justify-center shadow-lg shadow-orange-500/20 shrink-0 text-3xl">
                  🍜
                </div>
                <div>
                  <div class="flex items-center gap-2 mb-1">
                    <span class="w-2 h-2 rounded-full bg-orange-400 animate-ping"></span>
                    <span class="text-[10px] font-mono tracking-widest text-orange-400 uppercase font-bold">
                      MYCAY ENGINE // ANTI-CHEAT & LIVE ANALYTICS
                    </span>
                  </div>
                  <h2 class="text-xl sm:text-2xl font-display font-black text-white">
                    Quản Lý & Thống Kê Game Mỳ Cay
                  </h2>
                  <p class="text-xs text-slate-400 font-mono">
                    Hệ thống theo dõi telemetry thời gian thực, biểu đồ Chart.js trực quan và quản lý khóa ban thiết bị gian lận.
                  </p>
                </div>
              </div>

              <!-- Top Action Controls -->
              <div class="flex flex-wrap items-center gap-2.5">
                <!-- Real-time Live Status Badge -->
                <div 
                  class="flex items-center gap-2 px-3 py-1.5 rounded-xl border font-mono text-xs shadow-sm transition-all"
                  :class="mycayRealtimeStatus === 'connected' 
                    ? 'border-emerald-500/40 bg-emerald-500/10 text-emerald-300' 
                    : 'border-amber-500/40 bg-amber-500/10 text-amber-300'"
                >
                  <span 
                    class="w-2 h-2 rounded-full"
                    :class="mycayRealtimeStatus === 'connected' ? 'bg-emerald-400 animate-ping' : 'bg-amber-400 animate-pulse'"
                  ></span>
                  <span class="font-bold">
                    {{ mycayRealtimeStatus === 'connected' ? '⚡ REAL-TIME LIVE' : '⏳ ĐANG KẾT NỐI' }}
                  </span>
                  <span class="text-[10px] opacity-80 hidden sm:inline">
                    (Tự động đồng bộ)
                  </span>
                </div>

                <button 
                  @click="() => loadMycayData(false)"
                  :disabled="isMycayLoading"
                  class="px-3.5 py-2 rounded-xl bg-slate-800 hover:bg-slate-700 border border-slate-700 text-slate-300 hover:text-white text-xs font-mono font-bold flex items-center gap-1.5 transition-all"
                >
                  <span :class="isMycayLoading ? 'animate-spin' : ''">🔄</span>
                  <span>{{ isMycayLoading ? 'Đang tải...' : 'Làm Mới' }}</span>
                </button>

                <button 
                  @click="showMycayBanModal = true"
                  class="px-4 py-2 rounded-xl bg-gradient-to-r from-orange-500 via-rose-500 to-red-600 text-white font-display font-black text-xs uppercase tracking-wider shadow-lg shadow-rose-500/25 hover:scale-[1.02] active:scale-95 transition-all flex items-center gap-1.5"
                >
                  <span>🚫</span>
                  <span>+ Khóa / Ban Thiết Bị</span>
                </button>
              </div>
            </div>

            <!-- KPI Metric Cards -->
            <div class="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4 pt-2">
              <div class="p-4 rounded-2xl bg-black/40 border border-orange-500/30 space-y-1">
                <div class="text-[10px] font-mono text-orange-400 uppercase font-bold flex items-center gap-1">
                  <span>🔥</span> Lượt Chơi / Xem Game
                </div>
                <div class="text-xl sm:text-3xl font-display font-black text-orange-300">
                  {{ mycayViews.toLocaleString() }}
                </div>
                <div class="text-[10px] font-mono text-slate-400">
                  Cập nhật: {{ mycayAnalytics?.updated_at ? new Date(mycayAnalytics.updated_at).toLocaleDateString('vi-VN') : 'Mới nhất' }}
                </div>
              </div>

              <div class="p-4 rounded-2xl bg-black/40 border border-sky-500/30 space-y-1">
                <div class="text-[10px] font-mono text-sky-400 uppercase font-bold flex items-center gap-1">
                  <span>🌐</span> Nhật Ký Đã Ghi Nhận
                </div>
                <div class="text-xl sm:text-3xl font-display font-black text-sky-300">
                  {{ mycayVisitLogs.length }}
                </div>
                <div class="text-[10px] font-mono text-slate-400">Phiên truy cập chi tiết</div>
              </div>

              <div class="p-4 rounded-2xl bg-black/40 border border-red-500/30 space-y-1">
                <div class="text-[10px] font-mono text-red-400 uppercase font-bold flex items-center gap-1">
                  <span>⛔</span> Ban Vĩnh Viễn
                </div>
                <div class="text-xl sm:text-3xl font-display font-black text-red-400">
                  {{ mycayPermanentBansCount }}
                </div>
                <div class="text-[10px] font-mono text-slate-400">Vi phạm DevTools / gian lận</div>
              </div>

              <div class="p-4 rounded-2xl bg-black/40 border border-amber-500/30 space-y-1">
                <div class="text-[10px] font-mono text-amber-400 uppercase font-bold flex items-center gap-1">
                  <span>⏳</span> Khóa Tạm Thời
                </div>
                <div class="text-xl sm:text-3xl font-display font-black text-amber-300">
                  {{ mycayTemporaryLocksCount }}
                </div>
                <div class="text-[10px] font-mono text-slate-400">Đang chờ hết cooldown</div>
              </div>
            </div>
          </div>

          <!-- Sub-Tab Navigation Bar & Chart.js ON/OFF Toggle -->
          <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 p-3.5 rounded-2xl bg-[#090d1a]/90 border border-slate-800">
            <div class="flex items-center gap-2 flex-wrap text-xs font-mono font-bold">
              <button 
                @click="mycaySubTab = 'overview'"
                class="px-3.5 py-2 rounded-xl border transition-all flex items-center gap-1.5"
                :class="mycaySubTab === 'overview' ? 'bg-orange-500/20 text-orange-300 border-orange-500/50 shadow-lg shadow-orange-500/20' : 'text-slate-400 hover:text-white border-transparent'"
              >
                <span>📊</span>
                <span>Tổng Quan & Biểu Đồ</span>
              </button>

              <button 
                @click="mycaySubTab = 'locks'"
                class="px-3.5 py-2 rounded-xl border transition-all flex items-center gap-1.5"
                :class="mycaySubTab === 'locks' ? 'bg-red-500/20 text-red-300 border-red-500/50 shadow-lg shadow-red-500/20' : 'text-slate-400 hover:text-white border-transparent'"
              >
                <span>⛔</span>
                <span>Danh Sách Ban & Khóa</span>
                <span class="px-1.5 py-0.2 rounded bg-red-500/20 text-red-300 text-[10px]">{{ mycayLocks.length }}</span>
              </button>

              <button 
                @click="mycaySubTab = 'logs'"
                class="px-3.5 py-2 rounded-xl border transition-all flex items-center gap-1.5"
                :class="mycaySubTab === 'logs' ? 'bg-sky-500/20 text-sky-300 border-sky-500/50 shadow-lg shadow-sky-500/20' : 'text-slate-400 hover:text-white border-transparent'"
              >
                <span>🌐</span>
                <span>Nhật Ký Truy Cập</span>
                <span class="px-1.5 py-0.2 rounded bg-sky-500/20 text-sky-300 text-[10px]">{{ mycayVisitLogs.length }}</span>
              </button>
            </div>

            <!-- CHART.JS ON / OFF TOGGLE SWITCH -->
            <div class="flex items-center gap-2 font-mono text-xs">
              <button 
                @click="toggleMycayCharts"
                class="px-3.5 py-2 rounded-xl border transition-all flex items-center gap-2 text-xs font-bold"
                :class="showMycayCharts 
                  ? 'bg-emerald-500/15 border-emerald-500/40 text-emerald-300 shadow-lg shadow-emerald-500/10' 
                  : 'bg-slate-800/80 border-slate-700 text-slate-400 hover:text-slate-200'"
                title="Bật hoặc Tắt biểu đồ Chart.js"
              >
                <span>{{ showMycayCharts ? '📈' : '📉' }}</span>
                <span>Biểu Đồ Chart.js:</span>
                <span 
                  class="px-2 py-0.5 rounded-full text-[10px] font-black uppercase transition-all"
                  :class="showMycayCharts ? 'bg-emerald-500 text-slate-950 shadow-sm' : 'bg-slate-700 text-slate-300'"
                >
                  {{ showMycayCharts ? 'BẬT' : 'TẮT' }}
                </span>
              </button>
            </div>
          </div>

          <!-- ============================================================= -->
          <!-- SUB-TAB 1: OVERVIEW & CHART.JS DASHBOARD                      -->
          <!-- ============================================================= -->
          <div v-if="mycaySubTab === 'overview'" class="space-y-6">

            <!-- Chart.js Visualization Section (Conditional on Toggle) -->
            <div v-if="showMycayCharts" class="space-y-6">
              
              <!-- 3 Interactive Cyber Charts Grid -->
              <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                
                <!-- Chart 1: 30-Day Daily Visits Trend (Span 2 Cols) -->
                <div class="lg:col-span-2 p-5 rounded-3xl border border-orange-500/25 bg-[#090d1a]/90 backdrop-blur-xl space-y-4 shadow-xl">
                  <div class="flex items-center justify-between">
                    <div class="flex items-center gap-2">
                      <span class="w-2.5 h-2.5 rounded-full bg-orange-500 animate-pulse"></span>
                      <h3 class="font-display font-black text-white text-sm sm:text-base">
                        Xu Hướng Lượt Truy Cập Theo Ngày (30 Ngày Qua)
                      </h3>
                    </div>
                    <span class="text-[10px] font-mono text-orange-400 px-2 py-0.5 rounded bg-orange-500/10 border border-orange-500/20">
                      Line Area Chart
                    </span>
                  </div>

                  <div class="h-64 sm:h-72 w-full relative">
                    <canvas ref="dailyTrendCanvas"></canvas>
                  </div>
                </div>

                <!-- Chart 2: Device Distribution Doughnut -->
                <div class="p-5 rounded-3xl border border-cyan-500/25 bg-[#090d1a]/90 backdrop-blur-xl space-y-4 shadow-xl flex flex-col justify-between">
                  <div class="flex items-center justify-between">
                    <div class="flex items-center gap-2">
                      <span class="w-2.5 h-2.5 rounded-full bg-cyan-400"></span>
                      <h3 class="font-display font-black text-white text-sm sm:text-base">
                        Phân Bố Loại Thiết Bị
                      </h3>
                    </div>
                    <span class="text-[10px] font-mono text-cyan-300 px-2 py-0.5 rounded bg-cyan-500/10 border border-cyan-500/20">
                      Doughnut
                    </span>
                  </div>

                  <div class="h-56 w-full relative flex items-center justify-center">
                    <canvas ref="devicesCanvas"></canvas>
                  </div>

                  <div class="text-[11px] font-mono text-slate-400 text-center border-t border-slate-800/80 pt-2">
                    Tỉ lệ truy cập từ Mobile vs Desktop vs Tablet
                  </div>
                </div>

              </div>

              <!-- Chart 3 & Geographic Distribution Row -->
              <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                
                <!-- Chart 3: Browsers Breakdown Bar -->
                <div class="lg:col-span-2 p-5 rounded-3xl border border-sky-500/25 bg-[#090d1a]/90 backdrop-blur-xl space-y-4 shadow-xl">
                  <div class="flex items-center justify-between">
                    <div class="flex items-center gap-2">
                      <span class="w-2.5 h-2.5 rounded-full bg-sky-400"></span>
                      <h3 class="font-display font-black text-white text-sm sm:text-base">
                        Thống Kê Trình Duyệt Phổ Biến
                      </h3>
                    </div>
                    <span class="text-[10px] font-mono text-sky-300 px-2 py-0.5 rounded bg-sky-500/10 border border-sky-500/20">
                      Bar Chart
                    </span>
                  </div>

                  <div class="h-56 sm:h-64 w-full relative">
                    <canvas ref="browsersCanvas"></canvas>
                  </div>
                </div>

                <!-- Geographic Distribution Countries Card -->
                <div class="p-5 rounded-3xl border border-emerald-500/25 bg-[#090d1a]/90 backdrop-blur-xl space-y-4 shadow-xl flex flex-col justify-between">
                  <div>
                    <div class="flex items-center justify-between mb-3">
                      <div class="flex items-center gap-2">
                        <span class="w-2.5 h-2.5 rounded-full bg-emerald-400"></span>
                        <h3 class="font-display font-black text-white text-sm sm:text-base">
                          Khu Vực & Quốc Gia
                        </h3>
                      </div>
                      <span class="text-[10px] font-mono text-emerald-300 px-2 py-0.5 rounded bg-emerald-500/10 border border-emerald-500/20">
                        Geo Breakdown
                      </span>
                    </div>

                    <div class="space-y-2 max-h-56 overflow-y-auto pr-1">
                      <div 
                        v-for="country in (mycayStats?.countries || [{ code: 'VN', label: 'Việt Nam', count: mycayViews }])" 
                        :key="country.code"
                        class="p-2.5 rounded-xl bg-black/40 border border-slate-800 flex items-center justify-between text-xs font-mono"
                      >
                        <div class="flex items-center gap-2">
                          <span class="text-base">🇻🇳</span>
                          <span class="text-white font-bold">{{ country.label || country.code || 'Việt Nam' }}</span>
                        </div>
                        <span class="px-2 py-0.5 rounded bg-emerald-500/20 text-emerald-300 font-bold text-[11px]">
                          {{ country.count }} lượt
                        </span>
                      </div>
                    </div>
                  </div>

                  <div class="text-[10px] font-mono text-slate-500 text-center border-t border-slate-800/80 pt-2">
                    Ghi nhận qua IP & header Cloudflare/Supabase
                  </div>
                </div>

              </div>

            </div>

            <!-- COLLAPSED NOTICE WHEN CHARTS ARE TOGGLED OFF -->
            <div 
              v-else 
              class="p-8 rounded-3xl border border-slate-800 bg-[#090d1a]/60 text-center space-y-3"
            >
              <div class="text-3xl">📉</div>
              <h3 class="font-display font-bold text-white text-base">
                Biểu Đồ Chart.js Đang Được TẮT
              </h3>
              <p class="text-xs font-mono text-slate-400 max-w-md mx-auto">
                Chế độ rút gọn giúp giao diện mượt mà và tiết kiệm diện tích. Bạn có thể bật lại bất cứ lúc nào để xem các biểu đồ đường, tròn và cột trực quan.
              </p>
              <button 
                @click="toggleMycayCharts"
                class="px-4 py-2 rounded-xl bg-emerald-500/20 hover:bg-emerald-500/30 border border-emerald-500/40 text-emerald-300 font-mono font-bold text-xs transition-all inline-flex items-center gap-1.5"
              >
                <span>📈</span>
                <span>Bật Lại Biểu Đồ Chart.js Ngay</span>
              </button>
            </div>

            <!-- Quick Jump Summaries Row -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              
              <!-- Quick Jump: Security Locks -->
              <div class="p-5 rounded-2xl border border-red-500/20 bg-[#090d1a]/80 space-y-3">
                <div class="flex items-center justify-between">
                  <div class="font-display font-black text-white text-sm flex items-center gap-2">
                    <span>⛔</span>
                    <span>An Ninh: Thiết Bị Đang Bị Khóa ({{ mycayLocks.length }})</span>
                  </div>
                  <button 
                    @click="mycaySubTab = 'locks'"
                    class="text-xs font-mono text-red-400 hover:text-red-300 underline"
                  >
                    Xem Chi Tiết →
                  </button>
                </div>
                <div v-if="mycayLocks.length === 0" class="text-xs font-mono text-slate-500 italic">
                  Chưa có thiết bị nào bị khóa.
                </div>
                <div v-else class="space-y-1.5">
                  <div 
                    v-for="lock in mycayLocks.slice(0, 3)" 
                    :key="lock.device_id"
                    class="p-2 rounded-xl bg-black/40 border border-slate-800/80 flex items-center justify-between text-xs font-mono"
                  >
                    <span class="text-slate-300 break-all font-bold">{{ lock.device_id }}</span>
                    <span 
                      class="text-[10px] px-2 py-0.5 rounded font-bold uppercase"
                      :class="lock.is_permanent_ban ? 'bg-red-500/20 text-red-300' : 'bg-amber-500/20 text-amber-300'"
                    >
                      {{ lock.is_permanent_ban ? 'Ban Vĩnh Viễn' : 'Khóa Tạm' }}
                    </span>
                  </div>
                </div>
              </div>

              <!-- Quick Jump: Visit Logs -->
              <div class="p-5 rounded-2xl border border-sky-500/20 bg-[#090d1a]/80 space-y-3">
                <div class="flex items-center justify-between">
                  <div class="font-display font-black text-white text-sm flex items-center gap-2">
                    <span>🌐</span>
                    <span>Nhật Ký Truy Cập Mới Nhất ({{ mycayVisitLogs.length }})</span>
                  </div>
                  <button 
                    @click="mycaySubTab = 'logs'"
                    class="text-xs font-mono text-sky-400 hover:text-sky-300 underline"
                  >
                    Xem Nhật Ký →
                  </button>
                </div>
                <div v-if="mycayVisitLogs.length === 0" class="text-xs font-mono text-slate-500 italic">
                  Chưa có nhật ký truy cập nào được ghi nhận.
                </div>
                <div v-else class="space-y-1.5">
                  <div 
                    v-for="log in mycayVisitLogs.slice(0, 3)" 
                    :key="log.id"
                    class="p-2 rounded-xl bg-black/40 border border-slate-800/80 flex items-center justify-between text-xs font-mono"
                  >
                    <div class="flex items-center gap-2">
                      <span class="text-sky-300 font-bold">{{ log.browser || 'Browser' }}</span>
                      <span class="text-slate-500 text-[11px]">({{ log.device_type || 'Desktop' }})</span>
                    </div>
                    <span class="text-slate-400 text-[10px]">
                      {{ log.created_at ? new Date(log.created_at).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' }) : '—' }}
                    </span>
                  </div>
                </div>
              </div>

            </div>

          </div>

          <!-- ============================================================= -->
          <!-- SUB-TAB 2: SECURITY LOCKS & BAN MANAGEMENT                    -->
          <!-- ============================================================= -->
          <div v-if="mycaySubTab === 'locks'" class="space-y-4">
            
            <!-- Filter & Search Controls -->
            <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 p-4 rounded-2xl bg-[#090d1a]/80 border border-slate-800">
              <div class="flex items-center gap-2 flex-wrap text-xs font-mono">
                <span class="text-slate-400 font-bold">Lọc:</span>
                <button 
                  @click="mycayFilter = 'all'"
                  :class="mycayFilter === 'all' ? 'bg-orange-500/20 text-orange-300 border-orange-500/40 font-bold' : 'text-slate-400 hover:text-white border-transparent'"
                  class="px-3 py-1.5 rounded-lg border transition-all"
                >
                  Tất Cả ({{ mycayLocks.length }})
                </button>
                <button 
                  @click="mycayFilter = 'permanent'"
                  :class="mycayFilter === 'permanent' ? 'bg-red-500/20 text-red-300 border-red-500/40 font-bold' : 'text-slate-400 hover:text-white border-transparent'"
                  class="px-3 py-1.5 rounded-lg border transition-all"
                >
                  ⛔ Ban Vĩnh Viễn ({{ mycayPermanentBansCount }})
                </button>
                <button 
                  @click="mycayFilter = 'temporary'"
                  :class="mycayFilter === 'temporary' ? 'bg-amber-500/20 text-amber-300 border-amber-500/40 font-bold' : 'text-slate-400 hover:text-white border-transparent'"
                  class="px-3 py-1.5 rounded-lg border transition-all"
                >
                  ⏳ Khóa Tạm ({{ mycayTemporaryLocksCount }})
                </button>
                <button 
                  @click="mycayFilter = 'unlocked'"
                  :class="mycayFilter === 'unlocked' ? 'bg-emerald-500/20 text-emerald-300 border-emerald-500/40 font-bold' : 'text-slate-400 hover:text-white border-transparent'"
                  class="px-3 py-1.5 rounded-lg border transition-all"
                >
                  ✅ Đã Mở / Hết Hạn
                </button>
              </div>

              <div class="w-full sm:w-72">
                <input 
                  type="text"
                  v-model="mycaySearch"
                  placeholder="Tìm mã thiết bị (Device ID)..."
                  class="w-full px-3.5 py-2 rounded-xl bg-black/60 border border-slate-700 text-xs font-mono text-white placeholder-slate-500 outline-none focus:border-orange-400"
                />
              </div>
            </div>

            <!-- Security Locks Table -->
            <div class="border border-slate-800 rounded-3xl overflow-hidden bg-[#090d1a]/80 backdrop-blur-xl">
              <div v-if="filteredMycayLocks.length === 0" class="p-12 text-center font-mono text-xs text-slate-500 space-y-2">
                <div class="text-3xl">🛡️</div>
                <div class="text-slate-400 font-bold">Không có thiết bị nào bị khóa trong danh sách</div>
                <p class="text-[11px] text-slate-600">Khi người chơi mở DevTools hoặc gian lận trên game Mỳ Cay, mã máy sẽ tự động được ghi nhận tại đây.</p>
              </div>

              <div v-else class="overflow-x-auto">
                <table class="w-full text-left border-collapse text-xs font-mono">
                  <thead>
                    <tr class="bg-black/60 border-b border-slate-800 text-slate-400 text-[10px] uppercase tracking-wider">
                      <th class="p-3.5">Mã Thiết Bị (Device ID)</th>
                      <th class="p-3.5">Trạng Thái Khóa</th>
                      <th class="p-3.5">Lý Do</th>
                      <th class="p-3.5 text-center">Số Lần (Strikes)</th>
                      <th class="p-3.5">Thời Hạn Khóa Đến</th>
                      <th class="p-3.5">Cập Nhật</th>
                      <th class="p-3.5 text-right">Thao Tác</th>
                    </tr>
                  </thead>
                  <tbody class="divide-y divide-slate-800/60">
                    <tr v-for="lock in filteredMycayLocks" :key="lock.device_id" class="hover:bg-slate-800/20 transition-colors">
                      <td class="p-3.5">
                        <div class="flex items-center gap-2">
                          <span class="font-bold text-white break-all">{{ lock.device_id }}</span>
                          <button 
                            @click="copy(lock.device_id)"
                            class="p-1 rounded bg-slate-800 hover:bg-slate-700 text-slate-400 hover:text-white text-[10px]"
                            title="Sao chép Device ID"
                          >
                            📋
                          </button>
                        </div>
                      </td>
                      <td class="p-3.5">
                        <span 
                          v-if="lock.is_permanent_ban || (lock.locked_until && new Date(lock.locked_until).getFullYear() >= 9000)"
                          class="px-2.5 py-1 rounded-full text-[10px] font-bold uppercase bg-red-500/20 text-red-300 border border-red-500/40"
                        >
                          ⛔ BAN VĨNH VIỄN
                        </span>
                        <span 
                          v-else-if="lock.locked_until && new Date(lock.locked_until) > new Date()"
                          class="px-2.5 py-1 rounded-full text-[10px] font-bold uppercase bg-amber-500/20 text-amber-300 border border-amber-500/40"
                        >
                          ⏳ KHÓA TẠM THỜI
                        </span>
                        <span 
                          v-else
                          class="px-2.5 py-1 rounded-full text-[10px] font-bold uppercase bg-emerald-500/20 text-emerald-300 border border-emerald-500/40"
                        >
                          ✅ ĐÃ MỞ / HẾT HẠN
                        </span>
                      </td>
                      <td class="p-3.5 text-slate-300">
                        <span class="px-2 py-0.5 rounded bg-slate-800 text-[11px] text-slate-300">
                          {{ lock.reason || 'devtools_violation' }}
                        </span>
                      </td>
                      <td class="p-3.5 text-center font-bold">
                        <span class="text-rose-400">{{ lock.strikes || 1 }}</span>
                        <span class="text-slate-500 text-[10px]"> (Khóa {{ lock.lock_count || 1 }} lần)</span>
                      </td>
                      <td class="p-3.5 text-slate-400 text-[11px]">
                        <span v-if="lock.is_permanent_ban || (lock.locked_until && new Date(lock.locked_until).getFullYear() >= 9000)" class="text-red-400 font-bold">
                          Vô thời hạn (Vĩnh Viễn)
                        </span>
                        <span v-else-if="lock.locked_until" class="text-amber-300 font-mono">
                          {{ new Date(lock.locked_until).toLocaleString('vi-VN') }}
                        </span>
                        <span v-else class="text-slate-600">—</span>
                      </td>
                      <td class="p-3.5 text-slate-500 text-[11px]">
                        {{ lock.updated_at ? new Date(lock.updated_at).toLocaleString('vi-VN') : '—' }}
                      </td>
                      <td class="p-3.5 text-right">
                        <div class="flex items-center justify-end gap-2">
                          <button 
                            v-if="!lock.is_permanent_ban && (!lock.locked_until || new Date(lock.locked_until).getFullYear() < 9000)"
                            @click="handleBanMycayDevice(lock.device_id)"
                            class="px-2.5 py-1 rounded-lg border border-red-500/40 bg-red-500/10 hover:bg-red-500/20 text-red-300 text-[11px] font-bold transition-all"
                            title="Ban vĩnh viễn thiết bị này"
                          >
                            Ban Vĩnh Viễn ⛔
                          </button>
                          <button 
                            @click="handleUnlockMycayDevice(lock.device_id)"
                            class="px-2.5 py-1 rounded-lg border border-emerald-500/40 bg-emerald-500/10 hover:bg-emerald-500/20 text-emerald-300 text-[11px] font-bold transition-all"
                            title="Mở khóa thiết bị (Gỡ ban)"
                          >
                            Mở Khóa 🔓
                          </button>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>

          </div>

          <!-- ============================================================= -->
          <!-- SUB-TAB 3: LIVE VISIT LOGS TELEMETRY TABLE                     -->
          <!-- ============================================================= -->
          <div v-if="mycaySubTab === 'logs'" class="space-y-4">
            
            <div class="p-4 rounded-2xl bg-[#090d1a]/80 border border-slate-800 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
              <div>
                <h3 class="font-display font-black text-white text-sm">
                  Nhật Ký Phiên Truy Cập Trực Tiếp (Live Visit Logs)
                </h3>
                <p class="text-xs font-mono text-slate-400">
                  Dữ liệu ghi nhận tự động từ bảng <code class="text-sky-300">mycay_visit_logs</code>
                </p>
              </div>

              <div class="flex items-center gap-3">
                <span class="text-xs font-mono text-slate-400">
                  Hiển thị {{ mycayVisitLogs.length }} phiên gần nhất
                </span>
                <button 
                  v-if="mycayVisitLogs.length > 0"
                  @click="handleClearAllMycayVisitLogs"
                  class="px-3 py-1.5 rounded-xl border border-rose-500/40 bg-rose-500/10 hover:bg-rose-500/20 text-rose-300 text-xs font-mono font-bold transition-all flex items-center gap-1.5 shadow-sm"
                  title="Xóa sạch toàn bộ nhật ký truy cập"
                >
                  <span>🗑️</span>
                  <span>Xóa Tất Cả Logs</span>
                </button>
              </div>
            </div>

            <div class="border border-slate-800 rounded-3xl overflow-hidden bg-[#090d1a]/80 backdrop-blur-xl">
              <div v-if="mycayVisitLogs.length === 0" class="p-12 text-center font-mono text-xs text-slate-500 space-y-2">
                <div class="text-3xl">🌐</div>
                <div class="text-slate-400 font-bold">Chưa có nhật ký truy cập nào trong hệ thống</div>
              </div>

              <div v-else class="overflow-x-auto">
                <table class="w-full text-left border-collapse text-xs font-mono">
                  <thead>
                    <tr class="bg-black/60 border-b border-slate-800 text-slate-400 text-[10px] uppercase tracking-wider">
                      <th class="p-3.5">ID / Thiết Bị</th>
                      <th class="p-3.5">Địa Lý (Quốc Gia / Thành Phố)</th>
                      <th class="p-3.5">Loại Thiết Bị & HĐH</th>
                      <th class="p-3.5">Trình Duyệt</th>
                      <th class="p-3.5">Độ Phân Giải</th>
                      <th class="p-3.5">Ngôn Ngữ</th>
                      <th class="p-3.5">Thời Gian</th>
                      <th class="p-3.5 text-right">Thao Tác</th>
                    </tr>
                  </thead>
                  <tbody class="divide-y divide-slate-800/60">
                    <tr v-for="log in mycayVisitLogs" :key="log.id" class="hover:bg-slate-800/20 transition-colors">
                      <td class="p-3.5">
                        <div class="flex items-center gap-2">
                          <span class="text-white font-bold">{{ log.device_id || 'Ẩn danh' }}</span>
                          <button 
                            v-if="log.device_id"
                            @click="copy(log.device_id)"
                            class="p-1 rounded bg-slate-800 hover:bg-slate-700 text-slate-400 hover:text-white text-[10px]"
                            title="Sao chép Device ID"
                          >
                            📋
                          </button>
                        </div>
                      </td>
                      <td class="p-3.5">
                        <span class="text-emerald-300 font-bold">
                          {{ log.country_name || log.country || 'Việt Nam' }}
                        </span>
                        <span v-if="log.city" class="text-slate-400 text-[11px]"> • {{ log.city }}</span>
                      </td>
                      <td class="p-3.5">
                        <span 
                          class="px-2 py-0.5 rounded text-[10px] font-bold uppercase"
                          :class="log.device_type === 'Mobile' ? 'bg-orange-500/20 text-orange-300' : 'bg-cyan-500/20 text-cyan-300'"
                        >
                          {{ log.device_type || 'Desktop' }}
                        </span>
                        <span class="text-slate-300 ml-1.5">{{ log.os || 'HĐH' }}</span>
                      </td>
                      <td class="p-3.5 text-sky-300 font-bold">
                        {{ log.browser || 'Google Chrome' }}
                      </td>
                      <td class="p-3.5 text-slate-400 text-[11px]">
                        {{ log.screen_resolution || '1920x1080' }}
                      </td>
                      <td class="p-3.5 text-slate-400 text-[11px]">
                        {{ log.language || 'vi-VN' }}
                      </td>
                      <td class="p-3.5 text-slate-400 text-[11px]">
                        {{ log.created_at ? new Date(log.created_at).toLocaleString('vi-VN') : '—' }}
                      </td>
                      <td class="p-3.5 text-right">
                        <button 
                          @click="handleDeleteMycayVisitLog(log.id)"
                          class="px-2.5 py-1 rounded-lg bg-rose-500/10 hover:bg-rose-500/20 border border-rose-500/30 text-rose-300 hover:text-rose-100 text-[11px] font-bold transition-all inline-flex items-center gap-1 shadow-sm"
                          title="Xóa bản ghi nhật ký này"
                        >
                          <span>🗑️</span>
                          <span>Xóa</span>
                        </button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>

          </div>

        </div>

      </div>

      <!-- =================================================================== -->
      <!-- MODAL: DEVICE TELEMETRY DETAIL                                      -->
      <!-- =================================================================== -->
      <Teleport to="body">
        <div 
          v-if="selectedFeedback" 
          class="fixed inset-0 z-50 bg-black/80 backdrop-blur-md flex items-center justify-center p-4"
          @click.self="selectedFeedback = null"
        >
          <div class="w-full max-w-2xl rounded-3xl border border-slate-800 bg-[#090d1a] p-6 sm:p-8 space-y-5 text-slate-100 shadow-2xl max-h-[90vh] overflow-y-auto">
            <div class="flex items-center justify-between pb-3 border-b border-slate-800">
              <div>
                <h3 class="font-display font-black text-white text-lg">Thông Số Môi Trường Thiết Bị</h3>
                <p class="text-xs text-slate-400 font-mono">Báo cáo từ {{ selectedFeedback.app_name }} v{{ selectedFeedback.app_version }}</p>
              </div>
              <button @click="selectedFeedback = null" class="text-slate-400 hover:text-white text-lg">✕</button>
            </div>

            <!-- Reason & Comment -->
            <div class="p-4 rounded-2xl bg-amber-500/10 border border-amber-500/30 space-y-1 text-xs">
              <div class="font-bold text-amber-300 font-mono">LÝ DO GỠ: {{ formatFeedbackReason(selectedFeedback.reason) }}</div>
              <div v-if="selectedFeedback.details" class="text-slate-200">"{{ selectedFeedback.details }}"</div>
              <div v-if="selectedFeedback.email" class="text-slate-400">Email: {{ selectedFeedback.email }}</div>
            </div>

            <!-- Telemetry Details Table -->
            <div class="border border-slate-800 rounded-2xl overflow-hidden text-xs font-mono">
              <div class="bg-slate-900/90 p-3 font-bold text-cyan-300 border-b border-slate-800">
                THÔNG SỐ PHẦN CỨNG & HỆ THỐNG
              </div>
              <div class="divide-y divide-slate-800/60 bg-slate-950/60">
                <div class="flex p-2.5 justify-between"><span class="text-slate-500">Trình Duyệt:</span><span class="text-white font-bold">{{ selectedFeedback.device_info?.browser }} {{ selectedFeedback.device_info?.browser_version }}</span></div>
                <div class="flex p-2.5 justify-between"><span class="text-slate-500">Hệ Điều Hành:</span><span class="text-white">{{ selectedFeedback.device_info?.os }} ({{ selectedFeedback.device_info?.platform }})</span></div>
                <div class="flex p-2.5 justify-between"><span class="text-slate-500">Độ Phân Giải Màn Hình:</span><span class="text-white">{{ selectedFeedback.device_info?.screen_resolution }} (Khả dụng: {{ selectedFeedback.device_info?.avail_resolution }})</span></div>
                <div class="flex p-2.5 justify-between"><span class="text-slate-500">Pixel Ratio / Độ Sâu Màu:</span><span class="text-white">{{ selectedFeedback.device_info?.pixel_ratio }}x • {{ selectedFeedback.device_info?.color_depth }}</span></div>
                <div class="flex p-2.5 justify-between"><span class="text-slate-500">Số Nhân CPU:</span><span class="text-cyan-300">{{ selectedFeedback.device_info?.cpu_cores ? selectedFeedback.device_info.cpu_cores + ' Cores' : 'Không xác định' }}</span></div>
                <div class="flex p-2.5 justify-between"><span class="text-slate-500">Dung Lượng RAM:</span><span class="text-cyan-300">{{ selectedFeedback.device_info?.ram_gb ? selectedFeedback.device_info.ram_gb + ' GB' : 'Không xác định' }}</span></div>
                <div class="flex p-2.5 justify-between"><span class="text-slate-500">Múi Giờ / Ngôn Ngữ:</span><span class="text-white">{{ selectedFeedback.device_info?.timezone }} • {{ selectedFeedback.device_info?.language }}</span></div>
                <div class="flex p-2.5 justify-between"><span class="text-slate-500">Loại Kết Nối:</span><span class="text-white">{{ selectedFeedback.device_info?.connection_type || 'Mặc định' }}</span></div>
                <div class="flex p-2.5 justify-between"><span class="text-slate-500">Hỗ Trợ Cảm Ứng:</span><span class="text-white">{{ selectedFeedback.device_info?.touch_support ? 'Có (Touch Device)' : 'Không (Desktop)' }}</span></div>
                <div class="p-2.5 space-y-1">
                  <div class="text-slate-500">User Agent Đầy Đủ:</div>
                  <div class="text-[10px] text-slate-400 break-all bg-black/40 p-2 rounded-lg">{{ selectedFeedback.device_info?.user_agent }}</div>
                </div>
              </div>
            </div>

            <div class="flex justify-end">
              <button 
                @click="selectedFeedback = null"
                class="px-5 py-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs font-mono font-bold"
              >
                Đóng
              </button>
            </div>
          </div>
        </div>
      </Teleport>

      <!-- =================================================================== -->
      <!-- MODAL: CREATE NEW OAUTH APP                                         -->
      <!-- =================================================================== -->
      <Teleport to="body">
        <div 
          v-if="showCreateModal" 
          class="fixed inset-0 z-50 bg-black/80 backdrop-blur-md flex items-center justify-center p-4"
          @click.self="showCreateModal = false"
        >
          <div class="w-full max-w-lg rounded-3xl border border-slate-800 bg-[#090d1a] p-6 sm:p-8 space-y-5 text-slate-100 shadow-2xl">
            <div class="flex items-center justify-between pb-3 border-b border-slate-800">
              <h3 class="font-display font-black text-white text-lg">Tạo App OAuth Mới</h3>
              <button @click="showCreateModal = false" class="text-slate-400 hover:text-white">✕</button>
            </div>

            <form @submit.prevent="handleCreateApp" class="space-y-4 text-xs font-mono">
              <!-- Preset Selector Dropdown -->
              <div>
                <label class="block text-slate-400 mb-1 font-bold">CHỌN GAME / APP CÓ SẴN (HOẶC NHẬP MỚI):</label>
                <select 
                  v-model="selectedPreset" 
                  @change="onPresetChange"
                  class="w-full px-3 py-2.5 rounded-xl bg-slate-900 border border-slate-700 focus:border-cyan-400 text-cyan-300 font-bold outline-none cursor-pointer"
                >
                  <option v-for="g in availableGames" :key="g.slug" :value="g.slug">
                    🎮 {{ g.title }} (slug: {{ g.slug }})
                  </option>
                  <option value="custom">✨ + Nhập Tên Ứng Dụng / Game Mới Tùy Chọn</option>
                </select>
              </div>

              <!-- App Name Input (The only required manual field when creating custom!) -->
              <div>
                <label class="block text-slate-400 mb-1 font-bold">TÊN ỨNG DỤNG / GAME:</label>
                <input 
                  type="text" 
                  v-model="newAppForm.name" 
                  @input="onNameInput"
                  required 
                  placeholder="Ví dụ: Zero Grid: Quantum Shift"
                  class="w-full px-3 py-2.5 rounded-xl bg-slate-900 border border-slate-700 focus:border-cyan-400 text-white font-bold outline-none"
                />
              </div>

              <!-- App Type Dropdown -->
              <div class="grid grid-cols-2 gap-3">
                <div>
                  <label class="block text-slate-400 mb-1 font-bold">LOẠI PHẦN MỀM:</label>
                  <select 
                    v-model="newAppForm.app_type"
                    @change="onTypeChange"
                    class="w-full px-3 py-2.5 rounded-xl bg-slate-900 border border-slate-700 focus:border-cyan-400 text-white outline-none cursor-pointer"
                  >
                    <option value="game">game (Trò chơi)</option>
                    <option value="app">app (Ứng dụng)</option>
                  </select>
                </div>
                <div>
                  <label class="block text-slate-400 mb-1 font-bold">LOGO ĐẠI DIỆN:</label>
                  <div class="flex items-center gap-2 p-1.5 rounded-xl bg-slate-900 border border-slate-700">
                    <img 
                      :src="newAppForm.logo_url || '/icons/Icon-512.png'" 
                      class="w-7 h-7 rounded-lg object-contain bg-black/60 shrink-0" 
                      @error="$event.target.src = '/icons/Icon-512.png'"
                    />
                    <span class="text-[10px] text-slate-400 truncate">
                      {{ newAppForm.logo_url ? 'Đã gán Logo' : 'Logo mặc định' }}
                    </span>
                  </div>
                </div>
              </div>

              <!-- Auto-Generated Parameters Summary Card -->
              <div class="p-3.5 rounded-2xl bg-slate-900/90 border border-slate-800 space-y-2">
                <div class="flex items-center justify-between text-[11px]">
                  <span class="text-slate-400 font-bold">THÔNG SỐ HỆ THỐNG TỰ ĐỘNG SINH:</span>
                  <span class="px-2 py-0.5 rounded bg-cyan-500/20 text-cyan-300 text-[10px] font-bold">✓ TỰ ĐỘNG SINH</span>
                </div>
                <div class="grid grid-cols-2 gap-2 text-[11px]">
                  <div>
                    <span class="text-slate-500">Viết tắt:</span>
                    <span class="text-cyan-400 font-bold ml-1">{{ newAppForm.app_abbr || 'app' }}</span>
                  </div>
                  <div>
                    <span class="text-slate-500">Mã Slug:</span>
                    <span class="text-cyan-400 font-bold ml-1">{{ newAppForm.game_slug || 'slug' }}</span>
                  </div>
                </div>
                <div class="text-[11px] truncate">
                  <span class="text-slate-500">Deep link:</span>
                  <span class="text-pink-400 font-bold ml-1">{{ newAppForm.redirect_uri || 'Chưa thiết lập' }}</span>
                </div>
              </div>

              <!-- Toggle Advanced Customization (Optional) -->
              <div>
                <button 
                  type="button" 
                  @click="showAdvancedFields = !showAdvancedFields"
                  class="text-[11px] text-slate-400 hover:text-cyan-400 font-bold flex items-center gap-1.5 transition-all"
                >
                  <span>{{ showAdvancedFields ? '▲ Ẩn thông số chi tiết' : '▼ ⚙️ Chỉnh sửa thông số chi tiết (Tùy chọn nâng cao)' }}</span>
                </button>
                
                <div v-if="showAdvancedFields" class="mt-2.5 p-3 rounded-2xl bg-black/50 border border-slate-800 space-y-3">
                  <div class="grid grid-cols-2 gap-3">
                    <div>
                      <label class="block text-slate-500 text-[10px] mb-1">VIẾT TẮT CHỮ ĐẦU:</label>
                      <input 
                        type="text" 
                        v-model="newAppForm.app_abbr" 
                        class="w-full px-2.5 py-2 rounded-xl bg-slate-900 border border-slate-700 text-white text-xs lowercase outline-none" 
                      />
                    </div>
                    <div>
                      <label class="block text-slate-500 text-[10px] mb-1">SLUG HỆ THỐNG:</label>
                      <input 
                        type="text" 
                        v-model="newAppForm.game_slug" 
                        class="w-full px-2.5 py-2 rounded-xl bg-slate-900 border border-slate-700 text-cyan-300 text-xs font-bold outline-none" 
                      />
                    </div>
                  </div>
                  <div>
                    <label class="block text-slate-500 text-[10px] mb-1">DEEP LINK CALLBACK URI:</label>
                    <input 
                      type="text" 
                      v-model="newAppForm.redirect_uri" 
                      class="w-full px-2.5 py-2 rounded-xl bg-slate-900 border border-slate-700 text-white text-xs outline-none" 
                    />
                  </div>
                  <div>
                    <label class="block text-slate-500 text-[10px] mb-1">LOGO URL:</label>
                    <input 
                      type="text" 
                      v-model="newAppForm.logo_url" 
                      class="w-full px-2.5 py-2 rounded-xl bg-slate-900 border border-slate-700 text-white text-xs outline-none" 
                    />
                  </div>
                </div>
              </div>

              <!-- 3 Legal Links Auto-Generated -->
              <div class="p-3 rounded-xl bg-emerald-500/10 border border-emerald-500/20 text-[11px] text-emerald-300 space-y-1">
                <div class="font-bold">✓ Tự động cấp 3 link pháp lý chuẩn domain:</div>
                <div class="truncate">• https://txastudio.click/privacy?game={{ newAppForm.game_slug || 'slug' }}</div>
                <div class="truncate">• https://txastudio.click/terms?game={{ newAppForm.game_slug || 'slug' }}</div>
                <div class="truncate">• https://txastudio.click/delete-account?game={{ newAppForm.game_slug || 'slug' }}</div>
              </div>

              <button 
                type="submit" 
                :disabled="isCreatingApp"
                class="w-full py-3 px-4 rounded-xl bg-gradient-to-r from-cyan-400 to-pink-500 text-slate-950 font-display font-black text-xs uppercase tracking-wider shadow-lg shadow-cyan-500/20 hover:scale-[1.02] active:scale-95 transition-all"
              >
                {{ isCreatingApp ? 'ĐANG KHỞI TẠO...' : 'TẠO MÃ OAUTH CLIENT CHO GAME' }}
              </button>
            </form>
          </div>
        </div>
      </Teleport>

      <!-- =================================================================== -->
      <!-- MODAL: VIEW FLUTTER SNIPPET                                         -->
      <!-- =================================================================== -->
      <Teleport to="body">
        <div 
          v-if="selectedAppSnippet" 
          class="fixed inset-0 z-50 bg-black/80 backdrop-blur-md flex items-center justify-center p-4"
          @click.self="selectedAppSnippet = null"
        >
          <div class="w-full max-w-xl rounded-3xl border border-slate-800 bg-[#090d1a] p-6 sm:p-8 space-y-4 text-slate-100 shadow-2xl">
            <div class="flex items-center justify-between pb-3 border-b border-slate-800">
              <h3 class="font-display font-black text-white text-base">
                {{ isEn ? 'Application Configuration Code' : 'Mã Cấu Hình Ứng Dụng / Game' }}
              </h3>
              <button @click="selectedAppSnippet = null" class="text-slate-400 hover:text-white">✕</button>
            </div>

            <p class="text-xs text-slate-300 font-mono">
              {{ isEn 
                ? 'Paste the following code into your project configuration file:' 
                : 'Dán đoạn mã sau vào file cấu hình trong dự án của bạn:' }}
            </p>

            <div class="relative p-4 rounded-2xl bg-black/80 border border-slate-800 font-mono text-xs">
              <button 
                @click="copy(generatedSnippetCode)" 
                class="absolute top-3 right-3 px-3 py-1 rounded-lg bg-cyan-500/20 hover:bg-cyan-500/30 text-cyan-300 font-bold"
              >
                1-Click Copy
              </button>
              <pre class="overflow-x-auto text-[11px] text-cyan-300 leading-relaxed"><code>{{ generatedSnippetCode }}</code></pre>
            </div>
          </div>
        </div>
      </Teleport>

      <!-- =================================================================== -->
      <!-- MODAL: MANUAL TDROP LICENSE CREATION                                -->
      <!-- =================================================================== -->
      <Teleport to="body">
        <div 
          v-if="showManualLicenseModal" 
          class="fixed inset-0 z-50 bg-black/80 backdrop-blur-md flex items-center justify-center p-4"
          @click.self="showManualLicenseModal = false"
        >
          <div class="w-full max-w-lg rounded-3xl border border-indigo-500/40 bg-[#090d1f] p-6 sm:p-8 space-y-5 text-slate-100 shadow-2xl">
            <div class="flex items-center justify-between pb-3 border-b border-slate-800">
              <div class="flex items-center gap-3">
                <span class="text-2xl">💧</span>
                <h3 class="font-display font-black text-white text-lg">Tạo Key Bản Quyền T-Drop Thủ Công</h3>
              </div>
              <button @click="showManualLicenseModal = false" class="text-slate-400 hover:text-white">✕</button>
            </div>

            <form @submit.prevent="handleCreateManualLicense" class="space-y-4 text-xs font-mono">
              <div>
                <label class="block text-slate-300 mb-1 font-bold">MÃ MÁY KHÁCH HÀNG (MACHINE ID / HARDWARE HASH): *</label>
                <input 
                  type="text" 
                  v-model="manualLicenseForm.hardware_id" 
                  required 
                  placeholder="Ví dụ: A8B9C1D2E3F4G5H6 hoặc hash máy"
                  class="w-full px-3 py-2.5 rounded-xl bg-slate-900 border border-slate-700 focus:border-cyan-400 text-cyan-300 font-bold outline-none"
                />
                <p class="text-[10px] text-slate-500 mt-1">Mã máy hiển thị trong màn hình Kích Hoạt của ứng dụng T-Drop Desktop.</p>
              </div>

              <div class="grid grid-cols-2 gap-3">
                <div>
                  <label class="block text-slate-300 mb-1 font-bold">GÓI BẢN QUYỀN:</label>
                  <select 
                    v-model="manualLicenseForm.role"
                    class="w-full px-3 py-2.5 rounded-xl bg-slate-900 border border-slate-700 focus:border-indigo-400 text-white font-bold outline-none cursor-pointer"
                  >
                    <option value="VIP">VIP (Hạn dùng 30 Ngày)</option>
                    <option value="PREMIUM">PREMIUM (Hạn dùng 60 Ngày)</option>
                  </select>
                </div>
                <div>
                  <label class="block text-slate-300 mb-1 font-bold">TÊN THIẾT BỊ / GHI CHÚ:</label>
                  <input 
                    type="text" 
                    v-model="manualLicenseForm.device_name" 
                    placeholder="VD: Windows PC, MacBook"
                    class="w-full px-3 py-2.5 rounded-xl bg-slate-900 border border-slate-700 focus:border-indigo-400 text-white outline-none"
                  />
                </div>
              </div>

              <div class="p-3 rounded-xl bg-indigo-500/10 border border-indigo-500/20 text-[11px] text-indigo-300 space-y-1">
                <div class="font-bold">✓ Quy tắc cấp phát tự động:</div>
                <div>• Format mã key: <span class="font-mono text-cyan-300">TDR_{HardwareHash}_{Random5}</span></div>
                <div>• Thời hạn tính từ thời điểm tạo key và lưu trực tiếp vào cơ sở dữ liệu Supabase.</div>
              </div>

              <div class="flex items-center gap-3 pt-2">
                <button 
                  type="button"
                  @click="showManualLicenseModal = false"
                  class="flex-1 py-3 px-4 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 font-bold"
                >
                  Hủy Bỏ
                </button>
                <button 
                  type="submit" 
                  :disabled="isTDropLoading"
                  class="flex-1 py-3 px-4 rounded-xl bg-gradient-to-r from-cyan-400 via-sky-500 to-indigo-500 text-slate-950 font-display font-black text-xs uppercase tracking-wider shadow-lg shadow-cyan-500/20 hover:scale-[1.02] active:scale-95 transition-all"
                >
                  {{ isTDropLoading ? 'Đang Khởi Tạo...' : 'Khởi Tạo Key Ngay' }}
                </button>
              </div>
            </form>
          </div>
        </div>
      </Teleport>

      <!-- =================================================================== -->
      <!-- MODAL: TDROP LICENSE SUCCESS NOTIFICATION & 1-CLICK EMAIL           -->
      <!-- =================================================================== -->
      <Teleport to="body">
        <div 
          v-if="createdLicenseModalData" 
          class="fixed inset-0 z-50 bg-black/85 backdrop-blur-md flex items-center justify-center p-4"
          @click.self="createdLicenseModalData = null"
        >
          <div class="w-full max-w-lg rounded-3xl border border-emerald-500/40 bg-[#070b18] p-6 sm:p-8 space-y-5 text-slate-100 shadow-2xl text-center">
            <div class="w-16 h-16 rounded-full bg-emerald-500/20 border border-emerald-500/40 flex items-center justify-center text-3xl mx-auto shadow-lg shadow-emerald-500/20">
              🎉
            </div>

            <div class="space-y-1">
              <h3 class="font-display font-black text-white text-xl">
                {{ createdLicenseModalData.title || 'Cấp Phát Bản Quyền Thành Công!' }}
              </h3>
              <p class="text-xs text-slate-400 font-mono">
                Mã bản quyền đã được kích hoạt trên hệ thống Cloud Supabase.
              </p>
            </div>

            <!-- Big Glowing License Key Box -->
            <div class="p-4 rounded-2xl bg-black/80 border-2 border-emerald-500/50 space-y-2">
              <div class="text-[10px] font-mono text-slate-400 uppercase tracking-widest font-bold">MÃ LICENSE KEY T-DROP:</div>
              <div class="text-xl sm:text-2xl font-mono font-black text-emerald-300 tracking-wider break-all select-all">
                {{ createdLicenseModalData.license_key }}
              </div>
              <button 
                @click="copy(createdLicenseModalData.license_key)"
                class="px-4 py-1.5 rounded-xl bg-emerald-500/20 hover:bg-emerald-500/30 text-emerald-300 text-xs font-mono font-bold transition-all inline-flex items-center gap-1.5"
              >
                <span>📋</span>
                <span>1-Click Sao Chép Key</span>
              </button>
            </div>

            <!-- Details Summary -->
            <div class="border border-slate-800 rounded-xl p-3 bg-slate-900/60 text-xs font-mono text-left space-y-1">
              <div v-if="createdLicenseModalData.order_code" class="flex justify-between">
                <span class="text-slate-500">Mã đơn:</span>
                <span class="text-white font-bold">{{ createdLicenseModalData.order_code }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-slate-500">Gói bản quyền:</span>
                <span class="text-cyan-400 font-bold">{{ createdLicenseModalData.role }} ({{ createdLicenseModalData.role === 'PREMIUM' ? '60 ngày' : '30 ngày' }})</span>
              </div>
              <div class="flex justify-between">
                <span class="text-slate-500">Mã máy (Machine ID):</span>
                <span class="text-slate-300 break-all">{{ createdLicenseModalData.machine_id }}</span>
              </div>
              <div v-if="createdLicenseModalData.email" class="flex justify-between">
                <span class="text-slate-500">Email khách hàng:</span>
                <span class="text-pink-400 font-bold">{{ createdLicenseModalData.email }}</span>
              </div>
            </div>

            <!-- Action Buttons -->
            <div class="space-y-2 pt-2">
              <button 
                v-if="createdLicenseModalData.email"
                @click="sendAutoEmail(createdLicenseModalData)"
                :disabled="sendingEmailOrderId === (createdLicenseModalData.order_code || createdLicenseModalData.license_key)"
                class="w-full py-3.5 px-4 rounded-xl bg-gradient-to-r from-emerald-400 via-teal-500 to-cyan-500 text-slate-950 font-display font-black text-xs uppercase tracking-wider shadow-lg shadow-emerald-500/30 hover:scale-[1.02] active:scale-95 transition-all flex items-center justify-center gap-2"
              >
                <span v-if="sendingEmailOrderId === (createdLicenseModalData.order_code || createdLicenseModalData.license_key)" class="animate-spin">⏳</span>
                <span v-else>🚀</span>
                <span>{{ sendingEmailOrderId === (createdLicenseModalData.order_code || createdLicenseModalData.license_key) ? 'ĐANG GỬI EMAIL TỰ ĐỘNG...' : 'GỬI EMAIL TỰ ĐỘNG CHO KHÁCH HÀNG' }}</span>
              </button>

              <button 
                v-if="createdLicenseModalData.email"
                @click="openMailtoClient(createdLicenseModalData)"
                class="w-full py-2.5 px-4 rounded-xl bg-slate-900 border border-slate-700 text-slate-400 hover:text-white text-xs font-mono font-bold transition-all flex items-center justify-center gap-2"
              >
                <span>📧</span>
                <span>Mở Email Thủ Công (Mailto Dự Phòng)</span>
              </button>

              <button 
                @click="createdLicenseModalData = null"
                class="w-full py-2.5 px-4 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs font-mono font-bold"
              >
                Đóng Cửa Sổ
              </button>
            </div>
          </div>
        </div>
      </Teleport>

      <!-- =================================================================== -->
      <!-- MODAL: MANUAL MYCAY DEVICE BAN                                      -->
      <!-- =================================================================== -->
      <Teleport to="body">
        <div 
          v-if="showMycayBanModal" 
          class="fixed inset-0 z-50 bg-black/80 backdrop-blur-md flex items-center justify-center p-4"
          @click.self="showMycayBanModal = false"
        >
          <div class="w-full max-w-md rounded-3xl border border-orange-500/40 bg-[#0d0707] p-6 sm:p-8 space-y-5 text-slate-100 shadow-2xl">
            <div class="flex items-center justify-between pb-3 border-b border-slate-800">
              <div class="flex items-center gap-2">
                <span class="text-xl">🚫</span>
                <div>
                  <h3 class="font-display font-black text-white text-lg">Khóa Ban Thiết Bị Game Mỳ Cay</h3>
                  <p class="text-xs text-orange-400 font-mono">Anti-Cheat Security Terminal</p>
                </div>
              </div>
              <button @click="showMycayBanModal = false" class="text-slate-400 hover:text-white">✕</button>
            </div>

            <form @submit.prevent="handleCreateManualMycayBan" class="space-y-4 text-xs font-mono">
              <div class="space-y-1.5">
                <label class="text-slate-400 font-bold block">MÃ THIẾT BỊ (DEVICE ID) *</label>
                <input 
                  type="text" 
                  v-model="mycayBanForm.device_id" 
                  placeholder="Ví dụ: dev_abc123 hoặc fingerprint ID"
                  required
                  class="w-full px-3.5 py-2.5 rounded-xl bg-black/60 border border-slate-700 text-white font-mono text-xs outline-none focus:border-orange-400"
                />
                <p class="text-[10px] text-slate-500 mt-1">Mã thiết bị từ log anti-cheat hoặc fingerprint của người chơi vi phạm.</p>
              </div>

              <div class="space-y-1.5">
                <label class="text-slate-400 font-bold block">LÝ DO KHÓA</label>
                <input 
                  type="text" 
                  v-model="mycayBanForm.reason" 
                  placeholder="devtools_violation, gian lận, can thiệp mã nguồn..."
                  class="w-full px-3.5 py-2.5 rounded-xl bg-black/60 border border-slate-700 text-white font-mono text-xs outline-none focus:border-orange-400"
                />
              </div>

              <div class="p-3 rounded-xl bg-red-950/40 border border-red-500/30 text-[11px] text-red-300 space-y-1">
                <div class="font-bold flex items-center gap-1">⚠️ CẢNH BÁO AN NINH:</div>
                <div>Thiết bị này sẽ bị khóa ban vĩnh viễn (locked_until 9999-12-31). Người dùng trên thiết bị này sẽ bị chặn truy cập game cho đến khi Admin mở khóa thủ công.</div>
              </div>

              <div class="flex items-center justify-end gap-3 pt-3 border-t border-slate-800">
                <button 
                  type="button"
                  @click="showMycayBanModal = false"
                  class="px-4 py-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 font-bold text-xs"
                >
                  Hủy Bỏ
                </button>
                <button 
                  type="submit"
                  :disabled="isMycayLoading"
                  class="px-5 py-2.5 rounded-xl bg-gradient-to-r from-orange-500 via-rose-500 to-red-600 text-white font-display font-black text-xs uppercase tracking-wider shadow-lg shadow-rose-500/30 hover:scale-[1.02] active:scale-95 transition-all"
                >
                  {{ isMycayLoading ? 'Đang Xử Lý...' : 'Xác Nhận Khóa Vĩnh Viễn' }}
                </button>
              </div>
            </form>
          </div>
        </div>
      </Teleport>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, inject, nextTick, watch } from 'vue';
import { useRouter } from 'vue-router';
import { 
  adminListApps, 
  adminCreateApp, 
  adminDeleteApp,
  adminListDeletions, 
  adminUpdateDeletion, 
  getSystemConfigs, 
  updateSystemConfig,
  formatSecondsToHumanLabel,
  getCurrentWebUser,
  clearCurrentWebUser,
  promoteToAdmin,
  getAllGames,
  adminListFeedbacks,
  adminListTDropOrders,
  adminApproveTDropOrder,
  adminListTDropLicenses,
  adminCreateTDropLicense,
  adminRevokeTDropLicense,
  sendAutomaticLicenseEmail,
  adminGetMycayAnalytics,
  adminListMycaySecurityLocks,
  adminUnlockMycayDevice,
  adminBanMycayDevicePermanent,
  adminGetMycayAdminStats,
  adminListMycayVisitLogs,
  adminDeleteMycayVisitLog,
  adminClearAllMycayVisitLogs,
  subscribeToMycayRealtime
} from '../services/supabase.js';
import { sound } from '../services/sound.js';
import { loadChartJs } from '../services/chartLoader.js';

const router = useRouter();
const currentLang = inject('currentLang', ref('vi'));
const isEn = computed(() => currentLang.value === 'en');

const currentUser = ref(getCurrentWebUser());
const isAdmin = computed(() => currentUser.value && currentUser.value.role === 'admin');

const activeTab = ref('apps');
const appList = ref([]);
const deletionList = ref([]);
const feedbackList = ref([]);
const selectedFeedback = ref(null);
const systemConfigs = ref({});
const availableGames = ref([]);

// T-Drop Manager State (Bỏ mã PIN hoàn toàn, bảo mật trực tiếp theo quyền Admin của tài khoản)
const tdropActiveSubTab = ref('orders');
const tdropOrders = ref([]);
const tdropLicenses = ref([]);
const tdropOrderFilter = ref('all');
const tdropLicenseSearch = ref('');
const tdropLicenseRoleFilter = ref('all');
const isTDropLoading = ref(false);
const sendingEmailOrderId = ref(null);
const showManualLicenseModal = ref(false);
const manualLicenseForm = ref({
  hardware_id: '',
  role: 'VIP',
  device_name: ''
});
const createdLicenseModalData = ref(null);

const tdropPendingOrdersCount = computed(() => tdropOrders.value.filter(o => o.status === 'pending').length);
const tdropApprovedOrdersCount = computed(() => tdropOrders.value.filter(o => o.status === 'approved').length);
const tdropTotalRevenue = computed(() => {
  return tdropOrders.value
    .filter(o => o.status === 'approved')
    .reduce((sum, o) => sum + (Number(o.amount) || (o.role === 'PREMIUM' ? 49000 : 29000)), 0);
});
const tdropActiveLicensesCount = computed(() => tdropLicenses.value.filter(l => l.status === 'active').length);

const filteredTDropOrders = computed(() => {
  if (tdropOrderFilter.value === 'all') return tdropOrders.value;
  return tdropOrders.value.filter(o => o.status === tdropOrderFilter.value);
});

const filteredTDropLicenses = computed(() => {
  let list = tdropLicenses.value;
  if (tdropLicenseRoleFilter.value !== 'all') {
    list = list.filter(l => l.role === tdropLicenseRoleFilter.value);
  }
  if (tdropLicenseSearch.value.trim()) {
    const q = tdropLicenseSearch.value.trim().toLowerCase();
    list = list.filter(l => 
      (l.key && l.key.toLowerCase().includes(q)) ||
      (l.hardware_id && l.hardware_id.toLowerCase().includes(q)) ||
      (l.device_name && l.device_name.toLowerCase().includes(q)) ||
      (l.user_name && l.user_name.toLowerCase().includes(q))
    );
  }
  return list;
});

// Game Mỳ Cay Manager State (Security Locks & Views Analytics)
const mycayAnalytics = ref(null);
const mycayLocks = ref([]);
const mycayStats = ref(null);
const mycayVisitLogs = ref([]);
const mycaySubTab = ref('overview'); // 'overview', 'locks', 'logs'
const showMycayCharts = ref(localStorage.getItem('mycay_show_charts') !== 'false');
const isMycayLoading = ref(false);
const mycaySearch = ref('');
const mycayFilter = ref('all'); // 'all', 'permanent', 'temporary', 'unlocked'
const showMycayBanModal = ref(false);
const mycayRealtimeStatus = ref('connecting'); // 'connecting', 'connected', 'error', 'reconnecting'
const lastRealtimeEventAt = ref(null);
let mycayRealtimeCleanup = null;
let mycayPollingInterval = null;
const mycayBanForm = ref({
  device_id: '',
  reason: 'devtools_violation'
});

// Canvas refs for Chart.js
const dailyTrendCanvas = ref(null);
const devicesCanvas = ref(null);
const browsersCanvas = ref(null);

let dailyTrendChart = null;
let devicesChart = null;
let browsersChart = null;

const mycayViews = computed(() => {
  return Number(mycayStats.value?.total_views) || Number(mycayAnalytics.value?.total_views) || 0;
});

const mycayPermanentBansCount = computed(() => {
  return mycayLocks.value.filter(l => 
    l.is_permanent_ban === true || 
    (l.locked_until && new Date(l.locked_until).getFullYear() >= 9000)
  ).length;
});

const mycayTemporaryLocksCount = computed(() => {
  const now = new Date();
  return mycayLocks.value.filter(l => {
    if (l.is_permanent_ban) return false;
    if (!l.locked_until) return false;
    const lockDate = new Date(l.locked_until);
    return lockDate.getFullYear() < 9000 && lockDate > now;
  }).length;
});

const filteredMycayLocks = computed(() => {
  const now = new Date();
  let list = mycayLocks.value;
  
  if (mycayFilter.value === 'permanent') {
    list = list.filter(l => l.is_permanent_ban || (l.locked_until && new Date(l.locked_until).getFullYear() >= 9000));
  } else if (mycayFilter.value === 'temporary') {
    list = list.filter(l => !l.is_permanent_ban && l.locked_until && new Date(l.locked_until) > now && new Date(l.locked_until).getFullYear() < 9000);
  } else if (mycayFilter.value === 'unlocked') {
    list = list.filter(l => !l.is_permanent_ban && (!l.locked_until || new Date(l.locked_until) <= now));
  }
  
  if (mycaySearch.value.trim()) {
    const q = mycaySearch.value.trim().toLowerCase();
    list = list.filter(l => 
      (l.device_id && l.device_id.toLowerCase().includes(q)) ||
      (l.reason && l.reason.toLowerCase().includes(q))
    );
  }
  return list;
});

const expirySecondsInput = ref('300');
const previewExpiryLabel = computed(() => formatSecondsToHumanLabel(expirySecondsInput.value, isEn.value));
const promoteEmailInput = ref('');
const promoteNotice = ref('');
const settingsNotice = ref('');

const showCreateModal = ref(false);
const isCreatingApp = ref(false);
const showAdvancedFields = ref(false);
const selectedPreset = ref('quantumshift');

const newAppForm = ref({
  name: 'Zero Grid: Quantum Shift',
  game_slug: 'quantumshift',
  app_type: 'game',
  app_abbr: 'zgqs',
  redirect_uri: 'txa.zerogrid.quantumshift://oauth/callback',
  logo_url: 'https://txastudio.click/icons/Icon-512.png'
});

function computeAbbr(str) {
  if (!str) return 'app';
  const clean = str.replace(/[^a-zA-Z0-9\s]/g, ' ').trim();
  const words = clean.split(/\s+/).filter(Boolean);
  if (words.length === 1) {
    return words[0].substring(0, 4).toLowerCase();
  }
  return words.map(w => w[0]).join('').toLowerCase();
}

function computeSlug(str) {
  if (!str) return 'app';
  return str
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '') || 'app';
}

function applyGamePreset(game) {
  if (!game) return;
  newAppForm.value.name = game.title;
  newAppForm.value.app_type = 'game';
  newAppForm.value.game_slug = game.slug;
  newAppForm.value.app_abbr = computeAbbr(game.title);
  newAppForm.value.redirect_uri = `${game.package_id || ('txa.' + game.slug)}://oauth/callback`;
  newAppForm.value.logo_url = 'https://txastudio.click/icons/Icon-512.png';
}

function onPresetChange() {
  sound.playClick();
  if (selectedPreset.value === 'custom') {
    newAppForm.value.name = '';
    newAppForm.value.app_type = 'game';
    newAppForm.value.app_abbr = 'app';
    newAppForm.value.game_slug = 'app';
    newAppForm.value.redirect_uri = 'txa.app://oauth/callback';
    newAppForm.value.logo_url = 'https://txastudio.click/icons/Icon-512.png';
  } else {
    const found = availableGames.value.find(g => g.slug === selectedPreset.value);
    if (found) applyGamePreset(found);
  }
}

function onNameInput() {
  if (selectedPreset.value === 'custom') {
    const val = newAppForm.value.name;
    const abbr = computeAbbr(val);
    const slug = computeSlug(val);
    newAppForm.value.app_abbr = abbr;
    newAppForm.value.game_slug = slug;
    newAppForm.value.redirect_uri = `txa.${abbr}.${slug}://oauth/callback`;
  }
}

function onTypeChange() {
  if (selectedPreset.value === 'custom') {
    onNameInput();
  }
}

const selectedAppSnippet = ref(null);

const generatedSnippetCode = computed(() => {
  if (!selectedAppSnippet.value) return '';
  const app = selectedAppSnippet.value;
  return `class TxaConfig {
  static const String appType = '${app.app_type}';
  static const String appAbbr = '${app.app_abbr}';
  static const String gameId = '${app.game_slug}';
  
  // Client ID sinh chuẩn từ Admin:
  static const String clientId = '${app.client_id}';
  
  // Deep Link Callback & Cổng OAuth:
  static const String redirectUri = '${app.redirect_uris?.[0] || 'txa.zerogrid.quantumshift://oauth/callback'}';
  static const String authEndpoint = 'https://txastudio.click/oauth/authorize';
  static const int sessionTimeoutMinutes = 5;
}`;
});

function adminLogout() {
  sound.playClick();
  clearCurrentWebUser();
  currentUser.value = null;
  router.push('/login?redirect=/admin');
}

function switchAdminAccount() {
  sound.playClick();
  clearCurrentWebUser();
  currentUser.value = null;
  router.push('/login?redirect=/admin');
}

async function handlePromoteUser() {
  const email = promoteEmailInput.value.trim();
  if (!email) return;
  sound.playClick();
  try {
    const res = await promoteToAdmin(email);
    if (res?.success) {
      promoteNotice.value = `✓ Đã thăng cấp ${email} thành Admin thành công!`;
      promoteEmailInput.value = '';
      sound.playSuccess();
    } else {
      promoteNotice.value = `⚠️ ${res?.error || 'Lỗi thăng cấp'}`;
    }
  } catch (e) {
    promoteNotice.value = `⚠️ ${e.message}`;
  }
  setTimeout(() => { promoteNotice.value = ''; }, 4000);
}

async function loadDashboardData() {
  try {
    const [apps, deletions, configs, games, feedbacks] = await Promise.all([
      adminListApps(),
      adminListDeletions(),
      getSystemConfigs(),
      getAllGames(),
      adminListFeedbacks()
    ]);
    appList.value = apps || [];
    deletionList.value = deletions || [];
    systemConfigs.value = configs || {};
    availableGames.value = games || [];
    feedbackList.value = feedbacks?.items || [];
    expirySecondsInput.value = configs['oauth_expiry_seconds'] || (configs['oauth_expiry_minutes'] ? String(parseInt(configs['oauth_expiry_minutes'], 10) * 60) : '300');

    // Auto initialize preset if available
    if (availableGames.value.length > 0 && selectedPreset.value !== 'custom') {
      const found = availableGames.value.find(g => g.slug === selectedPreset.value) || availableGames.value[0];
      selectedPreset.value = found.slug;
      applyGamePreset(found);
    }

    // Load T-Drop Data
    await loadTDropData();

    // Load Game Mỳ Cay Data
    await loadMycayData();
  } catch (e) {
    console.error('Failed to load admin data', e);
  }
}

async function loadMycayData(silent = false) {
  if (!silent) isMycayLoading.value = true;
  try {
    const [analytics, locks, stats, visitLogs] = await Promise.all([
      adminGetMycayAnalytics(),
      adminListMycaySecurityLocks(),
      adminGetMycayAdminStats(),
      adminListMycayVisitLogs(50)
    ]);
    mycayAnalytics.value = analytics;
    mycayLocks.value = locks || [];
    mycayStats.value = stats || null;
    mycayVisitLogs.value = visitLogs || [];
    if (showMycayCharts.value && mycaySubTab.value === 'overview' && activeTab.value === 'mycay') {
      nextTick(() => renderMycayCharts());
    }
  } catch (err) {
    console.error('Failed to load Game Mỳ Cay data:', err);
  } finally {
    if (!silent) isMycayLoading.value = false;
  }
}

function startMycayRealtime() {
  stopMycayRealtime();
  mycayRealtimeStatus.value = 'connecting';

  // 1. Supabase Phoenix Channel over WebSocket
  mycayRealtimeCleanup = subscribeToMycayRealtime((event) => {
    if (event.type === 'STATUS') {
      mycayRealtimeStatus.value = event.status;
      return;
    }
    if (event.type === 'CHANGE') {
      lastRealtimeEventAt.value = new Date();
      mycayRealtimeStatus.value = 'connected';

      const { table, eventType, record, old_record } = event;

      if (table === 'mycay_visit_logs') {
        if (eventType === 'INSERT' && record) {
          // Real-time prepend visit log
          if (!mycayVisitLogs.value.some(l => l.id === record.id)) {
            mycayVisitLogs.value.unshift(record);
            if (mycayVisitLogs.value.length > 50) mycayVisitLogs.value.pop();
          }
          if (mycayAnalytics.value) {
            mycayAnalytics.value.total_views = (Number(mycayAnalytics.value.total_views) || 0) + 1;
          }
          if (mycayStats.value) {
            mycayStats.value.total_views = (Number(mycayStats.value.total_views) || 0) + 1;
          }
          if (showMycayCharts.value && mycaySubTab.value === 'overview' && activeTab.value === 'mycay') {
            nextTick(() => renderMycayCharts());
          }
        } else if (eventType === 'DELETE' && old_record) {
          mycayVisitLogs.value = mycayVisitLogs.value.filter(l => l.id !== old_record.id);
        } else {
          loadMycayData(true);
        }
      } else if (table === 'mycay_security_locks') {
        loadMycayData(true);
      } else if (table === 'mycay_analytics') {
        if (record?.total_views) {
          if (mycayAnalytics.value) mycayAnalytics.value.total_views = record.total_views;
          if (mycayStats.value) mycayStats.value.total_views = record.total_views;
        }
      }
    }
  });

  // 2. Continuous real-time sync poller fallback (every 4s)
  mycayPollingInterval = setInterval(() => {
    if (activeTab.value === 'mycay' && !isMycayLoading.value) {
      loadMycayData(true);
    }
  }, 4000);
}

function stopMycayRealtime() {
  if (mycayRealtimeCleanup) {
    try { mycayRealtimeCleanup(); } catch {}
    mycayRealtimeCleanup = null;
  }
  if (mycayPollingInterval) {
    clearInterval(mycayPollingInterval);
    mycayPollingInterval = null;
  }
}

function toggleMycayCharts() {
  sound.playClick();
  showMycayCharts.value = !showMycayCharts.value;
  try {
    localStorage.setItem('mycay_show_charts', String(showMycayCharts.value));
  } catch {}
  if (showMycayCharts.value) {
    nextTick(() => {
      renderMycayCharts();
    });
  } else {
    destroyMycayCharts();
  }
}

function destroyMycayCharts() {
  if (dailyTrendChart) {
    dailyTrendChart.destroy();
    dailyTrendChart = null;
  }
  if (devicesChart) {
    devicesChart.destroy();
    devicesChart = null;
  }
  if (browsersChart) {
    browsersChart.destroy();
    browsersChart = null;
  }
}

async function renderMycayCharts() {
  if (!showMycayCharts.value || mycaySubTab.value !== 'overview' || activeTab.value !== 'mycay') return;
  try {
    const Chart = await loadChartJs();
    if (!Chart) return;

    destroyMycayCharts();

    // 1. Daily Trend Line Chart
    if (dailyTrendCanvas.value) {
      const trendData = mycayStats.value?.daily_trend || [];
      const labels = trendData.length > 0 ? trendData.map(d => d.date) : ['Hôm nay'];
      const counts = trendData.length > 0 ? trendData.map(d => Number(d.visits) || 0) : [mycayViews.value || 0];

      dailyTrendChart = new Chart(dailyTrendCanvas.value, {
        type: 'line',
        data: {
          labels,
          datasets: [{
            label: 'Lượt Truy Cập / Chơi',
            data: counts,
            borderColor: '#FF5722',
            backgroundColor: 'rgba(255, 87, 34, 0.15)',
            borderWidth: 2.5,
            fill: true,
            tension: 0.35,
            pointBackgroundColor: '#FF9800',
            pointBorderColor: '#fff',
            pointRadius: 4,
            pointHoverRadius: 6
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: { display: false },
            tooltip: {
              backgroundColor: '#0f172a',
              titleColor: '#FF9800',
              bodyColor: '#fff',
              borderColor: '#FF5722',
              borderWidth: 1,
              padding: 10,
              displayColors: false
            }
          },
          scales: {
            x: {
              grid: { color: 'rgba(255, 255, 255, 0.05)' },
              ticks: { color: '#94a3b8', font: { family: 'monospace', size: 10 } }
            },
            y: {
              beginAtZero: true,
              grid: { color: 'rgba(255, 255, 255, 0.05)' },
              ticks: { color: '#94a3b8', font: { family: 'monospace', size: 10 }, stepSize: 1 }
            }
          }
        }
      });
    }

    // 2. Devices Doughnut Chart
    if (devicesCanvas.value) {
      const devices = mycayStats.value?.devices || [];
      const labels = devices.length > 0 ? devices.map(d => d.label) : ['Mobile', 'Desktop'];
      const counts = devices.length > 0 ? devices.map(d => Number(d.count) || 0) : [1, 0];

      devicesChart = new Chart(devicesCanvas.value, {
        type: 'doughnut',
        data: {
          labels,
          datasets: [{
            data: counts,
            backgroundColor: ['#FF5722', '#00F5FF', '#A855F7', '#10B981', '#F59E0B'],
            borderColor: '#0d0707',
            borderWidth: 2
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          cutout: '70%',
          plugins: {
            legend: {
              position: 'bottom',
              labels: { color: '#cbd5e1', font: { family: 'monospace', size: 11 }, boxWidth: 12, padding: 12 }
            }
          }
        }
      });
    }

    // 3. Browsers Bar Chart
    if (browsersCanvas.value) {
      const browsers = mycayStats.value?.browsers || [];
      const labels = browsers.length > 0 ? browsers.map(b => b.label) : ['Google Chrome'];
      const counts = browsers.length > 0 ? browsers.map(b => Number(b.count) || 0) : [1];

      browsersChart = new Chart(browsersCanvas.value, {
        type: 'bar',
        data: {
          labels,
          datasets: [{
            label: 'Lượt dùng',
            data: counts,
            backgroundColor: ['#3B82F6', '#EC4899', '#10B981', '#F59E0B', '#8B5CF6'],
            borderRadius: 6
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: { display: false }
          },
          scales: {
            x: {
              grid: { display: false },
              ticks: { color: '#94a3b8', font: { family: 'monospace', size: 10 } }
            },
            y: {
              beginAtZero: true,
              grid: { color: 'rgba(255, 255, 255, 0.05)' },
              ticks: { color: '#94a3b8', font: { family: 'monospace', size: 10 }, stepSize: 1 }
            }
          }
        }
      });
    }
  } catch (e) {
    console.error('Error rendering MyCay charts:', e);
  }
}

watch([mycaySubTab, activeTab], ([newSub, newTab]) => {
  if (newTab === 'mycay') {
    startMycayRealtime();
    if (newSub === 'overview' && showMycayCharts.value) {
      nextTick(() => renderMycayCharts());
    } else {
      destroyMycayCharts();
    }
  } else {
    stopMycayRealtime();
    destroyMycayCharts();
  }
});

async function handleUnlockMycayDevice(deviceId) {
  if (!confirm(`Bạn có chắc chắn muốn MỞ KHÓA (Unban) cho thiết bị: "${deviceId}" không?`)) return;
  sound.playClick();
  isMycayLoading.value = true;
  try {
    const res = await adminUnlockMycayDevice(deviceId);
    if (res?.success) {
      sound.playSuccess();
      alert(`Đã mở khóa thiết bị "${deviceId}" thành công!`);
      await loadMycayData();
    } else {
      alert(`Lỗi mở khóa: ${res?.message || 'Thao tác không thành công'}`);
    }
  } catch (err) {
    alert(`Lỗi kết nối khi mở khóa: ${err.message}`);
  } finally {
    isMycayLoading.value = false;
  }
}

async function handleBanMycayDevice(deviceId) {
  if (!confirm(`CẢNH BÁO: Bạn có chắc chắn muốn KHÓA BAN VĨNH VIỄN thiết bị "${deviceId}" không? Thiết bị này sẽ không thể tiếp tục chơi game Mỳ Cay!`)) return;
  sound.playClick();
  isMycayLoading.value = true;
  try {
    const res = await adminBanMycayDevicePermanent(deviceId);
    if (res?.success) {
      sound.playSuccess();
      alert(`Đã khóa BAN VĨNH VIỄN thiết bị "${deviceId}" thành công!`);
      await loadMycayData();
    } else {
      alert(`Lỗi khóa thiết bị: ${res?.message || 'Không thành công'}`);
    }
  } catch (err) {
    alert(`Lỗi kết nối khi khóa thiết bị: ${err.message}`);
  } finally {
    isMycayLoading.value = false;
  }
}

async function handleCreateManualMycayBan() {
  const devId = mycayBanForm.value.device_id?.trim();
  if (!devId) {
    alert('Vui lòng nhập Device ID cần khóa!');
    return;
  }
  sound.playClick();
  isMycayLoading.value = true;
  try {
    const res = await adminBanMycayDevicePermanent(devId);
    if (res?.success) {
      sound.playSuccess();
      alert(`Đã khóa ban vĩnh viễn thiết bị "${devId}" thành công!`);
      showMycayBanModal.value = false;
      mycayBanForm.value.device_id = '';
      await loadMycayData();
    } else {
      alert(`Lỗi: ${res?.message || 'Không thể khóa'}`);
    }
  } catch (err) {
    alert(`Lỗi: ${err.message}`);
  } finally {
    isMycayLoading.value = false;
  }
}

async function handleDeleteMycayVisitLog(logId) {
  if (!confirm(`Bạn có chắc chắn muốn xóa bản ghi nhật ký này (ID: #${logId}) không?`)) return;
  sound.playClick();
  isMycayLoading.value = true;
  try {
    const res = await adminDeleteMycayVisitLog(logId);
    if (res?.success) {
      sound.playSuccess();
      mycayVisitLogs.value = mycayVisitLogs.value.filter(l => l.id !== logId);
    } else {
      alert(`Không thể xóa nhật ký: ${res?.error || 'Lỗi không xác định'}`);
    }
  } catch (err) {
    alert(`Lỗi kết nối khi xóa: ${err.message}`);
  } finally {
    isMycayLoading.value = false;
  }
}

async function handleClearAllMycayVisitLogs() {
  if (mycayVisitLogs.value.length === 0) return;
  if (!confirm(`CẢNH BÁO: Bạn có chắc chắn muốn XÓA TOÀN BỘ ${mycayVisitLogs.value.length} bản ghi nhật ký truy cập không? Dữ liệu đã xóa không thể khôi phục!`)) return;
  sound.playClick();
  isMycayLoading.value = true;
  try {
    const res = await adminClearAllMycayVisitLogs();
    if (res?.success) {
      sound.playSuccess();
      mycayVisitLogs.value = [];
      alert('Đã xóa toàn bộ nhật ký truy cập thành công!');
      await loadMycayData();
    } else {
      alert(`Không thể xóa toàn bộ nhật ký: ${res?.error || 'Lỗi không xác định'}`);
    }
  } catch (err) {
    alert(`Lỗi kết nối khi xóa: ${err.message}`);
  } finally {
    isMycayLoading.value = false;
  }
}

let tdropSearchTimer = null;
function debounceTDropSearch() {
  clearTimeout(tdropSearchTimer);
  tdropSearchTimer = setTimeout(() => {
    loadTDropData();
  }, 400);
}

async function loadTDropData() {
  isTDropLoading.value = true;
  try {
    const [ordersRes, licensesRes] = await Promise.all([
      adminListTDropOrders(tdropOrderFilter.value),
      adminListTDropLicenses(tdropLicenseSearch.value, tdropLicenseRoleFilter.value)
    ]);
    if (ordersRes?.ok) {
      tdropOrders.value = ordersRes.orders || [];
    }
    if (licensesRes?.ok) {
      tdropLicenses.value = licensesRes.licenses || [];
    }
  } catch (err) {
    console.error('Failed to load T-Drop data:', err);
  } finally {
    isTDropLoading.value = false;
  }
}

async function handleApproveTDropOrder(order) {
  if (!confirm(`Xác nhận duyệt đơn hàng "${order.order_code}" cho thiết bị "${order.machine_id}"?`)) return;
  sound.playClick();
  isTDropLoading.value = true;
  try {
    const res = await adminApproveTDropOrder(order.order_code);
    if (res?.ok) {
      sound.playSuccess();
      const approvedData = {
        title: 'Duyệt Đơn & Cấp Key Thành Công!',
        order_code: order.order_code,
        license_key: res.license_key,
        role: res.role || order.role,
        email: res.email || order.email,
        machine_id: res.machine_id || order.machine_id
      };
      createdLicenseModalData.value = approvedData;
      await loadTDropData();

      // TỰ ĐỘNG GỬI EMAIL NGAY KHI DUYỆT ĐƠN!
      if (approvedData.email) {
        sendAutoEmail(approvedData);
      }
    } else {
      alert('Không thể duyệt đơn: ' + (res?.message || 'Lỗi không xác định'));
    }
  } catch (err) {
    alert('Lỗi duyệt đơn: ' + err.message);
  } finally {
    isTDropLoading.value = false;
  }
}

async function sendAutoEmail(order) {
  if (!order?.email || !order?.license_key) {
    alert('Đơn hàng chưa có email hoặc mã key!');
    return;
  }
  sound.playClick();
  const targetId = order.order_code || order.license_key;
  sendingEmailOrderId.value = targetId;
  try {
    const res = await sendAutomaticLicenseEmail({
      email: order.email,
      orderCode: order.order_code,
      licenseKey: order.license_key,
      role: order.role,
      machineId: order.machine_id
    });

    if (res?.success) {
      sound.playSuccess();
      alert(`✓ ĐÃ GỬI EMAIL TỰ ĐỘNG THÀNH CÔNG!\n\nĐã gửi thư kích hoạt kèm mã bản quyền ${order.license_key} tới địa chỉ "${order.email}".`);
    } else if (res?.not_configured) {
      const useMailto = confirm(`Hệ thống chưa tìm thấy RESEND_API_KEY hoặc BREVO_API_KEY trên Vercel để gửi tự động.\n\nBạn có muốn mở ứng dụng email (mailto) để gửi thủ công ngay bây giờ không?`);
      if (useMailto) {
        openMailtoClient(order);
      }
    } else {
      alert(`Lỗi gửi email tự động: ${res?.error || 'Không gửi được'}\nĐang mở mailto dự phòng...`);
      openMailtoClient(order);
    }
  } catch (err) {
    alert(`Lỗi gửi email: ${err.message}`);
    openMailtoClient(order);
  } finally {
    sendingEmailOrderId.value = null;
  }
}

function openMailtoClient(order) {
  sound.playClick();
  const subject = `[TXA Studio - T-Drop] Kích Hoạt Bản Quyền ${order.role || 'VIP'} - Mã Key Của Bạn`;
  const body = `Xin chào bạn,

Cảm ơn bạn đã tin tưởng và ủng hộ phần mềm T-Drop (AI Clipboard & Smart OCR Desktop App) của TXA Studio!

Đơn hàng VietQR của bạn (${order.order_code || 'T-Drop Order'}) đã được kiểm tra và duyệt thành công.

Dưới đây là thông tin bản quyền của bạn:
- Gói bản quyền: ${order.role} (${order.role === 'PREMIUM' ? '60 ngày' : '30 ngày'})
- Mã máy (Hardware ID): ${order.machine_id}
- MÃ BẢN QUYỀN (LICENSE KEY): ${order.license_key}

HƯỚNG DẪN KÍCH HOẠT:
1. Mở ứng dụng T-Drop trên máy tính của bạn.
2. Mở Cài Đặt (Settings) -> Kích Hoạt Bản Quyền (License Activation).
3. Dán mã key ở trên vào ô nhập rồi bấm "Kích Hoạt".

Nếu bạn cần hỗ trợ thêm, vui lòng phản hồi lại email này. Chúc bạn có trải nghiệm làm việc năng suất tuyệt vời cùng T-Drop!

Trân trọng,
TXA Studio Team
Website: https://txastudio.click
Support: txasoftdev@gmail.com`;

  const mailtoUrl = `mailto:${order.email}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;
  window.open(mailtoUrl, '_blank');
}

async function handleRevokeTDropLicense(license) {
  if (!confirm(`Bạn có chắc chắn muốn THU HỒI mã bản quyền "${license.key}"? Người dùng sẽ không thể sử dụng gói ${license.role} được nữa.`)) return;
  sound.playClick();
  isTDropLoading.value = true;
  try {
    const res = await adminRevokeTDropLicense(license.key);
    if (res?.ok) {
      sound.playSuccess();
      await loadTDropData();
    } else {
      alert('Không thể thu hồi: ' + (res?.message || 'Lỗi'));
    }
  } catch (err) {
    alert('Lỗi thu hồi key: ' + err.message);
  } finally {
    isTDropLoading.value = false;
  }
}

async function handleCreateManualLicense() {
  if (!manualLicenseForm.value.hardware_id) {
    alert('Vui lòng nhập Machine ID / Hardware ID của khách!');
    return;
  }
  sound.playClick();
  isTDropLoading.value = true;
  try {
    const res = await adminCreateTDropLicense(
      manualLicenseForm.value.hardware_id,
      manualLicenseForm.value.role,
      manualLicenseForm.value.device_name
    );
    if (res?.ok) {
      sound.playSuccess();
      showManualLicenseModal.value = false;
      createdLicenseModalData.value = {
        title: 'Tạo Mã Bản Quyền Thủ Công Thành Công!',
        license_key: res.license_key || res.key,
        role: res.role,
        machine_id: res.hardware_id,
        device_name: res.device_name
      };
      manualLicenseForm.value = { hardware_id: '', role: 'VIP', device_name: '' };
      await loadTDropData();
    } else {
      alert('Không thể tạo key: ' + (res?.message || 'Lỗi'));
    }
  } catch (err) {
    alert('Lỗi tạo key: ' + err.message);
  } finally {
    isTDropLoading.value = false;
  }
}

function calculateRemainingDays(expiresAt) {
  if (!expiresAt) return 'Vĩnh viễn / Chưa kích hoạt';
  const diffMs = new Date(expiresAt).getTime() - Date.now();
  if (diffMs <= 0) return 'Đã hết hạn';
  const days = Math.ceil(diffMs / (1000 * 60 * 60 * 24));
  return `Còn ${days} ngày`;
}

async function loadFeedbacks() {
  sound.playClick();
  const res = await adminListFeedbacks();
  feedbackList.value = res?.items || [];
  sound.playSuccess();
}

function formatFeedbackReason(reason) {
  const map = {
    broken_site: 'Vỡ trang / Lỗi video',
    ads_not_blocked: 'Không chặn được quảng cáo',
    slow_performance: 'Làm chậm / Lag web',
    hard_to_use: 'Giao diện khó dùng',
    switched_competitor: 'Đổi sang tiện ích khác',
    temporary_use: 'Chỉ dùng tạm thời',
    other: 'Lý do khác'
  };
  return map[reason] || reason || 'Không xác định';
}

async function loadDeletions() {
  sound.playClick();
  deletionList.value = await adminListDeletions();
}

async function updateDeletion(ticketId, status) {
  sound.playClick();
  await adminUpdateDeletion(ticketId, status);
  await loadDeletions();
  sound.playSuccess();
}

async function handleCreateApp() {
  sound.playClick();
  isCreatingApp.value = true;

  try {
    await adminCreateApp({
      name: newAppForm.value.name,
      game_slug: newAppForm.value.game_slug,
      app_type: newAppForm.value.app_type,
      app_abbr: newAppForm.value.app_abbr,
      logo_url: newAppForm.value.logo_url || 'https://txastudio.click/icons/Icon-512.png',
      redirect_uris: newAppForm.value.redirect_uri ? [newAppForm.value.redirect_uri] : []
    });

    sound.playSuccess();
    showCreateModal.value = false;
    await loadDashboardData();
  } catch (e) {
    alert('Lỗi tạo app: ' + e.message);
  } finally {
    isCreatingApp.value = false;
  }
}

async function handleDeleteApp(app) {
  sound.playClick();
  const confirmed = confirm(
    isEn.value 
      ? `Are you sure you want to permanently delete OAuth App "${app.name}" (${app.client_id})? This cannot be undone.`
      : `Bạn có chắc chắn muốn xóa vĩnh viễn App OAuth "${app.name}" (${app.client_id})? Hành động này không thể hoàn tác.`
  );
  if (!confirmed) return;

  try {
    const res = await adminDeleteApp(app.client_id);
    if (res?.success) {
      sound.playSuccess();
      alert(isEn.value ? `Successfully deleted app "${app.name}"!` : `Đã xóa thành công app "${app.name}"!`);
      await loadDashboardData();
    } else {
      alert((isEn.value ? 'Delete failed: ' : 'Lỗi xóa app: ') + (res?.error || 'Unknown error'));
    }
  } catch (err) {
    alert('Error: ' + err.message);
  }
}

async function saveExpiryConfig() {
  sound.playClick();
  const sec = parseInt(expirySecondsInput.value, 10);
  if (isNaN(sec) || sec <= 0) {
    alert('Vui lòng nhập số giây hợp lệ (> 0)');
    return;
  }
  await updateSystemConfig('oauth_expiry_seconds', String(sec));
  await updateSystemConfig('oauth_expiry_minutes', String(Math.round(sec / 60)));
  settingsNotice.value = `✓ Đã cập nhật thời hạn OAuth: ${sec} giây (= ${previewExpiryLabel.value})!`;
  sound.playSuccess();
  setTimeout(() => { settingsNotice.value = ''; }, 3500);
}

function viewSnippet(app) {
  sound.playClick();
  selectedAppSnippet.value = app;
}

async function copy(text) {
  sound.playSuccess();
  try {
    await navigator.clipboard.writeText(text);
    alert('Đã sao chép vào bộ nhớ tạm!');
  } catch (e) {}
}

function syncUser() {
  currentUser.value = getCurrentWebUser();
  if (!currentUser.value) {
    router.replace({ path: '/login', query: { redirect: '/admin' } });
    return;
  }
  if (currentUser.value.role !== 'admin') {
    router.replace('/');
    return;
  }
  loadDashboardData();
}

onMounted(() => {
  window.addEventListener('storage', syncUser);
  window.addEventListener('txa-auth-change', syncUser);
  syncUser();
  if (activeTab.value === 'mycay') {
    startMycayRealtime();
  }
});

onUnmounted(() => {
  destroyMycayCharts();
  stopMycayRealtime();
  window.removeEventListener('storage', syncUser);
  window.removeEventListener('txa-auth-change', syncUser);
});
</script>
