# ============================================
# Script de Despliegue a Futurenet
# LuminaRiff - Stellar Ideaton 2024
# ============================================

$ErrorActionPreference = "Stop"

# Configurar para ignorar errores de certificado SSL (solo para desarrollo)
$env:STELLAR_RPC_SKIP_TLS_VERIFY = "true"
$env:SOROBAN_RPC_SKIP_TLS_VERIFY = "true"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   LuminaRiff - Deploy to Futurenet" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# CONTRATO YA DESPLEGADO AUTOMÁTICAMENTE
# ============================================
$DEPLOYED_CONTRACT_ID = "CBWZ2Z644ZWULJ2WNYF37AIXJLIHRPYU4OTYVQP6WLZBXFB56GD3P5OA"
$DEPLOYED_ADMIN_ADDRESS = "GAO5SMPKFJ2ST6Z43PTHJ6R6ZDQDU3JWPVPIXS6CGV3T5E4YOQ7EAOKY"
$DEPLOYED_NETWORK = "futurenet"

Write-Host "CONTRATO YA DESPLEGADO EN FUTURNET:" -ForegroundColor Green
Write-Host "-----------------------------------" -ForegroundColor Gray
Write-Host "Contract ID:  $DEPLOYED_CONTRACT_ID" -ForegroundColor Yellow
Write-Host "Admin:        $DEPLOYED_ADMIN_ADDRESS" -ForegroundColor Yellow
Write-Host "Network:      $DEPLOYED_NETWORK" -ForegroundColor Yellow
Write-Host "Fecha:        19 de diciembre de 2025" -ForegroundColor Yellow
Write-Host ""

$useDeployed = Read-Host "¿Quieres usar el contrato ya desplegado? (y/n)"

if ($useDeployed -eq "y" -or $useDeployed -eq "Y") {
    Write-Host "`nUsando contrato desplegado automáticamente..." -ForegroundColor Green

    # ============================================
    # PRUEBAS CON EL CONTRATO DESPLEGADO
    # ============================================
    Write-Host "`n[1/3] Verificando contrato desplegado..." -ForegroundColor Yellow

    try {
        $result = stellar contract info --id $DEPLOYED_CONTRACT_ID --network $DEPLOYED_NETWORK 2>&1
        Write-Host "OK: Contrato encontrado en la red" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: No se pudo verificar el contrato" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 1
    }

    Write-Host "`n[2/3] Próximos pasos con el contrato desplegado:" -ForegroundColor Yellow
    Write-Host "--------------------------------------------" -ForegroundColor Gray

    Write-Host "`nPaso 1: Inicializar el contrato" -ForegroundColor Cyan
    Write-Host "stellar contract invoke --id $DEPLOYED_CONTRACT_ID --source admin --network $DEPLOYED_NETWORK -- initialize --admin $DEPLOYED_ADMIN_ADDRESS --token_address USDC_TOKEN_ADDRESS" -ForegroundColor White

    Write-Host "`nPaso 2: Comprar un ticket de prueba" -ForegroundColor Cyan
    Write-Host "stellar contract invoke --id $DEPLOYED_CONTRACT_ID --source admin --network $DEPLOYED_NETWORK -- buy_ticket --buyer $DEPLOYED_ADMIN_ADDRESS --roblox_user_id TestUser123" -ForegroundColor White

    Write-Host "`nPaso 3: Ver participantes" -ForegroundColor Cyan
    Write-Host "stellar contract invoke --id $DEPLOYED_CONTRACT_ID --network $DEPLOYED_NETWORK -- get_roblox_ids" -ForegroundColor White

    Write-Host "`nPaso 4: Ejecutar sorteo (solo admin)" -ForegroundColor Cyan
    Write-Host "stellar contract invoke --id $DEPLOYED_CONTRACT_ID --source admin --network $DEPLOYED_NETWORK -- execute_draw --admin $DEPLOYED_ADMIN_ADDRESS" -ForegroundColor White

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "  CONTRATO LISTO PARA USAR" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""

    exit 0
}

Write-Host "`nProcediendo con despliegue manual..." -ForegroundColor Yellow
Write-Host ""

$NETWORK = "futurenet"
$WASM_PATH = "target\wasm32-unknown-unknown\release\luminariff_contract.wasm"

# Verificar que el WASM existe
if (-not (Test-Path $WASM_PATH)) {
    Write-Host "ERROR: No se encontro el archivo WASM en: $WASM_PATH" -ForegroundColor Red
    Write-Host "Ejecuta primero: cargo build --release --target wasm32-unknown-unknown" -ForegroundColor Yellow
    exit 1
}

Write-Host "OK: WASM encontrado: $WASM_PATH" -ForegroundColor Green

# ============================================
# PASO 1: Configurar red futurenet
# ============================================
Write-Host "`n[1/6] Configurando red Futurenet..." -ForegroundColor Yellow

