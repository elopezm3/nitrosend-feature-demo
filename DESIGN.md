# Nitrosend SPA — DESIGN.md

Source of truth for the Nitrosend Vue 3 SPA's visual system. Follow this file when generating new UI, refactoring components, or wiring tokens. The implementation is **Tailwind CSS 4** (CSS-first config) — there is no `tailwind.config.js`; tokens live in [`src/assets/theme.css`](src/assets/theme.css) under `@theme`.

Scope: **product UI only** (SPA + dashboard). Per-account customer brand rendering (email templates, marketing forms) is out of scope and uses the `Brand` model's runtime tokens instead.

---

## 1. Visual Theme & Atmosphere

**Tone:** confident, energetic, editorial. A warm-orange accent against warm-stone neutrals in light mode; cool-dark surfaces with alpha-on-dark borders in dark mode (Linear/Vercel/Stripe convention).

**Density:** medium. 15px base font, generous form-row spacing (`gap-y-6`), inputs at 2.5rem default height. Not a high-density admin tool; not a marketing landing page.

**Posture:** purposeful and decisive. Solid brand-color CTAs, single primary action per surface, soft secondary actions, subtle tertiary actions. Avoid neutral-gray CTAs.

**Mood adjectives:** *warm, fast, professional, opinionated*. Avoid: cold, corporate, generic-SaaS, decorative.

---

## 2. Color Palette & Roles

All tokens live in [`src/assets/theme.css`](src/assets/theme.css) under `@theme`. Reference via Tailwind utilities (`bg-brand-500`, `text-default`, `ring-border`, etc.) — **never hardcode hex values in components.**

### Brand (warm orange)

| Token | Light | Role |
|---|---|---|
| `--color-brand-50` | `#FFF5F0` | Tinted background for soft buttons, active states |
| `--color-brand-100` | `#FFE6D9` | Hover tint for soft buttons |
| `--color-brand-500` | `#FF4D00` | Primary brand mark, solid CTA bg |
| `--color-brand-600` | `#CC3D00` | Primary action default (used by `.button.primary`) |
| `--color-brand-700` | `#992E00` | Active text on tinted bg |
| `--color-brand-950` | `#1A0800` | Dark-mode soft-button bg |

The full 50–950 scale is defined. `--color-brand` (no shade) aliases to `#FF4D00`.

### Surface (light → dark adaptive)

| Token | Light | Dark | Role |
|---|---|---|---|
| `--color-surface` | `#ffffff` | `#111113` | Default page/card bg |
| `--color-surface-raised` | `#ffffff` | `#1A1A1E` | Modals, popovers, elevated cards |
| `--color-surface-sunken` | `#f5f3ef` | `#08080A` | Section bg, recessed wells, inactive segments |
| `--color-surface-overlay` | `#ffffff` | `#1A1A1E` | Overlays sitting above raised surface |
| `--color-surface-hover` | `#efece9` | `#232228` | Row/menu/control hover |
| `--color-page-tint` | `#F6F3F1` | `#0D0A08` | Page-level warm wash behind cards |

### Foreground (text)

| Token | Light | Dark | Role |
|---|---|---|---|
| `--color-foreground` | `#1c1917` (stone-900) | `#E8E6EC` | Primary text |
| `--color-muted` | `#78716c` (stone-500) | `#8E8B96` | Secondary text, helpers, captions |
| `--color-subtle` | `#a8a29e` (stone-400) | `#64616D` | Placeholders, icon defaults, disabled-like |
| `--color-default` | `#1c1917` | `#F5F3F7` | Body default (set on `html`) |

### Borders & dividers

| Token | Light | Dark | Role |
|---|---|---|---|
| `--color-border` | `#e7e5e4` (stone-200) | `rgba(255,255,255,0.08)` | Default border |
| `--color-border-strong` | `#d6d3d1` (stone-300) | `rgba(255,255,255,0.14)` | Input borders, hover-emphasis |
| `--color-faint` | `#d6d3d1` | `rgba(255,255,255,0.06)` | Lowest-contrast separators |
| `--color-divider` | `#f5f5f4` | `rgba(255,255,255,0.05)` | Inline dividers |

**Why alpha borders in dark mode:** stone's warm-neutral steps lose contrast at low luminance; alpha-on-dark keeps separators visible across all three surfaces without per-component tuning.

