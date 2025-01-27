FROM quay.io/archlinux/archlinux AS box

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
    curl \
    diffutils \
    findutils \
    electron \
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
    rsync \
    rust \
    shadow \
    sudo \
    tcpdump \
    time \
    traceroute \
    tree \
    tzdata \
    unzip \
    util-linux \
    util-linux-libs \
    vte-common \
    wget \
    words \
    xorg-xauth \
    zip \
    mesa \
    opengl-driver \
    vulkan-intel \
    vte-common \
    vulkan-radeon \
    lib32-vulkan-radeon \
    zenity \
# Additional packages 0
    lib32-libnm \
    openal \
    pipewire \
    pipewire-pulse \
    pipewire-alsa \
    pipewire-jack \
    wireplumber \
    lib32-pipewire \
    lib32-pipewire-jack \
    lib32-libpulse \
    lib32-openal \
    libnotify \
# Additional packages 1
    cage \
    intel-media-driver \
    libva-mesa-driver \
    vulkan-mesa-layers \
    lib32-vulkan-mesa-layers \
    xdg-desktop-portal \
    xdg-desktop-portal-gnome \
    xdg-desktop-portal-gtk \
    xdg-utils \
    xorg-xeyes \
# Additional packages 2
    atuin \
    bat \
    bat-extras \
    bottom \
    btop \
    eza \
    fastfetch \
    fish \
    fisher \
    glow \
    libayatana-appindicator \
    libayatana-indicator \
    libappindicator-gtk3 \
    nano \
    reflector \
    starship \
    tealdeer \
    ueberzug \
    wlroots \
    yazi \
# Additional packages 3
    ffmpeg \
    gstreamer-vaapi \
    gstreamer \
    meld \
    mpv-mpris \
    python-mutagen \
    wl-clipboard \
    yt-dlp \
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
    aur/blackbox-terminal \
    --noconfirm
USER root
WORKDIR /

# Configs
RUN sed -i 's/# set autoindent/set autoindent/g; s/# set linenumbers/set linenumbers/g; s/# set magic/set magic/g; s/# set softwrap/set softwrap/g; s|# include /usr/share/nano/*.nanorc|include /usr/share/nano/*.nanorc|g' /etc/nanorc && \
    sed -i 's/#BottomUp/BottomUp/g' /etc/paru.conf && \
    sed -i 's@#en_US.UTF-8@en_US.UTF-8@g' /etc/locale.gen
# Cleanup
RUN userdel -r build && \
    rm -drf /home/build && \
    sed -i '/build ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
    sed -i '/root ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
    rm -rf /tmp/*