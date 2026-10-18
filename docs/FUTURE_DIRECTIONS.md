# Future directions: what the evidence says

This note is a short research pass on evidence-based approaches to low motivation and task initiation, for the people building Depress-o-buster. For each technique it gives a description with a source, an honest reading of the evidence, the V1 features it already maps onto, the planned seams it could inform, and what the app avoids on purpose. It exists to inform design and copy. The app is not a medical device, does not present itself as a treatment, and makes no health claims.

Bold is used only for V1 feature names and planned seams, as named in the product description.

## Contents

1. [Behavioural activation](#1-behavioural-activation)
2. [The five-minute rule](#2-the-five-minute-rule)
3. [Tiny Habits and the Fogg Behavior Model](#3-tiny-habits-and-the-fogg-behavior-model)
4. [Implementation intentions](#4-implementation-intentions)
5. [Opposite action from DBT](#5-opposite-action-from-dbt)
6. [Temptation bundling](#6-temptation-bundling)
7. [Body doubling](#7-body-doubling)
8. [Self-determination theory](#8-self-determination-theory)
9. [Self-compassion after setbacks](#9-self-compassion-after-setbacks)
10. [Gamification and streaks](#10-gamification-and-streaks)
11. [Engagement, retention and the wellness boundary](#11-engagement-retention-and-the-wellness-boundary)
12. [Work-rest intervals and the Pomodoro technique](#12-work-rest-intervals-and-the-pomodoro-technique)
13. [Graded exposure and approach behaviour](#13-graded-exposure-and-approach-behaviour)
14. [Saying intentions out loud](#14-saying-intentions-out-loud)
15. [Things this app deliberately avoids](#things-this-app-deliberately-avoids)
16. [What the ladder is, in these terms](#what-the-ladder-is-in-these-terms)
17. [Sources](#sources)

## 1. Behavioural activation

Behavioural activation (BA) is a structured approach to depression: track activity and mood, then schedule gradual contact with avoided activities, acting on the plan rather than the mood. Graded task assignment, ranking activities by difficulty, is a common self-help step. See [Martell, Dimidjian and Herman-Dunn (2021), The Guilford Press](https://www.guilford.com/books/Behavioral-Activation-for-Depression/Martell-Dimidjian-Herman-Dunn/9781462548385), [Jacobson, Martell and Dimidjian (2001), Clinical Psychology: Science and Practice](https://doi.org/10.1093/clipsy.8.3.255) and [Ekers et al. (2014), PLOS ONE](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0100100).

Evidence: moderate. A meta-analysis (a pooled analysis of trials) of 26 trials supports guided, multi-session programmes for diagnosed depression; unguided app delivery is barely represented.

Already in the app:

- **Task ladders**, **Approach/Rest intervals** and **Presets**: graded task assignment with any rung allowed, plus miniature activity scheduling started by the plan, not the mood.
- **AI breakdown**, **Snooze the approach**, **Optional mood tags** and **No-guilt history**: smaller steps, plan adjustment, light self-monitoring, and lapses as information.
- **XP and levels**: credit for approaching, as a scaffold; BA prefers naturally rewarding activities.

Could inform:

- **AI companion**: some manuals tie activities to personal values ([Lejuez et al. (2011), Behavior Modification](https://doi.org/10.1177/0145445510390929)); an optional "why this matters" line, read back only when asked.
- **Sync and backup**: history and ladders are the records BA depends on.

Avoid:

- Mood-contingent prompts ("you tagged low, try X"): activities follow a plan, not a mood.

## 2. The five-minute rule

The "five-minute rule" is popular advice to commit to a short, bounded stint of an avoided task, because starting is the hard part. A 2025 meta-analysis confirms that interrupted tasks tend to be resumed, but finds no reliable memory advantage for unfinished tasks. See [Ghibellini and Meier (2025), Humanities and Social Sciences Communications](https://doi.org/10.1057/s41599-025-05000-w) and [Steel (2007), Psychological Bulletin](https://doi.org/10.1037/0033-2909.133.1.65).

Evidence: anecdotal. No controlled trial of the rule itself was found; the adjacent evidence on resumption and procrastination is moderate and does not concern depression.

Already in the app:

- **Approach/Rest intervals**, **Presets** and **Low stimulation UI**: the rule made concrete, with duration fixed and one-tap start.
- **Task ladders** and **AI breakdown**: small rungs make a task less unpleasant, a strong correlate of procrastination in Steel's review.
- **Snooze the approach** and **No-guilt history**: carrying on is offered, never required; the start is the unit of success.

Could inform:

- **AI companion**: at rest-end, one neutral "another approach, or more rest?", offered, never pushed.

Avoid:

- Calling the rule "research-backed": write "many people find", not "studies show".
- Copy about unfinished tasks "nagging" at you: no reliable recall advantage was found.

## 3. Tiny Habits and the Fogg Behavior Model

The Fogg Behavior Model says a behaviour happens only when motivation, ability and a prompt coincide, so when motivation is low, simplifying the behaviour is the practical lever. Tiny Habits packages this as a tiny behaviour, an anchor in an existing routine, and a brief celebration. See [Fogg (2009), Persuasive '09](https://doi.org/10.1145/1541948.1541999), [Fogg (2020), Houghton Mifflin Harcourt](https://books.google.com/books?vid=ISBN9780358003328) and [Lally et al. (2010), European Journal of Social Psychology](https://doi.org/10.1002/ejsp.674).

Evidence: weak. The model is a design heuristic, no controlled trial of Tiny Habits was found, and the habit studies are small, non-experimental and in general-population volunteers.

Already in the app:

- **Approach/Rest intervals**, **Task ladders** and **AI breakdown**: the behaviour shrunk until it is doable on a bad day.
- **Presets**, **Alarms** and **Low stimulation UI**: a fixed behaviour in a fixed context, a prompt, and one-tap start.
- **XP and levels** and **No-guilt history**: a partial analogue of the celebration, and silent missed days; Lally et al. found a single missed occasion did not materially affect habit formation.

Could inform:

- **Presets**: an optional anchor sentence ("after I wake up") on the start screen.

## 4. Implementation intentions

An implementation intention is a plan of the form "if situation X arises, then I will do Y", made in advance for a goal the person already holds. Linking a concrete cue to a small response lets action start with less deliberation. See [Gollwitzer and Sheeran (2006), Advances in Experimental Social Psychology](https://doi.org/10.1016/S0065-2601(06)38002-1) and [Toli, Webb and Hardy (2016), British Journal of Clinical Psychology](https://pubmed.ncbi.nlm.nih.gov/25965276/).

Evidence: moderate. Strong for goal attainment in general samples, d = .65 (d is a standardised group difference: 0.2 small, 0.5 medium, 0.8 large). Only two of 29 clinical-sample studies concerned depression, and every outcome is goal attainment, not mood.

Already in the app:

- **Task ladders** and **AI breakdown**: each rung is a concrete "then" response; neither supplies the cue.
- **Presets**, **Approach/Rest intervals** and **Alarms**: decisions made ahead of time, with a recurring external cue. A loose mapping, since the evidence is on self-formed cues.

Could inform:

- An optional "when/then" line on a rung or preset, in the user's own words, never required.

Avoid:

- Mandatory plan-writing before a session: forced entry reintroduces the deliberation the technique removes.

## 5. Opposite action from DBT

Opposite action is a Dialectical Behaviour Therapy (DBT) skill: name the emotion, check whether it fits the facts and helps, and if not, act opposite to the urge. For sadness the urge is to withdraw; the opposites include getting active. See [Linehan (2015), Guilford Press](https://books.google.com/books?vid=ISBN9781462516995) and [Linehan et al. (2015), JAMA Psychiatry](https://jamanetwork.com/journals/jamapsychiatry/fullarticle/2205835).

Evidence: weak. The largest randomised trial is year-long, clinician-led skills training in women with borderline personality disorder (Linehan et al., 2015); smaller randomised trials exist in other groups, including a 24-person, 16-week waiting-list trial in treatment-resistant depression ([Harley et al. (2008), Journal of Nervous and Mental Disease](https://doi.org/10.1097/nmd.0b013e318162aa3f)), so the evidence is preliminary rather than absent. Opposite action alone rests on very small studies, such as a five-client pilot ([Rizvi and Linehan (2005), Cognitive and Behavioral Practice](https://doi.org/10.1016/S1077-7229(05)80071-9)), and nothing tested app use.

Already in the app:

- **Approach/Rest intervals** and **Task ladders**: a time-boxed "get active, approach", graded like DBT's build-mastery steps. The fit-the-facts judgement stays with the person.
- **Optional mood tags**: a light form of naming the emotion, never interpreted by the app.

Could inform:

- **Optional mood tags**: an optional one-word urge note at approach start ("stay in bed"), never scored.

Avoid:

- Branding features as DBT or "opposite action": the stand-alone evidence is preliminary.

## 6. Temptation bundling

Temptation bundling pairs an activity a person puts off with an enjoyable one available only, or mainly, while doing it; the original field study restricted tempting audiobooks to the gym. See [Milkman, Minson and Volpp (2014), Management Science](https://pmc.ncbi.nlm.nih.gov/articles/PMC4381662/).

Evidence: moderate. A randomised field experiment showed small gains in gym visits among existing members, which decayed weekly and vanished after a holiday closure. The app's arrangement, where rest is never restricted, is untested.

Already in the app:

- **Approach/Rest intervals** and **Presets**: a short "should" followed by a long "want", with nothing withheld. The mapping is structural; no reinforcing effect is claimed.
- **Snooze the approach**: keeps the pairing under the user's control; a sizeable minority rejected imposed restriction.

Could inform:

- **Music integration**: tag a playlist or podcast as approach-time, started with the approach and paused at rest, as a soft self-set rule.

Avoid:

- Locking content or the companion behind completing an approach: the locked condition decayed and vanished after a break.

## 7. Body doubling

Body doubling is a community-named practice, reported mostly by neurodivergent people, of starting or working on a task while someone else is present, in person or online. The main peer-reviewed evidence is one survey of 220 people; older research on mere presence finds small, task-dependent effects. See [Eagle, Baltaxe-Admony and Ringland (2024), ACM Transactions on Accessible Computing](https://doi.org/10.1145/3689648) and [Bond and Titus (1983), Psychological Bulletin](https://pubmed.ncbi.nlm.nih.gov/6356198/).

Evidence: weak. One descriptive survey, no controlled study of body doubling was found, no depression sample, and across 241 studies presence explains about 0.3% to 3% of performance variance.

Already in the app:

- None. Nothing in V1 is body doubling.

Could inform:

- **Body doubling / shared sessions**: a passive presence count ("3 others are in an approach"), shown only during an approach, with no chat, task names or completion status. Rest stays private.
- **AI companion**: a "just be here" option that says little.

Avoid:

- Accountability mechanics ("your partner is waiting", visible abandons): some respondents found a human double stressful, and fear of judgement is documented in this group.

## 8. Self-determination theory

Self-determination theory (SDT) holds that motivation and well-being are supported when three needs are met: autonomy (acting by one's own choice), competence (feeling effective at a well-pitched challenge) and relatedness (feeling connected). A meta-analysis of 128 experiments found expected rewards for an already-interesting task reduced later unprompted engagement, while positive feedback increased it. See [Ryan and Deci (2000), American Psychologist](https://pubmed.ncbi.nlm.nih.gov/11392867/) and [Deci, Koestner and Ryan (1999), Psychological Bulletin](https://pubmed.ncbi.nlm.nih.gov/10589297/).

Evidence: moderate. Decades of experiments support the model, but effects are small to moderate, the reward analysis was contested, and the tasks were interesting lab tasks rather than chores.

Already in the app:

- **Presets**, **Task ladders** and **Snooze the approach**: user-authored ratios, user-chosen challenge, and no demand without assent.
- **XP and levels**: an expected reward given on completion, the category found undermining, so a caution as much as a fit; no leaderboards and meaningful XP for one minute reduce the pressure.

Could inform:

- **AI companion**: prefer "that was five minutes beside the pile" over "I'm proud of you", which SDT treats as controlling.

## 9. Self-compassion after setbacks

Self-compassion means responding to one's own failures with kindness rather than harsh self-criticism. In small lab experiments a self-compassionate framing after failure led to more self-improvement effort than a self-esteem message, and students who forgave themselves for procrastinating procrastinated less before the next exam. See [Breines and Chen (2012), Personality and Social Psychology Bulletin](https://doi.org/10.1177/0146167212445599) and [Wohl, Pychyl and Bennett (2010), Personality and Individual Differences](https://doi.org/10.1016/j.paid.2010.01.029).

Evidence: weak. The re-engagement findings come from small undergraduate samples in single labs, and none tested non-judgement built into an interface.

Already in the app:

- **No-guilt history** and **XP and levels**: neutral logging, partial XP for starting, silent missed days and a multiplier that never resets remove app-side prompts for self-blame.
- **Snooze the approach**, **Task ladders** and **AI breakdown**: "not ready yet" and "too hard" are answered with time or a smaller step, not criticism.

Could inform:

- Post-abandon flow: straight into rest with a one-line log ("Ended at 1:40. Logged."), not a decision point. A hypothesis.

## 10. Gamification and streaks

Gamification adds points, levels, streaks and leaderboards to non-game apps to encourage repeated use. A review of 19 health studies found mostly positive or mixed short-term effects, and a field study found that a log showing a broken streak reduces later engagement. See [Johnson et al. (2016), Internet Interventions](https://pmc.ncbi.nlm.nih.gov/articles/PMC6096297/) and [Silverman and Barasch (2023), Journal of Consumer Research](https://academic.oup.com/jcr/article/49/6/1095/6623414).

Evidence: weak. The reviewed studies are short-term and could not isolate which element does what, and the broken-streak finding rests on one paper.

Already in the app:

- **XP and levels** and **No-guilt history**: a multiplier that never shows a broken state, and silent missed days. In the streak study 69% continued after a broken streak versus 93% with an intact one.

Could inform:

- **Sync and backup**: a failed restore that zeroes XP would show exactly the loss that reduces engagement; check that restore preserves the multiplier.

Avoid:

- Streak freezes or repair tokens: they presuppose a loss state, and repair only softens the effect (85% versus 93%).

## 11. Engagement, retention and the wellness boundary

Real-world use of consumer wellbeing apps is brief: across 93 popular apps, median 30-day retention was 3.3%. US guidance treats software limited to relaxation or stress claims, with no reference to a condition, as general wellness rather than a medical device. See [Baumel et al. (2019), Journal of Medical Internet Research](https://pmc.ncbi.nlm.nih.gov/articles/PMC6785720) and [FDA (2026), General Wellness: Policy for Low Risk Devices](https://www.fda.gov/regulatory-information/search-fda-guidance-documents/general-wellness-policy-low-risk-devices).

Evidence: moderate. The retention figures are well supported but descriptive, and the guidance describes policy, not outcomes.

Already in the app:

- **No-guilt history** and **XP and levels**: lapsing is the typical pattern, not a failure, and the never-resetting multiplier does not penalise intermittent use.
- **Alarms** and **AI breakdown**: the only prompts are session-bound sounds, and the AI never initiates.
- **Optional mood tags** and **Task ladders**: one optional word with no scores, and everyday activity with no reference to a condition.

Could inform:

- Store listing and onboarding: one line that the app is a timer and activity tool, not a medical device. The app's name references depression and deserves a deliberate review against the policy.

## 12. Work-rest intervals and the Pomodoro technique

The Pomodoro Technique divides work into fixed intervals, classically 25 minutes, each followed by a short break. A meta-analysis of breaks of ten minutes or less finds small self-reported gains in vigour and fatigue and no performance effect. See [Albulescu et al. (2022), PLOS ONE](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0272460), [Biwer et al. (2023), British Journal of Educational Psychology](https://cris.maastrichtuniversity.nl/en/publications/understanding-effort-regulation-comparing-pomodoro-breaks-and-sel) and [Smits, Wenzel and de Bruin (2025), Behavioral Sciences](https://pmc.ncbi.nlm.nih.gov/articles/PMC12292963/).

Evidence: weak. Micro-breaks have support for small self-report gains only; no study tested a short-work, long-rest ratio or a low-energy population.

Already in the app:

- **Approach/Rest intervals** and **Alarms**: the two-timer loop and its ring. The 20-30 minute rest sits outside the tested dose, so the app reuses the structure, not a dose.
- **Presets** and **Snooze the approach**: user-chosen ratios and extensions sit between the fixed and self-chosen designs the trials compared.

Could inform:

- Self-ended rest with an "I'm ready" button, since self-chosen timing did at least as well in two of three trials.

Avoid:

- Shipping 25/5 as the default or calling it the "correct" ratio: the one trial using exactly 25/5 (Smits et al.) found no overall difference from self-chosen timing, and the trial favouring fixed breaks (Biwer et al.) used 24/6 and 12/3, so nothing singles out 25/5.

## 13. Graded exposure and approach behaviour

Graded exposure breaks an avoided situation into a ladder of steps and keeps the person in contact with a step; current theory holds that strict order matters less than once assumed. In depression research, avoidance is proposed as one process that keeps low mood going. See [Craske et al. (2014), Behaviour Research and Therapy](https://pmc.ncbi.nlm.nih.gov/articles/PMC4114726/) and [Trew (2011), Clinical Psychology Review](https://doi.org/10.1016/j.cpr.2011.07.007).

Evidence: moderate for clinician-delivered exposure in anxiety; the depression link rests on one-time surveys plus theory, and no study tests a self-guided proximity timer.

Already in the app:

- **Task ladders** and **AI breakdown**: any rung allowed, since Craske et al. do not proceed linearly, plus intermediate steps on demand.
- **Approach/Rest intervals** and **Snooze the approach**: a bounded stay near an avoided cue that ends on time, not on feeling, one of Craske's behavioural end conditions.

Could inform:

- **AI companion**, **Music integration** and **Body doubling / shared sessions**: all are comforts that can blunt exposure learning, so keep each optional and never a condition for credit.

Avoid:

- Fear language ("face your fear", "confront the pile"): the app's target is low activation, not fear.

## 14. Saying intentions out loud

In motivational interviewing (MI) research, the share of a person's own speech favouring change ("change talk") is weakly associated with later change. Whether being heard by others helps is unsettled: four small experiments found intentions noticed by others were acted on less, while a 141-trial meta-analysis found publicly set goals more effective. See [Magill et al. (2018), Journal of Consulting and Clinical Psychology](https://pmc.ncbi.nlm.nih.gov/articles/PMC5958907/), [Gollwitzer et al. (2009), Psychological Science](https://www.psychologicalscience.org/journals/psychological-science/j.1467-9280.2009.02336.x/) and [Epton, Currie and Armitage (2017), Journal of Consulting and Clinical Psychology](https://research.manchester.ac.uk/en/publications/unique-effects-of-setting-goals-on-behavior-change-systematic-rev/).

Evidence: weak. The MI data are correlational (associations, not causes), with small effects (r = -.16; r is a correlation, and 0.1 is small). The backfire rests on 168 students in one lab, and nothing tests private self-statements in an app.

Already in the app:

- **Task ladders**: the rung "say out loud 'I'd like to do laundry'" is a private, self-written desire statement, the lowest-cost change talk. An analogy, not a tested effect.
- **Snooze the approach**, **AI breakdown** and **No-guilt history**: never asking for a reason, never persuading, and recording what happened rather than what was announced.

Could inform:

- **Task ladders**: an optional rung family from "I'd like to" through "I could" to "I will", with no strength treated as better.

## Things this app deliberately avoids

Merged from the lists above, with the techniques each item comes from.

- Streak loss, resets, decay to zero, or streak freezes and repair tokens. A broken-streak display lowers later engagement, a single missed day did not affect habit formation, and lapses are the norm for this app category. From: behavioural activation, Tiny Habits, self-compassion, gamification, engagement and retention.
- Rest as something to earn. The cited trials scheduled activities and did not withhold rest, and conditional rest becomes a reward given on completion. From: behavioural activation, opposite action, temptation bundling, self-determination theory, Pomodoro.
- Guilt, "should", consistency-pressure or cheerleading copy ("you promised", "you missed 3 days", "You're amazing"). Pressure makes action feel externally driven, and self-esteem praise did not produce the gains self-compassion did. From: behavioural activation, Tiny Habits, self-determination theory, self-compassion, saying intentions out loud.
- Locked rungs, mandatory order, automatic escalation, forced completion or obligatory continuation ("you've started, so keep going"). Ladders are difficulty orderings, not gates, and the bounded commitment is the point. From: behavioural activation, five-minute rule, Tiny Habits, opposite action, graded exposure.
- Mood-contingent prompting or interpreting mood tags, including telling the user a mood "does not fit the facts" or framing a gap as abnormal. Activities follow a plan, not a mood, that judgement belongs to the person, and a wellness product may not characterise output as abnormal. From: behavioural activation, opposite action, engagement and retention.
- Unsolicited notifications and re-engagement campaigns ("we miss you"). Nagging is what "AI never nags" rules out, and intermittent use is the norm. From: self-determination theory, gamification, engagement and retention.
- Public commitment, accountability partners, leaderboards, social comparison, and public rooms or chat by default. Exposing lapses invites evaluation, and the evidence on sharing intentions points both ways. From: every technique in this note.
- Mandatory plans or statements before a timer can start, or asking the user to explain a snooze. Forced entry reintroduces deliberation and invites arguing for staying put. From: implementation intentions, saying intentions out loud.
- Treatment, therapy or clinical language, including branding features as BA, DBT, motivational interviewing or exposure, "research-backed" copy, productivity claims and "66 days to a habit" countdowns. Every strong result here is guided, clinician-delivered work, and such claims take a product outside the wellness policy. From: every technique in this note.
- Markers on unfinished tasks, deadlines, countdowns, gated unlockables and randomised rewards. No reliable recall advantage was found for unfinished tasks, and locked content decayed and vanished after a break. From: five-minute rule, temptation bundling, gamification.
- Advertising the XP payout before a session as the reason to start. Expected rewards undermined later engagement, unexpected ones did not. From: self-determination theory.
- Shipping 25/5 as the default, treating five minutes as a minimum, or discarding a partial interval. Nothing singles out either number, and "does not count" is a loss mechanic. From: Pomodoro, five-minute rule.
- Distress ratings, ending on "feeling calmer", fear language, or making the companion, music or body doubling mandatory or XP-boosted. Within-session fear reduction does not predict later outcomes, and comforts are comforts only if optional. From: graded exposure, body doubling.
- Treating engagement, session count or daily opens as the design goal. Engagement does not necessarily contribute to wellbeing. From: self-determination theory, engagement and retention.

## What the ladder is, in these terms

In behavioural activation terms, a task ladder is graded task assignment: one avoided activity split into steps ranked by difficulty, with the aim of making contact rather than finishing. The approach interval is the scheduling half, a time-boxed slot that starts because the plan says so. In Tiny Habits terms, the lowest rungs are the behaviour shrunk to a bad-day size, and the rest-done sound is an available anchor for the next one. In five-minute-rule terms, every approach is the bounded commitment, shrunk to one or two minutes when five is too many. The exposure literature adds the ladder shape and the point that strict order matters less than once assumed, which is why any rung can be chosen. None of this has been tested as a self-guided timer, so the ladder is a way of counting small approaches, not a method with known effects.

## Sources

1. Martell, C. R., Dimidjian, S., & Herman-Dunn, R. (2021). Behavioral Activation for Depression: A Clinician's Guide (2nd ed.). The Guilford Press. <https://www.guilford.com/books/Behavioral-Activation-for-Depression/Martell-Dimidjian-Herman-Dunn/9781462548385>
2. Jacobson, N. S., Martell, C. R., & Dimidjian, S. (2001). Behavioral activation treatment for depression: Returning to contextual roots. Clinical Psychology: Science and Practice, 8(3), 255-270. <https://doi.org/10.1093/clipsy.8.3.255>
3. Ekers, D., et al. (2014). Behavioural Activation for Depression; An Update of Meta-Analysis of Effectiveness and Sub Group Analysis. PLOS ONE, 9(6), e100100. <https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0100100>
4. Lejuez, C. W., et al. (2011). Ten year revision of the brief behavioral activation treatment for depression: Revised treatment manual. Behavior Modification, 35(2), 111-161. <https://doi.org/10.1177/0145445510390929>
5. Ghibellini, R., & Meier, B. (2025). Interruption, recall and resumption: a meta-analysis of the Zeigarnik and Ovsiankina effects. Humanities and Social Sciences Communications, 12, 962. <https://doi.org/10.1057/s41599-025-05000-w>
6. Steel, P. (2007). The nature of procrastination: A meta-analytic and theoretical review of quintessential self-regulatory failure. Psychological Bulletin, 133(1), 65-94. <https://doi.org/10.1037/0033-2909.133.1.65>
7. Fogg, B. J. (2009). A behavior model for persuasive design. Persuasive '09, ACM, 1-7. <https://doi.org/10.1145/1541948.1541999>
8. Fogg, B. J. (2020). Tiny Habits: The Small Changes That Change Everything. Houghton Mifflin Harcourt. <https://books.google.com/books?vid=ISBN9780358003328>
9. Lally, P., et al. (2010). How are habits formed: Modelling habit formation in the real world. European Journal of Social Psychology, 40(6), 998-1009. <https://doi.org/10.1002/ejsp.674>
10. Gollwitzer, P. M., & Sheeran, P. (2006). Implementation intentions and goal achievement: A meta-analysis of effects and processes. Advances in Experimental Social Psychology, 38, 69-119. <https://doi.org/10.1016/S0065-2601(06)38002-1>
11. Toli, A., Webb, T. L., & Hardy, G. E. (2016). Does forming implementation intentions help people with mental health problems to achieve goals? A meta-analysis of experimental studies with clinical and analogue samples. British Journal of Clinical Psychology, 55(1), 69-90. <https://pubmed.ncbi.nlm.nih.gov/25965276/>
12. Linehan, M. M. (2015). DBT Skills Training Manual (2nd ed.). Guilford Press. <https://books.google.com/books?vid=ISBN9781462516995>
13. Linehan, M. M., et al. (2015). Dialectical Behavior Therapy for High Suicide Risk in Individuals With Borderline Personality Disorder: A Randomized Clinical Trial and Component Analysis. JAMA Psychiatry, 72(5), 475-482. <https://jamanetwork.com/journals/jamapsychiatry/fullarticle/2205835>
14. Harley, R., Sprich, S., Safren, S., Jacobo, M., & Fava, M. (2008). Adaptation of dialectical behavior therapy skills training group for treatment-resistant depression. Journal of Nervous and Mental Disease, 196(2), 136-143. <https://doi.org/10.1097/nmd.0b013e318162aa3f>
15. Rizvi, S. L., & Linehan, M. M. (2005). The treatment of maladaptive shame in borderline personality disorder: A pilot study of "opposite action". Cognitive and Behavioral Practice, 12(4), 437-447. <https://doi.org/10.1016/S1077-7229(05)80071-9>
16. Milkman, K. L., Minson, J. A., & Volpp, K. G. M. (2014). Holding the Hunger Games Hostage at the Gym: An Evaluation of Temptation Bundling. Management Science, 60(2), 283-299. <https://pmc.ncbi.nlm.nih.gov/articles/PMC4381662/>
17. Eagle, T., Baltaxe-Admony, L. B., & Ringland, K. E. (2024). "It Was Something I Naturally Found Worked and Heard About Later": An Investigation of Body Doubling with Neurodivergent Participants. ACM Transactions on Accessible Computing, 17(3), 1-30. <https://doi.org/10.1145/3689648>
18. Bond, C. F., & Titus, L. J. (1983). Social facilitation: A meta-analysis of 241 studies. Psychological Bulletin, 94(2), 265-292. <https://pubmed.ncbi.nlm.nih.gov/6356198/>
19. Ryan, R. M., & Deci, E. L. (2000). Self-determination theory and the facilitation of intrinsic motivation, social development, and well-being. American Psychologist, 55(1), 68-78. <https://pubmed.ncbi.nlm.nih.gov/11392867/>
20. Deci, E. L., Koestner, R., & Ryan, R. M. (1999). A meta-analytic review of experiments examining the effects of extrinsic rewards on intrinsic motivation. Psychological Bulletin, 125(6), 627-668. <https://pubmed.ncbi.nlm.nih.gov/10589297/>
21. Breines, J. G., & Chen, S. (2012). Self-compassion increases self-improvement motivation. Personality and Social Psychology Bulletin, 38(9), 1133-1143. <https://doi.org/10.1177/0146167212445599>
22. Wohl, M. J. A., Pychyl, T. A., & Bennett, S. H. (2010). I forgive myself, now I can study: How self-forgiveness for procrastinating can reduce future procrastination. Personality and Individual Differences, 48(7), 803-808. <https://doi.org/10.1016/j.paid.2010.01.029>
23. Johnson, D., et al. (2016). Gamification for health and wellbeing: A systematic review of the literature. Internet Interventions, 6, 89-106. <https://pmc.ncbi.nlm.nih.gov/articles/PMC6096297/>
24. Silverman, J., & Barasch, A. (2023). On or Off Track: How (Broken) Streaks Affect Consumer Decisions. Journal of Consumer Research, 49(6), 1095-1117. <https://academic.oup.com/jcr/article/49/6/1095/6623414>
25. Baumel, A., Muench, F., Edan, S., & Kane, J. M. (2019). Objective User Engagement With Mental Health Apps: Systematic Search and Panel-Based Usage Analysis. Journal of Medical Internet Research, 21(9), e14567. <https://pmc.ncbi.nlm.nih.gov/articles/PMC6785720>
26. U.S. Food and Drug Administration (2026). General Wellness: Policy for Low Risk Devices. Guidance for Industry and FDA Staff, January 6, 2026. <https://www.fda.gov/regulatory-information/search-fda-guidance-documents/general-wellness-policy-low-risk-devices>
27. Albulescu, P., et al. (2022). "Give me a break!" A systematic review and meta-analysis on the efficacy of micro-breaks for increasing well-being and performance. PLOS ONE, 17(8), e0272460. <https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0272460>
28. Biwer, F., Wiradhany, W., oude Egbrink, M. G. A., & de Bruin, A. B. H. (2023). Understanding effort regulation: Comparing 'Pomodoro' breaks and self-regulated breaks. British Journal of Educational Psychology, 93(S2), 353-367. <https://cris.maastrichtuniversity.nl/en/publications/understanding-effort-regulation-comparing-pomodoro-breaks-and-sel>
29. Smits, E. J. C., Wenzel, N., & de Bruin, A. (2025). Investigating the Effectiveness of Self-Regulated, Pomodoro, and Flowtime Break-Taking Techniques Among Students. Behavioral Sciences, 15(7), 861. <https://pmc.ncbi.nlm.nih.gov/articles/PMC12292963/>
30. Craske, M. G., Treanor, M., Conway, C., Zbozinek, T., & Vervliet, B. (2014). Maximizing exposure therapy: An inhibitory learning approach. Behaviour Research and Therapy, 58, 10-23. <https://pmc.ncbi.nlm.nih.gov/articles/PMC4114726/>
31. Trew, J. L. (2011). Exploring the roles of approach and avoidance in depression: An integrative model. Clinical Psychology Review, 31(7), 1156-1168. <https://doi.org/10.1016/j.cpr.2011.07.007>
32. Magill, M., et al. (2018). A meta-analysis of motivational interviewing process: Technical, relational, and conditional process models of change. Journal of Consulting and Clinical Psychology, 86(2), 140-157. <https://pmc.ncbi.nlm.nih.gov/articles/PMC5958907/>
33. Gollwitzer, P. M., Sheeran, P., Michalski, V., & Seifert, A. E. (2009). When intentions go public: Does social reality widen the intention-behavior gap? Psychological Science, 20(5), 612-618. <https://www.psychologicalscience.org/journals/psychological-science/j.1467-9280.2009.02336.x/>
34. Epton, T., Currie, S., & Armitage, C. J. (2017). Unique effects of setting goals on behavior change: Systematic review and meta-analysis. Journal of Consulting and Clinical Psychology, 85(12), 1182-1198. <https://research.manchester.ac.uk/en/publications/unique-effects-of-setting-goals-on-behavior-change-systematic-rev/>
