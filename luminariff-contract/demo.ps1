# ============================================
# LuminaRiff - Script de Demostración
# ============================================
# Este script demuestra el flujo completo del smart contract

param(
    [string]$ContractId = "",
    [string]$Network = "testnet"
)

# Colores para output
function Write-Step {
    param([string]$Message)
    Write-Host "`n$Message" -ForegroundColor Cyan
}

function Write-Info {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Red
}

# Banner
Write-Host "
╔════════════════════════════════════════╗
║     LuminaRiff Demo Script             ║
║     Stellar Soroban Smart Contract     ║
╚════════════════════════════════════════╝
" -ForegroundColor Magenta

# Verificar que se proporcionó el Contract ID
if ($ContractId -eq "") {
    Write-Error-Custom "Error: Debes proporcionar el Contract ID"
    Write-Info "Uso: .\demo.ps1 -ContractId 'TU_CONTRACT_ID' [-Network testnet]"
    exit 1
}

Write-Info "Contract ID: $ContractId"
Write-Info "Network: $Network"

# ============================================
# PASO 1: Verificar estado inicial
# ============================================
Write-Step "PASO 1: Consultando estado inicial del contrato..."

try {
    $count = stellar contract invoke `
        --id $ContractId `
        --network $Network `
        -- get_participants_count

    Write-Success "Participantes actuales: $count"
} catch {
    Write-Error-Custom "Error al consultar participantes: $_"
}

# ============================================
# PASO 2: Crear identidades si no existen
# ============================================
Write-Step "PASO 2: Verificando identidades de prueba..."

$identities = stellar keys ls 2>&1
if ($identities -notmatch "user1") {
    Write-Info "Creando identidad 'user1'..."
    stellar keys generate user1 --network $Network
}

if ($identities -notmatch "user2") {
    Write-Info "Creando identidad 'user2'..."
    stellar keys generate user2 --network $Network
}

# Obtener direcciones
$user1Address = stellar keys address user1
$user2Address = stellar keys address user2

Write-Success "User1: $user1Address"
Write-Success "User2: $user2Address"

# ============================================
# PASO 3: Financiar cuentas (si es necesario)
# ============================================
Write-Step "PASO 3: Verificando fondos de las cuentas..."
Write-Info "Si las cuentas no tienen fondos, ejecuta:"
Write-Info "stellar keys fund user1 --network $Network"
Write-Info "stellar keys fund user2 --network $Network"

# ============================================
# PASO 4: Comprar tickets
# ============================================
Write-Step "PASO 4: Comprando tickets..."

Write-Info "User1 comprando ticket con Roblox ID: roblox_demo_123"
try {
    stellar contract invoke `
        --id $ContractId `
        --source user1 `
        --network $Network `
        -- buy_ticket `
        --buyer $user1Address `
        --roblox_user_id "roblox_demo_123"

    Write-Success "Ticket comprado por user1"
} catch {
    Write-Error-Custom "Error al comprar ticket user1: $_"
}

Start-Sleep -Seconds 2

Write-Info "User2 comprando ticket con Roblox ID: roblox_demo_456"
try {
    stellar contract invoke `
        --id $ContractId `
        --source user2 `
        --network $Network `
        -- buy_ticket `
        --buyer $user2Address `
        --roblox_user_id "roblox_demo_456"

    Write-Success "Ticket comprado por user2"
} catch {
    Write-Error-Custom "Error al comprar ticket user2: $_"
}

# ============================================
# PASO 5: Consultar participantes
# ============================================
Write-Step "PASO 5: Consultando participantes registrados..."

try {
    $participants = stellar contract invoke `
        --id $ContractId `
        --network $Network `
        -- get_roblox_ids

    Write-Success "IDs de Roblox registrados:"
    Write-Host $participants -ForegroundColor White
} catch {
    Write-Error-Custom "Error al consultar participantes: $_"
}

try {
    $count = stellar contract invoke `
        --id $ContractId `
        --network $Network `
        -- get_participants_count

    Write-Success "Total de participantes: $count"
} catch {
    Write-Error-Custom "Error al consultar contador: $_"
}

# ============================================
# PASO 6: Ver todos los participantes completos
# ============================================
Write-Step "PASO 6: Consultando datos completos de participantes..."

try {
    $players = stellar contract invoke `
        --id $ContractId `
        --network $Network `
        -- get_players

    Write-Success "Participantes completos:"
    Write-Host $players -ForegroundColor White
} catch {
    Write-Error-Custom "Error al consultar jugadores: $_"
}

# ============================================
# PASO 7: Ejecutar sorteo (requiere admin)
# ============================================
Write-Step "PASO 7: Ejecutando sorteo..."
Write-Info "NOTA: Esta función requiere autenticación de admin"
Write-Info "Para ejecutar el sorteo, usa:"
Write-Host @"
stellar contract invoke \
  --id $ContractId \
  --source admin \
  --network $Network \
  -- execute_draw \
  --admin <ADMIN_ADDRESS>
"@ -ForegroundColor Gray

# Si existe la identidad admin, intentar ejecutar
$adminExists = stellar keys ls 2>&1 | Select-String "admin"
if ($adminExists) {
    $adminAddress = stellar keys address admin
    Write-Info "Detectada identidad admin: $adminAddress"
    Write-Info "Intentando ejecutar sorteo..."

    try {
        $winner = stellar contract invoke `
            --id $ContractId `
            --source admin `
            --network $Network `
            -- execute_draw `
            --admin $adminAddress

        Write-Success "¡GANADOR SELECCIONADO!"
        Write-Host $winner -ForegroundColor Yellow
    } catch {
        Write-Error-Custom "No se pudo ejecutar sorteo (verifica que 'admin' sea el owner): $_"
    }
}

# ============================================
# RESUMEN FINAL
# ============================================
Write-Step "DEMOSTRACIÓN COMPLETADA"
Write-Host @"

╔════════════════════════════════════════╗
║     Resumen de Funcionalidades         ║
╚════════════════════════════════════════╝

✓ Compra de tickets con USDC
✓ Registro de Roblox User IDs
✓ Consulta de participantes
✓ Sistema de sorteo aleatorio
✓ Control de acceso por admin

Próximos pasos:
1. Revisar el código en: src/lib.rs
2. Leer documentación en: README.md
3. Integrar con tu frontend
4. Preparar video de pitch

¡Buena suerte en la Ideatón! 🚀
"@ -ForegroundColor Green
