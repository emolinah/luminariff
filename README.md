# 🎟️ LuminaRiff

![Stellar](https://img.shields.io/badge/Stellar-Soroban-blue)
![Rust](https://img.shields.io/badge/Rust-1.75+-orange)
![License](https://img.shields.io/badge/license-MIT-green)
![Status](https://img.shields.io/badge/status-Stellar%20Ideatón%202024-yellow)

> Plataforma descentralizada de rifas en Stellar Soroban para ganar skins de Roblox

## 📋 Descripción

**LuminaRiff** es un proyecto desarrollado para la **Stellar Ideatón 2024** que combina la transparencia de blockchain con la gamificación. Los usuarios pueden comprar tickets con USDC (stablecoin) para participar en rifas y ganar skins exclusivos de Roblox.

### ✨ Características Principales

- 🎫 **Compra de Tickets**: Pago con USDC (1 USDC = 1 ticket)
- 🎲 **Sorteo Aleatorio**: Selección transparente usando blockchain
- 🔗 **Integración Roblox**: Vinculación directa con ID de usuario
- 🔐 **Seguridad**: Funciones protegidas solo para administradores
- 📊 **Transparencia**: Todas las transacciones públicas en Stellar
- ⚡ **Gas Optimizado**: Smart contract optimizado para eficiencia

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────┐
│                     LUMINARIFF                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────┐         ┌──────────────────┐          │
│  │  Frontend   │◄───────►│  Smart Contract  │          │
│  │ (React/Next)│         │   (Soroban)      │          │
│  └─────────────┘         └────────┬─────────┘          │
│                                   │                     │
│                          ┌────────▼─────────┐           │
│                          │  Stellar Ledger  │           │
│                          │   (Blockchain)   │           │
│                          └──────────────────┘           │
│                                   │                     │
│                          ┌────────▼─────────┐           │
│                          │  Roblox API      │           │
│                          │ (Skin Delivery)  │           │
│                          └──────────────────┘           │
└─────────────────────────────────────────────────────────┘
```

## 🚀 Inicio Rápido

### Paso 1: Verificar Herramientas

Ejecuta el script de verificación:

```powershell
.\check-install.ps1
```

Si ves ❌ (falta alguna herramienta), ve al **Paso 2**.
Si ves ✅ (todo instalado), salta al **Paso 3**.

### Paso 2: Instalar Herramientas (si es necesario)

**Instalación Rápida con Winget:**

```powershell
# Instalar Rust
winget install Rustlang.Rustup

# Cerrar y reabrir PowerShell, luego:
winget install Stellar.StellarCLI

# Agregar target WASM
rustup target add wasm32-unknown-unknown
```

📖 **[Ver guía completa de instalación](INSTALL.md)** para otras opciones

### Paso 3: Compilar el Contrato

```powershell
cd luminariff-contract
stellar contract build
```

**Salida esperada:**
```
✅ Compiling luminariff-contract v0.1.0
✅ Finished release [optimized] target(s)
```

### Documentación Completa

📖 **[Ver documentación del Smart Contract](luminariff-contract/README.md)**

Incluye:
- Guía de instalación detallada
- Instrucciones de compilación
- Ejemplos de uso
- Despliegue en testnet
- Demos interactivas

## 📦 Estructura del Proyecto

```
luminariff/
├── README.md                    # Este archivo
├── .gitignore                   # Archivos ignorados por Git
└── luminariff-contract/         # Smart Contract Soroban
    ├── src/
    │   └── lib.rs              # Código principal del contrato
    ├── Cargo.toml              # Dependencias de Rust
    ├── README.md               # Documentación técnica
    ├── LICENSE                 # Licencia MIT
    ├── demo.ps1                # Script de demostración
    └── setup.ps1               # Wizard de configuración
```

## 🎯 Funcionalidades del Smart Contract

| Función | Descripción | Acceso |
|---------|-------------|--------|
| `initialize()` | Configura admin y token USDC | Una vez |
| `buy_ticket()` | Compra ticket (1 USDC) | Público |
| `get_players()` | Lista de participantes | Público |
| `get_roblox_ids()` | IDs de Roblox | Público |
| `execute_draw()` | Ejecuta sorteo | Admin |
| `withdraw_funds()` | Retira fondos | Admin |
| `get_participants_count()` | Total de tickets | Público |

## 🔐 Seguridad

- ✅ Autenticación con `require_auth()`
- ✅ Funciones protegidas admin-only
- ✅ Validación de pagos (1 USDC exacto)
- ✅ Eventos para auditoría
- ✅ Inicialización única
- ✅ Sin mutabilidad innecesaria

## 🧪 Tests

```powershell
cd luminariff-contract
cargo test
```

## 📹 Demo

```powershell
# Ejecutar demo completa
cd luminariff-contract
.\demo.ps1
```

## 🛣️ Roadmap

- [x] Smart Contract base funcional
- [x] Tests unitarios
- [x] Documentación completa
- [x] Scripts de demostración
- [ ] Frontend React/Next.js
- [ ] Integración con Roblox API
- [ ] Sistema de múltiples rifas simultáneas
- [ ] Sistema de rewards para usuarios frecuentes
- [ ] Despliegue en mainnet

## 👥 Equipo

Proyecto desarrollado para **Stellar Ideatón 2024**

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver archivo [LICENSE](luminariff-contract/LICENSE) para más detalles.

## 🔗 Enlaces

- [Soroban Documentation](https://soroban.stellar.org/docs)
- [Stellar CLI](https://developers.stellar.org/docs/tools/developer-tools)
- [Rust Book](https://doc.rust-lang.org/book/)
- [Stellar Ideatón 2024](https://stellar.org)

## 🙏 Agradecimientos

Gracias a Stellar por organizar la Ideatón y proporcionar las herramientas para construir el futuro descentralizado.

---

<p align="center">
  Hecho con ❤️ para Stellar Ideatón 2024
</p>