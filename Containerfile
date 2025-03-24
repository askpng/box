# Build box first, then gaming-box

FROM quay.io/toolbx/arch-toolbox AS box

# Pacman Initialization
# Create build user
RUN sed -i 's/#Color/Color/g' /etc/pacman.conf && \
    printf "[multilib]\nInclude = /etc/pacman.d/mirrorlist\n" | tee -a /etc/pacman.conf && \
    sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$(nproc)"/g' /etc/makepkg.conf && \
    pacman-key --init && pacman-key --populate && \
    pacman -Syu --noconfirm && \
    useradd -m --shell=/bin/bash build && usermod -L build && \
    echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    pacman -S --clean --clean

# git & base-devel
RUN pacman -S --needed \
    git \
    base-devel \
    wget \
    --noconfirm

# Distrobox integration
RUN git clone https://github.com/89luca89/distrobox.git --single-branch /tmp/distrobox && \
    cp /tmp/distrobox/distrobox-host-exec /usr/bin/distrobox-host-exec && \
    ln -s /usr/bin/distrobox-host-exec /usr/bin/flatpak && \
    wget https://github.com/1player/host-spawn/releases/download/$(cat /tmp/distrobox/distrobox-host-exec | grep host_spawn_version= | cut -d "\"" -f 2)/host-spawn-$(uname -m) -O /usr/bin/host-spawn && \
    chmod +x /usr/bin/host-spawn && \
    rm -drf /tmp/distrobox

# Installation
RUN pacman -S --needed \
## Speed up first launch
    adw-gtk-theme \
    bash-completion \
    bc \
    cage \
    curl \
    diffutils \
    electron \
    findutils \
    glibc \
    glibc-locales \
    gnupg \
    inetutils \
    keyutils \
    less \
    lsof \
    man-db \
    man-pages \
    mlocate \
    mtr \
    ncurses \
    nss-mdns \
    openssh \
    pigz \
    pinentry \
    procps-ng \
    rust \
    rsync \
    shadow \
    sudo \
    tcpdump \
    time \
    traceroute \
    tree \
    tzdata \
    unrar \
    unzip \
    util-linux \
    util-linux-libs \
    vte-common \
    words \
    xorg-xauth \
    zenity \
    zip \
# Graphics 
    intel-media-driver \
    lib32-vulkan-icd-loader \
    lib32-vulkan-mesa-layers \
    libva-intel-driver \
    libva-mesa-driver \
    libva-utils \
    mesa \
    opengl-driver \
    vulkan-icd-loader \
    vulkan-intel \
    vulkan-mesa-layers \
    vulkan-radeon \
    lib32-vulkan-radeon \
    vulkan-tools \
# Sound 
    lib32-libnm \
    openal \
    pipewire \
    pipewire-alsa \
    pipewire-jack \
    pipewire-pulse \
    wireplumber \
    lib32-pipewire \
    lib32-pipewire-jack \
    lib32-libpulse \
    lib32-openal \
# Desktop Integration
    libnotify \
    xdg-desktop-portal \
    xdg-desktop-portal-gnome \
    xdg-desktop-portal-gtk \
    xdg-utils \
    xorg-xeyes \
# Fonts 
    adobe-source-han-sans-otc-fonts \
    adobe-source-han-serif-otc-fonts \
# Utilities 
    atuin \
    bat \
    bat-extras \
    bottom \
    btop \
    celluloid \
    eza \
    fastfetch \
    fish \
    fisher \
    glow \
    gum \
    libayatana-appindicator \
    libayatana-indicator \
    libappindicator-gtk3 \
    nano \
    rclone \
    reflector \
    ruby \
    rust \
    starship \
    tealdeer \
    ueberzug \
    wlroots \
    yazi \
    zenity \
# Multimedia 
    ffmpeg \
    gstreamer \
    gstreamer-vaapi \
    meld \
    mpv-mpris \
    python-mutagen \
    wl-clipboard \
    yt-dlp \
