# What I noticed, and what I built

## The observation

Nitrosend's home screen is a chat prompt. Not a dashboard with a chat panel in
the corner, but a conversation, with a placeholder that reads:

> Try: "Create a welcome email series for new subscribers"

That placeholder is the product solving this problem, badly, in eleven words.
It exists because a cursor on its own gives you nothing to do.

A dashboard, for all its clutter, carries an agenda. There is a calendar, a
list of flows, a nagging empty state, an unread count. You open it and it tells
you what your afternoon looks like. Chat inverts that. It is faster than any
dashboard once you know what you want, and completely silent until then.

Nitrosend removed the dashboard on purpose, and I think that was right. But the
dashboard was quietly doing a second job that nobody credits it for, and
deleting the mechanism deleted the function with it. The prompt is faster at
executing an intention and worse at producing one.

The intelligence to fix this is already in the platform. Both `nitro_get_status`
and `nitro_get_insights` return a `recommendations` field. Those recommendations
surface only if you are already in a session, already asking. There is nowhere
that says "here is your day".

## Why it matters

The cost of this is invisible, which is why it survives. A campaign you never
thought to send produces no error, no bounce, no complaint. It just does not
happen, and nothing anywhere records that it did not.

It compounds for the customer Nitrosend is aimed at. Agencies run five brands
on the Ultra plan. That is five blank prompts, five separate acts of
remembering, every week.

And the specific thing being forgotten is the thing a human is worst at
holding. You can remember that you should email people. You cannot remember
that 255 particular contacts opened something in the last 180 days and nothing
in the last 60. That is the one input the platform has and you do not, and it
is exactly the input a blank prompt cannot ask you for.

## What I built

A page that proposes campaigns worth sending today, built from what the account
has already sent and how its contacts actually behaved.

It does not write the email. It writes the prompt and shows it to you first, so
the agent still composes and the person still decides. That keeps it inside
Nitrosend's grain rather than bolting a second authoring system onto the side.

Three constraints do most of the work, and all three are there to stop it
becoming the thing the category is already full of.

**Every suggestion carries a number you can check.** Not "consider a win-back"
but "255 people opened something in the last 180 days and nothing in the last
60". Each audience prints its own definition next to its own count, so the rule
that produced the number is visible beside it. A suggestion you cannot verify is
an opinion with a statistic attached.

**"Why now" is mandatory.** If a suggestion would be equally true next Tuesday,
it is not a daily brief item, it is a blog post. That single constraint
eliminates most generic advice automatically, because most generic advice has no
timing.

**It can say send nothing.** Audiences under 40 people produce no suggestion,
and an audience whose angles have all been rejected says so plainly rather than
disappearing. A page that always has something to recommend is a slot machine.

## Three decisions worth explaining

**The angles are finite.** Each audience carries three genuinely different
campaigns, ordered strongest first. Turning one down promotes the next. It would
have been easy to generate forever, and that would have been a mistake: because
they are ordered by strength, infinite generation guarantees that anyone who
keeps clicking ends up reading the weakest idea wearing the same confidence as
the best. The underlying facts do not change between rejections either, so a
fourth angle for the same 202 people is padding rather than insight.

**Drafting closes the audience.** Once you have decided what to send these
people, offering two more ideas for the same people is the feature arguing with
itself. One send per audience per cycle is the honest cadence, and anything else
invites exactly the fatigue the page warns about elsewhere.

**Confidence is not a badge.** DESIGN.md's semantic law reserves badges for
things needing attention, and says passive configuration state belongs on the
quietest step of the text ramp. Confidence is passive metadata, so it renders as
small subtle text rather than a coloured chip. Colouring it was the easy call
and the wrong one.

## What is real and what is not

The numbers are measured. 1,200 seeded contacts, 14 past campaigns and 13,580
per-recipient delivery records with opens and clicks. Segment sizes, the 78%
engaged open rate, "an average of 13 campaigns", the strongest recent send and
its open rate are all computed live from that data. The `Delivery` model is what
makes this possible: without per-recipient engagement, "cold" and "most engaged"
are labels rather than measurements.

The copy is written by me, one block per angle in `SuggestionGenerator`. This is
a rules engine with real facts interpolated, not a model. I made that choice
deliberately for a prototype: the interesting question is what a good suggestion
must contain, not whether an LLM can phrase it. The seam where a model would
take over is `Suggestion#agent_prompt`, which already carries everything such a
call would need.

The campaign screen you land on after drafting is a deliberate placeholder.
That surface already exists in Nitrosend, and rebuilding it would say nothing
about the feature being proposed.

## What I would do next

**Replace the authored copy with a model call**, using the same computed facts
as input and keeping the three constraints as guardrails rather than prose. The
constraints are the valuable part and they do not depend on who writes the
sentence.

**Make the audiences real segments.** Nitrosend already ships system segments
(Bounced, Suppressed, Recently unsubscribed). These five are the same kind of
object and should be creatable as saved segments in one click, not a parallel
concept that happens to look similar.

**Question whether this should be a page at all.** A surface you have to
remember to visit has the same failure mode as the blank prompt. The stronger
version is probably a weekly digest that arrives, with the page as the place you
go when it does.

**Measure whether it works.** The honest test is whether campaigns started from
a suggestion outperform campaigns started from a blank prompt, on open rate and
on unsubscribes. If they do not, the feature is decoration however good it
looks.
