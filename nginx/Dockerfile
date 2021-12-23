FROM centos:7

ARG VERSION=1.20.2

COPY dep.sh nginx.sh build.sh ffmpeg.sh /opt/
COPY bin/ttyd /usr/local/bin/ttyd

RUN chmod +x /usr/local/bin/ttyd /opt/{dep.sh,nginx.sh,build.sh,ffmpeg.sh} && /opt/build.sh

COPY cors.conf /etc/nginx

EXPOSE 80 443

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
