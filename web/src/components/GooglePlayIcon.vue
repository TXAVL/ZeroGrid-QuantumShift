<template>
  <svg :class="customClass || 'w-5 h-5'" viewBox="0 0 512 512" fill="none" xmlns="http://www.w3.org/2000/svg">
    <!-- Left Blue Wing -->
    <path d="M47.1 27.2C43.8 30.7 41.8 36.1 41.8 43.1V468.9C41.8 475.9 43.8 481.3 47.1 484.8L49.5 487.1L272.9 263.7V258.3L49.5 24.9L47.1 27.2Z" fill="url(#gp_grad1)"/>
    <!-- Right Orange Triangle -->
    <path d="M347.4 338.2L272.9 263.7V258.3L347.4 183.8L349.1 184.8L437.3 234.9C462.5 249.2 462.5 272.8 437.3 287.1L349.1 337.2L347.4 338.2Z" fill="url(#gp_grad2)"/>
    <!-- Bottom Red Wing -->
    <path d="M349.1 337.2L272.9 261L47.1 486.8C55.4 495.6 69 496.7 84.4 488L349.1 337.2Z" fill="url(#gp_grad3)"/>
    <!-- Top Green Wing -->
    <path d="M349.1 184.8L84.4 34C69 25.3 55.4 26.4 47.1 35.2L272.9 261L349.1 184.8Z" fill="url(#gp_grad4)"/>
    <defs>
      <linearGradient id="gp_grad1" x1="252.8" y1="467.5" x2="33.1" y2="44.2" gradientUnits="userSpaceOnUse">
        <stop stop-color="#00A0FF"/>
        <stop offset="0.007" stop-color="#00A1FF"/>
        <stop offset="0.26" stop-color="#00BEFF"/>
        <stop offset="0.512" stop-color="#00D2FF"/>
        <stop offset="0.76" stop-color="#00DFFF"/>
        <stop offset="1" stop-color="#00E3FF"/>
      </linearGradient>
      <linearGradient id="gp_grad2" x1="467.8" y1="261" x2="41.2" y2="261" gradientUnits="userSpaceOnUse">
        <stop stop-color="#FFE000"/>
        <stop offset="0.409" stop-color="#FFBD00"/>
        <stop offset="0.775" stop-color="#FFA500"/>
        <stop offset="1" stop-color="#FF9C00"/>
      </linearGradient>
      <linearGradient id="gp_grad3" x1="298.5" y1="286.6" x2="9.8" y2="575.3" gradientUnits="userSpaceOnUse">
        <stop stop-color="#FF2F53"/>
        <stop offset="1" stop-color="#FF4343"/>
      </linearGradient>
      <linearGradient id="gp_grad4" x1="9.8" y1="-53.3" x2="298.5" y2="235.4" gradientUnits="userSpaceOnUse">
        <stop stop-color="#00E676"/>
        <stop offset="1" stop-color="#00B0FF"/>
      </linearGradient>
    </defs>
  </svg>
</template>

<script setup>
defineProps({
  customClass: {
    type: String,
    default: 'w-5 h-5'
  }
});
</script>
