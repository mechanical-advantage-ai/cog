# Cog

**Autonomous software development by [Mechanical Advantage](https://mechanicaladvantage.ai).**

Cog turns GitHub issues into merged pull requests. You describe what you want; Cog implements the code, opens the PR, addresses review feedback, and merges when approved. It orchestrates whichever coding harness you already use — Claude Code, Codex CLI, Gemini CLI, OpenCode, or pi — across the full lifecycle from idea to merge.

- **Install:** [`curl ... | sh`](#install) (one-liner below)
- **Quickstart:** [`cog auth login` → `cog skills install` → `cog start`](#quickstart)
- **Pricing:** flat $10/month, unlimited repos — [details](https://mechanicaladvantage.ai/pricing)
- **Full docs:** [mechanicaladvantage.ai/docs/quickstart](https://mechanicaladvantage.ai/docs/quickstart) · [Command reference](https://mechanicaladvantage.ai/docs/commands)

---

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/mechanical-advantage-ai/cog/main/install.sh | sh
```

The script downloads the right `cog` binary for your platform, installs it to `~/.cog/bin`, and adds that directory to your `PATH`. Restart your shell after installation, then verify:

```sh
cog --version
```

### Manual install

If you'd rather not pipe `curl` into a shell, grab the archive for your platform from the [Releases page](https://github.com/mechanical-advantage-ai/cog/releases/latest), extract the `cog` binary, and place it on your `PATH`. The release archives include SHA-256 checksums you can verify against `checksums.txt`.

### Auto-update

Cog checks for new releases in the background (about once a day) and applies the next version on the following run. You can also update on demand:

```sh
cog update
```

## Supported platforms

- macOS — Apple Silicon (`arm64`) and Intel (`amd64`)
- Linux — `amd64` and `arm64`
- Windows — `amd64` and `arm64`, via WSL, Git Bash, or MSYS2

## Prerequisites

Cog orchestrates a coding harness; it doesn't do the coding itself. Before you run `cog start` you need:

- **A supported coding harness, installed and authenticated.** Any of:
  - [Claude Code](https://docs.anthropic.com/claude/docs/claude-code)
  - [Codex CLI](https://github.com/openai/codex)
  - [Gemini CLI](https://github.com/google-gemini/gemini-cli)
  - [OpenCode](https://opencode.ai/)
  - [pi](https://pi.dev) — install with `curl -fsSL https://pi.dev/install.sh | bash`
- **[GitHub CLI (`gh`)](https://cli.github.com/) authenticated with repo access** (`gh auth login`). Cog uses `gh` for every issue and PR operation.
- **A `git` repository with a GitHub remote.** Cog discovers the repo from your working directory and reads its remote to determine the owner and repo name.
- **A Mechanical Advantage account.** Sign up at [app.mechanicaladvantage.ai](https://app.mechanicaladvantage.ai) and add a payment method, then run `cog auth login` — approving the device activates your $10/month Cog subscription.

## Quickstart

Three commands take you from zero to a Cog instance running against your repo:

```sh
cog auth login           # device authorization flow; activates your subscription
cog skills install       # install /cog-capture and /cog-shape into your harness
cog start                # priority loop: merge → revise → build
```

Run `cog start` from inside the repo you want Cog to work on. Leave it running — it will keep picking up approved PRs to merge, PRs needing revision, and unassigned issues to build. `Ctrl-C` stops it cleanly and leaves any in-flight worktrees intact for resume.

For the full walkthrough — filing your first issue with `/cog-capture`, reviewing the resulting PR, and what to expect on each phase — see the [Quickstart](https://mechanicaladvantage.ai/docs/quickstart).

## Commands

Cog ships as a single `cog` binary with subcommands. Each one-liner below comes straight from `cog <command> --help`; run that for full flag documentation, or see the [Command reference](https://mechanicaladvantage.ai/docs/commands) for examples and expected behavior.

### Lifecycle

| Command | Purpose |
|---|---|
| `cog start [issue-numbers...]` | Run the priority loop continuously. |
| `cog build [issue-number]` | Implement a GitHub issue. |
| `cog revise` | Address review feedback on PRs. |
| `cog merge` | Shepherd approved PRs to merge. |

`cog start` runs `merge`, then `revise`, then `build` in a single sequential loop — finishing existing work always takes precedence over starting new work.

### Skills (interactive)

| Command | Purpose |
|---|---|
| `cog skills install` | Install cog skills into a harness. |
| `cog skills uninstall` | Remove cog-installed skills from a harness. |
| `cog skills list` | List installed cog skills. |

`cog skills install` adds two slash commands to your harness:

- **`/cog-capture`** — turn a bug report or feature idea into a well-scoped GitHub issue.
- **`/cog-shape`** — Socratic decomposition of a complex idea into a set of ordered, implementable issues.

These run inside your harness's TUI (e.g., type `/cog-capture` in Claude Code). They are not `cog` subcommands and there is no `cog capture` or `cog shape` — capture and shape happen where you're already typing, using the harness's native rendering, input handling, and tool use.

### Inspection

| Command | Purpose |
|---|---|
| `cog status` | Show worktrees, PR states, and running instances. |
| `cog log [issue-number]` | Stream or review an issue log. |
| `cog claims` | Manage remote work-item claims. |
| `cog clean` | Prune orphaned worktrees. |

### Multi-harness experimentation

| Command | Purpose |
|---|---|
| `cog arena [issue-number]` | Run multiple candidates for one issue; a judge synthesizes the final PR. |
| `cog arena stats` | Aggregate arena attribution data across runs. |

Arena runs several harnesses against the same issue in parallel and has a judge harness synthesize a best-of-breed solution into a single PR. Use it for complex or high-stakes issues where the cost of running N harnesses is justified by higher quality.

### Reviewer-side helpers

| Command | Purpose |
|---|---|
| `cog respond [pr-number]` | Address review feedback on a single PR. |
| `cog review` | Run a read-only review against the working tree diff. |
| `cog rubber-stamp` | Auto-approve PRs awaiting review. |

### Config and meta

| Command | Purpose |
|---|---|
| `cog config` | Manage cog configuration. |
| `cog auth login` | Start the device authorization flow. |
| `cog auth logout` | Clear stored credentials. |
| `cog auth status` | Show authentication state. |
| `cog feedback` | Submit and track feedback. |
| `cog feedback submit` | Submit feedback. |
| `cog update` | Update cog to the latest version. |
| `cog stop` | Stop all running cog processes for the current repo. |

For full flag listings on any command, run `cog <command> --help`.

## Configuration

Cog stores configuration at `~/.config/cog/config.yaml`. Inspect or modify it with:

```sh
cog config list            # show every key and its current value
cog config get <key>       # print one value
cog config set <key> <val> # update one value
```

Common keys:

| Key | Purpose |
|---|---|
| `default-harness` | Harness and model used for build / revise / merge. Form: `harness@model[:variant]` (e.g., `claude@claude-opus-4-7`, `codex@gpt-5.5`, `opencode@anthropic/claude-opus-4-7:max`). |
| `judge-harness` | Harness and model used by `cog arena` to synthesize the final PR. |
| `review-harness` | Harness and model invoked by `cog build`'s external review step. Optional — when unset, self-review alone gates push. |
| `slack-webhook` | Slack incoming-webhook URL for build success and failure notifications. |
| `setup-script` | Script run inside fresh worktrees after creation (e.g., to copy `.env` files or install dependencies). |
| `arena-mode` | Make `cog start` default to arena-mode builds (`true`/`false`). |
| `max-turns.{build,revise,merge}` | Per-phase turn caps. |
| `timeout.{build,revise,merge}` | Per-phase wall-clock timeouts (e.g., `1h`, `30m`). |

Run `cog config list` to see every configurable key.

## How it works

Cog covers the development lifecycle in five phases. Two are interactive skills that live inside your harness; three are autonomous and run as a priority loop.

**Capture (skill).** A developer encounters a bug or has a feature idea. The skill helps them investigate the codebase, ask the right clarifying questions, check for duplicates, and file a well-documented GitHub issue grounded in technical reality. Output: a high-quality issue ready for autonomous implementation.

**Shape (skill).** A developer has a complex or nebulous idea — "we need multi-tenant billing" — but doesn't know how to break it down. The skill investigates the codebase, then runs a Socratic conversation: challenging assumptions, surfacing trade-offs, asking "what's the smallest version that would be useful?" When the scope is clear, it decomposes the work into ordered, implementable GitHub issues.

**Build (autonomous).** Cog watches for unassigned issues. When one appears, it self-assigns, creates a worktree and branch, explores the codebase, builds an implementation plan, writes the code, runs format / lint / tests until green, performs a self-review (and optionally an external review by a different harness), commits, pushes, opens a PR, and handles the Copilot review cycle.

**Revise (autonomous).** When a reviewer requests changes, Cog picks up the PR, reads every comment, categorizes each one, implements the fixes, runs checks, pushes a fix commit, replies to each thread with what it did, resolves the threads, and requests re-review.

**Merge (autonomous).** Once a PR is approved, Cog merges `main` into the branch, resolves any conflicts, fixes CI failures caused by the merge, handles any post-push automated review, and squash-merges when everything is green.

Cog resumes the original harness session for revise and merge, so the harness has full context of why the code was written the way it was — no cold-start re-learning.

For more on principles, the quality pipeline, and the multi-instance coordination model, see the [vision document](https://mechanicaladvantage.ai/about) and the [Quickstart](https://mechanicaladvantage.ai/docs/quickstart).

## Pricing

**$10/month, flat. Unlimited repos.**

You bring your own coding-harness subscription (Claude Code, Codex CLI, Gemini CLI, OpenCode, or pi) and your own GitHub access. Cog provides the orchestration. No tiers, no per-seat pricing, no usage metering.

See [mechanicaladvantage.ai/pricing](https://mechanicaladvantage.ai/pricing) for details.

## Links

- **Marketing site** — [mechanicaladvantage.ai](https://mechanicaladvantage.ai)
- **Quickstart** — [mechanicaladvantage.ai/docs/quickstart](https://mechanicaladvantage.ai/docs/quickstart)
- **Command reference** — [mechanicaladvantage.ai/docs/commands](https://mechanicaladvantage.ai/docs/commands)
- **Pricing** — [mechanicaladvantage.ai/pricing](https://mechanicaladvantage.ai/pricing)
- **Releases / changelog** — [github.com/mechanical-advantage-ai/cog/releases](https://github.com/mechanical-advantage-ai/cog/releases)
- **Install script** — [`install.sh`](./install.sh) in this repo
