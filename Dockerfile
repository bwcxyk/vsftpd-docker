FROM centos:7

ENV FTP_USER=**String** \
    FTP_PASS=**Random** \
    PASV_ADDRESS=**IPv4** \
    PASV_ADDR_RESOLVE=NO \
    PASV_ENABLE=YES \
    PASV_MIN_PORT=21100 \
    PASV_MAX_PORT=21110 \
    XFERLOG_STD_FORMAT=NO \
    LOG_STDOUT=**Boolean** \
    FILE_OPEN_MODE=0666 \
    LOCAL_UMASK=077 \
    REVERSE_LOOKUP_ENABLE=YES \
    TIME_ZONE=Asiz/Shanghai \
    TZ=Asiz/Shanghai \
    LANG=zh_CN.UTF-8

COPY vsftpd.conf /etc/vsftpd/
COPY vsftpd_virtual /etc/pam.d/
COPY docker-entrypoint.sh /

RUN set -x \
    && yum install -y vsftpd iproute db4-utils db4 kde-l10n-Chinese glibc \
	&& yum clean all \
    && localedef -c -f UTF-8 -i zh_CN zh_CN.utf8 \
	&& chmod +x /docker-entrypoint.sh
	
RUN mkdir -p /home/vsftpd/ \
	&& chown -R ftp:ftp /home/vsftpd/

VOLUME /home/vsftpd
VOLUME /var/log/vsftpd

EXPOSE 20 21

ENTRYPOINT ["sh","/docker-entrypoint.sh"]
