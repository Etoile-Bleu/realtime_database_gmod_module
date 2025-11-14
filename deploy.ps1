# deploy.ps1
# Script de déploiement des modules realtime vers le serveur GMod
# Copie uniquement les DLL realtime (hiredis est maintenant statiquement linké)

# Chemins source
$ProjectRoot = "C:\dev\gmod_realtime_module"
$GMODLuaBinDir = "$ProjectRoot\garrysmod\lua\bin"
$RealtimeX64 = "$GMODLuaBinDir\gmsv_realtime_win64.dll"
$RealtimeX86 = "$GMODLuaBinDir\gmsv_realtime_win32.dll"

# Chemins destination serveur GMod
$ServerLuaBinDir = "C:\dev\serveur_gmod\steamapps\common\GarrysModDS\garrysmod\lua\bin"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deploiement des modules realtime" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Verification des fichiers source
$filesToCheck = @(
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

# Verification du dossier destination
if (-not (Test-Path $ServerLuaBinDir)) {
    Write-Host "Creation du dossier destination: $ServerLuaBinDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $ServerLuaBinDir -Force | Out-Null
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Copie des DLL vers le serveur" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Copie les DLL dans le serveur
Write-Host "Destination: $ServerLuaBinDir`n" -ForegroundColor Cyan
try {
    Write-Host "  - gmsv_realtime_win64.dll" -ForegroundColor Yellow
    Copy-Item $RealtimeX64 -Destination "$ServerLuaBinDir\gmsv_realtime_win64.dll" -Force
    
    Write-Host "  - gmsv_realtime_win32.dll" -ForegroundColor Yellow
    Copy-Item $RealtimeX86 -Destination "$ServerLuaBinDir\gmsv_realtime_win32.dll" -Force
    
    Write-Host "`n[OK] Copie complete`n" -ForegroundColor Green
}
catch {
    Write-Host "Erreur lors de la copie: $_" -ForegroundColor Red
    exit 1
}

Write-Host "========================================" -ForegroundColor Green
Write-Host "Deploiement termine avec succes !" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

Write-Host "Fichiers deploys:" -ForegroundColor Green
$deployedFiles = Get-ChildItem "$ServerLuaBinDir\gmsv_realtime_win*.dll" -ErrorAction SilentlyContinue
$deployedFiles | ForEach-Object {
    Write-Host "  + $($_.Name)" -ForegroundColor Green
}

Write-Host "`n[INFO] Hiredis est maintenant statiquement linke dans les DLL realtime" -ForegroundColor Cyan
Write-Host "[INFO] Plus besoin de hiredis.dll separee !" -ForegroundColor Cyan
Write-Host "[INFO] Total: $($deployedFiles.Count) fichiers deploys`n" -ForegroundColor Cyan
