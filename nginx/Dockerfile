FROM centos:7

ARG VERSION=1.18.0

COPY dep.sh nginx.sh build.sh /opt/

RUN chmod +x /opt/{dep.sh,nginx.sh,build.sh} && /opt/build.sh

EXPOSE 80 443

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
