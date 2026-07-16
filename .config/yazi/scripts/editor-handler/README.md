# editor-handler

An `edit` opener for [yazi](https://github.com/sxyazi/yazi), used in this dotfiles setup. Opens directories in a terminal tab and files in the configured editor — transparently escalating to a privileged, symlink-safe edit flow when a file isn't writable by the current user.

## Reasons

Editing a root-owned config file from a file manager usually means dropping to a terminal and running `sudoedit` or `pkexec $EDITOR` by hand. This script folds that into the same "Edit" action yazi already offers for regular files: writable files open normally, non-writable ones are routed through a hardened privileged-edit flow automatically.

## Location in this repo

```
editor-handler/
└── editor-handler.sh
└── lib/
    ├── constants.sh
    ├── logger.sh
    ├── validation.sh
    ├── terminal.sh
    ├── privileged-editor.sh
    └── editor.sh
```

| File                       | Responsibility                                               |
| -------------------------- | ------------------------------------------------------------ |
| `lib/constants.sh`         | Exit codes, `TERMINAL`, `EDITOR`                             |
| `lib/logger.sh`            | `logger::info` / `logger::error`                             |
| `lib/validation.sh`        | `validate::arguments` / `validate::target`                   |
| `lib/terminal.sh`          | `terminal::open_directory` (Kitty tab or new window)         |
| `lib/privileged-editor.sh` | `privileged::edit_as_root` (temp-copy + `pkexec` write-back) |
| `lib/editor.sh`            | `editor::open_file` (writable vs. privileged dispatch)       |

Each library file is guarded against double-sourcing and documents its dependencies via a header comment.

## Features

- **Unified `Edit` action** — one opener handles directories, writable files, and privileged files.
- **Kitty-aware directory opening** — reuses an existing Kitty remote-control session (new tab, correct `cwd`) if reachable, falling back to a fresh detached window otherwise.
- **Privileged edit via `pkexec`** — files without write permission are edited through a temp-copy flow and written back with elevated privileges, without ever running the editor itself as root.
- **Symlink-attack hardening** — refuses to operate on symlinks, preventing the link target from being swapped between the copy and the privileged write-back.

## How it works

```
target = argv[1]

if target is a directory:
    open it in a Kitty tab (or a new window if Kitty isn't reachable)

elif target is a file:
    if writable by the current user:
        open it directly in $EDITOR
    else:
        1. refuse if target is a symlink
        2. copy target to a temp file, preserving mode and timestamps
        3. open the temp copy in $EDITOR --wait
        4. once the editor closes, write the temp file back to the
           original path via `pkexec install -m 644`
        5. remove the temp file

else:
    exit with an error
```

Only the final write-back step runs with elevated privileges — the editor itself always runs as the current user, reducing the amount of code that ever executes as root.

## Requirements

- `bash` ≥ 4
- [yazi](https://github.com/sxyazi/yazi)
- `kitty` with `allow_remote_control` enabled
- `pkexec` (part of polkit) for privileged edits

## Configuration

Wired up in `yazi.toml` as follows:

```toml
[opener]
edit = [
    { run = "~/.config/yazi/scripts/editor-handler/editor-handler %s", desc = "Edit", for = "unix" },
]

[open]
rules = [
    { url = "*/", use = [ "edit", "open", "reveal" ] },
    { mime = "text/*", use = [ "edit", "reveal" ] },
]
```

## Configuration

Edit `lib/constants.sh` to change the terminal and editor used:

```bash
readonly TERMINAL="kitty"
readonly EDITOR="zeditor"
```

`TERMINAL` must support remote control (`kitty @ ls`, `kitty @ launch`) for the tab-reuse behavior; otherwise every directory open falls back to a new detached window. `EDITOR` must support a `--wait` flag (blocks until the file is closed) for the privileged-edit flow to work correctly.

## Security notes

- **Symlink refusal**: `privileged::edit_as_root` explicitly rejects symlinks before copying. Without this check, an attacker could replace the target with a symlink between the copy step and the `pkexec` write-back, redirecting the privileged write to an arbitrary path (symlink attack).
- **Fixed write-back mode**: the privileged write-back always installs with mode `644`, regardless of the original file's mode. Non-standard modes (e.g. `640`) are not currently preserved on privileged edits.
- **Editor never runs as root**: only the final `install` step is privileged; the editing session itself always runs as the invoking user, on a temp file outside any privileged location.

## Known limitations

- The Kitty tab-reuse check (`kitty @ ls`) only verifies that _a_ Kitty remote-control session is reachable — not that it belongs to the currently focused window, so on multi-window Kitty setups a new tab may open in a different OS window than expected.
- `privileged::edit_as_root` does not prompt for confirmation before invoking `pkexec` — the polkit dialog itself is the only gate.
