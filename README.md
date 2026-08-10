# Nitrosend feature demo, AI suggested campaigns

A demo interface for a feature I think Nitrosend should add: a surface that
proposes campaigns worth sending today, grounded in what the account has
already sent and how its contacts actually behaved.

## The idea

Nitrosend's pitch is that email "stops being a tool you operate and becomes
something you simply prompt." That works, but it moves a burden. A dashboard,
for all its clutter, tells you what to do, a calendar, a flows list, a nagging
empty state. A chat prompt gives you a cursor and waits. You have to already
know what today's job is.

This page fills the blank prompt. It does not write the email; it writes the
prompt and shows it to you first, so the agent still composes and the human
still decides.

Three rules keep it from becoming the "AI suggests things" slop the category is
full of:

1. **Every suggestion carries a fact you can check.** Not "consider a win-back"
   but "255 people opened something in the last 180 days and nothing in the
   last 60." Each category prints its own definition next to its own count.
2. **"Why now" is mandatory.** If a suggestion would be equally true next
   Tuesday, it is not a daily brief item.
3. **It can say send nothing.** Segments under 40 people produce no suggestion,
   and the empty state is written as a real answer rather than a failure.

Each audience carries three genuinely different angles rather than one idea
dressed three ways. Turning one down promotes the next, so a category only
falls silent once its alternatives are actually exhausted. Dismissals persist
until you undo them, with no hidden expiry, and the page always shows what it
is holding back.

The angles are deliberately finite. They are ordered strongest first, so
generating forever would guarantee that anyone who kept clicking ended up
reading the weakest idea presented with the same confidence as the best one.
The facts do not change between rejections either, so a fourth angle for the
same 202 people would be padding. When an audience runs out it keeps its
heading, its count and its rule, and states which conclusion was reached:
a campaign was drafted, or every angle was turned down. New angles arrive when
the numbers move, not when you ask again.

Accepting a suggestion creates a real draft campaign, records which suggestion
produced it, and opens it. The campaign screen itself is a deliberate
placeholder: that surface already exists in Nitrosend, and rebuilding it would
say nothing about the feature being proposed.

## Running it

Two processes. Rails serves JSON; Vite serves the interface and proxies `/api`
to Rails, so there is no CORS setup.

```bash
bin/rails db:prepare
bin/rails db:seed        # 1,200 contacts, 14 campaigns, ~13,600 deliveries
bin/rails server         # :3000, API only

cd frontend
npm install
npm run dev              # :5173, open this one
```

Open <http://localhost:5173>.

## Layout

```
app/models/audience_segment.rb      the five audience definitions, in one place
app/services/suggestion_generator.rb turns data into grounded suggestions
app/controllers/api/                 JSON API
db/seeds.rb                          deterministic demo data
frontend/src/assets/                 Tailwind 4 tokens + component CSS
frontend/src/components/             Vue 3 components
frontend/DESIGN.md                   the visual system this is built to
```

## Notes on the build

- **Vue 3 + Vite + Tailwind CSS 4**, CSS-first config. No `tailwind.config.js`;
  tokens live in `frontend/src/assets/theme.css` under `@theme`.
- **Vite is pinned to 6.x**, Vite 7 requires Node ≥ 20.19.
- Data is seeded with a fixed RNG, so reseeding reproduces the same store.
- `Delivery` (per-recipient opens and clicks) is what makes the segments real.
  Without it, "cold" and "most engaged" are labels rather than measurements.
