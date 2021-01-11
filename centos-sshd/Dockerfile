FROM centos:7

RUN yum update -y \
    && yum install -y openssh-server \
    && mkdir -p /root/.ssh \
    && touch /root/.ssh/authorized_keys \
    && sshd-keygen 

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
