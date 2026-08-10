<script setup>
import { computed } from "vue"
import SuggestionCard from "@/components/SuggestionCard.vue"

const props = defineProps({
  category: { type: Object, required: true },
  draftingId: { type: Number, default: null }
})

defineEmits(["dismiss", "draft", "open"])

const format = new Intl.NumberFormat("en-US")

const exhausted = computed(() => props.category.state === "exhausted")

// Running out of advice for an audience is a conclusion, not an error, so the
// copy says which conclusion was reached. Drafting a campaign and rejecting
// every angle both empty the section, but they mean opposite things.
const verdict = computed(() => {
  const { drafted, considered } = props.category
  if (drafted > 0) {
    return "You drafted a campaign for this audience. Nothing further worth sending this week."
  }
  return `You passed on all ${considered} angles. Nothing here is worth a send this week.`
})
</script>

<template>
  <section>
    <header class="mb-4 border-b border-border pb-3">
      <div class="flex flex-wrap items-baseline gap-x-3 gap-y-1">
        <h2 class="text-base font-semibold tracking-[-0.01em] text-default">
          {{ category.label }}
        </h2>
        <span class="text-sm text-muted">{{ format.format(category.size) }} members</span>
        <!-- The product already ships system segments (Bounced, Suppressed,
             Recently unsubscribed) tagged exactly like this. These audiences
             are the same kind of object, so they carry the same mark. -->
        <span class="tag">System segment</span>
      </div>
      <!-- The rule sits next to the number on purpose. A suggestion is only
           worth trusting if you can see what it counted. -->
      <p class="mt-1 text-xs text-subtle">
        {{ category.definition }}
        <span v-if="category.remaining">
          &nbsp;·&nbsp;{{ category.remaining }} other angle{{ category.remaining === 1 ? "" : "s" }} ready
        </span>
      </p>
    </header>

    <!-- The audience keeps its heading, its count and its rule even with
         nothing left to suggest. Losing the advice is not the same as losing
         the people, and a section that disappears says the wrong one. -->
    <div v-if="exhausted" class="well well--sunken px-5 py-6">
      <p class="text-sm text-muted">{{ verdict }}</p>
      <p class="mt-1.5 text-xs text-subtle">
        New angles appear when the numbers move, not when you ask again.
      </p>
    </div>

    <div v-else class="flex flex-col gap-3">
      <SuggestionCard
        v-for="suggestion in category.suggestions"
        :key="suggestion.id"
        :suggestion="suggestion"
        :drafting="draftingId === suggestion.id"
        @dismiss="$emit('dismiss', $event)"
        @draft="$emit('draft', $event)"
        @open="$emit('open', $event)"
      />
    </div>
  </section>
</template>
