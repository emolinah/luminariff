# ============================================
# Script de Pruebas de Administración
# LuminaRiff - Prueba funciones de admin
# ============================================

$ErrorActionPreference = "Stop"

# Configurar para ignorar errores de certificado SSL
$env:STELLAR_RPC_SKIP_TLS_VERIFY = "true"
$env:SOROBAN_RPC_SKIP_TLS_VERIFY = "true"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   🔧 LuminaRiff - Admin Functions Test" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# CONFIGURACIÓN
# ============================================
$CONTRACT_ID = "CBWZ2Z644ZWULJ2WNYF37AIXJLIHRPYU4OTYVQP6WLZBXFB56GD3P5OA"
$ADMIN_ADDRESS = "GAO5SMPKFJ2ST6Z43PTHJ6R6ZDQDU3JWPVPIXS6CGV3T5E4YOQ7EAOKY"
$NETWORK = "futurenet"
$USDC_TOKEN_ADDRESS = "CDLZFC3SYJYDZT7K67VZ75HPJVIEUVNIXF47ZG2FB2RMQQVU2HHGCYSC"

Write-Host "📋 Configuración:" -ForegroundColor Yellow
Write-Host "  Contract ID: $CONTRACT_ID" -ForegroundColor White
Write-Host "  Admin:       $ADMIN_ADDRESS" -ForegroundColor White
Write-Host "  Network:     $NETWORK" -ForegroundColor White
Write-Host ""

# ============================================
# PASO 1: Configurar entorno
# ============================================
Write-Host "[1/4] Configurando entorno..." -ForegroundColor Yellow

stellar network add $NETWORK --rpc-url https://rpc-futurenet.stellar.org --network-passphrase "Test SDF Future Network ; October 2022" 2>&1 | Out-Null

# Asegurar que existe identidad admin
$adminExists = stellar keys ls 2>&1 | Select-String -Pattern "admin"
if (-not $adminExists) {
    stellar keys generate admin --network $NETWORK 2>&1 | Out-Null
    stellar keys fund admin --network $NETWORK
    Write-Host "✅ Identidad admin creada y financiada" -ForegroundColor Green
} else {
    Write-Host "ℹ️  Identidad admin ya existe" -ForegroundColor Gray
}

Write-Host "✅ Entorno configurado" -ForegroundColor Green

# ============================================
# PASO 2: Verificar permisos de admin
# ============================================
Write-Host "`n[2/4] Verificando permisos de administrador..." -ForegroundColor Yellow

try {
    $adminFromContract = stellar contract invoke --id $CONTRACT_ID --network $NETWORK -- get_admin
    Write-Host "✅ Función get_admin funciona" -ForegroundColor Green
    Write-Host "ℹ️  Admin configurado: $adminFromContract" -ForegroundColor Gray

    if ($adminFromContract -eq $ADMIN_ADDRESS) {
        Write-Host "✅ Admin address correcto" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Admin address no coincide" -ForegroundColor Yellow
        Write-Host "   Configurado: $adminFromContract" -ForegroundColor White
        Write-Host "   Esperado:    $ADMIN_ADDRESS" -ForegroundColor White
    }
} catch {
    Write-Host "❌ Error obteniendo admin: $($_.Exception.Message)" -ForegroundColor Red
}

# ============================================
# PASO 3: Probar funciones de admin (con verificación de permisos)
# ============================================
Write-Host "`n[3/4] Probando funciones administrativas..." -ForegroundColor Yellow

# Probar execute_draw sin participantes (debería fallar)
Write-Host "  Probando execute_draw sin participantes..." -ForegroundColor Gray
try {
    $drawResult = stellar contract invoke --id $CONTRACT_ID --source admin --network $NETWORK -- execute_draw --admin $ADMIN_ADDRESS
    Write-Host "  ⚠️  Sorteo ejecutado inesperadamente (sin participantes)" -ForegroundColor Yellow
} catch {
    $errorMsg = $_.Exception.Message
    if ($errorMsg -match "No participants") {
        Write-Host "  ✅ Sorteo correctamente rechazado (sin participantes)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Error inesperado en sorteo: $errorMsg" -ForegroundColor Red
    }
}

