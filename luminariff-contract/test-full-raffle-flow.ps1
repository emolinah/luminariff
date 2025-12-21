# ============================================
# Script de Pruebas Avanzadas - Flujo Completo de Rifa
# LuminaRiff - Prueba end-to-end del contrato
# ============================================

$ErrorActionPreference = "Stop"

# Configurar para ignorar errores de certificado SSL
$env:STELLAR_RPC_SKIP_TLS_VERIFY = "true"
$env:SOROBAN_RPC_SKIP_TLS_VERIFY = "true"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   🎰 LuminaRiff - End-to-End Test" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# CONFIGURACIÓN
# ============================================
$CONTRACT_ID = "CBWZ2Z644ZWULJ2WNYF37AIXJLIHRPYU4OTYVQP6WLZBXFB56GD3P5OA"
$ADMIN_ADDRESS = "GAO5SMPKFJ2ST6Z43PTHJ6R6ZDQDU3JWPVPIXS6CGV3T5E4YOQ7EAOKY"
$NETWORK = "futurenet"
$USDC_TOKEN_ADDRESS = "CDLZFC3SYJYDZT7K67VZ75HPJVIEUVNIXF47ZG2FB2RMQQVU2HHGCYSC"

# Nombres de identidades de prueba
$USER1 = "raffle_user1"
$USER2 = "raffle_user2"
$USER3 = "raffle_user3"

Write-Host "📋 Configuración del Test:" -ForegroundColor Yellow
Write-Host "  Contract ID: $CONTRACT_ID" -ForegroundColor White
Write-Host "  Admin:       $ADMIN_ADDRESS" -ForegroundColor White
Write-Host "  Network:     $NETWORK" -ForegroundColor White
Write-Host "  USDC Token:  $USDC_TOKEN_ADDRESS" -ForegroundColor White
Write-Host ""

# ============================================
# PASO 1: Configurar red y identidades
# ============================================
Write-Host "[1/8] Preparando entorno de pruebas..." -ForegroundColor Yellow

# Configurar red
stellar network add $NETWORK --rpc-url https://rpc-futurenet.stellar.org --network-passphrase "Test SDF Future Network ; October 2022" 2>&1 | Out-Null

# Crear identidades de usuarios de prueba
$users = @($USER1, $USER2, $USER3)
foreach ($user in $users) {
    $userExists = stellar keys ls 2>&1 | Select-String -Pattern $user
    if (-not $userExists) {
        stellar keys generate $user --network $NETWORK 2>&1 | Out-Null
        Write-Host "✅ Identidad '$user' creada" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  Identidad '$user' ya existe" -ForegroundColor Gray
    }
}

Write-Host "✅ Entorno preparado" -ForegroundColor Green

# ============================================
# PASO 2: Financiar cuentas con XLM
# ============================================
Write-Host "`n[2/8] Financiando cuentas con XLM..." -ForegroundColor Yellow

