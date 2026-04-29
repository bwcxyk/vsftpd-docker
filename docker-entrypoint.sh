#!/bin/bash

# Require mandatory envs.
if [ -z "${FTP_USER:-}" ]; then
    echo "ERROR: FTP_USER is required." >&2
    exit 1
fi

# If no env var has been specified, generate a random password for FTP_USER.
if [ -z "${FTP_PASS:-}" ]; then
    FTP_PASS="$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c16)"
    echo "INFO: Generated FTP_PASS for user ${FTP_USER}: ${FTP_PASS}"
fi

# Create home dir and update vsftpd user db:
mkdir -p "/home/vsftpd/${FTP_USER}"
chown -R ftp:ftp /home/vsftpd/

# Ensure vsftpd secure chroot dir exists with safe permissions.
mkdir -p /var/run/vsftpd/empty
chown root:root /var/run/vsftpd /var/run/vsftpd/empty
chmod 755 /var/run/vsftpd
chmod 555 /var/run/vsftpd/empty

FTP_PASS_HASH="$(openssl passwd -6 "${FTP_PASS}")"
echo "${FTP_USER}:${FTP_PASS_HASH}" > /etc/vsftpd/virtual_users.txt
chmod 600 /etc/vsftpd/virtual_users.txt

# Set passive mode parameters:
if [ -z "${PASV_ADDRESS:-}" ]; then
    echo "ERROR: PASV_ADDRESS is required. Please set a valid public IP or domain." >&2
    exit 1
fi
if [ -z "${PASV_MIN_PORT:-}" ] || [ -z "${PASV_MAX_PORT:-}" ]; then
    echo "ERROR: PASV_MIN_PORT and PASV_MAX_PORT are required." >&2
    exit 1
fi
if ! [[ "${PASV_MIN_PORT}" =~ ^[0-9]+$ ]] || ! [[ "${PASV_MAX_PORT}" =~ ^[0-9]+$ ]]; then
    echo "ERROR: PASV_MIN_PORT and PASV_MAX_PORT must be integers." >&2
    exit 1
fi
if [ "${PASV_MIN_PORT}" -lt 1 ] || [ "${PASV_MIN_PORT}" -gt 65535 ] || [ "${PASV_MAX_PORT}" -lt 1 ] || [ "${PASV_MAX_PORT}" -gt 65535 ]; then
    echo "ERROR: PASV ports must be in range 1-65535." >&2
    exit 1
fi
if [ "${PASV_MIN_PORT}" -gt "${PASV_MAX_PORT}" ]; then
    echo "ERROR: PASV_MIN_PORT must be less than or equal to PASV_MAX_PORT." >&2
    exit 1
fi

# Update passive mode parameters in-place.
sed -i "s|###pasv_address###|${PASV_ADDRESS}|g" /etc/vsftpd/vsftpd.conf
sed -i "s|###pasv_min_port###|${PASV_MIN_PORT}|g" /etc/vsftpd/vsftpd.conf
sed -i "s|###pasv_max_port###|${PASV_MAX_PORT}|g" /etc/vsftpd/vsftpd.conf

# Ensure log file exists and stream it to container logs.
touch /var/log/vsftpd.log
chmod 644 /var/log/vsftpd.log
tail -n 0 -F /var/log/vsftpd.log &

# Run vsftpd:
exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
