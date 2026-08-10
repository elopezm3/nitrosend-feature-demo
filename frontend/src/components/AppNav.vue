<script setup>
import { ref, onMounted, onBeforeUnmount } from "vue"

// The product's primary navigation is a slide-out drawer behind a hamburger,
// with a dimmed backdrop. The current item is a soft brand-tinted pill, brand
// text and brand icon together, which is the treatment DESIGN.md §2 sanctions
// for current app navigation.

const open = ref(false)
const dark = ref(false)

function applyTheme(value) {
  dark.value = value
  document.documentElement.classList.toggle("dark", value)
  localStorage.setItem("nitrosend-theme", value ? "dark" : "light")
}

function onKeydown(event) {
  if (event.key === "Escape" && open.value) {
    open.value = false
    return
  }
  // The drawer's own search shortcut, matching the "/" hint the product shows.
  if (event.key === "/" && !open.value) {
    const tag = document.activeElement?.tagName
    if (tag === "INPUT" || tag === "TEXTAREA") return
    event.preventDefault()
    open.value = true
  }
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

const PRIMARY = [
  { label: "Home", icon: "home" },
  { label: "Suggested", icon: "spark", current: true, badge: "New", tone: "green" },
  { label: "Campaigns", icon: "send" },
  { label: "Flows", icon: "flows" },
  { label: "Templates", icon: "templates" },
  { label: "Inbox", icon: "inbox", badge: "Beta", tone: "red" },
  { label: "Outreach", icon: "outreach", badge: "Soon", tone: "gray" },
  { label: "Activity", icon: "activity" },
  { label: "Contacts", icon: "contacts" }
]

const SECONDARY = [
  { label: "Brand", icon: "brand" },
  { label: "Integrations", icon: "integrations" },
  { label: "Learning Center", icon: "learning" }
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
      <div class="mb-6 flex items-center justify-between">
        <span class="text-[19px] font-semibold tracking-[-0.02em] text-default">
          <span class="text-brand-500">◗</span> nitrosend
        </span>
        <button
          type="button"
          class="icon-button"
          :aria-label="dark ? 'Switch to light mode' : 'Switch to dark mode'"
          @click="applyTheme(!dark)"
        >
          <svg viewBox="0 0 20 20" class="h-4 w-4" fill="currentColor" aria-hidden="true">
            <path
              v-if="dark"
              d="M17.29 12.79A8 8 0 0 1 7.21 2.71a8.001 8.001 0 1 0 10.08 10.08Z"
            />
            <path
              v-else
              d="M10 6a4 4 0 1 0 0 8 4 4 0 0 0 0-8Zm0-4a1 1 0 0 1 1 1v1a1 1 0 1 1-2 0V3a1 1 0 0 1 1-1Zm0 14a1 1 0 0 1 1 1v1a1 1 0 1 1-2 0v-1a1 1 0 0 1 1-1Zm8-6a1 1 0 0 1-1 1h-1a1 1 0 1 1 0-2h1a1 1 0 0 1 1 1ZM4 10a1 1 0 0 1-1 1H2a1 1 0 1 1 0-2h1a1 1 0 0 1 1 1Z"
            />
          </svg>
        </button>
      </div>

      <label class="mb-5 flex items-center gap-2 text-sm text-subtle">
        <span class="sr-only">Search</span>
        <input
          type="search"
          placeholder="Search…"
          class="w-full bg-transparent text-[15px] text-default placeholder:text-subtle focus:outline-none"
        />
        <span class="kbd">/</span>
      </label>

      <ul class="flex flex-col gap-0.5">
        <li v-for="item in PRIMARY" :key="item.label">
          <a
            href="#"
            class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-[15px] font-medium transition-colors"
            :class="
              item.current
                ? 'bg-brand-50 text-brand-700 dark:bg-brand-950 dark:text-brand-400'
                : 'text-default hover:bg-surface-hover'
            "
            :aria-current="item.current ? 'page' : undefined"
            @click.prevent="open = false"
          >
            <svg
              viewBox="0 0 20 20"
              class="h-5 w-5 shrink-0"
              :class="item.current ? 'text-brand-500' : 'text-muted'"
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
          </a>
        </li>
      </ul>

      <hr class="my-4 border-0 border-t border-border" />

      <ul class="flex flex-col gap-0.5">
        <li v-for="item in SECONDARY" :key="item.label">
          <a
            href="#"
            class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-[15px] font-medium
                   text-default transition-colors hover:bg-surface-hover"
            @click.prevent="open = false"
          >
            <svg
              viewBox="0 0 20 20"
              class="h-5 w-5 shrink-0 text-muted"
              fill="none"
              stroke="currentColor"
              stroke-width="1.5"
              stroke-linejoin="round"
              stroke-linecap="round"
            >
              <path :d="ICONS[item.icon]" />
            </svg>
            {{ item.label }}
          </a>
        </li>
      </ul>

      <div class="well well--sunken mt-auto p-4">
        <p class="mb-1 text-sm font-semibold text-brand-700 dark:text-brand-400">
          Connect your agent
        </p>
        <p class="text-[13px] text-muted">
          Connect Nitrosend to your AI agent for the full experience.
        </p>
      </div>
    </nav>
  </Transition>
</template>
