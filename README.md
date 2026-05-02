# git-squashx — squash with memory

> Squash your commits into one for a clean rebase, without losing the originals.

When your team requires `rebase` for catchups, squashing N commits into one means resolving conflicts only once instead of N times. `squashx` does the squash and preserves every original commit as a local Git tag that never expires — so you can always inspect or restore them.

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

If the install directory is not in your `$PATH`, the installer will tell you exactly what to add to your shell config.

**Manual install:**

```bash
curl -sSL https://raw.githubusercontent.com/cromagnoli/git-squashx/main/git-squashx \
  -o ~/.local/bin/git-squashx && chmod +x ~/.local/bin/git-squashx
```

## Compatibility

| Platform | Status |
|---|---|
| macOS | ✅ bash, zsh |
| Linux | ✅ bash |
| Windows Git Bash | ✅ |

> **Windows:** requires [Git for Windows](https://git-scm.com/download/win).

## Workflow

```
# Your feature branch before squashing
git log --oneline <base-branch>..HEAD
# a6892db fix edge case in parser
# 5e1ef0c add form validation
# cbb603a implement login form
```

```bash
# 1. Squash — originals are preserved as local tags
git squashx --save "feat: implement login"

# 2. Rebase — at most one conflict now, not N
git rebase <base-branch>

# 3. Push
git push --force-with-lease
```

The squash commit message:

```
[SQ] feat: implement login

Original commits:
- cbb603a: implement login form
- 5e1ef0c: add form validation
- a6892db: fix edge case in parser

custom-squash-id: squash-backup/feature/login/20260501050621
```

The `[SQ]` prefix makes squash commits easy to spot in the log. The original SHAs are embedded directly in the message — no extra commands needed.

If something goes wrong after the rebase, drop the squash to get back to the original commits:

```bash
git squashx --drop      # reads squash-id from HEAD
```

This resets the branch to the original tip and deletes all squashx tags. If the squash was already pushed to remote, the reset is skipped and only the tags are deleted — instructions for force push are shown.

## Commands

### `--save` / `-s`

Squashes all commits between `base-branch` and `HEAD` into one, tagging each original commit locally.

```bash
git squashx --save                                         # auto-detect base, no message
git squashx --save "feat: implement login"                 # auto-detect base, with message
git squashx --save <base-branch>                           # explicit base, no message
git squashx --save <base-branch> "feat: implement login"   # explicit base, with message
```

**Base branch auto-detection** looks for a branch whose tip is the exact divergence point of your branch. If exactly one such branch is found, it's used automatically. If the situation is ambiguous, `squashx` lists the candidates and asks you to pass the base explicitly:

```
-> could not auto-detect base branch unambiguously.
   candidates (sorted by distance):

   1) main                             (11 commits ahead)
   2) other-branch                     (18 commits ahead)

error: pass it explicitly: git squashx --save <base-branch> "message"
```

### `--peek` / `-p`

Shows the original commits of a squash: message, author, date, and diff stat.

```bash
git squashx --peek                       # reads squash-id from HEAD
git squashx --peek 7b60cd2               # by squash commit SHA
git squashx --peek squash-backup/...     # by squash-id tag
```

### `--restore` / `-r`

Recreates the original commits as a new branch by cherry-picking them in order onto the recorded base branch.

```bash
git squashx --restore                    # reads squash-id from HEAD
git squashx --restore 7b60cd2            # by squash commit SHA
git squashx --restore squash-backup/...  # by squash-id tag
```

Creates a branch named `restore/<original-branch>/<timestamp>`.

### `--drop` / `-d`

Undoes a squash: resets the branch to the original tip and deletes all associated tags. If the squash commit has already been pushed to a remote, only the tags are deleted and instructions for force push are shown.

```bash
git squashx --drop                       # reads squash-id from HEAD
git squashx --drop 7b60cd2               # by squash commit SHA
git squashx --drop squash-backup/...     # by squash-id tag
```

### `--list` / `-l`

Lists all saved squashes with their metadata.

```bash
git squashx --list
git squashx --list --branch feature/login
```

## How tags work

Each `--save` creates:
- One tag per original commit: `squash-backup/commits/<branch>/<sha>`
- One summary tag: `squash-backup/<branch>/<timestamp>`

Tags are **local by default** and never expire — Git's garbage collector won't remove objects reachable from a tag. Push them explicitly if you want a remote backup:

```bash
git push origin refs/tags/squash-backup/feature/login/20260501050621
```

To list all squashx tags:

```bash
git tag -l "squash-backup/*"
```

## Requirements

- Bash 3.x+ (Bash 4+ recommended on macOS — `brew install bash`)
- Git 2.x

## License

MIT © [Cristian Romagnoli](https://github.com/cromagnoli)