try {
    stellar network add $NETWORK --rpc-url https://rpc-futurenet.stellar.org --network-passphrase "Test SDF Future Network ; October 2022" 2>&1 | Out-Null
    Write-Host "OK: Red Futurenet configurada" -ForegroundColor Green
} catch {
    Write-Host "INFO: Red Futurenet ya estaba configurada" -ForegroundColor Gray
}

# ============================================
# PASO 2: Verificar/Crear identidad admin
# ============================================
Write-Host "`n[2/6] Verificando identidad admin..." -ForegroundColor Yellow

$existingKeys = stellar keys ls 2>&1
if ($existingKeys -match "admin") {
    Write-Host "OK: Identidad 'admin' ya existe" -ForegroundColor Green
} else {
    Write-Host "Creando nueva identidad 'admin'..." -ForegroundColor Gray
    stellar keys generate admin --network $NETWORK
    Write-Host "OK: Identidad 'admin' creada" -ForegroundColor Green
}

# Obtener direccion
$adminAddress = stellar keys address admin
Write-Host "Admin address: $adminAddress" -ForegroundColor White

# ============================================
# PASO 3: Financiar cuenta
# ============================================
Write-Host "`n[3/6] Financiando cuenta admin..." -ForegroundColor Yellow

try {
    stellar keys fund admin --network $NETWORK
    Write-Host "OK: Cuenta financiada exitosamente" -ForegroundColor Green
    Start-Sleep -Seconds 2
} catch {
    Write-Host "ERROR: Error al financiar la cuenta:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`nIntenta financiar manualmente visitando:" -ForegroundColor Yellow
    Write-Host "https://laboratory.stellar.org/#account-creator?network=futurenet" -ForegroundColor Cyan
    exit 1
}

# Verificar balance
Write-Host "`nVerificando balance..." -ForegroundColor Gray
try {
    $balance = stellar keys balance admin --network $NETWORK
    Write-Host "Balance: $balance" -ForegroundColor White
} catch {
    Write-Host "WARN: No se pudo verificar el balance, pero continuando..." -ForegroundColor Yellow
}

# ============================================
# PASO 4: Desplegar contrato
# ============================================
Write-Host "`n[4/6] Desplegando contrato a Futurenet..." -ForegroundColor Yellow
Write-Host "(Esto puede tardar 30-60 segundos...)" -ForegroundColor Gray

try {
    $contractId = stellar contract deploy --wasm $WASM_PATH --source admin --network $NETWORK 2>&1 | Select-Object -Last 1
    $contractId = $contractId.ToString().Trim()

    Write-Host "`nOK: Contrato desplegado exitosamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  CONTRACT ID:" -ForegroundColor Cyan
    Write-Host "  $contractId" -ForegroundColor Yellow
    Write-Host "============================================" -ForegroundColor Cyan

    # Guardar Contract ID
    $contractId | Out-File -FilePath "contract-id.txt" -Encoding utf8
    Write-Host "`nOK: Contract ID guardado en: contract-id.txt" -ForegroundColor Green

} catch {
    Write-Host "`nERROR: Error al desplegar el contrato:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# ============================================
# PASO 5: Informacion del despliegue
# ============================================
Write-Host "`n[5/6] Informacion del despliegue:" -ForegroundColor Yellow
Write-Host "--------------------------------------------" -ForegroundColor Gray
Write-Host "Network:      futurenet" -ForegroundColor White
Write-Host "Admin:        $adminAddress" -ForegroundColor White
Write-Host "Contract ID:  $contractId" -ForegroundColor White
Write-Host "WASM Size:    $((Get-Item $WASM_PATH).Length) bytes" -ForegroundColor White

# ============================================
# PASO 6: Proximos pasos
# ============================================
Write-Host "`n[6/6] Proximos pasos:" -ForegroundColor Yellow
Write-Host "--------------------------------------------" -ForegroundColor Gray

Write-Host "`nPaso 1: Inicializar el contrato" -ForegroundColor Cyan
Write-Host "stellar contract invoke --id $contractId --source admin --network $NETWORK -- initialize --admin $adminAddress --token_address USDC_TOKEN_ADDRESS" -ForegroundColor White

Write-Host "`nPaso 2: Comprar un ticket de prueba" -ForegroundColor Cyan
Write-Host "stellar contract invoke --id $contractId --source admin --network $NETWORK -- buy_ticket --buyer $adminAddress --roblox_user_id TestUser123" -ForegroundColor White

Write-Host "`nPaso 3: Ver participantes" -ForegroundColor Cyan
Write-Host "stellar contract invoke --id $contractId --network $NETWORK -- get_roblox_ids" -ForegroundColor White

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  DESPLIEGUE COMPLETADO" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""