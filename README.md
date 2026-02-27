# AI Daily Digest Local Suite

一个完整的本地 AI 技术日报方案：

- 抓取 90+ 技术博客 RSS
- 使用 Kimi 自动评分、摘要、分类
- 每天 09:00 Windows 定时生成日报
- 本地阅读站将 Markdown 渲染成优雅阅读页面
- 一键启动（桌面 / 开始菜单）

![AI Daily Digest 概览](assets/overview.png)

## 项目结构

```text
ai-daily-digest/
├─ scripts/
│  ├─ digest.ts                       # 核心日报生成器
│  ├─ run-digest-daily.ps1            # 每日自动运行脚本
│  ├─ register-digest-task.ps1        # 注册 09:00 定时任务
│  ├─ start-digest-viewer.ps1         # 启动本地阅读站并打开浏览器
│  └─ register-viewer-logon-task.ps1  # (可选) 登录 Windows 时自动启动阅读站
├─ viewer/
│  ├─ server.ts                       # 本地 Web 服务
│  ├─ index.html                      # 阅读站页面（Markdown 解析渲染）
│  └─ styles.css                      # 阅读站样式
├─ 打开日报阅读站.cmd                 # 双击启动入口
└─ output/                            # 自动生成日报目录（运行后出现）
```

## 环境要求

- Windows + PowerShell
- [Bun](https://bun.sh)
- 有效 API Key（至少一个）
  - `KIMI_API_KEY`（主路径，默认模型 `kimi-k2.5`）
  - `OPENAI_API_KEY`（可选兜底）

## 快速开始

### 1) 设置环境变量（仅首次）

```powershell
[System.Environment]::SetEnvironmentVariable("KIMI_API_KEY", "你的key", "User")
```

设置后重开终端/Codex 会话生效。

### 2) 手动生成一份日报

```powershell
cd C:\Users\justike.liu\ai-daily-digest
bun scripts/digest.ts --hours 48 --top-n 15 --lang zh --output output/digest-$(Get-Date -Format yyyyMMdd).md
```

### 3) 启动阅读站

双击：

`打开日报阅读站.cmd`

或执行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/start-digest-viewer.ps1
```

打开地址：

`http://localhost:8787`

## 自动化（每天 09:00）

### 注册日报定时任务

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/register-digest-task.ps1
```

任务名：`AI-Daily-Digest-9AM`

行为：

- 每天 09:00 生成 `output/digest-YYYYMMDD.md`
- 运行日志写入 `output/digest-run.log`

### （可选）登录即启动阅读站

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/register-viewer-logon-task.ps1
```

任务名：`AI-Digest-Viewer-OnLogon`

## 阅读站说明

阅读站不是原始 Markdown 文本框，而是结构化排版页面，支持：

- 标题层级（H1~H6）
- 段落、列表、引用、分割线
- 表格渲染
- 代码块与行内代码
- 链接可点击跳转
- 自动加载最新日报

日报来源目录：

- 优先 `output/`
- 兼容仓库根目录历史文件（`digest-YYYYMMDD.md`）

## 核心参数

```bash
bun scripts/digest.ts [options]

--hours <n>      时间范围（默认 48）
--top-n <n>      文章数量（默认 15）
--lang <zh|en>   输出语言（默认 zh）
--output <path>  输出路径
```

环境变量：

- `KIMI_API_KEY`
- `OPENAI_API_KEY`（可选）
- `OPENAI_API_BASE`（可选）
- `OPENAI_MODEL`（可选）

## Kimi 适配说明

当前默认调用 Kimi（OpenAI 兼容格式）：

- Endpoint：`https://api.moonshot.cn/v1/chat/completions`
- Model：`kimi-k2.5`

已按模型要求处理参数兼容（例如 `temperature/top_p`）。

## 常见问题

### 1) 报错 `Missing API key`

确认当前会话里存在：

```powershell
$env:KIMI_API_KEY
```

如果为空，重开终端或重新设置用户环境变量。

### 2) 09:00 没有生成新日报

检查任务状态：

```powershell
Get-ScheduledTask -TaskName AI-Daily-Digest-9AM | Get-ScheduledTaskInfo
```

### 3) 阅读站打不开

确认服务是否在跑：

```powershell
Invoke-WebRequest http://localhost:8787/api/reports
```

若失败，重新双击 `打开日报阅读站.cmd`。

## 信息源

RSS 来源精选自 Hacker News 热门技术博客榜单（Karpathy 推荐列表），涵盖：

Simon Willison、Paul Graham、Dan Abramov、Gwern、Krebs on Security 等。

完整列表见 `scripts/digest.ts`。

## 安全提醒

请勿将 `KIMI_API_KEY`、`OPENAI_API_KEY` 提交到 Git。  
本仓库已忽略日报产物与输出目录（`digest-*.md`、`output/`）。
