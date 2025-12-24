# Instrucciones para Probar las Vistas de Préstamos

## Configuración Actual

He configurado tu aplicación para que use el **login de prueba** en lugar del login normal. Esto te permitirá probar fácilmente las vistas de préstamos.

## Cómo Funciona

1. **Al iniciar la app**: Automáticamente irá al `TestLoginScreen`
2. **Usuarios de prueba disponibles**:
   - **5369**: SANTOS SIMON LAURA MAMANI (Datos completos predefinidos)
   - **2114**: MARIA GOMEZ SANCHEZ (Datos completos predefinidos)
   - **Cualquier otra cédula**: Generará un usuario genérico de prueba

3. **Flujo de navegación**:
   - Login de prueba → Menú principal → Servicios de Préstamos → Modal de evaluación automático

## Archivos Modificados

### `lib/main.dart`
- Agregado import de `clear_test_data.dart`
- Agregada llamada a `clearTestData()` para limpiar datos y forzar login de prueba
- Agregada ruta `'testlogin'`

### `lib/check_auth_screen.dart`
- Cambiado `ScreenNewLogin()` por `TestLoginScreen()` en ambas funciones de navegación

### `lib/navigation_general_pages.dart`
- Modificado para abrir automáticamente el modal de evaluación cuando se accede a préstamos: `ScreenLoansNew(openModalOnInit: true)`

### `lib/clear_test_data.dart` (Nuevo)
- Función para limpiar SharedPreferences y forzar el login de prueba

## Cómo Probar

1. **Ejecuta la aplicación**:
   ```bash
   flutter run
   ```

2. **En el login de prueba**:
   - Ingresa `5369` o `2114` para usuarios predefinidos
   - O cualquier otra cédula para usuario genérico
   - Presiona "INGRESAR AL SISTEMA"

3. **Navegación automática**:
   - Irás al menú principal
   - Toca "SERVICIOS DE PRÉSTAMOS"
   - Se abrirá automáticamente el modal de "Evaluación Referencial"

4. **Probar el flujo completo**:
   - Toca "INICIAR EVALUACIÓN REFERENCIAL"
   - Completa los datos según el tipo de afiliado
   - Configura monto y plazo
   - Ve los documentos requeridos
   - Guarda la evaluación

## Volver al Login Normal

Si quieres volver al login normal, comenta esta línea en `lib/main.dart`:

```dart
// await clearTestData(); // Comentar esta línea
```

Y cambia en `lib/check_auth_screen.dart`:
- `TestLoginScreen()` → `ScreenNewLogin()`

## Usuarios de Prueba Predefinidos

### Usuario 5369 (SANTOS SIMON LAURA MAMANI)
- Tipo: Activo/Pasivo según modalidades
- Token específico: `3e599c7c36a6d3021e17a2e8b9c1e732c25265738ed0e40136f81a6fe8c09348`

### Usuario 2114 (MARIA GOMEZ SANCHEZ)  
- Tipo: Activo/Pasivo según modalidades
- Token específico: `abf5085b10bcfad26f2920e1f1d5e1ca9a271a552088849ca8ce65fa290e430d`

### Usuario Genérico (Cualquier otra cédula)
- Datos generados automáticamente
- Token único generado con timestamp

## Notas Importantes

- Los datos son completamente de prueba y no afectan datos reales
- Las evaluaciones se guardan localmente para testing
- El sistema detecta automáticamente duplicados
- Todas las pantallas están configuradas para el flujo de prueba

¡Ahora puedes probar fácilmente todo el flujo de préstamos sin necesidad de autenticación real!