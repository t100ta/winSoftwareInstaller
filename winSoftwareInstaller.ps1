<#
  file:  fresh-win-dev-setup.ps1
  purpose:
    新しい Windows 開発マシンを一括セットアップ。
    - WSL2 & Ubuntu
    - Volta（＋Node.js LTS を Volta で管理）
    - 各種ツール／ユーティリティ／GUI パッケージマネージャ
    実行後は “🎉  All done” を表示。

  使い方:
    1. 管理者 PowerShell で実行
       (Shift+右クリック → “PowerShell として実行”)
    2. powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File .\winSoftwareInstaller.ps1

  メモ:
    - スクリプトは **UTF-8 (BOM 付き)** で保存。
    - PowerShell 7 なら追加の文字コード設定は不要。
    - プロキシ環境では `$env:HTTP_PROXY` / `$env:HTTPS_PROXY` を事前セット。
#>

# --- Admin check -------------------------------------------------------------
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent().IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) )
{ Write-Error "管理者で実行してください。" exit 1}


# --- (PowerShell 5.1 only) 文字化け対策 --------------------------------------
if ($PSVersionTable.PSVersion.Major -lt 7) { chcp 65001 | Out-Null }
$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::new()

# --- パッケージ ID 一覧 -------------------------------------------------------
$packages = @(
  # 0) WSL & Ubuntu
  "Microsoft.WSL",
  "Canonical.Ubuntu",

  # 1) コア開発環境
  "Microsoft.WindowsTerminal",
  "Microsoft.PowerShell",
  "Git.Git",
  "Microsoft.VisualStudioCode",
  # Node.js → Volta に置換
  "Volta.Volta",                           # :contentReference[oaicite:0]{index=0}
  "Docker.DockerDesktop",

  # 2) DB / クラウド CLI
  "PostgreSQL.pgAdmin",
  # "Amazon.AWSCLI",
  # "Microsoft.AzureCLI",
  # "Google.CloudSDK",

  # 3) デバッグ & テスト
  "Postman.Postman",
  "Insomnia.Insomnia",
  "Telerik.Fiddler.Classic",

  # 4) ブラウザ
  "Google.Chrome",
  "Mozilla.Firefox",

  # 5) コラボ
  #"SlackTechnologies.Slack",
  #"Microsoft.Teams",
  "Discord.Discord",

  # 6) ユーティリティ
  "DevToys -s msstore",
  "File-New-Project.EarTrumpet",
  "7zip.7zip",
  "voidtools.Everything",
  "Microsoft.PCManager",                   # :contentReference[oaicite:1]{index=1}

  # 7) 画面収録
  "OBSProject.OBSStudio",

  # 8) GUI パッケージマネージャ
  "MartiCliment.UniGetUI"
)

# --- winget install loop -----------------------------------------------------
foreach ($id in $packages) {
  Write-Host "▶  Installing $id ..."
  winget install --id $id -e --accept-package-agreements --accept-source-agreements `
    | Out-Null
  if ($LASTEXITCODE -ne 0) {
    Write-Warning "⚠  $id のインストールに失敗 (スキップしました)"
  }
}

# --- Volta で Node.js LTS を導入 --------------------------------------------
$voltaPath = "$env:USERPROFILE\AppData\Local\Volta\volta.exe"
if (Test-Path $voltaPath) {
  & $voltaPath install node@lts npm yarn
}

Write-Host "`n🎉  All done. 必要に応じて再起動してください。"
