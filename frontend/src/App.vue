<script setup>
import { RouterView } from "vue-router"
import AuroraBackdrop from "@/components/AuroraBackdrop.vue"
</script>

<template>
  <AuroraBackdrop />

  <main class="min-h-screen">
    <RouterView />
  </main>
</template>
