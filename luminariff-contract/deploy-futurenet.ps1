# ============================================
# Script de Despliegue a Futurenet
# LuminaRiff - Stellar Ideatón 2024
# ============================================

$ErrorActionPreference = "Stop"

Write-Host @"

╔════════════════════════════════════════╗
║   LuminaRiff - Deploy to Futurenet     ║
╚════════════════════════════════════════╝

"@ -ForegroundColor Cyan

$NETWORK = "futurenet"
$WASM_PATH = "target\wasm32-unknown-unknown\release\luminariff_contract.wasm"

# Verificar que el WASM existe
if (-not (Test-Path $WASM_PATH)) {
    Write-Host "❌ No se encontró el archivo WASM en: $WASM_PATH" -ForegroundColor Red
    Write-Host "   Ejecuta primero: cargo build --release --target wasm32-unknown-unknown" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ WASM encontrado: $WASM_PATH" -ForegroundColor Green

# ============================================
# PASO 1: Configurar red futurenet
# ============================================
Write-Host "`n[1/6] Configurando red Futurenet..." -ForegroundColor Yellow

try {
    stellar network add $NETWORK `
        --rpc-url https://rpc-futurenet.stellar.org `
        --network-passphrase "Test SDF Future Network ; October 2022" 2>&1 | Out-Null
    Write-Host "✅ Red Futurenet configurada" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Red Futurenet ya estaba configurada" -ForegroundColor Gray
}

# ============================================
# PASO 2: Verificar/Crear identidad admin
# ============================================
Write-Host "`n[2/6] Verificando identidad admin..." -ForegroundColor Yellow

$existingKeys = stellar keys ls 2>&1
if ($existingKeys -match "admin") {
    Write-Host "✅ Identidad 'admin' ya existe" -ForegroundColor Green
} else {
    Write-Host "Creando nueva identidad 'admin'..." -ForegroundColor Gray
    stellar keys generate admin --network $NETWORK
    Write-Host "✅ Identidad 'admin' creada" -ForegroundColor Green
}

# Obtener dirección
$adminAddress = stellar keys address admin
Write-Host "Admin address: $adminAddress" -ForegroundColor White

# ============================================
# PASO 3: Financiar cuenta
# ============================================
Write-Host "`n[3/6] Financiando cuenta admin..." -ForegroundColor Yellow

try {
    stellar keys fund admin --network $NETWORK
    Write-Host "✅ Cuenta financiada exitosamente" -ForegroundColor Green
    Start-Sleep -Seconds 2
} catch {
    Write-Host "❌ Error al financiar la cuenta:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`n⚠️  Intenta financiar manualmente visitando:" -ForegroundColor Yellow
    Write-Host "https://laboratory.stellar.org/#account-creator?network=futurenet" -ForegroundColor Cyan
    exit 1
}

# Verificar balance
Write-Host "`nVerificando balance..." -ForegroundColor Gray
try {
    $balance = stellar keys balance admin --network $NETWORK
    Write-Host "Balance: $balance" -ForegroundColor White
} catch {
    Write-Host "⚠️  No se pudo verificar el balance, pero continuando..." -ForegroundColor Yellow
}

# ============================================
# PASO 4: Desplegar contrato
# ============================================
Write-Host "`n[4/6] Desplegando contrato a Futurenet..." -ForegroundColor Yellow
Write-Host "(Esto puede tardar 30-60 segundos...)" -ForegroundColor Gray

try {
    $contractId = stellar contract deploy `
        --wasm $WASM_PATH `
        --source admin `
        --network $NETWORK `
        2>&1 | Select-Object -Last 1

    $contractId = $contractId.ToString().Trim()

    Write-Host "`n✅ ¡Contrato desplegado exitosamente!" -ForegroundColor Green
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  CONTRACT ID:" -ForegroundColor Cyan
    Write-Host "║  $contractId" -ForegroundColor Yellow
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

    # Guardar Contract ID
    $contractId | Out-File -FilePath "contract-id.txt" -Encoding utf8
    Write-Host "`n✅ Contract ID guardado en: contract-id.txt" -ForegroundColor Green

} catch {
    Write-Host "`n❌ Error al desplegar el contrato:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# ============================================
# PASO 5: Información del despliegue
# ============================================
Write-Host "`n[5/6] Información del despliegue:" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "Network:      futurenet" -ForegroundColor White
Write-Host "Admin:        $adminAddress" -ForegroundColor White
Write-Host "Contract ID:  $contractId" -ForegroundColor White
Write-Host "WASM Size:    $((Get-Item $WASM_PATH).Length) bytes" -ForegroundColor White

# ============================================
# PASO 6: Próximos pasos
# ============================================
Write-Host "`n[6/6] Próximos pasos:" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

Write-Host "`n1️⃣  Inicializar el contrato:" -ForegroundColor Cyan
$initCommand = @"
stellar contract invoke \`
  --id $contractId \`
  --source admin \`
  --network $NETWORK \`
  -- initialize \`
  --admin $adminAddress \`
  --token_address <USDC_TOKEN_ADDRESS_FUTURENET>
"@
Write-Host $initCommand -ForegroundColor White

Write-Host "`n2️⃣  Comprar un ticket de prueba:" -ForegroundColor Cyan
$buyCommand = @"
stellar contract invoke \`
  --id $contractId \`
  --source admin \`
  --network $NETWORK \`
  -- buy_ticket \`
  --buyer $adminAddress \`
  --roblox_user_id "TestUser123"
"@
Write-Host $buyCommand -ForegroundColor White

Write-Host "`n3️⃣  Ver participantes:" -ForegroundColor Cyan
$getCommand = @"
stellar contract invoke \`
  --id $contractId \`
  --network $NETWORK \`
  -- get_roblox_ids
"@
Write-Host $getCommand -ForegroundColor White

Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  ✅ DESPLIEGUE COMPLETADO              ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""