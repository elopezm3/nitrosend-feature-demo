<script setup>
// Composite skeletons pulse each bar, never the wrapper, so the card chrome
// stays still while its contents load. DESIGN.md §4.
defineProps({ count: { type: Number, default: 3 } })
</script>

<template>
  <div class="flex flex-col gap-8">
    <section v-for="n in count" :key="n">
      <div class="mb-4 flex items-baseline gap-3 border-b border-border pb-3">
        <div class="skeleton-line h-4 w-32 rounded"></div>
        <div class="skeleton-line h-3 w-20 rounded"></div>
      </div>
      <div class="card p-5">
        <div class="skeleton-line mb-4 h-4 w-2/5 rounded"></div>
        <div class="flex flex-col gap-2">
          <div class="skeleton-line h-3 w-full rounded"></div>
          <div class="skeleton-line h-3 w-11/12 rounded"></div>
          <div class="skeleton-line h-3 w-3/5 rounded"></div>
        </div>
        <div class="skeleton-block mt-5 h-9 w-full rounded-lg"></div>
      </div>
    </section>
  </div>
</template>
