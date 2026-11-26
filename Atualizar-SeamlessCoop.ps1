
# ============================================================
# SEAMLESS CO-OP UPDATER
# Atualizador automatico do Elden Ring Seamless Co-op
# GitHub: yuiamoroll/EldenRingSeamlessCoopRelease
# ============================================================

$ErrorActionPreference = "Stop"

# CONFIGURACOES
$Repo = "yuiamoroll/EldenRingSeamlessCoopRelease"
$ApiUrl = "https://api.github.com/repos/$Repo/releases/latest"

# ============================================================
# INICIO
# ============================================================

Clear-Host

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "          SEAMLESS CO-OP UPDATER" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# 1. DETECTAR ELDEN RING
# ============================================================

$GameDir = (Get-Location).Path
$GameExe = Join-Path $GameDir "eldenring.exe"

if (!(Test-Path -LiteralPath $GameExe -PathType Leaf)) {

    Write-Host "[ERRO] eldenring.exe nao encontrado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Diretorio atual: $GameDir"
    Write-Host ""
    Write-Host "Execute o script na pasta que contem eldenring.exe."

    Read-Host "Pressione ENTER para sair"
    exit 1
}

Write-Host "[OK] Elden Ring detectado!" -ForegroundColor Green
Write-Host "Executavel: $GameExe"
Write-Host "Diretorio: $GameDir"
Write-Host ""

# ============================================================
# 2. CONSULTAR GITHUB
# ============================================================

