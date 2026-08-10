<script setup>
import { onMounted, onBeforeUnmount, watch, nextTick, ref } from "vue"

// DESIGN.md §5: a record detail drawer. Overlays from the true window right,
// backdrop off by default, border-l edge, and it never compresses the page
// content behind it.
const props = defineProps({
  show: { type: Boolean, default: false },
  title: { type: String, default: "" }
})

const emit = defineEmits(["close"])
const panel = ref(null)

function onKeydown(event) {
  if (event.key === "Escape" && props.show) emit("close")
}

onMounted(() => document.addEventListener("keydown", onKeydown))
onBeforeUnmount(() => document.removeEventListener("keydown", onKeydown))

watch(
  () => props.show,
  async (open) => {
    if (!open) return
    await nextTick()
    panel.value?.focus()
  }
)
</script>

<template>
  <Transition
    enter-active-class="transition-transform duration-200 ease-out"
    enter-from-class="translate-x-full"
    leave-active-class="transition-transform duration-150 ease-in"
    leave-to-class="translate-x-full"
  >
    <aside
      v-if="show"
      ref="panel"
      class="fixed inset-y-0 right-0 z-50 flex w-full max-w-[440px] flex-col
             border-l border-border bg-surface-raised shadow-xl outline-none"
      role="dialog"
      aria-modal="false"
      :aria-label="title"
      tabindex="-1"
    >
      <header class="flex items-start justify-between gap-4 border-b border-border px-5 py-4">
        <p class="eyebrow pt-1">{{ title }}</p>
        <button type="button" class="icon-button -mr-1.5 -mt-1" aria-label="Close" @click="emit('close')">
          <svg viewBox="0 0 20 20" class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="1.6">
            <path d="M5 5l10 10M15 5L5 15" stroke-linecap="round" />
          </svg>
        </button>
      </header>

      <div class="flex-1 overflow-y-auto px-5 py-5">
        <slot />
      </div>

      <footer v-if="$slots.footer" class="border-t border-border px-5 py-4">
        <slot name="footer" />
      </footer>
    </aside>
  </Transition>
</template>
