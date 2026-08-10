<script setup>
import { ref, onMounted } from "vue"
import { RouterLink } from "vue-router"
import api from "@/services/api"
import AppNav from "@/components/AppNav.vue"

const props = defineProps({ id: { type: String, required: true } })

const campaign = ref(null)
const loading = ref(true)
const error = ref(null)

onMounted(async () => {
  try {
    campaign.value = await api.campaign(props.id)
  } catch (e) {
    error.value = "Could not load that campaign."
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="mx-auto max-w-[1200px] px-6 pt-6 pb-20">
    <RouterLink
      to="/"
      class="mb-5 inline-flex items-center gap-1.5 text-sm text-muted hover:text-default"
    >
      <svg viewBox="0 0 20 20" class="h-3.5 w-3.5" fill="currentColor" aria-hidden="true">
        <path d="M13 4l-6 6 6 6z" />
      </svg>
      Back to suggestions
    </RouterLink>

    <div v-if="loading" class="card p-6">
      <div class="skeleton-line mb-3 h-5 w-1/3 rounded"></div>
      <div class="skeleton-line h-3 w-2/3 rounded"></div>
    </div>

    <div
      v-else-if="error"
      class="rounded-lg bg-red-50 px-4 py-3 text-sm font-medium text-red-600 dark:bg-red-900/30 dark:text-red-400"
    >
      {{ error }}
    </div>

    <div v-else class="flex flex-col gap-5">
      <header class="flex items-start gap-3">
        <div class="pt-1.5">
          <AppNav />
        </div>
        <div class="min-w-0">
          <div class="mb-1.5 flex items-center gap-2.5">
            <p class="eyebrow">Campaign</p>
            <span class="badge yellow">Draft</span>
          </div>
          <h1 class="text-[34px] font-bold leading-[1.1] tracking-[-0.025em] text-default">
            {{ campaign.name }}
          </h1>
        </div>
      </header>

      <div class="card">
        <div class="card-header">
          <dl class="grid grid-cols-1 gap-x-8 gap-y-4 sm:grid-cols-2">
            <div>
              <dt class="eyebrow mb-1">Subject</dt>
              <dd class="text-sm text-default">“{{ campaign.subject }}”</dd>
            </div>
            <div>
              <dt class="eyebrow mb-1">Audience</dt>
              <dd class="text-sm text-default">{{ campaign.audience_label }}</dd>
            </div>
            <div>
              <dt class="eyebrow mb-1">From</dt>
              <dd class="text-sm text-default">
                {{ campaign.from_name }}
                <span class="text-muted">&lt;{{ campaign.from_email }}&gt;</span>
              </dd>
            </div>
            <div v-if="campaign.source">
              <dt class="eyebrow mb-1">Created from</dt>
              <dd class="text-sm text-default">{{ campaign.source.title }}</dd>
            </div>
          </dl>
        </div>
      </div>

      <!-- Deliberately a placeholder. Everything past this point is Nitrosend's
           existing campaign surface, and reimplementing it would say nothing
           about the feature being proposed. -->
      <div
        class="flex min-h-[280px] items-center justify-center rounded-xl border border-dashed border-border-strong px-6 py-12 text-center"
      >
        <div>
          <p class="font-mono text-sm text-muted">
            Nitrosend campaign show page with the campaign created
          </p>
          <p class="mx-auto mt-2 max-w-[42ch] text-xs text-subtle">
            The editor, preview, audience picker and send controls already exist
            in the product. This demo stops where the new work ends.
          </p>
        </div>
      </div>
    </div>
  </div>
</template>
