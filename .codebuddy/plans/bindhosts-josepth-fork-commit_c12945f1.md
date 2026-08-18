---
name: bindhosts-josepth-fork-commit
overview: 将 josepth fork 的全部已完成改动提交到 git（不含 push），收尾本次定制工作。所有功能性配置（订阅源、包名、外链、版本号、memory 铁律）均已改完，唯一剩余动作是 git add + commit。
todos:
  - id: git-add
    content: 暂存 8 个修改文件与 .codebuddy 目录
    status: completed
  - id: git-commit
    content: 提交 josepth fork 配置并附中文说明
    status: completed
    dependencies:
      - git-add
  - id: report
    content: 报告提交结果并提醒尚未 push
    status: completed
    dependencies:
      - git-commit
---

## 用户需求

用户 fork 了 bindhosts 模块（仓库 shiqianwei0508/bindhosts），此前已完成所有功能性自定义改动并通过 git status 确认。当前用户执行 "Plan !"，意图是将这些已完成的改动收尾提交到本地 git 仓库（git add + commit），**不执行 push**。

## 产品概述

本次不是功能性开发，而是对已完成的 josepth fork 定制工作做一次本地提交收尾。所有功能配置（订阅源替换、发布包名区分、外链指向自有仓库、版本号、memory 铁律文档）均已落地，仅剩提交动作。

## 核心任务

- 将 8 个已修改文件与新建的 .codebuddy/ 目录一并加入暂存区
- 创建一条清晰的提交记录，说明本次 josepth fork 的全部定制点
- 提交后向用户报告结果，并明确提醒尚未 push（按铁律不主动 push）

## 技术栈

- 版本控制：Git（PowerShell 环境下使用 Push-Location/Set-Location 切换路径，禁止 cmd 的 cd /d）
- 仓库默认分支：master

## 实现方案

采用单条 `git add` + `git commit` 完成收尾。理由：所有改动属于同一逻辑主题（josepth fork 配置），合并为一次提交可保持历史清晰、便于回滚。`.codebuddy/` 目录包含 MEMORY.md 铁律与当日工作日志，建议一并提交以固化踩坑经验，避免后续会话重复犯错。

### 待提交文件清单（来自 git status）

- `.github/workflows/release.yml`（包名前缀、移除 dispatch job）
- `README.md` / `README_zh-CN.md`（外链改自有仓库）
- `module/bindhosts.sh`（canary/locales 链接改 master）
- `module/common/repo.json`（信息卡链接改 master）
- `module/module.prop`（updateJson、description 加 fork 说明、author 保留原作者）
- `module/sources.txt`（完全替换为 gitee 自有订阅源）
- `update.json`（zipUrl 带 -josepth 版本号、changelog 链接）
- `.codebuddy/`（新建，铁律与日志）

## 执行注意

- 严格遵守铁律：本次**只 commit，不 push**，需等待用户明确指令才 push
- 提交信息使用 `feat:` 前缀中文描述，涵盖订阅源、包名、外链三大变化
- 不改动任何已修改文件的内容，仅做提交动作