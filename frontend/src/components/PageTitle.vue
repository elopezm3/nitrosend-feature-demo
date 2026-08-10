<script setup>
defineProps({
  eyebrow: { type: String, default: null },
  title: { type: String, required: true },
  count: { type: [Number, String], default: null }
})
</script>

<template>
  <!-- The product's page header: large bold title, subtitle beneath, and the
       page action sitting BELOW the title and left aligned rather than in a
       right-hand actions slot. -->
  <header class="mb-8">
    <div class="flex items-start gap-3">
      <div v-if="$slots.lead" class="pt-1.5">
        <slot name="lead" />
      </div>

      <div class="min-w-0">
        <p v-if="eyebrow" class="eyebrow mb-1.5">{{ eyebrow }}</p>

        <h1 class="flex items-baseline gap-2 text-[34px] font-bold leading-[1.1] tracking-[-0.025em] text-default">
          {{ title }}
          <span v-if="count !== null" class="text-lg font-medium text-subtle">({{ count }})</span>
        </h1>

        <p v-if="$slots.subtitle" class="mt-1.5 max-w-[62ch] text-[15px] text-muted">
          <slot name="subtitle" />
        </p>
      </div>
    </div>

    <div v-if="$slots.actions" class="mt-5 flex flex-wrap items-center gap-2.5">
      <slot name="actions" />
    </div>
  </header>
</template>
