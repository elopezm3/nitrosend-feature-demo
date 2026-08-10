<script setup>
import { ref } from "vue"

defineProps({
  suggestion: { type: Object, required: true }
})

const emit = defineEmits(["dismiss"])
const showPrompt = ref(false)

const format = new Intl.NumberFormat("en-US")

// DESIGN.md §4 semantic law: a badge means "needs attention". Confidence is
// passive metadata, so it renders on the quiet text ramp instead of as a
// coloured chip — the same treatment as a flow step's configuration state.
const CONFIDENCE_COPY = {
  high: "Strong signal",
  medium: "Worth a look",
  low: "Thin evidence"
}
</script>

<template>
  <article class="card">
    <div class="card-header flex items-start justify-between gap-6">
      <h3 class="card-title text-[17px] tracking-[-0.01em]">{{ suggestion.title }}</h3>
      <span class="meta-quiet shrink-0 pt-1">
        {{ CONFIDENCE_COPY[suggestion.confidence] }}
      </span>
    </div>

    <div class="card-body">
      <dl class="grid grid-cols-1 gap-x-6 gap-y-3 sm:grid-cols-[132px_1fr]">
        <dt class="eyebrow pt-1">What we found</dt>
        <dd class="text-sm text-default">{{ suggestion.headline_fact }}</dd>

        <dt class="eyebrow pt-1">Why now</dt>
        <dd class="text-sm text-muted">{{ suggestion.why_now }}</dd>

        <dt class="eyebrow pt-1">Angle</dt>
        <dd class="text-sm text-muted">{{ suggestion.proposed_angle }}</dd>

        <dt class="eyebrow pt-1">Subject</dt>
        <dd class="text-sm text-default">“{{ suggestion.proposed_subject }}”</dd>
      </dl>

      <div class="mt-5">
        <button
          type="button"
          class="text-xs text-muted underline decoration-border underline-offset-4 hover:text-default"
          :aria-expanded="showPrompt"
          @click="showPrompt = !showPrompt"
        >
          {{ showPrompt ? "Hide" : "See" }} the prompt this hands your agent
        </button>

        <!-- The page never writes the email. It writes the prompt, and shows
             it before anything runs. -->
        <div v-if="showPrompt" class="well well--sunken mt-3 p-4">
          <pre class="font-mono text-xs leading-relaxed whitespace-pre-wrap text-muted">{{ suggestion.agent_prompt }}</pre>
        </div>
      </div>
    </div>

    <footer
      class="flex flex-wrap items-center justify-between gap-4 border-t border-divider px-4 py-3 sm:px-5"
    >
      <span class="text-xs text-subtle">
        Reaches {{ format.format(suggestion.estimated_reach) }} people
      </span>
      <div class="flex items-center gap-2">
        <button type="button" class="button ghost sm" @click="emit('dismiss', suggestion.id)">
          Not this one
        </button>
        <button type="button" class="button secondary sm">Draft this campaign</button>
      </div>
    </footer>
  </article>
</template>
