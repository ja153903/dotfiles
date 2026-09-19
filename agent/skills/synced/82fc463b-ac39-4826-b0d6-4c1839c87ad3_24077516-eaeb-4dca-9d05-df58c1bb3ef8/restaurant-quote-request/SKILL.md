---
name: restaurant-quote-request
description: Generate quote-request emails for Jaime Abbariao and Jenny Chen to send to restaurants/venues when planning a private dinner event (e.g. a ~50-person dinner). Use this whenever Jaime asks to email restaurants or venues for pricing, availability, private dining, or catering quotes for a group event — including requests like "draft an email asking for quotes", "reach out to these restaurants", or "write an email for the dinner we're planning." Produces both a reusable template and personalized, ready-to-send versions per restaurant.
---

# Restaurant Quote Request Emails

Generates warm, casual quote-request emails from Jaime Abbariao & Jenny Chen to restaurants/venues, for private dinner events (typically ~50 guests).

## What to ask for (every time)

Only two things are required per use, since everything else has a sensible default:

1. **Event date** (or a rough date range if not fixed yet)
2. **Party size** (default to ~50 guests if Jaime doesn't specify)

Don't ask about budget, cuisine, or dietary restrictions unless Jaime brings them up — the template already asks the restaurant about dietary accommodations generically. If Jaime wants to add something specific (a cuisine preference, a budget ceiling, an outdoor-space requirement), fold it into the email as an extra line rather than expanding the intake questions.

## Fixed details (always the same)

- Signed **"Jaime Abbariao & Jenny Chen"**
- Tone: warm and casual, not corporate
- Framed as a **private dinner**, not a corporate/business event
- Leave `[Phone Number]` and `[Email Address]` as placeholders unless Jaime has given contact info in this conversation — don't invent them

## Output modes

**1. Reusable template** — When Jaime just wants something to work from, or hasn't given specific restaurant names yet, fill in the event date and party size in `assets/quote_request_template.md` and hand back a single template with `[Restaurant Name]` left as a placeholder to swap in per send.

**2. Per-restaurant personalized emails** — When Jaime gives one or more specific restaurant names (and optionally contact names/emails), generate one filled-in email per restaurant: swap in the restaurant name, and if a contact person's name is known, greet them by name instead of "team." Present each as a clearly labeled, separate email so Jaime can copy each one directly.

If Jaime gives a list of restaurants at once, generate all of them in one response, clearly separated by restaurant name as headers.

## Style notes

- Keep it short — restaurants get a lot of these, and a tight email gets read.
- Always ask about: availability, private/semi-private space, set-menu or family-style pricing per person, minimums/fees/deposits, and dietary accommodations. These five items are the core of every version — don't drop them even when personalizing.
- Don't oversell the event or add unnecessary flourishes; friendly and efficient beats elaborate.
