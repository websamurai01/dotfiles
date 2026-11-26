# AGENTS.md

## NixOS environment

This machine is a sandboxed MicroVM guest called `box` running NixOS (`~/nix-tree/hosts/box/box.nix`) within a NixOS host called `home` (`~/nix-tree/hosts/home/home.nix`). You don't have access to any of my secrets or my ssh keys, acknowledge that when trying to use them (e.g. `git push`, etc.).

When testing the Nix configuration, prefer using `nix eval` (option values, derivations, paths) instead of `nix build`/`nixos-rebuild switch`. Build wastes time and traffic.

## No Heredoc

- You are absolutely forbidden to use heredoc pattern when working with files. Never use heredoc `bash` or `python` for reading, writing, and editing files. Always use tooling provided to you by the harness you're in. Always prefer `edit` over full unnecessary `write` pass to save tokens and reduce LoC churn.

## Harness Tooling Use

- For any inline comments and user facing strings ALWAYS use `/skill:simple-english`
- Use `ponytail` skill heavily when deciding *how* to implement anything.

## Preferred Shell Programs

- Please use `fd` instead of `find`, and `rg` instead of `grep` when using `bash` tool.

## Output Standards

- Avoid superlatives and praise. Stop telling me I am absolutely right. Give me the cold hard truth.
- I am running fish shell on all of my systems. If you return ANY shell commands for **me** to run, make sure they are written in fish.

## EGM (Elephant-Goldfish Model)

EGM is installed at `~/.pi/agent/git/github.com/google/elephant-goldfish-model` and loads as the `egm-*` skills (`/skill:egm-review`, `/skill:egm-draft`, …).

- When an EGM skill says "spawn a subagent", use the `subagent` tool with the `egm-*` agent names (`egm-zoom-out`, `egm-design`, `egm-comprehension`, `egm-structural`, `egm-style`, `egm-implementation-readiness`, `egm-codebase-details`, `egm-inventive-catalyst`, `egm-synthesizer`, `egm-bootstrap-orchestrator`).
- Reviewers are read-only (`read, grep, find, ls`) and pinned to `openrouter/deepseek/deepseek-v4.1-flash-1017`.
- Pass absolute paths for persona files and document standards; the plugin root is `~/.pi/agent/git/github.com/google/elephant-goldfish-model`.
- Prefer direct dispatch over `egm-synthesizer`: every reviewer is then a direct child and its cost lands in the session total.
