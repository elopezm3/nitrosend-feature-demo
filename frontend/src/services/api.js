import axios from "axios"

// Vite proxies /api to Rails on :3000 in development, so the browser stays on
// a single origin and no CORS handling is needed.
const client = axios.create({
  baseURL: "/api",
  headers: { Accept: "application/json" }
})

export default {
  suggestions: () => client.get("/suggestions").then((r) => r.data),
  dismiss: (id) => client.patch(`/suggestions/${id}/dismiss`),
  regenerate: () => client.post("/suggestions/regenerate").then((r) => r.data)
}
