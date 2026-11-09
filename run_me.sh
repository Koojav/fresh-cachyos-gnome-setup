#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# =============================================================================
# Definitions
# =============================================================================

SECTIONS=("core" "gnome" "dev" "gpu" "gaming" "comms")

# =============================================================================
# Prerequisites
# =============================================================================

# Base packages
pacman_update
pacman_upgrade

# Install paru to access AUR (Arch User Repository)
# Install dialog to display dialog windows with choices in text interface
pacman_install paru dialog

# =============================================================================
# CORE: base + git + shell
# =============================================================================

function install_section_core {
    show_dialog_section_begin "Core" "Fonts, pretty terminal"

    # Google Chrome
    aur_install google-chrome

    # Nerd fonts
    aur_install extra/ttf-firacode-nerd

    # Tailscale VPN
    pacman_install tailscale
    # https://tailscale.com/docs/reference/linux-dns#networkmanager--systemd-resolved
    sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
    sudo systemctl enable --now tailscaled

    # Starship
    curl -sS https://starship.rs/install.sh | sh -s -- -y

    # FZF - gigachad CTR-R search
    pacman_install fzf

    # Copy config files
    mkdir -p ~/.config && cp "$SCRIPT_DIR/.config/starship.toml" ~/.config/starship.toml
    cp -r "$SCRIPT_DIR/.config/fish" ~/.config
    cp -r "$SCRIPT_DIR/.config/kitty" ~/.config

    # Locale - install en_GB locale, just like en_US but weekdays start with Monday
    sudo localedef -i en_GB -f UTF-8 en_GB.UTF-8

    show_dialog_section_finished "Core"
}

# =============================================================================
# DESKTOP ENVIRONMENT: Gnome settings
# =============================================================================

function install_section_gnome {
    show_dialog_section_begin "Desktop Environment" "Gnome related modifications"

    gsettings set org.gnome.mutter dynamic-workspaces false
    gsettings set org.gnome.desktop.wm.preferences num-workspaces 4

    WM=org.gnome.desktop.wm.keybindings
%
    # Window shortcuts
    gsettings set $WM close            "['<Super>q']"
    gsettings set $WM toggle-maximized "['<Super>f']"

    # Workspace shortcuts: Super+N switches, Super+Shift+N moves the window
    for i in 1 2 3 4; do
        gsettings set org.gnome.shell.keybindings switch-to-application-$i "[]"
        gsettings set $WM switch-to-workspace-$i "['<Super>$i']"
        gsettings set $WM move-to-workspace-$i   "['<Shift><Super>$i']"
    done

    # Custom shortcut: Super+T opens kitty
    MK=org.gnome.settings-daemon.plugins.media-keys
    KB=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/

    gsettings set $MK custom-keybindings "['$KB']"
    gsettings set $MK.custom-keybinding:$KB name    'Open Kitty'
    gsettings set $MK.custom-keybinding:$KB command 'kitty'
    gsettings set $MK.custom-keybinding:$KB binding '<Super>t'

    # Switch to Dark Mode automatically
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

    show_dialog_section_finished "Desktop Environment"
}

# =============================================================================
# DEVELOPMENT: base + git + shell
# =============================================================================

function install_section_dev {
    show_dialog_section_begin "Development" "Python, Terraform, Docker, Github CLI, AWS CLI"

    pacman_install base-devel github-cli direnv

    # Python related
    pacman_install tk python python-pip pyenv 
    aur_install pyenv-virtualenv
    
    # tldr command
    pacman_install tealdeer
    tldr --update

    # Visual Studio Code (official, not some OSS bullshit)
    aur_install visual-studio-code-bin

    # Docker
    pacman_install docker docker-compose
    sudo systemctl enable docker
    sudo usermod -aG docker $USER

    # Terraform 
    pacman_install terraform

    # AWS CLI
    pacman_install aws-cli

    # Git settings
    local current_git_email=$(git config --global user.email 2>/dev/null)
    local current_git_name=$(git config --global user.name 2>/dev/null)
    local current_git_editor=$(git config --global core.editor 2>/dev/null)

    local git_email=$(dialog --stdout --inputbox "Git email:" 8 50 "$current_git_email")
    local git_name=$(dialog --stdout --inputbox "Git name:" 8 50 "$current_git_name")
    local git_editor=$(dialog --stdout --inputbox "Git editor:" 8 50 "$current_git_editor")

    [ -n "$git_email" ] && git config --global user.email "$git_email"
    [ -n "$git_name" ] && git config --global user.name "$git_name"
    [ -n "$git_editor" ] && git config --global core.editor "$git_editor"

    show_dialog_section_finished "Development"
}
# =============================================================================
# GPU: auto-detect and install drivers
# =============================================================================