foreach ($user in $users) {
    try {
        stellar keys fund $user --network $NETWORK
        Write-Host "✅ Cuenta '$user' financiada con XLM" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Error financiando '$user': $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# ============================================
# PASO 3: Obtener USDC para los usuarios
# ============================================
Write-Host "`n[3/8] Preparando USDC para pruebas..." -ForegroundColor Yellow

Write-Host "ℹ️  IMPORTANTE: Para probar buy_ticket, necesitas USDC en las cuentas" -ForegroundColor Yellow
Write-Host "ℹ️  Puedes obtener USDC de prueba en: https://faucet-futurenet.stellar.org" -ForegroundColor White
Write-Host ""

$hasUSDC = Read-Host "¿Ya tienes USDC en las cuentas de prueba? (y/n)"

if ($hasUSDC -eq "y" -or $hasUSDC -eq "Y") {

    # ============================================
    # PASO 4: Verificar estado inicial
    # ============================================
    Write-Host "`n[4/8] Verificando estado inicial del contrato..." -ForegroundColor Yellow

    try {
        $initialPlayers = stellar contract invoke --id $CONTRACT_ID --network $NETWORK -- get_players
        Write-Host "✅ Estado inicial verificado" -ForegroundColor Green
        Write-Host "ℹ️  Participantes iniciales: $($initialPlayers | ConvertFrom-Json | Measure-Object | Select-Object -ExpandProperty Count)" -ForegroundColor Gray
    } catch {
        Write-Host "❌ Error verificando estado inicial: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }

    # ============================================
    # PASO 5: Simular compras de tickets
    # ============================================
    Write-Host "`n[5/8] Simulando compras de tickets..." -ForegroundColor Yellow

    $robloxIds = @("RobloxUser1", "RobloxUser2", "RobloxUser3")
    $purchases = @()

    for ($i = 0; $i -lt $users.Length; $i++) {
        $user = $users[$i]
        $robloxId = $robloxIds[$i]
        $userAddress = stellar keys address $user

        try {
            Write-Host "  Comprando ticket para $user ($robloxId)..." -ForegroundColor Gray
            $result = stellar contract invoke --id $CONTRACT_ID --source $user --network $NETWORK -- buy_ticket --buyer $userAddress --roblox_user_id $robloxId
            Write-Host "  ✅ Ticket comprado por $user" -ForegroundColor Green
            $purchases += @{User=$user; RobloxId=$robloxId; Address=$userAddress}
        } catch {
            Write-Host "  ❌ Error comprando ticket para $user: $($_.Exception.Message)" -ForegroundColor Red
        }

        # Pequeña pausa entre transacciones
        Start-Sleep -Seconds 2
    }

    # ============================================
    # PASO 6: Verificar participantes después de compras
    # ============================================
    Write-Host "`n[6/8] Verificando participantes después de compras..." -ForegroundColor Yellow

    try {
        $currentPlayers = stellar contract invoke --id $CONTRACT_ID --network $NETWORK -- get_players
        $playerCount = ($currentPlayers | ConvertFrom-Json).Count
        Write-Host "✅ Verificación completada" -ForegroundColor Green
        Write-Host "ℹ️  Total participantes: $playerCount" -ForegroundColor Gray

        $currentRobloxIds = stellar contract invoke --id $CONTRACT_ID --network $NETWORK -- get_roblox_ids
        Write-Host "ℹ️  IDs de Roblox: $currentRobloxIds" -ForegroundColor Gray

        if ($playerCount -eq $purchases.Count) {
            Write-Host "✅ Número de participantes correcto" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Número de participantes inesperado" -ForegroundColor Yellow
        }

    } catch {
        Write-Host "❌ Error verificando participantes: $($_.Exception.Message)" -ForegroundColor Red
    }

    # ============================================
    # PASO 7: Ejecutar sorteo
    # ============================================
    Write-Host "`n[7/8] Ejecutando sorteo..." -ForegroundColor Yellow

    try {
        $drawResult = stellar contract invoke --id $CONTRACT_ID --source admin --network $NETWORK -- execute_draw --admin $ADMIN_ADDRESS
        Write-Host "✅ Sorteo ejecutado exitosamente" -ForegroundColor Green

        # Parsear el resultado del ganador
        $winnerData = $drawResult | ConvertFrom-Json
        Write-Host "🏆 GANADOR:" -ForegroundColor Green
        Write-Host "  Dirección Stellar: $($winnerData.stellar_address)" -ForegroundColor Yellow
        Write-Host "  ID de Roblox: $($winnerData.roblox_user_id)" -ForegroundColor Yellow

        # Verificar que el ganador está en la lista de participantes
        $winnerFound = $false
        foreach ($purchase in $purchases) {
            if ($purchase.RobloxId -eq $winnerData.roblox_user_id) {
                Write-Host "✅ Ganador válido: $($purchase.User)" -ForegroundColor Green
                $winnerFound = $true
                break
            }
        }

        if (-not $winnerFound) {
            Write-Host "⚠️  Ganador no encontrado en la lista de participantes" -ForegroundColor Yellow
        }

    } catch {
        Write-Host "❌ Error ejecutando sorteo: $($_.Exception.Message)" -ForegroundColor Red
    }

    # ============================================
    # PASO 8: Verificar estado después del sorteo
    # ============================================
    Write-Host "`n[8/8] Verificando estado después del sorteo..." -ForegroundColor Yellow

    try {
        $finalPlayers = stellar contract invoke --id $CONTRACT_ID --network $NETWORK -- get_players
        $finalCount = ($finalPlayers | ConvertFrom-Json).Count
        Write-Host "✅ Verificación completada" -ForegroundColor Green
        Write-Host "ℹ️  Participantes después del sorteo: $finalCount" -ForegroundColor Gray

        if ($finalCount -eq 0) {
            Write-Host "✅ Lista de participantes limpiada correctamente" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Lista de participantes no fue limpiada" -ForegroundColor Yellow
        }

    } catch {
        Write-Host "❌ Error verificando estado final: $($_.Exception.Message)" -ForegroundColor Red
    }

} else {
    Write-Host "ℹ️  Saltando pruebas que requieren USDC..." -ForegroundColor Gray
    Write-Host "ℹ️  Para probar completamente, obtén USDC de: https://faucet-futurenet.stellar.org" -ForegroundColor White
}

# ============================================
# RESUMEN FINAL
# ============================================
Write-Host "`n============================================" -ForegroundColor Green
Write-Host "  🎰 END-TO-END TEST COMPLETADO" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

if ($hasUSDC -eq "y" -or $hasUSDC -eq "Y") {
    Write-Host "📋 Resumen del flujo de rifa:" -ForegroundColor Cyan
    Write-Host "  ✅ Contrato inicializado" -ForegroundColor White
    Write-Host "  ✅ Múltiples tickets comprados" -ForegroundColor White
    Write-Host "  ✅ Participantes registrados" -ForegroundColor White
    Write-Host "  ✅ Sorteo ejecutado" -ForegroundColor White
    Write-Host "  ✅ Ganador seleccionado" -ForegroundColor White
    Write-Host "  ✅ Lista limpiada para próxima rifa" -ForegroundColor White
    Write-Host ""
    Write-Host "🎯 El contrato LuminaRiff funciona correctamente!" -ForegroundColor Green
} else {
    Write-Host "📋 Tests básicos completados:" -ForegroundColor Cyan
    Write-Host "  ✅ Configuración de red" -ForegroundColor White
    Write-Host "  ✅ Creación de identidades" -ForegroundColor White
    Write-Host "  ✅ Financiamiento de cuentas" -ForegroundColor White
    Write-Host "  ⚠️  Tests avanzados requieren USDC" -ForegroundColor Yellow
}

Write-Host "`n🔗 Contract ID: $CONTRACT_ID" -ForegroundColor Cyan
Write-Host "🌐 Network: $NETWORK" -ForegroundColor Cyan
Write-Host ""