import { defineStore } from "pinia"
import { ref, computed } from "vue"
import api from "@/services/api"

// A creation that resolves in 20ms and yanks you to another screen reads as a
// glitch rather than a transition. This holds the "Creating this campaign"
// state on screen long enough to be legible. It does not fake work, it only
// stops a real result from flashing past.
const MIN_VISIBLE_MS = 650

async function atLeast(ms, work) {
  const [result] = await Promise.all([
    work,
    new Promise((resolve) => setTimeout(resolve, ms))
  ])
  return result
}

export const useSuggestionsStore = defineStore("suggestions", () => {
  const account = ref(null)
  const categories = ref([])
  const dismissed = ref([])
  const loading = ref(false)
  const rebuilding = ref(false)
  const draftingId = ref(null)
  const error = ref(null)

  // Exhausted audiences stay on the page, so the only genuinely empty case is
  // having no audience worth showing at all.
  const quiet = computed(
    () => !loading.value && !error.value && categories.value.length === 0
  )

  function absorb(data) {
    account.value = data.account
    categories.value = data.categories
    dismissed.value = data.dismissed ?? []
  }

  async function run(flag, work, message) {
    if (flag) flag.value = true
    error.value = null
    try {
      absorb(await work())
    } catch (e) {
      error.value = message
    } finally {
      if (flag) flag.value = false
    }
  }

  const load = () => run(loading, api.suggestions, "Could not reach the suggestions service.")
  const rebuild = () => run(rebuilding, api.regenerate, "Could not rebuild suggestions.")
  const dismiss = (id) => run(null, () => api.dismiss(id), "Could not dismiss that suggestion.")
  const restore = (id) => run(null, () => api.restore(id), "Could not bring that suggestion back.")

  // Returns the new campaign id so the caller can navigate to it.
  async function draft(id) {
    draftingId.value = id
    error.value = null
    try {
      const { campaign_id } = await atLeast(MIN_VISIBLE_MS, api.draft(id))
      return campaign_id
    } catch (e) {
      error.value = "Could not create that campaign."
      return null
    } finally {
      draftingId.value = null
    }
  }

  return {
    account, categories, dismissed, loading, rebuilding, draftingId, error,
    quiet,
    load, rebuild, dismiss, restore, draft
  }
})
