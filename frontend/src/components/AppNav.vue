<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from "vue"
import { RouterLink, useRoute } from "vue-router"

const route = useRoute()

// Everything except "Suggested" belongs to the existing product. It renders as
// plain text rather than links so nothing offers an affordance it cannot honour.

const open = ref(false)
const dark = ref(false)
const copied = ref(false)

const connectCommand = computed(
  () => `claude mcp add --transport http nitrosend ${window.location.origin}/mcp`
)

async function copyCommand() {
  try {
    await navigator.clipboard.writeText(connectCommand.value)
    copied.value = true
    setTimeout(() => (copied.value = false), 2000)
  } catch (e) {
    copied.value = false
  }
}

function applyTheme(value) {
  dark.value = value
  document.documentElement.classList.toggle("dark", value)
  localStorage.setItem("nitrosend-theme", value ? "dark" : "light")
}

function onKeydown(event) {
  if (event.key === "Escape" && open.value) open.value = false
}

onMounted(() => {
  const saved = localStorage.getItem("nitrosend-theme")
  applyTheme(saved ? saved === "dark" : window.matchMedia("(prefers-color-scheme: dark)").matches)
  document.addEventListener("keydown", onKeydown)
})

onBeforeUnmount(() => document.removeEventListener("keydown", onKeydown))

const ICONS = {
  home: "M3 9.5 10 4l7 5.5V16a1 1 0 0 1-1 1h-3.5v-4.5h-5V17H4a1 1 0 0 1-1-1z",
  spark: "M10 2.5 11.9 8 17.5 10 11.9 12 10 17.5 8.1 12 2.5 10 8.1 8z",
  send: "M3.5 10 17 3.5 12.5 17 10 11.5z",
  flows: "M3 5h5v4H3zM12 11h5v4h-5zM8 7h2.5a1.5 1.5 0 0 1 1.5 1.5V13",
  templates: "M3 6.5 10 3l7 3.5-7 3.5zM3 10.5 10 14l7-3.5M3 14 10 17.5 17 14",
  inbox: "M3 11h4l1 2h4l1-2h4M3 11l2-6h10l2 6v5a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1z",
  outreach: "M4 8v4h3l5 3.5v-11L7 8zM15 8.5a3 3 0 0 1 0 3",
  activity: "M4 16V9M8.5 16V5M13 16v-4M17.5 16v-7",
  contacts: "M7.5 9a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5zM2.5 16c0-2.5 2.2-4 5-4s5 1.5 5 4M14 5.2a2.4 2.4 0 0 1 0 4.6M15 12.4c1.7.5 2.8 1.7 2.8 3.6",
  brand: "M5 3h6l4 4v10a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1zM11 3v4h4",
  integrations: "M8 3.5h4v3h3v4h-3v3H8v-3H5v-4h3z",
  learning: "M10 3.5 18 7l-8 3.5L2 7zM5.5 9v4.5c0 1.2 2 2.5 4.5 2.5s4.5-1.3 4.5-2.5V9"
}

const EXISTING = [
  { label: "Home", icon: "home" },
  { label: "Campaigns", icon: "send" },
  { label: "Flows", icon: "flows" },
  { label: "Templates", icon: "templates" },
  { label: "Inbox", icon: "inbox", badge: "Beta", tone: "red" },
  { label: "Outreach", icon: "outreach", badge: "Soon", tone: "gray" },
  { label: "Activity", icon: "activity" },
  { label: "Contacts", icon: "contacts" },
  { label: "Brand", icon: "brand" },
  { label: "Integrations", icon: "integrations" },
]

// Two working destinations now, so the current item is derived from the route
// rather than hardcoded.
const MINE = [
  { label: "Suggested", icon: "spark", to: "/", badge: "New", tone: "green" },
  { label: "Learning Center", icon: "learning", to: "/learning" }
]
</script>

