<script setup>
// DESIGN.md §5: the ambient aurora backdrop is the DEFAULT canvas for every
// dashboard page, with no per-route opt-in, and runs at reduced opacity in
// dark mode. The product ships a static webp; this is a CSS approximation.
//
// The rules live in main.css rather than a scoped block here. A scoped
// `:global(.dark) .aurora` did not win over the base rule, so the page kept
// painting its light gradient under dark-mode text. Unscoped CSS keeps the
// selectors predictable.
</script>

<template>
  <div class="aurora" aria-hidden="true"></div>
</template>
