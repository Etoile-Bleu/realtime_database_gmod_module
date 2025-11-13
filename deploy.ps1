# deploy.ps1
# Script de déploiement des modules realtime et hiredis vers le serveur GMod
# Copie TOUTES les DLL (hiredis x32/x64 + realtime x32/x64) dans les DEUX dossiers

# Chemins source
$ProjectRoot = "C:\dev\gmod_realtime_module"
$GMODLuaBinDir = "$ProjectRoot\garrysmod\lua\bin"
$HiredisX64 = "$ProjectRoot\include\hiredis\build_x64\Release\hiredis.dll"
$HiredisX86 = "$ProjectRoot\include\hiredis\build_x86\Release\hiredis.dll"
$RealtimeX64 = "$GMODLuaBinDir\gmsv_realtime_win64.dll"
$RealtimeX86 = "$GMODLuaBinDir\gmsv_realtime_win32.dll"

# Chemins destination serveur GMod
$ServerBinDir = "C:\dev\serveur_gmod\steamapps\common\GarrysModDS\garrysmod\bin"
$ServerLuaBinDir = "C:\dev\serveur_gmod\steamapps\common\GarrysModDS\garrysmod\lua\bin"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deploiement des modules realtime" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Verification des fichiers source
$filesToCheck = @(
    $HiredisX64,
    $HiredisX86,
    $RealtimeX64,
    $RealtimeX86
)

$allExist = $true
foreach ($file in $filesToCheck) {
    if (Test-Path $file) {
        Write-Host "[OK] $file" -ForegroundColor Green
    } else {
        Write-Host "[ERREUR] Fichier introuvable: $file" -ForegroundColor Red
        $allExist = $false
    }
}

if (-not $allExist) {
    Write-Host "`nVeuillez d'abord compiler le projet avec .\build.ps1" -ForegroundColor Yellow
    exit 1
}

# Verification des dossiers destination
$destDirs = @($ServerBinDir, $ServerLuaBinDir)
foreach ($dir in $destDirs) {
    if (-not (Test-Path $dir)) {
        Write-Host "Creation du dossier destination: $dir" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Copie de TOUTES les DLL dans les 2 dossiers" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Copie TOUTES les DLL dans $ServerBinDir
Write-Host "Copie dans: $ServerBinDir`n" -ForegroundColor Cyan
try {
    Write-Host "  - hiredis_win64.dll" -ForegroundColor Yellow
    Copy-Item $HiredisX64 -Destination "$ServerBinDir\hiredis_win64.dll" -Force
    
    Write-Host "  - hiredis_win32.dll" -ForegroundColor Yellow
    Copy-Item $HiredisX86 -Destination "$ServerBinDir\hiredis_win32.dll" -Force
    
    Write-Host "  - gmsv_realtime_win64.dll" -ForegroundColor Yellow
    Copy-Item $RealtimeX64 -Destination "$ServerBinDir\gmsv_realtime_win64.dll" -Force
    
    Write-Host "  - gmsv_realtime_win32.dll" -ForegroundColor Yellow
    Copy-Item $RealtimeX86 -Destination "$ServerBinDir\gmsv_realtime_win32.dll" -Force
    
    Write-Host "[OK] Copie complete`n" -ForegroundColor Green
}
catch {
    Write-Host "Erreur lors de la copie: $_" -ForegroundColor Red
    exit 1
}

# Copie TOUTES les DLL dans $ServerLuaBinDir
Write-Host "Copie dans: $ServerLuaBinDir`n" -ForegroundColor Cyan
try {
    Write-Host "  - hiredis_win64.dll" -ForegroundColor Yellow
    Copy-Item $HiredisX64 -Destination "$ServerLuaBinDir\hiredis_win64.dll" -Force
    
    Write-Host "  - hiredis_win32.dll" -ForegroundColor Yellow
    Copy-Item $HiredisX86 -Destination "$ServerLuaBinDir\hiredis_win32.dll" -Force
    
    Write-Host "  - gmsv_realtime_win64.dll" -ForegroundColor Yellow
    Copy-Item $RealtimeX64 -Destination "$ServerLuaBinDir\gmsv_realtime_win64.dll" -Force
    
    Write-Host "  - gmsv_realtime_win32.dll" -ForegroundColor Yellow
    Copy-Item $RealtimeX86 -Destination "$ServerLuaBinDir\gmsv_realtime_win32.dll" -Force
    
    Write-Host "[OK] Copie complete`n" -ForegroundColor Green
}
catch {
    Write-Host "Erreur lors de la copie: $_" -ForegroundColor Red
    exit 1
}

Write-Host "========================================" -ForegroundColor Green
Write-Host "Deploiement termine avec succes !" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

Write-Host "Fichiers deploys:" -ForegroundColor Green

Write-Host "`nDans $ServerBinDir :" -ForegroundColor Cyan
$binFiles = @(Get-ChildItem "$ServerBinDir\hiredis_win*.dll" -ErrorAction SilentlyContinue) + @(Get-ChildItem "$ServerBinDir\gmsv_realtime_win*.dll" -ErrorAction SilentlyContinue)
$binFiles | ForEach-Object {
    Write-Host "  + $($_.Name)" -ForegroundColor Green
}

Write-Host "`nDans $ServerLuaBinDir :" -ForegroundColor Cyan
$luaBinFiles = @(Get-ChildItem "$ServerLuaBinDir\hiredis_win*.dll" -ErrorAction SilentlyContinue) + @(Get-ChildItem "$ServerLuaBinDir\gmsv_realtime_win*.dll" -ErrorAction SilentlyContinue)
$luaBinFiles | ForEach-Object {
    Write-Host "  + $($_.Name)" -ForegroundColor Green
}

Write-Host "`n[INFO] Les 4 modules sont maintenant prets pour le serveur GMod !" -ForegroundColor Cyan
Write-Host "[INFO] Total: $($binFiles.Count + $luaBinFiles.Count) fichiers deploys`n" -ForegroundColor Cyan
