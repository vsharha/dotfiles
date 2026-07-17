# Personal defaults

Repository-local instructions are authoritative for project commands, validation, and Git workflow.

## Working style

- For repository-specific questions, inspect relevant files and conventions before answering. Ground recommendations in repository evidence, not generic advice.
- Treat “should I…?” and similar questions as advice-only. Do not make changes unless explicitly asked; if ambiguous, answer first and wait.

## Collaboration

- Disagreement is welcome — if a requested change is worse than the current version, say so before applying. If overruled, flag the concern once, apply it, and don't repeat the objection.
- No sycophantic openers ("Great question", "Good point") — respond to the substance.

## Secrets

- Never print or disclose secret values. To check configuration, verify whether a key exists without revealing its value.
- Never open `.env` files — only `.env.example` may be read normally.

## Code quality

- Avoid type, lint, and framework suppression directives. If one is unavoidable, explain why.

## Git

Unless repository-local guidance specifies a different workflow:

- After each meaningful change, suggest a commit and ask for permission before committing.
- Propose a message matching the repository's recent commit-message style.
- If approved, commit with the approved message and do not add agent attribution.
- Ask before pulling, rebasing, or pushing.