function install_section_gpu {
    local gpu_type=$(detect_gpu)
    show_dialog_section_begin "GPU" "$gpu_type drivers"

    case "$gpu_type" in
        nvidia)
            pacman_install linux-cachyos-nvidia-open nvidia-utils lib32-nvidia-utils nvidia-settings
            show_dialog_section_finished "$gpu_type drivers installed"
            ;;
        amd)
            pacman_install mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon
            show_dialog_section_finished "$gpu_type drivers installed"
            ;;
        intel)
            pacman_install mesa lib32-mesa vulkan-intel lib32-vulkan-intel
            show_dialog_section_finished "$gpu_type drivers installed"
            ;;
        *)
            show_dialog_section_finished "GPU NOT DETECTED - INSTALL DRIVERS MANUALLY"
            return 1
            ;;
    esac 
}

# =============================================================================
# GAMING - CachyOS meta-packages
# =============================================================================

function install_section_gaming {
    show_dialog_section_begin "Gaming" "CachyOS gaming packages"

    # CachyOS gaming meta-packages
    # - cachyos-gaming-meta: Proton, Wine, 32-bit libs, Vulkan tools, audio plugins
    # - cachyos-gaming-applications: Steam, gamescope, mangohud
    pacman_install cachyos-gaming-meta cachyos-gaming-applications

    # Wrapper for applications like Steam that allows games to request optimizations
    # https://wiki.archlinux.org/title/GameMode
    # NOTE: Remember to add: 
    # gamemoderun PROTON_ENABLE_NVAPI=1 DXVK_ENABLE_NVAPI=1 DXVK_NVAPI_ALLOW_OTHER_DRIVERS=1 %command%
    # to Steam games' parameters
    pacman_install gamemode lib32-gamemode
    sudo usermod -aG gamemode $USER

    show_dialog_section_finished "Gaming"
}

# =============================================================================
# COMMUNICATORS - Slack, Vesktop (Discord)
# =============================================================================

function install_section_comms {
    show_dialog_section_begin "Communicators" "Slack, Vencord"

    aur_install vesktop-bin slack-desktop-wayland

    show_dialog_section_finished "Communicators"
}

# =============================================================================
# RUNNER
# =============================================================================

show_dialog_menu() {
    local args=()
    args+=("ALL" ">>> Install everything <<<" "OFF")
    for i in "${!SECTIONS[@]}"; do
        args+=("$((i+1))" "${SECTIONS[i]}" "OFF")
    done

    local choices
    choices=$(dialog --stdout --title "CachyOS Fresh Setup" \
        --checklist "SPACE=toggle, ENTER=confirm" \
        20 90 15 \
        "${args[@]}")

    echo "$choices"
}

install_sections() {
    local indices="$1"

    if [[ "$indices" == *"ALL"* ]]; then
        for section in "${SECTIONS[@]}"; do
            "install_section_${section}"
        done
        return
    fi

    for index in $indices; do
        index="${index//\"/}"
        local section="${SECTIONS[index-1]}"
        "install_section_${section}"
    done
}

main() {
    local input=""

    if [[ "$1" == "--all" ]]; then
        input="ALL"

    elif [[ "$#" -eq 0 ]]; then
        input=$(show_dialog_menu)
        if [[ -z "$input" ]]; then
            echo "No sections selected. Exiting."
            exit 0
        fi

    else
        input="$*"
    fi

    install_sections "$input"
}

main "$@"

echo "Type 'reboot' so all changes to usergroups etc. are finalized."