### Semantic (status)

Mapped to Tailwind's stock palette — use as-is:

| Status | Solid | Tint bg | Ring |
|---|---|---|---|
| Success | `green-600` | `green-50` / `green-900/30` | `green-600/20` |
| Info | `blue-700` | `blue-50` / `blue-900/30` | `blue-600/20` |
| Warning | `yellow-800` | `yellow-50` / `yellow-900/30` | `yellow-600/20` |
| Danger | `red-600` | `red-50` / `red-900/30` | `red-600/20` |

Reserve **brand-orange** for product-positive actions and brand identity. Do not use it for warnings, errors, or destructive flows.

### Colour restraint (the law)

Colour exists to signal **action** or **true status** — nothing else.

- **Brand orange** goes on real CTAs and buttons (and current-app-navigation / selected large option cards). Never on passive marks.
- **Status colours** (green/blue/yellow/red) appear only inside `.badge`/`.alert`/status chips where the colour carries semantics (deliverability, success, danger).
- **Everything passive is ink.** A boolean tick, a selection check, a decorative icon renders `text-default` or `text-muted` — exactly like the selection ticks in `SegmentSelector` and the contacts field manager, and the typed boolean cell in `DataTableCellValue`.
- When a mark needs a treatment, copy the exact treatment from the closest established surface. Do not invent a tinted variant.

---

## 3. Typography Rules

### Families

| Variable | Stack | Use |
|---|---|---|
| `--x-font-family-default` | `Inter`, system-ui, sans-serif | All UI text (body, headings, inputs, buttons) |
| `--x-font-family-secondary` | `SF Pro Text`, sans-serif | Apple-platform native UI moments (rare; opt-in) |
| `--x-font-family-monospace` | `JetBrains Mono`, monospace | Code, tokens, IDs, API keys, raw values |

Inter is loaded from `inter-ui` npm package. SF Pro from `/fonts/sf-pro/` self-hosted. JetBrains Mono from Google Fonts.

### Scale

Base size is **15px** (`html { font-size: 15px }`). All Tailwind `text-*` utilities scale from this.

| Utility | Computed | Role |
|---|---|---|
| `text-xs` | ~11px | Badges, micro-helpers, kbd hints, hints under inputs |
| `text-[10px]` | 10px | `.tag` only (compact inline label) |
| `text-sm` | ~13px | Default UI text — buttons, inputs, body in cards |
| `text-base` | ~15px | Large input variant, prominent body |
| `text-[13px]` | 13px | Toolbar buttons (explicit pixel for chrome-y feel) |

Use semantic sizes (`text-sm`, `text-base`) over arbitrary values unless matching chrome conventions.

### Weights

- `font-medium` (500) — labels, navigation, secondary buttons
- `font-semibold` (600) — buttons, card titles, headings
- `font-bold` (700) — reserved for marketing/display moments

Body text is **400** (regular) by default. Never use `font-light` for UI text.

### Leading

- `leading-6` for form labels and helper text (sits cleanly with 24px row rhythm)
- Default Tailwind leading otherwise

---

## 4. Component Stylings

The SPA ships hand-built component CSS in [`src/assets/`](src/assets/). All components consume tokens above — never hardcode colors.

### Buttons → [`buttons.css`](src/assets/buttons.css)

**Base class:** `.button` — applies `inline-flex`, icon/text `gap`, `rounded-md`, `px-3 py-2`, `text-sm`, `font-semibold`, and a focus-visible outline. Icons inside buttons should not carry their own horizontal margins; spacing belongs to the button primitive.

**Tones × Styles matrix** (combine via classes: `<button class="button secondary sm">`):

| Style | brand / primary | secondary | danger |
|---|---|---|---|
| *(solid, default)* | `bg-brand-500/600` white text | `bg-surface` + `ring-border` + readable text | `bg-red-600` white text |
| `outline` | transparent + `ring-brand-200` | transparent + `ring-border` + readable text | transparent + `ring-red-200` |
| `soft` | `bg-brand-50` text-brand-600 | `bg-surface-sunken` text-default | `bg-red-50` text-red-600 |
| `subtle` | soft + ring | soft + ring | soft + ring |
| `ghost` | transparent → tinted hover | transparent → muted hover | transparent → red hover |
| `link` | text-only, underline on hover | text-only | text-only |

