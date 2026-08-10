<script setup>
import { computed } from "vue"
import PageTitle from "@/components/PageTitle.vue"
import AppNav from "@/components/AppNav.vue"
import CopyCommand from "@/components/CopyCommand.vue"

const connectCommand = computed(
  () => `claude mcp add --transport http nitrosend ${window.location.origin}/mcp`
)

// The order carries meaning here: each step depends on the one before it.
const STEPS = [
  {
    ask: "What can I send today?",
    body: "Returns the five audiences. Each states the rule used to select it, how " +
          "many people it holds, and the measured fact behind the recommendation, " +
          "plus the other angles held back for that audience."
  },
  {
    ask: "Draft the one for slipping away",
    body: "Creates a real draft campaign and closes that audience, because one " +
          "campaign per audience is the point. You can draft a held-back angle " +
          "directly; there is no need to dismiss your way down to it."
  },
  {
    ask: "Send it",
    body: "It will not, and it will tell you why. Drafting is where this stops. " +
          "Sending is a separate approval a person performs in Nitrosend after " +
          "reviewing the audience and the copy, so there is deliberately no tool " +
          "here that can send.",
    emphasis: true
  },
  {
    ask: "Not that one",
    body: "Dismisses the recommendation and promotes the next angle. Dismissing is " +
          "permanent, so it is for rejecting an idea rather than browsing."
  }
]

const TOOLS = [
  [ "nitro_suggest_campaigns", "What is worth sending today, one recommendation per audience." ],
  [ "nitro_dismiss_suggestion", "Turn down an angle; the next one is promoted." ],
  [ "nitro_draft_campaign", "Accept an angle and create the draft." ]
]
</script>

<template>
  <div class="mx-auto max-w-[1200px] px-6 pt-4 pb-20">
    <PageTitle eyebrow="Learning Center" title="Suggested campaigns over MCP">
      <template #lead><AppNav /></template>
      <template #subtitle>
        The same suggestions are available to any MCP client, so you can ask what
        to send without opening this page.
      </template>
    </PageTitle>

    <div class="grid gap-5 lg:grid-cols-[minmax(0,1fr)_320px]">
      <div class="flex flex-col gap-5">
        <section class="card">
          <div class="card-header">
            <h2 class="card-title">1. Connect</h2>
            <p class="card-subtitle mt-1">
              Claude Code, Claude Desktop, or any MCP client. No account, no key.
            </p>
          </div>
          <div class="card-body">
            <CopyCommand :command="connectCommand" />
          </div>
        </section>

        <section class="card">
          <div class="card-header">
            <h2 class="card-title">2. Ask it things</h2>
            <p class="card-subtitle mt-1">Four worth trying, in order.</p>
          </div>
          <div class="card-body flex flex-col gap-4">
            <div
              v-for="step in STEPS"
              :key="step.ask"
              class="well well--sunken p-4"
              :class="step.emphasis ? 'border-border-strong' : ''"
            >
              <p class="mb-1.5 font-mono text-[13px] text-default">“{{ step.ask }}”</p>
              <p class="text-sm text-muted">{{ step.body }}</p>
            </div>
          </div>
        </section>
      </div>

      <aside class="flex flex-col gap-5">
        <section class="card">
          <div class="card-header">
            <h2 class="card-title text-sm">The three tools</h2>
          </div>
          <div class="card-body flex flex-col gap-3">
            <div v-for="[name, what] in TOOLS" :key="name">
              <p class="font-mono text-[12px] text-default">{{ name }}</p>
              <p class="mt-0.5 text-[13px] text-muted">{{ what }}</p>
            </div>
          </div>
        </section>

        <section class="well well--sunken p-4">
          <p class="eyebrow mb-1.5">Nothing here sends</p>
          <p class="text-[13px] text-muted">
            Every tool stops at a draft. That is not a limitation of the demo: Nitrosend
            already separates composing from approving, and a suggestion that could send
            itself would skip a gate the product deliberately has.
          </p>
        </section>
      </aside>
    </div>
  </div>
</template>
