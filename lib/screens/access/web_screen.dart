import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muserpol_pvt/bloc/notification/notification_bloc.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/components/susessful.dart';
import 'package:muserpol_pvt/database/db_provider.dart';
import 'package:muserpol_pvt/model/biometric_user_model.dart';
import 'package:muserpol_pvt/model/user_model.dart';
import 'package:muserpol_pvt/provider/app_state.dart';
import 'package:muserpol_pvt/screens/list_services_menu/list_service.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Webscreen extends StatefulWidget {
  final String codeVerifier;
  final String initialUrl;

  const Webscreen({
    super.key,
    required this.initialUrl,
    required this.codeVerifier,
  });

  @override
  State<Webscreen> createState() => _WebScreenState();
}

class _WebScreenState extends State<Webscreen> {
  late final WebViewController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) async {
          final url = request.url;

          if (url.startsWith('com.muserpol.pvt:/oauth2redirect')) {
            final uri = Uri.parse(url);
            final code = uri.queryParameters['code'];
            final error = uri.queryParameters['error'];

            if (error != null) {
              debugPrint('Error: $error');
              _closeScreen();
              return NavigationDecision.prevent;
            }

            if (code != null) {
              debugPrint('Authorization code recibido: $code');
              await _handleOAuthCallback(code);
              return NavigationDecision.prevent;
            }
          }

          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  //PROCESO DE AUTENTICACON POR CIUDADANIA DIGITAL

  Future<void> _handleOAuthCallback(String code) async {
    final userBloc = BlocProvider.of<UserBloc>(context, listen: false);
    final notificationBloc =
        BlocProvider.of<NotificationBloc>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final tokenState = Provider.of<TokenState>(context, listen: false);

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      final versionOK = await checkVersion(mounted, context);

      if (!versionOK) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Versión de la app desactualizada.")),
        );
        _closeScreen();
        return;
      }

      final requestBody = {
        'code': code,
        'code_verifier': widget.codeVerifier,
      };

      final response = await serviceMethod(
        mounted,
        context,
        'post',
        requestBody,
        serviceVerificationCode(),
        false,
        true,
      );

      if (response != null) {
        await DBProvider.db.database;

        UserModel user =
            userModelFromJson(json.encode(json.decode(response.body)['data']));

        var username = json.decode(response.body)['user_app']['username'];
        var cellphone = json.decode(response.body)['user_app']['cellphone'];

        await authService.writeAuxtoken(user.apiToken!);
        tokenState.updateStateAuxToken(true);
        await authService.writeUser(context, userModelToJson(user));

        userBloc.add(UpdateUser(user.user!));

        final affiliateModel = AffiliateModel(idAffiliate: user.user!.affiliateId!);
        await DBProvider.db.newAffiliateModel(affiliateModel);

        notificationBloc.add(UpdateAffiliateId(user.user!.affiliateId!));

        initSessionUserApp(
            response,
            UserAppMobile(identityCard: username, numberPhone: cellphone),
            user);

        debugPrint('Validación exitosa');
        if (!mounted) return;
      } else {
        debugPrint('Falló la validación');
        _closeScreen();
      }
    } catch (e) {
      debugPrint("Error inesperado: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error durante la validación.")),
      );
      _closeScreen();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  initSessionUserApp(
      dynamic response, UserAppMobile userApp, UserModel user) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final tokenState = Provider.of<TokenState>(context, listen: false);
    tokenState.updateStateAuxToken(false);

    final biometricUserModel = BiometricUserModel(
      affiliateId: json.decode(response.body)['data']['user']['id'],
    );

    if (!mounted) return;
    await authService.writeBiometric(
        context, biometricUserModelToJson(biometricUserModel));

    if (!mounted) return;
    await authService.writeToken(context, user.apiToken!);

    if (!mounted) return;
    await authService.writeToken(context, user.apiToken!);
    tokenState.updateStateAuxToken(false);

    if (!mounted) return;

    //Ingreso con un "ok" a la aplicacion

    showSuccessful(
      context,
      'Correcto, Autenticacion Exitosa',
      () {
        // Luego de que el mensaje de éxito se cierre, navegamos a la siguiente pantalla
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const ScreenListService(
              showTutorial: true,
            ),
            transitionDuration: const Duration(seconds: 0),
          ),
        );
      },
    );
  }

  void _closeScreen([dynamic result]) {
    if (!mounted) return;
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ciudadanía Digital'),
        backgroundColor: const Color(0xff419388),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha((0.4 * 255).toInt()),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
