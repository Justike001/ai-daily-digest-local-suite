@echo off
setlocal
set "REPO_DIR=%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%REPO_DIR%scripts\start-digest-viewer.ps1"
