FROM debian:bullseye

# upgrade debian packages
ENV DEBIAN_FRONTEND="noninteractive"
# fix "September 30th problem"
# https://github.com/nodesource/distributions/issues/1266#issuecomment-931597235
RUN apt update; apt install -y ca-certificates && \
    apt update; \
    apt install apt-utils -y \
    && apt upgrade -y \
    && rm -rf /var/lib/apt/lists/* \
;

# install the necessary things
RUN apt install -y \
    git \
    curl \
    zsh \
    neovim \
    python3-pip \
    neofetch \
    lolcat \
    cowsay \
    bat \
    exa \
    && rm -rf /var/lib/apt/lists/* \
;

# add /usr/games to the path so we can use lolcat and cowsay
ENV PATH=/usr/games:$PATH

# symlink batcat to bat
RUN ln -s /usr/bin/batcat /usr/bin/bat

# install cloudflared
ENV CLOUDFLARED_VERSION=2022.12.1
RUN curl -Ls https://github.com/cloudflare/cloudflared/releases/download/${CLOUDFLARED_VERSION}/cloudflared-linux-amd64 \
           > /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# install ansible
# https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-debian
RUN echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu focal main" | \
    tee /etc/apt/sources.list.d/ansible.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367 && \
    apt update \
    && apt install ansible -y \
    && rm -rf /var/lib/apt/lists/* \
;

# change working directory to root user's home directory
WORKDIR /root

# install zplug
# https://github.com/zplug/zplug#manually
ENV ZPLUG_HOME=/root/.zplug
RUN git clone https://github.com/zplug/zplug $ZPLUG_HOME

# install liquidprompt
RUN mkdir -p dev/git
RUN git clone https://github.com/nojhan/liquidprompt.git dev/git/liquidprompt
ENV LP_ENABLE_SSH_COLORS=1

# copy over zsh plugins and install
COPY .jeffreytse_zsh-vi-mode.tar.gz /root/.zplug/jeffreytse_zsh-vi-mode.tar.gz
RUN cd /root/.zplug && tar xzvf jeffreytse_zsh-vi-mode.tar.gz

# copy over .zshrc
COPY .zshrc .

# main working directory
WORKDIR /usr/src

# run playbooks as entrypoint
ENTRYPOINT ["/usr/bin/ansible-playbook"]
