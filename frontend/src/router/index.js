import { createRouter, createWebHistory } from "vue-router"
import SuggestedCampaigns from "@/views/SuggestedCampaigns.vue"
import CampaignShow from "@/views/CampaignShow.vue"
import LearningCenter from "@/views/LearningCenter.vue"

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: "/", name: "suggestions", component: SuggestedCampaigns,
      meta: { title: "AI suggested campaigns" } },
    { path: "/campaigns/:id", name: "campaign", component: CampaignShow, props: true,
      meta: { title: "Campaign" } },
    { path: "/learning", name: "learning", component: LearningCenter,
      meta: { title: "Learning Center" } }
  ],
  scrollBehavior: () => ({ top: 0 })
})

router.afterEach((to) => {
  document.title = `${to.meta.title ?? "Nitrosend"} · Nitrosend`
})

export default router
