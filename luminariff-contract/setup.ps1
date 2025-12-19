# ============================================
# LuminaRiff - Script de Setup Inicial
# ============================================
# Este script configura el entorno y despliega el contrato

param(
    [string]$Network = "testnet"
)

function Write-Step {
    param([string]$Message)
    Write-Host "`n>>> $Message" -ForegroundColor Cyan
}

function Write-Info {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Green
}

# Banner
Write-Host @"

╔════════════════════════════════════════╗
║   LuminaRiff - Setup Wizard            ║
║   Stellar Soroban Smart Contract       ║
╚════════════════════════════════════════╝

"@ -ForegroundColor Magenta

# ============================================
# PASO 1: Verificar herramientas instaladas
# ============================================
Write-Step "Verificando herramientas instaladas..."

# Verificar Rust
try {
    $rustVersion = cargo --version
    Write-Success "✓ Rust instalado: $rustVersion"
} catch {
    Write-Host "✗ Rust no encontrado. Instálalo desde: https://rustup.rs/" -ForegroundColor Red
    exit 1
}

# Verificar Stellar CLI
try {
    $stellarVersion = stellar --version
    Write-Success "✓ Stellar CLI instalado: $stellarVersion"
} catch {
    Write-Host "✗ Stellar CLI no encontrado. Instálalo con: winget install Stellar.StellarCLI" -ForegroundColor Red
    exit 1
}

# Verificar target WASM
Write-Info "Verificando target wasm32-unknown-unknown..."
rustup target add wasm32-unknown-unknown

# ============================================
# PASO 2: Configurar red
# ============================================
Write-Step "Configurando red $Network..."

try {
    stellar network add testnet `
        --rpc-url https://soroban-testnet.stellar.org:443 `
        --network-passphrase "Test SDF Network ; September 2015" `
        2>&1 | Out-Null
    Write-Success "✓ Red testnet configurada"
} catch {
    Write-Info "Red testnet ya estaba configurada"
}

# ============================================
# PASO 3: Crear identidades
# ============================================
Write-Step "Creando identidades..."

# Verificar identidades existentes
$existingKeys = stellar keys ls 2>&1

# Admin
if ($existingKeys -notmatch "admin") {
    stellar keys generate admin --network $Network
    Write-Success "✓ Identidad 'admin' creada"
} else {
    Write-Info "Identidad 'admin' ya existe"
}

# User1
if ($existingKeys -notmatch "user1") {
    stellar keys generate user1 --network $Network
    Write-Success "✓ Identidad 'user1' creada"
} else {
    Write-Info "Identidad 'user1' ya existe"
}

# User2
if ($existingKeys -notmatch "user2") {
    stellar keys generate user2 --network $Network
    Write-Success "✓ Identidad 'user2' creada"
} else {
    Write-Info "Identidad 'user2' ya existe"
}

# Mostrar direcciones
$adminAddress = stellar keys address admin
$user1Address = stellar keys address user1
$user2Address = stellar keys address user2

Write-Host "`nDirecciones generadas:" -ForegroundColor Cyan
Write-Host "Admin:  $adminAddress" -ForegroundColor White
Write-Host "User1:  $user1Address" -ForegroundColor White
Write-Host "User2:  $user2Address" -ForegroundColor White

# ============================================
# PASO 4: Financiar cuentas
# ============================================
Write-Step "Financiando cuentas con XLM de prueba..."

Write-Info "Financiando admin..."
stellar keys fund admin --network $Network
Start-Sleep -Seconds 2

Write-Info "Financiando user1..."
stellar keys fund user1 --network $Network
Start-Sleep -Seconds 2

Write-Info "Financiando user2..."
stellar keys fund user2 --network $Network

Write-Success "✓ Cuentas financiadas"

# ============================================
# PASO 5: Compilar contrato
# ============================================
Write-Step "Compilando Smart Contract..."

try {
    stellar contract build
    Write-Success "✓ Contrato compilado exitosamente"
} catch {
    Write-Host "✗ Error al compilar el contrato: $_" -ForegroundColor Red
    exit 1
}

# ============================================
# PASO 6: Desplegar contrato
# ============================================
Write-Step "Desplegando contrato en $Network..."

try {
    $contractId = stellar contract deploy `
        --wasm target\wasm32-unknown-unknown\release\luminariff_contract.wasm `
        --source admin `
        --network $Network `
        2>&1 | Select-Object -Last 1

    $contractId = $contractId.Trim()
    Write-Success "✓ Contrato desplegado exitosamente!"
    Write-Host "`nContract ID: $contractId" -ForegroundColor Yellow

    # Guardar Contract ID en archivo
    $contractId | Out-File -FilePath "contract-id.txt" -Encoding utf8
    Write-Info "Contract ID guardado en: contract-id.txt"

} catch {
    Write-Host "✗ Error al desplegar el contrato: $_" -ForegroundColor Red
    exit 1
}

# ============================================
# PASO 7: Inicializar contrato
# ============================================
Write-Step "Inicializando contrato..."

Write-Info "NOTA: Necesitas la dirección del token USDC en testnet"
Write-Host @"

Para inicializar el contrato, ejecuta:

stellar contract invoke \
  --id $contractId \
  --source admin \
  --network $Network \
  -- initialize \
  --admin $adminAddress \
  --token_address <USDC_TOKEN_ADDRESS>

"@ -ForegroundColor Gray

# ============================================
# PASO 8: Resumen
# ============================================
Write-Host @"

╔════════════════════════════════════════╗
║         Setup Completado!              ║
╚════════════════════════════════════════╝

✓ Herramientas verificadas
✓ Red configurada
✓ Identidades creadas y financiadas
✓ Contrato compilado y desplegado

Información importante:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Contract ID: $contractId
Admin:       $adminAddress
User1:       $user1Address
User2:       $user2Address

Próximos pasos:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Obtén la dirección del token USDC en testnet
2. Inicializa el contrato (comando mostrado arriba)
3. Ejecuta el script de demostración:
   .\demo.ps1 -ContractId '$contractId'

Archivos generados:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ contract-id.txt - ID del contrato desplegado

¡Listo para la Ideatón! 🚀

"@ -ForegroundColor Green
