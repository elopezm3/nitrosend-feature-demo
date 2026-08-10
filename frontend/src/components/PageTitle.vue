<script setup>
defineProps({
  eyebrow: { type: String, default: null },
  title: { type: String, required: true }
})
</script>

<template>
  <header class="mb-8 flex flex-wrap items-end justify-between gap-x-8 gap-y-4">
    <div>
      <p v-if="eyebrow" class="eyebrow mb-1.5">{{ eyebrow }}</p>
      <h1 class="text-2xl font-semibold tracking-[-0.02em] text-default">{{ title }}</h1>
      <p v-if="$slots.subtitle" class="mt-1.5 max-w-[62ch] text-sm text-muted">
        <slot name="subtitle" />
      </p>
    </div>
    <div v-if="$slots.actions" class="flex items-center gap-2">
      <slot name="actions" />
    </div>
  </header>
</template>
