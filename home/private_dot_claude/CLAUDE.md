@~/.agents/AGENTS.md

## Memory

- Never write to your own memory. Do not create, update, or delete memory files, and do not add entries to the memory index. If something seems worth persisting, say so in the reply and let the user decide.

## Clarifying questions

- When a request is ambiguous or under-specified, use the question tool to gather the missing context instead of guessing.
- Ask across multiple turns if one round is not enough — do not begin work that depends on an unanswered question.

## Shell mode

- The `!` prefix runs a command inside this session with no TTY and the same filesystem and network access you have. It is not an interactive shell and grants the user no extra access — it only skips your permission prompts.
- When a command needs a terminal (an interactive prompt, a login flow, an editor, a TUI) or access you lack, ask the user to run it in a separate terminal. Do not suggest `!` for those.
- Suggesting `!` is fine for a non-interactive command the user wants to run themselves and have the output land in the session.
