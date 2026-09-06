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

        <div class="flex items-center gap-3">
          <!-- Link to Docs API -->
          <router-link 
            to="/docs" 
            class="px-4 py-2.5 rounded-xl border border-cyan-500/40 bg-cyan-500/10 hover:bg-cyan-500/20 text-cyan-300 font-mono text-xs font-bold transition-all flex items-center gap-2"
          >
            <span>📖</span>
            <span>{{ isEn ? 'API & Integration Docs' : 'Tài Liệu API & Hướng Dẫn' }}</span>
          </router-link>

          <button 
            v-if="isAdminAuthenticated"
            @click="adminLogout" 
            class="px-3 py-2 rounded-xl border border-slate-700 bg-slate-800/80 hover:bg-slate-700 text-slate-300 font-mono text-xs transition-all"
          >
            {{ isEn ? 'Lock Terminal' : 'Khóa Terminal' }}
          </button>
        </div>
      </div>

      <!-- =================================================================== -->
      <!-- AUTHENTICATION GATE (PIN ENTRY)                                     -->
      <!-- =================================================================== -->
      <div v-if="!isAdminAuthenticated" class="max-w-md mx-auto p-6 sm:p-8 rounded-3xl border border-slate-800 bg-[#090d1a]/95 backdrop-blur-xl shadow-2xl text-center space-y-6">
        <div class="inline-flex p-3 rounded-2xl bg-pink-500/10 border border-pink-500/30 text-pink-400 text-2xl">
          🔒
        </div>
        <div class="space-y-1">
          <h2 class="text-lg font-display font-bold text-white">
            {{ isEn ? 'Enter Admin Access PIN' : 'Nhập Mã PIN Quản Trị' }}
          </h2>
          <p class="text-xs text-slate-400 font-mono">
            {{ isEn ? 'Default PIN: 888888 (Changeable in settings)' : 'Mã PIN bảo mật mặc định: 888888' }}
          </p>
        </div>

        <form @submit.prevent="handlePinAuth" class="space-y-4">
          <input 
            type="password" 
            v-model="pinInput" 
            maxlength="10"
            required
            placeholder="••••••"
            class="w-full text-center tracking-[0.5em] text-lg font-mono px-4 py-3 rounded-xl bg-black/60 border border-slate-700 focus:border-pink-500 text-pink-300 outline-none transition-all"
          />

          <div v-if="pinError" class="text-xs text-rose-400 font-mono">
            {{ pinError }}
          </div>

          <button 
            type="submit" 
            class="w-full py-3.5 px-6 rounded-2xl bg-gradient-to-r from-pink-500 via-purple-500 to-cyan-400 text-white font-display font-black text-xs uppercase tracking-wider shadow-lg shadow-pink-500/30 hover:scale-[1.02] active:scale-95 transition-all"
          >
            {{ isEn ? 'UNLOCK ADMIN TERMINAL' : 'MỞ KHÓA BẢNG QUẢN TRỊ' }}
          </button>
        </form>
      </div>

      <!-- =================================================================== -->
      <!-- AUTHENTICATED ADMIN DASHBOARD                                       -->
      <!-- =================================================================== -->
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
                    <img :src="app.logo_url || '/icons/Icon-512.png'" class="w-full h-full object-contain rounded-xl" />
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
                  📋 Xem mã Flutter txa_config.dart
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

            <!-- Expiry Config -->
            <div class="space-y-2">
              <label class="block text-xs font-mono uppercase tracking-wider text-slate-400 font-bold">
                Thời Hạn Phiên Ủy Quyền OAuth (Phút)
              </label>
              <div class="flex items-center gap-3">
                <input 
                  type="number" 
                  min="1" 
                  max="60"
                  v-model="expiryInput" 
                  class="w-24 px-4 py-2.5 rounded-xl bg-black/60 border border-slate-700 text-cyan-300 font-mono text-sm outline-none focus:border-cyan-400 text-center font-bold"
                />
                <span class="text-xs text-slate-400 font-mono">phút (Mặc định: 5 phút)</span>
                <button 
                  @click="saveExpiryConfig"
                  class="px-4 py-2.5 rounded-xl bg-cyan-500/20 hover:bg-cyan-500/30 border border-cyan-500/40 text-cyan-300 text-xs font-mono font-bold transition-all ml-auto"
                >
                  Lưu Cấu Hình
                </button>
              </div>
            </div>

            <!-- PIN Config -->
            <div class="space-y-2 pt-4 border-t border-slate-800">
              <label class="block text-xs font-mono uppercase tracking-wider text-slate-400 font-bold">
                Đổi Mã PIN Truy Cập Admin
              </label>
              <div class="flex items-center gap-3">
                <input 
                  type="password" 
                  v-model="newPinInput" 
                  maxlength="10"
                  placeholder="Mã PIN mới"
                  class="w-36 px-4 py-2.5 rounded-xl bg-black/60 border border-slate-700 text-pink-300 font-mono text-sm outline-none focus:border-pink-400 text-center font-bold"
                />
                <button 
                  @click="savePinConfig"
                  class="px-4 py-2.5 rounded-xl bg-pink-500/20 hover:bg-pink-500/30 border border-pink-500/40 text-pink-300 text-xs font-mono font-bold transition-all ml-auto"
                >
                  Cập Nhật PIN
                </button>
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
              <div>
                <label class="block text-slate-400 mb-1">TÊN ỨNG DỤNG / GAME:</label>
                <input 
                  type="text" 
                  v-model="newAppForm.name" 
                  required 
                  placeholder="Zero Grid: Quantum Shift"
                  class="w-full px-3 py-2.5 rounded-xl bg-slate-900 border border-slate-700 focus:border-cyan-400 text-white outline-none"
                />
              </div>

              <div class="grid grid-cols-2 gap-3">
                <div>
                  <label class="block text-slate-400 mb-1">LOẠI PHẦN MỀM:</label>
                  <select 
                    v-model="newAppForm.app_type"
                    class="w-full px-3 py-2.5 rounded-xl bg-slate-900 border border-slate-700 focus:border-cyan-400 text-white outline-none"
                  >
                    <option value="game">game (Trò chơi)</option>
                    <option value="app">app (Ứng dụng)</option>
                  </select>
                </div>
                <div>
                  <label class="block text-slate-400 mb-1">VIẾT TẮT CHỮ ĐẦU:</label>
                  <input 
                    type="text" 
                    v-model="newAppForm.app_abbr" 
                    required 
                    placeholder="zgqs"
                    class="w-full px-3 py-2.5 rounded-xl bg-slate-900 border border-slate-700 focus:border-cyan-400 text-white outline-none lowercase"
                  />
                </div>
              </div>

              <div>
                <label class="block text-slate-400 mb-1">LIÊN KẾT GAME ĐÃ CÓ TRONG TXA_GAMES:</label>
                <input 
                  type="text" 
                  v-model="newAppForm.game_slug" 
                  required 
                  placeholder="quantumshift"
                  class="w-full px-3 py-2.5 rounded-xl bg-slate-900 border border-slate-700 focus:border-cyan-400 text-cyan-300 font-bold outline-none"
                />
              </div>

              <div>
                <label class="block text-slate-400 mb-1">DEEP LINK CALLBACK URI (TÙY CHỌN):</label>
                <input 
                  type="text" 
                  v-model="newAppForm.redirect_uri" 
                  placeholder="txa.zerogrid.quantumshift://oauth/callback"
                  class="w-full px-3 py-2.5 rounded-xl bg-slate-900 border border-slate-700 focus:border-cyan-400 text-white outline-none"
                />
              </div>

              <div class="p-3 rounded-xl bg-emerald-500/10 border border-emerald-500/20 text-[11px] text-emerald-300 space-y-1">
                <div class="font-bold">✓ Tự động cấp 3 link từ website hiện tại:</div>
                <div>• https://txastudio.click/privacy?game={{ newAppForm.game_slug || 'slug' }}</div>
                <div>• https://txastudio.click/terms?game={{ newAppForm.game_slug || 'slug' }}</div>
                <div>• https://txastudio.click/delete-account?game={{ newAppForm.game_slug || 'slug' }}</div>
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
              <h3 class="font-display font-black text-white text-base">Mã Cấu Hình Flutter (txa_config.dart)</h3>
              <button @click="selectedAppSnippet = null" class="text-slate-400 hover:text-white">✕</button>
            </div>

            <p class="text-xs text-slate-300 font-mono">
              Dán đoạn mã sau vào file <span class="text-cyan-400 font-bold">lib/config/txa_config.dart</span> trong dự án game của bạn:
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
import { ref, computed, onMounted, inject } from 'vue';
import { 
  adminListApps, 
  adminCreateApp, 
  adminListDeletions, 
  adminUpdateDeletion, 
  getSystemConfigs, 
  updateSystemConfig 
} from '../services/supabase.js';
import { sound } from '../services/sound.js';

