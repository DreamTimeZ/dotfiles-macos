# Initialize ASDF version manager (Homebrew variant)
if [ -f "$(brew --prefix asdf)/libexec/asdf.sh" ]; then
  source "$(brew --prefix asdf)/libexec/asdf.sh"
fi