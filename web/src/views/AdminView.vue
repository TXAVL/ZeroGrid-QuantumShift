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

      <!-- =================================================================== -->
      <!-- AUTHENTICATION GATE (WEBSITE ACCOUNT WITH ROLE: ADMIN)              -->
      <!-- =================================================================== -->
      
      <!-- STATE A: NOT LOGGED IN -->
      <div v-if="!currentUser" class="max-w-md mx-auto p-6 sm:p-8 rounded-3xl border border-slate-800 bg-[#090d1a]/95 backdrop-blur-xl shadow-2xl text-center space-y-6">
        <div class="inline-flex p-4 rounded-2xl bg-cyan-500/10 border border-cyan-500/30 text-cyan-400 text-3xl">
          🔐
        </div>
        <div class="space-y-2">
          <span class="px-3 py-1 rounded-full text-[10px] font-mono font-bold uppercase tracking-widest bg-cyan-500/20 text-cyan-300 border border-cyan-500/30">
            ADMIN ACCESS REQUIRED
          </span>
          <h2 class="text-xl font-display font-black text-white">
            {{ isEn ? 'Master Admin Login Required' : 'Yêu Cầu Đăng Nhập Quản Trị' }}
          </h2>
          <p class="text-xs text-slate-300 font-mono leading-relaxed">
            {{ isEn 
              ? 'You must sign in with a TXA Studio account that has the "admin" role to access this control terminal.' 
              : 'Bạn cần đăng nhập bằng tài khoản TXA Studio có vai trò Quản trị viên (role: admin) để truy cập Bảng Điều Khiển này.' }}
          </p>
        </div>

        <router-link 
          to="/login?redirect=/admin"
          class="block w-full py-3.5 px-6 rounded-2xl bg-gradient-to-r from-cyan-400 via-sky-500 to-pink-500 text-slate-950 font-display font-black text-xs uppercase tracking-wider shadow-lg shadow-cyan-500/30 hover:scale-[1.02] active:scale-95 transition-all text-center"
        >
          {{ isEn ? 'SIGN IN WITH ADMIN ACCOUNT' : 'ĐĂNG NHẬP TÀI KHOẢN ADMIN' }}
        </router-link>
      </div>

      <!-- STATE B: LOGGED IN BUT NOT ADMIN -->
      <div v-else-if="!isAdmin" class="max-w-md mx-auto p-6 sm:p-8 rounded-3xl border border-rose-500/30 bg-[#090d1a]/95 backdrop-blur-xl shadow-2xl text-center space-y-6">
        <div class="inline-flex p-4 rounded-2xl bg-rose-500/10 border border-rose-500/30 text-rose-400 text-3xl">
          🚫
        </div>
        <div class="space-y-2">
          <span class="px-3 py-1 rounded-full text-[10px] font-mono font-bold uppercase tracking-widest bg-rose-500/20 text-rose-300 border border-rose-500/30">
            ACCESS RESTRICTED // 403 FORBIDDEN
          </span>
          <h2 class="text-xl font-display font-black text-white">
            {{ isEn ? 'Insufficient Privileges' : 'Từ Chối Truy Cập' }}
          </h2>
          <p class="text-xs text-slate-300 font-mono leading-relaxed">
            {{ isEn 
              ? `Your account (${currentUser.email}) has role "${currentUser.role || 'player'}". Only accounts with role "admin" can access the system terminal.` 
              : `Tài khoản hiện tại (${currentUser.email}) chỉ có vai trò "${currentUser.role || 'player'}". Chỉ tài khoản có vai trò "admin" mới có quyền truy cập bảng điều khiển này.` }}
          </p>
        </div>

        <div class="space-y-3 pt-2">
          <button 
            @click="switchAdminAccount"
            class="w-full py-3.5 px-6 rounded-2xl bg-gradient-to-r from-pink-500 via-purple-500 to-cyan-400 text-white font-display font-black text-xs uppercase tracking-wider shadow-lg shadow-pink-500/30 hover:scale-[1.02] active:scale-95 transition-all"
          >
            {{ isEn ? 'SWITCH TO ADMIN ACCOUNT' : 'ĐỔI SANG TÀI KHOẢN ADMIN' }}
          </button>
          <router-link to="/" class="inline-block text-xs font-mono text-slate-500 hover:text-slate-300 underline">
            ← {{ isEn ? 'Return to Home Portal' : 'Quay về trang chủ TXA Studio' }}
          </router-link>
        </div>
      </div>

      <!-- STATE C: LOGGED IN AND ROLE === 'admin' -->
      <div v-else class="space-y-6">
        
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
            @click="activeTab = 'deletions'"
            class="px-4 py-2.5 rounded-xl border transition-all flex items-center gap-2 shrink-0"
            :class="activeTab === 'deletions' ? 'bg-rose-500/10 text-rose-300 border-rose-500/40 shadow-lg shadow-rose-500/10' : 'text-slate-400 border-slate-800 hover:text-white'"
          >
            <span>🗑️ Duyệt Yêu Cầu Xóa Dữ Liệu</span>
            <span class="px-1.5 py-0.2 rounded bg-rose-500/20 text-rose-300 text-[10px]">{{ deletionList.length }}</span>
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

              <!-- Flutter Integration Snippet Button -->
              <div class="pt-2 border-t border-slate-800/80 flex items-center justify-between">
                <button 
                  @click="viewSnippet(app)"
                  class="text-xs font-mono text-cyan-400 hover:text-cyan-300 underline font-bold"
                >
                  📋 {{ isEn ? 'View Config Snippet' : 'Xem mã cấu hình' }}
                </button>
                <span class="text-[10px] font-mono text-slate-500">Status: {{ app.status }}</span>
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

      </div>

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

    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, inject } from 'vue';
