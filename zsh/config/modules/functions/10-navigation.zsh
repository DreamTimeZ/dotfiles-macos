# ===============================
# FILE & DIRECTORY NAVIGATION FUNCTIONS
# ===============================

# Create a directory and navigate to it (use z for zoxide tracking)
mkcd() {
    mkdir -p "$1" && z "$1"
}

# Show disk usage for top 10 largest directories/files
dusage() {
    du -ah . | sort -rh | head -n 10
}

# Fuzzy file finder with preview (using bat if available)
ffind() {
    find . -type f | fzf --preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}'
}

# Fuzzy directory finder
fdir() {
    local dir
    dir=$(find . -type d 2>/dev/null | fzf +m) && cd "$dir"
} 