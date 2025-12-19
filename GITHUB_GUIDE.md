# 📚 Guía de GitHub Issues y Actions para LuminaRiff

Esta guía explica cómo usar Issues y GitHub Actions en tu proyecto.

---

## 📋 GitHub Issues - Sistema de Tareas

### ¿Qué Son?

Los **Issues** son como tarjetas de Trello o tickets de Jira, pero integrados directamente en GitHub. Te permiten organizar el trabajo, reportar bugs y planificar features.

### Cómo Crear un Issue

1. Ve a tu repositorio: https://github.com/emolinah/luminariff
2. Click en la pestaña **"Issues"**
3. Click en **"New Issue"**
4. Completa el formulario:
   - **Título**: Breve descripción (ej: "Agregar función de balance")
   - **Descripción**: Detalles del problema/tarea
   - **Labels**: bug, enhancement, documentation, etc.
   - **Assignees**: Asignar a ti mismo u otros colaboradores
   - **Milestone**: Agrupar por versión (v1.0, v2.0, etc.)

### Ejemplos de Issues para LuminaRiff

#### Issue #1: Frontend Development
```markdown
**Título:** 🎨 Desarrollar Frontend con React/Next.js

**Descripción:**
Crear interfaz web para que usuarios interactúen con el smart contract.

**Tareas:**
- [ ] Setup proyecto Next.js + TypeScript
- [ ] Instalar @stellar/stellar-sdk
- [ ] Componente WalletConnect
- [ ] Página principal con lista de rifas
- [ ] Formulario de compra de tickets
- [ ] Panel de administración

**Labels:** enhancement, frontend, high-priority
**Milestone:** v1.0 - MVP
```

#### Issue #2: Security Improvement
```markdown
**Título:** 🔒 Agregar validación de balance en withdraw_funds

**Descripción:**
La función `withdraw_funds()` en src/lib.rs:232 no valida que el
contrato tenga suficiente balance antes de intentar retirar.

**Solución:**
Agregar check de balance con `token_client.balance()` antes de transferir.

**Labels:** bug, security, critical
**Milestone:** v0.2 - Security Patches
```

#### Issue #3: Roblox Integration
```markdown
**Título:** 🔗 Integrar API de Roblox para entrega de skins

**Descripción:**
Necesitamos conectar con la API de Roblox para entregar automáticamente
los skins al ganador después del sorteo.

**Investigar:**
- API de Roblox para transferencia de items
- Autenticación necesaria
- Rate limits

**Labels:** enhancement, integration, research
**Milestone:** v1.5 - Automation
```

### Labels Recomendados

Crea estos labels en tu repositorio:

| Label | Color | Uso |
|-------|-------|-----|
| `bug` 🐛 | #d73a4a (rojo) | Errores del código |
| `enhancement` ✨ | #a2eeef (azul claro) | Nuevas features |
| `documentation` 📝 | #0075ca (azul) | Mejorar docs |
| `security` 🔒 | #ee0701 (rojo oscuro) | Vulnerabilidades |
| `frontend` 🎨 | #bfdadc (verde agua) | Trabajo de UI |
| `smart-contract` ⚙️ | #fbca04 (amarillo) | Código Soroban |
| `good first issue` 🌱 | #7057ff (púrpura) | Fácil para nuevos |
| `help wanted` 🆘 | #008672 (verde) | Necesita ayuda |

### Cerrar Issues Automáticamente

En tus commits, usa palabras clave:

```bash
git commit -m "fix: Add balance validation in withdraw_funds

This adds a check to ensure the contract has sufficient balance
before attempting to withdraw.

Fixes #2"
```

Cuando hagas push, GitHub automáticamente cerrará el Issue #2.

**Palabras clave que funcionan:**
- `fixes #N`
- `closes #N`
- `resolves #N`

---

## ⚙️ GitHub Actions - Automatización CI/CD

### ¿Qué Son?

**GitHub Actions** es un sistema que ejecuta tareas automáticamente cuando ocurren eventos en tu repositorio (push, PR, etc.).

### Cómo Funciona

```
📝 Push código → ⚡ Trigger → 🤖 GitHub Actions → ✅ Tests/Build/Deploy
```

### Tu Workflow Actual: `rust-ci.yml`

Ya configuramos un workflow que se ejecuta automáticamente en cada push y PR.

**Lo que hace:**

