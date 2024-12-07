自行打包的 [frp](https://github.com/fatedier/frp)，包括 `frps` 和 `frpc`，供 Debian 或其他发行版上使用。

Self-packaged [frp](https://github.com/fatedier/frp) for use on Debian or other distro, include `frps` 和 `frpc`.


## Usage/用法

```sh
echo "deb [trusted=yes] https://github.com/wcbing/frp-debs/releases/latest/download ./" |
    sudo tee /etc/apt/sources.list.d/frp.list
sudo apt update
```

## 配置文件

### frps

frps 有 Systemd 服务，安装后默认启动并设置开机自启。

其配置文件在 `/etc/frp/frps.toml`，修改文件后使用重启服务。

### frpc

为保证安全并未设置 Systemd 服务，有需要请自行编写。

默认配置文件在 `/etc/frp/frpc.toml`。

---

更多内容请查看[官网](https://gofrp.org/zh-cn/)。
