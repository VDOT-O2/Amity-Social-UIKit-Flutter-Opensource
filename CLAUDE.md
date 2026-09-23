# socialplus-flutter

Fork of the Amity UIKit Flutter package (`amity_uikit_beta_service`) — the social feature UI the V.O2 app embeds.

When asked to remember a new instruction, convention, or rule for this repository, write it to this file.

## Coding conventions

### Comments

- Default to no comment. Code should read on its own; a comment is the exception, not the finishing touch on a change.
- Do not comment minor UI tweaks, layout adjustments, or straightforward bug fixes. The diff and the commit message already say what changed.
- Do comment when the *why* is genuinely non-obvious and expensive to rediscover: a workaround for a platform/framework bug, an ordering or lifecycle constraint, a non-obvious API contract, or a deliberate deviation from the surrounding pattern.
- Never write a comment that restates the line below it, or that narrates the change ("now uses X so it doesn't Y") rather than the current state of the code.
- Match the comment density of the surrounding file. If neighbouring code has none, don't add any.
- No explanatory comments on individual arguments, properties, or fields that just spell out why a value is what it is right now. If the reasoning matters, it belongs in the method/class doc or a decision note — not inline next to the property. A two- or three-word label on a parameter (`// test seam`) is fine; a sentence is not.
- Keep comments short. When one is warranted, one line is usually enough; don't write a paragraph.
- Do not justify a guard, condition, or early return with a comment — `if (amount > 0)` needs no note explaining why zero is excluded. The condition is the explanation.
- Do not use a comment to explain the bug a fix prevents, or to give a worked example of the case that broke. That belongs in the commit message and the test name, not the source.
- Put the explanation next to the code it explains — the branch, the constant, the condition — not on a factory, wrapper, or signature that only forwards the value.
- Don't explain an obvious default, such as a nullable parameter falling back to production behaviour. The `??` is the explanation.
- Setup or reporting steps that live outside the codebase (a dashboard to configure, a dimension to register) belong in the handover notes, not in a source comment.
- Before leaving any comment, check it against the rules above and delete it unless it clearly earns its place. When in doubt, no comment.
