import 'package:shared_preferences/shared_preferences.dart';

/// Función para limpiar datos de prueba y forzar el login de prueba
Future<void> clearTestData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // Limpiar todos los datos relacionados con autenticación
    await prefs.remove('token');
    await prefs.remove('user');
    await prefs.remove('biometric');
    await prefs.remove('first_time'); // También limpiar first_time para forzar el flujo
    
    // Limpiar cualquier otro dato que pueda interferir
    final keys = prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith('auth_') || 
          key.startsWith('user_') || 
          key.contains('login') ||
          key.contains('session')) {
        await prefs.remove(key);
      }
    }
    
    print('✅ Datos de prueba limpiados completamente. La app irá al login de prueba.');
  } catch (e) {
    print('❌ Error limpiando datos de prueba: $e');
  }
}