param(
  [int]$Hours = 48,
  [int]$TopN = 15,
  [ValidateSet('zh', 'en')]
  [string]$Lang = 'zh'
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$outputDir = Join-Path $repoRoot 'output'
$dateTag = Get-Date -Format 'yyyyMMdd'
$outputFile = Join-Path $outputDir ("digest-{0}.md" -f $dateTag)
$logFile = Join-Path $outputDir 'digest-run.log'

if (-not (Test-Path $outputDir)) {
  New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

Push-Location $repoRoot
try {
  $bunPath = (Get-Command bun -ErrorAction Stop).Source
  & $bunPath "scripts/digest.ts" --hours $Hours --top-n $TopN --lang $Lang --output $outputFile 2>&1 |
    Tee-Object -FilePath $logFile -Append
} finally {
  Pop-Location
}
