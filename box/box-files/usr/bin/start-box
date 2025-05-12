#!/usr/bin/env bash

set -euo pipefail
distrobox-export --app hatt -el none
distrobox-export --app "/usr/share/applications/jdownloader.desktop" -el none
distrobox-export --app megabasterd -el none
distrobox-export --bin /usr/bin/btop
distrobox-export --bin /usr/bin/glow
distrobox-export --bin /usr/bin/tldr
distrobox-export --bin /usr/bin/pingu
distrobox-export --app mangojuice -el none
distrobox-export --app zed -el none
echo "Exports successful!"
# Mirrors
echo "Updating Arch mirrors..."
sudo reflector --verbose -c AU -c CN -c ID -c JP -c NZ -c SG -c KR -c TH -c VN --protocol https --sort rate --latest 10 --download-timeout 3 --save /etc/pacman.d/mirrorlist
echo "Arch mirrors updated!"
# Font cache
fc-cache -fv
echo "Font cache successfully updated!"