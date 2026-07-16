# script-executor

A shebang-aware script executor used as the `execute` opener for [yazi](https://github.com/sxyazi/yazi) in this dotfiles setup. It runs any executable script directly from the file manager — regardless of its file extension — by inspecting the shebang line rather than relying on `.sh`, `.py`, or similar suffixes.

## Reasons

yazi's `[open]` rules match on MIME type or file extension. Neither is reliable for scripts:

- **Extension matching** (`url = "*.sh"`) misses scripts with no extension at all, which is a common convention for CLI entrypoints (`bin/my-tool`, not `bin/my-tool.sh`).
- **MIME-type matching** (`mime = "text/x-shellscript"`) depends on `libmagic` correctly classifying the file, which is inconsistent across distributions and rarely produces a dedicated MIME type for interpreted languages other than shell (Python, Lua, Fish, ...).

This script sidesteps both by reading the file's first line and matching it against a configurable interpreter list, covering both shebang styles:

```
#!/bin/bash
#!/usr/bin/env bash
#!/usr/bin/env -S python3 -u
```

## Location in this repo

```
script-executor/
├── script-executor.sh
└── lib/
    ├── constants.sh
    ├── logger.sh
    ├── validation.sh
    └── executor.sh
```

| File                | Responsibility                                                   |
| ------------------- | ---------------------------------------------------------------- |
| `lib/constants.sh`  | Exit codes, `SCRIPT_NAME`, and the `EXECUTOR_INTERPRETERS` array |
| `lib/logger.sh`     | `logger::info` / `logger::error`                                 |
| `lib/validation.sh` | `validate::arguments` / `validate::file`                         |
| `lib/executor.sh`   | Shebang detection, permission granting/reverting, execution      |

Each library file is guarded against double-sourcing and documents its own dependencies via a header comment. `lib/executor.sh` requires `lib/constants.sh` to be sourced first, since it reads `EXECUTOR_INTERPRETERS` at source time to build its matching pattern.

## Features

- **Content-based detection** — works on any script regardless of extension.
- **Dual shebang support** — direct interpreter paths (`#!/bin/bash`) and `env`-based lookups (`#!/usr/bin/env bash`), including the `-S` flag for extra interpreter arguments.
- **Configurable interpreter list** — extend support for new languages by editing a single array in `lib/constants.sh`; no changes to matching logic required.
- **Non-destructive permission handling** — if a script lacks the executable bit, it's granted automatically and **reverted if execution fails**, so a failed run never leaves a permanent side effect on files that weren't already executable.
- **Semantic exit codes** for scripting and debugging.

## Requirements

- `bash` ≥ 4
- [yazi](https://github.com/sxyazi/yazi)
- The interpreters you intend to run scripts with, available on `$PATH`

## Configuration

Wired up in `yazi.toml` as follows:

```toml
[opener]
execute = [
    { run = "~/.config/yazi/scripts/script-executor/script-executor.sh %s", desc = "Execute" },
]

[open]
rules = [
    # Match on content (shebang), not extension
    # Works for scripts with no file extension.
    { mime = "text/*", use = [ "edit", "execute", "reveal" ] },
]
```

## Usage

From yazi, select any script and choose **Execute** from the opener menu. The script runs in place; output and any errors are printed to the terminal yazi is running in.

Can also be invoked directly, outside of yazi:

```bash
~/.config/yazi/scripts/script-executor/script-executor.sh /path/to/some/script
```

### Exit codes

| Code | Meaning                                           |
| ---- | ------------------------------------------------- |
| `0`  | Success                                           |
| `2`  | Invalid arguments (expects exactly one file path) |
| `3`  | File not found                                    |
| `4`  | Unsupported file type (no recognized shebang)     |
| `5`  | Execution failed (script ran but exited non-zero) |

## Supported interpreters

Defined in `lib/constants.sh` as `EXECUTOR_INTERPRETERS`:

```bash
readonly -a EXECUTOR_INTERPRETERS=(
    bash
    sh
    zsh
    dash
    fish
    ksh
    "python[0-9.]*"
    "lua[0-9.]*"
    perl
    ruby
    node
)
```

Entries support regex alternation syntax, so version-qualified interpreters like `python3.12` or `lua5.4` are matched via patterns such as `"python[0-9.]*"`. To add a new language, append it to this array — no other file needs to change.

## How permission handling works

Scripts detected as valid (recognized shebang) but lacking the executable bit are granted `+x` automatically before running. If the script then **fails** (non-zero exit), the granted permission is reverted with `chmod -x`, leaving the filesystem exactly as it was found. If the script was already executable beforehand, its permission is never touched — successful or not.