const currentLang = inject('currentLang', ref('vi'));
const isEn = computed(() => currentLang.value === 'en');

const isAdminAuthenticated = ref(sessionStorage.getItem('txa_admin_auth') === 'true');
const pinInput = ref('');
const pinError = ref('');

const activeTab = ref('apps');
const appList = ref([]);
const deletionList = ref([]);
const systemConfigs = ref({});

const expiryInput = ref('5');
const newPinInput = ref('');
const settingsNotice = ref('');

const showCreateModal = ref(false);
const isCreatingApp = ref(false);
const newAppForm = ref({
  name: '',
  game_slug: 'quantumshift',
  app_type: 'game',
  app_abbr: 'zgqs',
  redirect_uri: 'txa.zerogrid.quantumshift://oauth/callback'
});

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

async function handlePinAuth() {
  sound.playClick();
  pinError.value = '';
  
  // Verify with saved pin in configs or default '888888'
  const cfgs = await getSystemConfigs();
  const currentPin = cfgs['admin_pin'] || '888888';

  if (pinInput.value.trim() === currentPin) {
    isAdminAuthenticated.value = true;
    sessionStorage.setItem('txa_admin_auth', 'true');
    sound.playSuccess();
    loadDashboardData();
  } else {
    sound.playClick();
    pinError.value = 'Mã PIN không chính xác!';
  }
}

