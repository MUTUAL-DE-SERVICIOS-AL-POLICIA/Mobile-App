import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InputComponent extends StatelessWidget {
  final IconData? icon;
  final String labelText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final TextEditingController controllerText;
  final List<TextInputFormatter>? inputFormatters;
  final Function() onEditingComplete;
  final Function(String) validator;
  final bool obscureText;
  final Function()? onTap;
  final IconData? iconOnTap;
  final TextCapitalization textCapitalization;
  final Function(String)? onChanged;
  final Function()? onTapInput;
  final bool? stateAutofocus;

  const InputComponent({
    super.key,
    required this.labelText,
    required this.keyboardType,
    required this.textInputAction,
    this.focusNode,
    required this.controllerText,
    this.inputFormatters,
    required this.onEditingComplete,
    required this.validator,
    this.icon,
    this.obscureText = false,
    this.onTap,
    this.iconOnTap,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.onTapInput,
    this.stateAutofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? Colors.white : const Color(0xff419388);
    final focusedBorderColor =
        isDarkMode ? Colors.white70 : const Color(0xff2B807B);

    return TextFormField(
      autofocus: stateAutofocus!,
      textAlignVertical: TextAlignVertical.center,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20.sp,
        color: primaryColor,
        fontFamily: 'Poppins',
      ),
      focusNode: focusNode,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      validator: (text) => validator(text!),
      controller: controllerText,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onTap: onTapInput,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelStyle: TextStyle(
          color: primaryColor,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 18.sp,
        ),
        suffixIcon: iconOnTap != null
            ? InkWell(
                onTap: onTap,
                child: Icon(iconOnTap, color: primaryColor),
              )
            : null,
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: focusedBorderColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 20.w),
      ),
    );
  }
}
