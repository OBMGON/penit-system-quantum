# 🎯 GUÍA DE DEMOSTRACIÓN - PENITSYSTEM QUANTUM

**Versión**: 1.0.0 - MVP  
**Fecha**: Diciembre 2024

---

## 🚀 **INICIAR LA DEMOSTRACIÓN**

### **Opción 1: Web (Recomendado)**
```bash
# Ejecutar en Chrome
flutter run -d chrome --web-port 8080

# O usar el script de deploy
./scripts/deploy_web.sh
```

### **Opción 2: iOS Simulator**
```bash
flutter run -d ios
```

### **Opción 3: Android Emulator**
```bash
flutter run -d android
```

---

## 🔐 **CREDENCIALES DE PRUEBA**

### **Usuarios Disponibles**
| Rol | Usuario | Contraseña | Acceso |
|-----|---------|------------|--------|
| **Director General** | `Isacio97` | `1234` | Completo |
| **Jefe de Seguridad** | `seguridad` | `1234` | Seguridad |
| **Funcionario** | `funcionario` | `1234` | Operativo |
| **Médico** | `medico` | `1234` | Médico |
| **Auditor** | `auditor` | `1234` | Auditoría |

---

## 📱 **FLUJO DE DEMOSTRACIÓN**

### **1. 🔐 Pantalla de Login**
- **URL**: `http://localhost:8080` (o puerto asignado)
- **Acción**: Ingresar credenciales de cualquier usuario
- **Demo**: Usar `Isacio97` / `1234` para acceso completo

### **2. 📊 Dashboard Principal**
- **Métricas en tiempo real**
- **Estadísticas de reclusos**
- **Alertas automáticas**
- **Acceso rápido a funciones**

### **3. 👥 Gestión de Reclusos**

#### **A. Registrar Nuevo Recluso**
1. Ir a "Registrar Recluso"
2. Completar formulario con datos de prueba:
   - **Nombre**: Juan Pérez
   - **DIP**: 12345678
   - **Centro**: Malabo Central
   - **Delito**: Robo
   - **Sentencia**: 5 años
3. Subir foto (opcional)
4. Guardar

#### **B. Buscar Recluso**
1. Ir a "Buscar Recluso"
2. Probar diferentes filtros:
   - Por nombre
   - Por DIP
   - Por centro penitenciario
   - Por estado
3. Ver resultados en tiempo real

### **4. 📊 Reportes y Estadísticas**

#### **A. Generar Reporte PDF**
1. Ir a "Reportes"
2. Seleccionar tipo de reporte:
   - Reporte mensual
   - Certificado de recluso
   - Log de auditoría
3. Generar PDF
4. Descargar o imprimir

#### **B. Dashboard de Estadísticas**
- Ver métricas en tiempo real
- Gráficos interactivos
- Filtros por fecha/centro

### **5. 🔍 Auditoría**
1. Ir a "Auditoría"
2. Ver log de todas las acciones
3. Filtrar por usuario/fecha
4. Exportar reportes

---

## 🎯 **FUNCIONALIDADES A DEMOSTRAR**

### **✅ Funcionalidades Core**
- [x] **Login seguro** con roles
- [x] **Registro de reclusos** completo
- [x] **Búsqueda avanzada** con filtros
- [x] **Dashboard** con métricas
- [x] **Generación de PDF** para reportes
- [x] **Auditoría** completa
- [x] **Alertas automáticas**

### **✅ Características Técnicas**
- [x] **Responsive design** (móvil/desktop)
- [x] **PWA** (Progressive Web App)
- [x] **Offline** functionality
- [x] **Encriptación** de datos
- [x] **Performance** optimizado

---

## 📋 **CHECKLIST DE DEMOSTRACIÓN**

### **Login y Autenticación**
- [ ] Login con diferentes roles
- [ ] Validación de credenciales
- [ ] Control de acceso por roles
- [ ] Logout seguro

### **Gestión de Reclusos**
- [ ] Registrar nuevo recluso
- [ ] Buscar recluso existente
- [ ] Editar información
- [ ] Ver historial completo

### **Dashboard y Reportes**
- [ ] Ver métricas en tiempo real
- [ ] Generar reporte PDF
- [ ] Exportar datos
- [ ] Filtrar estadísticas

### **Auditoría y Seguridad**
- [ ] Ver log de auditoría
- [ ] Filtrar por usuario/fecha
- [ ] Exportar reportes
- [ ] Verificar encriptación

### **Performance y UX**
- [ ] Carga rápida (< 3s)
- [ ] Responsive en móvil
- [ ] Navegación intuitiva
- [ ] Feedback visual

---

## 🚨 **POSIBLES PROBLEMAS Y SOLUCIONES**

### **Problema**: App no carga
**Solución**: 
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

### **Problema**: Error de puerto
**Solución**:
```bash
flutter run -d chrome --web-port 8081
```

### **Problema**: PDF no se genera
**Solución**: Verificar permisos de escritura en el directorio

### **Problema**: Imágenes no cargan
**Solución**: Verificar que las imágenes estén en `assets/images/`

---

## 🎉 **CONCLUSIÓN DE LA DEMOSTRACIÓN**

### **Puntos Clave a Destacar**
1. **Sistema completo** y funcional
2. **Multiplataforma** (web, móvil, desktop)
3. **Seguridad avanzada** implementada
4. **Performance optimizado**
5. **UX profesional** y intuitiva

### **Próximos Pasos**
1. **Deploy a producción**
2. **Configurar dominio**
3. **Entrenar usuarios**
4. **Monitoreo y mantenimiento**

---

**PenitSystem Quantum** - Sistema penitenciario de próxima generación 🚀 