1. **🦀 Setup Rust** - Instala Rust y herramientas
2. **📝 Check Format** - Verifica que el código esté formateado correctamente
3. **🔍 Clippy Linter** - Busca errores comunes y malas prácticas
4. **🏗️ Build** - Compila el WASM
5. **🧪 Run Tests** - Ejecuta todos los tests
6. **📦 Upload WASM** - Guarda el binario compilado (puedes descargarlo)
7. **🔒 Security Audit** - Escanea vulnerabilidades en dependencias

### Cómo Ver los Resultados

1. Ve a tu repositorio en GitHub
2. Click en la pestaña **"Actions"**
3. Verás una lista de todas las ejecuciones:
   ```
   ✅ Rust CI - docs: Add main README (#3548587)
   ✅ Rust CI - Initial commit (#90d2733)
   ```
4. Click en cualquier ejecución para ver los detalles

### Badges en el README

Puedes agregar badges que muestran el estado del build:

```markdown
![CI Status](https://github.com/emolinah/luminariff/workflows/Rust%20CI/badge.svg)
```

Esto mostrará:
- ✅ Verde = Tests pasando
- ❌ Rojo = Tests fallando
- 🟡 Amarillo = En ejecución

### Workflows Adicionales que Podrías Crear

#### 1. Auto-Deploy a Testnet
```yaml
name: Deploy to Testnet

on:
  push:
    tags:
      - 'v*'  # Se ejecuta cuando creas un tag como v1.0

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Stellar CLI
        run: |
          # Instalar Stellar CLI
      - name: Deploy Contract
        env:
          STELLAR_SECRET: ${{ secrets.STELLAR_ADMIN_SECRET }}
        run: |
          stellar contract deploy --wasm target/...
```

#### 2. Generar Documentación Automática
```yaml
name: Generate Docs

on:
  push:
    branches: [ main ]

jobs:
  docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Generate cargo docs
        run: cd luminariff-contract && cargo doc --no-deps
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./luminariff-contract/target/doc
```

#### 3. Scheduled Security Scan (cada semana)
```yaml
name: Weekly Security Scan

on:
  schedule:
    - cron: '0 0 * * 0'  # Cada domingo a medianoche

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Cargo Audit
        run: |
          cargo install cargo-audit
          cargo audit
```

### Límites de GitHub Actions

**Plan Free:**
- ✅ 2,000 minutos/mes de ejecución (suficiente para proyectos pequeños)
- ✅ Workflows ilimitados
- ✅ Repositorios públicos: minutos ilimitados

**Tu uso estimado:**
- 1 push = ~3 minutos de ejecución
- Con 100 pushes/mes = 300 minutos (bien dentro del límite)

---

## 🎯 Plan de Acción para LuminaRiff

### Semana 1: Organización
1. Crear 5-10 issues para organizar el trabajo pendiente
2. Asignar labels y milestones
3. Verificar que el workflow de CI funcione

### Semana 2-3: Desarrollo
1. Trabajar en los issues uno por uno
2. Crear branches para cada feature: `git checkout -b feature/frontend`
3. Hacer commits con referencias a issues: `git commit -m "feat: Add wallet connect (see #1)"`
4. Ver que los tests pasen en Actions antes de merge

### Semana 4: Release
1. Cerrar todos los issues del milestone v1.0
2. Crear un release: `git tag v1.0.0 && git push --tags`
3. Publicar en GitHub Releases con notas de la versión

---

## 📊 Ejemplo de Workflow Completo

```
1. Creas Issue #5: "Agregar función get_contract_balance"
   ↓
2. Creas branch: git checkout -b feature/get-balance
   ↓
3. Escribes el código en src/lib.rs
   ↓
4. Commit: git commit -m "feat: Add get_contract_balance function (#5)"
   ↓
5. Push: git push origin feature/get-balance
   ↓
6. GitHub Actions ejecuta automáticamente:
   - ✅ Compila
   - ✅ Tests pasan
   - ✅ Linter OK
   ↓
7. Creas Pull Request hacia main
   ↓
8. Revisas los checks de Actions en el PR
   ↓
9. Merge a main
   ↓
10. Issue #5 se cierra automáticamente
```

---

## 🔗 Enlaces Útiles

- [Documentación de Issues](https://docs.github.com/en/issues)
- [Documentación de Actions](https://docs.github.com/en/actions)
- [Marketplace de Actions](https://github.com/marketplace?type=actions)
- [Sintaxis de Workflows](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)

---

**Siguiente paso:** Sube estos archivos a GitHub y ve a la pestaña Actions para ver tu primer workflow ejecutándose! 🚀