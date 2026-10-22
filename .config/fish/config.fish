# Source original CachyOS Fish helpers
source /usr/share/cachyos-fish-config/cachyos-config.fish

# Remove default Fish greeting defined in the above cachyos-config.fish
function fish_greeting
end

# Pyenv root
set -Ux PYENV_ROOT $HOME/.pyenv
# Add pyenv to PATH if not already present
test -d $PYENV_ROOT/bin; and fish_add_path $PYENV_ROOT/bin

# Disable virtualenv prompt changes
set -gx PYENV_VIRTUALENV_DISABLE_PROMPT 1

# Initialize pyenv for Fish
pyenv init - fish | source

# Add SSH key to SSH Agent
if not ssh-add -l &>/dev/null
    eval (ssh-agent -c)
    ssh-add ~/.ssh/id_rsa
end

# To learn about prompt customization visit: https://starship.rs/config/
starship init fish | source 

# Turn on Fuzzy search shortcuts
fzf --fish | source
