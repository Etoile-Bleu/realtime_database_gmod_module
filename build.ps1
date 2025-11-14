# build.ps1
# Script pour compiler le module GMOD avec CMake + Visual Studio 2022
# Génère gmsv_realtime_win64.dll et gmsv_realtime_win32.dll

# Chemin du projet
$ProjectRoot = "C:\dev\gmod_realtime_module"
$GMODLuaBinDir = "$ProjectRoot\garrysmod\lua\bin"

# Architectures à compiler
$Architectures = @(
    @{ Name = "x64"; Generator = "Visual Studio 17 2022"; Args = "-A x64" },
    @{ Name = "x86"; Generator = "Visual Studio 17 2022"; Args = "-A Win32" }
)

# Vérifie si le CMakeLists.txt existe
if (-Not (Test-Path "$ProjectRoot\CMakeLists.txt")) {
    Write-Error "CMakeLists.txt introuvable dans $ProjectRoot"
    exit 1
}

# Crée le dossier garrysmod/lua/bin s'il n'existe pas
if (-Not (Test-Path $GMODLuaBinDir)) {
    Write-Host "Création du dossier $GMODLuaBinDir..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $GMODLuaBinDir | Out-Null
}

# Compile pour chaque architecture
foreach ($Arch in $Architectures) {
    $ArchName = $Arch.Name
    $BuildDir = "$ProjectRoot\build_$ArchName"
    $ReleaseDir = "$BuildDir\Release"
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Compilation pour $ArchName (${ArchName}bit)..." -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    # Supprime l'ancien dossier build s'il existe
    if (Test-Path $BuildDir) {
        Write-Host "Suppression du dossier build existant..." -ForegroundColor Yellow
        Remove-Item $BuildDir -Recurse -Force
    }
    
    # Crée le dossier build
    New-Item -ItemType Directory -Path $BuildDir | Out-Null
    
    # Change de répertoire
    Push-Location $BuildDir
    
    # Génère les fichiers Visual Studio via CMake
    Write-Host "Génération des fichiers de build avec CMake..." -ForegroundColor Cyan
    $CMakeCmd = "cmake .. -G '$($Arch.Generator)' $($Arch.Args)"
    Write-Host "Commande: $CMakeCmd" -ForegroundColor Gray
    
    Invoke-Expression $CMakeCmd
    if ($LASTEXITCODE -ne 0) { 
        Write-Error "Erreur CMake pour $ArchName"
        Pop-Location
        exit $LASTEXITCODE 
    }
    
    # Compile le projet en Release
    Write-Host "Compilation en Release pour $ArchName..." -ForegroundColor Cyan
    cmake --build . --config Release
    $buildExitCode = $LASTEXITCODE
    Pop-Location
    
    if ($buildExitCode -ne 0) { 
        Write-Error "Erreur compilation pour $ArchName"
        exit $buildExitCode 
    }
    
    # Cherche la DLL générée
    $DLLPath = Get-ChildItem -Path $ReleaseDir -Name "gmsv_realtime*.dll" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $DLLPath) {
        Write-Error "DLL gmsv_realtime*.dll non trouvée dans $ReleaseDir"
        exit 1
    }
    
    $DLLFullPath = Join-Path $ReleaseDir $DLLPath
    Write-Host "DLL trouvee: $DLLFullPath" -ForegroundColor Green
    
    # Copie la DLL dans le dossier GMod
    Write-Host "Copie de la DLL vers $GMODLuaBinDir..." -ForegroundColor Cyan
    Copy-Item $DLLFullPath -Destination $GMODLuaBinDir -Force
    Write-Host "DLL copiee avec succes" -ForegroundColor Green
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Build complet termine !" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`nDLL generees dans: $GMODLuaBinDir" -ForegroundColor Green
$dlls = @(Get-ChildItem $GMODLuaBinDir -Name "gmsv_realtime*.dll" -ErrorAction SilentlyContinue)
foreach ($dll in $dlls) {
    Write-Host "  - $dll" -ForegroundColor Green
}

