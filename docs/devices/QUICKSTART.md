# 快速开始

## 🚀 一键编译

### 基础编译（增量，灵活）

```bash
cd /home/jack/openwrt

# Hiker - 首次
./docker-compile.sh --clean

# Hiker - 增量（快速）
./docker-compile.sh

# DIR-505 16M
./compile-dir505.sh --clean
./compile-dir505.sh
```

### 快速编译（预编译工具链）⭐

```bash
# Hiker (mipsel)
./docker-compile-hiker.sh --build-image  # 首次构建镜像（60分钟，一次性）
./docker-compile-hiker.sh                # 快速编译（5-10分钟）⚡

# DIR-505 16M (mips)
./docker-compile-dir505-16m.sh --build-image
./docker-compile-dir505-16m.sh
```

**就这么简单！** 每个设备一个脚本。

## ⚡ 编译速度

| 方案 | 首次 | 增量/快速 |
|------|------|----------|
| **基础编译** | 50分钟 | 5-15分钟 |
| **快速编译** | 60分钟（构建镜像） | 5-10分钟 ⚡ |

**注意**：
- 基础编译：不使用 `--clean` 可保留缓存加速
- 快速编译：首次构建镜像后，每次都很快

## 📦 使用自定义 Feed（GitHub Actions）

自定义 Feed 位于：`/home/jack/openwrt-devices-feed/`

### 上传 Feed

```bash
cd /home/jack/openwrt-devices-feed
git config user.name "Your Name"
git config user.email "your@email.com"
git add -A
git commit -m "Custom devices feed"
git remote add origin https://github.com/YOUR_USERNAME/openwrt-devices-feed.git
git push -u origin main
```

### 在 Actions 中使用

Fork [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)

**diy-part1.sh**:
```bash
echo 'src-git customdevices https://github.com/YOUR_USERNAME/openwrt-devices-feed.git' >> feeds.conf.default
```

**diy-part2.sh**:
```bash
bash feeds/customdevices/install-devices.sh
```

上传 `.config` 文件，触发编译。

## 📖 文档

- `README.md` - 项目总览
- `COMPILE_TIPS.md` - 编译优化技巧
- `DOCKER_STRATEGIES.md` - Docker 方案对比
- `MULTIPLATFORM_DOCKER.md` - 多架构说明
- `scripts/migration-guide.md` - 设备迁移指南

## 🔍 查看编译进度

```bash
tail -f build.log
ls -lh bin/targets/ramips/rt305x/
ls -lh bin/targets/ath79/generic/
```

## 🎯 脚本总览

| 脚本 | 用途 | 速度 |
|------|------|------|
| `docker-compile-hiker.sh` | Hiker 快速编译 | 5-10分钟 ⚡ |
| `docker-compile-dir505-16m.sh` | DIR-505 快速编译 | 5-10分钟 ⚡ |
| `docker-compile.sh` | Hiker 基础编译 | 5-15分钟 |
| `compile-dir505.sh` | DIR-505 基础编译 | 5-15分钟 |

**推荐**：使用快速编译脚本！
