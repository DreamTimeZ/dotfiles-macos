# .dotfiles

Modern, modular dotfiles configuration for a productive macOS development environment.

## 🎯 Overview

A carefully curated collection of dotfiles optimized for:
- 🔧 Zsh with Powerlevel10k
- 🔌 Plugin management with Sheldon
- 📝 Neovim with lazy.nvim
- 📦 Tmux with plugin management
- 🔑 SSH with local overrides
- 🌳 Git with split configuration

## ✨ Features

### Shell (Zsh)

- Powerlevel10k prompt with instant startup
- Smart directory navigation with `zoxide`
- Sheldon plugin manager for fast, modern plugin management
- Enhanced shell experience:
  - Syntax highlighting
  - Auto-suggestions and autocompletion
  - Fuzzy finding with `fzf`
- Modular configuration with separate files for:
  - Exports and environment variables
  - Plugin management
  - Aliases
  - Functions
  - Extra configurations
- iTerm2 integration with optimized settings (see [iTerm2 Configuration](docs/iterm2.md))

### Neovim

- Modern Lua-based configuration
- Lazy plugin management
- Features include:
  - Treesitter syntax highlighting
  - Telescope fuzzy finder
  - Built-in file explorer
  - Git integration
  - Status line
  - System clipboard integration

### Tmux

- Custom prefix key (Ctrl+A)
- Vim-style pane navigation
- Mouse support
- Clipboard integration
- Session management
- Plugins:
  - tmux-resurrect
  - tmux-continuum
  - tmux-cpu
  - tmux-yank
  - tmux-open

## 🚀 Installation

### COMING SOON! Automatic Setup (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/DreamTimeZ/dotfiles-macos/main/install.sh | bash
```

Or clone and run the installer:

```bash
git clone git@github.com:DreamTimeZ/dotfiles-macos.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

### Manual Setup

1. Clone the repository:
```bash
git clone git@github.com:DreamTimeZ/dotfiles-macos.git ~/.dotfiles
```

2. Create symbolic links:
```bash
# Zsh
ln -sf ~/.dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/zsh/.zprofile ~/.zprofile

# Sheldon (Zsh plugin manager)
mkdir -p ~/.config/sheldon
ln -sf ~/.dotfiles/zsh/sheldon/plugins.toml ~/.config/sheldon/plugins.toml
sheldon lock --update

# Neovim
mkdir -p ~/.config/nvim
ln -sf ~/.dotfiles/nvim/init.lua ~/.config/nvim/init.lua

# Tmux
ln -sf ~/.dotfiles/tmux/.tmux.conf ~/.tmux.conf

# Git
ln -sf ~/.dotfiles/git/.gitconfig ~/.gitconfig
ln -sf ~/.dotfiles/git/.gitignore_global ~/.gitignore_global

# Create local Git config (if not exists)
if [ ! -f ~/.dotfiles/git/.gitconfig.local ]; then
  cat > ~/.dotfiles/git/.gitconfig.local <<EOL
[user]
    name = Your Name
    email = your.email@example.com
EOL
fi

# SSH
mkdir -p ~/.ssh
ln -sf ~/.dotfiles/ssh/config ~/.ssh/config

# Create local SSH config (if not exists)
if [ ! -f ~/.dotfiles/ssh/config.local ]; then
  cat > ~/.dotfiles/ssh/config.local <<EOL
# Local SSH configurations - Example private server
Host myserver
    HostName server.example.com
    User admin
    Port 22
    IdentityFile ~/.ssh/id_ed25519_server
    AddKeysToAgent yes
    UseKeychain yes
    ForwardAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 10
EOL
fi

# Set proper permissions for SSH files
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config*
```

3. Secure important directories (run once):
```bash
# Restrict write permissions on Zsh function path directory
# This prevents potential security vulnerabilities by ensuring 
# only the owner can modify the directory where Zsh loads functions
chmod go-w "$(dirname ${fpath[1]})"

# Restrict write permissions on the cache directory
# This improves security by preventing other users from modifying cached data
# that might affect program execution or contain sensitive information
chmod go-w "${XDG_CACHE_HOME:-$HOME/.cache}"
```

4. Install iTerm2 shell integration:
```bash
curl -L https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh
```

5. Configure local settings:
   - Edit `~/.dotfiles/git/.gitconfig.local` with your Git user information
   - Edit `~/.dotfiles/ssh/config.local` with your SSH keys and host-specific settings
   - Both files are ignored by Git to keep sensitive information private

## 📋 Requirements

- macOS
- Git
- Zsh
- Neovim >= 0.8.0
- Tmux >= 3.0
- Sheldon (Zsh plugin manager, installed via Homebrew)
- [Optional] Powerlevel10k
- [Optional] Tmuxinator for session management
- Additional tools:
  - `zoxide` for smart directory jumping
  - `zsh-syntax-highlighting` for command syntax highlighting
  - `zsh-autosuggestions` for Fish-like autosuggestions
  - `fzf` for fuzzy finding

## 🔧 Local Customization

The configuration supports local overrides through `.local` files:
- `git/.gitconfig.local`: Git user info and machine-specific settings
- `ssh/config.local`: Machine-specific SSH configurations

## 🗺️ Roadmap

### Planned Features

- [ ] Automated installation script / Configuration wizard for first-time setup
- [ ] Package manager integration (Homebrew)
- [ ] Backup and restore system for configurations
- [ ] Performance optimization and startup time improvements
- [ ] Path structure implementation:
  ```
  ~/.local/bin/     # Direct symlinks only
  ~/dotfiles/bin/   # Helper scripts, install script, manifest
  ```

## 📝 License

MIT License
