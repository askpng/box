# box

Arch Linux distrobox intended for on-the-go command line use or for building other containers. Optimized for GNOME.

## box:

```
distrobox create -i ghcr.io/askpng/box:latest -n box
```

Notable inclusion:
- Distrobox first launch packages
- AMD & Intel graphics packages
- Pipewire & Wireplumber packages
- Adobe Source CJK Sans & Sans Serif fonts
- BlackBox terminal, downgrade, MoreWaita icon pack, and pingu straight from AUR
- CLI tools, such as arttime, atuin, bat, fish, eza, glow, starship, tealdeer, wl-clipboard, and yazi
- celluloid, ffmpeg, gstreamer, and yt-dlp
- fastfetch, of course
- fish shell with aliases included within `/etc/fish/functions/`
- paru & nano configured
- `vesktop-electron`, `discord_arch_electron`, and `linux-discord-rich-presence` installed to rely on Electron installed from the default Arch repo

Configure exports by running

```
start-box
```

upon distrobox creation.

## gaming-box

```
distrobox create -i ghcr.io/askpng/box:latest -n box
```

Notable inclusion:
- AdwSteamGTK, Lutris, Steam & SGDBoop
- gamemode
- goverlay & mangohud
- ludusavi 
- steamtinkerlaunch & vkBasalt
- ProtonPlus, wine & winetricks

(Optional) Add Chaotic-AUR repos by running

```
chaotic
```

Configure exports by running

```
start-gb
```

upon distrobox creation.