Special:
- `.button.cta` — page-header / dashboard primary action (alias of `.button.primary` styling)
- `.button.white` — light bg button for use over colored hero sections
- `.button.secondary` — default non-primary action. Use this for export,
  settings, routing, and header-adjacent actions instead of a transparent
  outline.
- `.button.outline` — exceptional transparent bordered treatment. Avoid it for
  ordinary secondary actions because it reads as harsh chrome beside the warm
  stone surfaces.

**Sizes:** `xs` (px-2 py-1 text-xs), `sm` (px-2.5 py-1.5), default (px-3 py-2), `lg` (px-4), `xl` (px-6 py-3 text-base), `icon` (8×8 square), `toolbar` (h-8 rounded-lg px-3 text-[13px]).

**Composed patterns:**
- `.button-group` — segmented connected buttons (auto rounds first/last, `-ml-px` overlap)
- `.tab-group` — pill-style segmented control on `bg-surface-sunken` p-1. Active state is a neutral raised surface with readable text, not an orange border or fill. Always pair it with a size modifier: `tab-group--md` for page/action controls, `tab-group--compact` for drawer and panel controls, and `tab-group--xs` for dense icon-only controls. Add `tab-group--bordered` only when the rail sits beside bordered controls or on a low-contrast page-tint surface.
- `.route-tab` / `.route-tab--active` — compact route/filter tab primitive used by `FilterPills` tab mode. Do not use this for page-level sub-nav.
- `.facet-pill` / `.facet-pill--active` — FILTER chip primitive (white lifted selection). Filters only; never navigation.
- `.float-action` / `.float-action--danger` — floating hover icon buttons (flow node duplicate/delete, library card delete): white ground, `shadow-sm` + `ring-black/5`, hover `bg-surface-sunken`, press `bg-surface-hover`. Danger changes ONLY the icon colour on hover (red-500) — backgrounds stay identical to the base. One definition; never restyle per component.
- `.range-field` + `.range-value-input` (forms.css) — THE slider: hairline ink track (foreground progress via `--range-progress`), white ring thumb, compact tabular value chip. Brand orange never appears on sliders; consume via `components/inputs/RangeInput.vue`.
- `.text-button` — typographic action (no chrome, brand-color)
- `.icon-button` — bare icon click target (22×22 min)
- `.close-button` — modal close (6×6, subtle → default on hover)
- `.option-card` — selectable tile (flat bordered surface, border-only hover, brand-ring on `.active`)

**Tabs and filter controls:** `PageTabs` is the page-level underlined sub-nav pattern, used for durable sections such as Brand and Settings. Keep it underlined. Compact route/filter tabs use `.route-tab` through `FilterPills` tab mode: same lifted-surface language as facet pills (white selected + hairline ring, translucent-white hover) in a squared `rounded-md` shape with a semibold active label. Loose filter chips may use `rounded-full` and the same soft active surface. Segmented controls do not use a brand edge; selected segments are neutral raised surfaces inside a sunken rail. The segmented rail border is opt-in via `tab-group--bordered`, used when the control sits beside bordered buttons or would otherwise disappear into the page background. Segmented groups use equal-width centered segments when labels compete for space, but they do not share one universal font size: use `tab-group--md` at page/action scale, `tab-group--compact` inside drawers and property panels, and `tab-group--xs` for dense icon-only controls. Fully rounded chips (`rounded-full`) are for loose facets, such as integration categories. Squared-off rounded controls (`rounded-md`/`rounded-lg`) are for compact route/filter tabs, buttons, and segmented switches. Avoid `text-brand-600`, `bg-brand-50`, or `border-brand-500` for ordinary compact route/filter tabs; reserve stronger brand states for primary actions, current app navigation, page-level underlined tabs, drag/drop targets, and selected large option cards. Keyboard focus may use the brand outline/ring.

### Forms → [`forms.css`](src/assets/forms.css)

**Input heights** (CSS variables):
- `--input-height: 2.5rem` (default)
- `--input-height-lg: 3rem`
- `--input-height-sm: 2rem`

**Default input pattern:** `.default-input` / `.form-input` — `rounded-md`, `ring-1 ring-inset ring-border-strong`, `px-2.5 py-2`, `text-sm sm:leading-6`. Focus → `ring-2 ring-brand-600`.

