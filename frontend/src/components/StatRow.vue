<script setup>
defineProps({ stats: { type: Array, required: true } })
</script>

<template>
  <div class="mb-9 grid grid-cols-2 gap-3 sm:grid-cols-4">
    <div v-for="stat in stats" :key="stat.label" class="card px-4 py-3">
      <p class="eyebrow">{{ stat.label }}</p>
      <p class="mt-1.5 text-[26px] font-semibold leading-none tracking-[-0.02em] text-default">
        {{ stat.value }}
      </p>
      <p class="mt-2 truncate text-xs text-subtle">{{ stat.detail }}</p>
    </div>
  </div>
</template>