# Others
    alsa-lib \
    alsa-plugins \
    giflib \
    gnutls \
    gst-libav \
    gst-plugins-bad \
    gst-plugins-base \
    gst-plugins-base-libs \
    gst-plugins-good \
    gst-plugins-ugly \
    gtk3 \
    lib32-alsa-lib \
    lib32-alsa-plugins \
    lib32-giflib \
    lib32-gnutls \
    lib32-gst-plugins-base \
    lib32-gst-plugins-base-libs \
    lib32-gst-plugins-good \
    lib32-gtk3 \
    lib32-libpulse \
    lib32-libva \
    lib32-libxcomposite \
    lib32-ocl-icd \
    lib32-sqlite \
    lib32-v4l-utils \
    libpulse \
    libva \
    libxcomposite \
    ocl-icd \
    sqlite \
    v4l-utils \
    --noconfirm && \
    rm -rf /var/cache/pacman/pkg/*

USER build
WORKDIR /home/build
RUN git clone https://aur.archlinux.org/paru-bin.git --single-branch && \
    cd paru-bin && \
    makepkg -si --noconfirm && \
    cd .. && \
    rm -drf paru-bin
RUN paru -S \
    # aur/arttime-git \
    aur/betterdiscord-installer-bin \
    aur/blackbox-terminal \
    aur/discord_arch_electron \
    aur/downgrade \
    aur/hatt-bin \
    aur/jdownloader2 \
    # aur/linux-discord-rich-presence \
    aur/ludusavi-bin \
    aur/megabasterd-bin \
    aur/nsz2nsp \
    aur/pingu \
    # aur/vesktop-electron \
    --noconfirm
USER root
WORKDIR /

RUN pacman -S --clean --clean

# Configs
RUN cp /etc/pacman.conf /etc/pacman.conf.bak && \
    sed -i 's/#BottomUp/BottomUp/g' /etc/paru.conf && \
    # sed -i -e '25s/^#IgnorePkg/IgnorePkg/' -e '25s/$/ arttime-git blackbox-terminal hatt-bin jdownloader2 linux-discord-rich-presence megabasterd-bin pingu spotify-player-full-pipe vesktop-electron/' /etc/pacman.conf && \
    sed -i -e '25s/^#IgnorePkg/IgnorePkg/' -e '25s/$/ blackbox-terminal hatt-bin jdownloader2 megabasterd-bin pingu/' /etc/pacman.conf && \
    sed -i 's@#en_US.UTF-8@en_US.UTF-8@g' /etc/locale.gen && \
    sed -i 's/-march=x86-64 -mtune=generic/-march=native -mtune=native/g' /etc/makepkg.conf
    # sed -i 's@ (linux-discord-rich-presence)@@g' /usr/share/applications/linux-discord-rich-presence.desktop

# Cleanup
RUN userdel -r build && \
    rm -drf /home/build && \
    sed -i '/build ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
    sed -i '/root ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
    rm -rf /home/build/.cache/* && \
    rm -rf \
        /tmp/* \
        /var/cache/pacman/pkg/*

COPY box-files /

# Build gaming-box

FROM box AS gaming-box

RUN sed -i 's/-march=native -mtune=native/-march=x86-64 -mtune=generic/g' /etc/makepkg.conf

RUN pacman -S --needed \
        libbsd \
        wmctrl \
        wxwidgets-gtk3 \
        xorg-xwayland \
        xorg-xwininfo \
        --noconfirm && \
    pacman -S --needed \
        gnu-free-fonts \
        goverlay \
        lib32-mangohud \
        mangohud \
        mesa-demos \
        vulkan-tools \
        --noconfirm && \
    pacman -S --needed \
        sdl2 \
        lib32-sdl2 \
        vkd3d \
        lib32-vkd3d \
        vulkan-icd-loader \
        lib32-vulkan-icd-loader \
        winetricks \
        --noconfirm && \
    pacman -S --needed \
        lutris \
        steam \
        --noconfirm

# Create build user
RUN useradd -m --shell=/bin/bash build && usermod -L build && \
    echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
# Install AUR packages
USER build
WORKDIR /home/build
RUN paru -S \
        aur/adwsteamgtk \
        aur/citron \
        aur/mangojuice-bin \
        aur/protonplus \
        aur/sgdboop-bin \
        # aur/steamcmd \
        aur/steamtinkerlaunch \
        aur/vkbasalt \
        aur/lib32-vkbasalt \
        --noconfirm
USER root
WORKDIR /

RUN pacman -S --clean --clean

COPY gb-files /

# Clean up Steam desktop entry
RUN sed -i 's@ (Runtime)@@g' /usr/share/applications/steam.desktop && \
    sed -i 's/-march=x86-64 -mtune=generic/-march=native -mtune=native/g' /etc/makepkg.conf && \
    # sed -i '25s/$/ adwsteamgtk ludusavi-bin protonplus sgdboop-bin steamcmd steamtinkerlaunch/' /etc/pacman.conf
    sed -i '25s/$/ adwsteamgtk ludusavi-bin protonplus sgdboop-bin/' /etc/pacman.conf

# Clean up any unnecessary files
RUN userdel -r build && \
    rm -drf /home/build && \
    sed -i '/build ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
    sed -i '/root ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
    rm -rf /home/build/.cache/* && \
    rm -rf \
        /tmp/* \
        /var/cache/pacman/pkg/*
