FROM python:3-alpine

WORKDIR /elimage

RUN apk add git file libqrencode --no-cache && \
    pip install tornado && \
    git clone https://github.com/Vim-cn/elimage . --depth 1 && \
    apk del git

EXPOSE 8888
VOLUME /tmp
VOLUME /elimage/elimage.db

CMD python3 /elimage/main.py
