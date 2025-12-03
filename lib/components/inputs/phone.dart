import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_picker/country_picker.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:muserpol_pvt/components/inputs/text_input_formarter.dart';

class PhoneNumber extends StatefulWidget {
  final TextEditingController phoneCtrl;
  final bool focusState;
  final VoidCallback onEditingComplete;
  final ValueChanged<String>? onDialCodeChanged;
  final String initialIso;
  final double pickerWidth;

  const PhoneNumber({
    super.key,
    required this.phoneCtrl,
    required this.onEditingComplete,
    this.focusState = false,
    this.onDialCodeChanged,
    this.initialIso = 'BO',
    this.pickerWidth = 110,
  });

  @override
  State<PhoneNumber> createState() => _PhoneNumberState();
}

class _PhoneNumberState extends State<PhoneNumber> {
  late String _dialCode;
  late Country _country;
  bool cellphoneExt = true;

  final tooltipController = JustTheController();

  @override
  void initState() {
    super.initState();
    _country = Country.parse(widget.initialIso);
    _dialCode = '+${_country.phoneCode}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDialCodeChanged?.call(_dialCode);
    });
  }

  void _openCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryFilter: const [
        'DE',
        'AR',
        'AU',
        'BO',
        'BR',
        'CA',
        'CL',
        'CO',
        'CU',
        'EC',
        'ES',
        'US',
        'FR',
        'GT',
        'IT',
        'MX',
        'NI',
        'NO',
        'PY',
        'PE',
        'PT',
        'UY',
        'VE',
      ],
      onSelect: (c) {
        setState(() {
          _country = c;
          _dialCode = '+${c.phoneCode}';
        });
        widget.onDialCodeChanged?.call(_dialCode);
      },
    );
  }

  Widget _buildPrefix(bool isDark) {
    return InkWell(
      onTap: _openCountryPicker,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _country.flagEmoji,
              style: const TextStyle(fontSize: 20),
            ),
            SizedBox(width: 6.w),
            Text(
              _dialCode,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              width: 2,
              height: 28.h,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Número de teléfono personal:',
              style: TextStyle(
                fontSize: 18.sp,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 6.h),
            TextFormField(
              autofocus: widget.focusState,
              controller: widget.phoneCtrl,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              onEditingComplete: widget.onEditingComplete,
              validator: (text) {
                final value = text ?? '';
                if (value.isEmpty) {
                  return 'Ingrese su número telefónico';
                }
                return null;
              },
              inputFormatters: [
                LengthLimitingTextInputFormatter(11),
                PhoneNumberFormatter(),
              ],
              textAlignVertical: TextAlignVertical.center,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
                color: isDark ? Colors.white : Colors.black,
                fontFamily: 'Poppins',
              ),
              decoration: InputDecoration(
                prefixIcon: cellphoneExt ? _buildPrefix(isDark) : null,
                prefixIconConstraints: cellphoneExt
                    ? BoxConstraints(
                        minWidth: widget.pickerWidth,
                        minHeight: 0,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
