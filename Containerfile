FROM docker.io/cachyos/cachyos:latest AS cachyos-toolbox

RUN sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$(nproc)"/g' /etc/makepkg.conf && \
    pacman-key --init && pacman-key --populate && \
    useradd -m --shell=/bin/bash build && usermod -L build && \
    echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/build

RUN pacman -Sy --needed \
    # appindicator
    libayatana-appindicator
    # QoL CLI
    atuin \
    bat \
    bat-extras \
    bottom \
    downgrade \
    eza \
    fastfetch \
    fish \
    glow \
    jdownloader2 \
    reflector \
    superfile \
    starship \
    tealdeer \
    yazi \ 
    # Other CLI
    nano \
    python-mutagen \
    ueberzug \
    unrar \
    unzip \
    util-linux \
    wget \
    which \
    wl-clipboard \
    # Videos
    deno \
    ffmpeg \
    gstreamer \
    mpv \
    mpv-mpris \
    yt-dlp \
    # Firmware
    linux-firmware \
    linux-firmware-amdgpu \
    linux-firmware-intel \
    intel-media-driver \
    vulkan-intel \
    vulkan-radeon \
    # Everything else
    cage \
    electron \
    foot \
    micro \
    meld \
    nano \
    which \
    xdg-desktop-portal-gtk \
    xdg-utils \
    xorg-xeyes \
    yay \
    zenity \
    --noconfirm  

USER build
WORKDIR /home/build
RUN yay -S \
    aur/megabasterd-bin \
    aur/nsz2nsp \
    aur/pingu \
    aur/sgdboop-bin \ 
    --noconfirm --removemake
RUN yay -Sccd --noconfirm
USER root
WORKDIR /

RUN git clone https://github.com/89luca89/distrobox.git --single-branch /tmp/distrobox && \
    cp /tmp/distrobox/internal/inside-distrobox/assets/distrobox-host-exec /usr/bin/distrobox-host-exec && \
    ln -s /usr/bin/distrobox-host-exec /usr/bin/flatpak && \
    wget https://github.com/1player/host-spawn/releases/download/$(cat /tmp/distrobox/internal/inside-distrobox/assets/distrobox-host-exec | grep host_spawn_version= | cut -d "\"" -f 2)/host-spawn-$(uname -m) -O /usr/bin/host-spawn && \
    chmod +x /usr/bin/host-spawn && \
    rm -drf /tmp/distrobox  

RUN userdel -r build && \
    rm -drf /home/build && \
    rm -f /etc/sudoers.d/build && \
    rm -rf /home/build/.cache/* && \
    rm -rf \
        /tmp/* \
        /var/cache/* && \
    # pacman -Rcns binutils gcc guile texinfo --noconfirm && \
    pacman -Scc --clean --clean

RUN sed -i 's@#en_US.UTF-8@en_US.UTF-8@g' /etc/locale.gen && \
    mkdir -p /etc/sudoers.d && \
    echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/wheel

RUN if [[ -e /etc/sudoers.pacnew ]] ; then \
        rm /etc/sudoers && mv /etc/sudoers.pacnew /etc/sudoers; \
    fi

COPY box-files /