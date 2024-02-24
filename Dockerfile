FROM debian:bookworm

COPY ./filesystem /.
COPY ./filesystem-shared-ca-certificates /.

ARG _SSH_AUTHORIZED_KEYS
ENV SSH_AUTHORIZED_KEYS=${_SSH_AUTHORIZED_KEYS}

RUN bash /mnt/pre-install.sh
RUN bash /mnt/setup-ca.sh
RUN bash /mnt/install-ssh.sh

ENV container docker
ENV DEBIAN_FRONTEND noninteractive

# Enable systemd.
RUN apt-get update ; \
    apt-get install -y systemd systemd-sysv; \
    apt-get clean ; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ; \
    rm -rf /lib/systemd/system/multi-user.target.wants/* ; \
    rm -rf /etc/systemd/system/*.wants/* ; \
    rm -rf /lib/systemd/system/local-fs.target.wants/* ; \
    rm -rf /lib/systemd/system/sockets.target.wants/*udev* ; \
    rm -rf /lib/systemd/system/sockets.target.wants/*initctl* ; \
    rm -rf /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* ; \
    rm -rf /lib/systemd/system/systemd-update-utmp*

RUN systemctl enable ssh

VOLUME [ "/sys/fs/cgroup" ]
CMD ["/lib/systemd/systemd"]
