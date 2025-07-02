import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Servicio de autenticación y almacenamiento seguro
/// Esta clase se encarga de guardar y recuperar tokens, información del usuario
/// y datos del dispositivo de manera segura utilizando `flutter_secure_storage`.
class AuthService extends ChangeNotifier {
  /// Instancia del almacenamiento seguro
  final storage = const FlutterSecureStorage();

  /// Guarda el token principal de sesión, asociado a la versión actual
  Future<void> writeToken(BuildContext context, String token) async {
    await storage.write(
      key: 'tokenv${dotenv.env['version']}',
      value: token,
    );
  }

  /// Recupera el token principal de sesión
  Future<String> readToken() async {
    return await storage.read(key: 'tokenv${dotenv.env['version']}') ?? '';
  }

  /// Guarda un token auxiliar, por ejemplo usado temporalmente antes de iniciar sesión completa
  Future<void> writeAuxtoken(String token) async {
    await storage.write(key: 'auxToken', value: token);
  }

  /// Recupera el token auxiliar
  Future<String> readAuxToken() async {
    return await storage.read(key: 'auxToken') ?? '';
  }

  /// Guarda los datos del usuario autenticado (en formato JSON)
  Future<void> writeUser(BuildContext context, String value) async {
    await storage.write(key: 'user', value: value);
  }

  /// Recupera los datos del usuario (en formato JSON)
  Future<String> readUser() async {
    return await storage.read(key: 'user') ?? '';
  }

  /// Guarda el identificador único del dispositivo
  Future<void> writeDeviceId(String deviceId) async {
    await storage.write(key: 'device_id', value: deviceId);
  }

  /// Recupera el identificador único del dispositivo
  Future<String> readDeviceId() async {
    return await storage.read(key: 'device_id') ?? '';
  }

  /// Elimina los datos de sesión al cerrar sesión del usuario
  Future<void> logout() async {
    await storage.delete(key: 'user');
    await storage.delete(key: 'tokenv${dotenv.env['version']}');
    await storage.delete(key: 'auxToken');
    await storage.delete(key: 'device_id');
  }

  /// Borra absolutamente todo el contenido del almacenamiento seguro
  /// Útil para depuración o reinicio completo de sesión
  Future<void> clearAll() async {
    await storage.deleteAll();
  }

  // Lee si es la primera vez que se abre la app

  Future<String> readFirstTime() async {
    return await storage.read(key: 'firstTime') ?? '';
  }

// Guarda si el usuario tiene activada la autenticación biométrica

  Future<void> writeBiometric(BuildContext context, String value) async {
    await storage.write(key: 'biometric', value: value);
  }

// Lee si la autenticación biométrica está activada

  Future<String> readBiometric() async {
    return await storage.read(key: 'biometric') ?? '';
  }

  // Guarda si es la primera vez que se abre la app (ej. para mostrar onboarding)

  Future<void> writeFirstTime(BuildContext context) async {
    await storage.write(key: 'firstTime', value: 'true');
  }

// Funciones que deberian ser eliminadas (no se usan en el nuevo sistema de login, pero pueden recuperarse si se desea)

// Guarda el estado actual de la app (complemento, oficina virtual, etc.)

  // Future<void> writeStateApp(BuildContext context, String value) async {
  //   await storage.write(key: 'stateApp', value: value);
  // }

// Lee el estado actual de la app

  // Future<String> readStateApp() async {
  //   return await storage.read(key: 'stateApp') ?? '';
  // }

// Guarda el token del backend de Complemento Económico

  Future<void> writeTokenCE(String token) async {
    await storage.write(key: 'token_ce', value: token);
  }

// Lee el token del backend de Complemento Económico

  Future<String> readTokenCE() async {
    return await storage.read(key: 'token_ce') ?? '';
  }
}
