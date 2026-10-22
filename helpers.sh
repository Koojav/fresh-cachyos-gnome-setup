#!/bin/bash
# helpers.sh - Arch Linux detection and package helpers

show_dialog_section_begin() {
    dialog --title " $1 " --infobox "\n$2\n" 5 60
    sleep 1.5
}

show_dialog_section_finished() {
    dialog --title " $1 " --infobox "\n✓ Done\n" 5 60
    sleep 1.3
}

# =============================================================================
# Package manager related
# =============================================================================

pacman_update() {
    sudo pacman -Syy
}

pacman_upgrade() {
    sudo pacman -Syu --noconfirm
}

pacman_install() {
    sudo pacman -S --noconfirm --needed "$@"
}

aur_install() {
    paru -S --noconfirm --needed "$@"
}

# =============================================================================
# GPU - auto-detect and install drivers
# =============================================================================

detect_gpu() {
    if lspci | grep -qi nvidia; then
        echo "nvidia"
    elif lspci | grep -qi "amd\|radeon"; then
        echo "amd"
    elif lspci | grep -qi intel; then
        echo "intel"
    else
        echo "unknown"
    fi
}