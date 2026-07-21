# claude-teamlead

A [Claude Code](https://code.claude.com) skill that turns the main agent into a **team lead**: it never does the work itself — it splits tasks, dispatches sub-agent "workers" in the background, picks the right model + effort for each job, and stays free so you can keep talking to it while work runs.

Ships three things in one skill:

- **Orchestration mode** — aggressive background delegation; the main thread never blocks.
- **`/teamlead brainstorm`** — a real multi-agent brainstorming session (N independent thinkers × M rounds, overlapping lenses, questions asked back to you between rounds, a final Opus verifier, and a saved plan).
- **`/teamlead superdoc`** — sets up / audits / repairs a project's self-maintaining docs system (a `superdoc/` folder by default, or `docs/`) so new agents never have to guess *why* something was built the way it is.

> ⚠️ Personal tooling, not battle-tested. `superdoc` hasn't been run end-to-end against a real repo yet. Use on projects you can `git`-revert.

---

## Requirements

- **Claude Code** (CLI, desktop, or IDE extension).
- Models: the workers pin **Opus** and **Sonnet** at specific reasoning-effort levels via agent frontmatter, so you need access to both.

---

## Install

```bash
git clone https://github.com/Ritze03/claude-teamlead.git
cd claude-teamlead
```

Then run the installer for your OS — it copies the skill + 3 worker agents into your Claude config dir (`~/.claude`, or `%USERPROFILE%\.claude` on Windows; honors `CLAUDE_CONFIG_DIR`).

**macOS / Linux**
```bash
./install.sh
```

**Windows (PowerShell)**
```powershell
./install.ps1
```

**Or install by hand** — copy these into your Claude config dir, preserving structure:
- `agents/tl-*.md` → `~/.claude/agents/`
- `skills/teamlead/` → `~/.claude/skills/teamlead/`

**Then restart Claude Code** (custom agents + skills load at session start) and run `/teamlead`.

---

## Usage

| command | what it does |
|---|---|
| `/teamlead` | Turn on team-lead mode (persistent until `stop`). |
| `/teamlead stop` | Turn it off. |
| `/teamlead help` | Print the command + glyph reference. |
| `/teamlead brainstorm <agents> <iterations> <topic>` | Multi-agent brainstorm. Numbers are **agents first, iterations second**; free text works. e.g. `/teamlead brainstorm 5 2 improve the auth flow` |
| `/teamlead superdoc [path]` | Set up / audit / repair a project's docs system — a `superdoc/` folder by default, or `docs/`. Also fires on `/superdoc` or "init superdoc". |

**Glyphs:** 🧭 orchestrating · 🧠 brainstorm · 📄 superdoc · ✅ activated · ❌ deactivated · 🚩 tripwire · ⚠️ needs your input.

### Model / effort routing

Effort can't be set per-call in Claude Code — it comes from agent frontmatter — so each model+effort combo is its own worker agent:

| worker | model · effort | used for |
|---|---|---|
| `tl-sonnet-medium` | Sonnet · Medium | reading, research, info-gathering, small/UI edits |
| `tl-sonnet-high` | Sonnet · High | writing non-trivial code from a given plan; heavier UI |
| `tl-opus-high` | Opus · High | reasoning, bug fixes, unclear/architectural edits, image analysis, UI logic, scouting, QC |

The lead routes automatically (unclear/risky → an Opus scout first, then the recommended worker). You can always override by naming a model/effort.

---

## How it works

- **Stay unblocked** — workers run in the background; the lead chains dependent steps on completion events instead of freezing. It posts a short heads-up before each dispatch and a summary when results land.
- **Split for throughput** — when the same instructions apply across many units (dates, subdirectories, files, modules), it fans out one worker per unit instead of grinding serially. One writer per file; concurrent writers use worktree isolation.
- **Retry ladder + QC** — a Sonnet worker self-checks, gets one correction attempt, then escalates to Opus; non-trivial work gets an Opus QC pass.
- **superdoc** models its output on a hand-built reference docs system: a hub `overview.md`, a terminology glossary, a styling guide, per-capability pages with inline `Why:` notes, and a thin `CLAUDE.md` that force-loads only the must-read rules. The doc-root folder (default `superdoc/`, or `docs/`) and version policy (default date-based, or auto-bump / manual) are chosen per project and stored in-repo. Run it in an empty repo and it lays just the ground structure (skeleton + force-loaded discipline) so everything built afterward is documented as it lands.

---

## Layout

```
agents/
  tl-opus-high.md          # Opus · High worker
  tl-sonnet-high.md        # Sonnet · High worker
  tl-sonnet-medium.md      # Sonnet · Medium worker
skills/teamlead/
  SKILL.md                 # doctrine + inline modes (normal · brainstorm · superdoc)
  superdoc-playbook.md     # worker knowledge base for building docs
  superdoc-assets/         # files copied verbatim into target repos
    documentation.md
    version-policy-date-based.md
    version-policy-auto-bump.md
    version-policy-manual.md
install.sh / install.ps1   # copy into ~/.claude
```

## License

MIT — see [LICENSE](LICENSE).
