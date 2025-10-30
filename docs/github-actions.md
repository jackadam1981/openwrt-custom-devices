# GitHub Actions 自动化编译指南

本项目使用 GitHub Actions 自动编译 OpenWrt 固件。

## 🚀 工作流程

### 1. 自动编译 (build-firmware.yml)

**触发条件：**
- 推送到 `main` 分支（修改 `devices/**` 或 workflow 文件）
- Pull Request
- 手动触发

**功能：**
- 自动编译所有设备的所有配置
- 并行构建，节省时间
- 上传编译产物到 Artifacts
- 可选创建 Release

**手动触发：**
```
GitHub 仓库 → Actions → Build OpenWrt Firmware → Run workflow
  - Device: hiker-rt5350 (或 all)
  - Profile: p910nd (或 all)
  - Release: true/false
```

### 2. 发布版本 (release.yml)

**触发条件：**
- 推送 tag（如 `v1.0.0`）
- 手动触发

**功能：**
- 编译所有设备的所有配置
- 自动创建 GitHub Release
- 上传所有固件到 Release
- 生成 SHA256 校验文件

**创建发布：**
```bash
# 方法1: 推送 tag
git tag v1.0.0
git push origin v1.0.0

# 方法2: 手动触发
GitHub → Actions → Create Release → Run workflow
  - Tag: v1.0.0
```

## 📦 编译产物

### Artifacts (build-firmware.yml)

每次编译会生成 Artifacts：
```
hiker-rt5350-SNAPSHOT-minimal/
├── hiker-rt5350-SNAPSHOT-minimal.bin
└── hiker-rt5350-SNAPSHOT-minimal.bin.sha256
```

**下载方式：**
```
GitHub → Actions → 选择 workflow run → Artifacts
```

保留时间：90 天（GitHub 默认）

### Releases (release.yml)

正式发布会创建 Release：
```
Release v1.0.0
├── hiker-rt5350-SNAPSHOT-minimal.bin
├── hiker-rt5350-SNAPSHOT-minimal.bin.sha256
├── hiker-rt5350-SNAPSHOT-p910nd.bin
├── hiker-rt5350-SNAPSHOT-p910nd.bin.sha256
└── ... (其他配置)
```

**下载方式：**
```
GitHub → Releases → 选择版本 → Assets
```

保留时间：永久

## ⚙️ 配置说明

### 添加新设备

编辑 `.github/workflows/build-firmware.yml`：

```yaml
strategy:
  matrix:
    include:
      # ... 现有设备
      
      # 新设备
      - device: new-device
        profile: default
        name: "New Device - Default"
```

### 自定义编译选项

修改 workflow 中的环境变量：

```yaml
env:
  OPENWRT_REPO: openwrt/openwrt    # OpenWrt 仓库
  OPENWRT_BRANCH: main             # 分支
  UPLOAD_FIRMWARE: true            # 上传 Artifacts
  UPLOAD_RELEASE: true             # 上传到 Release
```

### 优化编译时间

**并行构建：**
- 默认已启用 `strategy.fail-fast: false`
- 每个配置并行编译

**缓存 DL 目录：**

添加缓存步骤（可选）：
```yaml
- name: Cache
  uses: actions/cache@v3
  with:
    path: openwrt/dl
    key: dl-${{ hashFiles('openwrt/feeds.conf.default') }}
```

**使用 ccache：**

```yaml
- name: Setup ccache
  uses: hendrikmuhs/ccache-action@v1
  with:
    key: ${{ matrix.device }}-${{ matrix.profile }}
```

## 🐛 故障排查

### 编译失败

1. **查看日志：**
   ```
   GitHub → Actions → 失败的 run → 点击失败的 job
   ```

2. **本地复现：**
   ```bash
   # 使用相同的配置在本地编译
   cp devices/hiker-rt5350/profiles/p910nd/defconfig .config
   make defconfig
   make -j1 V=s  # 单线程详细输出
   ```

3. **常见问题：**
   - **磁盘空间不足**：添加 Free disk space 步骤
   - **依赖缺失**：更新 apt-get install 列表
   - **配置冲突**：检查 defconfig 文件

### Artifacts 未上传

检查条件：
```yaml
if: steps.compile.outputs.status == 'success' && env.UPLOAD_FIRMWARE == 'true'
```

确保：
- 编译成功
- `UPLOAD_FIRMWARE` 为 `true`

### Release 创建失败

检查：
- `GITHUB_TOKEN` 权限（默认自动提供）
- Tag 格式是否正确
- Release 文件是否存在

## 📊 构建矩阵

当前配置会并行构建：

| 设备 | 配置 | 预计时间 |
|------|------|----------|
| hiker-rt5350 | minimal | ~60 分钟 |
| hiker-rt5350 | p910nd | ~60 分钟 |
| hiker-rt5350 | wifi-client | ~60 分钟 |
| hiker-rt5350 | full-wifi | ~60 分钟 |

**总时间**：~60 分钟（并行）

## 🔐 安全考虑

### Secrets

如果需要私有配置，添加 Secrets：

```
GitHub → Settings → Secrets and variables → Actions → New repository secret
```

使用：
```yaml
env:
  MY_SECRET: ${{ secrets.MY_SECRET }}
```

### Permissions

默认权限足够。如需自定义：

```yaml
permissions:
  contents: write    # 创建 Release
  packages: write    # 上传到 GitHub Packages
```

## 📝 最佳实践

1. **小改动用 Artifacts**：
   - 日常开发
   - 测试新配置

2. **稳定版用 Release**：
   - 重大更新
   - 经过测试的版本

3. **使用 Draft Release**：
   - 先测试编译产物
   - 确认无误后发布

4. **定期清理 Artifacts**：
   - 减少存储成本
   - 保留重要的 Release

## 🔗 相关链接

- [GitHub Actions 文档](https://docs.github.com/actions)
- [OpenWrt 编译指南](https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem)
- [softprops/action-gh-release](https://github.com/softprops/action-gh-release)

---

**提示**: 首次编译会下载大量源码和依赖，约需 60-90 分钟。后续编译会更快（如使用缓存）。

