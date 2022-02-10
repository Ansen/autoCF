# AutoCF 查找CloudfFlare 优先IP 并更新 gost

## 系统要求

- CentOS 7+
- Ubuntu 16.04+

## 安装

```shell
git clone https://github.com/Ansen/autoCF.git
```

## 使用

> 安装 gost

```shell
cd autoCF
/bin/bash autoCF.sh install
```

> 卸载 gost

```shell
cd autoCF
/bin/bash autoCF.sh uninstall
```

> 查找优选IP，更新 gost 配置，并重启 gost

```shell
cd autoCF
/bin/bash autoCF.sh update
```

## 感谢

- [Cloudflare](https://www.cloudflare.com/)
- [gost](https://github.com/ginuerzh/gost)
- [better-cloudflare-ip](https://github.com/badafans/better-cloudflare-ip)
- [gost.sh](https://github.com/eicky/gost.sh)
- [GitHub Proxy](https://ghproxy.com/)
