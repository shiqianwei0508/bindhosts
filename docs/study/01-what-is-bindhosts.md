# 01 · bindhosts 是什么？

本章目标：让你在**完全不懂 Android 底层**的情况下，也能看懂后面所有文档。每个专业名词后面都给了「点开就能查」的链接。

---

## 1.1 用一句话讲人话

普通手机上，App 想访问一个网站（比如 `ads.example.com`），系统会先去问一个叫 **hosts** 的小本本："这个域名对应哪个 IP？"

bindhosts 干的事就是：**接管这个小本本，往里面塞一堆"广告域名 → 0.0.0.0（无效地址）"的映射**，于是广告请求全部失败、广告就不见了；同时你也随时能往里加自己的自定义规则。

它之所以能做到，是因为它运行在 **已经 root（拿到手机最高权限）的手机** 上，能改写系统分区里那个平时改不了的小本本。

---

## 1.2 必备背景知识（名词 → 链接）

下面每个名词都给出官方/权威说明，按需点击。

### 🔧 root（超级用户权限）
手机出厂时把系统最高权限锁住了，像电脑的 Administrator 被禁用。**root** 就是"解锁最高权限"，拿到后就能改系统任何文件。
- 通俗解释（中文）：<https://zh.wikipedia.org/wiki/Root_(Android)>（Android 系统下的 root）
- 英文总览：<https://en.wikipedia.org/wiki/Rooting_(Android)>

### 📦 Magisk（最流行的 root 方案之一）
一套"不修改系统分区、以挂载方式注入修改"的 root 框架。bindhosts 最初就是 Magisk 模块。
- 官网/文档：<https://github.com/topjohnwu/Magisk>
- 模块机制说明：<https://topjohnwu.github.io/Magisk/guides.html>

### 🐧 KernelSU（另一种 root 方案，运行在内核里）
相比 Magisk 在用户态，KernelSU 把 root 管理能力做进了 Linux 内核，性能更好、更隐蔽。
- 官网文档：<https://kernelsu.org/>
- GitHub：<https://github.com/tiann/KernelSU>

### 🧩 LSPosed / Xposed（另一种框架）
通过"钩子（hook）"修改 App 运行时的框架，bindhosts 也兼容它的模块机制。
- 项目地址：<https://github.com/LSPosed/LSPosed>
- Xposed 概念：<https://en.wikipedia.org/wiki/Xposed_Framework>

### 📄 hosts 文件
一个把"域名"映射到"IP 地址"的纯文本表，格式 `IP 域名`。系统解析域名时优先查它。
- Wikipedia（含格式示例）：<https://en.wikipedia.org/wiki/Hosts_(file)>
- 中文解释：<https://zh.wikipedia.org/wiki/Hosts>

### 🗂️ overlayfs（叠加文件系统）
Linux 的一种"把两层目录叠在一起看"的文件系统：上层覆盖下层，但下层原文件不动。Magisk/KernelSU 用它来"假装"改了系统分区，其实只是盖了一层。
- 内核文档（英文）：<https://www.kernel.org/doc/Documentation/filesystems/overlayfs.txt>
- 中文科普：<https://zh.wikipedia.org/wiki/OverlayFS>

### 🔗 符号链接（symlink / 软链接）
一个"快捷方式"文件，指向另一个真实文件/目录。bindhosts 用它在 `/system/etc/hosts` 和系统分区之间建立映射。
- Wikipedia：<https://en.wikipedia.org/wiki/Symbolic_link>
- 中文：<https://zh.wikipedia.org/wiki/%E7%AC%A6%E5%8F%B7%E9%93%BE%E6%8E%A5>

### 🖥️ WebUI X（模块内置网页界面框架）
KernelSU/MMRL 提供的机制，让模块能直接内置一个网页，用户在管理器 App 里点一下就能打开管理界面。
- WebUI X 说明：<https://github.com/MMRLApp/WebUI-X>
- kernelsu-alt（前端调用后端 shell 的库）：<https://github.com/rifsxd/kernelsu-alt>

### ⚡ Vite（前端构建工具）
把写好的网页源码打包成浏览器能跑的文件，速度极快、带热更新。bindhosts 的前端用它构建。
- 官网：<https://vitejs.dev/>
- 中文文档：<https://cn.vitejs.dev/>

### ✍️ CodeMirror（网页代码编辑器）
一个嵌在网页里的"代码编辑框"组件，bindhosts 用来让用户编辑 hosts 规则文件。
- 官网：<https://codemirror.net/>

### 🎨 Material Web（MDC Web 组件）
Google Material Design 的网页 UI 组件库（按钮、开关、对话框等），bindhosts 前端用它做界面。
- 官网：<https://github.com/material-components/material-web>

---

## 1.3 这个项目具体在做什么（功能清单）

| 功能 | 说明 | 对应代码 |
|------|------|----------|
| 接管系统 hosts | 把 `/system/etc/hosts` 换成自己管理的版本 | `module/bindhosts.sh` 的 `main_commit`/`action` |
| 屏蔽广告/跟踪 | 内置订阅源（默认指向 josepth 自己的 hosts 源）自动拉取屏蔽列表 | `module/sources.txt` + `force_update` |
| 自定义规则 | 用户可在网页里增删自己的 hosts 条目 | `webui/page/hosts/hosts.js` |
| 黑白名单 | 把某个域名"放过"（白名单）或"强制屏蔽"（黑名单） | `bindhosts.sh` 的 `--whitelist`/`--blacklist` |
| 暂停/恢复 | 一键停用或重新启用全部 hosts 管理 | `bindhosts.sh` 的 `pause`/`resume` |
| 自动更新 | 每天定时重新拉取订阅源 | `module/customize.sh` 的 `crontab` |
| 网页管理 | 手机里打开一个网页就能操作以上所有功能 | `webui/` 整个目录 |
| 模块自更新 | 检查新版本并下载安装 | `update.json` + `--nightly` |

---

## 1.4 它"不做"什么（边界）

- ❌ 它不是 VPN、不是代理，不改网络流量走向，只改域名→IP 的解析结果。
- ❌ 它不能在没有 root 的普通手机上运行。
- ❌ 它不拦截 HTTPS 内容本身，只决定"这个域名解析到哪"。

---

## 1.5 文件位置速记

```
bindhosts/                  ← 仓库根目录
├── module/                 ← 装在手机里的"大脑"（shell 脚本）
│   ├── bindhosts.sh        ← 核心逻辑（430 行）
│   ├── module.prop         ← 模块身份证
│   └── ...                 ← 各生命周期脚本
├── webui/                  ← 手机里打开的"管理网页"
│   ├── page/home/          ← 首页（状态+查询）
│   ├── page/hosts/         ← 规则编辑页
│   └── page/more/          ← 关于/设置页
├── update.json             ← 版本与更新信息
└── build-module.sh         ← 本地打包脚本（无 release 权限时的替代方案）
```

> 下一章 [02-project-structure.md](./02-project-structure.md) 会逐个文件讲职责。
