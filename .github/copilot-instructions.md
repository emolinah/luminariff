# LuminaRiff Smart Contract - Guías de Codificación para IA

## Resumen del Proyecto
LuminaRiff es un smart contract de Stellar Soroban que implementa un sistema de rifas descentralizadas donde los usuarios compran tickets con USDC para ganar skins de Roblox. Construido con Rust usando Soroban SDK 22.0.0.

## Arquitectura
- **Contrato Único**: Toda la funcionalidad en `luminariff_contract`
- **Claves de Almacenamiento**: Dirección del admin, dirección del token USDC, vector de participantes
- **Estructuras de Datos**: Estructura `Participant` con dirección Stellar e ID de usuario de Roblox
- **Aleatoriedad**: Usa timestamp del ledger + secuencia para selección pseudo-aleatoria del ganador

## Funciones Principales
- `initialize(admin, token_address)`: Configuración única requiriendo autenticación del admin
- `buy_ticket(buyer, roblox_user_id)`: Transfiere 1 USDC, agrega participante
- `get_players()`: Retorna lista completa de participantes
- `get_roblox_ids()`: Retorna solo IDs de Roblox para el frontend
- `execute_draw(admin)`: Sorteo solo para admin, limpia lista de participantes
- `withdraw_funds(admin, amount)`: Retiro de fondos USDC solo para admin

## Flujo de Desarrollo
- **Compilar**: `cd luminariff-contract && stellar contract build`
- **Probar**: `cargo test` (usa Soroban testutils)
- **Desplegar**: `stellar contract deploy --wasm target/wasm32-unknown-unknown/release/luminariff_contract.wasm --source admin --network testnet`
- **Inicializar**: Llamar `initialize` con dirección del admin y dirección del token USDC
- **Interactuar**: Usar `stellar contract invoke` con parámetros específicos

## Patrones Clave
- **Verificaciones de Auth**: `buyer.require_auth()` para compras de tickets, `admin.require_auth()` para funciones de admin
- **Transferencias de Token**: Usar `token::Client` para pagos USDC (1 USDC = 1_0000000 unidades)
- **Eventos**: Emitir eventos `ticket`, `winner`, `withdraw` para seguimiento
- **Manejo de Errores**: Mensajes de pánico personalizados en español para errores amigables al usuario
- **Almacenamiento**: Almacenamiento de instancia para datos del contrato, limpiado después de cada sorteo

## Scripts de PowerShell
- `setup.ps1`: Configuración completa del entorno, generación de claves, financiamiento, compilación, despliegue
- `demo.ps1 -ContractId <ID>`: Demuestra flujo completo de rifa con usuarios de prueba
- Usar `stellar keys generate <name> --network testnet` para identidades
- Usar `stellar keys fund <name> --network testnet` para XLM de prueba

## Problemas Comunes
- El contrato debe inicializarse una vez con dirección válida del token USDC
- Solo el admin puede ejecutar sorteos y retirar fondos
- La lista de participantes se reinicia después de cada sorteo
- Todos los valores monetarios en stroops (1 USDC = 10^7 stroops)

## Pruebas
- Pruebas unitarias en `src/lib.rs` usando Soroban testutils
- Probar inicialización y gestión básica de participantes
- Direcciones mock y clientes de token para pruebas aisladas

## Redes de Despliegue
- **Testnet**: Para desarrollo y pruebas
- **Futurenet**: Para pruebas avanzadas
- Usar `stellar network add <network>` para configurar endpoints RPC