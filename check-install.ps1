# ============================================
# Script de Verificación de Instalación
# LuminaRiff - Stellar Ideatón 2024
# ============================================

Write-Host @"

╔════════════════════════════════════════╗
║  Verificación de Herramientas         ║
║  LuminaRiff Setup Checker              ║
╚════════════════════════════════════════╝

"@ -ForegroundColor Cyan

$allGood = $true

# ============================================
# Verificar Rust
# ============================================
Write-Host "`n[1/5] Verificando Rust..." -ForegroundColor Yellow
try {
    $rustVersion = rustc --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Rust instalado: $rustVersion" -ForegroundColor Green
    } else {
        throw "Error ejecutando rustc"
    }
} catch {
    Write-Host "  ❌ Rust NO instalado" -ForegroundColor Red
    Write-Host "     Instalar desde: https://rustup.rs/" -ForegroundColor Gray
    $allGood = $false
}

# ============================================
# Verificar Cargo
# ============================================
Write-Host "`n[2/5] Verificando Cargo..." -ForegroundColor Yellow
try {
    $cargoVersion = cargo --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Cargo instalado: $cargoVersion" -ForegroundColor Green
    } else {
        throw "Error ejecutando cargo"
    }
} catch {
    Write-Host "  ❌ Cargo NO instalado" -ForegroundColor Red
    Write-Host "     Instalar Rust (incluye Cargo): https://rustup.rs/" -ForegroundColor Gray
    $allGood = $false
}

# ============================================
# Verificar Stellar CLI
# ============================================
Write-Host "`n[3/5] Verificando Stellar CLI..." -ForegroundColor Yellow
try {
    $stellarVersion = stellar --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Stellar CLI instalado: $stellarVersion" -ForegroundColor Green
    } else {
        throw "Error ejecutando stellar"
    }
} catch {
    Write-Host "  ❌ Stellar CLI NO instalado" -ForegroundColor Red
    Write-Host "     Instalar con: winget install Stellar.StellarCLI" -ForegroundColor Gray
    Write-Host "     O desde: https://github.com/stellar/stellar-cli/releases" -ForegroundColor Gray
    $allGood = $false
}

# ============================================
# Verificar WASM Target
# ============================================
Write-Host "`n[4/5] Verificando WASM target..." -ForegroundColor Yellow
try {
    $targets = rustup target list --installed 2>&1
    if ($targets -match "wasm32-unknown-unknown") {
        Write-Host "  ✅ WASM target instalado" -ForegroundColor Green
    } else {
        Write-Host "  ❌ WASM target NO instalado" -ForegroundColor Red
        Write-Host "     Instalar con: rustup target add wasm32-unknown-unknown" -ForegroundColor Gray
        $allGood = $false
    }
} catch {
    Write-Host "  ❌ No se pudo verificar WASM target (Rustup no instalado)" -ForegroundColor Red
    $allGood = $false
}

# ============================================
# Verificar Git
# ============================================
Write-Host "`n[5/5] Verificando Git..." -ForegroundColor Yellow
try {
    $gitVersion = git --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Git instalado: $gitVersion" -ForegroundColor Green
    } else {
        throw "Error ejecutando git"
    }
} catch {
    Write-Host "  ⚠️  Git NO instalado (opcional pero recomendado)" -ForegroundColor Yellow
    Write-Host "     Instalar desde: https://git-scm.com/download/win" -ForegroundColor Gray
}

# ============================================
# Resumen
# ============================================
Write-Host "`n" + ("=" * 50) -ForegroundColor Cyan

if ($allGood) {
    Write-Host @"

╔════════════════════════════════════════╗
║     ✅ TODO LISTO PARA COMPILAR        ║
╚════════════════════════════════════════╝

Puedes proceder a compilar el contrato:

  cd luminariff-contract
  stellar contract build

O ejecutar el setup completo:

  .\setup.ps1

"@ -ForegroundColor Green
} else {
    Write-Host @"

╔════════════════════════════════════════╗
║   ❌ FALTAN HERRAMIENTAS               ║
╚════════════════════════════════════════╝

Por favor instala las herramientas faltantes.

Ver guía completa de instalación:
  INSTALL.md

O usa el instalador automático:

  # Instalar Rust
  winget install Rustlang.Rustup

  # Instalar Stellar CLI
  winget install Stellar.StellarCLI

  # Agregar WASM target
  rustup target add wasm32-unknown-unknown

Luego vuelve a ejecutar este script para verificar.

"@ -ForegroundColor Red
}

Write-Host ("=" * 50) -ForegroundColor Cyan
Write-Host ""