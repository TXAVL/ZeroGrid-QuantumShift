<template>
  <div class="min-h-screen flex flex-col justify-between selection:bg-cyan-400 selection:text-black font-sans relative">
    <!-- Interactive Matrix/Cyber Canvas Grid -->
    <CyberBackground />

    <!-- Navigation Header -->
    <CyberNavbar />

    <!-- Main Dynamic Route View -->
    <main class="flex-grow flex flex-col">
      <router-view v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </main>

    <!-- Studio Footer -->
    <CyberFooter />

    <!-- Global Platform Download & Internal Testing Modal -->
    <DownloadPlatformModal ref="downloadModalRef" />
  </div>
</template>

<script setup>
import { ref, provide, onMounted } from 'vue';
import CyberBackground from './components/CyberBackground.vue';
import CyberNavbar from './components/CyberNavbar.vue';
import CyberFooter from './components/CyberFooter.vue';
import DownloadPlatformModal from './components/DownloadPlatformModal.vue';

const currentLang = ref(localStorage.getItem('txa_portal_lang') || 'vi');
const downloadModalRef = ref(null);

function setLang(lang) {
  currentLang.value = lang;
  localStorage.setItem('txa_portal_lang', lang);
  document.documentElement.lang = lang;
}

function openDownloadModal(platform) {
  if (downloadModalRef.value) {
    downloadModalRef.value.open(platform);
  }
}

provide('currentLang', currentLang);
provide('setLang', setLang);
provide('openDownloadModal', openDownloadModal);

onMounted(() => {
  document.documentElement.lang = currentLang.value;
});
</script>

<style>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease, transform 0.2s ease;
}

.fade-enter-from {
  opacity: 0;
  transform: translateY(6px);
}

.fade-leave-to {
  opacity: 0;
  transform: translateY(-6px);
}
</style>
