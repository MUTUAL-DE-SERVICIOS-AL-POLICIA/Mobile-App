import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class ButtonComponent extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  final bool stateLoading;
  const ButtonComponent(
      {super.key,
      required this.text,
      required this.onPressed,
      this.stateLoading = false});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        minWidth: 200,
        padding: const EdgeInsets.symmetric(vertical: 19),
        color: AdaptiveTheme.of(context).theme.primaryColor,
        disabledColor: Colors.grey,
        onPressed: onPressed,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          stateLoading
              ? Center(
                  child: Image.asset(
                  'assets/images/load.gif',
                  fit: BoxFit.cover,
                  height: 20,
                ))
              : Text(text,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  )),
        ]));
  }
}

class ButtonIconComponent extends StatelessWidget {
  final Widget icon;
  final String text;
  final Function()? onPressed;
  final bool stateLoading;
  const ButtonIconComponent(
      {super.key,
      required this.icon,
      required this.text,
      required this.onPressed,
      this.stateLoading = false});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: AdaptiveTheme.of(context).theme.primaryColor,
      disabledColor: Colors.grey,
      onPressed: onPressed,
      child: stateLoading
          ? Center(
              child: Image.asset(
              'assets/images/load.gif',
              fit: BoxFit.cover,
              height: 20,
            ))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: icon,
                ),
                const SizedBox(
                  width: 8,
                ),
                Flexible(
                    child: Text(text,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ))),
              ],
            ),
    );
  }
}

class ButtonWhiteComponent extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  const ButtonWhiteComponent(
      {super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MaterialButton(
          onPressed: onPressed,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          )),
    );
  }
}

class ButtonDate extends StatelessWidget {
  final String text;
  final Color? colorText;
  final FontWeight? fontWeight;
  final bool iconState;
  final Function() onPressed;
  const ButtonDate(
      {super.key,
      required this.text,
      required this.onPressed,
      this.iconState = false,
      this.colorText,
      this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        elevation: 0,
        focusElevation: 0,
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: const BorderSide(
              color: Colors.grey,
              width: 2.0,
            )),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(text,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: AdaptiveTheme.of(context).theme.primaryColor,
              )),
        ]));
  }
}

class IconBtnComponent extends StatelessWidget {
  final Function() onPressed;
  final String iconText;
  final Color? iconColor;
  final double? iconSize;
  const IconBtnComponent(
      {super.key,
      required this.onPressed,
      required this.iconText,
      this.iconColor,
      this.iconSize = 30});

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      padding: const EdgeInsets.all(5.0),
      onPressed: () {},
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      elevation: 2.0,
      fillColor: Colors.white,
      shape: const CircleBorder(),
      child: IconButton(
          iconSize: 20,
          icon: SvgPicture.asset(
            iconText,
            height: 40.0,
          ),
          onPressed: () => onPressed()),
    );
  }
}

class Buttontoltip extends StatelessWidget {
  final JustTheController tooltipController;
  final Function(bool) onPressed;
  const Buttontoltip(
      {super.key, required this.tooltipController, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 0,
        right: 0,
        child: JustTheTooltip(
            controller: tooltipController,
            showWhenUnlinked: true,
            barrierDismissible: true,
            isModal: true,
            borderRadius: const BorderRadius.all(Radius.circular(18)),
            content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '¿Cuenta con un carnet alfanumérico?\nEj. 123456-1M',
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ButtonWhiteComponent(
                            text: 'SI', onPressed: () => onPressed(true)),
                        ButtonWhiteComponent(
                            text: 'NO', onPressed: () => onPressed(false)),
                      ],
                    )
                  ],
                )),
            child: Material(
              color: AdaptiveTheme.of(context).theme.primaryColor,
              shape: const CircleBorder(),
              elevation: 0,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.horizontal_rule,
                  color: Colors.white,
                ),
              ),
            )));
  }
}

class NumberComponent extends StatelessWidget {
  final String text;
  final bool iconColor;
  const NumberComponent(
      {super.key, required this.text, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: () {},
      elevation: 2.0,
      fillColor: iconColor ? const Color(0xff419388) : Colors.white,
      shape: const CircleBorder(),
      child: Text(
        text,
        style: TextStyle(color: iconColor ? Colors.white : Colors.black),
      ),
    );
  }
}

class CiudadaniaButtonComponent extends StatelessWidget {
  final bool stateLoading;
  final Function()? onPressed;

  const CiudadaniaButtonComponent({
    super.key,
    this.stateLoading = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 60, 66, 121),
          foregroundColor: Colors.white,
          elevation: 0,
          side: const BorderSide(
              color: Color.fromARGB(255, 255, 255, 255), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: stateLoading ? null : onPressed,
        child: stateLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2B3486)),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo_ciudadania.png',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 20),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ciudadania',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      Text(
                        'Digital',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class BiometricButtonComponent extends StatelessWidget {
  final bool stateLoading;
  final bool enabled;
  final VoidCallback? onPressed;

  const BiometricButtonComponent({
    super.key,
    this.stateLoading = false,
    this.enabled = true,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    
    const activeColor =   Color.fromARGB(255, 71, 96, 207);
    final disabledColor = activeColor.withValues(alpha: 120);

    return SizedBox(
      width: 150,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? activeColor : disabledColor,
          elevation: 0,
          side: const BorderSide(
              color: Color.fromARGB(255, 255, 255, 255), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: (stateLoading || !enabled) ? null : onPressed,
        child: stateLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2B3486)),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/finger.png',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 20),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ingreso',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      Text(
                        'por biometria',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
