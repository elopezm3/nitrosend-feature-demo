<script setup>
import SuggestionCard from "@/components/SuggestionCard.vue"

defineProps({
  category: { type: Object, required: true }
})

defineEmits(["dismiss"])

const format = new Intl.NumberFormat("en-US")
</script>

<template>
  <section>
    <header class="mb-4 border-b border-border pb-3">
      <div class="flex flex-wrap items-baseline gap-x-3 gap-y-1">
        <h2 class="text-base font-semibold tracking-[-0.01em] text-default">
          {{ category.label }}
        </h2>
        <span class="text-sm text-muted">{{ format.format(category.size) }} contacts</span>
      </div>
      <!-- The rule sits next to the number on purpose. A suggestion is only
           worth trusting if you can see what it counted. -->
      <p class="mt-1 text-xs text-subtle">{{ category.definition }}</p>
    </header>

    <div class="flex flex-col gap-3">
      <SuggestionCard
        v-for="suggestion in category.suggestions"
        :key="suggestion.id"
        :suggestion="suggestion"
        @dismiss="$emit('dismiss', $event)"
      />
    </div>
  </section>
</template>
