import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/bloc/notification/notification_bloc.dart';
import 'package:muserpol_pvt/model/user_model.dart';
import 'package:muserpol_pvt/model/biometric_user_model.dart';
import 'package:muserpol_pvt/database/db_provider.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:muserpol_pvt/screens/list_services_menu/list_service.dart';
import 'package:provider/provider.dart';

class TestLoginScreen extends StatefulWidget {
  const TestLoginScreen({super.key});

  @override
  State<TestLoginScreen> createState() => _TestLoginScreenState();
}

class _TestLoginScreenState extends State<TestLoginScreen> {
  final TextEditingController _ciController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Mapeo de cédulas de prueba a datos de usuarios reales
  // Puedes agregar más usuarios aquí según necesites
  final Map<String, Map<String, dynamic>> _testUsers = {
    '5369': {
      'fullName': 'SANTOS SIMON LAURA	MAMANI',
      'affiliateId': 5369,
      'kinship': 'TITULAR',
      'degree': 'SUBOFICIAL PRIMERO',
      'category': '85%',
      'pensionEntity': 'MUSERPOL',
      'isPolice': true,
      'isEconomicComplement': true,
      'enrolled': true,
      'isDoblePerception': false,
      'messageEcoCom': '',
      'verified': true,
      'apiToken': '3e599c7c36a6d3021e17a2e8b9c1e732c25265738ed0e40136f81a6fe8c09348',
    },
    '2114': {
      'fullName': 'MARIA GOMEZ SANCHEZ',
      'affiliateId': 2114,
      'kinship': 'TITULAR',
      'degree': 'SARGENTO',
      'category': '100%',
      'pensionEntity': 'MUSERPOL',
      'isPolice': false,
      'isEconomicComplement': true,
      'enrolled': true,
      'isDoblePerception': false,
      'messageEcoCom': '',
      'verified': true,
      'apiToken': 'abf5085b10bcfad26f2920e1f1d5e1ca9a271a552088849ca8ce65fa290e430d',
    },
  };

  @override
  void dispose() {
    _ciController.dispose();
    super.dispose();
  }

  void _loginTest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Simular delay de login
      await Future.delayed(const Duration(milliseconds: 800));

      final ci = _ciController.text.trim();
      
      // Buscar el usuario en el mapeo de prueba
      Map<String, dynamic>? userData = _testUsers[ci];
      
      // Token a usar (específico del usuario o genérico)
      String apiToken;
      
      // Si no se encuentra en el mapeo, usar datos genéricos
      if (userData == null) {
        apiToken = 'test_token_${ci}_${DateTime.now().millisecondsSinceEpoch}';
        userData = {
          'fullName': 'USUARIO DE PRUEBA - $ci',
          'affiliateId': int.tryParse(ci) ?? 9999,
          'kinship': 'TITULAR',
          'degree': 'CABO',
          'category': '85%',
          'pensionEntity': 'MUSERPOL',
          'isPolice': true,
          'isEconomicComplement': true,
          'enrolled': true,
          'isDoblePerception': false,
          'messageEcoCom': '',
          'verified': true,
        };
      } else {
        // Usar el token específico del usuario
        apiToken = userData['apiToken'] as String;
      }

      // Inicializar la base de datos
      await DBProvider.db.database;

      // Crear usuario con los datos del mapeo o genéricos
      final testUser = User(
        identityCard: ci,
        fullName: userData['fullName'],
        kinship: userData['kinship'],
        affiliateId: userData['affiliateId'],
        isEconomicComplement: userData['isEconomicComplement'],
        enrolled: userData['enrolled'],
        degree: userData['degree'],
        category: userData['category'],
        pensionEntity: userData['pensionEntity'],
        isPolice: userData['isPolice'],
        isDoblePerception: userData['isDoblePerception'],
        messageEcoCom: userData['messageEcoCom'],
        verified: userData['verified'],
      );

      // Actualizar el BLoC con el usuario de prueba
      if (!mounted) return;
      context.read<UserBloc>().add(UpdateUser(testUser));

      // Crear y guardar el modelo de afiliado para la base de datos
      final affiliateModel = AffiliateModel(idAffiliate: testUser.affiliateId!);
      await DBProvider.db.newAffiliateModel(affiliateModel);

      // Actualizar el bloc de notificaciones con el ID del afiliado
      final notificationBloc = context.read<NotificationBloc>();
      notificationBloc.add(UpdateAffiliateId(testUser.affiliateId!));

      // Guardar el token específico del usuario
      final authService = context.read<AuthService>();
      await authService.writeToken(context, apiToken);
      
      // Guardar los datos del usuario
      final userModel = UserModel(
        apiToken: apiToken,
        user: testUser,
      );
      await authService.writeUser(context, userModelToJson(userModel));
      
      // Crear datos biométricos de prueba
      final biometricUserModel = BiometricUserModel(
        biometricUser: false,
        affiliateId: testUser.affiliateId!,
        userAppMobile: UserAppMobile(
          identityCard: testUser.identityCard!,
          numberPhone: '70000000',
        ),
      );
      await authService.writeBiometric(context, biometricUserModelToJson(biometricUserModel));

      // Navegar al menú principal
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ScreenListService(showTutorial: false),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo/Título
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xff419388),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.security,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Text(
                      'LOGIN DE PRUEBA',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff419388),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Text(
                      'Ingresa tu cédula para acceder al sistema de pruebas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Campo de Cédula de Identidad
                    TextFormField(
                      controller: _ciController,
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z-]')),
                        LengthLimitingTextInputFormatter(15),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Cédula de Identidad',
                        hintText: 'Ej: 12345678',
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: Color(0xff419388),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xff419388),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa tu cédula de identidad';
                        }
                        if (value.trim().length < 4) {
                          return 'La cédula debe tener al menos 4 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Botón de Login
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _loginTest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff419388),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'INGRESAR AL SISTEMA',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Información de prueba
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Modo de Prueba',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Este login es para pruebas. Usa las cédulas 5369 o 2114 para usuarios predefinidos, o cualquier otra para generar un usuario de prueba genérico.',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Versión
                    Text(
                      'Versión de Pruebas 4.1.1',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}