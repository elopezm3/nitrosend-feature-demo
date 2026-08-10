<script setup>
import { onMounted, computed, ref } from "vue"
import { useRouter } from "vue-router"
import { useSuggestionsStore } from "@/stores/suggestions"
import PageTitle from "@/components/PageTitle.vue"
import CategorySection from "@/components/CategorySection.vue"
import NoDataPlaceholder from "@/components/NoDataPlaceholder.vue"
import SkeletonLoader from "@/components/SkeletonLoader.vue"
import DismissedTray from "@/components/DismissedTray.vue"
import SlideOver from "@/components/SlideOver.vue"
import PromptBlock from "@/components/PromptBlock.vue"

const store = useSuggestionsStore()
const router = useRouter()
const format = new Intl.NumberFormat("en-US")

const selected = ref(null)

onMounted(() => store.load())

const subtitle = computed(() => {
  const account = store.account
  if (!account) return ""
  const parts = [
    `Built from ${format.format(account.list_size)} subscribed contacts and ${account.campaigns_sent} past campaigns.`
  ]
  if (account.last_send) {
    parts.push(`Last send was “${account.last_send.name}”, opened by ${account.last_send.open_rate}%.`)
  }
  return parts.join(" ")
})

async function draft(id) {
  const campaignId = await store.draft(id)
  if (campaignId) {
    selected.value = null
    router.push(`/campaigns/${campaignId}`)
  }
}
</script>

<template>
  <div class="mx-auto max-w-[1200px] px-6 py-12">
    <PageTitle eyebrow="Kestrel Supply Co." title="AI suggested campaigns">
      <template #subtitle>{{ subtitle }}</template>
      <template #actions>
        <!-- A utility rather than the point of the page, so it stays secondary.
             Brand orange lives on current navigation instead. -->
        <button
          type="button"
          class="button secondary"
          :disabled="store.rebuilding"
          @click="store.rebuild()"
        >
          {{ store.rebuilding ? "Rebuilding…" : "Rebuild from current data" }}
        </button>
      </template>
    </PageTitle>

    <div
      v-if="store.error"
      class="mb-6 rounded-lg bg-red-50 px-4 py-3 text-sm font-medium text-red-600 dark:bg-red-900/30 dark:text-red-400"
    >
      {{ store.error }}
    </div>

    <SkeletonLoader v-if="store.loading" :count="3" />

    <!-- An empty page is a real answer here, not a failure state. -->
    <NoDataPlaceholder
      v-else-if="store.quiet"
      title="Nothing worth sending today"
      body="No audience is large enough to justify a campaign yet. Import contacts or send something, and suggestions will appear as the numbers build up."
    />

    <div v-else class="flex flex-col gap-10">
      <CategorySection
        v-for="category in store.categories"
        :key="category.key"
        :category="category"
        :drafting-id="store.draftingId"
        @dismiss="store.dismiss($event)"
        @draft="draft($event)"
        @open="selected = $event"
      />
    </div>

    <DismissedTray
      v-if="!store.loading"
      class="mt-12"
      :dismissed="store.dismissed"
      @restore="store.restore($event)"
    />

    <SlideOver :show="!!selected" title="Suggested campaign" @close="selected = null">
      <template v-if="selected">
        <h2 class="text-lg font-semibold tracking-[-0.01em] text-default">{{ selected.title }}</h2>

        <dl class="mt-5 flex flex-col gap-4">
          <div>
            <dt class="eyebrow mb-1">What we found</dt>
            <dd class="text-sm text-default">{{ selected.headline_fact }}</dd>
          </div>
          <div>
            <dt class="eyebrow mb-1">Why now</dt>
            <dd class="text-sm text-muted">{{ selected.why_now }}</dd>
          </div>
          <div>
            <dt class="eyebrow mb-1">Angle</dt>
            <dd class="text-sm text-muted">{{ selected.proposed_angle }}</dd>
          </div>
          <div>
            <dt class="eyebrow mb-1">Subject</dt>
            <dd class="text-sm text-default">“{{ selected.proposed_subject }}”</dd>
          </div>
          <div>
            <dt class="eyebrow mb-1">Reach</dt>
            <dd class="text-sm text-default">
              {{ format.format(selected.estimated_reach) }} people
            </dd>
          </div>
        </dl>

        <div class="mt-6">
          <PromptBlock :prompt="selected.agent_prompt" />
        </div>
      </template>

      <template #footer>
        <!-- The one surface where a single primary action genuinely exists,
             so this is where brand orange belongs. -->
        <div class="flex items-center justify-between gap-3">
          <button
            type="button"
            class="button ghost"
            :disabled="store.draftingId === selected?.id"
            @click="store.dismiss(selected.id); selected = null"
          >
            Not this one
          </button>
          <button
            type="button"
            class="button primary"
            :disabled="store.draftingId === selected?.id"
            @click="draft(selected.id)"
          >
            {{ store.draftingId === selected?.id ? "Creating this campaign…" : "Draft this campaign" }}
          </button>
        </div>
      </template>
    </SlideOver>
  </div>
</template>
