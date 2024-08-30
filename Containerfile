FROM quay.io/toolbx/arch-toolbox AS box
# FROM quay.io/archlinux/archlinux:latest AS box

# Pacman init & Build user
RUN sed -i 's/#Color/Color/g' /etc/pacman.conf && \
    printf "[multilib]\nInclude = /etc/pacman.d/mirrorlist\n" | tee -a /etc/pacman.conf && \
    sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$(nproc)"/g' /etc/makepkg.conf && \
    pacman-key --init && pacman-key --populate && \
    pacman -Syu --noconfirm && \
    useradd -m --shell=/bin/bash build && usermod -L build && \
    echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install git & base-devel
RUN pacman -S --needed \
        git \
        base-devel \
        --noconfirm

# Distrobox init
RUN git clone https://github.com/89luca89/distrobox.git --single-branch /tmp/distrobox && \
    cp /tmp/distrobox/distrobox-host-exec /usr/bin/distrobox-host-exec && \
    ln -s /usr/bin/distrobox-host-exec /usr/bin/flatpak && \
    wget https://github.com/1player/host-spawn/releases/download/$(cat /tmp/distrobox/distrobox-host-exec | grep host_spawn_version= | cut -d "\"" -f 2)/host-spawn-$(uname -m) -O /usr/bin/host-spawn && \
    chmod +x /usr/bin/host-spawn && \
    rm -drf /tmp/distrobox

# Install reflector & update mirrors
RUN pacman -S reflector --noconfirm
RUN reflector --protocol https --sort rate --latest 5 --download-timeout 35 --save /etc/pacman.d/mirrorlist

# Default packages for distrobox
RUN pacman -S \
        adw-gtk-theme \
        bash-completion \
        bc \
        curl \
        diffutils \
        findutils \
        glibc \
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
        --noconfirm

# Install needed packages
RUN pacman -S --needed \
        cage \
        libva-mesa-driver \
        vulkan-mesa-layers \
        vulkan-radeon \
        wlroots \
        xdg-desktop-portal \
        xdg-desktop-portal-gnome \
        xdg-desktop-portal-gtk \
        xdg-utils \
        xorg-xeyes \
        --noconfirm

# Install CLI essentials
RUN pacman -S --needed \
        atuin \
        bat \
        bat-extras \
        btop \
        eza \
        fastfetch \
        fish \
        fisher \
        nano \
        starship \
        tealdeer \
        ueberzug \
        wl-clipboard \
        yazi \
        --noconfirm

# Install media utilities
RUN pacman -S --needed \
        celluloid \
        ffmpeg \
        gstreamer-vaapi \
        gstreamer \
        mpv-mpris \
        playerctl \
        python-mutagen \
        yt-dlp \
        --noconfirm

# Add paru for building AUR packages
USER build
WORKDIR /home/build
RUN git clone https://aur.archlinux.org/paru-bin.git --single-branch && \
    cd paru-bin && \
    makepkg -si --noconfirm && \
    cd .. && \
    rm -drf paru-bin
#    paru -S \
#        aur/placeholder \
#        --noconfirm

# Run paru to build hatt-bin & megabasterd-bin
RUN paru -S \
        aur/hatt-bin \
        aur/megabasterd-bin \
        --noconfirm
USER root
WORKDIR /

# Cleanup
RUN sed -i 's@#en_US.UTF-8@en_US.UTF-8@g' /etc/locale.gen && \
    userdel -r build && \
    rm -drf /home/build && \
    sed -i '/build ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
    sed -i '/root ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
    rm -rf \
        /tmp/* \
        /var/cache/pacman/pkg/*