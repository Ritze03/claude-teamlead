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
- Models: the workers pin **Opus 5** and **Sonnet 5** (by exact model ID) at specific reasoning-effort levels via agent frontmatter, so you need access to both. Sonnet 5 is the default; Opus is reserved for advanced reasoning and escalation.

---

## Install

```bash
git clone https://github.com/Ritze03/claude-teamlead.git
cd claude-teamlead
```

Then run the installer for your OS — it copies the skill + 6 worker agents into your Claude config dir (`~/.claude`, or `%USERPROFILE%\.claude` on Windows; honors `CLAUDE_CONFIG_DIR`).

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
| `/teamlead effort <xlow\|low\|medium\|high\|xhigh>` | Bias this project's worker model/effort routing (persisted). No argument reports the current setting. |
| `/teamlead opus <role-dependant\|on-demand\|never>` | Set this project's Opus policy for **workers** (persisted). The lead's own model is unaffected. No argument reports the current setting. |

**Glyphs:** 🧭 orchestrating · 🧠 brainstorm · 📄 superdoc · ✅ activated · ❌ deactivated · 🚩 tripwire · ⚠️ needs your input.

### Model / effort routing

Effort can't be set per-call in Claude Code — it comes from agent frontmatter — so each model+effort combo is its own worker agent:

| worker | model · effort | used for |
|---|---|---|
| `tl-sonnet-low` | Sonnet 5 · Low | cheapest tier — trivial/mechanical: one-line edits, run-a-command-and-report, simple lookups |
| `tl-sonnet-medium` | Sonnet 5 · Medium | reading, research, info-gathering, bounded scouting, small/UI edits |
| `tl-sonnet-high` | Sonnet 5 · High | **the default workhorse** — non-trivial code from a plan, bug fixes, UI logic, unclear-but-bounded edits, default QC |
| `tl-opus-low` | Opus 5 · Low | the cheapest Opus tier — a lightweight Opus-level judgment call, or the lightest rung of Opus escalation |
| `tl-opus-medium` | Opus 5 · Medium | a lighter escalation step below `tl-opus-high`, or a first Opus try before paying for high effort |
| `tl-opus-high` | Opus 5 · High | **advanced reasoning only** — hard architecture/design, ambiguous cross-system debugging, image analysis, and the escalation target when Sonnet fails twice |

**Sonnet 5 is the default worker**; Opus is opt-in for advanced reasoning and the escalation ceiling — not the default whenever a path is merely "unclear." The lead routes automatically (unclear/risky → a Sonnet scout first, then the recommended worker; QC defaults to Sonnet, Opus only for high-stakes work). You can always override by naming a model/effort.

Each project can also bias this routing with `/teamlead effort <xlow|low|medium|high|xhigh>` — `low`/`medium`/`high` shift the default worker a rung down/unchanged/up the ladder above, `xlow`/`xhigh` additionally hard-disable the High/Low tier outright.

A separate `/teamlead opus <role-dependant|on-demand|never>` dial controls whether **worker** dispatch can reach Opus at all: `role-dependant` (default) matches the routing above; `on-demand` makes Opus fallback-only (never first-choice, only after a Sonnet worker actually fails); `never` removes Opus workers entirely — a stuck Sonnet worker asks the lead directly instead of escalating, and the lead reasons through just that one blocker before handing it back. This doesn't touch the lead's own model, only workers.

Both settings are asked once via a prompt on a project's first `/teamlead` run, then persisted together in `.claude/teamlead.md`.

---

## How it works

- **Stay unblocked** — workers run in the background; the lead chains dependent steps on completion events instead of freezing. It posts a short heads-up before each dispatch and a summary when results land.
- **Split for throughput** — when the same instructions apply across many units (dates, subdirectories, files, modules), it fans out one worker per unit instead of grinding serially. One writer per file; concurrent writers use worktree isolation.
- **Retry ladder + QC** — a Sonnet worker self-checks, gets one correction attempt, then escalates to Opus (this is the main road to Opus); non-trivial work gets a QC pass, on Sonnet by default and Opus only for high-stakes changes.
- **superdoc** models its output on a hand-built reference docs system: a hub `overview.md`, a terminology glossary, a styling guide, per-capability pages with inline `Why:` notes, and a thin `CLAUDE.md` that force-loads only the must-read rules. The doc-root folder (default `superdoc/`, or `docs/`) and version policy (default date-based, or auto-bump / manual) are chosen per project and stored in-repo. Run it in an empty repo and it lays just the ground structure (skeleton + force-loaded discipline) so everything built afterward is documented as it lands.

---

## Layout

```
agents/
  tl-opus-high.md          # Opus 5 · High worker (advanced reasoning / escalation)
  tl-opus-medium.md        # Opus 5 · Medium worker (lighter escalation step)
  tl-opus-low.md           # Opus 5 · Low worker (cheapest Opus tier)
  tl-sonnet-high.md        # Sonnet 5 · High worker (default workhorse)
  tl-sonnet-medium.md      # Sonnet 5 · Medium worker
  tl-sonnet-low.md         # Sonnet 5 · Low worker (trivial/mechanical)
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
