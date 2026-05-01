#!/usr/bin/env sh
#
# git-squashx installer
# Supports: Linux, macOS (bash/zsh), Windows Git Bash
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/cromagnoli/git-squashx/main/install.sh | sh

set -eu

REPO="cromagnoli/git-squashx"
BRANCH="main"
SCRIPT_NAME="git-squashx"
RAW_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/${SCRIPT_NAME}"

red()    { printf "\033[0;31m%s\033[0m\n" "$*"; }
green()  { printf "\033[0;32m%s\033[0m\n" "$*"; }
yellow() { printf "\033[0;33m%s\033[0m\n" "$*"; }
bold()   { printf "\033[1m%s\033[0m\n" "$*"; }
dim()    { printf "\033[2m%s\033[0m\n" "$*"; }

die() { red "error: $*" >&2; exit 1; }

# ── detect platform ───────────────────────────────────────────────────────────

detect_platform() {
  _uname=$(uname -s)
  case "$_uname" in
    Linux*)             echo "linux"   ;;
    Darwin*)            echo "mac"     ;;
    MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
    *)                  echo "unknown" ;;
  esac
}

# ── detect current shell ──────────────────────────────────────────────────────

detect_shell() {
  _shell=$(basename "${SHELL:-sh}")
  case "$_shell" in
    zsh)  echo "zsh"  ;;
    bash) echo "bash" ;;
    *)    echo "sh"   ;;
  esac
}

# ── get shell profile file ────────────────────────────────────────────────────

get_profile_file() {
  _platform="$1"
  _shell="$2"
  case "$_shell" in
    zsh)  echo "$HOME/.zshrc" ;;
    bash)
      case "$_platform" in
        mac) echo "$HOME/.bash_profile" ;;
        *)   echo "$HOME/.bashrc" ;;
      esac
      ;;
    *) echo "$HOME/.profile" ;;
  esac
}

# ── detect install dir ────────────────────────────────────────────────────────

detect_install_dir() {
  _platform="$1"
  case "$_platform" in
    windows)
      echo "$HOME/bin"
      return
      ;;
  esac
  if [ -w "/usr/local/bin" ] || [ "$(id -u)" = "0" ]; then
    echo "/usr/local/bin"
  else
    echo "$HOME/.local/bin"
  fi
}

# ── check PATH and suggest fix ────────────────────────────────────────────────

check_path() {
  _dir="$1"
  _profile="$2"
  case ":${PATH}:" in
    *":${_dir}:"*) return 0 ;;
  esac
  echo ""
  yellow "note: $_dir is not in your PATH."
  echo "  add this to $_profile:"
  echo ""
  printf '    export PATH="%s:$PATH"\n' "$_dir"
  echo ""
  echo "  then reload it:"
  echo ""
  printf '    source %s\n' "$_profile"
  echo ""
}

# ── check dependencies ────────────────────────────────────────────────────────

command -v git  >/dev/null 2>&1 || die "git is required but not installed"
command -v curl >/dev/null 2>&1 || die "curl is required but not installed"

# ── main ──────────────────────────────────────────────────────────────────────

PLATFORM=$(detect_platform)
SHELL_NAME=$(detect_shell)
INSTALL_DIR=$(detect_install_dir "$PLATFORM")
PROFILE_FILE=$(get_profile_file "$PLATFORM" "$SHELL_NAME")

bold "Installing git-squashx..."
echo ""
dim "  platform : $PLATFORM"
dim "  shell    : $SHELL_NAME"
dim "  into     : $INSTALL_DIR"
echo ""

mkdir -p "$INSTALL_DIR"

TMP=$(mktemp)
echo "  Downloading..."
curl -sSL "$RAW_URL" -o "$TMP" || die "Failed to download $SCRIPT_NAME"
chmod +x "$TMP"
mv "$TMP" "$INSTALL_DIR/$SCRIPT_NAME"

check_path "$INSTALL_DIR" "$PROFILE_FILE"

green "Done!: Installed $INSTALL_DIR/$SCRIPT_NAME"
echo ""
bold "Usage:"
echo ""
echo "  git squashx --save    [base-branch] [\"message\"]   (-s)"
echo "  git squashx --peek    [squash-id | sha]            (-p)"
echo "  git squashx --restore [squash-id | sha]            (-r)"
echo "  git squashx --list    [--branch <name>]            (-l)"
echo "  git squashx --help                                 (-h)"
echo ""
