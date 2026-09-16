<template>
  <svg :class="customClass || 'w-5 h-5'" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="1.5"/>
    <circle cx="12" cy="12" r="4" fill="currentColor"/>
    <path d="M12 2A10 10 0 0 1 20.66 7L12 12" stroke="currentColor" stroke-width="1.5"/>
    <path d="M20.66 7A10 10 0 0 1 12 22L12 12" stroke="currentColor" stroke-width="1.5"/>
    <path d="M12 22A10 10 0 0 1 3.34 7L12 12" stroke="currentColor" stroke-width="1.5"/>
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
