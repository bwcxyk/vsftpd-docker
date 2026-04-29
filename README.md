# yaokun/vsftpd

这是一个基于 Debian 的轻量级 `vsftpd` Docker 镜像，使用 PAM `pam_pwdfile` 实现虚拟用户登录。

## 功能特性

- Debian slim 基础镜像
- `vsftpd` 虚拟用户登录
- 支持被动模式（NAT/公网环境推荐）
- 日志输出到容器标准输出（`docker logs` 可查看）

## 镜像拉取

```bash
docker pull yaokun/vsftpd
```

## 运行时环境变量

- `FTP_USER`
  - 默认值：`admin`
  - 说明：FTP 用户名。

- `FTP_PASS`
  - 默认值：未传入时启动自动生成 16 位随机密码
  - 说明：FTP 密码。

- `PASV_ADDRESS`（必填）
  - 说明：被动模式返回给客户端的公网 IP 或域名。
  - 注意：未设置时容器会启动失败并退出。

- `PASV_MIN_PORT`
  - 默认值：`21100`
  - 说明：被动模式端口范围起始值。

- `PASV_MAX_PORT`
  - 默认值：`21110`
  - 说明：被动模式端口范围结束值。

## 端口与数据卷

- 暴露端口：`20`、`21`、`21100-21110`
- 数据卷：
  - `/home/vsftpd`（用户目录）

## 快速启动

```bash
docker run -d \
  --name vsftpd \
  -p 20:20 \
  -p 21:21 \
  -p 21100-21110:21100-21110 \
  -v /data/ftp:/home/vsftpd \
  -e FTP_USER=myuser \
  -e FTP_PASS=mypass \
  -e PASV_ADDRESS=203.0.113.10 \
  -e PASV_MIN_PORT=21100 \
  -e PASV_MAX_PORT=21110 \
  --restart=always \
  yaokun/vsftpd
```

如果 `PASV_ADDRESS` 使用域名，请确保客户端侧 DNS 可正常解析。

## 说明

- 本镜像使用 `pam_pwdfile`，用户密码以哈希形式存储在 `/etc/vsftpd/virtual_users.txt`。
- 若未设置 `FTP_PASS`，容器启动时会自动生成随机密码。
- 被动模式可用需同时满足：
  - `PASV_ADDRESS` 配置正确
  - Docker 端口映射、宿主机防火墙、安全组放行与被动端口范围一致
