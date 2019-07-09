#
# Dockerfile for shadowsocks-libev
# docker run -p 1080:1080 -p 8118:8118 --name container_name image_name
#

FROM ubuntu:18.04
LABEL maintainer="codemeow5 <codemeow@icloud.com>"

ADD https://github.com/codemeow5/HowTo/raw/master/Assets/ubt_1804_aliyun_sources.list /etc/apt/sources.list

RUN apt-get update
RUN apt install shadowsocks-libev privoxy -y

RUN sed -i '$a\forward-socks5\t/\t127.0.0.1:1080\t.' /etc/privoxy/config
RUN sed -i 's/^listen-address/#listen-address/' /etc/privoxy/config
RUN sed -i '$a\listen-address\t0.0.0.0:8118' /etc/privoxy/config

ADD ./shadowsocks.json /etc/shadowsocks.json
ADD v2ray-plugin_linux_amd64 /usr/bin/v2ray-plugin_linux_amd64
ADD server.crt /root/server.crt

EXPOSE 1080 8118

CMD /usr/sbin/privoxy \
	  --pidfile /var/run/privoxy.pid \
	  /etc/privoxy/config && \
	  /usr/bin/ss-local \
	  -c /etc/shadowsocks.json