**Wrappers:**
- `.default-form` — `grid gap-y-6` (vertical form rhythm)
- `.default-form.grid-form` — 6-column responsive grid (`grid-cols-1 sm:grid-cols-6`)
- `.input-segments` — input with addon prefix/suffix (single focus ring around group)
- `.input-switch` — toggle (h-6 w-11, brand-600 on `.checked`, `.sm` variant available)
- `.input-error` (red-500 xs) / `.input-hint` (muted xs)

**Special:** `.gradient-input` — large input wrapped with brand-gradient border (`#FF6B2C → #FF4D00`), used for hero/marquee form moments.

**Checkboxes & radios:** `.default-checkbox` — `h-4 w-4 rounded border-border-strong text-brand-600` — is THE checkbox for forms; `.default-radio` is its circular sibling for single-choice. Never use the raw `@tailwindcss/forms` `.form-checkbox`/`.form-radio` plugin classes — they render **blue**, not brand. (DataTable keeps its own scoped `.checkbox` for the row-selection column; that is the one intentional exception.)

**Toggle vs checkbox:** a **toggle** (`ToggleSwitch`, the shared boolean switch over `.input-switch`) means "turn this capability on/off"; a **checkbox** means "pick items from a set." Don't use a checkbox to enable a feature. On/off settings render as a `.setting-row` (description left, toggle right).

**No fake inputs:** never render read-only facts in input chrome (a `readonly` text input or an input-styled div). If there is no choice to make, render nothing and state the fact where it matters (e.g. the sender is shown in the send modal, not as a dead From field). Pickers render only when options > 1.

### Cards → [`cards.css`](src/assets/cards.css)

`.card` — flat content surface: `bg-surface`, `border-border`, `rounded-xl`. Overlays and modals own elevation; ordinary product cards should not rely on drop shadows.

Sub-parts: `.card-header` (`px-4 py-4 sm:px-5 sm:py-5`), `.card-body`, `.card-title` (`font-semibold`), `.card-subtitle` (`text-sm text-muted max-w-xl`).

Variants:
- `.card--link` — whole-card navigation or command affordance. Pair with `RouterLink` for route changes and `<button>` for commands. It owns hover, focus-visible, pressed, and active/current states; callers own layout (`flex`, `grid`, padding). Hover is border-only; do not fill whole cards with `bg-surface-hover` because that token is for rows, menus, and compact controls.

Large interactive cards and selectable tiles use border-only hover. Reserve filled backgrounds, brand tints, shadows, and rings for selected, active, focused, dragged, or modal states.
- `.form-card` — denser form surface padding.

**Wells** — `.well` / `.well--sunken` / `.well--raised` — the `rounded-2xl` inner panel used INSIDE modals, detail views, and the email builder (integration config panels, import source notes, library/starter cards, builder property cards, square icon tiles). Distinct from `.card`, the `rounded-xl` page-level content card. Chrome only (`rounded-2xl border border-border` + tint): padding, layout, and sizing are composed at the call site (`class="well well--sunken p-4"`). Compose the tint modifier with the base, same convention as `facet-pill`/`float-action`. Never redeclare this chrome in scoped CSS — scoped `@apply` can't reference it anyway; add the classes in the template.

### Skeletons → [`skeletons.css`](src/assets/skeletons.css)

Pulsing placeholders while content loads. Two scales, one definition each:
- `.skeleton-line` — text/control-sized bar. Contrasty `bg-faint` tint so thin bars read on any surface.
- `.skeleton-block` — large area placeholder. Subtle `bg-surface-sunken` tint, `white/5` in dark (where sunken is near-invisible).

Size, width, and radius are composed at the call site (`h-4 w-1/2 rounded skeleton-line`, `rounded-full` for avatars) — the primitives carry only pulse + tint, so utilities and well/card chrome never fight them. Composite skeletons pulse each bar, not the wrapper. `SkeletonLoader.vue` provides ready-made line/card/table-row variants.

### Badges & Tags → [`badges.css`](src/assets/badges.css)

`.badge` — `inline-flex`, `gap-1`, `rounded-md`, `text-xs`, `font-medium`, `px-2 py-0.5`. Tones: `gray`, `brand`, `blue`, `green`, `yellow`, `red`. SVG status dots render at `h-1.5 w-1.5` and should not carry their own horizontal margins.

