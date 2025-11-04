# AutoCF

查找 CloudfFlare 优先IP 并更新 gost


## 系统要求

- CentOS 7+
- Ubuntu 16.04+

## 安装

无需安装，可通过 curl/wget 配合管道直接运行

## 配置

- 中转端口默认为3389，请在 `config.json.example` 中自行修改。
- 默认配置：测试IPV4优选、带宽60兆、线程数20，可自行在 `autoCF.sh` 中修改

## 使用

> 安装 gost

安装 gost 为 systemd 服务
gost路径为: `/usr/local/bin/gost`
systemd 服务配置路径为: `/lib/systemd/system/gost.service`

```shell
bash <(wget -q -O - https://raw.githubusercontent.com/Ansen/autoCF/refs/heads/master/autoCF.sh) install
# Or
curl -s https://raw.githubusercontent.com/Ansen/autoCF/refs/heads/master/autoCF.sh) install
```

> 卸载 gost

```shell
bash <(wget -q -O - https://raw.githubusercontent.com/Ansen/autoCF/refs/heads/master/autoCF.sh) uninstall
# Or
bash <(curl -s https://raw.githubusercontent.com/Ansen/autoCF/refs/heads/master/autoCF.sh) uninstall
```

> 查找优选IP，更新 gost 配置，并重启 gost

```shell
bash <(wget -q -O - https://raw.githubusercontent.com/Ansen/autoCF/refs/heads/master/autoCF.sh) update
# Or
bash <(curl -s https://raw.githubusercontent.com/Ansen/autoCF/refs/heads/master/autoCF.sh) update
```

## 感谢

- [Cloudflare](https://www.cloudflare.com/)
- [gost](https://github.com/go-gost/gost/)
- [better-cloudflare-ip](https://github.com/badafans/better-cloudflare-ip)
- [GitHub Proxy](https://ghproxy.com/)
