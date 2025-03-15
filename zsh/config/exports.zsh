# ===============================
# Environment Variables and Options
# ===============================

# ----- History Configuration -----
HISTSIZE=10000                # Maximum number of events in memory
SAVEHIST=1000000              # Maximum number of events saved to history file
HISTFILE="$HOME/.zsh_history" # History file location
setopt EXTENDED_HISTORY       # Record timestamp with each command
setopt APPEND_HISTORY         # Append to history rather than overwrite
setopt HIST_IGNORE_ALL_DUPS   # Do not record duplicate entries

# ----- Miscellaneous Options -----
setopt CORRECT                # Auto-correct minor errors in commands and paths
setopt PROMPT_SP
setopt NO_CASE_GLOB           # Enable case-insensitive globbing
setopt GLOBSTAR_SHORT         # Enable recursive globbing with **

# ----- Auto-completion -----
autoload -Uz compinit && compinit
