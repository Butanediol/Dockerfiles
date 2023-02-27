FROM gregyankovoy/alpine-base

ARG build_deps="git build-base ncurses-dev autoconf automake git gettext-dev libmaxminddb-dev"
ARG runtime_deps="nginx tini ncurses libintl libmaxminddb"
ARG geolite_city_link="https://git.io/GeoLite2-City.mmdb"

WORKDIR /goaccess

# Build goaccess with mmdb geoip
RUN apk add --update --no-cache ${build_deps} && \
    git clone https://github.com/allinurl/goaccess . && \
    git checkout $(git describe --tags `git rev-list --tags --max-count=1`) && \
    autoreconf -fiv && \
    ./configure --enable-utf8 --enable-geoip=mmdb && \
    make && \
    make install && \
    rm -rf /tmp/goaccess/* /goaccess && \
    apk del $build_deps

# Get necessary runtime dependencies and set up configuration
RUN apk add --update --no-cache ${runtime_deps} && \
    mkdir -p /usr/local/share/GeoIP && \
    wget -q -O /usr/local/share/GeoIP/GeoLite2-City.mmdb ${geolite_city_link}

COPY /root /

RUN chmod +x /usr/local/bin/goaccess.sh && \
    chmod -R 777 /var/tmp/nginx

EXPOSE 7889
VOLUME [ "/config", "/opt/log" ]

CMD [ "sh", "/usr/local/bin/goaccess.sh" ]