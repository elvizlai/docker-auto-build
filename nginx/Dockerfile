FROM centos:7

ARG VERSION=1.20.2

COPY org-build.sh org-dep.sh org-nginx.sh org-ffmpeg.sh /opt/
COPY bin/ttyd /usr/local/bin/ttyd

RUN chmod +x /usr/local/bin/ttyd /opt/{org-build.sh,org-dep.sh,org-nginx.sh,org-ffmpeg.sh} && /opt/org-build.sh

COPY cors.conf /etc/nginx

EXPOSE 80 443

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