function adminLogout() {
  sound.playClick();
  isAdminAuthenticated.value = false;
  sessionStorage.removeItem('txa_admin_auth');
}

async function loadDashboardData() {
  try {
    const [apps, deletions, configs] = await Promise.all([
      adminListApps(),
      adminListDeletions(),
      getSystemConfigs()
    ]);
    appList.value = apps || [];
    deletionList.value = deletions || [];
    systemConfigs.value = configs || {};
    expiryInput.value = configs['oauth_expiry_minutes'] || '5';
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
      redirect_uris: newAppForm.value.redirect_uri ? [newAppForm.value.redirect_uri] : []
    });

    sound.playSuccess();
    showCreateModal.value = false;
    newAppForm.value.name = '';
    await loadDashboardData();
  } catch (e) {
    alert('Lỗi tạo app: ' + e.message);
  } finally {
    isCreatingApp.value = false;
  }
}

async function saveExpiryConfig() {
  sound.playClick();
  await updateSystemConfig('oauth_expiry_minutes', expiryInput.value);
  settingsNotice.value = '✓ Đã cập nhật thời hạn phiên OAuth thành công!';
  sound.playSuccess();
  setTimeout(() => { settingsNotice.value = ''; }, 3000);
}

async function savePinConfig() {
  if (!newPinInput.value || newPinInput.value.length < 4) {
    alert('Mã PIN tối thiểu 4 số');
    return;
  }
  sound.playClick();
  await updateSystemConfig('admin_pin', newPinInput.value);
  newPinInput.value = '';
  settingsNotice.value = '✓ Đã cập nhật mã PIN Admin thành công!';
  sound.playSuccess();
  setTimeout(() => { settingsNotice.value = ''; }, 3000);
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

onMounted(() => {
  if (isAdminAuthenticated.value) {
    loadDashboardData();
  }
});
</script>
