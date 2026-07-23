#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="${DOTFILES_MANIFEST:-$SCRIPT_DIR/dotfiles-manifest.yaml}"
YQ_VERSION="v4.44.3"
PLATFORM="linux"

MODE="install"
FORCE=false
DRY_RUN=false
LIST=false
ALL=false
REQUESTED=()

declare -A TOOLS=()
declare -A CONFIGS=()
declare -A TOOL_STACK=()
declare -A TOOL_DONE=()

usage() {
  cat <<'EOF'
Usage: dotfiles-setup.sh [tool|tag ...] [options]

Modes:
  --install-only       Install selected tools only (default)
  --configure          Install tools, then link their configs
  --configure-only     Link configs only; never install tools

Options:
  --all                Select all tools
  --list               List tools, tags, and configs
  --force              Reinstall tools and replace existing targets
  --dry-run            Print actions without changing anything
  -h, --help           Show this help

Examples:
  ./dotfiles-setup.sh neovim
  ./dotfiles-setup.sh neovim --configure
  ./dotfiles-setup.sh neovim --configure-only
  ./dotfiles-setup.sh dev --configure
  ./dotfiles-setup.sh workstation --configure-only
EOF
}

ensure_yq() {
  if command -v yq >/dev/null 2>&1 && yq --version 2>/dev/null | grep -qi mikefarah; then return; fi
  local arch
  case "$(uname -m)" in
    x86_64|amd64) arch=amd64 ;;
    aarch64|arm64) arch=arm64 ;;
    *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
  esac
  echo "Installing yq ${YQ_VERSION}..."
  sudo curl -fsSL "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${arch}" -o /usr/local/bin/yq
  sudo chmod +x /usr/local/bin/yq
}

run() { echo "> $1"; [[ "$DRY_RUN" == true ]] || bash -lc "$1"; }
has_key() { yq -e ".$1 | has(\"$2\")" "$MANIFEST" >/dev/null 2>&1; }

select_tool() {
  local tool=$1 cfg
  has_key tools "$tool" || { echo "Unknown tool: $tool" >&2; exit 1; }
  TOOLS["$tool"]=1
  while IFS= read -r cfg; do if [[ -n "$cfg" ]]; then CONFIGS["$cfg"]=1; fi; done < <(yq -r ".tools.\"$tool\".configs[]?" "$MANIFEST")
}

select_tag() {
  local tag=$1 tool
  has_key tags "$tag" || { echo "Unknown tag: $tag" >&2; exit 1; }
  while IFS= read -r tool; do
    local has_tag
    has_tag=$(yq -r ".tools.\"$tool\".tags[]? | select(. == \"$tag\")" "$MANIFEST")
    if [[ -n "$has_tag" ]]; then select_tool "$tool"; fi
  done < <(yq -r '.tools | keys | .[]' "$MANIFEST")
}

platform_value() {
  local path=$1 type
  type=$(yq -r "$path | type" "$MANIFEST")
  if [[ "$type" == "!!map" ]]; then yq -r "$path.$PLATFORM // \"\"" "$MANIFEST"; else yq -r "$path // \"\"" "$MANIFEST"; fi
}

tool_installed() {
  local tool=$1 check
  check=$(platform_value ".tools.\"$tool\".check")
  [[ -n "$check" && "$check" != "null" ]] && command -v "$check" >/dev/null 2>&1
}

