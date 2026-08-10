<script setup>
defineProps({
  title: { type: String, required: true },
  body: { type: String, required: true }
})
</script>

<template>
  <div class="card flex flex-col items-center px-8 py-16 text-center">
    <div class="well well--sunken flex h-14 w-14 items-center justify-center">
      <svg
        viewBox="0 0 24 24"
        class="h-6 w-6 text-muted"
        fill="none"
        stroke="currentColor"
        stroke-width="1.5"
        stroke-linecap="round"
        stroke-linejoin="round"
      >
        <path d="M4 8.5 12 5l8 3.5-8 3.5zM4 12.5 12 16l8-3.5M4 16 12 19.5l8-3.5" />
      </svg>
    </div>

    <h2 class="mt-4 text-base font-semibold text-default">{{ title }}</h2>
    <p class="mx-auto mt-1.5 max-w-[46ch] text-sm text-muted">{{ body }}</p>

    <div v-if="$slots.default" class="mt-5 flex items-center gap-2.5">
      <slot />
    </div>
  </div>
</template>
