# Elimage

An opensource image bed.

https://github.com/Vim-cn/elimage

## Usage

```yaml
version: "3"
services:
  app:
    image: butanediol/elimage:action
    restart: always
    volumes:
      - ./img:/tmp
      - type: bind
        source: ./elimage.db
        target: /elimage/elimage.db
    command: python3 /elimage/main.py --password="password" --cloudflare true
```

