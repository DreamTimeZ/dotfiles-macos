# ===============================
# .ZPROFILE - LOGIN SHELL CONFIG
# ===============================
# Executed for login shells

# ------ Base Configuration ------
export ZDOTFILES_DIR="${ZDOTFILES_DIR:-$HOME/.dotfiles}"
export ZDOTFILES_CONFIG_DIR="${ZDOTFILES_CONFIG_DIR:-$ZDOTFILES_DIR/zsh/config}"

# ------ Minimal Path Management ------
# Add essential paths for non-interactive shells
zdotfiles_path_prepend() {
  [[ -d "$1" && ":$PATH:" != *":$1:"* ]] && export PATH="$1:$PATH"
}

[[ -d "/opt/homebrew/bin" ]] && zdotfiles_path_prepend "/opt/homebrew/bin"
[[ -d "$HOME/.local/bin" ]] && zdotfiles_path_prepend "$HOME/.local/bin"

# ------ Environment Variables ------
export EDITOR="${EDITOR:-nvim}"

# ------ SSH Key Management (Performance-Optimized) ------
: ${SSH_KEY_DIR:="$HOME/.ssh"}
: ${SSH_USE_KEYCHAIN:=1}
: ${SSH_EXCLUDED_PATTERNS:="*.pub config* known_hosts* authorized_keys*"}

# Command availability cache - check once instead of repeatedly
_HAVE_SSH_AGENT=0
_HAVE_SSH_ADD=0
command -v ssh-agent &>/dev/null && _HAVE_SSH_AGENT=1
command -v ssh-add &>/dev/null && _HAVE_SSH_ADD=1

# Only proceed if commands are available
if [[ $_HAVE_SSH_AGENT -eq 1 && $_HAVE_SSH_ADD -eq 1 ]]; then
  # Robust agent detection - check both SSH_AGENT_PID and processes
  ssh_agent_running() {
    if [[ -n "$SSH_AGENT_PID" ]]; then
      kill -0 "$SSH_AGENT_PID" &>/dev/null && return 0
    fi
    pgrep -x ssh-agent &>/dev/null
    return $?
  }
  
  # Start SSH agent if not running
  if ! ssh_agent_running; then
    eval "$(ssh-agent -s)" > /dev/null
  fi
  
  # Smart caching with minimal I/O - single read/write
  SSH_CACHE_FILE="/tmp/ssh_loaded_keys_$USER"
  SSH_CACHE_MAX_AGE=3600  # Cache valid for 1 hour
  
  # Simple platform detection for macOS-specific features
  _IS_MACOS=0
  [[ "$OSTYPE" == darwin* ]] && _IS_MACOS=1
  
  # Load cached fingerprints if fresh enough
  if [[ -f "$SSH_CACHE_FILE" ]]; then
    # Fast cache age check - avoid complex calculations
    if [[ -n "$(find "$SSH_CACHE_FILE" -mmin -60 2>/dev/null)" ]]; then
      loaded_keys=$(cat "$SSH_CACHE_FILE")
    else
      loaded_keys=$(ssh-add -l 2>/dev/null | awk '{print $2}')
      echo "$loaded_keys" > "$SSH_CACHE_FILE" 2>/dev/null
    fi
  else
    loaded_keys=$(ssh-add -l 2>/dev/null | awk '{print $2}')
    echo "$loaded_keys" > "$SSH_CACHE_FILE" 2>/dev/null
  fi
  
  # Key validation function - reused for each key
  validate_key() {
    local key="$1"
    [[ ! -f "$key" || ! -r "$key" ]] && return 1
    # Content check first, fallback to fingerprint
    grep -q -E "BEGIN .* PRIVATE KEY" "$key" 2>/dev/null && return 0
    ssh-keygen -lf "$key" &>/dev/null
    return $?
  }
  
  # Pattern matching for exclusions
  should_exclude() {
    local filename="$1"
    for pattern in $SSH_EXCLUDED_PATTERNS; do
      [[ "$filename" == $~pattern ]] && return 0
    done
    return 1
  }
  
  # Add keys
  success_count=0
  for key in "$SSH_KEY_DIR"/*; do
    filename="$(basename "$key")"    
    should_exclude "$filename" && continue
    
    # Only validate keys that pass exclusion filter
    validate_key "$key" || continue
    
    # Get fingerprint and check if already loaded
    fingerprint=$(ssh-keygen -lf "$key" 2>/dev/null | awk '{print $2}')
    [[ -z "$fingerprint" || "$loaded_keys" == *"$fingerprint"* ]] && continue
    
    # Add key with platform-specific options
    if [[ $_IS_MACOS -eq 1 && $SSH_USE_KEYCHAIN -eq 1 ]]; then
      ssh-add --apple-use-keychain "$key" 2>/dev/null && {
        loaded_keys="$loaded_keys $fingerprint"
        ((success_count++))
      }
    else
      ssh-add "$key" 2>/dev/null && {
        loaded_keys="$loaded_keys $fingerprint"
        ((success_count++))
      }
    fi
  done
  
  # Only update cache if we added keys
  [[ $success_count -gt 0 ]] && echo "$loaded_keys" > "$SSH_CACHE_FILE" 2>/dev/null
  
  # Cleanup all temp variables
  unset -f ssh_agent_running validate_key should_exclude
  unset loaded_keys fingerprint SSH_CACHE_FILE SSH_CACHE_MAX_AGE 
  unset SSH_KEY_DIR SSH_USE_KEYCHAIN SSH_EXCLUDED_PATTERNS
  unset _HAVE_SSH_AGENT _HAVE_SSH_ADD _IS_MACOS success_count
fi