`.tag` — smaller (`text-[10px]`, `gap-1`, `rounded` not `rounded-md`, no ring). For inline compact labels inside dense tables/lists.

`.kbd` — keyboard shortcut hint (`bg-surface-sunken border-border text-xs text-subtle`).

`.eyebrow` — THE micro-caps label (`text-[10px] font-semibold uppercase tracking-[0.12em] text-subtle`). Section eyebrows, group heads, panel labels. Compose spacing in the template (`class="eyebrow mb-1"`); never redeclare the ramp in scoped styles.

**Semantic law:** a badge/tag means **needs attention**. Passive configuration state (e.g. a flow email step's "Transactional · BCC") renders as the quietest step of the text ramp — small (`text-[11px]`), `text-subtle`, normal case, dot-separated — never as chips and never as tracked caps.

### Alerts → [`alerts.css`](src/assets/alerts.css)

`.alert` — `px-4 py-3 rounded-lg text-sm font-medium`. Tones: `info`, `success`, `warning`, `danger`, `dark`. Light bg + dark text; dark mode flips to `*-900/30` bg + `*-400` text.

### Other surface CSS

[`chat.css`](src/assets/chat.css), [`list.css`](src/assets/list.css), [`pagination.css`](src/assets/pagination.css), [`popper.css`](src/assets/popper.css) (floating-vue overrides), [`scrollbars.css`](src/assets/scrollbars.css), [`tables.css`](src/assets/tables.css). Read these before introducing a parallel pattern.

---

## 5. Surface Chrome & Reusable Patterns

The chrome every list/detail surface is assembled from. **Reuse these; never
hand-roll a parallel.** If a page needs something these do not cover, extend
the shared piece, don't fork it.

### Page anatomy (list surfaces)

```text
PageTitle (title + subtitle; #actions slot holds THE page CTA: .button.cta)
ListToolbar class="mb-4" (#tabs -> FilterPills, #lead -> pickers/SearchInput,
                          #filters -> FilterBar chips, #actions -> secondary)
DataTable (columns, rows, pagination, cursor, pulse)
```

- `PageTitle` `#actions` is where the page's single primary action lives (`New Segment`, `New message`). Not in the toolbar.
- `ListToolbar` always carries `class="mb-4"` — that IS the toolbar-to-table spacing standard.
- `FilterPills` variants: `tab` (route/state tabs), `pill` (loose facets), `segmented` (binary axes). The two roles have DIFFERENT active identities — never mix them:
  - **Filter chips** (`pill` mode → `.facet-pill` in buttons.css): selected chip lifts to the **white raised surface** (`bg-surface`, `shadow-sm`, hairline `ring-black/5`); hover is a 75% translucent preview (`bg-surface/75`). Templates categories, integrations facets.
  - **Navigation tabs** (`tab` mode → `.route-tab`): campaigns/contacts/inbox sub-navs. Same lifted-surface language as facet pills (declared ONCE in buttons.css for both), distinguished by shape: `rounded-md` and a semibold active label instead of a fully rounded chip. Page-level sub-nav stays `PageTabs` (brand underline). Never a brand edge on either.

### DataTable — typed columns

Column defs accept `type: "age" | "date" | "boolean" | "number"`. `DataTableCellValue.vue` is **the single default renderer** for typed cells:

| Type | Renders | Notes |
|---|---|---|
| `age` | relative time + absolute `title` tooltip | activity/created columns |
| `date` | absolute `14 Jul 2026` | invoices, expiries |
| `boolean` | plain-ink `CheckIcon` / muted dash | never coloured |
| `number` | `tabular-nums` | counts, money |

Typed columns get `whitespace-nowrap` on their `<td>` automatically — dates and numbers never wrap. Write a `#cell-<key>` slot only for genuinely bespoke cells (the column keeps its `type` so nowrap still applies). `accessor: (row) => …` feeds computed values. Table headers render on `bg-surface-sunken` with tighter padding (`py-2.5`) than body rows — defined once in `tables.css`.

Liveness: `:pulse-ids` flashes changed rows, `:cursor-id` renders the keyboard cursor ring. Pagination is server-side (Kaminari 25/page, `X-Total-Count`) through `paginatedState/paginatedFetch` and the windowed `Pagination` component.

### Overlays — who is what

| Piece | Use | Rules |
|---|---|---|
| `Modal` | focused tasks (compose, forms, viewers) | variants `centered`/`top`/`fullscreen`; registers with `useOverlayStack`, so active opening order owns z-index and only the top layer is interactive |
| `SlideOver` | record/detail drawers (contact, thread, lead) | overlays from the **true window right**, above the AI chat pane (z-50 > chat z-40); **backdrop OFF by default**; `border-l border-border` edge; never compresses the page content |
| `ConfirmModal` | destructive confirmation | opens above whatever spawned it |

Browser BACK closes the topmost local overlay through `useModalHistory`. Routed overlays are excluded: Vue Router alone owns their entries and Back behavior. When local and routed layers coexist, only the visually topmost local marker may handle the event.

Setup Center may auto-open once for an eligible first-run account, but only when the current route is not an overlay and `useOverlayStack` reports no active overlay.

The ambient aurora backdrop (static webp, `AuroraBackdrop`) is the DEFAULT canvas for every dashboard page — list and detail alike, no per-route opt-in; dark mode runs it at 25% opacity.

Routed drawer pattern (deep-linkable): child route renders `<SlideOver :show="true" @close="goBack">` with the `#container` slot; `goBack()` = `router.back()` with a `router.replace` fallback. Both `Modal` and `SlideOver` carry the nested-dialog guard — opening a child dialog must not close the parent.

The flow editor's `FlowStepPanel` overlays the canvas like every other drawer — the canvas must never compress or reflow when a panel opens (operator rule, Jul 2026). `ChatPane` remains the one docked exception (the shell reserves its width).

### Keyboard & command palette

List surfaces wire `useKeyboardNav` (j/k walk, enter open, plus surface verbs like e/r/c) feeding DataTable's `cursor-id`, and register verbs with `registerContextualCommands` (cleared on unmount). Escape belongs to the open dialog's own Dialog — never double-bind it in the surface.

### Live data

Server models `include Broadcastable` + `broadcasts_as`; clients subscribe via `useCable().onEntityType("<entity>", handler)` and the store merges **in place** (`Object.assign` on the loaded row), evicting rows that leave the active filter — never blind-upsert broadcast payloads into filtered lists.

### Empty states

`NoDataPlaceholder` through DataTable's `empty-*` props, with per-tab copy (what lands here and why), never one generic placeholder.

---

## 6. Layout Principles

### Containers

- `.container` — `max-width: 1200px`, `mx-auto px-6`. Default page wrapper.
- `.container.mobile` — `max-width: 420px` (mobile preview frames, narrow auth flows).
- `.mw-page` — `max-width: 1600px`. Use for full-bleed dashboard layouts.

### Spacing rhythm

Tailwind scale (4px increments). Form rows use `gap-y-6` (24px). Card padding is `px-4 py-5` mobile → `sm:px-6` desktop. Section dividers use 24–32px vertical space.

### Grid

Forms: `grid grid-cols-1 sm:grid-cols-6 gap-x-6 gap-y-6`. Wide layouts often use `grid-cols-12`. Avoid arbitrary `grid-template-columns: ...` — use Tailwind utilities.

### Z-index

- Fixed app chrome and `.skip-to-content` may use `z-50`.
- `useOverlayStack` assigns overlay roots from `z-51` in opening order. The shared Headless UI portal root has no z-index or stacking context.
- Toasts use `z-100`; below `z-40` remains available for in-flow stacking.

---

## 7. Depth & Elevation

Shadows are intentionally restrained — borders and surface tints do most of the elevation work. Ordinary product cards are flat. Overlays, modals, command palettes, dropdowns, drawers, and floating progress trays may use shadow because they are spatially above the page.

| Token | Use |
|---|---|
| `shadow-sm` | Buttons (rest), form inputs |
| `shadow` | Raised controls or active segments, sparingly |
| `shadow-lg` | Dropdowns, modals, floating trays, command palette |
| `shadow-xl+` | Only large overlays/drawers; never ordinary cards |

**Dark mode:** drop `shadow` entirely. Use `ring-1 ring-border` (alpha-white) to define surfaces. Shadows lose meaning on `#111` and become muddy halos.

**Radius scale:**

| Radius | Use |
|---|---|
| `rounded` (4px) | Tags, kbd |
| `rounded-md` (6px) | Inputs, buttons, badges |
| `rounded-lg` (8px) | Cards, alerts, toolbar buttons, tab-groups, gradient-input |
| `rounded-xl` (12px) | Option cards, large marketing moments |
| `rounded-2xl` (16px) | `.well` inner panels only — always via the class |
| `rounded-full` | Switches, avatar, pill counters |

---

## 8. Do's and Don'ts

### Do

- ✅ Use semantic tokens: `bg-surface`, `text-default`, `text-muted`, `ring-border-strong`. Light/dark mode handles itself.
- ✅ Compose buttons by tone + style: `class="button primary"` or `class="button secondary sm"`.
- ✅ Place exactly **one** solid brand-color button per surface (the primary action). Default secondary actions use `secondary`; low-emphasis actions use `soft`, `ghost`, or `link`. Use `outline` only when a transparent bordered treatment is deliberately needed.
- ✅ Use `text-muted` for helper text under inputs; `text-subtle` for placeholders and inactive icons.
- ✅ Use `ring-1 ring-inset` for input/button borders (not `border`) — keeps width consistent with focus ring.
- ✅ Use `focus-visible:outline-2 focus-visible:outline-offset-2` for keyboard focus. Already on `.button`.
- ✅ Use Tailwind `sm:` (640px) breakpoint as the primary mobile→tablet pivot; modals go full-screen below this.
- ✅ Use the **stone** neutrals (built into Tailwind) — they pair with brand-orange's warmth.

### Don't

- ❌ Don't hardcode hex values in components. If you need a color that isn't a token, add a token to [`theme.css`](src/assets/theme.css) first.
- ❌ Don't sprinkle `cursor-pointer` per component. It's already applied globally to `button`, `[role="button"]`, `a[href]` in [`main.css`](src/assets/main.css).
- ❌ Don't use Tailwind's **gray** (cool) — the system is **stone** (warm). They look almost identical in isolation but clash side-by-side.
- ❌ Don't use `shadow-lg` / `shadow-xl` / `shadow-2xl` on ordinary cards. If you need more elevation, you're describing a modal, drawer, popover, command palette, or floating tray.
- ❌ Don't use brand-orange for warnings, errors, or destructive actions. Reserve it for positive product moments.
- ❌ Don't colour passive marks (ticks, selection checks, decorative icons) — plain ink, per §2 Colour restraint.
- ❌ Don't hand-roll table cells for dates/booleans/numbers — use typed DataTable columns (§5).
- ❌ Don't introduce a new component CSS file without checking if [`buttons.css`](src/assets/buttons.css), [`forms.css`](src/assets/forms.css), [`cards.css`](src/assets/cards.css), [`badges.css`](src/assets/badges.css), [`alerts.css`](src/assets/alerts.css), or [`skeletons.css`](src/assets/skeletons.css) already covers the pattern.
- ❌ Don't apply static inline visual styles (`style="..."`) or write SCSS for new work. Dynamic runtime styles are acceptable for measured geometry, progress widths, iframe sizing, and customer brand colors.
- ❌ Don't apply `font-light` to UI text. Inter at 300 looks fragile at 13px.
- ❌ Don't use `border-radius` above `rounded-xl` (12px) — anything more decorative belongs in marketing/illustration, not app chrome. The one sanctioned exception is the `.well` family (`rounded-2xl` inner panels); use the class, never a raw `rounded-2xl`.

---

## 9. Responsive Behavior

### Breakpoints (Tailwind defaults)

| Prefix | Min width | Pivot |
|---|---|---|
| *(none)* | 0 | Mobile-first base |
| `sm:` | 640px | Tablet portrait — modals stop being full-screen, forms switch to 6-col grid |
| `md:` | 768px | Tablet landscape |
| `lg:` | 1024px | Desktop |
| `xl:` | 1280px | Wide desktop |
| `2xl:` | 1536px | Approaches `.mw-page` cap (1600px) |

### Mobile rules (≤ 639px)

- **Modals go full-screen.** [`main.css:107-119`](src/assets/main.css#L107-L119) enforces `max-height: 100vh`, `border-radius: 0`, body scrolls with momentum (`-webkit-overflow-scrolling: touch`).
- **Card padding** drops from `sm:px-6` to `px-4`.
- **Form grid** collapses from 6-col to 1-col (`grid-cols-1 sm:grid-cols-6`).
- **Mobile container** option: `.container.mobile` caps at 420px for narrow flows (auth, onboarding, mobile-preview frames).

### Touch targets

Default button is `py-2` + `text-sm` → ~36px tall; passes WCAG 2.5.5 (24px min, 44px recommended). `.icon-button` is 22×22 minimum — only safe inside touch-permissive contexts (toolbars). Promote to `.button.icon` (32×32) for primary touch surfaces.

### Dark mode

Class-based via `@custom-variant dark (&:where(.dark, .dark *))`. Toggle `.dark` on `<html>`. All component CSS includes `dark:` variants — never write a component without them.

---

## 10. Agent Prompt Guide

Drop these prompts (or fragments of them) into agent invocations or generated `SKILL.md` files to scaffold new UI on this system.

### System prompt fragment

```text
You are building UI for the Nitrosend Vue 3 SPA. Visual system documented in
app/DESIGN.md. Constraints:

- Tailwind CSS 4, CSS-first config. Tokens live in src/assets/theme.css.
- Component CSS lives in src/assets/*.css — reuse .button, .card, .badge,
  .alert, .default-input before introducing new patterns.
- Use semantic tokens (bg-surface, text-default, text-muted, ring-border) —
  never hardcode hex values.
- Brand color is warm orange (#FF4D00). Reserve it for positive primary
  actions. Use red for danger, yellow for warning, blue for info, green for
  success.
- Neutrals are STONE (warm), not GRAY (cool). Do not mix.
- One solid brand button per surface. Default secondary actions use
  `.button.secondary`; lower-emphasis actions use soft, ghost, or link.
  Outline is exceptional, not the default secondary button.
- Dark mode is class-based (.dark on <html>). Every new component needs
  dark: variants. Light mode uses shadows + stone borders; dark mode uses
  alpha-white borders, no shadows.
- Mobile breakpoint is sm: (640px). Modals go full-screen below.
- Composition API + <script setup> only. Pinia stores for state. Axios via
  services/api.js.
```

### Component scaffold prompt

```text
Generate a Vue 3 component that {goal}. Requirements:
- Use existing classes from src/assets/*.css where possible: .button, .card,
  .badge, .alert, .default-form, .default-input, .input-switch, .option-card.
- Use semantic color tokens only. If you need a color not in theme.css,
  STOP and add the token first.
- Include dark: variants for any custom Tailwind utilities.
- Primary action: <button class="button primary">. Cancel/secondary:
  <button class="button secondary"> or <button class="button ghost">.
- Form layout: <form class="default-form grid-form"> with col-span-N children.
- Helper text under inputs: <p class="input-hint">…</p>. Errors:
  <p class="input-error">…</p>.
```

### Token check prompt

```text
Audit this component for Nitrosend design-system compliance:
1. Any hardcoded hex/rgb values? → Replace with theme.css token or add one.
2. Any "cursor-pointer" on buttons/links? → Remove; it's global.
3. Any Tailwind "gray-*" classes? → Replace with "stone-*" or semantic token.
4. Missing dark: variants? → Add them.
5. Using "border" instead of "ring-1 ring-inset"? → Switch.
6. Using shadow on dark mode? → Replace with "dark:ring-1 dark:ring-border".
7. More than one solid brand button visible? → Demote secondary ones to
   "secondary", "soft", or "ghost". Avoid outline unless the transparent
   bordered treatment is intentional.
```

### New surface prompt

```text
Design a {page/modal/panel} for {goal}. Layout:
- Wrap in <div class="container"> (max 1200px) or .mw-page (max 1600px) for
  dashboards.
- Group content in .card with .card-header (title + optional CTA) and
  .card-body.
- Section spacing: 24-32px (use space-y-6 or gap-y-6 utilities).
- Mobile: card padding collapses to px-4; forms collapse to single column;
  modals go full-screen automatically.
- Always exactly one primary CTA per surface.
```

---

## Related references

- [`AGENTS.md`](AGENTS.md) — frontend conventions (Vue/Pinia patterns, file structure)
- [`CLAUDE.md`](CLAUDE.md) — Claude Code project memory for the SPA
- [`src/assets/theme.css`](src/assets/theme.css) — authoritative token definitions
- [`src/assets/main.css`](src/assets/main.css) — global rules, base layer
