# LuminaRiff - Smart Contract de Rifas en Stellar Soroban

![Stellar](https://img.shields.io/badge/Stellar-Soroban-blue)
![Rust](https://img.shields.io/badge/Rust-1.75+-orange)
![License](https://img.shields.io/badge/license-MIT-green)

Proyecto desarrollado para la Ideatón de Stellar. LuminaRiff es una plataforma descentralizada de rifas donde los usuarios pueden comprar tickets con USDC para ganar skins de Roblox.

## Características Principales

- **Compra de Tickets**: Los usuarios pagan 1 USDC por ticket y registran su ID de Roblox
- **Sorteo Aleatorio**: Sistema de selección aleatoria de ganadores usando el timestamp del ledger
- **Transparencia**: Todas las transacciones y participantes son públicos en la blockchain
- **Administración Segura**: Solo el administrador puede ejecutar sorteos y retirar fondos

## Arquitectura del Contrato

### Estructuras de Datos

```rust
struct Participant {
    stellar_address: Address,
    roblox_user_id: String,
}
```

### Funciones Principales

1. **initialize** - Configura el contrato con admin y token USDC
2. **buy_ticket** - Permite comprar un ticket pagando 1 USDC
3. **get_players** - Obtiene lista completa de participantes
4. **get_roblox_ids** - Obtiene solo los IDs de Roblox (para frontend)
5. **execute_draw** - Ejecuta el sorteo y selecciona ganador (solo admin)
6. **withdraw_funds** - Retira fondos del contrato (solo admin)

## Requisitos Previos en Windows 10

### 1. Instalar Rust

```powershell
# Descargar e instalar Rust desde https://rustup.rs/
# O usar winget:
winget install Rustlang.Rustup
```

### 2. Instalar Stellar CLI

```powershell
# Opción 1: Usando winget (recomendado)
winget install --id Stellar.StellarCLI

# Opción 2: Descargar desde GitHub
# https://github.com/stellar/stellar-cli/releases
```

### 3. Agregar Target WASM

```powershell
rustup target add wasm32-unknown-unknown
```

### 4. Verificar Instalación

```powershell
stellar --version
cargo --version
rustc --version
```

## Compilación del Contrato

### Paso 1: Navegar al Directorio

```powershell
cd "C:\Users\exequiel molina\Documents\Proyectos\Luminariff\luminariff\luminariff-contract"
```

### Paso 2: Compilar el Contrato

```powershell
stellar contract build
```

Esto generará el archivo WASM en:
```
target\wasm32-unknown-unknown\release\luminariff_contract.wasm
```

### Paso 3: Optimizar el Contrato (Opcional)

```powershell
stellar contract optimize --wasm target\wasm32-unknown-unknown\release\luminariff_contract.wasm
```

## Despliegue en Testnet

### 🚀 Contrato Ya Desplegado en Futurenet

**El contrato ya está desplegado automáticamente en Futurenet** gracias al sistema de CI/CD con GitHub Actions.

#### 📋 Información del Contrato Desplegado

| Propiedad | Valor |
|-----------|-------|
| **Contract ID** | `CBWZ2Z644ZWULJ2WNYF37AIXJLIHRPYU4OTYVQP6WLZBXFB56GD3P5OA` |
| **Red** | Futurenet (Test SDF Future Network) |
| **Admin Address** | `GAO5SMPKFJ2ST6Z43PTHJ6R6ZDQDU3JWPVPIXS6CGV3T5E4YOQ7EAOKY` |
| **Fecha de Despliegue** | 19 de diciembre de 2025 |
| **Versión** | v0.1.3 |

#### 🧪 Probar el Contrato Desplegado

```powershell
# 1. Configurar Futurenet
stellar network add futurenet `
  --rpc-url https://rpc-futurenet.stellar.org `
  --network-passphrase "Test SDF Future Network ; October 2022"

# 2. Crear identidad de prueba
stellar keys generate testuser --network futurenet
stellar keys fund testuser --network futurenet

# 3. Verificar contrato
stellar contract info --id CBWZ2Z644ZWULJ2WNYF37AIXJLIHRPYU4OTYVQP6WLZBXFB56GD3P5OA --network futurenet

# 4. Ver IDs de Roblox (inicialmente vacío)
stellar contract invoke `
  --id CBWZ2Z644ZWULJ2WNYF37AIXJLIHRPYU4OTYVQP6WLZBXFB56GD3P5OA `
  --network futurenet `
  -- get_roblox_ids
```

### 🔧 Despliegue Manual (Opcional)

Si deseas desplegar tu propia instancia del contrato, sigue estos pasos:

### 1. Configurar Red de Pruebas

```powershell
# Configurar la red testnet
stellar network add testnet `
  --rpc-url https://soroban-testnet.stellar.org:443 `
  --network-passphrase "Test SDF Network ; September 2015"
```

### 2. Crear Identidad (Wallet)

```powershell
# Crear identidad de administrador
stellar keys generate admin --network testnet

# Crear identidad de usuario de prueba
stellar keys generate user1 --network testnet
```

### 3. Obtener Fondos de Prueba

```powershell
# Financiar cuenta de admin
stellar keys fund admin --network testnet

# Financiar cuenta de usuario
stellar keys fund user1 --network testnet
```

### 4. Desplegar el Contrato

```powershell
stellar contract deploy `
  --wasm target\wasm32-unknown-unknown\release\luminariff_contract.wasm `
  --source admin `
  --network testnet
```

**Guarda el Contract ID que se muestra** (ej: `CBGTQW...`)

### 5. Inicializar el Contrato

```powershell
# Reemplaza CONTRACT_ID con tu ID de contrato
# Reemplaza USDC_TOKEN_ADDRESS con la dirección del token USDC en testnet

stellar contract invoke `
  --id CONTRACT_ID `
  --source admin `
  --network testnet `
  -- initialize `
  --admin GADMIN_ADDRESS `
  --token_address USDC_TOKEN_ADDRESS
```

## Uso del Contrato

### Comprar un Ticket

```powershell
stellar contract invoke `
  --id CONTRACT_ID `
  --source user1 `
  --network testnet `
  -- buy_ticket `
  --buyer GUSER1_ADDRESS `
  --roblox_user_id "12345678"
```

### Ver Participantes

```powershell
stellar contract invoke `
  --id CONTRACT_ID `
  --network testnet `
  -- get_players
```

### Ver Solo IDs de Roblox

```powershell
stellar contract invoke `
  --id CONTRACT_ID `
  --network testnet `
  -- get_roblox_ids
```

### Ejecutar Sorteo (Solo Admin)

```powershell
stellar contract invoke `
  --id CONTRACT_ID `
  --source admin `
  --network testnet `
  -- execute_draw `
  --admin GADMIN_ADDRESS
```

### Ver Número de Participantes

```powershell
stellar contract invoke `
  --id CONTRACT_ID `
  --network testnet `
  -- get_participants_count
```

### Retirar Fondos (Solo Admin)

```powershell
# Retirar 10 USDC (10 * 10^7 = 100000000)
stellar contract invoke `
  --id CONTRACT_ID `
  --source admin `
  --network testnet `
  -- withdraw_funds `
  --admin GADMIN_ADDRESS `
  --amount 100000000
```

## Script de Demostración Completo

Crea un archivo `demo.ps1` con el siguiente contenido:

```powershell
# Variables de configuración
$CONTRACT_ID = "TU_CONTRACT_ID_AQUI"
$NETWORK = "testnet"

Write-Host "=== Demo LuminaRiff ===" -ForegroundColor Cyan

# 1. Ver estado inicial
Write-Host "`n1. Consultando participantes iniciales..." -ForegroundColor Yellow
stellar contract invoke --id $CONTRACT_ID --network $NETWORK -- get_participants_count

# 2. Comprar tickets
Write-Host "`n2. Usuario 1 comprando ticket..." -ForegroundColor Yellow
stellar contract invoke `
  --id $CONTRACT_ID `
  --source user1 `
  --network $NETWORK `
  -- buy_ticket `
  --buyer (stellar keys address user1) `
  --roblox_user_id "roblox_player_123"

Write-Host "`n3. Usuario 2 comprando ticket..." -ForegroundColor Yellow
stellar contract invoke `
  --id $CONTRACT_ID `
  --source user2 `
  --network $NETWORK `
  -- buy_ticket `
  --buyer (stellar keys address user2) `
  --roblox_user_id "roblox_player_456"

# 3. Ver participantes
Write-Host "`n4. Consultando todos los participantes..." -ForegroundColor Yellow
stellar contract invoke --id $CONTRACT_ID --network $NETWORK -- get_roblox_ids

# 4. Ejecutar sorteo
Write-Host "`n5. Ejecutando sorteo (solo admin)..." -ForegroundColor Yellow
stellar contract invoke `
  --id $CONTRACT_ID `
  --source admin `
  --network $NETWORK `
  -- execute_draw `
  --admin (stellar keys address admin)

Write-Host "`n=== Demo Completada ===" -ForegroundColor Green
```

## Scripts de Prueba

El proyecto incluye scripts de PowerShell para probar exhaustivamente todas las funcionalidades del contrato desplegado en Futurenet:

### 🧪 test-contract-functions.ps1
Script básico para probar las funciones principales del contrato:
- Verificación de información del contrato desplegado
- Consulta de dirección del administrador
- Verificación de estado de inicialización
- Consulta de participantes e IDs de Roblox
- Verificación de conteo de participantes

```powershell
# Ejecutar pruebas básicas
.\test-contract-functions.ps1
```

### 🎯 test-full-raffle-flow.ps1
Script completo para simular un flujo de rifa end-to-end:
- Configuración de múltiples usuarios de prueba
- Financiamiento de cuentas con XLM y USDC
- Compra de tickets por múltiples participantes
- Verificación de balances y participantes
- Ejecución del sorteo por el administrador
- Validación del ganador y limpieza de la lista

```powershell
# Ejecutar simulación completa de rifa
.\test-full-raffle-flow.ps1
```

### 🔐 test-admin-functions.ps1
Script para probar funciones administrativas y controles de seguridad:
- Verificación de permisos de administrador
- Pruebas de acceso no autorizado (deben fallar)
- Ejecución de sorteos con credenciales correctas
- Pruebas de retiro de fondos
- Validación de controles de seguridad

```powershell
# Ejecutar pruebas de seguridad administrativa
.\test-admin-functions.ps1
```

### 📋 Requisitos para Ejecutar Pruebas

1. **Stellar CLI instalado** y configurado
2. **Acceso a Futurenet** (configurado automáticamente por los scripts)
3. **Fondos de prueba** (XLM y USDC) - obtenidos automáticamente por los scripts
4. **PowerShell** con permisos de ejecución

### 🔄 Flujo de Pruebas Recomendado

```powershell
# 1. Pruebas básicas (sin costos)
.\test-contract-functions.ps1

# 2. Pruebas administrativas (sin costos)
.\test-admin-functions.ps1

# 3. Simulación completa de rifa (requiere USDC)
.\test-full-raffle-flow.ps1
```

**Nota**: Los scripts incluyen prompts interactivos para confirmar operaciones que requieren fondos reales (USDC).

## Ejecutar Tests

```powershell
cargo test
```

## Estructura del Proyecto

```
luminariff-contract/
├── Cargo.toml              # Configuración y dependencias
├── README.md               # Esta documentación
├── src/
│   └── lib.rs             # Código del smart contract
└── target/                # Archivos compilados (generado)
```

## Seguridad

- El contrato verifica la autenticación usando `require_auth()`
- Solo el administrador puede ejecutar sorteos y retirar fondos
- El precio del ticket está fijado en el código (1 USDC)
- La lista de participantes se limpia después de cada sorteo

## Notas para el Video de Pitch

### Comandos Clave a Demostrar

1. **Compilación**:
   ```powershell
   stellar contract build
   ```

2. **Compra de Ticket** (ejemplo funcional):
   ```powershell
   stellar contract invoke --id <CONTRACT_ID> --source user1 --network testnet -- buy_ticket --buyer <USER_ADDRESS> --roblox_user_id "demo_user_123"
   ```

3. **Ver Participantes**:
   ```powershell
   stellar contract invoke --id <CONTRACT_ID> --network testnet -- get_roblox_ids
   ```

4. **Ejecutar Sorteo**:
   ```powershell
   stellar contract invoke --id <CONTRACT_ID> --source admin --network testnet -- execute_draw --admin <ADMIN_ADDRESS>
   ```

### Puntos Técnicos a Destacar

- **Aleatoriedad**: Usa `env.ledger().timestamp()` y `sequence` para generar números aleatorios
- **Eventos**: Emite eventos para tracking (`ticket`, `winner`, `withdraw`)
- **Gas Optimizado**: Perfil de compilación optimizado para reducir tamaño
- **Clean Code**: Comentarios educativos en español
- **Funciones de Vista**: `get_players`, `get_roblox_ids` no requieren auth

## Troubleshooting

### Error: "contract already initialized"
El contrato solo puede inicializarse una vez. Despliega un nuevo contrato o usa el existente.

### Error: "command not found: stellar"
Asegúrate de que Stellar CLI esté instalado y en el PATH de Windows.

### Error al compilar WASM
Verifica que tengas el target instalado:
```powershell
rustup target add wasm32-unknown-unknown
```

## Próximos Pasos

1. Integrar con frontend (React/Next.js)
2. Conectar con API de Roblox para entregar skins automáticamente
3. Implementar múltiples rifas simultáneas
4. Agregar sistema de rewards para compradores frecuentes

## Licencia

MIT License - Ver archivo LICENSE

## Contacto

Proyecto desarrollado para Stellar Ideatón 2024

## Referencias

- [Soroban Documentation](https://soroban.stellar.org/docs)
- [Stellar CLI](https://developers.stellar.org/docs/tools/developer-tools)
- [Rust Book](https://doc.rust-lang.org/book/)
