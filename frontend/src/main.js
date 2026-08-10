import { createApp } from "vue"
import { createPinia } from "pinia"
import "inter-ui/inter-variable-latin.css"
import "@/assets/main.css"
import App from "./App.vue"
import router from "./router"

createApp(App).use(createPinia()).use(router).mount("#app")
