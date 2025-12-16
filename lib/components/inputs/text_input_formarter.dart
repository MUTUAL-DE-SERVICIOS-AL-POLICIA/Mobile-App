import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    String formatted = '';
    if (digits.length <= 3) {
      formatted = '${digits}';
    } else if (digits.length <= 6) {
      formatted = '${digits.substring(0, 3)} ${digits.substring(3)}';
    } else {
      formatted =
          '${digits.substring(0, 3)} ${digits.substring(3, digits.length)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
