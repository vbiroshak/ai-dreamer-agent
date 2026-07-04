# AI Dreamer Agent

A memory consolidation agent for Claude Code. It runs a reflective pass over your project's memory files — merging new signal from session logs, pruning stale facts, and reconciling memories against governing documents.

Designed to work with the [AI Project Architect](https://github.com/vbiroshak/ai-project-architect) system, but adaptable to any Claude Code project with an auto-memory directory.

## Files

| File | What it is | Where to install |
|------|-----------|-----------------|
| `dreamer.md` | Agent prompt (fill variables, then place) | `~/.claude/agents/dreamer.md` or `.claude/agents/dreamer.md` |
| `dreamer-guard.sh` | Hook script — restricts writes to memory directory | Anywhere on your machine; reference its path in the agent's `${HOOK_PATH}` |
| `dream-skill.md` | `/dream` slash command — dispatches the agent | `~/.claude/skills/dream/SKILL.md` or `.claude/skills/dream/SKILL.md` |

## Usage

Once installed, type `/dream` in any Claude Code session. The agent runs in the background, consolidates recent session work into your memory files, and returns a summary.

## Variables

Replace these in `dreamer.md` before installing. The table shows what each variable means generically and how the AI Project Architect system fills it.

| Variable | Generic concept | Architect mapping |
|----------|----------------|-------------------|
| `${MODEL}` | Claude model to run the agent on | `claude-opus-4-6` |
| `${EFFORT}` | Reasoning effort level | `medium` |
| `${HOOK_PATH}` | Absolute path to `dreamer-guard.sh` on your machine | `~/.claude/hooks/dreamer-guard.sh` |
| `${MEMORY_DIR}` | Directory where memory files live. Default: `~/.claude/projects/<project>/memory/`; overridden by `autoMemoryDirectory` in `.claude/settings.json` | `Project/Claude Memory/` |
| `${MEMORY_INDEX}` | Filename of the memory index inside the memory directory | `MEMORY.md` |
| `${INDEX_MAX_LINES}` | Maximum lines for the memory index (Claude's context loads it every turn) | `200` |
| `${SESSION_LOGS}` | Directory of curated session logs (one file per session, decisions and state changes) | `Project/Session Logs/` |
| `${READABLE_TRANSCRIPTS}` | Directory of rendered session transcripts (.md, one per session) | `Project/Sessions/` |
| `${RAW_TRANSCRIPTS}` | Directory of raw transcript files (.jsonl) for grep searches | `~/.claude/projects/<slug>/` |
| `${RECALL_SUMMARIES}` | Optional: directory of per-session topic-unit digests (if you use a recall/embedding system) | `.recall/summaries/` |
| `${GOVERNING_DOCS}` | Project's governing documents to reconcile memories against | `PROJECT_CONTEXT.md` + output style file |
| `${ADDITIONAL_CONTEXT}` | Optional: extra instructions appended at invocation time (leave empty if unused) | (empty) |

## Prerequisites

- Claude Code with agent support
- `jq` installed (used by the guard hook)
- Auto memory enabled (default) — the guard hook finds the memory directory automatically, or reads `autoMemoryDirectory` from `.claude/settings.json` if you've redirected it
- Session logs that the agent can read for recent signal

## How it works

The agent runs five phases:

1. **Orient** — reads existing memories and determines the signal window (sessions since last dream)
2. **Gather** — reads session logs and other sources for new information worth persisting
3. **Consolidate** — writes or updates memory files with new signal
4. **Prune** — keeps the memory index concise and resolves contradictions
5. **Reconcile** — checks memories against governing documents for drift

A `.dream-state` file in the memory directory tracks where the last dream stopped, so subsequent runs pick up only new sessions.

## Contributing

This is a project I maintain for my own work. Hopefully you find it useful and can adapt it to yours. If you run into problems or have suggestions, open an issue on the repo.

## Credits

The memory-consolidation ("dream") behavior this agent implements is adapted from Claude Code's own dream/memory prompts, as documented in the [claude-code-system-prompts](https://github.com/Piebald-AI/claude-code-system-prompts) repository (© 2025 Piebald LLC, MIT License). See [LICENSE](LICENSE) for the full third-party notice.

## License

[MIT](LICENSE)

---
*Part of [AI Dreamer Agent](https://github.com/vbiroshak/ai-dreamer-agent) — Version 1.0*