import { useRouter } from 'vue-router';
import { 
  adminListApps, 
  adminCreateApp, 
  adminListDeletions, 
  adminUpdateDeletion, 
  getSystemConfigs, 
  updateSystemConfig,
  formatSecondsToHumanLabel,
  getCurrentWebUser,
  clearCurrentWebUser,
  promoteToAdmin,
  getAllGames
} from '../services/supabase.js';
import { sound } from '../services/sound.js';

const router = useRouter();
const currentLang = inject('currentLang', ref('vi'));
const isEn = computed(() => currentLang.value === 'en');

const currentUser = ref(getCurrentWebUser());
const isAdmin = computed(() => currentUser.value && currentUser.value.role === 'admin');

const activeTab = ref('apps');
const appList = ref([]);
const deletionList = ref([]);
const systemConfigs = ref({});
const availableGames = ref([]);

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
    const [apps, deletions, configs, games] = await Promise.all([
      adminListApps(),
      adminListDeletions(),
      getSystemConfigs(),
      getAllGames()
    ]);
    appList.value = apps || [];
    deletionList.value = deletions || [];
    systemConfigs.value = configs || {};
    availableGames.value = games || [];
    expirySecondsInput.value = configs['oauth_expiry_seconds'] || (configs['oauth_expiry_minutes'] ? String(parseInt(configs['oauth_expiry_minutes'], 10) * 60) : '300');

    // Auto initialize preset if available
    if (availableGames.value.length > 0 && selectedPreset.value !== 'custom') {
      const found = availableGames.value.find(g => g.slug === selectedPreset.value) || availableGames.value[0];
      selectedPreset.value = found.slug;
      applyGamePreset(found);
    }
  } catch (e) {
    console.error('Failed to load admin data', e);
  }
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
  if (isAdmin.value) {
    loadDashboardData();
  }
}

onMounted(() => {
  window.addEventListener('storage', syncUser);
  window.addEventListener('txa-auth-change', syncUser);
  syncUser();
});

onUnmounted(() => {
  window.removeEventListener('storage', syncUser);
  window.removeEventListener('txa-auth-change', syncUser);
});
</script>
