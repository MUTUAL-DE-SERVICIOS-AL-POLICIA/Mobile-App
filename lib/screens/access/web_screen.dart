import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muserpol_pvt/bloc/notification/notification_bloc.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/database/db_provider.dart';
import 'package:muserpol_pvt/model/biometric_user_model.dart';
import 'package:muserpol_pvt/model/user_model.dart';
import 'package:muserpol_pvt/provider/app_state.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:muserpol_pvt/utils/auth_helpers.dart';
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
              await _handleOAuthCallback(code);
              return NavigationDecision.prevent;
            }
          }

          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  Future<void> _handleOAuthCallback(String code) async {
    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      final requestBody = {
        'isCitizenshipDigital': true,
        'citizenshipDigitalCode': code,
        'citizenshipDigitalCodeVerifier': widget.codeVerifier,
      };

      final response = await serviceMethod(
        mounted,
        context,
        'post',
        requestBody,
        loginAppMobile(),
        false,
        true,
      );

      if (response == null) {
        _closeScreen();
        return;
      }

      final jsonResponse = json.decode(response.body);

      if (jsonResponse['error'] == true &&
          jsonResponse.containsKey('logoutUrl')) {
        final String message =
            jsonResponse['message'] ?? 'Sesión finalizada por seguridad';

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        final logoutUrl = jsonResponse['logoutUrl'];
        await _controller.loadRequest(Uri.parse(logoutUrl));

        await Future.delayed(const Duration(seconds: 1));

        _closeScreen();
        return;
      }

      if (jsonResponse['error'] == false &&
          jsonResponse.containsKey('logoutUrl')) {
        final authService = Provider.of<AuthService>(context, listen: false);
        final tokenState = Provider.of<TokenState>(context, listen: false);
        final notificationBloc =
            BlocProvider.of<NotificationBloc>(context, listen: false);
        final userBloc = BlocProvider.of<UserBloc>(context, listen: false);

        await DBProvider.db.database;

        UserModel user = UserModel.fromJson({
          "api_token": jsonResponse['data']['apiToken'],
          "user": jsonResponse['data']['information']
        });

        await authService.writeAuxtoken(user.apiToken!);
        tokenState.updateStateAuxToken(true);

        if (!mounted) return;

        await authService.writeUser(context, userModelToJson(user));
        userBloc.add(UpdateUser(user.user!));

        final affiliateModel =
            AffiliateModel(idAffiliate: user.user!.affiliateId!);
        await DBProvider.db.newAffiliateModel(affiliateModel);
        notificationBloc.add(UpdateAffiliateId(user.user!.affiliateId!));
        final logoutUrl = jsonResponse['logoutUrl'];

        await _controller.loadRequest(Uri.parse(logoutUrl));

        if (!mounted) return;
        await AuthHelpers.initSessionUserApp(
          context: context,
          response: response,
          userApp: UserAppMobile(
              identityCard: jsonResponse['data']['information']['identityCard'],
              numberPhone: jsonResponse['data']['information']['cellphone']),
          user: user,
        );
        return;
      }
    } catch (e) {
      debugPrint("Error inesperado: $e");
      _closeScreen();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              color: Colors.black87,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
