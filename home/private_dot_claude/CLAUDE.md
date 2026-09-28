@~/.agents/AGENTS.md

## Shell mode

- The `!` prefix runs a command inside this session with no TTY and the same filesystem and network access you have. It is not an interactive shell and grants the user no extra access — it only skips your permission prompts.
- When a command needs a terminal (an interactive prompt, a login flow, an editor, a TUI) or access you lack, ask the user to run it in a separate terminal. Do not suggest `!` for those.
- Suggesting `!` is fine for a non-interactive command the user wants to run themselves and have the output land in the session.
