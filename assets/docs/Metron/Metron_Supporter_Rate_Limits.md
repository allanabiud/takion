# Introducing Supporter Rate Limits

**July 16, 2026 · 6 min read**

**Brian Pepple** · Founder of the Metron Project / Code Monkey

Back when we added Open Collective support in December 2024, I mentioned that a paid tier for a higher API rate limit wasn't something I was planning on — but that it might be worth revisiting someday if there was enough demand. Then in March we had to cut the daily limit from 10,000 to 5,000 requests due to server load, with a promise to look at restoring it if donations picked up. Well, someday is here: **donors to the project now automatically get an elevated daily API rate limit** — no paid subscription plan required, just a donation through Open Collective.

## How It Works

Every hour, Metron checks for new contributions on our Open Collective page and matches them to Metron accounts by confirmed email address — so make sure the email you donate with matches the confirmed email on your Metron account. A single contribution grants an elevated rate limit for about a month; a recurring monthly donation keeps that window rolling forward automatically with each charge.

There's nothing to sign up for beyond donating — no separate subscription flow, no promo code. If your donation's email matches your account, your profile page will show your active tier and when it expires the next time the sync runs.

## The Tiers

Your tier is based on how much you've given during your current supporter period:

| Tier | Contribution | Daily Requests |
| --- | --- | --- |
| Friend | $2+/mo | 7,500 |
| Backer | $5+/mo | 10,000 |
| Sponsor | $10+/mo | 15,000 |
| Mega Sponsor | $25+/mo | 25,000 |

The standard daily limit remains **5,000 requests/day** (unchanged since the March update) for everyone else.

> These tiers and their limits are based on a limited window of server log data, so consider them a starting point rather than something set in stone — we may need to adjust them once we see how usage plays out in practice.

If you're already a recurring donor, you don't need to do anything — the next sync run will pick up your existing contribution automatically, provided your donation email matches your confirmed Metron account email.

## Stacking Contributions

If you make an additional one-time contribution while you already have an active supporter period, it doesn't reset your clock — it combines with what you've already given that period and can bump you up to a higher tier for the time you have remaining. Your recurring monthly donation is what keeps renewing the period itself.

## Checking Your Status

Head to your profile page while logged in — if you're an active supporter, you'll see your current tier and the date your elevated limit expires, right next to your daily API usage meter.

> If you made a contribution on or after **July 1st, 2026** and it isn't showing up on your account, don't worry — just e-mail me and I'll sort it out.

## Updated Tooling

Mokkari v4.0.0 and Metron-Tagger v4.10.3 are out now with support for these dynamically tiered daily rate limits, replacing the old static bucket-based limiter with reactive tracking of the API's `X-RateLimit-*` headers. This is a **breaking change** for Mokkari: the `api` method no longer takes a `bucket` param. If you don't use that parameter directly, no changes are needed on your end; if you do, you'll need to update your code before upgrading.

One thing that trips up a lot of new Mokkari users: reactive tracking doesn't mean the limit disappears — Mokkari still raises a `RateLimitError` once you hit it, and your code still needs to catch it. Skipping that `try/except` is the single most common source of "my script is hammering your server" bugs we get, tier-aware limits or not:

```python
import mokkari
from mokkari.exceptions import RateLimitError

import time

m = mokkari.api(username, password)

try:
    issue = m.issue(31660)
except RateLimitError as e:
    print(f"Rate limited, retry after {e.retry_after}s: {e}")
    time.sleep(e.retry_after)
```

## For Developers: Reading the Rate Limit Headers

Because your daily limit can now change automatically as your supporter tier changes, don't hardcode a request budget in your scripts or integrations. Instead, read it from the `X-RateLimit-*` headers on every response, the same headers covered in our API tips post:

```http
X-RateLimit-Burst-Limit: 20
X-RateLimit-Burst-Remaining: 17
X-RateLimit-Burst-Reset: 1712876543

X-RateLimit-Sustained-Limit: 15000
X-RateLimit-Sustained-Remaining: 14983
X-RateLimit-Sustained-Reset: 1712966400
```

`Sustained-Limit` reflects whatever your account is entitled to right now — **5,000** for standard accounts, or your tier's elevated limit if you have an active supporter period — so treat it as the source of truth rather than assuming a fixed number:

```python
import requests

response = requests.get("https://metron.cloud/api/issue/1234/", auth=("user", "pass"))

sustained_limit = int(response.headers["X-RateLimit-Sustained-Limit"])
sustained_remaining = int(response.headers["X-RateLimit-Sustained-Remaining"])

if sustained_remaining <= 0:
    reset_at = int(response.headers["X-RateLimit-Sustained-Reset"])
    print(f"Out of requests until {reset_at}; your current daily limit is {sustained_limit}.")
else:
    print(f"{sustained_remaining}/{sustained_limit} requests remaining today.")
```

The same logic in JavaScript:

```javascript
const response = await fetch("https://metron.cloud/api/issue/1234/", {
  headers: { Authorization: "Basic " + btoa("user:pass") },
});

const sustainedLimit = parseInt(response.headers.get("X-RateLimit-Sustained-Limit"), 10);
const sustainedRemaining = parseInt(response.headers.get("X-RateLimit-Sustained-Remaining"), 10);

if (sustainedRemaining <= 0) {
  const resetAt = parseInt(response.headers.get("X-RateLimit-Sustained-Reset"), 10);
  console.log(`Out of requests until ${resetAt}; your current daily limit is ${sustainedLimit}.`);
} else {
  console.log(`${sustainedRemaining}/${sustainedLimit} requests remaining today.`);
}
```

Or just inspecting them from the command line with curl:

```bash
curl -isu user:pass https://metron.cloud/api/issue/1234/ | grep -i 'x-ratelimit-sustained'
```

> If you're on Mokkari v4.0.0+ or Metron-Tagger v4.10.3+, this is handled for you automatically — both now track these headers reactively instead of enforcing a static bucket, so they'll always respect your account's current tier without any configuration.

## Thank You

To everyone who has already donated: thank you for keeping Metron running, and enjoy the extra headroom. If you've been holding off, now's a great time to become a supporter — every contribution, at any tier, genuinely helps keep the project free for the whole community.

Thanks also to Open Collective for providing the platform and API that make this whole system possible.

If you have any questions or suggestions, don't hesitate to e-mail me or ping me on Matrix.
