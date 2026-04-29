FROM debian:trixie-slim

ENV LANG=C.UTF-8 \
    TZ=Asia/Shanghai \
    FTP_USER=admin \
    PASV_MIN_PORT=21100 \
    PASV_MAX_PORT=21110

COPY vsftpd.conf /etc/vsftpd/
COPY vsftpd_virtual /etc/pam.d/
COPY --chmod=755 docker-entrypoint.sh /usr/local/bin/

RUN set -eux \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        vsftpd \
        libpam-pwdfile \
        openssl \
    && rm -rf /var/lib/apt/lists/*
	
RUN mkdir -p /home/vsftpd/ \
	&& chown -R ftp:ftp /home/vsftpd/

VOLUME /home/vsftpd
WORKDIR /home/vsftpd

EXPOSE 20 21 21100-21110

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
