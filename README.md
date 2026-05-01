# Git-squashx — squash with memory

> Squash your commits into one for a clean rebase, without losing the originals.

When your team requires `rebase` for catchups, squashing N commits into one means resolving conflicts only once instead of N times. `squashx` does the squash and preserves every original commit as a local Git tag that never expires — so you can always inspect or restore them.

## Compatibility

| Platform | Supported |
|---|---|
| Linux | ✅ bash |
| macOS | ✅ bash, zsh |
| Windows | ✅ Git Bash |

> **macOS note:** macOS ships with bash 3.x. `git-squashx` is compatible with bash 3, but bash 4+ is recommended. To upgrade: `brew install bash`.

> **Windows note:** requires [Git for Windows](https://git-scm.com/download/win), which includes Git Bash.

## Install

```bash
curl -sSL https://raw.githubusercontent.com/cromagnoli/git-squashx/main/install.sh | bash
```

The installer detects your platform and shell and places the script in the right directory:

| Platform | Install dir |
|---|---|
| Linux (with sudo) | `/usr/local/bin` |
| Linux (without sudo) | `~/.local/bin` |
| macOS (with sudo) | `/usr/local/bin` |
| macOS (without sudo) | `~/.local/bin` |
| Windows Git Bash | `~/bin` |

If the install directory is not in your `$PATH`, the installer will tell you exactly what to add to your `.bashrc`, `.zshrc`, or `.bash_profile`.

**Manual install:**

```bash
# Linux / macOS
curl -sSL https://raw.githubusercontent.com/cromagnoli/git-squashx/main/git-squashx \
  -o /usr/local/bin/git-squashx && chmod +x /usr/local/bin/git-squashx

# Windows Git Bash
curl -sSL https://raw.githubusercontent.com/cromagnoli/git-squashx/main/git-squashx \
  -o ~/bin/git-squashx && chmod +x ~/bin/git-squashx
```

## Usage

```bash
git squashx --save    [base-branch] ["message"]   # -s
git squashx --peek    [squash-id | sha]            # -p
git squashx --restore [squash-id | sha]            # -r
git squashx --list    [--branch <name>]            # -l
git squashx --help                                 # -h
```

## Workflow

```bash
# Illustrative — your commits might look like this
git log --oneline main..HEAD
# a6892db fix edge case in parser
# 5e1ef0c add form validation
# cbb603a implement login form

# 1. Squash and preserve originals
git squashx --save "feat: implement login feature"

# 2. Catchup — only one conflict to resolve if any
git rebase main

# 3. Push normally
git push --force-with-lease
```

The resulting squash commit message looks like this:

```
[SQ] feat: implement login feature

Original commits:
- cbb603a: implement login form
- 5e1ef0c: add form validation
- a6892db: fix edge case in parser

custom-squash-id: squash-backup/feature/login/20260501050621
```

The `[SQ]` tag makes squash commits immediately recognizable in the log. The original SHAs are right there so you can reference them without running any command. The `custom-squash-id` at the bottom is local metadata used by `squashx` — it's not a native Git field.

## Commands

### `--save` / `-s`

Squashes all commits between `base-branch` and `HEAD` into one, and tags each original commit locally.

The base branch is resolved in this order:
1. The explicit argument you pass
2. The upstream tracking branch of your current branch (`@{upstream}`)
3. Error with a clear message if neither is available

```bash
git squashx --save                                  # Auto-detects base branch, no message
git squashx --save "feat: implement login"          # Auto-detects base branch, with message
git squashx --save main                             # Explicit base, no message
git squashx --save main "feat: implement login"     # Explicit base, with message
```

If your branch has no upstream configured and you don't pass a base branch explicitly, `squashx` will exit with a clear error and tell you what to do.

### `--peek` / `-p`

Shows the original commits of a squash: message, author, date, and diff stat.

```bash
git squashx --peek                       # Reads squash-id from HEAD
git squashx --peek 7b60cd2               # By squash commit SHA
git squashx --peek squash-backup/...     # By squash-id tag
```

### `--restore` / `-r`

Recreates the original commits as a new branch by cherry-picking them in order onto `base-branch`.

```bash
git squashx --restore                    # Reads squash-id from HEAD
git squashx --restore 7b60cd2            # By squash commit SHA
git squashx --restore squash-backup/...  # By squash-id tag
```

Creates a branch named `restore/<original-branch>/<timestamp>`.

### `--list` / `-l`

Lists all saved squashes with their metadata.

```bash
git squashx --list
git squashx --list --branch feature/login
```

## How tags work

Each squash creates:
- One tag per original commit: `squash-backup/commits/<branch>/<sha>`
- One tag for the squash itself: `squash-backup/<branch>/<timestamp>`

Tags are **local by default** and never expire — Git's garbage collector won't remove objects that are reachable from a tag. A `git push` does **not** upload them unless you do so explicitly:

```bash
# Share a specific squash with a teammate
git push origin refs/tags/squash-backup/feature/login/...

# See only squashx tags
git tag -l "squash-backup/*"
```

## Requirements

- Bash 4+
- Git 2.x

## License

MIT © [Cristian Romagnoli](https://github.com/cromagnoli)
