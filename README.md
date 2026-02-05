# PowerShell Windows Optimization & Maintenance Script
# Version: 1.0.0
# -MuRDoKGLC-

## 📋 Descripción
Este script actúa como una herramienta de administrador de sistemas para auditar, actualizar, reparar y optimizar Windows 10 y Windows 11.
Está diseñado para ser SEGURO por defecto: no realizará cambios a menos que se lo indiques explícitamente y siempre funciona en modo simulación (DryRun) si no se desactiva.

## 🚀 Cómo usarlo

1. Abre PowerShell como **Administrador**.
2. Navega a la carpeta donde está el script.

### 🛡️ Modo Auditoría (Recomendado para empezar)
Solo verifica el estado del sistema sin tocar nada.
```powershell
.\Invoke-WindowsMaintenance.ps1 -AuditOnly
```

### 🧪 Modo Simulación (Dry Run)
Simula qué cambios haría si ejecutaras las reparaciones u optimizaciones.
(Activado por defecto si no pones `-DryRun:$false`)
```powershell
.\Invoke-WindowsMaintenance.ps1 -UpdateAll -Harden
```

### 🔥 Modo Real (Aplicar Cambios)
Para aplicar los cambios, debes desactivar explícitamente el modo DryRun.

**Reparar Errores y Actualizar:**
```powershell
.\Invoke-WindowsMaintenance.ps1 -DryRun:$false -FixErrors -UpdateAll
```

**Optimizar y Hardening (Debloat + Seguridad):**
```powershell
.\Invoke-WindowsMaintenance.ps1 -DryRun:$false -Harden
```

**Mantenimiento Completo:**
```powershell
.\Invoke-WindowsMaintenance.ps1 -DryRun:$false -UpdateAll -FixErrors -Harden
```

## ⚙️ Qué hace cada módulo

- **AuditOnly**: Revisa versión de Windows, espacio en disco, estado de Defender y errores recientes en logs.
- **UpdateAll**: Actualiza apps vía Winget y Chocolatey, y busca actualizaciones de Windows Update.
- **FixErrors**: Ejecuta `sfc /scannow`, `DISM`, limpia archivos temporales seguros y resetea componentes de Windows Update si es necesario.
- **Harden**:
  - Elimina bloatware seguro (CandyCrush, Netflix, etc.)
  - Ajusta Telemetría al mínimo (Basic).
  - Pone servicios innecesarios (Xbox, Mapas) en Manual.

## ⚠️ Seguridad
- Crea automáticamente un **Punto de Restauración** antes de aplicar cambios.
- Genera logs detallados en la carpeta `Logs` junto al script.
- No elimina componentes críticos del sistema.
