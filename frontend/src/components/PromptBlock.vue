<script setup>
import { ref } from "vue"

defineProps({ prompt: { type: String, required: true } })

const copied = ref(false)
let timer = null

async function copy(text) {
  try {
    await navigator.clipboard.writeText(text)
  } catch (e) {
    // Clipboard access can be refused. Fall back to selecting the text so the
    // reader can still copy it by hand rather than hitting a dead control.
    const range = document.createRange()
    range.selectNodeContents(document.getElementById("agent-prompt"))
    const selection = window.getSelection()
    selection.removeAllRanges()
    selection.addRange(range)
  }
  copied.value = true
  clearTimeout(timer)
  timer = setTimeout(() => (copied.value = false), 2000)
}
</script>

<template>
  <div class="well well--sunken p-4">
    <div class="mb-2.5 flex items-center justify-between gap-3">
      <p class="eyebrow">Handed to your agent</p>
      <button type="button" class="button ghost xs" @click="copy(prompt)">
        {{ copied ? "Copied" : "Copy" }}
      </button>
    </div>
    <pre
      id="agent-prompt"
      class="font-mono text-xs leading-relaxed whitespace-pre-wrap text-muted"
    >{{ prompt }}</pre>
  </div>
</template>
