<script setup>
import { ref, onMounted } from "vue"
import SuggestedCampaigns from "@/views/SuggestedCampaigns.vue"

// DESIGN.md §9: dark mode is class-based, toggled by .dark on <html>.
const dark = ref(false)

function apply(value) {
  dark.value = value
  document.documentElement.classList.toggle("dark", value)
  localStorage.setItem("nitrosend-theme", value ? "dark" : "light")
}

onMounted(() => {
  const saved = localStorage.getItem("nitrosend-theme")
  apply(saved ? saved === "dark" : window.matchMedia("(prefers-color-scheme: dark)").matches)
})

// DESIGN.md §2: brand orange marks current app navigation. It is the only
// place it appears on this screen — a list of five equally-weighted options
// has no single primary action, and inventing one would be the design error.
const NAV = [
  { label: "Campaigns", current: false },
  { label: "Flows", current: false },
  { label: "Contacts", current: false },
  { label: "Suggested", current: true }
]
</script>

<template>
  <div class="min-h-screen bg-page-tint">
    <header class="border-b border-border bg-surface">
      <div class="mx-auto flex max-w-[1200px] items-center gap-8 px-6">
        <span class="py-3.5 font-mono text-xs font-medium tracking-[0.18em] uppercase text-default">
          Nitrosend
        </span>

        <nav class="flex items-center gap-1" aria-label="Primary">
          <a
            v-for="item in NAV"
            :key="item.label"
            href="#"
            class="-mb-px border-b-2 px-3 py-3.5 text-sm font-medium transition-colors"
            :class="
              item.current
                ? 'border-brand-500 text-brand-700 dark:text-brand-400'
                : 'border-transparent text-muted hover:text-default'
            "
            :aria-current="item.current ? 'page' : undefined"
          >
            {{ item.label }}
          </a>
        </nav>

        <button
          type="button"
          class="icon-button ml-auto"
          :aria-label="dark ? 'Switch to light mode' : 'Switch to dark mode'"
          @click="apply(!dark)"
        >
          <svg v-if="dark" viewBox="0 0 20 20" class="h-4 w-4" fill="currentColor" aria-hidden="true">
            <path d="M10 2a1 1 0 0 1 1 1v1a1 1 0 1 1-2 0V3a1 1 0 0 1 1-1Zm0 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8Zm7-4a1 1 0 0 1-1 1h-1a1 1 0 1 1 0-2h1a1 1 0 0 1 1 1ZM5 10a1 1 0 0 1-1 1H3a1 1 0 1 1 0-2h1a1 1 0 0 1 1 1Zm.64-5.36a1 1 0 0 1 1.41 0l.71.7a1 1 0 0 1-1.41 1.42l-.71-.71a1 1 0 0 1 0-1.41Zm7.6 7.6a1 1 0 0 1 1.41 0l.71.71a1 1 0 0 1-1.41 1.41l-.71-.71a1 1 0 0 1 0-1.41Zm2.12-7.6a1 1 0 0 1 0 1.41l-.71.71a1 1 0 1 1-1.41-1.42l.71-.7a1 1 0 0 1 1.41 0Zm-7.6 7.6a1 1 0 0 1 0 1.41l-.71.71a1 1 0 0 1-1.41-1.41l.71-.71a1 1 0 0 1 1.41 0ZM10 16a1 1 0 0 1 1 1v1a1 1 0 1 1-2 0v-1a1 1 0 0 1 1-1Z" />
          </svg>
          <svg v-else viewBox="0 0 20 20" class="h-4 w-4" fill="currentColor" aria-hidden="true">
            <path d="M17.29 12.79A8 8 0 0 1 7.21 2.71a8.001 8.001 0 1 0 10.08 10.08Z" />
          </svg>
        </button>
      </div>
    </header>

    <main>
      <SuggestedCampaigns />
    </main>
  </div>
</template>