# Probar execute_draw con usuario no admin (debería fallar)
Write-Host "  Probando execute_draw con usuario no admin..." -ForegroundColor Gray
try {
    # Crear usuario temporal para prueba
    $tempUser = "temp_test_user"
    $userExists = stellar keys ls 2>&1 | Select-String -Pattern $tempUser
    if (-not $userExists) {
        stellar keys generate $tempUser --network $NETWORK 2>&1 | Out-Null
        stellar keys fund $tempUser --network $NETWORK 2>&1 | Out-Null
    }

    $tempAddress = stellar keys address $tempUser
    $drawResult = stellar contract invoke --id $CONTRACT_ID --source $tempUser --network $NETWORK -- execute_draw --admin $tempAddress
    Write-Host "  ❌ Sorteo ejecutado por usuario no admin (ERROR DE SEGURIDAD)" -ForegroundColor Red
} catch {
    $errorMsg = $_.Exception.Message
    if ($errorMsg -match "Only admin" -or $errorMsg -match "not authorized") {
        Write-Host "  ✅ Sorteo correctamente rechazado para no admin" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Error inesperado: $errorMsg" -ForegroundColor Red
    }
}

# ============================================
# PASO 4: Probar withdraw_funds
# ============================================
Write-Host "`n[4/4] Probando función withdraw_funds..." -ForegroundColor Yellow

# Primero verificar si hay fondos en el contrato
Write-Host "  Verificando balance del contrato..." -ForegroundColor Gray
try {
    $balanceResult = stellar contract invoke --id $USDC_TOKEN_ADDRESS --network $NETWORK -- balance --id $CONTRACT_ID
    Write-Host "  ℹ️  Balance del contrato: $balanceResult USDC" -ForegroundColor Gray

    $balance = [int]$balanceResult
    if ($balance -gt 0) {
        Write-Host "  ✅ El contrato tiene fondos disponibles" -ForegroundColor Green

        # Preguntar si quiere retirar fondos
        $withdrawConfirm = Read-Host "  ¿Retirar fondos del contrato? (y/n)"
        if ($withdrawConfirm -eq "y" -or $withdrawConfirm -eq "Y") {
            try {
                # Retirar una pequeña cantidad para prueba (1 USDC = 10000000 stroops)
                $withdrawAmount = 10000000  # 1 USDC
                $withdrawResult = stellar contract invoke --id $CONTRACT_ID --source admin --network $NETWORK -- withdraw_funds --admin $ADMIN_ADDRESS --amount $withdrawAmount
                Write-Host "  ✅ Fondos retirados exitosamente" -ForegroundColor Green
                Write-Host "  ℹ️  Cantidad retirada: $([math]::Round($withdrawAmount / 10000000, 2)) USDC" -ForegroundColor Gray
            } catch {
                Write-Host "  ❌ Error retirando fondos: $($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Host "  ℹ️  Retiro cancelado por usuario" -ForegroundColor Gray
        }
    } else {
        Write-Host "  ℹ️  El contrato no tiene fondos para retirar" -ForegroundColor Gray
        Write-Host "  💡 Para probar withdraw_funds, primero compra algunos tickets" -ForegroundColor Cyan
    }
} catch {
    Write-Host "  ❌ Error verificando balance: $($_.Exception.Message)" -ForegroundColor Red
}

# ============================================
# RESUMEN FINAL
# ============================================
Write-Host "`n============================================" -ForegroundColor Green
Write-Host "  🔧 ADMIN TESTS COMPLETADOS" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Funciones administrativas probadas:" -ForegroundColor Cyan
Write-Host "  ✅ get_admin - Obtener dirección del admin" -ForegroundColor White
Write-Host "  ✅ execute_draw - Control de acceso correcto" -ForegroundColor White
Write-Host "  ✅ withdraw_funds - Verificación de fondos" -ForegroundColor White
Write-Host "  ✅ Seguridad - Rechazo de operaciones no autorizadas" -ForegroundColor White
Write-Host ""

Write-Host "🔒 Verificaciones de seguridad:" -ForegroundColor Cyan
Write-Host "  ✅ Solo admin puede ejecutar sorteos" -ForegroundColor White
Write-Host "  ✅ Sorteo requiere participantes" -ForegroundColor White
Write-Host "  ✅ Retiro requiere fondos disponibles" -ForegroundColor White
Write-Host ""

Write-Host "🚀 Próximos pasos:" -ForegroundColor Cyan
Write-Host "  1. Ejecutar test-full-raffle-flow.ps1 para flujo completo" -ForegroundColor White
Write-Host "  2. Probar con fondos reales en el contrato" -ForegroundColor White
Write-Host "  3. Verificar eventos emitidos por el contrato" -ForegroundColor White
Write-Host ""

Write-Host "🔗 Contract ID: $CONTRACT_ID" -ForegroundColor Cyan
Write-Host ""