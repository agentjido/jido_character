# Character v3 compatibility result

Starting branch: `main`. Starting revision: `39ebc771b102ff786ace00021c4503695c470d62`.
The primary branch was retained to preserve local and concurrent work.
The delivery report names the exact published branch and commit.

Status: checked v3 source candidate.

## Boundary and implementation

This is a dependency migration from Zoi 0.18 and ReqLLM 1.29. Character keeps
its public construction, validation, update, rendering, and persistence APIs.
The manifest now requires Zoi `~> 0.19.0` and ReqLLM `~> 1.30`. The lock also
updates JSV, LLMDB, NimbleOptions, and the required Decimal dependency.
The new consumer fixture passes a rendered ReqLLM context into
`Jido.AI.Context.new/1`; it checks valid updates and invalid input without a
model call. No direct workspace package consumer of Character was found.

## Checks

- Isolated owning copy `/private/tmp/five-v3/character`: `mix deps.update zoi req_llm`, then `mix deps.get`.
- `mix test`: 258 passed.
- `mix quality`: passed, including Dialyzer. It ran in the isolated copy.
- `integration/jido_v3`: `mix deps.get`, `mix deps.unlock --unused`, `mix test`: 1 passed.
- `mix hex.build`: passed. The explicit fixture file list excludes its generated `deps` and `_build` trees.

Initial Zoi-only resolution failed because locked ReqLLM 1.29 needs Zoi 0.18.
The compatible ReqLLM 1.30 graph repaired that failure. The isolated copy also
needed a Git metadata directory for its standard git_hooks dependency.

## Shared evidence and limits

Date: 2026-11-14. GitHub API checks confirmed consolidated core `release/v3`
at `047bf746330a2fbe7c3b25c045552e0303c97eaf`. Tests used Elixir 1.20.4,
OTP 29.1.2. Core owns Action, Signal, and AI modules. No separate legacy
core package is present in either new consumer fixture dependency tree.
No mandatory core runtime dependency was added to a standalone package.

The package sources and consumer fixtures were self-checked. A separate source
review checked the Harness reconciliation. No live model or paid provider
check ran. No live app home, checkpoint, or database was changed.

Jidoka started on `release/v3` at
`5b697d3d3a0f96bc7baf063687d4a98f31a0565a`, with local checkpoint work.
Its source was copied to `/private/tmp/five-v3/jidoka`. Only that copy's
manifest used paths to the four candidate libraries. Core remained pinned to
`047bf746`. The command below passed 4 tests with a temporary SQLite database:

```sh
MIX_TARGET=desktop ERL_FLAGS='+S 4:4' mix test test/jidoka/workspaces_test.exs test/jidoka/inference/detector_test.exs
```

The first two tests cover write/read/list/capture, mutation policy, storage
selection refusal, and close. The other two cover provider discovery and
failure normalization. They do not run a live Harness provider. The original
Jidoka checkout and its existing local changes were preserved.

## Release order

Publish the required consolidated core and shared dependencies first. ReqLLM
1.30.0 and Zoi 0.19.0 are already available. Release VFS before Shell, then
Workspace, then update and check Jidoka dependency pins. Character and Harness
can release independently after their shared dependencies are available.
Migrate Hancho before claiming it supports the new Harness candidate. No
registry publication, release, merge, or PR was part of this work.
