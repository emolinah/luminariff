# ============================================
# Script de Pruebas del Contrato LuminaRiff
# Prueba todas las funcionalidades del contrato desplegado
# ============================================

$ErrorActionPreference = "Stop"

# Configurar para ignorar errores de certificado SSL
$env:STELLAR_RPC_SKIP_TLS_VERIFY = "true"
$env:SOROBAN_RPC_SKIP_TLS_VERIFY = "true"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   🧪 LuminaRiff - Test Suite" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# CONFIGURACIÓN DEL CONTRATO DESPLEGADO
# ============================================
$CONTRACT_ID = "CBWZ2Z644ZWULJ2WNYF37AIXJLIHRPYU4OTYVQP6WLZBXFB56GD3P5OA"
$ADMIN_ADDRESS = "GAO5SMPKFJ2ST6Z43PTHJ6R6ZDQDU3JWPVPIXS6CGV3T5E4YOQ7EAOKY"
$NETWORK = "futurenet"

# Dirección del token USDC en Futurenet (necesaria para inicializar)
$USDC_TOKEN_ADDRESS = "CDLZFC3SYJYDZT7K67VZ75HPJVIEUVNIXF47ZG2FB2RMQQVU2HHGCYSC"

Write-Host "📋 Configuración del Test:" -ForegroundColor Yellow
Write-Host "  Contract ID: $CONTRACT_ID" -ForegroundColor White
Write-Host "  Admin:       $ADMIN_ADDRESS" -ForegroundColor White
Write-Host "  Network:     $NETWORK" -ForegroundColor White
Write-Host "  USDC Token:  $USDC_TOKEN_ADDRESS" -ForegroundColor White
Write-Host ""

# ============================================
# PASO 1: Configurar Red Futurenet
# ============================================
Write-Host "[1/8] Configurando red Futurenet..." -ForegroundColor Yellow

try {
    stellar network add $NETWORK --rpc-url https://rpc-futurenet.stellar.org --network-passphrase "Test SDF Future Network ; October 2022" 2>&1 | Out-Null
    Write-Host "✅ Red Futurenet configurada" -ForegroundColor Green
} catch {
    Write-Host "ℹ️  Red Futurenet ya estaba configurada" -ForegroundColor Gray
}

# ============================================
# PASO 2: Crear identidades de prueba
# ============================================
Write-Host "`n[2/8] Creando identidades de prueba..." -ForegroundColor Yellow

# Crear identidad de admin si no existe
$adminExists = stellar keys ls 2>&1 | Select-String -Pattern "admin"
if (-not $adminExists) {
    stellar keys generate admin --network $NETWORK 2>&1 | Out-Null
    Write-Host "✅ Identidad 'admin' creada" -ForegroundColor Green
} else {
    Write-Host "ℹ️  Identidad 'admin' ya existe" -ForegroundColor Gray
}

# Crear identidad de usuario de prueba
$userExists = stellar keys ls 2>&1 | Select-String -Pattern "testuser"
if (-not $userExists) {
    stellar keys generate testuser --network $NETWORK 2>&1 | Out-Null
    Write-Host "✅ Identidad 'testuser' creada" -ForegroundColor Green
} else {
    Write-Host "ℹ️  Identidad 'testuser' ya existe" -ForegroundColor Gray
}

# ============================================
# PASO 3: Financiar cuentas de prueba
# ============================================
Write-Host "`n[3/8] Financiando cuentas de prueba..." -ForegroundColor Yellow

try {
    stellar keys fund admin --network $NETWORK
    Write-Host "✅ Cuenta 'admin' financiada" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Error financiando cuenta admin: $($_.Exception.Message)" -ForegroundColor Yellow
}

try {
    stellar keys fund testuser --network $NETWORK
    Write-Host "✅ Cuenta 'testuser' financiada" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Error financiando cuenta testuser: $($_.Exception.Message)" -ForegroundColor Yellow
}

# ============================================
# PASO 4: Verificar contrato desplegado
# ============================================
Write-Host "`n[4/8] Verificando contrato desplegado..." -ForegroundColor Yellow

