# ===============================
# ALIASES
# ===============================

# VCS (Git)
if command -v git &>/dev/null; then
    alias ga='git add . && git status'
    alias gs='git status'
    alias gsw='git switch'                # Switch to another branch
    alias gswc='git switch -c'            # Create and switch to new branch
    alias gb='git branch'                 # List branches
    alias gbd='git branch -d'             # Safe delete (warns if not merged)
    alias gbD='git branch -D'             # Force delete (even if not merged)
    alias gbrd='git push origin --delete' # Delete remote branch
    alias gc='git commit'                 # Commit
    alias gcm='git commit -m'             # Commit with message
    alias gca='git commit --amend'        # Amend last commit
    alias gundo='git reset --soft HEAD~1'
    alias gpl='git pull'
    alias gps='git push'
    alias gpsf='git push --force-with-lease' # Safe force push
    alias glg='git log --oneline --graph --decorate --all'
    alias gl='git log --oneline --decorate'
    alias ghist='git log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short'
    alias gdf='git diff'
    alias gdc='git diff --cached'       # Show staged changes
    alias grs='git restore .'           # Restore working directory changes
    alias grss='git restore --staged .' # Unstage staged files
    alias grb='git rebase'
    alias grbi='git rebase -i'
    alias gcl='git clone'
    alias gfa='git fetch --all --prune'
    alias glast='git log -1 HEAD'
    alias gtags='git tag -l'
    alias gtagd='git tag -d'
fi

# tldr (tealdealer)
if command -v tldr &>/dev/null; then
    alias tldr="noglob tldr"
fi

# Editor tools
if command -v nvim &>/dev/null; then
    alias vi='nvim'
fi

# Search and Replace
if command -v rg &>/dev/null; then
    unalias grep 2>/dev/null
    alias grep='rg'
fi

## Cursor with Profiles
if command -v cursor &>/dev/null; then
    alias cu="cursor --profile 'Default'"
    alias cun="cursor --new-window --profile 'Default'"
    alias cpy="cursor --profile 'Python'"
    alias ctr="cursor --profile 'TypeScript React'"
    alias cs="cursor --profile 'Spring Boot'"
    alias cxx="cursor --profile 'Cpp'"
fi

# Tmux
if command -v tmux &>/dev/null; then
    alias t="tmux attach-session -t default 2>/dev/null || tmux new-session -s default"
fi

# Navigation using zoxide
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
if command -v zoxide &>/dev/null; then
    alias cd='z'
    alias cdi='zoxide query --interactive'
    alias cdf='cd "$(zoxide query --interactive)" || return' # Consider switching to 'z --interactive'
fi

# File listing using eza (if installed)
if command -v eza &>/dev/null; then
    alias ls='eza --color=auto --group-directories-first'
    alias ll='eza -l --color=always --group-directories-first --icons'
    alias lla='eza -la --color=always --group-directories-first --icons'
    alias la='eza -a --color=always --group-directories-first --icons'
    alias lh='eza -l --color=always --icons .* 2>/dev/null'
    alias tree='eza --tree --level=2 --icons'
fi

# Core utilities with safe defaults
alias mkdir='mkdir -pv'
alias rm='rm -Iv'
alias rd='rmdir'
alias cp='cp -iv'
alias mv='mv -iv'
alias df='df -h'
alias du='du -h'

# Networking tools
alias ports='netstat -tuln'

if command -v tcpdump &>/dev/null; then
    alias sniff='sudo tcpdump -i any port'
fi

if command -v nmap &>/dev/null; then
    alias nscan='sudo nmap -sS -Pn'
fi

# Docker aliases
if command -v docker &>/dev/null; then
    # Most essential docker commands
    alias d='docker'
    alias dps='docker ps'
    alias di='docker images'
    alias dex='docker exec -it'
    alias dlogs='docker logs -f'
    
    # Docker compose essentials
    if command -v docker-compose &>/dev/null || command -v docker &>/dev/null; then
        alias dc='docker-compose'
        alias dcup='docker-compose up -d'
        alias dcdown='docker-compose down'
    fi
    
    # Clean up
    alias dprune='docker system prune'
fi

# HTTPie aliases
if command -v http &>/dev/null; then
    # Basic http methods
    alias hget='http GET'
    alias hpost='http POST'
    alias hput='http PUT'
    
    # Content types
    alias hjson='http --json'
    
    # Debug helpers
    alias hverbose='http --verbose'
    alias hheaders='http --headers'
fi

alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

if command -v grc &>/dev/null; then
  GRC_CMDS=(
    ip ifconfig ping traceroute dig whois df du mount ps lsof
  )
  for cmd in "${GRC_CMDS[@]}"; do
    alias "$cmd"="grc $cmd"
  done
fi

alias ipv4='curl -s https://ipv4.icanhazip.com'
alias ipv6='curl -s https://ipv6.icanhazip.com'

# Miscellaneous
alias cls='clear'
alias reload='source ~/.zshrc' # Reload this configuration
alias '?'='echo $?'            # Print the exit code of the last command

# Kubernetes shortcuts (if kubectl is installed)
if command -v kubectl &>/dev/null; then
    alias k='kubectl'
    alias kgp='kubectl get pods'
    alias kgs='kubectl get svc'
    alias kgn='kubectl get nodes'
fi

# Ollama
if command -v ollama &>/dev/null; then
    alias ollama-up='pgrep -x ollama >/dev/null || (ollama serve > /dev/null 2>&1 &)'
fi