<template>
  <button
    type="button"
    class="icon-button"
    aria-label="Open navigation"
    :aria-expanded="open"
    @click="open = true"
  >
    <svg viewBox="0 0 20 20" class="h-5 w-5" stroke="currentColor" stroke-width="1.6" fill="none">
      <path d="M3 6h14M3 10h14M3 14h14" stroke-linecap="round" />
    </svg>
  </button>

  <Transition
    enter-active-class="transition-opacity duration-200"
    enter-from-class="opacity-0"
    leave-active-class="transition-opacity duration-150"
    leave-to-class="opacity-0"
  >
    <div v-if="open" class="fixed inset-0 z-50 bg-stone-900/40" @click="open = false"></div>
  </Transition>

  <Transition
    enter-active-class="transition-transform duration-200 ease-out"
    enter-from-class="-translate-x-full"
    leave-active-class="transition-transform duration-150 ease-in"
    leave-to-class="-translate-x-full"
  >
    <nav
      v-if="open"
      class="fixed inset-y-0 left-0 z-51 flex w-full max-w-[420px] flex-col overflow-y-auto
             bg-surface px-5 py-5"
      aria-label="Primary"
    >
      <div class="mb-7 flex items-center justify-between">
        <!-- Two files rather than a filter: inverting would wreck the mark. -->
        <img src="/nitrosend-logo.png" alt="Nitrosend" class="h-6 w-auto dark:hidden" />
        <img src="/nitrosend-logo-dark.png" alt="Nitrosend" class="hidden h-6 w-auto dark:block" />

        <button
          type="button"
          class="icon-button"
          :aria-label="dark ? 'Switch to light mode' : 'Switch to dark mode'"
          @click="applyTheme(!dark)"
        >
          <svg viewBox="0 0 20 20" class="h-4 w-4" fill="currentColor" aria-hidden="true">
            <path v-if="dark" d="M17.29 12.79A8 8 0 0 1 7.21 2.71a8.001 8.001 0 1 0 10.08 10.08Z" />
            <path
              v-else
              d="M10 6a4 4 0 1 0 0 8 4 4 0 0 0 0-8Zm0-4a1 1 0 0 1 1 1v1a1 1 0 1 1-2 0V3a1 1 0 0 1 1-1Zm0 14a1 1 0 0 1 1 1v1a1 1 0 1 1-2 0v-1a1 1 0 0 1 1-1Zm8-6a1 1 0 0 1-1 1h-1a1 1 0 1 1 0-2h1a1 1 0 0 1 1 1ZM4 10a1 1 0 0 1-1 1H2a1 1 0 1 1 0-2h1a1 1 0 0 1 1 1Z"
            />
          </svg>
        </button>
      </div>

      <p class="eyebrow mb-2">This prototype</p>
      <ul class="flex flex-col gap-0.5">
        <li v-for="item in MINE" :key="item.label">
          <RouterLink
            :to="item.to"
            class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-[15px] font-medium transition-colors"
            :class="
              route.path === item.to
                ? 'bg-brand-50 text-brand-700 dark:bg-brand-950 dark:text-brand-400'
                : 'text-default hover:bg-surface-hover'
            "
            :aria-current="route.path === item.to ? 'page' : undefined"
            @click="open = false"
          >
            <svg
              viewBox="0 0 20 20"
              class="h-5 w-5 shrink-0"
              :class="route.path === item.to ? 'text-brand-500' : 'text-muted'"
              fill="none"
              stroke="currentColor"
              stroke-width="1.5"
              stroke-linejoin="round"
              stroke-linecap="round"
            >
              <path :d="ICONS[item.icon]" />
            </svg>
            {{ item.label }}
            <span v-if="item.badge" class="badge ml-auto" :class="item.tone">{{ item.badge }}</span>
          </RouterLink>
        </li>
      </ul>

      <div class="mt-6 mb-2 flex items-baseline justify-between gap-3">
        <p class="eyebrow">Existing Nitrosend</p>
        <span class="meta-quiet">not wired up</span>
      </div>

      <ul class="flex flex-col gap-0.5">
        <li
          v-for="item in EXISTING"
          :key="item.label"
          class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-[15px] font-medium text-subtle"
        >
          <svg
            viewBox="0 0 20 20"
            class="h-5 w-5 shrink-0"
            fill="none"
            stroke="currentColor"
            stroke-width="1.5"
            stroke-linejoin="round"
            stroke-linecap="round"
          >
            <path :d="ICONS[item.icon]" />
          </svg>
          {{ item.label }}
          <span v-if="item.badge" class="badge ml-auto" :class="item.tone">{{ item.badge }}</span>
        </li>
      </ul>

      <p class="mt-5 text-[13px] text-subtle">
        Only the two above are new work. The rest is Nitrosend as it ships today.
      </p>

      <div class="well well--sunken mt-auto p-4">
        <span class="badge brand mb-2.5">Connect your agent</span>

        <p class="mb-3 text-[13px] text-muted">
          The same suggestions are available over MCP. There is a short guide in the
          <RouterLink to="/learning" class="font-medium text-brand-700 underline decoration-border underline-offset-2 dark:text-brand-400" @click="open = false">Learning Center</RouterLink>.
        </p>

        <div class="rounded-lg bg-surface p-3">
          <div class="mb-1.5 flex items-center justify-between gap-2">
            <span class="eyebrow">Paste into your terminal</span>
            <button type="button" class="button ghost xs" @click="copyCommand">
              {{ copied ? "Copied" : "Copy" }}
            </button>
          </div>
          <code class="block font-mono text-[11px] leading-relaxed break-all text-muted">
            {{ connectCommand }}
          </code>
        </div>

        <p class="mt-2.5 text-[11px] text-subtle">
          Claude Code, Claude Desktop, or any MCP client.
        </p>
      </div>
    </nav>
  </Transition>
</template>
