# Install on Another Computer

这份文档用于在另一台电脑上完成两件事：

1. 克隆 `ai-daily-digest` 仓库
2. 给该电脑的 Codex CLI 安装本仓库对应的 `ai-daily-digest` skill（使用仓库里的 `SKILL.md`）

## Prerequisites

- Git
- Codex CLI（已初始化，存在 `~/.codex` 或设置了 `CODEX_HOME`）
- Windows PowerShell

## 1) Clone Repository

```powershell
cd $HOME
git clone https://github.com/vigorX777/ai-daily-digest.git
cd ai-daily-digest
```

## 2) Install Skill to Codex (Recommended: Link Mode)

`Link` 模式会把 Codex 的 skill 目录指向这个 git 仓库目录。  
优点：后续你 `git pull` 后，Codex 直接使用最新 `SKILL.md` 和脚本，无需重复安装。

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-codex-skill.ps1 -Mode Link -Force
```

安装目标目录默认是：

- `$env:CODEX_HOME\skills\ai-daily-digest`（如果设置了 `CODEX_HOME`）
- 否则：`$HOME\.codex\skills\ai-daily-digest`

## 3) Alternative: Copy Mode

如果你的环境不允许创建链接，使用复制模式：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-codex-skill.ps1 -Mode Copy -Force
```

## 4) Verify Install

```powershell
Test-Path "$HOME\.codex\skills\ai-daily-digest\SKILL.md"
```

如果你设置了 `CODEX_HOME`，把上面的路径替换为：

```powershell
Test-Path "$env:CODEX_HOME\skills\ai-daily-digest\SKILL.md"
```

## 5) Restart Codex

安装完成后，重启 Codex CLI 让新 skill 生效。

## Update Workflow

在另一台电脑后续更新这套 skill：

```powershell
cd $HOME\ai-daily-digest
git pull
```

- 如果你用的是 `Link` 模式：到这里就完成了，Codex 自动使用最新内容。
- 如果你用的是 `Copy` 模式：再执行一次安装命令覆盖到 Codex 目录。

## Optional: Register Daily 09:00 Task

克隆后可直接注册日报定时任务，不需要改本机用户名路径：

```powershell
cd $HOME\ai-daily-digest
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\register-digest-task.ps1
```

自定义任务名和时间（24 小时制 `HH:mm`）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\register-digest-task.ps1 -TaskName "AI-Digest-Work" -DailyAt "08:30"
```
