import { createRouter, createWebHistory } from "vue-router"
import SuggestedCampaigns from "@/views/SuggestedCampaigns.vue"
import CampaignShow from "@/views/CampaignShow.vue"

export default createRouter({
  history: createWebHistory(),
  routes: [
    { path: "/", name: "suggestions", component: SuggestedCampaigns },
    { path: "/campaigns/:id", name: "campaign", component: CampaignShow, props: true }
  ],
  scrollBehavior: () => ({ top: 0 })
})
