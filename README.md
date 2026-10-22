# Setup a brand new CachyOS with Hyprland

## 📝 Remember to backup important stuff
- [ ] Credentials: `.ssh`, `.aws`, `.pgpass`, `.my.cnf`
- [ ] Configs: `.gitconfig`
- [ ] Projects

## 🧑‍🔧 Install CachyOS 

Download from [here](https://cachyos.org/download/) and install with following components:

- Bootloader: **Limine**
- Desktop Environment: **Gnome**
- Terminal: **Kitty**
- Shell: **Fish**

## 🍝 Copypasta this

```
cd ~ \
   && git clone https://github.com/Koojav/fresh-cachyos-setup.git \
   && cd fresh-cachyos-setup \
   && chmod +x run_me.sh \
   && ./run_me.sh
```

## 🔄 Restart 
Don't skip this step. Some group settings and other stuff need an actual reboot.

## 🎉 There you go!

Following shit has been configured for you:

### Core

- [x] `Full System update` : all newest packages
- [x] `Chrome` : renders StackOverflow a bit nicer than curl
- [x] `FiraCode Nerd Fonts` : icons for everything
- [x] `Kitty` `Fish` `Starship` : terminal, shell and prompt with love
- [x] `fzf` : recursive search that works

### Gnome

- [x] Setup basic shortcuts via `gsettings`

### Development

- [x] `base-devel`: prerequired libraries, noone cares what's in it
- [x] `github-cli` : create Pull Requests like 90s hackers
- [x] `direnv` : automatic environments when you cd into a folder
- [x] `tealdeer` : man pages for human beings
- [x] `Visual Studio Code` : food ain't free
- [x] `Docker` : containerized containers keep containerizing
- [x] `aws-cli` `terraform`: would be a shame if something happened to your cluster

### GPU

- [x] `drivers` : automatic NVIDIA / AMD driver installation

### Gaming

- [x] `cachyos-gaming-meta` `cachyos-gaming-applications` : Steam, gamescope, mangohud
- [x] `gamemode` : Wrapper for applications like Steam that allows games to request optimizations.  

⚠️ **Important** ⚠️ see also [Running games on Steam](#running-games-on-steam) section.  

### Communicators

- [x] `Vesktop` : Discord that shares less with Our Great Communist Overlords
- [x] `Slack` : I don't want to talk about it  

# Post-installation customization
When making changes remember to manually sync them between this repo and your `~/.config`.  
This can be done by re-running `run_me.sh` or using a shortcut defined in `.config/hypr/conf/keybindings.conf`

## Arch Linux
Base for CachyOS.  
Great knowledge base is available in [the official Wiki](https://wiki.archlinux.org/).

## Starship
Responsible for prompt look and functionality.  
Please see `.config/starship.toml` file and [the official Website](https://starship.rs/config).

## Kitty
Responsible for terminal emulation.  
Please see:  
- `.config/kitty/colors_gruvbox_dark` for color definitions
- `.config/kitty/kitty.conf` for layout and other settings  

Also [the official Kitty Website](https://sw.kovidgoyal.net/kitty/).

# Additional info

## Running games on Steam 

Set compatibility to: `proton-cachyos-10.x-YYYYMMDD`

Use following launch options 

```
gamemoderun PROTON_ENABLE_NVAPI=1 DXVK_ENABLE_NVAPI=1 DXVK_NVAPI_ALLOW_OTHER_DRIVERS=1 %command%
```

which enable:
- OS optimizations
- CPU governance (performance mode)
- DLSS
