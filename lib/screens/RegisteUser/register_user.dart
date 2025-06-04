import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muserpol_pvt/components/animate.dart';
import 'package:muserpol_pvt/components/dialog_action.dart';
import 'package:muserpol_pvt/components/paint.dart';

class ScreenRegister extends StatefulWidget {
  @override
  State<ScreenRegister> createState() => _ScreenRegister();
}

class _ScreenRegister extends State<ScreenRegister> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController ciController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          bool exitApp = await _onBackPressed();
          if (exitApp) {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('REGISTRO DE NUEVO USUARIO')),
          body: Stack(
            children: [
              const Formtop(),
              const FormButtom(),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image(
                      image: AssetImage(
                        AdaptiveTheme.of(context).mode.isDark
                            ? 'assets/images/muserpol-logo.png'
                            : 'assets/images/muserpol-logo2.png',
                      ),
                    ),
                    PageView(
                      controller: _pageController,
                      physics: NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      children: [],
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Widget _buildStepCard({
    required String image,
    required String label,
    required Widget input,
    required VoidCallback onNext,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 120),
          SizedBox(height: 20),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          input,
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: onNext,
            child: Text('SIGUIENTE'),
          )
        ],
      ),
    );
  }

  Widget _buildDateField(String hint) {
    return SizedBox(
      width: 80,
      child: TextField(
        decoration: InputDecoration(hintText: hint),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    return await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return ComponentAnimate(
              child: DialogTwoAction(
                  message: '¿Deseas salir de la registrar usuario?',
                  actionCorrect: () =>
                      Navigator.pushNamed(context, 'check_auth'),
                  messageCorrect: 'Salir'));
        });
  }
}
