---
title: "Look at all the things he's not doing"
description: "David's keynote was sure where Rails is heading and quiet on how we get there. The rest of Rails World had better answers."
layout: article
category: ruby
date: 2026-10-02 09:00
image:
  base: "2026/look-at-all-the-things-he-is-not-doing"
  alt: "Four boys looking at a huge pile of underpants in the underpants gnomes' cave"
  credit: "South Park Studios"
  source: "https://en.wikipedia.org/wiki/Gnomes_(South_Park)"
---

There's a moment in the early seasons of South Park when Cartman et al find the source of an underwear crisis in their mountain town. It's the [underpants gnomes](https://en.wikipedia.org/wiki/Gnomes_(South_Park)) in their cave. They have a plan.

1. Collect Underpants
2. ???
3. Profit

I've been considering [David's opening Rails World keynote](https://youtu.be/vDjW_dRyKXY) and realised that this is the main problem I have with it. Rails World is about "shaping the future of Ruby on Rails". Instead what we got was opinionmaxxing: a lot of certainty about the destination, but [in his own words](https://youtu.be/vDjW_dRyKXY?t=2761), not much that was 'practical' or 'prescriptive' about getting there.

1. The model got good at writing code
2. ???
3. Models write all code, we don't need to care

There's a vibration of uncertainty in our community and the wider industry, even from folks, like me, who were early to playing with and then using the new LLM-powered coding tools and harnesses for real production work.

I was left with a "what's the point?" feeling. I don't believe this was the intention. I think David meant it as a provocation, to jolt the room. But the room was already there: when he [polled the audience](https://youtu.be/vDjW_dRyKXY?t=1308) only _five_ people out of 1,200 were still writing material amounts of code by hand. He seemed surprised at the scale of that. He shouldn't have been, the Rails community are tinkerers, early adopters and pragmatists.

To be clear I think he's directionally right on software. The way we make software has changed forever. Yesterday I shipped (and reviewed) 21 bug fix PRs to CoverageBook, upgraded a Rails app from 7.x and Tailwind 2 to latest versions and shipped a couple of feature PRs. I'm engaging more judgement on how much I code review when I can verify in other ways. I've never been so able to deliver well-made software, so fast.

I do believe however there's a lot of interesting work to do in step 2. Software engineering has always been more than typing code. I'm not seeing evidence I can abdicate my taste to Anthropic, OpenAI or the fast-following open-weight models.

## Elsewhere

There were multiple version numbers mentioned in the keynote: all LLMs, not a single mention of Rails 8.2.

David's attention is elsewhere. Ruby was ["about 3%"](https://youtu.be/vDjW_dRyKXY?t=2205) of his work this year, and he's ["talked about nothing else but Omarchy for about 3 months."](https://youtu.be/vDjW_dRyKXY?t=2892) Now the models can one-shot a calculator and convert existing applications to Rust. He seems uninterested in the useful guardrails, determinism and token efficiency[^1] that a battle-tested framework can provide when using agents.

He did concede, [on the panel the next day](https://youtu.be/IEOqgPfGLQ8?t=3510), that he'd still spin up Rails apps for new web software. And in the keynote he admitted the designers' vibe-coded work on Basecamp 5 left the architecture ["a little like Swiss cheese"](https://youtu.be/vDjW_dRyKXY?t=1370), and they went back to manual review.

Problem is, the rest of us need to work now, and the next model might not be perfect. The Rails Foundation's own [Agents on Rails benchmark](https://rubyonrails.org/2026/9/9/agents-on-rails-stage-2) says it isn't there yet: the best result on real feature tickets is 53.3%[^2], and most models score 15–35%. The timeline is unclear. Of course, if the next model removes the need for anything but machine code, this is all moot. But we're in the aftermath of one tipping point, not past a second, greater one.

Rails's opinions used to be all about step 2. The keynote put all the certainty on the destination and handed the path to the next model release. That's the only plan for step 2: ["give it freaking 5 minutes."](https://youtu.be/vDjW_dRyKXY?t=1395) Robby Russell [reflected in his keynote](https://youtu.be/XXjTdyhml0c?t=2845) that folks need "somebody willing to say, 'We've learned enough from these experiments. We're doing it this way now.'"

## Aim & Blast Radius

Jeremy Daer, moderating the [fireside chat between Matz & David](https://youtu.be/IEOqgPfGLQ8) [asked whether words like "slop" and "meat proxies" were diagnoses or coping mechanisms](https://youtu.be/IEOqgPfGLQ8?t=1754). David said ["90% cope"](https://youtu.be/IEOqgPfGLQ8?t=1785) and that ["even the slop grenade is not long for this world."](https://youtu.be/IEOqgPfGLQ8?t=1896) Jeremy pushed back:

["Slop plus the delivery… when it's being dumped on them"](https://youtu.be/IEOqgPfGLQ8?t=1905).

That made me reconsider the other elements of that metaphor that make it really sing: the inaccurate trajectory, lobbed and not watched, the implication of a timer and the difference in experience of the thrower and the receiver.

David said ["I don't mind slop grenades at all... I don't have to catch"](https://youtu.be/IEOqgPfGLQ8?t=1938). That's true for him, both in open source (you can refuse a drive-by PR) and at work (he's in charge).

That's not what slop grenades end up being for the rest of us though. Most of us can't ignore PRs from our co-workers or a 3am page from the explosion of a slop-enabled production incident. It's a thrower's perspective. We have to catch.

If the models emulate human intelligence with machine determination why wouldn't having higher level, verifiable, abstractions be useful? That's why you can spin up a calculator or a Rust duplicate of an existing Rails app. The irresistible force of the agent has something to check its homework on: a bunch of industry standards, a test suite, an existing implementation. Aaron Patterson [made this case](https://youtu.be/t0knYnEYBRo?t=3600) from a lower level:

"I've heard the argument that AI is just our next compiler… [you don't read its output] because the compiler made a promise to you… your AI has not made this promise. There is no as-if rule for your English."

Step 2's hard part is that the model can't write your spec. The published failure mode in the foundation's own AI research is hand-rolling. [Matz said it](https://youtu.be/IEOqgPfGLQ8?t=1515): "we know how to define the goal for the agents… we have to formalize them and teach to the following generations."

Clarity of aim turns a careless lob into a directed pass. I [ported readability](https://github.com/andycroll/readability-rb) from JS to Ruby overnight - its test suite was the guard.[^3]

How is David's Rust-based HEY backend tested? How far along is it? If it's checked against anything, the best spec is the Rails app it replaces. The six native apps are impressive and I absolutely agree I'd go for a performant API & native app combination when powered by LLMs. But they are all also based on well-established, native, well-maintained, well-documented, platform frameworks like SwiftUI, WinUI, Jetpack Compose, Qt.

The web has one of those too. As [Kinsey Durham Grace](https://youtu.be/QMkZ2J24XGI?t=866) put it: "If you designed a framework from scratch for agents, you'd land close to Rails."

Without aim, a grenade just blows holes in whatever it lands on. Not sure waiting 5 minutes for the models is a good solution to having to solve problems now.

## Rails World answered its own keynote

[Hot Cell](https://github.com/basecamp/hotcell) was the only feature that made the keynote[^4] but [Mike Dalessio's talk](https://youtu.be/swXl8M84YmM) was absolutely about how AI is affecting open source (and specifically a Rails CVE) and a framework-shaped answer to _holy shit the robots are coming to hack your systems_.

[Joël Quenneville](https://youtu.be/L6-3a_rwLIg) & [Rachael Wright-Munn](https://youtu.be/aornGet-EoI) talked about fixing the system and bolting deterministic hooks, or [context-injecting generators](https://youtu.be/aornGet-EoI?t=536), onto your agentic tools. Before Rachael's custom generators carried RubyEvents' conventions, the AI ["would invent keys"](https://youtu.be/aornGet-EoI?t=116). Merging [Marco Roth's Herb](https://youtu.be/REtfdqtW3PY) into Rails gives us a parsing tool for the view layer that can escalate errors into an agent's context.

[Kinsey](https://youtu.be/QMkZ2J24XGI) also brought numbers from her time on GitHub's Copilot coding agent team: 84% of developers use AI to write code, but only 29% trust it. ["Generation is really, really cheap, and verification is not"](https://youtu.be/QMkZ2J24XGI?t=164), so reviewing harder won't fix it. Her answer: ["Constraints beat instruction"](https://youtu.be/QMkZ2J24XGI?t=1238). A rule in AGENTS.md fades as the context fills; a CI check that fails the build applies every time and costs no tokens. It's also why Rachael's generators work. With a generator, ["you're making the command that puts [service objects] there cheaper than writing the file by hand. It'll take the cheap path because agents always do."](https://youtu.be/QMkZ2J24XGI?t=1573)

Robby argued for improving the "workshop" of our apps, making the preferred way obvious for humans and agents. Applying our curiosity to the problems we see in our day to day and leaving things better than we found them.

Jeremy [asked what's past Rails](https://youtu.be/IEOqgPfGLQ8?t=3131): "I want to keep Rails… what about the values of Rails?" The answer was ["find your tribe… stick around."](https://youtu.be/IEOqgPfGLQ8?t=3250) That's not a plan for Rails. David's own tribe, and his energy, is clearly Omarchy, his agent-focussed Linux distribution.

People move on. That's fine. There's an entire army of people wanting to do, and already doing, the work before the models (maybe) do all software engineering and the framework doesn't matter.

8.1.4, [a bugfix release](https://rubyonrails.org/2026/9/24/Rails-Version-8-1-4-has-been-released), came out on day 2 of the conference. There's a bunch of cool stuff in 8.2. There's no doubt an editing job to do to make Rails useful through the AI-chaos era that [Mike identified in his talk](https://youtu.be/swXl8M84YmM?t=1527).

## Look at all the things we can do

There's an alt-history version of this talk that pivots on the delight of David's 21-year-old demo ["look at all the things I'm not doing"](https://youtu.be/vDjW_dRyKXY?t=1144) into a vision for how Rails helps the models and the humans compress and accelerate. Then it was the framework, now it's the framework and the model. David credited only the model.

Kinsey closed with the version I wanted from the keynote: ["Convention over configuration was never really about productivity. It was about care. A predictable and clear place to put things is a message to whoever shows up next… We called it a framework, because somebody always comes next."](https://youtu.be/QMkZ2J24XGI?t=1795)

No doubt Rails needs to change—some things in, some things out—but it felt to me like a resignation from this version of his world view. If David's focus has moved on, that's his call. There was enough can-do, roll-your-sleeves-up attitude in the rest of the conference to take on the uncertain future.

Mike [opened with a timeline](https://youtu.be/swXl8M84YmM?t=62): prehistory to modern computing, then "you are here" in a band marked "CHAOS!", and a giant question mark. That question mark _is_ step 2. It won't look like the old work. But it's our work, and you don't need permission to do it.

[^1]: He [praised it in the keynote](https://youtu.be/vDjW_dRyKXY?t=2038) and called it ['a short-term consideration'](https://youtu.be/IEOqgPfGLQ8?t=2736) the next day.

[^2]: Stage 2 gives models 20 feature tickets, written the way a product person would, against 37signals' Fizzy app, graded by hidden checks. At default settings the [best score was 35%](https://rubyonrails.org/2026/9/9/agents-on-rails-stage-2). The 53.3% is the same model, GPT-6 Astra, at [maximum effort](https://rubyonrails.org/2026/9/21/agents-on-rails-maximum-effort-and-deepseek-4-1-flash): 2.6 times the cost and almost three times the time. Claude Fable 5.1 spent twice as much at max for the same 32%.

[^3]: Simon Willison [ported](https://simonwillison.net/2025/Dec/15/porting-justhtml/) a standards-compliant HTML parser ([JustHTML](https://github.com/EmilStenstrom/justhtml)) from Python to JS in four and a half hours.

[^4]: In passing, at [59:45](https://youtu.be/vDjW_dRyKXY?t=3585).
