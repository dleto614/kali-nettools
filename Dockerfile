FROM kalilinux/kali-rolling

# Noninteractive mode to avoid prompts during installs
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y

RUN apt update && \
    apt install -y \
        git \
        python3 \
        python3-pip \
        hostapd \
        isc-dhcp-server \
        rfkill \
        iproute2 \
        iputils-ping \
        net-tools \
        aircrack-ng \
        build-essential \
        libnl-3-dev \
        libnl-genl-3-dev \
        libssl-dev \
        libdbus-1-dev \
        libpcap-dev \
        libreadline-dev \
        libsqlite3-dev \
        libpcre3-dev \
        libnl-genl-3-200 \
        dnsmasq \
        iw \
        tcpdump \
        bettercap \
        pipx \
        jq \
        network-manager \
        dbus \
        wireless-tools \
        && apt clean

# Clone and install EAPHammer
RUN git clone https://github.com/s0lst1c3/eaphammer.git /opt/eaphammer

# You have to input y or yes or else this fails.
# TODO: Edit the setup script to truly be noninteractive. Done. Fuck NetworkManager.
# TODO: symlink eaphammer to /usr/local/bin
RUN cd /opt/eaphammer && yes | ./kali-setup
#RUN ./eaphammer --cert-wizard # This doesn't work without user input.

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh # Install rust
RUN pipx ensurepath

# We can just do sudo apt install netexec, but...
RUN pipx install git+https://github.com/Pennyw0rth/NetExec

# Will add more tools as I continue testing this image and figure out what I want.
# Will write more scripts to automate every tool to give users the most options using the tools.

WORKDIR /opt/

COPY start.sh /etc/init/
RUN chmod +x /etc/init/start.sh
ENTRYPOINT ["/etc/init/start.sh"]

