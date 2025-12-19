# ============================================
# Script de Despliegue Manual a Futurenet
# LuminaRiff - Stellar Ideaton 2024
# ============================================
# Este script usa financiamiento manual para evitar problemas SSL

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   LuminaRiff - Deploy Manual" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$NETWORK = "futurenet"
$WASM_PATH = "target\wasm32-unknown-unknown\release\luminariff_contract.wasm"

# Verificar que el WASM existe
if (-not (Test-Path $WASM_PATH)) {
    Write-Host "ERROR: No se encontro el archivo WASM" -ForegroundColor Red
    exit 1
}

Write-Host "OK: WASM encontrado" -ForegroundColor Green

# ============================================
# PASO 1: Obtener direccion admin
# ============================================
Write-Host "`n[1/4] Obteniendo direccion admin..." -ForegroundColor Yellow

try {
    $adminAddress = stellar keys address admin 2>&1
    Write-Host "Admin address: $adminAddress" -ForegroundColor White
} catch {
    Write-Host "ERROR: No se encontro la identidad 'admin'" -ForegroundColor Red
    Write-Host "Ejecuta: stellar keys generate admin" -ForegroundColor Yellow
    exit 1
}

# ============================================
# PASO 2: Financiamiento manual
# ============================================
Write-Host "`n[2/4] FINANCIAMIENTO MANUAL REQUERIDO" -ForegroundColor Yellow
Write-Host "--------------------------------------------" -ForegroundColor Gray
Write-Host "`nDebido a problemas con certificados SSL, debes financiar manualmente:" -ForegroundColor White
Write-Host "`n1. Visita esta URL en tu navegador:" -ForegroundColor Cyan
Write-Host "   https://laboratory.stellar.org/#account-creator?network=futurenet" -ForegroundColor White
Write-Host "`n2. En el formulario:" -ForegroundColor Cyan
Write-Host "   - Pega esta direccion: $adminAddress" -ForegroundColor Yellow
Write-Host "   - Click en 'Get test network funds'" -ForegroundColor White
Write-Host "`n3. Espera unos segundos hasta que veas 'Account funded!'" -ForegroundColor Cyan

Write-Host "`n¿Ya financiaste la cuenta? (S/N): " -NoNewline -ForegroundColor Yellow
$response = Read-Host

if ($response -ne "S" -and $response -ne "s") {
    Write-Host "`nCancela el script. Financia la cuenta primero." -ForegroundColor Red
    exit 0
}

# ============================================
# PASO 3: Desplegar contrato
# ============================================
Write-Host "`n[3/4] Desplegando contrato a Futurenet..." -ForegroundColor Yellow
Write-Host "(Esto puede tardar 30-60 segundos...)" -ForegroundColor Gray
Write-Host ""

# Ejecutar deploy y capturar toda la salida
$deployOutput = stellar contract deploy --wasm $WASM_PATH --source admin --network $NETWORK 2>&1

# Mostrar la salida completa
Write-Host $deployOutput -ForegroundColor Gray

# Intentar extraer el Contract ID de la salida
$contractId = $null
foreach ($line in $deployOutput) {
    $lineStr = $line.ToString()
    # El Contract ID suele ser una cadena que empieza con C y tiene 56 caracteres
    if ($lineStr -match '(C[A-Z0-9]{55})') {
        $contractId = $matches[1]
        break
    }
}

if ($contractId) {
    Write-Host "`nOK: Contrato desplegado exitosamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  CONTRACT ID:" -ForegroundColor Cyan
    Write-Host "  $contractId" -ForegroundColor Yellow
    Write-Host "============================================" -ForegroundColor Cyan

    # Guardar Contract ID
    $contractId | Out-File -FilePath "contract-id.txt" -Encoding utf8
    Write-Host "`nOK: Contract ID guardado en: contract-id.txt" -ForegroundColor Green
} else {
    Write-Host "`nERROR: No se pudo extraer el Contract ID" -ForegroundColor Red
    Write-Host "Revisa la salida anterior para ver si hubo errores" -ForegroundColor Yellow

    # Intentar encontrar el Contract ID manualmente en la salida
    Write-Host "`nBusca el Contract ID en la salida anterior (una cadena que empieza con 'C')" -ForegroundColor Yellow
    Write-Host "¿Quieres ingresar el Contract ID manualmente? (S/N): " -NoNewline -ForegroundColor Yellow
    $response = Read-Host

    if ($response -eq "S" -or $response -eq "s") {
        Write-Host "Ingresa el Contract ID: " -NoNewline -ForegroundColor Cyan
        $contractId = Read-Host
        $contractId | Out-File -FilePath "contract-id.txt" -Encoding utf8
    } else {
        exit 1
    }
}

# ============================================
# PASO 4: Proximos pasos
# ============================================
Write-Host "`n[4/4] Proximos pasos:" -ForegroundColor Yellow
Write-Host "--------------------------------------------" -ForegroundColor Gray

Write-Host "`nPaso 1: Inicializar el contrato" -ForegroundColor Cyan
Write-Host "stellar contract invoke --id $contractId --source admin --network $NETWORK -- initialize --admin $adminAddress --token_address USDC_TOKEN" -ForegroundColor White

Write-Host "`nPaso 2: Ver informacion del contrato" -ForegroundColor Cyan
Write-Host "stellar contract invoke --id $contractId --network $NETWORK -- get_admin" -ForegroundColor White

Write-Host "`nPaso 3: Ver participantes" -ForegroundColor Cyan
Write-Host "stellar contract invoke --id $contractId --network $NETWORK -- get_participants_count" -ForegroundColor White

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  PROCESO COMPLETADO" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Contract ID guardado en: contract-id.txt" -ForegroundColor Gray
Write-Host "Admin Address: $adminAddress" -ForegroundColor Gray
Write-Host ""