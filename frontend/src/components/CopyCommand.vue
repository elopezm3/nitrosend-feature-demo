<script setup>
import { ref } from "vue"

defineProps({
  command: { type: String, required: true },
  label: { type: String, default: "Paste into your terminal" }
})

const copied = ref(false)
let timer = null

async function copy(text) {
  try {
    await navigator.clipboard.writeText(text)
    copied.value = true
    clearTimeout(timer)
    timer = setTimeout(() => (copied.value = false), 2000)
  } catch (e) {
    copied.value = false
  }
}
</script>

<template>
  <div class="rounded-lg border border-border bg-surface p-3">
    <div class="mb-1.5 flex items-center justify-between gap-2">
      <span class="eyebrow">{{ label }}</span>
      <button type="button" class="button ghost xs" @click="copy(command)">
        {{ copied ? "Copied" : "Copy" }}
      </button>
    </div>
    <code class="block font-mono text-[11.5px] leading-relaxed break-all text-muted">{{ command }}</code>
  </div>
</template>
