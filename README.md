# Nitrosend feature demo: AI suggested campaigns

A page that suggests campaigns to send today, based on past campaigns and how
contacts have actually engaged. Contacts are grouped into audiences (Most
engagement, New subscribers, Slipping away, Cold contacts, Never opened) and
each one gets suggestions with the numbers behind them.

Dismissing a suggestion offers a different angle for the same audience.
Accepting one creates a draft campaign and opens it.

Built to [DESIGN.md](DESIGN.md), Nitrosend's visual system.

## Running it

Rails serves JSON. Vite serves the interface and proxies `/api` to Rails, so
there is no CORS setup.

```bash
bin/rails db:prepare
bin/rails db:seed        # 1,200 contacts, 14 campaigns, ~13,600 deliveries
bin/rails server         # :3000, API only
```

```bash
cd frontend
npm install
npm run dev              # :5173, open this one
```

Open <http://localhost:5173>.

Reset the demo data at any time with `bin/rails db:seed`.

## MCP

The same feature is exposed over MCP, so an agent can ask what is worth sending
without opening the page.

```bash
claude mcp add --transport http nitrosend-demo https://nitrosend-feature-demo.fly.dev/mcp
```

Three tools: `nitro_suggest_campaigns` lists today's suggestions, one angle per
audience with the fact behind it; `nitro_dismiss_suggestion` turns one down and
promotes the next; `nitro_draft_campaign` accepts one and creates the draft.
Drafting closes the audience, the same as in the interface.

## Deploying

Rails serves the built SPA, so it deploys as a single app. The Docker build
compiles the frontend and bakes the seeded database into the image.

```bash
brew install flyctl
fly auth login
fly apps create nitrosend-feature-demo
fly secrets set SECRET_KEY_BASE=$(bin/rails secret)
fly deploy --ha=false
fly scale count 1
```

Run on **one machine only**. The SQLite database ships inside the image, so two
machines means two independent copies and writes land in whichever one answered.

Seeded dates are relative to build time, so redeploy to refresh them.

## Tests

```bash
bin/rails test test/models/
```

Covers the audience definitions, the suggestion generator and the draft
behaviour.

## Layout

```
app/models/audience_segment.rb        the five audience definitions
app/services/suggestion_generator.rb  builds suggestions from the data
app/controllers/api/                  JSON API
db/seeds.rb                           demo data, fixed RNG so it is repeatable
frontend/src/assets/                  Tailwind 4 tokens and component CSS
frontend/src/components/              Vue 3 components
DESIGN.md                             the visual system
```

## Notes

- Vue 3, Vite, Tailwind CSS 4 with CSS-first config. No `tailwind.config.js`;
  tokens are in `frontend/src/assets/theme.css` under `@theme`.
- Vite is pinned to 6.x because Vite 7 needs Node 20.19 or newer.
- Minitest is pinned to 5.x because Rails 7.2's test runner is incompatible
  with Minitest 6.
- `Delivery` holds per-recipient opens and clicks. Without it the audiences
  cannot be computed.
- Suggestion copy is written in `SuggestionGenerator`; the numbers in it are
  computed from the data. Swapping in a model call means replacing the authored
  angles with a request built from the same facts.
- The campaign screen you land on after drafting is a placeholder. That
  surface already exists in Nitrosend.
