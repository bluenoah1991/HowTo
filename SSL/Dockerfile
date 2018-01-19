FROM ubuntu:14.04

MAINTAINER codemeow codemeow@yahoo.com

RUN cp /etc/apt/sources.list /etc/apt/sources.list.raw
ADD https://github.com/codemeow5/software/raw/master/ubt_sources_list_aliyun.txt /etc/apt/sources.list
RUN apt-get update && apt-get install wget -y

RUN apt-get install apache2 apache2-data -y
RUN a2enmod ssl
RUN apt-get install openssl -y
#RUN openssl genrsa -des3 -out server.key 1024
#RUN openssl req -new -key server.key -out server.csr
#RUN openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
RUN openssl req -nodes -new -x509 -keyout server.key -out server.crt \
	-subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com"

CMD /bin/bash
