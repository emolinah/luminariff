# ============================================
# Script para Encontrar y Configurar Stellar CLI
# ============================================

Write-Host "`n=== Buscando Stellar CLI ===" -ForegroundColor Cyan

# Buscar stellar.exe en ubicaciones comunes
$searchPaths = @(
    "C:\Program Files\Stellar",
    "C:\Program Files (x86)\Stellar",
    "$env:LOCALAPPDATA\Programs\Stellar",
    "$env:LOCALAPPDATA\Microsoft\WinGet\Packages",
    "$env:USERPROFILE\.cargo\bin",
    "C:\ProgramData\chocolatey\bin"
)

$stellarPath = $null

Write-Host "`nBuscando en ubicaciones comunes..." -ForegroundColor Yellow

foreach ($path in $searchPaths) {
    if (Test-Path $path) {
        Write-Host "  Buscando en: $path" -ForegroundColor Gray
        $found = Get-ChildItem -Path $path -Filter stellar.exe -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            $stellarPath = $found.DirectoryName
            Write-Host "  ✅ Encontrado en: $stellarPath" -ForegroundColor Green
            break
        }
    }
}

# Si no se encontró, buscar en todo el sistema (puede tardar)
if (-not $stellarPath) {
    Write-Host "`nNo encontrado en ubicaciones comunes. Buscando en todo el sistema..." -ForegroundColor Yellow
    Write-Host "(Esto puede tardar varios minutos...)" -ForegroundColor Gray

    $found = Get-ChildItem -Path "C:\" -Filter stellar.exe -Recurse -ErrorAction SilentlyContinue -Depth 6 | Select-Object -First 1
    if ($found) {
        $stellarPath = $found.DirectoryName
        Write-Host "✅ Encontrado en: $stellarPath" -ForegroundColor Green
    }
}

if (-not $stellarPath) {
    Write-Host "`n❌ No se encontró stellar.exe en el sistema" -ForegroundColor Red
    Write-Host "`nPor favor, instala Stellar CLI primero:" -ForegroundColor Yellow
    Write-Host "  winget install Stellar.StellarCLI" -ForegroundColor White
    exit 1
}

# Verificar versión
Write-Host "`n=== Información de Stellar CLI ===" -ForegroundColor Cyan
$stellarExe = Join-Path $stellarPath "stellar.exe"
$version = & $stellarExe --version
Write-Host "Versión: $version" -ForegroundColor White
Write-Host "Ubicación: $stellarExe" -ForegroundColor White

# Verificar si ya está en el PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$inPath = $currentPath -split ";" | Where-Object { $_ -eq $stellarPath }

if ($inPath) {
    Write-Host "`n✅ Stellar CLI ya está en el PATH del usuario" -ForegroundColor Green
} else {
    Write-Host "`n⚠️  Stellar CLI NO está en el PATH" -ForegroundColor Yellow
    Write-Host "`n¿Deseas agregar Stellar CLI al PATH del usuario? (S/N)" -ForegroundColor Cyan
    $response = Read-Host

    if ($response -eq "S" -or $response -eq "s") {
        # Agregar al PATH del usuario
        $newPath = $currentPath + ";" + $stellarPath
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")

        Write-Host "`n✅ Stellar CLI agregado al PATH del usuario" -ForegroundColor Green
        Write-Host "`n⚠️  IMPORTANTE: Debes cerrar y reabrir PowerShell para que los cambios tengan efecto" -ForegroundColor Yellow

        # Actualizar PATH en la sesión actual
        $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")

        Write-Host "`nPATH actualizado en la sesión actual. Probando..." -ForegroundColor Cyan
        try {
            stellar --version
            Write-Host "✅ stellar funciona correctamente en esta sesión" -ForegroundColor Green
        } catch {
            Write-Host "⚠️  Necesitas cerrar y reabrir PowerShell para usar 'stellar' desde cualquier ubicación" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n=== Resumen ===" -ForegroundColor Cyan
Write-Host "Stellar CLI: $stellarExe" -ForegroundColor White
Write-Host "`nPara usar stellar desde cualquier ubicación:" -ForegroundColor Yellow
Write-Host "1. Cierra esta ventana de PowerShell" -ForegroundColor White
Write-Host "2. Abre una nueva ventana de PowerShell" -ForegroundColor White
Write-Host "3. Ejecuta: stellar --version" -ForegroundColor White
Write-Host ""