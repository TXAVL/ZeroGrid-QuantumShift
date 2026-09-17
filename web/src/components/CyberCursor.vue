<template>
  <div v-if="isEnabled" class="cyber-cursor-container pointer-events-none fixed inset-0 z-[9999] overflow-hidden">
    <!-- Smooth Trailing Outer Ring -->
    <div 
      class="cursor-follower fixed top-0 left-0 rounded-full pointer-events-none transition-transform duration-75 ease-out"
      :class="{
        'is-hovering': isHovering,
        'is-clicking': isClicking,
        'is-disabled': isDisabledState
      }"
      :style="{
        transform: `translate3d(${trailingX}px, ${trailingY}px, 0) translate(-50%, -50%)`
      }"
    >
      <!-- Neon particle halo -->
      <div class="ring-glow w-full h-full rounded-full"></div>
    </div>

    <!-- Laser Core Pointer Dot -->
    <div 
      class="cursor-dot fixed top-0 left-0 rounded-full pointer-events-none"
      :class="{
        'dot-hover': isHovering,
        'dot-click': isClicking,
        'dot-disabled': isDisabledState
      }"
      :style="{
        transform: `translate3d(${cursorX}px, ${cursorY}px, 0) translate(-50%, -50%)`
      }"
    ></div>

    <!-- Click Ripple Wave -->
    <div 
      v-for="ripple in ripples" 
      :key="ripple.id"
      class="click-ripple fixed top-0 left-0 rounded-full pointer-events-none"
      :style="{
        transform: `translate3d(${ripple.x}px, ${ripple.y}px, 0) translate(-50%, -50%)`
      }"
    ></div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue';

const isEnabled = ref(false);
const cursorX = ref(-100);
const cursorY = ref(-100);
const trailingX = ref(-100);
const trailingY = ref(-100);

const isHovering = ref(false);
const isClicking = ref(false);
const isDisabledState = ref(false);
const ripples = ref([]);

let animFrameId = null;
let rippleCounter = 0;

function updateTrailing() {
  // Smooth Lerp (Linear Interpolation) 0.18 factor
  trailingX.value += (cursorX.value - trailingX.value) * 0.22;
  trailingY.value += (cursorY.value - trailingY.value) * 0.22;

  animFrameId = requestAnimationFrame(updateTrailing);
}

function onMouseMove(e) {
  cursorX.value = e.clientX;
  cursorY.value = e.clientY;

  // Check element under cursor for hover / disabled states
  const target = e.target;
  if (!target) return;

  const isClickable = target.closest('a, button, [role="button"], input, select, textarea, .cursor-pointer, .glass-card, [tabindex="0"]');
  const isDisabled = target.closest(':disabled, [aria-disabled="true"], .cursor-not-allowed, .disabled');

  isDisabledState.value = Boolean(isDisabled);
  isHovering.value = Boolean(isClickable && !isDisabled);
}

function onMouseDown(e) {
  isClicking.value = true;

  // Add expanding ripple ring
  const id = ++rippleCounter;
  ripples.value.push({ id, x: e.clientX, y: e.clientY });

  setTimeout(() => {
    ripples.value = ripples.value.filter(r => r.id !== id);
  }, 600);
}

function onMouseUp() {
  isClicking.value = false;
}

function onMouseLeave() {
  cursorX.value = -100;
  cursorY.value = -100;
}

onMounted(() => {
  // Only enable on desktop pointer devices
  if (window.matchMedia('(hover: hover) and (pointer: fine)').matches) {
    isEnabled.value = true;
    window.addEventListener('mousemove', onMouseMove, { passive: true });
    window.addEventListener('mousedown', onMouseDown, { passive: true });
    window.addEventListener('mouseup', onMouseUp, { passive: true });
    document.addEventListener('mouseleave', onMouseLeave, { passive: true });

    animFrameId = requestAnimationFrame(updateTrailing);
  }
});

onUnmounted(() => {
  if (animFrameId) cancelAnimationFrame(animFrameId);
  window.removeEventListener('mousemove', onMouseMove);
  window.removeEventListener('mousedown', onMouseDown);
  window.removeEventListener('mouseup', onMouseUp);
  document.removeEventListener('mouseleave', onMouseLeave);
});
</script>

<style>
/* ==========================================================================
   GLOBAL CUSTOM CYBERPUNK CURSORS (Embedded SVG)
   ========================================================================== */

/* 1. DEFAULT CURSOR: Cyberpunk Neon Arrow */
html, body {
  cursor: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24'%3E%3Cpolygon points='2,2 2,19 7,14 11,21 13,20 9,13 16,13' fill='%2305070e' stroke='%2300f0ff' stroke-width='1.5' stroke-linejoin='round'/%3E%3Cpolygon points='4,5 4,14 7,11 10,17 11,16 8,10 12,10' fill='%2300f0ff'/%3E%3C/svg%3E"), auto !important;
}

