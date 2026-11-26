---
name: commit-rules
description: Specific rules for writing commit messages
argument-hint: "Which rules do i use for writing commits?"
---

When you write a commit message, follow these rules:

- Separate the subject line from the body with a single blank line.
- Write subject line in strict lowercase (except literal string references from code itself), keep body normal.
- Limit the subject line to 50 characters (72 is the absolute hard limit).
- Do not end the subject line with a period.
- Use the imperative mood in the subject line (e.g., "Fix bug," "Add feature," not "Fixed" or "Adds"). Test formula: It must complete the sentence: "If applied, this commit will [your subject line here]".
- Wrap the body text manually at 72 characters to prevent Git formatting issues.
- Use the body to explain what and why vs. how. Assume the code explains the how; the message must explain the context and reasoning. 

