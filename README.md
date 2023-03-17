# Nginx-rtmp-docker

## Ports

- 1935: RTMP
- 8080: HTTP(HLS)

## Usage

### Push(OBS)

Settings -> Stream -> Service: Custom -> Server: rtmp://<address>/live

Stream key: any string

### Watch

http://<address>:8080/hls/<stream key>.m3u8

or

rtmp://<address>/live/<stream key>
