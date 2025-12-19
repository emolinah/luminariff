# 🚀 Guía de Despliegue con GitHub Actions

Esta guía te muestra cómo desplegar tu smart contract LuminaRiff a Stellar Futurenet usando GitHub Actions, evitando problemas de certificados SSL en Windows.

---

## ✅ DEPLOYMENT COMPLETADO EXITOSAMENTE

**El contrato LuminaRiff ya está desplegado en Futurenet** mediante el sistema automático de GitHub Actions.

### 📋 Información del Contrato Desplegado

| Propiedad | Valor |
|-----------|-------|
| **Estado** | ✅ Desplegado |
| **Contract ID** | `CBWZ2Z644ZWULJ2WNYF37AIXJLIHRPYU4OTYVQP6WLZBXFB56GD3P5OA` |
| **Red** | Futurenet |
| **Admin Address** | `GAO5SMPKFJ2ST6Z43PTHJ6R6ZDQDU3JWPVPIXS6CGV3T5E4YOQ7EAOKY` |
| **Fecha** | 19 de diciembre de 2025 |
| **Versión** | v0.1.3 |
| **Workflow Run** | [Ver en GitHub](https://github.com/emolinah/luminariff/actions/runs/20384041068) |

### 🧪 Probar el Contrato

```powershell
# Configurar Futurenet
stellar network add futurenet --rpc-url https://rpc-futurenet.stellar.org --network-passphrase "Test SDF Future Network ; October 2022"

# Verificar contrato
stellar contract info --id CBWZ2Z644ZWULJ2WNYF37AIXJLIHRPYU4OTYVQP6WLZBXFB56GD3P5OA --network futurenet

# Ver participantes actuales
stellar contract invoke --id CBWZ2Z644ZWULJ2WNYF37AIXJLIHRPYU4OTYVQP6WLZBXFB56GD3P5OA --network futurenet -- get_roblox_ids
```

---

## 📋 Requisitos Previos

1. ✅ Código subido a GitHub
2. ✅ Repositorio: https://github.com/emolinah/luminariff

---

## 🎯 Paso 1: Subir el Workflow a GitHub

El workflow ya está creado en `.github/workflows/deploy-futurenet.yml`.

Sube los cambios a GitHub:

```powershell
cd "C:\Users\exequiel molina\Documents\Proyectos\Luminariff\luminariff"

# Agregar archivos
git add .

# Commit
git commit -m "feat: Add GitHub Actions deployment workflow

- Add automated deployment to Futurenet/Testnet
- Workflow runs on manual trigger
- Avoids SSL certificate issues on Windows
- Saves deployment info as artifact"

# Push
git push
```

---

## 🚀 Paso 2: Ejecutar el Deployment desde GitHub

### Método Visual (Recomendado)

1. **Ve a tu repositorio en GitHub:**
   ```
   https://github.com/emolinah/luminariff
   ```

2. **Click en la pestaña "Actions"**

3. **En el menú izquierdo, click en "Deploy to Futurenet"**

4. **Click en el botón "Run workflow"** (derecha de la pantalla)

5. **Selecciona la red:**
   - `futurenet` (recomendado)
   - `testnet` (si prefieres)

6. **Click en "Run workflow" (verde)**

7. **Espera 2-3 minutos** mientras se ejecuta

8. **Una vez completado:**
   - ✅ Verás un check verde
   - Click en el workflow
   - Verás el **Contract ID** en el summary

---

## 📥 Paso 3: Obtener el Contract ID

### Opción A: Ver en el Summary

1. Click en el workflow completado
2. Scroll abajo hasta "Deployment Successful"
3. Copia el **Contract ID**

### Opción B: Descargar Artifact

1. Click en el workflow completado
2. Scroll abajo hasta "Artifacts"
3. Descarga `deployment-info-futurenet`
4. Abre el archivo `info.txt`

---

## 📝 Paso 4: Inicializar el Contrato

Con el Contract ID obtenido, ejecuta en tu PowerShell local:

```powershell
# Reemplaza CONTRACT_ID con el tuyo
$CONTRACT_ID = "TU_CONTRACT_ID_AQUI"
$ADMIN_ADDRESS = "GDKFOQO2FI4L7CELBHN357Y5S344TBBWYGXDE3PSK54BZWQMDJN74BPW"

# Inicializar (necesitarás una dirección de token USDC)
stellar contract invoke `
  --id $CONTRACT_ID `
  --source admin `
  --network futurenet `
  -- initialize `
  --admin $ADMIN_ADDRESS `
  --token_address USDC_TOKEN_ADDRESS_AQUI
```

---

## 🎬 Ejemplo Completo de Uso

Una vez desplegado e inicializado:

```powershell
# Ver información del contrato
stellar contract invoke `
  --id $CONTRACT_ID `
  --network futurenet `
  -- get_admin

# Ver contador de participantes
stellar contract invoke `
  --id $CONTRACT_ID `
  --network futurenet `
  -- get_participants_count

# Comprar un ticket (requiere USDC)
stellar contract invoke `
  --id $CONTRACT_ID `
  --source admin `
  --network futurenet `
  -- buy_ticket `
  --buyer $ADMIN_ADDRESS `
  --roblox_user_id "TestUser123"
```

---

## 🔍 Troubleshooting

### El workflow falla en "Fund account"

**Solución:** Re-ejecuta el workflow. A veces el friendbot de Stellar está ocupado.

### No veo el Contract ID en el summary

**Solución:**
1. Click en el step "Deploy contract"
2. Expande los logs
3. Busca la línea que empieza con `C` (56 caracteres)

### Quiero desplegar a testnet en lugar de futurenet

**Solución:**
1. Al ejecutar el workflow
2. Selecciona "testnet" en el dropdown
3. Run workflow

---

## 📊 Ventajas de Este Método

✅ **Sin problemas de SSL** - GitHub Actions no tiene problemas de certificados
✅ **Automatizado** - Un click y listo
✅ **Reproducible** - Puedes re-desplegar fácilmente
✅ **Historial** - Guardas registro de cada deployment
✅ **Artifacts** - Descargas la info del deployment

---

## 🎯 Próximos Pasos

Una vez que tengas el Contract ID:

1. ✅ Inicializar el contrato
2. ✅ Crear token USDC de prueba (o usar uno existente en futurenet)
3. ✅ Probar compra de tickets
4. ✅ Ejecutar sorteo de prueba
5. ✅ Documentar para tu video de la Ideatón

---

## 📹 Para tu Video de Ideatón

Puedes mostrar:
- ✅ El código del smart contract
- ✅ La compilación exitosa (GitHub Actions)
- ✅ El deployment automático
- ✅ El Contract ID desplegado en Futurenet
- ✅ Screenshots de GitHub Actions ejecutándose

---

## 🔗 Enlaces Útiles

- **Tu Repositorio:** https://github.com/emolinah/luminariff
- **GitHub Actions:** https://github.com/emolinah/luminariff/actions
- **Stellar Laboratory:** https://laboratory.stellar.org/
- **Futurenet Explorer:** https://stellar.expert/explorer/futurenet

---

¿Necesitas ayuda? Abre un Issue en el repositorio.