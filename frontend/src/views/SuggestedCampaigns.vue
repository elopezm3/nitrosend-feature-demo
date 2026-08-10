<script setup>
import { onMounted, computed } from "vue"
import { useSuggestionsStore } from "@/stores/suggestions"
import PageTitle from "@/components/PageTitle.vue"
import CategorySection from "@/components/CategorySection.vue"
import NoDataPlaceholder from "@/components/NoDataPlaceholder.vue"
import SkeletonLoader from "@/components/SkeletonLoader.vue"

const store = useSuggestionsStore()
const format = new Intl.NumberFormat("en-US")

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
</script>

<template>
  <div class="container mx-auto max-w-[1200px] px-6 py-12">
    <PageTitle eyebrow="Kestrel Supply Co." title="AI suggested campaigns">
      <template #subtitle>{{ subtitle }}</template>
      <template #actions>
        <!-- A utility, not the point of the page — so it stays secondary.
             See the note in App.vue about where brand orange belongs here. -->
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

    <div v-if="store.error" class="mb-6 rounded-lg bg-red-50 px-4 py-3 text-sm font-medium text-red-600 dark:bg-red-900/30 dark:text-red-400">
      {{ store.error }}
    </div>

    <SkeletonLoader v-if="store.loading" :count="3" />

    <!-- An empty page is a real answer here, not a failure state. Some days
         the correct recommendation is to send nothing at all. -->
    <NoDataPlaceholder
      v-else-if="store.quiet"
      title="Nothing worth sending today"
      body="No audience has moved enough, or is large enough, to justify a campaign. Sending anyway spends attention you will want later."
    />

    <div v-else class="flex flex-col gap-10">
      <CategorySection
        v-for="category in store.withSuggestions"
        :key="category.key"
        :category="category"
        @dismiss="store.dismiss($event)"
      />
    </div>
  </div>
</template>
