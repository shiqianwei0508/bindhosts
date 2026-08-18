# 06 · 日常使用指南

本章面向**普通用户**：拿到 zip 后怎么装、怎么屏蔽广告、怎么增删规则、怎么更新。所有操作都在手机里完成。

> 前置：手机已 root（[Magisk](https://github.com/topjohnwu/Magisk) / [KernelSU](https://kernelsu.org/) / [APatch](https://github.com/APatch-org/APatch) 其一），且装了对应管理器 App（Magisk App / KernelSU App / APatch App 或 [MMRL](https://github.com/MMRLApp/MMRL)）。

---

## 6.1 安装

1. 把 `bindhosts-josepth-vX.zip`（由 [05 §5.2] 产出）传到手机。
2. 在管理器里**刷入模块** → 重启。
3. 安装时 `customize.sh` 会跑（见 [03 §3.4]）：
   - 6 秒内按**音量下**可跳过安装配套 App（BindHosts-app，铁律5 保持原样）；
   - 自动建立软链接、迁移旧规则到持久化目录。

> 模块 id 是 `bindhosts`，会**覆盖**你手机上原有的原版 bindhosts 模块（铁律1）。

---

## 6.2 打开管理网页（WebUI）

在管理器里找到 bindhosts 模块 → 点"打开 WebUI"：
- KernelSU/APatch：直接用内置 WebUI X 打开（[04 §4.13]）。
- Magisk：若装了 KSUWebUI / MMRL，自动跳转；否则用 MMRL 打开。

页面有三页（底部栏切换，见 [04 §4.4]）：
- **首页**：看状态 + 查域名
- **规则**：编辑 5 类文件 + 运行
- **更多**：设置 / 文档 / 支持 / 更新

---

## 6.3 屏蔽广告（默认已生效）

装好后，默认订阅源 `sources.txt`（[03 §3.12]，指向 josepth 的屏蔽源）已在后台拉取并应用。一般**无需操作**就能屏蔽大部分广告。

- 想强制刷新订阅源：规则页 → **强制更新** 按钮（= `--force-update`，[04 §4.6]）。
- 想定时自动更新：更多页 → 开 **每日更新** 开关（= `--enable-cron`，[03 §3.2.6]）。

---

## 6.4 增删规则（规则页）

规则页管理 5 类文件（[04 §4.6]）：

| 文件 | 用途 | 怎么改 |
|------|------|--------|
| `custom.txt` | 你的自定义 hosts 规则 | 直接编辑 / 导入文件 |
| `sources.txt` | 订阅源 URL 列表 | 编辑加自己的源 |
| `blacklist.txt` | 强制屏蔽某域名 | 编辑加域名 |
| `whitelist.txt` | 放行某域名（不被屏蔽） | 编辑 / 首页查询后"移除" |
| `sources_whitelist.txt` | 订阅源级白名单 | 编辑 |

操作步骤：
1. 选文件 → 在 CodeMirror 编辑器里改（增删 `0.0.0.0 域名` 之类）。
2. 点 **保存**。
3. 点 **运行**（= `--action`）让改动生效（[03 §3.2.3]）。

> 也可在**首页**查域名：搜到被屏蔽的条目 → 点删除 → 直接加白名单（= `--whitelist`，[04 §4.5] `handleRemove`）。

---

## 6.5 暂停 / 恢复

- 在管理器里**禁用模块**并重启 = 完全停用 hosts 管理。
- 想保留模块但临时关规则：规则页/更多页找"重置"（`--force-reset` 清所有自定义，回到默认订阅）。

---

## 6.6 模式选择（开发者）

- 首页状态卡片**连点 5 下**开开发者选项（[04 §4.5] `setupDevOtp`）。
- 开后点 **mode** 按钮，从 `modes.json`（[04 §4.12]）选挂载方式（overlay/bind/susfs 等，对应 [03 §3.5] 的 `operating_mode`）。
- 选完会写 `mode_override.sh`，**重启生效**。

> 普通用户**不用动**模式，默认自动探测最优（post-fs-data.sh 写 mode.sh）。

---

## 6.7 更新模块

- **OTA 自动**：管理器读 `update.json` 的 `zipUrl`（[05 §5.3]）检测新版本 → 提示升级。
  - ⚠️ 当前 `zipUrl` 指向 GitHub release（本 fork 无权限，实际 404）。需先把 `zipUrl` 改成可用托管才真正能用（见 [05 §5.5]）。
- **手动**：更多页 → **canary 更新** 按钮（= `--install-canary`，[04 §4.7]）。

---

## 6.8 卸载

管理器里卸载模块 → `uninstall.sh` 清理（[03 §3.11]）：
- 删除持久化目录 `/data/adb/bindhosts`（**用户规则一并丢失**）；
- 删除软链接；重置 hfr/znhr helper hosts；
- 若装了配套 App 一并卸载。

---

## 6.9 排错速查

| 现象 | 可能原因 | 处理 |
|------|----------|------|
| 广告没屏蔽 | 订阅源没拉到 / 模式不对 | 规则页"强制更新"；看首页 mode 对不对 |
| 网页打不开 | WebUI X 未装 / 管理器不支持 | 装 MMRL 或 KSUWebUI |
| 某正常网站被墙 | 域名被误屏蔽 | 首页查到 → 删除（加白名单） |
| 重启后失效 | 模式用了需热装/降级 | 用 hotinstall 或改 mode 为 2 |

---

> 全文档到此结束。回到 [README.md](./README.md) 可重新导航。
