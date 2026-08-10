<script setup>
defineProps({
  suggestion: { type: Object, required: true },
  drafting: { type: Boolean, default: false }
})

const emit = defineEmits(["dismiss", "draft", "open"])

const format = new Intl.NumberFormat("en-US")

// DESIGN.md §4 semantic law: a badge means "needs attention". Confidence is
// passive metadata, so it renders on the quiet text ramp instead of as a
// coloured chip.
const CONFIDENCE_COPY = {
  high: "Strong signal",
  medium: "Worth a look",
  low: "Thin evidence"
}
</script>

<template>
  <article class="card">
    <div class="card-header flex items-start justify-between gap-6">
      <button
        type="button"
        class="text-left text-[17px] font-semibold tracking-[-0.01em] text-default
               hover:underline decoration-border underline-offset-4
               focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-600"
        @click="emit('open', suggestion)"
      >
        {{ suggestion.title }}
      </button>
      <span class="meta-quiet shrink-0 pt-1">{{ CONFIDENCE_COPY[suggestion.confidence] }}</span>
    </div>

    <div class="card-body">
      <dl class="grid grid-cols-1 gap-x-6 gap-y-3 sm:grid-cols-[132px_1fr]">
        <dt class="eyebrow pt-1">What we found</dt>
        <dd class="text-sm text-default">{{ suggestion.headline_fact }}</dd>

        <dt class="eyebrow pt-1">Why now</dt>
        <dd class="text-sm text-muted">{{ suggestion.why_now }}</dd>

        <dt class="eyebrow pt-1">Subject</dt>
        <dd class="text-sm text-default">“{{ suggestion.proposed_subject }}”</dd>
      </dl>
    </div>

    <footer
      class="flex flex-wrap items-center justify-between gap-4 border-t border-divider px-4 py-3 sm:px-5"
    >
      <span class="text-xs text-subtle">
        Reaches {{ format.format(suggestion.estimated_reach) }} people
      </span>
      <div class="flex items-center gap-2">
        <button
          type="button"
          class="button ghost sm"
          :disabled="drafting"
          @click="emit('dismiss', suggestion.id)"
        >
          Not this one
        </button>
        <button
          type="button"
          class="button secondary sm"
          :disabled="drafting"
          @click="emit('draft', suggestion.id)"
        >
          {{ drafting ? "Creating this campaign…" : "Draft this campaign" }}
        </button>
      </div>
    </footer>
  </article>
</template>
