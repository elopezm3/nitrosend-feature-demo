import { defineStore } from "pinia"
import { ref, computed } from "vue"
import api from "@/services/api"

export const useSuggestionsStore = defineStore("suggestions", () => {
  const account = ref(null)
  const categories = ref([])
  const loading = ref(false)
  const rebuilding = ref(false)
  const error = ref(null)

  // Categories with nothing to suggest are still real audiences — they just
  // have no advice attached today, so they do not earn space on the page.
  const withSuggestions = computed(() =>
    categories.value.filter((category) => category.suggestions.length > 0)
  )

  const quiet = computed(
    () => !loading.value && !error.value && withSuggestions.value.length === 0
  )

  const total = computed(() =>
    categories.value.reduce((sum, category) => sum + category.suggestions.length, 0)
  )

  function absorb(data) {
    account.value = data.account
    categories.value = data.categories
  }

  async function load() {
    loading.value = true
    error.value = null
    try {
      absorb(await api.suggestions())
    } catch (e) {
      error.value = "Could not reach the suggestions service."
    } finally {
      loading.value = false
    }
  }

  async function rebuild() {
    rebuilding.value = true
    error.value = null
    try {
      absorb(await api.regenerate())
    } catch (e) {
      error.value = "Could not rebuild suggestions."
    } finally {
      rebuilding.value = false
    }
  }

  async function dismiss(id) {
    // Remove it locally first so the page responds immediately, then reconcile.
    const previous = categories.value
    categories.value = categories.value.map((category) => ({
      ...category,
      suggestions: category.suggestions.filter((s) => s.id !== id)
    }))

    try {
      await api.dismiss(id)
    } catch (e) {
      categories.value = previous
      error.value = "Could not dismiss that suggestion."
    }
  }

  return {
    account, categories, loading, rebuilding, error,
    withSuggestions, quiet, total,
    load, rebuild, dismiss
  }
})
