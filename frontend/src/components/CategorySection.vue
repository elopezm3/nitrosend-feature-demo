<script setup>
import { computed } from "vue"
import { RouterLink } from "vue-router"
import SuggestionCard from "@/components/SuggestionCard.vue"

const props = defineProps({
  category: { type: Object, required: true },
  draftingId: { type: Number, default: null }
})

defineEmits(["dismiss", "draft", "open"])

const format = new Intl.NumberFormat("en-US")

const closed = computed(() => props.category.state !== "active")
const drafted = computed(() => props.category.state === "drafted")

const verdict = computed(() =>
  drafted.value
    ? "You have a campaign in progress for this audience."
    : `You passed on all ${props.category.passed} angles. Nothing here is worth a send this week.`
)

const note = computed(() =>
  drafted.value
    ? "One send per audience is the point. This one is settled until the next cycle."
    : "New angles appear when the numbers move, not when you ask again."
)
</script>

<template>
  <section>
    <header class="mb-4 border-b border-border pb-3">
      <div class="flex flex-wrap items-baseline gap-x-3 gap-y-1">
        <h2 class="text-base font-semibold tracking-[-0.01em] text-default">
          {{ category.label }}
        </h2>
        <span class="text-sm text-muted">{{ format.format(category.size) }} members</span>
        <span class="tag">System segment</span>
      </div>
      <p class="mt-1 text-xs text-subtle">
        {{ category.definition }}
        <span v-if="category.remaining">
          &nbsp;·&nbsp;{{ category.remaining }} other angle{{ category.remaining === 1 ? "" : "s" }} ready
        </span>
      </p>
    </header>

    <div v-if="closed" class="well well--sunken flex flex-wrap items-center justify-between gap-4 px-5 py-6">
      <div>
        <p class="text-sm text-muted">{{ verdict }}</p>
        <p class="mt-1.5 text-xs text-subtle">{{ note }}</p>
      </div>
      <RouterLink
        v-if="category.drafted_campaign_id"
        :to="`/campaigns/${category.drafted_campaign_id}`"
        class="button secondary sm"
      >
        Open the draft
      </RouterLink>
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
