FROM centos:7

ARG VERSION=1.18.0

COPY ./dep.sh /opt/dep.sh
RUN chmod +x /opt/dep.sh && /opt/dep.sh

COPY ./nginx.sh /opt/nginx.sh
RUN chmod +x /opt/nginx.sh && /opt/nginx.sh ${VERSION}

EXPOSE 80 443

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