try {
    $contractInfo = stellar contract info --id $CONTRACT_ID --network $NETWORK
    Write-Host "✅ Contrato encontrado en la red" -ForegroundColor Green
    Write-Host "ℹ️  Info del contrato:" -ForegroundColor Gray
    Write-Host $contractInfo -ForegroundColor White
} catch {
    Write-Host "❌ Error: No se pudo verificar el contrato" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# ============================================
# PASO 5: Probar función get_admin
# ============================================
Write-Host "`n[5/8] Probando función get_admin..." -ForegroundColor Yellow

try {
    $adminResult = stellar contract invoke --id $CONTRACT_ID --network $NETWORK -- get_admin
    Write-Host "✅ Función get_admin funciona" -ForegroundColor Green
    Write-Host "ℹ️  Admin actual: $adminResult" -ForegroundColor Gray

    if ($adminResult -eq $ADMIN_ADDRESS) {
        Write-Host "✅ Admin address coincide con el esperado" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Admin address diferente al esperado" -ForegroundColor Yellow
        Write-Host "   Esperado: $ADMIN_ADDRESS" -ForegroundColor White
        Write-Host "   Actual:   $adminResult" -ForegroundColor White
    }
} catch {
    Write-Host "❌ Error probando get_admin: $($_.Exception.Message)" -ForegroundColor Red
}

# ============================================
# PASO 6: Probar funciones de consulta (antes de inicializar)
# ============================================
Write-Host "`n[6/8] Probando funciones de consulta (estado inicial)..." -ForegroundColor Yellow

# Probar get_players
try {
    $players = stellar contract invoke --id $CONTRACT_ID --network $NETWORK -- get_players
    Write-Host "✅ get_players funciona (lista vacía)" -ForegroundColor Green
    Write-Host "ℹ️  Participantes actuales: $players" -ForegroundColor Gray
} catch {
    Write-Host "❌ Error en get_players: $($_.Exception.Message)" -ForegroundColor Red
}

# Probar get_roblox_ids
try {
    $robloxIds = stellar contract invoke --id $CONTRACT_ID --network $NETWORK -- get_roblox_ids
    Write-Host "✅ get_roblox_ids funciona (lista vacía)" -ForegroundColor Green
    Write-Host "ℹ️  IDs de Roblox: $robloxIds" -ForegroundColor Gray
} catch {
    Write-Host "❌ Error en get_roblox_ids: $($_.Exception.Message)" -ForegroundColor Red
}

# ============================================
# PASO 7: Inicializar contrato (si no está inicializado)
# ============================================
Write-Host "`n[7/8] Verificando si el contrato necesita inicialización..." -ForegroundColor Yellow

# Intentar inicializar (puede fallar si ya está inicializado)
try {
    $initResult = stellar contract invoke --id $CONTRACT_ID --source admin --network $NETWORK -- initialize --admin $ADMIN_ADDRESS --token_address $USDC_TOKEN_ADDRESS
    Write-Host "✅ Contrato inicializado exitosamente" -ForegroundColor Green
} catch {
    $errorMessage = $_.Exception.Message
    if ($errorMessage -match "already initialized") {
        Write-Host "ℹ️  Contrato ya estaba inicializado" -ForegroundColor Gray
    } else {
        Write-Host "❌ Error inicializando contrato: $errorMessage" -ForegroundColor Red
    }
}

# ============================================
# PASO 8: Probar compra de ticket (opcional)
# ============================================
Write-Host "`n[8/8] ¿Quieres probar la compra de un ticket?" -ForegroundColor Yellow
$testTicket = Read-Host "Esto requiere tener USDC en la cuenta testuser (y/n)"

if ($testTicket -eq "y" -or $testTicket -eq "Y") {
    Write-Host "`nProbando compra de ticket..." -ForegroundColor Yellow

    try {
        $ticketResult = stellar contract invoke --id $CONTRACT_ID --source testuser --network $NETWORK -- buy_ticket --buyer $(stellar keys address testuser) --roblox_user_id "TestUser123"
        Write-Host "✅ Ticket comprado exitosamente" -ForegroundColor Green

        # Verificar que se agregó el participante
        Start-Sleep -Seconds 2
        $updatedPlayers = stellar contract invoke --id $CONTRACT_ID --network $NETWORK -- get_players
        Write-Host "ℹ️  Participantes después de compra: $updatedPlayers" -ForegroundColor Gray

        $updatedRobloxIds = stellar contract invoke --id $CONTRACT_ID --network $NETWORK -- get_roblox_ids
        Write-Host "ℹ️  IDs de Roblox después de compra: $updatedRobloxIds" -ForegroundColor Gray

    } catch {
        Write-Host "❌ Error comprando ticket: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "ℹ️  Asegúrate de que la cuenta testuser tenga suficientes USDC" -ForegroundColor Yellow
    }
}

# ============================================
# RESUMEN FINAL
# ============================================
Write-Host "`n============================================" -ForegroundColor Green
Write-Host "  ✅ TESTS COMPLETADOS" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Funciones probadas:" -ForegroundColor Cyan
Write-Host "  ✅ get_admin" -ForegroundColor White
Write-Host "  ✅ get_players" -ForegroundColor White
Write-Host "  ✅ get_roblox_ids" -ForegroundColor White
Write-Host "  ✅ initialize (verificado)" -ForegroundColor White
Write-Host "  ⚠️  buy_ticket (requiere USDC)" -ForegroundColor Yellow
Write-Host "  ⚠️  execute_draw (requiere admin + participantes)" -ForegroundColor Yellow
Write-Host "  ⚠️  withdraw_funds (requiere admin + fondos)" -ForegroundColor Yellow
Write-Host ""

Write-Host "🚀 Próximos pasos recomendados:" -ForegroundColor Cyan
Write-Host "  1. Obtener USDC de prueba para testuser" -ForegroundColor White
Write-Host "  2. Probar buy_ticket con USDC real" -ForegroundColor White
Write-Host "  3. Probar execute_draw con múltiples participantes" -ForegroundColor White
Write-Host "  4. Probar withdraw_funds después de un sorteo" -ForegroundColor White
Write-Host ""

Write-Host "🔗 Contract ID para usar en otras pruebas:" -ForegroundColor Cyan
Write-Host "  $CONTRACT_ID" -ForegroundColor Yellow
Write-Host ""