try {

    Write-Host "[1/5] Consultando GitHub..." -ForegroundColor Yellow

    if ($PSVersionTable.PSVersion.Major -lt 6) {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    }

    $Headers = @{
        "User-Agent" = "SeamlessCoopUpdater-PowerShell"
        "Accept" = "application/vnd.github+json"
    }

    $Release = Invoke-RestMethod `
        -Uri $ApiUrl `
        -Headers $Headers `
        -Method Get

    $Version = $Release.tag_name

    if ([string]::IsNullOrWhiteSpace($Version)) {
        throw "O GitHub nao informou a versao."
    }

    Write-Host "[OK] Versao encontrada: $Version" -ForegroundColor Green

}
catch {

    Write-Host "[ERRO] Nao foi possivel consultar o GitHub." -ForegroundColor Red
    Write-Host $_.Exception.Message

    Read-Host "Pressione ENTER para sair"
    exit 1
}

# ============================================================
# 3. LOCALIZAR ZIP
# ============================================================

try {

    Write-Host ""
    Write-Host "[2/5] Localizando arquivo ZIP..." -ForegroundColor Yellow

    $ZipAssets = @(
        $Release.assets | Where-Object {
            $_.name -match '\.zip$'
        }
    )

    if ($ZipAssets.Count -eq 0) {
        throw "Nenhum arquivo ZIP encontrado na Release."
    }

    foreach ($AssetItem in $ZipAssets) {
        Write-Host "Encontrado: $($AssetItem.name)"
    }

    # Selecionar primeiro ZIP
    $Asset = $ZipAssets[0]

    Write-Host ""
    Write-Host "[OK] Arquivo selecionado: $($Asset.name)" -ForegroundColor Green

}
catch {

    Write-Host "[ERRO] Falha ao localizar o ZIP." -ForegroundColor Red
    Write-Host $_.Exception.Message

    Read-Host "Pressione ENTER para sair"
    exit 1
}

# ============================================================
# 4. PREPARAR DIRETORIOS
# ============================================================

$WorkDir = Join-Path $env:TEMP "SeamlessCoopUpdater"
$VersionDir = Join-Path $WorkDir $Version
$ZipPath = Join-Path $VersionDir $Asset.name
$ExtractDir = Join-Path $VersionDir "Extraido"

New-Item -ItemType Directory -Path $VersionDir -Force | Out-Null

# ============================================================
# 5. DOWNLOAD
# ============================================================

try {

    Write-Host ""
    Write-Host "[3/5] Baixando arquivos..." -ForegroundColor Yellow

    Invoke-WebRequest `
        -Uri $Asset.browser_download_url `
        -OutFile $ZipPath `
        -Headers $Headers `
        -UseBasicParsing

    if (!(Test-Path -LiteralPath $ZipPath -PathType Leaf)) {
        throw "Arquivo ZIP nao encontrado apos download."
    }

    $FileInfo = Get-Item $ZipPath

    if ($FileInfo.Length -lt 100KB) {
        throw "Arquivo ZIP parece estar incompleto."
    }

    Write-Host "[OK] Download concluido!" -ForegroundColor Green

    Write-Host "Arquivo: $($Asset.name)"
    Write-Host "Tamanho: $([math]::Round($FileInfo.Length / 1MB, 2)) MB"

}
catch {

    Write-Host "[ERRO] Falha no download." -ForegroundColor Red
    Write-Host $_.Exception.Message

    Read-Host "Pressione ENTER para sair"
    exit 1
}

# ============================================================
# 6. EXTRAIR ARQUIVOS
# ============================================================

try {

    Write-Host ""
    Write-Host "[4/5] Extraindo arquivos..." -ForegroundColor Yellow

    if (Test-Path -LiteralPath $ExtractDir) {
        Remove-Item -LiteralPath $ExtractDir -Recurse -Force
    }

    New-Item -ItemType Directory -Path $ExtractDir -Force | Out-Null

    Expand-Archive `
        -LiteralPath $ZipPath `
        -DestinationPath $ExtractDir `
        -Force

    # Procurar launcher
    $Launcher = Get-ChildItem `
        -Path $ExtractDir `
        -Filter "ersc_launcher.exe" `
        -File `
        -Recurse |
        Select-Object -First 1

    # Procurar pasta SeamlessCoop
    $ModFolder = Get-ChildItem `
        -Path $ExtractDir `
        -Directory `
        -Recurse |
        Where-Object {
            $_.Name -eq "SeamlessCoop"
        } |
        Select-Object -First 1

    if (!$Launcher -or !$ModFolder) {
        throw "Estrutura do ZIP nao corresponde ao mod esperado."
    }

    $PayloadDir = $Launcher.Directory.FullName

    $PayloadMod = Join-Path $PayloadDir "SeamlessCoop"

    if (!(Test-Path -LiteralPath $PayloadMod -PathType Container)) {
        throw "Pasta SeamlessCoop nao encontrada junto ao launcher."
    }

    Write-Host "[OK] Extracao concluida!" -ForegroundColor Green

}
catch {

    Write-Host "[ERRO] Falha na extracao ou validacao." -ForegroundColor Red
    Write-Host $_.Exception.Message

    Read-Host "Pressione ENTER para sair"
    exit 1
}

# ============================================================
# 7. MOSTRAR ARQUIVOS
# ============================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "             ARQUIVOS EXTRAIDOS" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

Get-ChildItem -LiteralPath $PayloadDir -Force | ForEach-Object {
    Write-Host " - $($_.Name)"
}

Write-Host ""
Write-Host "Versao: $Version" -ForegroundColor Green
Write-Host "ZIP: $ZipPath"
Write-Host "Extracao: $ExtractDir"

# ============================================================
# 8. CONFIRMAR INSTALACAO
# ============================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Deseja instalar esta versao no Elden Ring?"
Write-Host ""
Write-Host "S = Instalar"
Write-Host "N = Apenas testar download e extracao"
Write-Host "============================================" -ForegroundColor Cyan

$Answer = Read-Host "Sua escolha"

if ($Answer -notmatch '^(S|s|SIM|sim)$') {

    Write-Host ""
    Write-Host "[OK] Teste concluido!" -ForegroundColor Green
    Write-Host "Nenhum arquivo do jogo foi alterado."
    Write-Host ""
    Write-Host "Arquivos extraidos em:"
    Write-Host $ExtractDir

    Read-Host "Pressione ENTER para sair"
    exit 0
}

# ============================================================
# 9. BACKUP E INSTALACAO
# ============================================================

$BackupDir = Join-Path `
    $env:LOCALAPPDATA `
    "SeamlessCoopUpdater\Backups\$((Get-Date).ToString('yyyyMMdd-HHmmss'))"

try {

    Write-Host ""
    Write-Host "[5/5] Instalando Seamless Co-op..." -ForegroundColor Yellow

    # Criar backup
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null

    $OldLauncher = Join-Path $GameDir "ersc_launcher.exe"
    $OldModFolder = Join-Path $GameDir "SeamlessCoop"

    # Backup launcher
    if (Test-Path -LiteralPath $OldLauncher) {

        Copy-Item `
            -LiteralPath $OldLauncher `
            -Destination $BackupDir `
            -Force
    }

    # Backup pasta do mod
    if (Test-Path -LiteralPath $OldModFolder) {

        Copy-Item `
            -LiteralPath $OldModFolder `
            -Destination $BackupDir `
            -Recurse `
            -Force
    }

    # Backup configuracao
    $SettingsFile = Join-Path $OldModFolder "ersc_settings.ini"
    $SettingsBackup = $null

    if (Test-Path -LiteralPath $SettingsFile) {

        $SettingsBackup = Join-Path $BackupDir "ersc_settings.ini"

        Copy-Item `
            -LiteralPath $SettingsFile `
            -Destination $SettingsBackup `
            -Force
    }

    # Remover versao antiga
    if (Test-Path -LiteralPath $OldModFolder) {

        Remove-Item `
            -LiteralPath $OldModFolder `
            -Recurse `
            -Force
    }

    # Copiar nova versao
    Copy-Item `
        -Path (Join-Path $PayloadDir "*") `
        -Destination $GameDir `
        -Recurse `
        -Force

    # Restaurar configuracao
    if ($SettingsBackup -and (Test-Path -LiteralPath $SettingsBackup)) {

        $NewSettings = Join-Path $GameDir "SeamlessCoop\ersc_settings.ini"

        Copy-Item `
            -LiteralPath $SettingsBackup `
            -Destination $NewSettings `
            -Force
    }

    # Validar instalacao
    if (!(Test-Path -LiteralPath $OldLauncher)) {
        throw "Launcher nao encontrado apos instalacao."
    }

    if (!(Test-Path -LiteralPath (Join-Path $OldModFolder "ersc.dll"))) {
        throw "ersc.dll nao encontrado apos instalacao."
    }

    # Limpar arquivos temporarios apos instalacao
Write-Host ""
Write-Host "Limpando arquivos temporarios..." -ForegroundColor Yellow

if (Test-Path -LiteralPath $VersionDir) {
    Remove-Item -LiteralPath $VersionDir -Recurse -Force
}

Write-Host "[OK] Arquivos temporarios removidos!" -ForegroundColor Green

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "         ATUALIZACAO CONCLUIDA!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green

    Write-Host ""
    Write-Host "Versao instalada: $Version"
    Write-Host "Backup: $BackupDir"

}
catch {

    Write-Host ""
    Write-Host "[ERRO] Falha durante a instalacao!" -ForegroundColor Red
    Write-Host $_.Exception.Message

    Write-Host ""
    Write-Host "Backup disponivel em:"
    Write-Host $BackupDir

    Write-Host "Verifique os arquivos antes de iniciar o jogo."
}

Write-Host ""
Read-Host "Pressione ENTER para finalizar"
