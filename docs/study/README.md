# bindhosts 项目学习文档（josepth fork）

> 这是一套「项目解剖书」：把 bindhosts 这个 Android root 模块的**每一行关键代码**讲清楚，让没有 Android 底层经验的普通人也能看懂它是什么、做什么、怎么做。
> 所有专业名词都附带网络上可查的说明链接，代码片段均标注**文件路径 + 行号**，可直接对照源码。

---

## 一句话总览

**bindhosts 是一个 Android root 模块**：它装进已经"root"（拿到系统最高权限）的手机里，接管系统的 `/system/etc/hosts` 文件，让你能一键屏蔽广告/跟踪域名、添加自定义域名解析规则，并通过一个内置网页（WebUI）来管理这一切。

- 本仓库是 josepth 对原版 bindhosts 的 **fork（分叉副本）**，模块 id 故意保持 `bindhosts` 以覆盖原版安装。
- 代码分为两大块：**`module/`（运行在手机里的 shell 脚本）** 和 **`webui/`（手机里打开的管理网页）**。

---

## 文档导航

| # | 文件 | 内容 | 适合谁看 |
|---|------|------|----------|
| 00 | [README.md](./README.md) | 本文档索引 | 所有人 |
| 01 | [01-what-is-bindhosts.md](./01-what-is-bindhosts.md) | 项目是什么 + 必备背景知识（root/Magisk/KernelSU/hosts/overlayfs 等，带链接） | 零基础 |
| 02 | [02-project-structure.md](./02-project-structure.md) | 目录结构与每个文件的一句话职责 | 想看全貌 |
| 03 | [03-module-scripts.md](./03-module-scripts.md) | 模块侧 shell 脚本**逐文件、逐函数**解读 | 想懂底层原理 |
| 04 | [04-webui-frontend.md](./04-webui-frontend.md) | 前端三页（首页/规则/更多）+ 路由 + 前后端如何通信 | 前端/二次开发 |
| 05 | [05-build-and-release.md](./05-build-and-release.md) | 本地打包脚本 build-module.sh、update.json、版本号规则 | 想自己发版 |
| 06 | [06-usage.md](./06-usage.md) | 安装 / 更新 / 增删规则 / 模式选择 的日常使用流程 | 普通用户 |

---

## 阅读建议

1. 完全不懂 Android root 的：**先读 01**，把名词搞明白再往下。
2. 想快速知道"文件夹里都是啥"的：读 02。
3. 想二次开发 / 改 bug 的：按 03 → 04 → 05 顺序读，配合源码对照行号。
4. 只想用起来的：直接跳 06。

---

## 关键约定（铁律，贯穿全文）

文档里会反复提到几条「josepth fork 铁律」，先在这里记一下：

- **铁律 1**：模块 id 永远是 `bindhosts`，不改名——目的是**覆盖**用户手机上的原版 bindhosts 模块。
- **铁律 2**：发布包名一定是 `bindhosts-josepth-{版本号}.zip`，用 `-josepth` 区分分发，但模块 id 仍是 `bindhosts`。
- **铁律 3**：发版必须同步涨版本号（同时改 4 处文件），否则自动发版流程不会触发。
- 仓库默认分支是 **`master`**（不是 `main`），所有对外链接都指向 `master` 分支。

> 详细铁律见工作记忆 `MEMORY.md`，文档中仅在相关处点出。
