# 🛠️ Guía de Instalación - LuminaRiff

Esta guía te ayudará a instalar todas las herramientas necesarias para compilar y desplegar el smart contract de LuminaRiff en Windows 10/11.

---

## ✅ Checklist de Requisitos

Antes de comenzar, necesitas:

- [ ] Windows 10/11
- [ ] PowerShell 5.1 o superior
- [ ] Conexión a Internet
- [ ] Permisos de Administrador (para algunas instalaciones)

---

## 📦 Opción 1: Instalación Automática con Winget (Recomendado)

### Paso 1: Verificar que tienes Winget

Abre **PowerShell** y ejecuta:

```powershell
winget --version
```

Si ves un número de versión (ej: `v1.6.xxx`), continúa. Si no, instala desde:
https://github.com/microsoft/winget-cli/releases

### Paso 2: Instalar Rust

```powershell
# Instalar Rustup (instalador de Rust)
winget install Rustlang.Rustup

# Cerrar y reabrir PowerShell después de la instalación
```

### Paso 3: Instalar Stellar CLI

```powershell
# Instalar Stellar CLI
winget install --id Stellar.StellarCLI

# Cerrar y reabrir PowerShell
```

### Paso 4: Configurar WASM Target

```powershell
rustup target add wasm32-unknown-unknown
```

### Paso 5: Verificar Instalaciones

```powershell
# Verificar Rust
rustc --version
cargo --version

# Verificar Stellar CLI
stellar --version

# Deberías ver algo como:
# rustc 1.75.0
# cargo 1.75.0
# stellar 21.x.x
```

---

## 📦 Opción 2: Instalación Manual

### Paso 1: Instalar Rust

1. **Descargar Rustup:**
   - Ve a: https://rustup.rs/
   - Click en **"Download rustup-init.exe"**

2. **Ejecutar el instalador:**
   ```
   - Doble click en rustup-init.exe
   - Opción 1 (instalación por defecto)
   - Presiona ENTER
   - Espera 5-10 minutos
   ```

3. **Verificar instalación:**
   ```powershell
   # Cerrar y reabrir PowerShell
   rustc --version
   cargo --version
   ```

### Paso 2: Instalar Stellar CLI

**Opción A - Desde GitHub Releases:**

1. Ve a: https://github.com/stellar/stellar-cli/releases/latest

2. Descarga el archivo para Windows:
   ```
   stellar-cli-XXX-x86_64-pc-windows-msvc.zip
   ```

3. Extrae el archivo ZIP

4. **Agregar al PATH:**
   ```powershell
   # Opción 1: Mover a una carpeta existente en PATH
   Move-Item stellar.exe "C:\Windows\System32\"

   # Opción 2: Crear carpeta y agregar al PATH
   New-Item -Path "C:\Program Files\Stellar" -ItemType Directory -Force
   Move-Item stellar.exe "C:\Program Files\Stellar\"

   # Agregar al PATH del sistema
   $env:Path += ";C:\Program Files\Stellar"
   [Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)
   ```

5. **Verificar:**
   ```powershell
   # Cerrar y reabrir PowerShell
   stellar --version
   ```

**Opción B - Compilar desde código (requiere Rust instalado):**

```powershell
# Instalar usando Cargo (puede tardar 10-15 minutos)
cargo install --locked stellar-cli --features opt

# Verificar
stellar --version
```

### Paso 3: Configurar WASM Target

```powershell
rustup target add wasm32-unknown-unknown
```

---

## 🎯 Verificación Final

Ejecuta este script para verificar que todo está instalado correctamente:

```powershell
Write-Host "`n=== Verificación de Instalación ===" -ForegroundColor Cyan

# Rust
try {
    $rustVersion = rustc --version
    Write-Host "✅ Rust: $rustVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Rust no instalado" -ForegroundColor Red
}

# Cargo
try {
    $cargoVersion = cargo --version
    Write-Host "✅ Cargo: $cargoVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Cargo no instalado" -ForegroundColor Red
}

# Stellar CLI
try {
    $stellarVersion = stellar --version
    Write-Host "✅ Stellar CLI: $stellarVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Stellar CLI no instalado" -ForegroundColor Red
}

# WASM Target
$targets = rustup target list --installed
if ($targets -match "wasm32-unknown-unknown") {
    Write-Host "✅ WASM target instalado" -ForegroundColor Green
} else {
    Write-Host "❌ WASM target no instalado. Ejecuta: rustup target add wasm32-unknown-unknown" -ForegroundColor Red
}

Write-Host "`n=== Fin de Verificación ===`n" -ForegroundColor Cyan
```

---

## 🚀 Siguiente Paso: Compilar el Contrato

Una vez que todo esté instalado, compila el smart contract:

```powershell
# Navegar al directorio del contrato
cd luminariff-contract

# Compilar
stellar contract build

# Verificar que se generó el WASM
dir target\wasm32-unknown-unknown\release\luminariff_contract.wasm
```

**Salida esperada:**
```
✅ Compiling luminariff-contract v0.1.0
✅ Finished release [optimized] target(s) in 12.34s
```

---

## 🐛 Troubleshooting

### Error: "cargo: command not found"

**Solución:**
1. Cierra y reabre PowerShell
2. Verifica que Rust se instaló: `where.exe cargo`
3. Si no aparece, reinstala Rust desde https://rustup.rs/

### Error: "stellar: command not found"

**Solución:**
1. Verifica instalación: `where.exe stellar`
2. Si no aparece, reinstala Stellar CLI
3. Verifica que esté en el PATH del sistema

### Error: "linking with `link.exe` failed"

**Solución:**
Instala las herramientas de compilación de Visual Studio:

```powershell
# Opción 1: VS Build Tools (ligero)
winget install Microsoft.VisualStudio.2022.BuildTools

# Opción 2: Visual Studio Community (completo)
winget install Microsoft.VisualStudio.2022.Community
```

Durante la instalación, selecciona:
- "Desktop development with C++"
- Windows 10/11 SDK

### Error: "error: target 'wasm32-unknown-unknown' not found"

**Solución:**
```powershell
rustup target add wasm32-unknown-unknown
```

### Error al compilar: "failed to run custom build command"

**Solución:**
```powershell
# Actualizar Rust a la última versión
rustup update

# Limpiar caché y recompilar
cd luminariff-contract
cargo clean
cargo build --release --target wasm32-unknown-unknown
```

---

## 📚 Recursos Adicionales

- **Documentación de Rust:** https://www.rust-lang.org/learn
- **Documentación de Soroban:** https://soroban.stellar.org/docs
- **Stellar CLI Docs:** https://developers.stellar.org/docs/tools/developer-tools
- **Discord de Stellar:** https://discord.gg/stellar

---

## ✅ Todo Listo!

Una vez que completes esta instalación, puedes:

1. **Compilar el contrato:**
   ```powershell
   cd luminariff-contract
   stellar contract build
   ```

2. **Ejecutar el setup completo:**
   ```powershell
   .\setup.ps1
   ```

3. **Ejecutar la demo:**
   ```powershell
   .\demo.ps1
   ```

---

**¿Necesitas ayuda?** Abre un Issue en GitHub: https://github.com/emolinah/luminariff/issues