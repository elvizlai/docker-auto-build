FROM centos:7

COPY ./dep.sh /opt/dep.sh

RUN chmod +x /opt/dep.sh && \
    /opt/dep.sh

COPY ./nginx.sh /opt/nginx.sh

RUN chmod +x /opt/nginx.sh && \
    /opt/nginx.sh

EXPOSE 80 443

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]