<script setup>
defineProps({
  title: { type: String, required: true },
  body: { type: String, required: true }
})
</script>

<template>
  <div class="card px-8 py-14 text-center">
    <h2 class="card-title text-base">{{ title }}</h2>
    <p class="mx-auto mt-2 max-w-[46ch] text-sm text-muted">{{ body }}</p>
    <slot />
  </div>
</template>