/* 2. POINTER / CLICKABLE CURSOR: Cyber Target Crosshair Diamond */
a, button, [role="button"], .cursor-pointer, input[type="button"], input[type="submit"] {
  cursor: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='28' height='28' viewBox='0 0 28 28'%3E%3Ccircle cx='14' cy='14' r='11' fill='none' stroke='%23ff007f' stroke-width='1.5' stroke-dasharray='3 2'/%3E%3Cpolygon points='14,3 14,8 10,14 14,20 14,25 18,14' fill='%2300f0ff' stroke='%2305070e' stroke-width='1'/%3E%3Ccircle cx='14' cy='14' r='2.5' fill='%23ff007f'/%3E%3C/svg%3E") 14 14, pointer !important;
}

/* 3. TEXT / INPUT CURSOR: Cyber Beam */
input[type="text"], input[type="email"], input[type="password"], input[type="search"], textarea, [contenteditable="true"] {
  cursor: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='18' height='24' viewBox='0 0 18 24'%3E%3Cpath d='M6 3h6M9 3v18M6 21h6' fill='none' stroke='%2300f0ff' stroke-width='2' stroke-linecap='round'/%3E%3Ccircle cx='9' cy='12' r='2' fill='%23ff007f'/%3E%3C/svg%3E") 9 12, text !important;
}

/* 4. NOT-ALLOWED / DISABLED CURSOR: Cyber Lockout Hex */
:disabled, [aria-disabled="true"], .cursor-not-allowed, .disabled {
  cursor: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24'%3E%3Ccircle cx='12' cy='12' r='9' fill='%231f0a10' stroke='%23f43f5e' stroke-width='2'/%3E%3Cline x1='6' y1='6' x2='18' y2='18' stroke='%23f43f5e' stroke-width='2' stroke-linecap='round'/%3E%3C/svg%3E") 12 12, not-allowed !important;
}

/* ==========================================================================
   DYNAMIC FOLLOWER & RIPPLE STYLES
   ========================================================================== */

.cursor-dot {
  width: 6px;
  height: 6px;
  background-color: #00f0ff;
  box-shadow: 0 0 8px #00f0ff, 0 0 16px rgba(0, 240, 255, 0.6);
  transition: width 0.15s ease, height 0.15s ease, background-color 0.2s ease;
  z-index: 10000;
}

.cursor-dot.dot-hover {
  width: 8px;
  height: 8px;
  background-color: #ff007f;
  box-shadow: 0 0 10px #ff007f, 0 0 20px rgba(255, 0, 127, 0.8);
}

.cursor-dot.dot-disabled {
  background-color: #f43f5e;
  box-shadow: 0 0 8px #f43f5e;
}

.cursor-follower {
  width: 28px;
  height: 28px;
  border: 1.5px solid rgba(0, 240, 255, 0.5);
  box-shadow: 0 0 14px rgba(0, 240, 255, 0.25);
  transition: width 0.25s cubic-bezier(0.16, 1, 0.3, 1), 
              height 0.25s cubic-bezier(0.16, 1, 0.3, 1), 
              border-color 0.2s ease, 
              background-color 0.2s ease;
  z-index: 9998;
}

.cursor-follower.is-hovering {
  width: 44px;
  height: 44px;
  border-color: rgba(255, 0, 127, 0.8);
  background-color: rgba(255, 0, 127, 0.08);
  box-shadow: 0 0 22px rgba(255, 0, 127, 0.4), inset 0 0 12px rgba(255, 0, 127, 0.2);
}

.cursor-follower.is-clicking {
  width: 22px;
  height: 22px;
  border-color: #00ffa3;
  background-color: rgba(0, 255, 163, 0.2);
  box-shadow: 0 0 18px rgba(0, 255, 163, 0.6);
}

.cursor-follower.is-disabled {
  border-color: rgba(244, 63, 94, 0.6);
  background-color: rgba(244, 63, 94, 0.1);
  box-shadow: 0 0 12px rgba(244, 63, 94, 0.3);
}

.click-ripple {
  width: 10px;
  height: 10px;
  border: 2px solid #00f0ff;
  animation: cyber-ripple-anim 0.55s cubic-bezier(0.1, 0.8, 0.2, 1) forwards;
  z-index: 9997;
}

@keyframes cyber-ripple-anim {
  0% {
    width: 8px;
    height: 8px;
    opacity: 1;
    border-color: #00f0ff;
  }
  50% {
    border-color: #ff007f;
  }
  100% {
    width: 60px;
    height: 60px;
    opacity: 0;
    border-color: #7000ff;
  }
}
</style>
