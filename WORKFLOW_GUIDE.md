# GitHub Actions 工作流指南

本项目提供 3 个 GitHub Actions workflows，适用于不同场景。

## 📦 Workflows 列表

### 1. Build All Profiles (Auto) - `build-firmware.yml`

**用途**: 自动编译所有配置

**触发条件**:
- Push 到 `main` 分支（修改 `devices/**` 或 workflow 文件）
- Pull Request
- 手动触发（编译所有）

**编译内容**: 
- Hiker RT5350 所有 4 个配置（并行）

**OpenWrt 版本**: 
- 固定使用 `main` 分支（SNAPSHOT）

**使用场景**:
- 日常开发，自动验证所有配置
- CI/CD 自动化测试

---

### 2. Build Single Profile - `build-single.yml` ⭐

**用途**: 手动编译指定配置和 OpenWrt 版本

**触发条件**:
- 仅手动触发

**可配置参数**:
```
Device: hiker-rt5350
Profile: minimal | p910nd | wifi-client | full-wifi
OpenWrt Version: 
  - main (SNAPSHOT)
  - openwrt-23.05 (23.05 稳定版)
  - openwrt-24.10 (24.10 稳定版)
Create Release: true/false
```

**使用场景**:
- 快速编译单个配置
- 测试不同 OpenWrt 版本
- 节省编译时间（~15分钟 vs ~60分钟）

**操作方法**:
```
GitHub → Actions → Build Single Profile → Run workflow
  1. 选择设备: hiker-rt5350
  2. 选择配置: p910nd (推荐)
  3. 选择 OpenWrt 版本: main (最新) 或 openwrt-23.05 (稳定)
  4. 是否创建 Release: false (测试时) / true (正式发布)
  5. 点击 "Run workflow"
```

---

### 3. Create Release - `release.yml`

**用途**: 创建正式发布，编译所有配置

**触发条件**:
- Push tag (如 `v1.0.0`)
- 手动触发

**编译内容**: 
- 所有设备的所有配置
- 自动创建 GitHub Release

**OpenWrt 版本**: 
- 固定使用 `main` 分支（SNAPSHOT）

**使用场景**:
- 正式版本发布
- 里程碑版本

**操作方法**:
```bash
# 方法1: 推送 tag（推荐）
git tag v1.0.0
git push origin v1.0.0

# 方法2: 手动触发
GitHub → Actions → Create Release → Run workflow
  → 输入 tag: v1.0.0
```

---

## 🎯 典型使用场景

### 场景1: 日常开发测试

**需求**: 修改了 p910nd 配置，想快速验证

**方法**: 使用 `Build Single Profile`
```
1. 修改 devices/hiker-rt5350/profiles/p910nd/defconfig
2. git commit && git push
3. GitHub → Actions → Build Single Profile → Run workflow
   - Device: hiker-rt5350
   - Profile: p910nd
   - OpenWrt: main
   - Release: false
4. 等待 ~15 分钟
5. 下载 Artifacts 测试
```

### 场景2: 测试不同 OpenWrt 版本

**需求**: 验证固件在 OpenWrt 23.05 稳定版上的兼容性

**方法**: 使用 `Build Single Profile`
```
GitHub → Actions → Build Single Profile → Run workflow
  - Device: hiker-rt5350
  - Profile: p910nd
  - OpenWrt: openwrt-23.05  ← 选择稳定版
  - Release: false
```

### 场景3: 完整验证

**需求**: 验证所有配置都能正常编译

**方法**: Push 代码触发 `Build All Profiles`
```
git push  # 自动触发，编译全部 4 个配置
```

或手动触发:
```
GitHub → Actions → Build All Profiles (Auto) → Run workflow
```

### 场景4: 正式发布

**需求**: 发布 v1.0.0 版本

**方法**: 使用 `Create Release`
```bash
git tag v1.0.0
git push origin v1.0.0

# 自动编译所有配置并创建 Release
```

---

## 📊 编译时间对比

| Workflow | 配置数 | 并行 | 时间 | 成本 |
|----------|--------|------|------|------|
| Build All | 4 | ✅ | ~60 分钟 | 高 |
| Build Single | 1 | ❌ | ~15 分钟 | 低 |
| Release | 4 | ✅ | ~60 分钟 | 高 |

**建议**:
- 日常开发: 用 `Build Single` 节省时间
- 发布前: 用 `Build All` 完整验证
- 正式版: 用 `Release` 创建发布

---

## 🔧 OpenWrt 版本说明

### main (SNAPSHOT)
- **特点**: 最新代码，滚动更新
- **优点**: 最新功能和驱动
- **缺点**: 可能不稳定
- **推荐**: 开发测试

### openwrt-23.05
- **特点**: 稳定版分支
- **优点**: 稳定可靠
- **缺点**: 功能较旧
- **推荐**: 生产环境

### openwrt-24.10
- **特点**: 较新的稳定版（如果存在）
- **优点**: 新功能 + 稳定
- **推荐**: 平衡选择

---

## 📝 最佳实践

1. **开发阶段**:
   - 用 `Build Single` 快速迭代
   - 只编译正在修改的配置

2. **测试阶段**:
   - 用 `Build Single` 测试不同 OpenWrt 版本
   - 验证兼容性

3. **发布前**:
   - 用 `Build All` 完整验证所有配置
   - 确保没有编译错误

4. **正式发布**:
   - 用 `Create Release` 创建版本
   - 生成永久保存的固件文件

---

## 💡 提示

- Artifacts 保留 90 天，Release 永久保存
- 手动触发支持选择 OpenWrt 版本
- 单配置编译节省 75% 时间
- 推荐配置: hiker-rt5350 + p910nd + main

---

**更多信息**: 查看 [docs/github-actions.md](docs/github-actions.md)
