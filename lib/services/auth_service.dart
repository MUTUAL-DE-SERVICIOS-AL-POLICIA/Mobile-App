import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Para leer variables de entorno (.env)
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Para almacenamiento seguro

// AuthService maneja el guardado seguro de datos relacionados con la autenticación
class AuthService extends ChangeNotifier {
  // Instancia del almacenamiento seguro
  final storage = const FlutterSecureStorage();

  // Guarda si el usuario tiene activada la autenticación biométrica
  Future writeBiometric(BuildContext context, String value) async {
    await storage.write(key: 'biometric', value: value);
  }

  // Guarda el estado actual de la app (ej. 'loggedIn', 'onboarding', etc.)
  Future writeStateApp(BuildContext context, String value) async {
    await storage.write(key: 'stateApp', value: value);
    return;
  }

  // Guarda la información del usuario (puede ser un ID, JSON, etc.)
  Future writeUser(BuildContext context, String value) async {
    await storage.write(key: 'user', value: value);
    return;
  }

  // Guarda el token principal de acceso con versión dinámica desde .env
  Future writeToken(BuildContext context, String token) async {
    await storage.write(
      key: 'tokenv${dotenv.env['version']}', // Clave basada en versión
      value: token,
    );
    return;
  }

  // Guarda un token auxiliar (opcional)
  Future writeAuxtoken(String token) async {
    await storage.write(key: 'auxToken', value: token);
    return;
  }

  // Marca que es la primera vez que se abre la app
  Future writeFirstTime(BuildContext context) async {
    await storage.write(key: 'firstTime', value: 'true');
    return;
  }

  // Elimina los datos sensibles al cerrar sesión
  Future logout() async {
    await storage.delete(key: 'user');
    await storage.delete(key: 'tokenv${dotenv.env['version']}');
    await storage.delete(key: 'auxToken');
    await storage.delete(key: 'stateApp');
    return;
  }

  // Lee si la autenticación biométrica está activada
  Future<String> readBiometric() async {
    return await storage.read(key: 'biometric') ?? '';
  }

  // Lee el estado actual de la app
  Future<String> readStateApp() async {
    return await storage.read(key: 'stateApp') ?? '';
  }

  // Lee los datos del usuario
  Future<String> readUser() async {
    return await storage.read(key: 'user') ?? '';
  }

  // Lee el token principal desde el almacenamiento
  Future<String> readToken() async {
    return await storage.read(key: 'tokenv${dotenv.env['version']}') ?? '';
  }

  // Lee el token auxiliar
  Future<String> readAuxToken() async {
    return await storage.read(key: 'auxToken') ?? '';
  }

  // Lee si es la primera vez que se ejecuta la app
  Future<String> readFirstTime() async {
    return await storage.read(key: 'firstTime') ?? '';
  }

  // Guarda el token del backend de Complemento Económico
  Future writeTokenCE(String token) async {
    await storage.write(key: 'token_ce', value: token);
  }

  // Lee el token del backend de Complemento Económico
  Future<String> readTokenCE() async {
    return await storage.read(key: 'token_ce') ?? '';
  }

  //Guarda el Id del dispositivo
  Future writeDeviceId(String deviceId) async {
    await storage.write(key: 'device_id', value: deviceId);
  }

  //Lee el id del device

  Future<String> readDeviceId() async {
    return await storage.read(key: 'device_id') ?? '';
  }
}
