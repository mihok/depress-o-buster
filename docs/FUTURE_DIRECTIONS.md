# Future directions: what the evidence says

Date: 2026-10-18

This note is a research pass on evidence-based approaches to depression, low motivation and task initiation, written for people working on Depress-o-buster. For each technique it gives a short description with a source, an honest reading of the evidence, the V1 features it already maps onto, the planned seams it could inform, and what the app avoids on purpose. It exists to inform design and copy, not to make the app a treatment. Nothing here is baked into the product beyond what the V1 feature list already describes. The app is not a medical device and makes no health claims.

## Contents

1. [Behavioural activation](#1-behavioural-activation)
2. [The five-minute rule and task-initiation momentum](#2-the-five-minute-rule-and-task-initiation-momentum)
3. [Tiny Habits and the Fogg Behavior Model](#3-tiny-habits-and-the-fogg-behavior-model)
4. [Implementation intentions](#4-implementation-intentions)
5. [Opposite action and DBT behavioural skills](#5-opposite-action-and-dbt-behavioural-skills)
6. [Temptation bundling and the Premack principle](#6-temptation-bundling-and-the-premack-principle)
7. [Body doubling](#7-body-doubling)
8. [Self-determination theory](#8-self-determination-theory)
9. [Self-compassion after setbacks](#9-self-compassion-after-setbacks)
10. [Gamification, streaks and dark patterns](#10-gamification-streaks-and-dark-patterns)
11. [Engagement, retention and the wellness boundary](#11-engagement-retention-and-the-wellness-boundary)
12. [Work-rest intervals and the Pomodoro technique](#12-work-rest-intervals-and-the-pomodoro-technique)
13. [Graded exposure, avoidance hierarchies and approach behaviour](#13-graded-exposure-avoidance-hierarchies-and-approach-behaviour)
14. [Saying intentions out loud](#14-saying-intentions-out-loud)
15. [Things this app deliberately avoids](#things-this-app-deliberately-avoids)
16. [What the ladder is, in these terms](#what-the-ladder-is-in-these-terms)
17. [Sources](#sources)

Feature names in bold are the V1 features and planned seams as named in the product description.

## 1. Behavioural activation

Behavioural activation (BA) is a structured approach to depression in which a person tracks activity and mood, then schedules and gradually increases contact with avoided activities, acting on the plan rather than on current mood. Self-help versions add a difficulty ranking (graded task assignment) and place activities in time slots. See [Martell, Dimidjian and Herman-Dunn (2021), The Guilford Press](https://www.guilford.com/books/Behavioral-Activation-for-Depression/Martell-Dimidjian-Herman-Dunn/9781462548385), [Ekers et al. (2014), PLOS ONE](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0100100), [Richards et al. (2016), The Lancet](https://pmc.ncbi.nlm.nih.gov/articles/PMC5007415/), [Jacobson et al. (1996), Journal of Consulting and Clinical Psychology](https://doi.org/10.1037/0022-006X.64.2.295) and the [Greater Manchester Mental Health NHS Foundation Trust self-help worksheets](https://www.gmmh.nhs.uk/behavioural-activation).

**Evidence:** moderate. Trials and a 26-trial meta-analysis support guided, multi-session programmes for adults with diagnosed depression, but unguided app delivery is barely represented and the approach-then-long-rest timer is the app's own untested design.

Already in the app:

- **Task ladders**: an analogue of graded task assignment, where steps are ranked from easiest to hardest. Letting the user pick any rung keeps the aim, contact with the activity, without enforcing an order.
- **Approach/Rest intervals**: a miniature form of activity scheduling plus the principle that activities follow a plan, not a mood. The approach is a scheduled, time-boxed alternative to an avoidance pattern (the TRAP to TRAC model from Jacobson, Martell and Dimidjian, 2001).
- **AI breakdown**: matches the practice of breaking a task into smaller parts when a step is too large ("it is easier to start small"). Neutral wording matches the coach-like stance the Martell guide describes.
- **Presets**: saved ratios act as reusable scheduled activities, which is how BA turns one-off activities into a recurring plan.
- **Snooze the approach**: an in-the-moment change to the plan rather than a failure, in keeping with BA's collaborative adjustment of schedules.
- **Optional mood tags**: a lightweight version of the activity and mood self-monitoring that Ekers et al. list as a core element.
- **No-guilt history**: BA records what was done and treats lapses as information for the next plan. Crediting a start rewards the approach itself.
- **XP and levels**: in the behavioural model, depression involves a low rate of positive reinforcement, so credit for a one-minute approach rewards approaching. BA manuals favour naturally reinforcing activities over arbitrary rewards, so points are a scaffold, not the technique.
- **Alarms**: a loose mapping. A scheduled activity has a defined start and end, and the two sounds mark those boundaries without adding evaluation.

Could inform:

- **Music integration**: a user-chosen track that starts with every approach is a stable cue for a scheduled activity. Keep it the user's choice and never auto-select "uplifting" music.
- **AI companion**: some BA protocols link activities to the person's own values (the Martell guide has a chapter on value-directed behaviour; the BATD-R manual by Lejuez et al., 2011, is built around life areas and values). If the user has written a one-line "why this matters to me" on a ladder, the companion could read it back verbatim only when asked.
- **Body doubling / shared sessions**: COBRA's BA was delivered by workers with five days of training and fortnightly supervision, so it is not evidence that an untrained peer helps. The modest form is an opt-in shared timer with no XP comparison and no visibility of who abandoned.
- **Sync and backup**: BA monitoring is useful over weeks, so losing the history log removes the one record the technique depends on. Backup of history and ladders comes before any other synced data.
- Small feature, activity-mood view: a read-only per-task view of the user's own before/after **Optional mood tags**, with no advice attached.
- Small feature, optional values line: one optional free-text field on each ladder for what the task connects to. Never required, never surfaced in XP.
- Small feature, "what got in the way" tag: a one-tap, user-defined tag on snooze or abandon (tired, noise, phone), mirroring the TRAP trigger-awareness step. For the user's own history only, never prompting a response from the app.

Avoid:

- Streak-loss or "broken" states: BA treats a lapse as data, and the avoidance model predicts that an aversive consequence after a missed day makes the next approach less likely.
- Guilt, "should" or cheerleading copy: the effect comes from contact with activity, not motivational language, and training materials list "just do it" style lines as a pitfall.
- Locking rungs or requiring the ladder be climbed in order: graded task assignment is a difficulty ordering, not a gate, and gates add friction exactly where avoidance wins.
- Making rest conditional on completing an approach: the cited trials scheduled activities, they did not withhold rest.
- Mood-contingent prompting ("you tagged low, try X"): activities follow a plan, not a mood, so mood tags must never trigger a nudge.
- Public commitment or social-pressure nudges: not part of the cited protocols, and a visible commitment adds a social cost to abandoning.
- Treatment language or outcome claims: every cited study is guided, multi-session BA delivered by trained people. The app is a timer with a ladder.
- Pushing only "pleasant" activities: modern BA targets avoided chores and mastery tasks too, so the laundry pile and the doorway are the right kind of example.

## 2. The five-minute rule and task-initiation momentum

The "five-minute rule" is popular advice to commit to a short, bounded stint of an avoided task, on the premise that starting is the hard part and people often carry on once begun. It is usually justified by two 1920s findings: interrupted tasks tend to be resumed (Ovsiankina) and were claimed to be better remembered (Zeigarnik); a 2025 meta-analysis supports the resumption tendency but finds no reliable memory advantage. See [Ghibellini and Meier (2025), Humanities and Social Sciences Communications](https://doi.org/10.1057/s41599-025-05000-w), [Ovsiankina (1928), Psychologische Forschung](https://link.springer.com/article/10.1007/BF00410261), [Steel (2007), Psychological Bulletin](https://doi.org/10.1037/0033-2909.133.1.65) and [Gollwitzer and Sheeran (2006), Advances in Experimental Social Psychology](https://doi.org/10.1016/S0065-2601(06)38002-1).

**Evidence:** anecdotal or popular. No controlled trial of the rule itself was found; the adjacent evidence (a 67% weighted resumption rate in lab studies, correlates of procrastination, and if-then plans with d = .65) is moderate, and none of it concerns depression.

Already in the app:

- **Approach/Rest intervals**: the approach is the rule made concrete and bounded. The rest after an unfinished approach resembles the interruption condition in which resumption was observed, though lab interruptions were imposed by an experimenter, not scheduled by the person.
- **Presets**: a saved ratio fixes the how (duration and ratio) in advance and removes a decision at the moment of starting. It is only part of an implementation intention, because it does not say when or where.
- **Task ladders**: picking any rung, including near-zero ones, lowers task aversiveness and raises expected success, both strong correlates of procrastination in Steel's meta-analysis. The lowest rungs are the rule shrunk to one minute.
- **AI breakdown**: on-demand micro-steps lower a task's aversiveness.
- **Snooze the approach**: the "carry on if you want to" half of the rule, offered rather than required.
- **No-guilt history**: partial XP for abandoned sessions treats the start as the unit of success. Getting started is one of the points where goal pursuit commonly fails.
- **Low stimulation UI**: one-tap start removes friction at the moment of initiation, which is the moment the rule is about.

Could inform:

- **AI companion**: during an approach the voice talks about unrelated things and never mentions the task. At rest-end it could ask once, neutrally, "another approach, or more rest?", so resumption is offered, never pushed.
- **Music integration**: an ambient track whose length equals the approach makes the interval's end an external, neutral cue rather than a decision.
- **Presets** with an optional when/where line: "after the kettle boils: laundry proximity 5/30" turns a preset into a lightweight if-then plan. Show it as the preset's subtitle, never as a notification.
- Resume card at rest-end: a single dismissible one-tap card, "Same rung again?", with no copy about unfinished work.
- **Body doubling / shared sessions**: share the start moment rather than the outcome or duration, and never compare durations.
- Neutral resumption field in **No-guilt history**: log whether an approach was followed by another in the same session, so the app can later see for itself whether short approaches lead to more.

Avoid:

- Copy that calls the rule "research-backed" or "proven": the only study naming it is a 10-person, non-randomised student poster with no results, so the phrasing is "many people find", not "studies show".
- Relying on the Zeigarnik memory effect ("unfinished tasks will nag at you"): no reliable recall advantage was found, and for someone in bed the reminder adds guilt without support.
- "You've started, so keep going" prompts or obligatory continuation: the rule's value is the small bounded commitment, and a demand raises task aversiveness and contradicts sacred rest.
- Pressure, urgency or performance framing: the meta-analysis found no Zeigarnik effect under achievement or neutral conditions, and the resumption tendency does not need it.
- Deadline countdowns or streak-loss to manufacture urgency: an imposed deadline is one more aversive feature, and loss framing conflicts with the no-guilt principle.
- Treating five minutes as a fixed minimum: nothing privileges five minutes, so one- and two-minute rungs earn the same first-step recognition.
- Badges or markers on unfinished or abandoned tasks: the memory-tension premise is unsupported, and markers accumulate into a visible backlog.

## 3. Tiny Habits and the Fogg Behavior Model

The Fogg Behavior Model states that a behaviour occurs only when motivation, ability and a prompt coincide, and argues that when motivation is low, making the behaviour simpler is often the practical lever. Tiny Habits packages this as a recipe: a version small enough for a bad day, an anchor in an existing routine, and an immediate brief celebration; a separate observational line links repetition in a consistent context to rising self-reported automaticity. See [Fogg (2009), Persuasive '09](https://doi.org/10.1145/1541948.1541999), [Fogg (2020), Houghton Mifflin Harcourt](https://books.google.com/books?vid=ISBN9780358003328), [Lally et al. (2010), European Journal of Social Psychology](https://doi.org/10.1002/ejsp.674), [Judah et al. (2018), BMC Psychology](https://pmc.ncbi.nlm.nih.gov/articles/PMC6302524/) and [Gardner, Lally and Wardle (2012), British Journal of General Practice](https://pmc.ncbi.nlm.nih.gov/articles/PMC3505409/).

**Evidence:** weak. The model is a design heuristic from a conference paper, no controlled trial of the Tiny Habits programme was found, and the habit studies are small, non-experimental and in general-population volunteers.

Already in the app:

- **Approach/Rest intervals**: a seconds-to-minutes approach is the "tiny" behaviour. The rest-done moment can serve as the anchor for the next approach, which is the app's own application of the idea.
- **Task ladders**: the near-zero rungs correspond to the book's starter steps and scaled-back versions. Picking any rung matches the advice to shrink the behaviour until it is doable on a bad day.
- **AI breakdown**: the ability lever directly. The 2009 paper says increasing motivation is not always the solution, which fits the non-cheerleading wording.
- **Presets**: a preset is in effect a recipe (fixed tiny behaviour plus fixed context). One-tap start supports the consistent-context repetition that Lally et al. link to automaticity.
- **Alarms**: the distinct sounds act as the prompt. Without a prompt the behaviour will not occur even with motivation and ability.
- **XP and levels**: the closest analogue of the celebration step, though XP is an external marker, not the felt emotion, so the mapping is partial. Judah et al. found pleasure strengthened the repetition-to-automaticity link while perceived usefulness did not.
- **No-guilt history**: Lally et al. found a single missed occasion did not materially affect habit formation, consistent with silent missed days and a multiplier that never resets. Missing a week does hinder it.
- **Snooze the approach**: consistent with the book's troubleshooting stance (adjust the recipe, not the person), though snoozing itself was not studied.
- **Low stimulation UI**: one-tap start and large touch targets reduce time, physical effort and brain cycles, three of the paper's six elements of simplicity.

Could inform:

- Anchor sentence on **Presets**: an optional free-text anchor ("after I wake up", "after this rest ends") shown as one line on the start screen.
- Celebration moment at approach-done: a one- to two-second neutral acknowledgement before the XP tally, tying the feeling to the act rather than the accounting.
- **AI companion**: deliver that acknowledgement in one dry sentence at interval-end, then stop.
- **Music integration**: binding a preset to one track makes the track part of the consistent context. Whether the track becomes a cue is untested.
- **Body doubling / shared sessions**: another person's presence could act as a prompt and lower the ability cost, so design it as quiet co-presence rather than accountability. A design inference, not a studied effect.
- **Optional mood tags**: the after-session tag is a rough proxy for the pleasure variable Judah et al. measured. A private, non-scored view of whether approaches feel better over time could be surfaced later.
- **Sync and backup**: time to plateau ranged from 18 to 254 days, so history needs to survive device changes.

Avoid:

- Streak-loss or broken-chain mechanics: a single missed occasion did not matter in Lally et al., so a reset is unsupported and adds guilt.
- Motivational or cheerleading copy: the sources give no support for copy about why the task matters, and perceived benefits did not predict behaviour in Judah et al.
- Public commitment or intention pledges: not part of this evidence base, and Judah et al. found strong intentions weakened the repetition-to-habit link.
- A "66 days to a habit" progress bar: the median comes from 39 participants with a range of 18 to 254 days, so a fixed target would mislead.
- Automatic rung escalation or mandatory order: raising the ability cost on a bad day is what the model says stops the behaviour.
- Deferring all positive feedback to levels or weekly summaries: pleasure of the act is tied to the moment.
- Presenting the method as a treatment: none of the sources studied people with depression.

## 4. Implementation intentions

An implementation intention is a plan in the form "if situation X arises, then I will do Y", made in advance for a goal the person already holds. Linking a concrete cue to a small response makes the cue easier to notice and lets action start with less deliberation. See [Gollwitzer (1999), American Psychologist](https://doi.org/10.1037/0003-066X.54.7.493), [Gollwitzer and Sheeran (2006), Advances in Experimental Social Psychology](https://doi.org/10.1016/S0065-2601(06)38002-1), [Toli, Webb and Hardy (2016), British Journal of Clinical Psychology](https://pubmed.ncbi.nlm.nih.gov/25965276/), [Fritzsche et al. (2016), Cognitive Therapy and Research](https://doi.org/10.1007/s10608-015-9749-6) and [Wang, Wang and Gai (2021), Frontiers in Psychology](https://pmc.ncbi.nlm.nih.gov/articles/PMC8149892/).

**Evidence:** moderate. Strong for goal attainment in general samples (d = .65 across 94 tests), but only two of 29 clinical-sample studies were depression-related, and every outcome is goal attainment, not mood.

Already in the app:

- **Task ladders**: each rung is a concrete, small "then" response (what, for how long, where), which addresses the poorly elaborated goals that prompt deliberation rather than action. A rung supplies the response half of a plan, not the cue half.
- **AI breakdown**: turns a vague goal into specific micro-steps, the elaboration step Toli et al. credit for action. It does not by itself attach a cue.
- **Presets**: a decision made ahead of time. Gollwitzer argues that decisions made only in situ hamper goal pursuit, while anticipative decisions let action start immediately.
- **Alarms**: the rest-done sound works as an external cue, supplying the "if" part. The evidence is on self-formed cue-response links rather than reminders, so this is a loose mapping.
- **Approach/Rest intervals**: the fixed structure gives a recurring, predictable cue for the next action, so the person does not decide from scratch each time.
- **Low stimulation UI**: one-tap start keeps the "then" response cheap, which a multi-screen start would undo.

Could inform:

- Optional "when/then" line on a rung or preset, in the user's own words ("when the kettle boils, I'll sit beside the laundry for 5 min"), shown as one sentence on the start screen. Toli et al. note the contingent if-then format matters, so keep the wording and never require it.
- **Alarms** carrying the next rung: "Rest's up. Next: stand in the doorway, 2 min", with one-tap start. If ignored it stays silent.
- Reluctance plans in **AI breakdown**: optionally one neutral line in the "maintain effort" format ("If I feel reluctant to..., then I will..."), with the "then" being the 1-minute rung rather than more effort.
- **Optional mood tags** as cues: a before-mood tag could pre-select a default rung ("flat" suggests the lowest rung), so the response is already chosen.
- **Body doubling / shared sessions**: collaborative planning is untested in mental health samples. Two people could pick a shared start time while each keeps a private rung.
- **AI companion**: read the user's own when/then sentence once at the start of an approach, then talk about unrelated things. A single read-back is closer to the mechanism than repeated reminders.

Avoid:

- Mandatory plan-writing before a session can start: the technique's benefit comes from removing in-situ deliberation, so forced text entry reintroduces friction.
- Effort-mobilising copy ("then I'll push through"): Gollwitzer recommends "cold" responses over stepping up effort, so "then" responses are smaller rungs, not more effort.
- Plans that tell the user to ignore or suppress how they feel: Toli et al. warn such plans can strengthen the response and produce rebound.
- Streak-loss, guilt or "you promised" mechanics: plan effects depend on commitment to the goal and can be counterproductive in people high in perfectionism; punishing a missed plan turns a cue into a demand.
- Public commitment or social-accountability nudges: none of the sources test public pledges.
- Copy implying that planning improves mood: Fritzsche et al. found more goals attained but no between-group effect on depression or self-efficacy.

## 5. Opposite action and DBT behavioural skills

Opposite action is a skill in the emotion-regulation module of Dialectical Behaviour Therapy (DBT) skills training: name the emotion, check whether it fits the facts and whether acting on it would help, and if not, act opposite to the urge. For sadness the listed urge is to withdraw, and the listed opposites include getting active, approaching, avoiding avoiding and building mastery. See [Linehan (2015), Guilford Press](https://books.google.com/books?vid=ISBN9781462516995), [Linehan et al. (2015), JAMA Psychiatry](https://jamanetwork.com/journals/jamapsychiatry/fullarticle/2205835), [Valentine et al. (2015), Journal of Clinical Psychology](https://collaborate.umb.edu/en/publications/the-use-of-dialectical-behavior-therapy-skills-training-as-stand-/) and [Sauer-Zavala et al. (2019), Behaviour Research and Therapy](https://pmc.ncbi.nlm.nih.gov/articles/PMC6467696/).

**Evidence:** weak. Randomised evidence exists only for year-long, clinician-led skills training in women with borderline personality disorder; opposite action on its own rests on a 16-adult lab study and a five-client pilot (Rizvi and Linehan, 2005), and nothing tested self-directed or app-based use.

Already in the app:

- **Approach/Rest intervals**: the approach is a time-boxed version of "get active, approach" and "avoid avoiding". The fit-the-facts judgement stays with the person. Rest has only a loose link: DBT frames body care as vulnerability reduction, not something to be earned.
- **Task ladders**: a graded form of the Build Mastery steps ("do something difficult, but possible", "if the first task is too difficult, do something a little easier next time"). Stepping down matches the handout's own instruction.
- **AI breakdown**: corresponds to "take the first step, and then the second" and "identify small action steps toward your goal". Neutral language keeps it a tool rather than a coach.
- **Optional mood tags**: a lightweight form of naming the emotion, and a private record of whether anything shifted. The app does not interpret the tags.
- **XP and levels**: credits "at least one thing each day to build a sense of accomplishment", rewarding the attempt rather than completion.
- **Snooze the approach**: lets a user keep going when it is working, their own version of "act opposite all the way", without the app deciding.
- **No-guilt history**: avoids shame cues. The shame urge is to hide or avoid, the same direction as the sadness urge the approach is meant to counter.

Could inform:

- **AI companion**: unrelated chat is closer to DBT's distress-tolerance distraction than to opposite action. Treat it as an optional time-passing aid, off by default, that never coaches or asks the user to "check the facts".
- **Music integration**: marking one track as approach music is a small "do pleasant things that are possible now" step.
- **Body doubling / shared sessions**: addresses the isolation half of the sadness urge. Nothing tested it in this form, so keep it opt-in with no visibility of others' XP, rungs or history.
- Optional "urge note" beside **Optional mood tags**: one word at approach start ("stay in bed"), so the after tag shows the user whether anything shifted. Never scored.
- Cope-ahead: a one-tap "pick tomorrow's first rung" at session end, loosely mirroring the cope-ahead skill; the practical gain is a smaller next zero-friction start.
- Posture rungs: the sadness entry includes changing posture (head up, eyes open, shoulders back). **Task ladders** could offer a default posture rung, presented as a rung, not as something that changes mood.

Avoid:

- "Broken streak" or decayed-to-zero displays: a guilt or shame cue that pulls toward exactly the withdrawal the approach exists to counter.
- Telling the user their mood "does not fit the facts": in DBT that judgement belongs to the person, and sadness that fits the facts (real losses) is routed elsewhere. The app cannot make that distinction.
- Forcing completion or auto-escalating rungs: even the skills-only trial arm had 39% dropout, and the handout itself says to do something easier next time.
- Branding features as DBT, "opposite action" or "emotion regulation training": the evidence for stand-alone skills is preliminary, and the name would imply something the app is not.
- Public commitment or social pressure: pressure that reads as shame triggers the hide/avoid urge.
- Making rest conditional on finishing the approach: body care is vulnerability reduction, not a reward.
- The AI companion acting as a real-time skills coach: unsolicited coaching conflicts with "AI assists but never nags" and risks reading as judgement.

## 6. Temptation bundling and the Premack principle

Temptation bundling pairs an activity a person tends to put off with an enjoyable one that is available only, or mainly, while doing it; the original field study restricted tempting audiobooks to the gym. It is related to the Premack principle, a 1959 laboratory finding that access to a more probable behaviour can reinforce a less probable one. See [Milkman, Minson and Volpp (2014), Management Science](https://pmc.ncbi.nlm.nih.gov/articles/PMC4381662/), [Kirgios et al. (2020), Organizational Behavior and Human Decision Processes](https://faculty.wharton.upenn.edu/wp-content/uploads/2017/07/TemptationBundling.pdf), [Premack (1959), Psychological Review](https://pubmed.ncbi.nlm.nih.gov/13668003/) and [Herrod et al. (2023), Behavior Modification](https://pubmed.ncbi.nlm.nih.gov/35354379/).

**Evidence:** moderate. Two randomised field experiments show small gains in gym visits among existing gym members (one effect decayed weekly and vanished after a holiday, the other persisted up to seventeen weeks), and the app's arrangement, in which rest is never restricted, has not been tested.

Already in the app:

- **Approach/Rest intervals**: structurally a Premack-style sequence, a brief low-probability behaviour followed by the user's most probable one. The app does not withhold rest, so the mapping is structural only and the reinforcing effect is not claimed.
- **Presets**: a ratio like "Laundry proximity 5/30" encodes the user's own pairing of a short should with a long want. Kirgios et al. relied on self-set rules rather than enforcement and saw effects that persisted.
- **Task ladders**: Premack's point is that reinforcement depends on relative probability, and applied studies often skipped checking it. Letting the user pick a step close to what they already do loosely echoes this.
- **Snooze the approach**: 39 percent of participants in the 2014 study would pay nothing for an imposed restriction. Snoozing keeps the pairing under the user's control.
- **XP and levels**: the 2014 effect collapsed after the gym closed over Thanksgiving. A multiplier that never resets and a bonus after a 3+ day gap are a design response to that collapse, not a tested fix.
- **No-guilt history**: Kirgios et al. describe bundling as making the want "less wasteful and guilt-inducing". Neutral logging keeps the pleasant half from being recorded as a lapse.

Could inform:

- **Music integration**: the most direct seam. Let a user tag a playlist, podcast or audiobook as "approach-time", start it when an approach begins and pause it at rest, as a soft self-set rule the user can break at will.
- **AI companion**: the companion is itself a candidate "want". The 2014 study found a larger initial effect among people who enjoyed the first bundled session, so let the user choose topic and voice and treat the first approach as a trial.
- **Presets**: an optional one-line "pair with" field ("a show I only watch during approach"). Kirgios et al. found people inferred the pairing from merely being handed the want.
- **Optional mood tags**: an on-request summary of after-session moods per pairing, so the user can see whether a paired want still feels good. Make swapping the paired content easy.
- **AI breakdown**: give the prompt the user's recently completed rung level and ask for steps at or below it, so suggestions stay close to what the user already does.

Avoid:

- Locking content or the companion behind completing an approach: the locked condition decayed weekly and vanished after a break, and a lock conflicts with zero-friction start.
- Making rest something to earn ("back to bed once you finish"): applying Premack means restricting the high-probability behaviour, which here is rest. That is a punishment-shaped mechanic and contradicts sacred rest.
- Streak-loss mechanics: the 2014 effect collapsed after an enforced gap, so penalising gaps compounds the documented failure mode.
- Explaining the technique at length: explicit teaching added only 2 to 3 percentage points over merely providing the want. One neutral sentence is enough.
- Shared sessions as public commitment or accountability: the mechanism is pairing a want with a should, and a sizeable minority rejected imposed restriction.
- Presenting bundling as a lasting fix or making a health claim for it: effects were small, measured as gym visits, and in one study temporary.

## 7. Body doubling

Body doubling is a community-named practice, reported mostly by people with ADHD and other neurodivergent people, of starting or working on a task while someone else is present, in the same room, on a call, or as a live or recorded stream. The main peer-reviewed evidence is one self-report survey of 220 people, and the older social-facilitation literature finds small, task-dependent effects of mere presence. See [Eagle, Baltaxe-Admony and Ringland (2023), ASSETS '23](https://doi.org/10.1145/3597638.3614486), [Eagle, Baltaxe-Admony and Ringland (2024), ACM Transactions on Accessible Computing](https://doi.org/10.1145/3689648), [Bond and Titus (1983), Psychological Bulletin](https://pubmed.ncbi.nlm.nih.gov/6356198/) and [Zajonc (1965), Science](https://pubmed.ncbi.nlm.nih.gov/14300526/).

**Evidence:** weak. One descriptive survey (reported twice), no controlled trials, no depression sample, and a 241-study meta-analysis in which the presence of others accounts for about 0.3% to 3% of performance variance.

Already in the app:

- **Approach/Rest intervals**: respondents use presence to start, focus on or finish a task, not to rest. A double would attach only to the approach, and rest stays private.
- **Task ladders**: respondents double household chores, study, work and self-care, and getting started is a main motivation. The near-zero rungs already isolate that moment, so a shared session needs no new task model.
- **Low stimulation UI**: the calm one-tap UI sits at the ambient end of the mutuality continuum, where it belongs; presence raises arousal and slows complex tasks.
- **Optional mood tags**: a private record of whether a session with company felt different, without the app claiming any effect.

Could inform:

- **Body doubling / shared sessions**: start at the ambient end with a passive presence indicator ("3 other people are in an approach right now"), shown only during an approach, with no chat, no task names and no completion status.
- **Body doubling / shared sessions**: a "run this preset together" mode for two people who know each other, where each sees only that the other's approach timer is running. Abandon and snooze are never shown.
- **AI companion**: sits at the recorded, low-mutuality corner. Add a "just be here" option that says little beyond a quiet "still here" every few minutes, and make it easy to mute, since a 12-person VR preprint found people split on human versus AI doubles.
- **Music integration**: cafes and "study with me" streams count as doubling for respondents, so an ambient "someone else is working" soundscape (pages turning, quiet typing) could sit next to music.
- **Sync and backup**: any shared session needs an account and sync first, so keep presence strictly dependent on this seam.

Avoid:

- Accountability mechanics (partner sees your abandon, "your partner is waiting", shared checkmarks): accountability is the far end of the continuum, some participants found a human double stressful, and the one controlled poster found no effect at all.
- Public rooms, cameras or chat as the default: fear of judgement is documented in this group, and many respondents occupy the anonymous, low-awareness end. Default to silent, camera-free presence.
- Prompting users to invite a friend or join a session mid-approach: most who use doubling discovered it themselves. Keep it opt-in from settings.
- Presenting body doubling as proven: at most "some people find company helps them start".
- Social comparison or shared streaks: nothing supports comparison between users, and it adds evaluation pressure.
- Using the rest interval for anything social: presence ties to starting and staying on task, and rest is sacred.

## 8. Self-determination theory

Self-determination theory (SDT) holds that self-motivation and well-being are supported when three needs are met: autonomy (acting from one's own volition), competence (feeling effective at an optimally challenging task) and relatedness (feeling connected to others). A meta-analysis of 128 experiments found that expected rewards contingent on an already-interesting task reduced later free-choice engagement, while positive verbal feedback increased it; the METUX framework applies the three needs to digital products. See [Ryan and Deci (2000), American Psychologist](https://pubmed.ncbi.nlm.nih.gov/11392867/), [Deci, Koestner and Ryan (1999), Psychological Bulletin](https://pubmed.ncbi.nlm.nih.gov/10589297/), [Peters, Calvo and Ryan (2018), Frontiers in Psychology](https://www.frontiersin.org/articles/10.3389/fpsyg.2018.00797/full) and [Ryan, Rigby and Przybylski (2006), Motivation and Emotion](https://doi.org/10.1007/s11031-006-9051-8).

**Evidence:** moderate. Decades of experiments support the model, but effect sizes are small to moderate, the meta-analysis was contested in the same journal issue, the tasks were interesting lab tasks rather than chores, and METUX is a proposal whose measures still need validation.

Already in the app:

- **Approach/Rest intervals**: rest as part of the method keeps it out of the completion-contingent reward category (d = -0.36 for free-choice engagement). Setting both intervals down to seconds is the kind of choice that supports autonomy.
- **Presets**: user-authored, user-named ratios are personalisation, which supports autonomy through ownership and choice.
- **Snooze the approach**: matches the criterion that autonomy-supportive products do not demand actions without assent, and avoids the deadlines and directives that reduce intrinsic motivation.
- **Task ladders**: picking any rung is choice, and it lets the user set their own level of challenge. A task that is too easy or too hard stops satisfying competence.
- **AI breakdown**: on-demand only fits the no-demand-without-assent criterion. Neutral wording avoids the pressured evaluation that pushes the perceived locus of causality outside the person.
- **XP and levels**: XP is an expected, completion-contingent reward, the category found undermining on interesting tasks, so this is a caution as much as a fit. No leaderboards, a never-resetting multiplier and meaningful XP for one minute reduce the pressure, but no source shows any XP design is neutral.
- **No-guilt history**: partial XP for starting, silent missed days and neutral logging avoid threats and pressured evaluations. Acknowledging a return is nearer positive feedback (d = 0.33), though praise of the person can read as controlling.
- **Low stimulation UI**: an analogy to the intuitive controls associated with competence and autonomy in game play. Minimal stimulation also limits the crowding out of other activities.
- **Optional mood tags**: optional and user-chosen, and they record how approaching the task felt, the real activity rather than satisfaction with the app.

Could inform:

- **AI companion**: relatedness independently predicted enjoyment in a survey of online gamers, so a companion is consistent with SDT. Keep it opt-in and conversational, and prefer "that was five minutes beside the pile" over "I'm proud of you", which SDT treats as controlling.
- **Music integration**: let the user choose the track and confirm once before auto-start. Starting audio without assent is a small demand.
- **Body doubling / shared sessions**: social features can make users compare themselves with others and do not by themselves satisfy relatedness. Favour real-time presence over feeds, and hide XP, levels and history from others.
- Unannounced acknowledgements: unexpected rewards did not undermine engagement, so keep first-time bonuses as after-the-fact surprises rather than targets to chase.
- Brief dismissible rationale: a meaningful rationale for an uninteresting behaviour, with autonomy support, promoted internalisation in one lab study. One dismissible line on why approach then rest, with no instruction to do more, fits that pattern.
- Task-versus-behaviour check: a user "may find the app itself engaging but not feel more willingness to exercise". An occasional optional one-tap question ("closer to the laundry than last week? yes/no/unsure") would show whether app use tracks the real activity.

Avoid:

- Streak-loss, "broken chain" or decay-to-zero mechanics: they make XP a threat withdrawn for non-compliance, and threats diminish intrinsic motivation.
- Guilt or pressuring copy ("don't lose your progress", "you missed yesterday"): directives and pressure push the locus of causality outside the person.
- Making rest conditional on finishing the approach: this converts rest into a completion-contingent reward and contradicts the method.
- Advertising the XP payout before a session as the reason to start: expected rewards undermine, unexpected ones do not. Show XP afterwards as a record.
- Leaderboards, public commitment or visible comparison: social features can prompt comparison without satisfying relatedness.
- Auto-escalating difficulty or uninvited "try a harder rung" prompts: competence needs optimal challenge, but the user chooses it.
- Nagging notifications to pull the user back: too much engagement can crowd out healthy activities. The measure of use is time near the laundry, not time in the app.
- Treating engagement or session count as the design goal: engagement and enjoyment do not necessarily contribute to sustainable wellbeing.

## 9. Self-compassion after setbacks

Self-compassion means responding to one's own failures with kindness rather than harsh self-criticism, seeing them as part of ordinary human experience, and holding painful feelings in balanced awareness. In small lab experiments a brief self-compassionate framing after a failure was followed by more self-improvement effort than a self-esteem message, and in one prospective study students who forgave themselves for procrastinating procrastinated less before the next exam. See [Neff (2003), Self and Identity](https://doi.org/10.1080/15298860309032), [Breines and Chen (2012), Personality and Social Psychology Bulletin](https://doi.org/10.1177/0146167212445599), [Wohl, Pychyl and Bennett (2010), Personality and Individual Differences](https://doi.org/10.1016/j.paid.2010.01.029) and [MacBeth and Gumley (2012), Clinical Psychology Review](https://doi.org/10.1016/j.cpr.2012.06.003).

**Evidence:** weak. The construct correlates with lower distress (r = -0.54 across 20 samples), but the re-engagement findings come from small undergraduate samples in single labs with no located replication, and none tested interface-embedded non-judgement.

Already in the app:

- **No-guilt history**: neutral logging, partial XP for starting, silent missed days and a marked return remove the app-side cues that invite self-blame. Wohl et al. measured a person's own stance, so the feature removes prompts for self-criticism rather than producing self-forgiveness.
- **XP and levels**: a multiplier that decays slightly but never resets avoids a visible failure signal. The gap bonus marks the return rather than the absence.
- **Snooze the approach**: treats "not ready yet" as information rather than failure, which is Neff's self-kindness component.
- **Task ladders**: a low-capacity day counts as a legitimate attempt instead of a shortfall against a fixed standard.
- **AI breakdown**: answers "this is too hard" with a smaller step, avoiding both criticism and the evaluative praise that Neff separates from self-compassion.
- **Approach/Rest intervals**: rest as part of the method removes a rest-only-if-you-performed rule, a design analogue of Neff's contrast between self-compassion and worth that depends on performance.
- **Optional mood tags**: one optional word lets the user notice a feeling without being asked to evaluate or fix it, loosely the balanced-awareness component.

Could inform:

- **AI companion**: a tone sheet that forbids commenting on missed days, abandoned sessions or XP. If the user mentions a lapse, one brief common-humanity line ("a lot of people find that bit hard"), then back to the unrelated topic.
- Post-abandon flow: when a user ends an approach early, go straight into rest with a one-line neutral log ("Ended at 1:40. Logged.") instead of returning home. Wohl et al. found the link ran through lower negative affect, so the moment after a lapse is rest, not a decision point. A hypothesis, not a tested design.
- Return-after-gap screen: pair the gap bonus with one short normalising line ("Gaps happen. You're here now.") and no summary of what was missed.
- **No-guilt history**: an optional one-word "what got in the way" tag, presented as information for the user and never surfaced as a pattern or reminder.
- **Body doubling / shared sessions**: presence as the only shared signal; never show others' completion, abandonment or XP.
- **Presets**: let the user name a preset in their own terms ("bad day 1/30"), so a minimal ratio reads as a legitimate option rather than a fallback.

Avoid:

- Streak-loss, chain-break or "X days missed" mechanics: lower self-forgiveness went with more negative affect and more later procrastination, and a broken streak is a built-in prompt for self-criticism.
- Guilt or disappointment copy and sad-mascot states ("You missed 3 days", "Don't give up"): this rests on the no-guilt principle plus the direction of the evidence.
- Cheerleading or self-esteem praise ("You're amazing", "Crushed it"): Breines and Chen's self-esteem condition did not produce the gains the self-compassion condition did. Keep acknowledgement calm and factual.
- Public commitment, accountability partners who see lapses, or leaderboards: exposing lapses invites social evaluation, the opposite of common humanity.
- XP deductions, multiplier resets or penalty states: explicit self-criticism prompts.
- Forced self-compassion scripts, mandatory affirmations or "be kind to yourself" pushes: the evidence is about the user's own stance, and unsolicited messaging violates "AI never nags". Keep the stance in mechanics and copy.
- Presenting any of this as therapy or a way to reduce distress: the meta-analysis is correlational and the motivational studies are small.

## 10. Gamification, streaks and dark patterns

Gamification adds game elements such as points, levels, progress feedback, streaks and leaderboards to non-game apps to encourage repeated use. One systematic review of 19 health and wellbeing studies found mostly positive or mixed short-term effects, a second review of 50 mental-health apps only catalogued which elements are used, a log that shows a broken streak reduces subsequent engagement, and some time-based mechanics have been classed as dark patterns. See [Johnson et al. (2016), Internet Interventions](https://pmc.ncbi.nlm.nih.gov/articles/PMC6096297/), [Cheng et al. (2019), JMIR Mental Health](https://pmc.ncbi.nlm.nih.gov/articles/PMC6617915/), [Silverman and Barasch (2023), Journal of Consumer Research](https://academic.oup.com/jcr/article/49/6/1095/6623414) and [Zagal, Björk and Lewis (2013), Foundations of Digital Games](https://research.chalmers.se/en/publication/177148).

**Evidence:** weak. The effects review covers short-term studies that could not isolate which element does what, the broken-streak finding rests on one paper (a 980-person field study plus six online experiments), and nothing was tested with people who are depressed or low in energy.

Already in the app:

- **XP and levels**: progress feedback (80% of apps) and points (56%) were the most common elements in Cheng et al., so XP and calm level names use the most familiar ones. The multiplier that never shows a "broken" state is designed around the broken-streak finding.
- **No-guilt history**: the effect depends on how the log represents behaviour, not on behaviour itself, and is amplified by self-attribution (53% continued with an intact streak, 42% after an externally attributed break, 29% after a self-attributed one). Silent missed days and neutral labels are the representation choices that avoid it.
- **Approach/Rest intervals**: the darkness of "playing by appointment" is nullified if appointments are not required for progression. Nothing in the app is gated on showing up at a particular time.
- **Presets**: a named preset such as "Edge of bed 2/20" answers the guiding question "can the player develop a sense of the time commitment necessary?" before a session starts.
- **Task ladders**: no rung is mandatory, so there is no coerced repetition for progression (grinding). The ladder gives the first-time-on-a-higher-rung bonus something concrete to attach to.
- **Optional mood tags**: points and social comparison may be inappropriate where users could be in distress. Keeping the tag private and unscored keeps the one self-report outside the game layer.

Could inform:

- **Body doubling / shared sessions**: social cooperation appeared in 10% of mental-health apps and is called underutilised, while competition may be incompatible with many mental-health domains. Co-presence with no visibility of anyone else's missed days, XP or level fits.
- **Sync and backup**: a failed restore that zeroes XP or the multiplier would show the user a loss of the kind that reduces engagement. Check that restore preserves the multiplier and first-time-bonus flags before it ships.
- **AI companion**: appointment mechanics force people to orient real life around the app's schedule. The companion speaks only inside an approach the user started and never prompts one.
- **Music integration**: a user-chosen setting rather than unlockable content, which is tied to grinding.
- Progress screen (new idea, not a listed seam): the log's representation drives the effect, so counts that only go up (sessions this week, lifetime approaches) are safer than any consecutive-day figure.

Avoid:

- Consecutive-day streak counters or any "streak broken" screen: 69% continued after a broken streak versus 93% with an intact one, and the drop is larger when people blame themselves.
- Streak freezes, repair tokens or "use a freeze?" prompts: they presuppose a loss state, repair only attenuates the effect (85% versus 93%), and about 43% of participants said they would watch an advertisement to repair a streak, a lever a no-guilt app does not hold.
- XP or multipliers that decay to zero, or "come back by midnight" deadlines: "playing by appointment" is a temporal dark pattern, and the gentle floor-limited decay stays as it is.
- Reminders tied to missed activity ("you haven't started today"): this surfaces the missed day the history keeps silent, and it is the nagging pattern (a repeated intrusion, Gray et al., 2018) that "AI never nags" rules out.
- Leaderboards, rankings or public commitment: leaderboards had mixed results with no isolated effect, and competition may be incompatible with mental-health domains.
- Randomised rewards and gated unlockables: unlocking is tied to grinding, and variable rewards conflict with the low-stimulation principle. A design-principle decision rather than an evidence-based one.
- Making rest something to earn (XP thresholds before rest, "skip rest" bonuses): this inverts the method and matches the grinding pattern.
- Health or treatment claims in copy or the store listing: the clearest effects were for physical activity, the mental-health review did not assess effectiveness, and no source tested this population.

## 11. Engagement, retention and the wellness boundary

Real-world use of consumer wellbeing apps is brief and intermittent: in a panel of 93 popular apps the median share of installers opening an app on a given day was 4.0% and median 30-day retention was 3.3%, and across 70 trials mean dropout was 24.1% short-term and 35.5% longer-term. One tailored push notification per day raised next-day logging by 3.9% in relative terms in a microrandomised trial, and FDA and MHRA guidance treat software limited to relaxation or stress claims, with no reference to a condition, as general wellness, while a claim to help treat a condition is not. See [Baumel et al. (2019), Journal of Medical Internet Research](https://pmc.ncbi.nlm.nih.gov/articles/PMC6785720), [Linardon and Fuller-Tyszkiewicz (2020), Journal of Consulting and Clinical Psychology](https://doi.org/10.1037/ccp0000459), [Bidargaddi et al. (2018), JMIR mHealth and uHealth](https://pmc.ncbi.nlm.nih.gov/articles/PMC6293241/), [Torous et al. (2018), Evidence-Based Mental Health](https://pmc.ncbi.nlm.nih.gov/articles/PMC10270395), [FDA (2026), General Wellness: Policy for Low Risk Devices](https://www.fda.gov/regulatory-information/search-fda-guidance-documents/general-wellness-policy-low-risk-devices) and [MHRA (2023), Medical device stand-alone software including apps](https://www.gov.uk/government/publications/medical-devices-software-applications-apps).

**Evidence:** moderate. The retention figures are well supported but descriptive, so the mappings below are inferences; the notification evidence is one trial with a small relative effect; and the regulatory documents describe policy, not outcomes.

Already in the app:

- **No-guilt history**: with 30-day retention near 3% and usage declining through trials, lapsing is the typical pattern, not a failure. Symptom tracking can carry emotional costs, another reason to log abandoned sessions neutrally.
- **XP and levels**: the never-resetting multiplier avoids penalising the intermittent use the data show is typical. The gap bonus marks a return that most installers never make.
- **Alarms**: the only prompts in V1 are session-bound sounds for intervals the user started, the lowest-burden form. The trial itself capped prompting at one decision a day and prompted inactive users less to limit uninstalls.
- **AI breakdown**: never initiating messaging keeps the app free of unsolicited prompts. Its micro-steps stay practical and never suggest clinical action, which the FDA guidance lists as disqualifying.
- **Low stimulation UI**: one-tap start and minimal setup address the set-up fatigue and time-consuming data entry Torous et al. identify. Since most installers open the app only occasionally, each open has to cost near zero.
- **Optional mood tags**: tracker apps had higher open rates and retention than breathing apps (correlational). The tag stays a single optional word with no scores, thresholds or alerts, since clinical thresholds and ongoing monitoring take a product outside the wellness policy.
- **Task ladders**: rungs are everyday activity described without reference to any condition, the pattern the FDA guidance treats as general wellness. Household chores are not literally on the FDA list, so this is a reading, not a determination.

Could inform:

- **AI companion**: opt-in, session-bound and never push-initiated, with output kept away from clinical framing (no "therapy", "treatment", "symptoms", "your depression").
- **Music integration**: FDA Illustrative Example 1 says software that plays music to soothe and manage stress is not a device function. Keep the framing ambient rather than mood treatment.
- **Body doubling / shared sessions**: peer-support apps had the highest open rate (17%) and retention (8.9%), but that rests on two apps. Optional non-comparative presence fits better than accountability.
- **Sync and backup**: a person who comes back after months is a realistic case. Preserve history and the multiplier across reinstalls, so a return is not greeted by an empty app.
- A single optional check-in reminder: off by default, user-chosen time, at most one a day, auto-paused after a run of inactivity, living in **Alarms** settings, never using "we miss you" copy. Trial reminders were associated with lower attrition.
- Store listing and onboarding copy: one line that the app is a timer and activity tool, not a medical device and not a substitute for care, without naming a condition it treats. The FDA guidance expects labelling and marketing to stay within a wellness intended use, and the MHRA says medical purpose is determined by labelling, instructions and promotional material, including the store description. A point for the team: the app's name itself references depression and deserves a deliberate review rather than being assumed to sit inside the policy.

Avoid:

- Streak-loss mechanics: lapses are the typical pattern, so a reset penalises the normal user.
- Unsolicited re-engagement campaigns ("we miss you", several nudges a day): one tailored prompt raised engagement by only 3.9% in relative terms, and frequent notifications are linked to inattention and reduced wellbeing.
- Treatment, diagnosis or clinical language anywhere ("treats depression", "clinically proven", "symptom tracker", mood scores with thresholds): these take a product outside the wellness policy.
- Characterising a gap or a low mood tag as abnormal, a relapse or a problem to fix: a wellness product may not characterise output as abnormal or pathological, and it cuts across the no-guilt principle.
- Public commitment, accountability partners or leaderboards: the only social retention signal comes from two peer-support apps, and no baseline characteristic reliably predicts dropout, so there is no "at-risk user" to nudge harder.
- Judging the app by consumer DAU or retention benchmarks: intermittent use is the norm for this category, and chasing daily opens pushes toward the mechanics the evidence argues against.

## 12. Work-rest intervals and the Pomodoro technique

The Pomodoro Technique divides work into fixed timed intervals, classically 25 minutes, each followed by a short break, with a longer break after four. A meta-analysis of breaks of ten minutes or less finds small gains in self-reported vigour and fatigue and no significant effect on performance, and three small student trials comparing fixed and self-chosen breaks disagree on mood and find no difference in task completion or learning. See [Albulescu et al. (2022), PLOS ONE](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0272460), [Cirillo (2018), Crown](https://books.google.com/books?vid=ISBN9781524760700), [Biwer et al. (2023), British Journal of Educational Psychology](https://cris.maastrichtuniversity.nl/en/publications/understanding-effort-regulation-comparing-pomodoro-breaks-and-sel), [Smits, Wenzel and de Bruin (2025), Behavioral Sciences](https://pmc.ncbi.nlm.nih.gov/articles/PMC12292963/), [Göksu, Wiradhany and de Bruin (2026), Behavioral Sciences](https://pmc.ncbi.nlm.nih.gov/articles/PMC13405840/) and [Sonnentag and Fritz (2007), Journal of Occupational Health Psychology](https://kops.uni-konstanz.de/entities/publication/901f4299-e3f5-46af-99cb-a27bdd4bca71).

**Evidence:** weak. Micro-breaks have meta-analytic support for small self-report gains only (d = .36 for vigour, d = .35 for fatigue, with 4 of 22 studies at low risk of bias), and no study tested an inverted short-work/long-rest ratio, a rest longer than ten minutes, or a low-activation population.

Already in the app:

- **Approach/Rest intervals**: the two-timer loop is Cirillo's core mechanism. Break length did not moderate the micro-break outcomes, and the app's 20-30 minute rest sits outside the ten-minute definition, so the app reuses the structure rather than a tested dose.
- **Presets**: Göksu participants found an imposed 12/3 schedule too short and preferred longer, less frequent breaks, and the authors recommend tailoring to task and preference. Several named user-chosen ratios instead of one canonical ratio fits what the trials show.
- **Snooze the approach**: the trials split on self-chosen versus fixed timing (two favoured self-chosen, one favoured fixed). A fixed timer with a user-controlled extension sits between the two designs.
- **Alarms**: in Cirillo's method the timer ring marks the end of an interval and the start of a break. The two distinct sounds implement that signal.
- **Optional mood tags**: the break trials measured mood with single-item self-ratings before and after intervals. A one-word tag is a much lighter, unvalidated version of the same kind of measure.
- **No-guilt history**: Cirillo's recording stage logs each interval as plain data. Neutral logging keeps that record while dropping his rule that an interrupted pomodoro does not count.

Could inform:

- **Music integration**: break activity type could not be tested as a moderator, and relaxation is one of Sonnentag and Fritz's four recovery experiences. An optional ambient track during rest is untested and defaults to silence.
- **AI companion**: psychological detachment (not thinking about the task) is a recovery experience. If the companion is ever available during rest it only talks about unrelated things, as it already does during approach.
- Self-ended rest: an open-ended rest timer with an "I'm ready" button, logged as a completed rest. Two trials found self-chosen timing at least as good on subjective state, one found self-regulated students took longer breaks and felt worse, so this is reasonable but not clearly supported.
- Rest-length note in **Presets**: a neutral one-line note ("longer rests are fine") when a user shortens rest below a few minutes, and never a prompt to shorten it.
- **Body doubling / shared sessions**: Cirillo's 2018 edition adds chapters on teams, so a shared timer could keep the same loop. The trials say nothing about social accountability, so any shared layer stays opt-in and private.

Avoid:

- Shipping 25/5 as the default or labelling it the "correct" ratio: no trial supports that ratio, and 25/5 was no better than self-chosen timing on any mean outcome.
- Discarding a partially completed interval (Cirillo's "does not count" rule): a productivity convention with no outcome evidence, and a loss mechanic that conflicts with partial XP.
- Productivity or performance claims ("get more done", "be more focused"): no significant performance effect in the meta-analysis, and no difference in task completion or learning in any trial.
- Framing rest as earned or nudging users to shorten rest: nothing supports shortening rest, and detachment and relaxation are associated with well-being.
- Encouraging runs of four cycles: motivation declined faster under four 25/5 cycles than under self-chosen timing, and these users start from low energy. One approach plus one rest is a complete session.
- Streak-loss or public-commitment mechanics: the closest evidence is lower acceptability when a schedule was imposed rather than chosen.
- Implying the interval structure treats or improves depression: every study used students or office workers and measured mood, fatigue, task completion or comprehension.

## 13. Graded exposure, avoidance hierarchies and approach behaviour

Graded exposure breaks an avoided situation into a ladder of steps and has the person stay in contact with a step rather than avoid it; the current inhibitory-learning account holds that strict step order matters less than once assumed. In depression research, avoidance correlates with depressive symptoms and is proposed as one process that keeps low mood going by cutting off rewarding activity. See [Craske et al. (2014), Behaviour Research and Therapy](https://pmc.ncbi.nlm.nih.gov/articles/PMC4114726/), [Wolpe (1958), Stanford University Press](https://books.google.com/books?id=Sf_aAAAAMAAJ), [Ottenbreit and Dobson (2004), Behaviour Research and Therapy](https://doi.org/10.1016/S0005-7967(03)00140-2), [Trew (2011), Clinical Psychology Review](https://doi.org/10.1016/j.cpr.2011.07.007) and [Ferster (1973), American Psychologist](https://pubmed.ncbi.nlm.nih.gov/4753644/).

**Evidence:** moderate. Graded exposure is well supported as clinician-delivered treatment for anxiety disorders, but the depression evidence is cross-sectional self-report in undergraduates plus theory, the mechanism (fear extinction) is not the app's target, and no study tests a self-guided proximity timer.

Already in the app:

- **Task ladders**: an analogue of Wolpe's anxiety hierarchy. Craske et al. begin with moderately difficult exposures and "do not necessarily proceed up a hierarchy in a linear fashion", which fits picking any rung. Near-zero rungs are the app's own extension.
- **Approach/Rest intervals**: the approach is a bounded, timed stay near an avoided cue. Craske et al. end an exposure on a behavioural condition rather than on fear level, and a timer that ends on time rather than on feeling is one such condition.
- **Snooze the approach**: extending without judgement keeps the end condition behavioural rather than emotional. A design inference.
- **AI breakdown**: adds lower rungs on demand, like inserting intermediate hierarchy items when a step is too big.
- **No-guilt history**: by principle only. Avoidance is driven by aversive cues, so neutral logging avoids attaching a new aversive cue to the act of returning.
- **XP and levels**: Ferster and Trew describe depression in terms of reduced positively reinforced behaviour and avoidance that cuts off reinforcement. Immediate XP for any approach is a small, immediate consequence, though whether points act as reinforcement here is untested.
- **Optional mood tags**: Craske et al. list affect labelling as one of eight strategies, citing one lab study with spider-fearful participants. A one-word tag resembles it only loosely and is not supported by it.
- **Presets**: a named preset pairs a hierarchy item with a behavioural end condition (duration), so presets double as reusable rungs.

Could inform:

- **AI companion**: distraction and "the presence of another person, cell phones" are listed as safety signals that can blunt exposure learning. That concern is about fear extinction, not the app's target, so a companion is defensible if opt-in, default off, mutable mid-interval, with a "quiet" mode that only announces time.
- **Music integration**: same caveat. Default to ambient or lyric-free tracks, and let a ladder include a rung such as "same step, without music", dropped by the user's choice.
- **Body doubling / shared sessions**: another person present is a possible safety signal, so shared sessions stay optional and earn no more XP than solo ones. A silent presence count is enough.
- Ladder variability: varying stimuli, duration and context is described as aiding retention and generalisation. A small optional "try a different rung today" suggestion, never a requirement.
- Optional expectancy note: a skippable "what do you expect will happen?" before and "what happened?" after, next to **Optional mood tags**. Neutral and never scored.
- **Sync and backup**: user-authored ladders are the most valuable and hardest-to-rebuild data, so they are first in line for backup.

Avoid:

- Forcing rung order or locking higher rungs: Craske et al. do not proceed linearly and start at moderately difficult items, so a locked ladder has no support and adds friction.
- Ending the approach when the person "feels calmer" or requiring distress ratings: within-session fear reduction does not predict later fear, and required ratings break one-tap start. End on time or on a stated behavioural goal.
- Streak-loss, resets or "broken" states: nothing here supports penalties, and a punishing lapse state makes opening the app one more thing to avoid.
- Describing the app as exposure therapy, "treating avoidance" or reducing depression: the strong evidence is clinician-delivered exposure for anxiety, and there is none for a self-guided proximity timer.
- Making the companion, music or body doubling mandatory or XP-boosted: all three match items on the safety-behaviour list, so they are comforts only if optional and never the condition for credit.
- Public commitment or social-accountability nudges: the avoidance scale has a social axis, so for some users social contact is itself an avoided situation.
- Fear or dread language ("face your fear", "confront the pile"): the sources' target is fear, the app's is low activation. Neutral proximity wording ("be near it for 5 minutes") fits better.

## 14. Saying intentions out loud

In motivational interviewing (MI) research, the share of a person's own in-session speech that favours change is weakly associated with later behaviour change, and speech defending the status quo ("sustain talk") with worse outcomes. Whether being heard by others helps is unsettled: four small experiments found identity intentions noticed by others were acted on less, while a 141-trial meta-analysis of goal setting found publicly set goals more effective on average. See [Amrhein et al. (2003), Journal of Consulting and Clinical Psychology](https://researchwith.montclair.edu/en/publications/client-commitment-language-during-motivational-interviewing-predi/), [Magill et al. (2018), Journal of Consulting and Clinical Psychology](https://pmc.ncbi.nlm.nih.gov/articles/PMC5958907/), [Walker et al. (2011), Addictive Behaviors](https://pmc.ncbi.nlm.nih.gov/articles/PMC3342010/), [Gollwitzer et al. (2009), Psychological Science](https://www.psychologicalscience.org/journals/psychological-science/j.1467-9280.2009.02336.x/), [Epton, Currie and Armitage (2017), Journal of Consulting and Clinical Psychology](https://research.manchester.ac.uk/en/publications/unique-effects-of-setting-goals-on-behavior-change-systematic-rev/) and [Miller and Rollnick (2013), Guilford Press](https://www.routledge.com/Motivational-Interviewing-Third-Edition-Helping-People-Change/Miller-Rollnick/p/book/9781609182274).

**Evidence:** weak. The MI data are correlational and clinician-delivered with small effects (r = -.16 for proportion change talk), the commitment-language finding did not replicate, the "going public" backfire rests on four single-lab studies totalling 168 students, and nothing tests private spoken self-statements in an app.

Already in the app:

- **Task ladders**: the existing rung "say out loud 'I'd like to do laundry'" is a private, self-written desire statement, the lowest-cost form of change talk. Because the user writes and picks it, the words are their own, which is the condition MI attaches to such statements. An analogy, not a tested effect.
- **Snooze the approach**: extending without asking for a reason avoids inviting the user to argue for staying put (sustain talk). Applying that to a UI prompt is an inference.
- **AI breakdown**: neutral, on-demand micro-steps avoid persuading, confronting or directing, which correlated with more sustain talk and no extra change talk. Neutrality is the defensible target, not "eliciting" anything.
- **No-guilt history**: the log is private and records what happened rather than what was announced, so it does not create the "others noticed my intention" condition.

Could inform:

- **AI companion**: one optional open question at the start ("what would be slightly nicer once this is done?"), reflect the user's own words once, then move to unrelated chat. It never argues for change or reminds the user what they said earlier.
- **Body doubling / shared sessions**: with the evidence mixed, default to silent co-presence (two timers running at once), make sharing of intentions or completions opt-in per item, and never require stating a goal to join.
- **Task ladders**: an optional rung family that scales wording from desire ("I'd like to") through ability ("I could") to commitment ("I will sit beside it for 2 minutes"), with the user choosing the strength. Given Walker et al., the commitment rung is not treated as better than the desire rung.
- Optional self-only voice note: a rung variant where the user records a one-sentence statement on-device and replays it only to themselves at the next approach. Opt-in, local, never shared.
- **Sync and backup**: rung text and any recordings are private by default, with no default sharing and no social export.

Avoid:

- Public commitment as a default or precondition ("tell a friend what you'll do today" cards, intention feeds): the evidence points both ways, and with a no-guilt principle sharing is opt-in per item.
- Leaderboards or public streaks of stated intentions: being seen to intend gave a premature sense of already having the identity in Gollwitzer's Study 4.
- A mandatory commitment statement before a timer can start: breaks zero-friction start, and MI holds that change talk is elicited, not demanded.
- Consistency-pressure copy ("you said you would", "keep your word"): persuading and confronting correlated with more sustain talk, and it is guilt copy.
- Asking the user to explain a snooze or abandonment: any prompt that invites justification invites arguing for staying put. Keep both one-tap and silent.
- Describing any rung or companion prompt as motivational interviewing or therapy: the evidence comes from trained clinicians in treatment settings.

## Things this app deliberately avoids

The avoid lists above overlap heavily. Merged and de-duplicated, with the techniques each item comes from:

- **Streak loss, broken chains, resets or decay to zero.** A log that shows a broken streak lowers later engagement, a single missed day did not affect habit formation, and lapses are the normal pattern in this app category. From: behavioural activation, five-minute rule, Tiny Habits, implementation intentions, opposite action, temptation bundling, self-determination theory, self-compassion, gamification, engagement and retention, Pomodoro, graded exposure.
- **Streak freezes, repair tokens or "use a freeze?" prompts.** They presuppose a loss state, and repair only attenuates the broken-streak effect. From: gamification.
- **Rest as something to earn.** The cited trials scheduled activities and did not withhold rest, restricting rest is the punishment-shaped half of the Premack arrangement, and conditional rest turns it into a completion-contingent reward. From: behavioural activation, opposite action, temptation bundling, self-determination theory, self-compassion, gamification, Pomodoro.
- **Guilt, "should", disappointment or consistency-pressure copy** ("you promised", "you said you would", "you missed 3 days", sad-mascot states). Directives and pressure push the locus of causality outside the person, and the effect of every technique here comes from contact with activity rather than motivational language. From: behavioural activation, implementation intentions, self-determination theory, self-compassion, saying intentions out loud, engagement and retention.
- **Cheerleading, motivational or self-esteem praise** ("You're amazing", "Crushed it"). Self-esteem messages did not produce the gains self-compassion did, perceived benefits did not predict behaviour, and praise of the person reads as controlling. From: behavioural activation, Tiny Habits, self-compassion, self-determination theory.
- **Locked rungs, mandatory rung order, automatic escalation or forced completion.** Hierarchies are difficulty orderings, not gates, exposure work does not proceed linearly, and raising the ability cost on a bad day stops the behaviour. From: behavioural activation, Tiny Habits, opposite action, self-determination theory, graded exposure.
- **Obligatory continuation or effort-mobilising copy** ("you've started, so keep going", "push through"), and encouraging runs of four cycles. The bounded commitment is the point, "then" responses are smaller rungs rather than more effort, and motivation declined faster under four fixed cycles. One approach plus one rest is a complete session. From: five-minute rule, implementation intentions, Pomodoro.
- **Mood-contingent prompting or interpreting mood tags**, including telling the user a mood "does not fit the facts" or framing a gap or a low tag as abnormal or a relapse. Activities follow a plan, not a mood, the fit-the-facts judgement belongs to the person, and a wellness product may not characterise output as abnormal. From: behavioural activation, opposite action, engagement and retention.
- **Unsolicited notifications, re-engagement campaigns and reminders tied to missed activity** ("we miss you", "you haven't started today", "be kind to yourself" pushes, mid-session invitations). One tailored prompt a day lifted engagement by 3.9% in relative terms, frequent notifications are linked to inattention, and nagging is the pattern "AI never nags" rules out. From: self-determination theory, self-compassion, gamification, engagement and retention, body doubling.
- **Public commitment, accountability partners, leaderboards, social comparison, shared streaks, and public rooms, cameras or chat by default.** None of the protocols cited used social pressure, exposing lapses invites evaluation, social contact is itself avoided by some users, the evidence on sharing intentions points both ways, and competition may be incompatible with mental-health domains. From: every technique in this note.
- **Mandatory plan or commitment statements before a timer can start, or asking the user to explain a snooze or abandonment.** Forced entry reintroduces the deliberation the technique removes, breaks zero-friction start, and invites arguing for staying put. From: implementation intentions, saying intentions out loud.
- **Plans that tell the user to ignore or suppress how they feel.** They can strengthen the response and produce rebound. From: implementation intentions.
- **Treatment, therapy, diagnosis or clinical language**, including branding features as behavioural activation, DBT, opposite action, motivational interviewing or exposure therapy, "research-backed" or "proven" copy, productivity claims, and "66 days to a habit" countdowns. Every strong result here comes from guided, clinician-delivered work in diagnosed populations, nothing tested a self-guided timer, and such claims take a product outside the wellness policies. From: every technique in this note.
- **Relying on the Zeigarnik memory effect, or badges and markers on unfinished tasks.** No reliable recall advantage was found, and markers accumulate into a visible backlog. From: five-minute rule.
- **Deadlines, countdowns, urgency framing and "come back by midnight" mechanics.** An imposed deadline is one more aversive feature, and "playing by appointment" is a temporal dark pattern. From: five-minute rule, gamification.
- **Locking content or the companion behind completion, gated unlockables and randomised rewards.** The locked condition decayed and vanished after a break, unlocking is tied to grinding, and variable rewards conflict with low stimulation. From: temptation bundling, gamification.
- **Advertising the XP payout before a session as the reason to start.** Expected rewards undermined free-choice engagement, unexpected ones did not. From: self-determination theory.
- **Shipping 25/5 as the default, treating five minutes as a fixed minimum, or discarding a partially completed interval.** No trial supports a specific ratio, nothing privileges five minutes, and the "does not count" rule is a loss mechanic. From: Pomodoro, five-minute rule.
- **Requiring distress ratings or ending an approach when the person "feels calmer".** Within-session fear reduction does not predict later outcomes, and ratings break one-tap start. From: graded exposure.
- **Fear or dread language** ("face your fear", "confront the pile"). The app's target is low activation, not fear. From: graded exposure.
- **Making the companion, music or body doubling mandatory or XP-boosted.** All three are possible safety signals and are comforts only if optional. From: graded exposure.
- **Using the rest interval for anything social or task-related.** Presence ties to starting, detachment is a recovery experience, and rest is sacred. From: body doubling, Pomodoro.
- **Pushing only "pleasant" activities.** Modern behavioural activation targets avoided chores and mastery tasks as well. From: behavioural activation.
- **Treating engagement, session count or daily opens as the design goal.** Engagement does not necessarily contribute to wellbeing, and intermittent use is the norm. From: self-determination theory, engagement and retention.
- **Deferring all positive feedback to levels or weekly summaries.** Pleasure of the act is tied to the moment. From: Tiny Habits.
- **The AI companion acting as a real-time skills coach.** The evidence is for the person choosing a skill, and unsolicited coaching reads as judgement. From: opposite action.

## What the ladder is, in these terms

In behavioural activation terms, a task ladder is graded task assignment: one avoided activity split into steps ranked by difficulty, with the aim of making contact rather than finishing. The approach interval is the scheduling half, a time-boxed slot that starts because the plan says so, not because the mood does. In Tiny Habits terms, the lowest rungs are starter steps, versions of the behaviour small enough for a bad day, and the rest-done sound is an available anchor for the next one. In five-minute-rule terms, every approach is the bounded commitment, and the ladder shrinks it further to one or two minutes when five is too many. The exposure literature adds the ladder shape and the point that strict order matters less than once assumed, which is why any rung can be chosen. None of this has been tested as a self-guided timer, so the ladder is a way of counting small approaches, not a method with known effects.

## Sources

1. Jacobson NS, Dobson KS, Truax PA, Addis ME, Koerner K, Gollan JK, Gortner E, Prince SE (1996). A component analysis of cognitive-behavioral treatment for depression. Journal of Consulting and Clinical Psychology, 64(2), 295-304. PMID 8871414. <https://doi.org/10.1037/0022-006X.64.2.295>
2. Ekers D, Webster L, Van Straten A, Cuijpers P, Richards D, Gilbody S (2014). Behavioural Activation for Depression; An Update of Meta-Analysis of Effectiveness and Sub Group Analysis. PLOS ONE, 9(6), e100100. <https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0100100>
3. Richards DA, Ekers D, McMillan D, Taylor RS, Byford S, Warren FC, Barrett B, Farrand PA, Gilbody S, Kuyken W, O'Mahen H, Watkins ER, Wright KA, Hollon SD, Reed N, Rhodes S, Fletcher E, Finning K (2016). Cost and Outcome of Behavioural Activation versus Cognitive Behavioural Therapy for Depression (COBRA): a randomised, controlled, non-inferiority trial. The Lancet, 388(10047), 871-880. <https://pmc.ncbi.nlm.nih.gov/articles/PMC5007415/>
4. Martell CR, Dimidjian S, Herman-Dunn R (2021). Behavioral Activation for Depression: A Clinician's Guide (2nd ed.). The Guilford Press. ISBN 9781462548385 (paperback, 2022) / 9781462548392 (hardcover, 2021). <https://www.guilford.com/books/Behavioral-Activation-for-Depression/Martell-Dimidjian-Herman-Dunn/9781462548385>
5. Greater Manchester Mental Health NHS Foundation Trust (n.d.). Behavioural Activation (self-help worksheet sequence: record current activity, identify activities, organise activities by difficulty, plan). <https://www.gmmh.nhs.uk/behavioural-activation>
6. Ghibellini, R., & Meier, B. (2025). Interruption, recall and resumption: a meta-analysis of the Zeigarnik and Ovsiankina effects. Humanities and Social Sciences Communications, 12, 962. <https://doi.org/10.1057/s41599-025-05000-w>
7. Ovsiankina, M. (1928). Untersuchungen zur Handlungs- und Affektpsychologie. VI. Die Wiederaufnahme unterbrochener Handlungen. Psychologische Forschung, 11, 302-379. <https://link.springer.com/article/10.1007/BF00410261>
8. Steel, P. (2007). The nature of procrastination: A meta-analytic and theoretical review of quintessential self-regulatory failure. Psychological Bulletin, 133(1), 65-94. <https://doi.org/10.1037/0033-2909.133.1.65>
9. Gollwitzer, P. M., & Sheeran, P. (2006). Implementation intentions and goal achievement: A meta-analysis of effects and processes. Advances in Experimental Social Psychology, 38, 69-119. <https://doi.org/10.1016/S0065-2601(06)38002-1>
10. Fogg, B. J. (2009). A behavior model for persuasive design. Proceedings of the 4th International Conference on Persuasive Technology (Persuasive '09), ACM, pp. 1-7. <https://doi.org/10.1145/1541948.1541999>
11. Fogg, B. J. (2020). Tiny Habits: The Small Changes That Change Everything. Houghton Mifflin Harcourt. ISBN 9780358003328. <https://books.google.com/books?vid=ISBN9780358003328>
12. Lally, P., van Jaarsveld, C. H. M., Potts, H. W. W., & Wardle, J. (2010). How are habits formed: Modelling habit formation in the real world. European Journal of Social Psychology, 40(6), 998-1009. <https://doi.org/10.1002/ejsp.674>
13. Judah, G., Gardner, B., Kenward, M. G., DeStavola, B., & Aunger, R. (2018). Exploratory study of the impact of perceived reward on habit formation. BMC Psychology, 6, 62. doi:10.1186/s40359-018-0270-z. <https://pmc.ncbi.nlm.nih.gov/articles/PMC6302524/>
14. Gardner, B., Lally, P., & Wardle, J. (2012). Making health habitual: the psychology of 'habit-formation' and general practice. British Journal of General Practice, 62(605), 664-666. doi:10.3399/bjgp12X659466. <https://pmc.ncbi.nlm.nih.gov/articles/PMC3505409/>
15. Gollwitzer, P. M. (1999). Implementation intentions: Strong effects of simple plans. American Psychologist, 54(7), 493-503. <https://doi.org/10.1037/0003-066X.54.7.493>
16. Toli, A., Webb, T. L., & Hardy, G. E. (2016). Does forming implementation intentions help people with mental health problems to achieve goals? A meta-analysis of experimental studies with clinical and analogue samples. British Journal of Clinical Psychology, 55(1), 69-90. doi:10.1111/bjc.12086. PMID 25965276. <https://pubmed.ncbi.nlm.nih.gov/25965276/>
17. Fritzsche, A., Schlier, B., Oettingen, G., & Lincoln, T. M. (2016). Mental contrasting with implementation intentions increases goal-attainment in individuals with mild to moderate depression. Cognitive Therapy and Research, 40(4), 557-564. <https://doi.org/10.1007/s10608-015-9749-6>
18. Wang, G., Wang, Y., & Gai, X. (2021). A meta-analysis of the effects of mental contrasting with implementation intentions on goal attainment. Frontiers in Psychology, 12, 565202. <https://pmc.ncbi.nlm.nih.gov/articles/PMC8149892/>
19. Linehan, M. M. (2015; released October 2014). DBT Skills Training Manual (2nd ed.). New York: Guilford Press. ISBN 9781462516995. Companion volume: DBT Skills Training Handouts and Worksheets (2nd ed.), Emotion Regulation Handouts 8-13, 19 and 20. <https://books.google.com/books?vid=ISBN9781462516995>
20. Linehan, M. M., Korslund, K. E., Harned, M. S., Gallop, R. J., Lungu, A., Neacsiu, A. D., McDavid, J., Comtois, K. A., & Murray-Gregory, A. M. (2015). Dialectical Behavior Therapy for High Suicide Risk in Individuals With Borderline Personality Disorder: A Randomized Clinical Trial and Component Analysis. JAMA Psychiatry, 72(5), 475-482. doi:10.1001/jamapsychiatry.2014.3039. <https://jamanetwork.com/journals/jamapsychiatry/fullarticle/2205835>
21. Valentine, S. E., Bankoff, S. M., Poulin, R. M., Reidler, E. B., & Pantalone, D. W. (2015). The Use of Dialectical Behavior Therapy Skills Training as Stand-Alone Treatment: A Systematic Review of the Treatment Outcome Literature. Journal of Clinical Psychology, 71(1), 1-20. doi:10.1002/jclp.22114. <https://collaborate.umb.edu/en/publications/the-use-of-dialectical-behavior-therapy-skills-training-as-stand-/>
22. Sauer-Zavala, S., Wilner, J. G., Cassiello-Robbins, C., Saraff, P., & Pagan, D. (2019; online October 2018). Isolating the Effect of Opposite Action in Borderline Personality Disorder: A Laboratory-based Alternating Treatment Design. Behaviour Research and Therapy, 117, 79-86. doi:10.1016/j.brat.2018.10.006. <https://pmc.ncbi.nlm.nih.gov/articles/PMC6467696/>
23. Milkman, K. L., Minson, J. A., & Volpp, K. G. M. (2014). Holding the Hunger Games Hostage at the Gym: An Evaluation of Temptation Bundling. Management Science, 60(2), 283-299. doi:10.1287/mnsc.2013.1784. <https://pmc.ncbi.nlm.nih.gov/articles/PMC4381662/>
24. Kirgios, E. L., Mandel, G. H., Park, Y., Milkman, K. L., Gromet, D. M., Kay, J. S., & Duckworth, A. L. (2020). Teaching temptation bundling to boost exercise: A field experiment. Organizational Behavior and Human Decision Processes, 161(Suppl.), 20-35. doi:10.1016/j.obhdp.2020.09.003 (open access, CC BY; the linked file is the authors' in-press copy). <https://faculty.wharton.upenn.edu/wp-content/uploads/2017/07/TemptationBundling.pdf>
25. Premack, D. (1959). Toward empirical behavior laws: I. Positive reinforcement. Psychological Review, 66(4), 219-233. doi:10.1037/h0040891. <https://pubmed.ncbi.nlm.nih.gov/13668003/>
26. Herrod, J. L., Snyder, S. K., Hart, J. B., Frantz, S. J., & Ayres, K. M. (2023). Applications of the Premack Principle: A Review of the Literature. Behavior Modification, 47(1), 219-246. doi:10.1177/01454455221085249. <https://pubmed.ncbi.nlm.nih.gov/35354379/>
27. Eagle, T., Baltaxe-Admony, L. B., & Ringland, K. E. (2023). Proposing Body Doubling as a Continuum of Space/Time and Mutuality: An Investigation with Neurodivergent Participants. ASSETS '23: The 25th International ACM SIGACCESS Conference on Computers and Accessibility, Article 1-4. <https://doi.org/10.1145/3597638.3614486>
28. Eagle, T., Baltaxe-Admony, L. B., & Ringland, K. E. (2024). "It Was Something I Naturally Found Worked and Heard About Later": An Investigation of Body Doubling with Neurodivergent Participants. ACM Transactions on Accessible Computing, 17(3), 1-30. <https://doi.org/10.1145/3689648>
29. Bond, C. F., & Titus, L. J. (1983). Social facilitation: A meta-analysis of 241 studies. Psychological Bulletin, 94(2), 265-292. <https://pubmed.ncbi.nlm.nih.gov/6356198/>
30. Zajonc, R. B. (1965). Social Facilitation. Science, 149(3681), 269-274. <https://pubmed.ncbi.nlm.nih.gov/14300526/>
31. Ryan, R. M., & Deci, E. L. (2000). Self-determination theory and the facilitation of intrinsic motivation, social development, and well-being. American Psychologist, 55(1), 68-78. doi:10.1037/0003-066X.55.1.68. <https://pubmed.ncbi.nlm.nih.gov/11392867/>
32. Deci, E. L., Koestner, R., & Ryan, R. M. (1999). A meta-analytic review of experiments examining the effects of extrinsic rewards on intrinsic motivation. Psychological Bulletin, 125(6), 627-668. doi:10.1037/0033-2909.125.6.627. <https://pubmed.ncbi.nlm.nih.gov/10589297/>
33. Peters, D., Calvo, R. A., & Ryan, R. M. (2018). Designing for Motivation, Engagement and Wellbeing in Digital Experience. Frontiers in Psychology, 9, 797. doi:10.3389/fpsyg.2018.00797. <https://www.frontiersin.org/articles/10.3389/fpsyg.2018.00797/full>
34. Ryan, R. M., Rigby, C. S., & Przybylski, A. (2006). The Motivational Pull of Video Games: A Self-Determination Theory Approach. Motivation and Emotion, 30(4), 344-360. doi:10.1007/s11031-006-9051-8. <https://doi.org/10.1007/s11031-006-9051-8>
35. Neff, K. D. (2003). Self-compassion: An alternative conceptualization of a healthy attitude toward oneself. Self and Identity, 2(2), 85-101. <https://doi.org/10.1080/15298860309032>
36. Breines, J. G., & Chen, S. (2012). Self-compassion increases self-improvement motivation. Personality and Social Psychology Bulletin, 38(9), 1133-1143. <https://doi.org/10.1177/0146167212445599>
37. Wohl, M. J. A., Pychyl, T. A., & Bennett, S. H. (2010). I forgive myself, now I can study: How self-forgiveness for procrastinating can reduce future procrastination. Personality and Individual Differences, 48(7), 803-808. <https://doi.org/10.1016/j.paid.2010.01.029>
38. MacBeth, A., & Gumley, A. (2012). Exploring compassion: A meta-analysis of the association between self-compassion and psychopathology. Clinical Psychology Review, 32(6), 545-552. <https://doi.org/10.1016/j.cpr.2012.06.003>
39. Johnson, D., Deterding, S., Kuhn, K.-A., Staneva, A., Stoyanov, S., & Hides, L. (2016). Gamification for health and wellbeing: A systematic review of the literature. Internet Interventions, 6, 89-106. doi:10.1016/j.invent.2016.10.002. <https://pmc.ncbi.nlm.nih.gov/articles/PMC6096297/>
40. Cheng, V. W. S., Davenport, T., Johnson, D., Vella, K., & Hickie, I. B. (2019). Gamification in Apps and Technologies for Improving Mental Health and Well-Being: Systematic Review. JMIR Mental Health, 6(6), e13717. doi:10.2196/13717. <https://pmc.ncbi.nlm.nih.gov/articles/PMC6617915/>
41. Silverman, J., & Barasch, A. (2023). On or Off Track: How (Broken) Streaks Affect Consumer Decisions. Journal of Consumer Research, 49(6), 1095-1117. doi:10.1093/jcr/ucac029. <https://academic.oup.com/jcr/article/49/6/1095/6623414>
42. Zagal, J. P., Björk, S., & Lewis, C. (2013). Dark Patterns in the Design of Games. Proceedings of the 8th International Conference on the Foundations of Digital Games (FDG 2013). <https://research.chalmers.se/en/publication/177148>
43. Baumel A, Muench F, Edan S, Kane JM (2019). Objective User Engagement With Mental Health Apps: Systematic Search and Panel-Based Usage Analysis. Journal of Medical Internet Research, 21(9), e14567. doi:10.2196/14567. PMCID PMC6785720. <https://pmc.ncbi.nlm.nih.gov/articles/PMC6785720>
44. Linardon J, Fuller-Tyszkiewicz M (2020). Attrition and adherence in smartphone-delivered interventions for mental health problems: A systematic and meta-analytic review. Journal of Consulting and Clinical Psychology, 88(1), 1-13. doi:10.1037/ccp0000459. PMID 31697093. <https://doi.org/10.1037/ccp0000459>
45. Bidargaddi N, Almirall D, Murphy S, Nahum-Shani I, Kovalcik M, Pituch T, Maaieh H, Strecher V (2018). To Prompt or Not to Prompt? A Microrandomized Trial of Time-Varying Push Notifications to Increase Proximal Engagement With a Mobile Health App. JMIR mHealth and uHealth, 6(11), e10123. doi:10.2196/10123. PMCID PMC6293241. <https://pmc.ncbi.nlm.nih.gov/articles/PMC6293241/>
46. Torous J, Nicholas J, Larsen ME, Firth J, Christensen H (2018). Clinical review of user engagement with mental health smartphone apps: evidence, theory and improvements. Evidence-Based Mental Health, 21(3), 116-119. doi:10.1136/eb-2018-102891. PMID 29871870. PMCID PMC10270395. <https://pmc.ncbi.nlm.nih.gov/articles/PMC10270395>
47. U.S. Food and Drug Administration, Center for Devices and Radiological Health (2026). General Wellness: Policy for Low Risk Devices. Guidance for Industry and Food and Drug Administration Staff, issued January 6, 2026 (supersedes the September 27, 2019 version). Docket FDA-2014-N-1039, document number 1300013. PDF at <https://www.fda.gov/media/90652/download>. <https://www.fda.gov/regulatory-information/search-fda-guidance-documents/general-wellness-policy-low-risk-devices>
48. Medicines and Healthcare products Regulatory Agency (2023). Medical device stand-alone software including apps (including IVDMDs), v1.10g. PDF attached to the gov.uk publication "Medical devices: software applications", last updated 1 July 2023. <https://www.gov.uk/government/publications/medical-devices-software-applications-apps>
49. Albulescu, P., Macsinga, I., Rusu, A., Sulea, C., Bodnaru, A., & Tulbure, B. T. (2022). "Give me a break!" A systematic review and meta-analysis on the efficacy of micro-breaks for increasing well-being and performance. PLOS ONE, 17(8), e0272460. doi:10.1371/journal.pone.0272460. <https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0272460>
50. Cirillo, F. (2018). The Pomodoro Technique: The Acclaimed Time-Management System That Has Transformed How We Work. Crown (Currency imprint), Penguin Random House. ISBN 9781524760700. <https://books.google.com/books?vid=ISBN9781524760700>
51. Biwer, F., Wiradhany, W., oude Egbrink, M. G. A., & de Bruin, A. B. H. (2023). Understanding effort regulation: Comparing 'Pomodoro' breaks and self-regulated breaks. British Journal of Educational Psychology, 93(S2), 353-367. doi:10.1111/bjep.12593. PMID 36859717. <https://cris.maastrichtuniversity.nl/en/publications/understanding-effort-regulation-comparing-pomodoro-breaks-and-sel>
52. Smits, E. J. C., Wenzel, N., & de Bruin, A. (2025). Investigating the Effectiveness of Self-Regulated, Pomodoro, and Flowtime Break-Taking Techniques Among Students. Behavioral Sciences, 15(7), 861. doi:10.3390/bs15070861. <https://pmc.ncbi.nlm.nih.gov/articles/PMC12292963/>
53. Göksu, A., Wiradhany, W., & de Bruin, A. B. H. (2026). When to Take a Break: Comparing Effects of Systematic Short (Pomodoro) and Self-Regulated Breaks on Subjective Experience and Actual Learning. Behavioral Sciences, 16(7), 1158. doi:10.3390/bs16071158. <https://pmc.ncbi.nlm.nih.gov/articles/PMC13405840/>
54. Sonnentag, S., & Fritz, C. (2007). The Recovery Experience Questionnaire: Development and Validation of a Measure for Assessing Recuperation and Unwinding From Work. Journal of Occupational Health Psychology, 12(3), 204-221. doi:10.1037/1076-8998.12.3.204. <https://kops.uni-konstanz.de/entities/publication/901f4299-e3f5-46af-99cb-a27bdd4bca71>
55. Craske, M. G., Treanor, M., Conway, C., Zbozinek, T., & Vervliet, B. (2014). Maximizing exposure therapy: An inhibitory learning approach. Behaviour Research and Therapy, 58, 10-23. doi:10.1016/j.brat.2014.04.006. PMC4114726. <https://pmc.ncbi.nlm.nih.gov/articles/PMC4114726/>
56. Wolpe, J. (1958). Psychotherapy by Reciprocal Inhibition. Stanford University Press. <https://books.google.com/books?id=Sf_aAAAAMAAJ>
57. Ottenbreit, N. D., & Dobson, K. S. (2004). Avoidance and depression: The construction of the Cognitive-Behavioral Avoidance Scale. Behaviour Research and Therapy, 42(3), 293-313. doi:10.1016/S0005-7967(03)00140-2. PMID 14975771. <https://doi.org/10.1016/S0005-7967(03)00140-2>
58. Trew, J. L. (2011). Exploring the roles of approach and avoidance in depression: An integrative model. Clinical Psychology Review, 31(7), 1156-1168. doi:10.1016/j.cpr.2011.07.007. PMID 21855826. <https://doi.org/10.1016/j.cpr.2011.07.007>
59. Ferster, C. B. (1973). A functional analysis of depression. American Psychologist, 28(10), 857-870. doi:10.1037/h0035605. PMID 4753644. <https://pubmed.ncbi.nlm.nih.gov/4753644/>
60. Amrhein, P. C., Miller, W. R., Yahne, C. E., Palmer, M., & Fulcher, L. (2003). Client commitment language during motivational interviewing predicts drug use outcomes. Journal of Consulting and Clinical Psychology, 71(5), 862-878. doi:10.1037/0022-006X.71.5.862. PMID 14516235. <https://researchwith.montclair.edu/en/publications/client-commitment-language-during-motivational-interviewing-predi/>
61. Magill, M., Apodaca, T. R., Borsari, B., Gaume, J., Hoadley, A., Gordon, R. E. F., Tonigan, J. S., & Moyers, T. (2018). A meta-analysis of motivational interviewing process: Technical, relational, and conditional process models of change. Journal of Consulting and Clinical Psychology, 86(2), 140-157. doi:10.1037/ccp0000250. PMC5958907. <https://pmc.ncbi.nlm.nih.gov/articles/PMC5958907/>
62. Walker, D., Stephens, R., Rowland, J., & Roffman, R. (2011). The influence of client behavior during motivational interviewing on marijuana treatment outcome. Addictive Behaviors, 36(6), 669-673. doi:10.1016/j.addbeh.2011.01.009. PMID 21316861. PMC3342010. <https://pmc.ncbi.nlm.nih.gov/articles/PMC3342010/>
63. Gollwitzer, P. M., Sheeran, P., Michalski, V., & Seifert, A. E. (2009). When intentions go public: Does social reality widen the intention-behavior gap? Psychological Science, 20(5), 612-618. doi:10.1111/j.1467-9280.2009.02336.x. <https://www.psychologicalscience.org/journals/psychological-science/j.1467-9280.2009.02336.x/>
64. Epton, T., Currie, S., & Armitage, C. J. (2017). Unique effects of setting goals on behavior change: Systematic review and meta-analysis. Journal of Consulting and Clinical Psychology, 85(12), 1182-1198. doi:10.1037/ccp0000260. PMID 29189034. <https://research.manchester.ac.uk/en/publications/unique-effects-of-setting-goals-on-behavior-change-systematic-rev/>
65. Miller, W. R., & Rollnick, S. (2013). Motivational Interviewing: Helping People Change (3rd ed.). Guilford Press. <https://www.routledge.com/Motivational-Interviewing-Third-Edition-Helping-People-Change/Miller-Rollnick/p/book/9781609182274>

Mentioned in passing, with bibliographic details confirmed but publisher pages not readable at the time of writing, so not relied on above: Jacobson NS, Martell CR, Dimidjian S (2001), Clinical Psychology: Science and Practice, 8(3), 255-270 (TRAP/TRAC); Lejuez CW, Hopko DR, Acierno R, Daughters SB, Pagoto SL (2011), Behavior Modification, 35(2), 111-161, doi 10.1177/0145445510390929 (BATD-R values and life areas); Rizvi SL and Linehan MM (2005), Cognitive and Behavioral Practice, 12(4), 437-447 (five-client opposite-action pilot); Gray CM et al. (2018), CHI 2018, <https://par.nsf.gov/servlets/purl/10057203> (definition of nagging).
