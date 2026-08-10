<script setup>
import { ref } from "vue"

defineProps({ dismissed: { type: Array, required: true } })
defineEmits(["restore"])

const expanded = ref(false)
</script>

<template>
  <section v-if="dismissed.length" class="border-t border-border pt-5">
    <button
      type="button"
      class="flex items-center gap-2 text-xs text-muted hover:text-default"
      :aria-expanded="expanded"
      @click="expanded = !expanded"
    >
      <svg
        viewBox="0 0 20 20"
        class="h-3 w-3 transition-transform"
        :class="expanded ? 'rotate-90' : ''"
        fill="currentColor"
        aria-hidden="true"
      >
        <path d="M7 4l6 6-6 6z" />
      </svg>
      {{ dismissed.length }} suggestion{{ dismissed.length === 1 ? "" : "s" }} dismissed
    </button>

    <ul v-if="expanded" class="mt-3 flex flex-col gap-1.5">
      <li
        v-for="item in dismissed"
        :key="item.id"
        class="flex flex-wrap items-center justify-between gap-3 rounded-lg bg-surface-sunken px-3.5 py-2.5"
      >
        <span class="text-sm text-muted">
          <span class="text-subtle">{{ item.label }}</span>
          &nbsp;{{ item.title }}
        </span>
        <button type="button" class="button ghost xs" @click="$emit('restore', item.id)">
          Bring it back
        </button>
      </li>
    </ul>
  </section>
</template>
