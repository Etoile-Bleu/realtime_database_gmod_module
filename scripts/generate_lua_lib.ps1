# Generate lua_shared.lib from lua_shared.dll using Visual Studio Build Tools
# Same approach as build.ps1 - use Visual Studio 17 2022 generator

$ProjectRoot = "C:\dev\gmod_realtime_module"
$DefFile = "$ProjectRoot\include\lua\lua_shared.def"
$LibFile = "$ProjectRoot\include\lua\lua_shared.lib"
$LibFile86 = "$ProjectRoot\include\lua\lua_shared_x86.lib"

Write-Host "Generating import libraries from .def files..." -ForegroundColor Cyan

# Create temporary cmake project to invoke lib.exe
$TempDir = "$ProjectRoot\temp_libgen"
if (Test-Path $TempDir) {
    Remove-Item $TempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $TempDir | Out-Null

# Create CMakeLists.txt for lib generation
$CMakeContent = @"
cmake_minimum_required(VERSION 3.16)
project(generate_lua_lib)

# Find lib.exe via Visual Studio
find_program(LIB_EXE lib.exe REQUIRED)

# Generate x64
add_custom_target(generate_x64 ALL
    COMMAND `${LIB_EXE} /def:"$DefFile" /out:"$LibFile" /machine:x64
    COMMENT "Generating lua_shared.lib (x64)"
)

# Generate x86
add_custom_target(generate_x86 ALL
    COMMAND `${LIB_EXE} /def:"$DefFile" /out:"$LibFile86" /machine:x86
    COMMENT "Generating lua_shared_x86.lib (x86)"
)
"@

$CMakeContent | Out-File "$TempDir\CMakeLists.txt" -Encoding UTF8

# Run CMake to build the .lib files
Push-Location $TempDir

Write-Host "Running CMake to generate import libraries..." -ForegroundColor Yellow

# Configure x64
New-Item -ItemType Directory -Path "build_x64" -Force | Out-Null
Push-Location "build_x64"
& cmake .. -G "Visual Studio 17 2022" -A x64
if ($LASTEXITCODE -ne 0) {
    Write-Error "CMake configuration failed"
    Pop-Location
    Pop-Location
    exit 1
}
Pop-Location

# Configure and build x86
New-Item -ItemType Directory -Path "build_x86" -Force | Out-Null
Push-Location "build_x86"
& cmake .. -G "Visual Studio 17 2022" -A Win32
if ($LASTEXITCODE -ne 0) {
    Write-Error "CMake configuration failed"
    Pop-Location
    Pop-Location
    exit 1
}
Pop-Location

Pop-Location

# Check results
Write-Host "`nVerifying generated files..." -ForegroundColor Cyan
if ((Test-Path $LibFile) -and (Get-Item $LibFile).Length -gt 0) {
    $size = (Get-Item $LibFile).Length / 1KB
    Write-Host "✓ Generated $LibFile ($([math]::Round($size, 1)) KB)" -ForegroundColor Green
} else {
    Write-Error "$LibFile not generated or empty"
    exit 1
}

if ((Test-Path $LibFile86) -and (Get-Item $LibFile86).Length -gt 0) {
    $size = (Get-Item $LibFile86).Length / 1KB
    Write-Host "✓ Generated $LibFile86 ($([math]::Round($size, 1)) KB)" -ForegroundColor Green
} else {
    Write-Error "$LibFile86 not generated or empty"
    exit 1
}

# Cleanup
Remove-Item $TempDir -Recurse -Force

Write-Host "`n✓ All import libraries generated successfully!" -ForegroundColor Green

