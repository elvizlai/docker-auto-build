FROM centos:7

ARG VERSION=1.20.0

COPY dep.sh nginx.sh build.sh ffmpeg.sh /opt/

RUN chmod +x /opt/{dep.sh,nginx.sh,build.sh,ffmpeg.sh} && /opt/build.sh

COPY cors.conf /etc/nginx

EXPOSE 80 443

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