install_tool() {
  local tool=$1 dep cmd
  [[ -z "${TOOL_DONE[$tool]:-}" ]] || return
  [[ -z "${TOOL_STACK[$tool]:-}" ]] || { echo "Dependency cycle detected at $tool" >&2; exit 1; }
  TOOL_STACK["$tool"]=1
  while IFS= read -r dep; do if [[ -n "$dep" ]]; then install_tool "$dep"; fi; done < <(platform_value ".tools.\"$tool\".depends_on[]?")
  unset 'TOOL_STACK[$tool]'

  if [[ "$FORCE" != true ]] && tool_installed "$tool"; then
    echo "Already installed: $tool"
  else
    echo "Installing: $tool"
    mapfile -t commands < <(yq -r ".tools.\"$tool\".install.$PLATFORM[]?" "$MANIFEST")
    if [[ ${#commands[@]} -eq 0 ]]; then echo "No $PLATFORM install commands for $tool"; else for cmd in "${commands[@]}"; do run "$cmd"; done; fi
  fi
  TOOL_DONE["$tool"]=1
}

expand_target() {
  local target=$1
  target="${target/#\~/$HOME}"
  printf '%s\n' "$target"
}

configure_item() {
  local cfg=$1 source target parent existing
  source="$SCRIPT_DIR/$(yq -r ".configs.\"$cfg\".source" "$MANIFEST")"
  target=$(yq -r ".configs.\"$cfg\".targets.$PLATFORM // \"\"" "$MANIFEST")
  [[ -n "$target" ]] || { echo "No $PLATFORM target for config: $cfg"; return; }
  target=$(expand_target "$target")
  [[ -e "$source" ]] || { echo "Missing config source: $source" >&2; return; }

  if [[ -L "$target" ]] && [[ "$(readlink -f "$target")" == "$(readlink -f "$source")" ]]; then echo "Already configured: $cfg"; return; fi
  if [[ -e "$target" || -L "$target" ]]; then
    if [[ "$FORCE" != true ]]; then echo "Target exists; use --force: $target"; return; fi
    echo "Removing: $target"
    [[ "$DRY_RUN" == true ]] || rm -rf -- "$target"
  fi
  parent=$(dirname "$target")
  echo "Linking: $target -> $source"
  if [[ "$DRY_RUN" != true ]]; then mkdir -p -- "$parent"; ln -s -- "$source" "$target"; fi
}

while (($#)); do
  case "$1" in
    --install-only) MODE=install ;;
    --configure) MODE=both ;;
    --configure-only) MODE=configure ;;
    --all) ALL=true ;;
    --list) LIST=true ;;
    --force) FORCE=true ;;
    --dry-run) DRY_RUN=true ;;
    -h|--help) usage; exit 0 ;;
    --*) echo "Unknown option: $1" >&2; exit 1 ;;
    *) REQUESTED+=("$1") ;;
  esac
  shift
done

[[ -f "$MANIFEST" ]] || { echo "Manifest not found: $MANIFEST" >&2; exit 1; }
ensure_yq

# Verify required package managers are available
while IFS= read -r pm; do
  [[ -n "$pm" ]] || continue
  pm_platform=$(yq -r ".package_managers.\"$pm\".platform // \"\"" "$MANIFEST")
  [[ -z "$pm_platform" || "$pm_platform" == "$PLATFORM" ]] || continue
  pm_check=$(yq -r ".package_managers.\"$pm\".check // \"\"" "$MANIFEST")
  if [[ -n "$pm_check" ]] && ! command -v "$pm_check" >/dev/null 2>&1; then
    pm_hint=$(yq -r ".package_managers.\"$pm\".hint // \"\"" "$MANIFEST")
    if [[ -n "$pm_hint" ]]; then echo "Warning [$pm]: $pm_hint" >&2; else echo "Warning: Package manager '$pm' not found ($pm_check)." >&2; fi
  fi
done < <(yq -r '.package_managers | keys | .[]' "$MANIFEST")

if [[ "$LIST" == true ]]; then
  echo "Tools:"; yq -r '.tools | to_entries[] | "  \(.key) - \(.value.description)"' "$MANIFEST"
  echo "Tags:"; yq -r '.tags | to_entries[] | "  \(.key) - \(.value)"' "$MANIFEST"
  echo "Configs:"; yq -r '.configs | to_entries[] | "  \(.key) - \(.value.description)"' "$MANIFEST"
  exit 0
fi

if [[ "$ALL" == true || ${#REQUESTED[@]} -eq 0 ]]; then
  while IFS= read -r tool; do select_tool "$tool"; done < <(yq -r '.tools | keys | .[]' "$MANIFEST")
else
  for name in "${REQUESTED[@]}"; do
    if has_key tools "$name"; then select_tool "$name"; elif has_key tags "$name"; then select_tag "$name"; else echo "Unknown tool or tag: $name" >&2; exit 1; fi
  done
fi

if [[ "$MODE" != configure ]]; then
  while IFS= read -r tool; do if [[ -n "${TOOLS[$tool]:-}" ]]; then install_tool "$tool"; fi; done < <(yq -r '.tools | keys | .[]' "$MANIFEST")
fi
if [[ "$MODE" != install ]]; then
  if [[ ${#CONFIGS[@]} -eq 0 ]]; then echo "No configs associated with the selection."; else
    while IFS= read -r cfg; do if [[ -n "${CONFIGS[$cfg]:-}" ]]; then configure_item "$cfg"; fi; done < <(yq -r '.configs | keys | .[]' "$MANIFEST")
  fi
fi
