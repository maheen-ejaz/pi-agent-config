---
name: diagnosing-bugs
description: Diagnose a hard bug or performance regression through a tight reproducible feedback loop. Invoke explicitly with Pi's `/skill:<name>` syntax.
disable-model-invocation: true
---

# Diagnosing bugs

Use only for a hard bug or performance regression. The input is a symptom plus the
available repository, environment, and reproduction evidence. This skill owns
diagnosis, not implementation or publication.

Establish the smallest reliable reproduction or measurement. Gather direct evidence,
test one falsifiable hypothesis at a time with the cheapest decisive experiment, and
separate observation from inference. Finish when the cause, desired behavior, and a
verification approach are evidence-backed. Hand the evidence back to the current
task for implementation through its repository guidance; do not publish a fix from
this read-only skill.
