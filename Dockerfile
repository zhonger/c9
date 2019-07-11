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

RUN apt-get update \
    && apt-get install -y dnsutils inetutils-ping ca-certificates apt-transport-https \
    && apt-get install -y git-core fish mycli apt-utils zip unzip

COPY sources.list /etc/apt/sources.list
COPY mirror.sh /home/node/mirror.sh

RUN wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add - \
    && echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list \
    && apt-get update && apt-get -y install php7.2 \
    && apt-get -y install php7.2-cli php7.2-common php7.2-curl php7.2-mbstring php7.2-mysql php7.2-xml \
    && rm -rf /var/lib/apt/lists/* \
    && wget https://getcomposer.org/composer.phar \
    && wget https://install.phpcomposer.com/composer.phar \
    && chmod +x composer.phar \
    && mv composer.phar /usr/local/bin/composer  


VOLUME /workspace
EXPOSE 8181 
ENTRYPOINT ["forever", "/cloud9/server.js", "-w", "/workspace", "--listen", "0.0.0.0"]

CMD ["--auth","c9:c9"]