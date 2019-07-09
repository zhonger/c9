# Cloud9 server
# A lot inspired by https://hub.docker.com/r/gai00/cloud9/~/dockerfile/
#                   https://hub.docker.com/r/kdelfour/cloud9-docker/~/dockerfile/
#                   https://github.com/sapk/dockerfiles/blob/master/cloud9/Dockerfile

FROM node:slim
LABEL maintainer="zhonger <zhonger@live.cn>"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y locales \
 && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
 && locale-gen en_US.UTF-8 \
 && dpkg-reconfigure locales \
 && /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

RUN buildDeps='make build-essential g++ gcc python2.7' && softDeps="tmux git" \
 && apt-get update && apt-get upgrade -y \
 && apt-get install -y $buildDeps $softDeps --no-install-recommends \
 && npm install -g forever && npm cache clean --force \
 && git clone --depth=5 https://github.com/c9/core.git /cloud9 && cd /cloud9 \
 && scripts/install-sdk.sh \
 && apt-get purge -y --auto-remove $buildDeps \
 && apt-get autoremove -y && apt-get autoclean -y && apt-get clean -y \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && npm cache clean --force \
 && git reset --hard

RUN apt-get update && apt-get install -y zsh git-core \
    && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
    && chsh -s /bin/zsh

RUN apt-get update \
    && apt-get install -y dns-utils apt-transport-https inetutils-ping \
    && rm -rf /var/lib/apt/lists/*

VOLUME /workspace
EXPOSE 8181 
ENTRYPOINT ["forever", "/cloud9/server.js", "-w", "/workspace", "--listen", "0.0.0.0"]

CMD ["--auth","c9:c9"]