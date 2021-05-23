FROM centos:7 as build

COPY build.sh /opt/
RUN chmod +x /opt/build.sh && sh /opt/build.sh

FROM centos:7

COPY --from=build /opt/ffmpeg/bin/ffmpeg /usr/bin/
COPY --from=build /opt/ffmpeg/bin/ffprobe /usr/bin/
