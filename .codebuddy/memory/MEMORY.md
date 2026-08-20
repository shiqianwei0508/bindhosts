# 长效记忆 (MEMORY.md)

## bindhosts 自定义 fork 项目铁律

仓库：shiqianwei0508/bindhosts（本地 e:\Work\code\bindhosts），fork 自原版 bindhosts 模块。
默认分支：**master**（不是 main！远程 origin/HEAD 指向 master）。任何 raw.githubusercontent / nightly / 链接一律用 master 分支，否则 404。

### 铁律 1：模块 id 必须保持 `bindhosts`，不得改名
目标是在用户设备上**覆盖原版 bindhosts 模块**，所以 `module/module.prop` 的 `id=bindhosts` 永远不变。
改名 bindhostsjosepth 会变成并存模块、无法覆盖原包（已踩过坑，git checkout 还原过）。

### 铁律 2：发布包名规则 = `bindhosts-josepth-{版本号}.zip`
- 例：bindhosts-josepth-v2.1.4.zip
- 由 `.github/workflows/release.yml` 的 `ZIP_PREFIX`(bindhosts-josepth) + `VERSION`(取自 update.json 的 version) 自动拼。
- `update.json` 的 `zipUrl` 必须与此完全一致（带 -josepth + 版本号）。
- 模块 id 仍是 bindhosts，仅 zip 文件名区分。

### 铁律 3：发版必须同步版本号（否则 workflow 不发 release）
改版本时同步 4 处：
1. `module/module.prop` → `version`(如 v2.1.5) 且 `versionCode`(+1)
2. `update.json` → `version`、`versionCode`、以及 `zipUrl` 文件名里的版本号
3. （可选）`CHANGELOG.md` 加条目
workflow 判定 `version_changed` 基于 update.json 的 version/versionCode，不更新就不发 release。

### 铁律 4：所有对外链接指向用户仓库 shiqianwei0508/bindhosts（master 分支）
改过的位置清单：
- module/module.prop: updateJson
- module/bindhosts.sh: nightly.link canary + raw locales 下载
- update.json: zipUrl、changelog
- module/common/repo.json: readme/screenshots/support
- webui/page/more/more.js: github issue + locales_version
- README.md / README_zh-CN.md: 下载/issue/PR 主页链接
- .github/workflows/release.yml: 产出名、移除 dispatch 同步到 KernelSU-Modules-Repo/bindhosts 的 job（不能同步到原/官方仓库）

### 铁律 5：不要动 BindHosts-app 逻辑
bindhosts-app.sh / customize.sh 安装提示 / uninstall.sh 卸载 app / webui more.js 的 app UI 全部保持原样。
（曾尝试移除，因改动点多、风险高、且要覆盖原包行为一致，已撤销。）

### 铁律 6：不抢原作者署名
module.prop 的 `author` 保持原作者（xx, KOWX712），不要改成自己；description 可加 "(josepth fork)" 说明。

### 铁律 7：hosts 订阅地址
module/sources.txt 完全替换为自有订阅：https://gitlab.com/rainmor/Adhosts-block/-/raw/hosts-latest/hosts
（原作者的默认源已删除，不留。2026-08-20 由 gitee fish_cat 源改为 gitlab rainmor 源。）

### 已踩坑记录
- 误把全路径改成 bindhostsjosepth（想"加 josepth 区分"）→ 错，会破坏覆盖原包。已 git checkout 还原。
- update.json/repo.json/module.prop 链接写成 main 分支 → 错，仓库是 master。已改回。
- Windows 下 PowerShell 里直接 `bash` 会走到 WSL（报 WSL_E_WSL_OPTIONAL_COMPONENT_REQUIRED）。打包要这样跑：`& "C:\Program Files\Git\bin\bash.exe" build-module.sh`。脚本用 python3(zipfile) 打包，不依赖 zip 命令。
