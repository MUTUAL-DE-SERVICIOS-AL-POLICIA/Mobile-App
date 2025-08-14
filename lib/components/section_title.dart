import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SectiontitleComponent extends StatelessWidget {
  final String title;
  final String? subTitle;
  final IconData icon;
  final Function() onTap;
  final bool? stateLoading;
  const SectiontitleComponent(
      {super.key,
      required this.title,
      this.subTitle,
      required this.icon,
      required this.onTap,
      this.stateLoading = false});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 15.sp),
      ),
      subtitle: subTitle != null
          ? Text(
              subTitle!,
            )
          : null,
      trailing: stateLoading!
          ? Image.asset(
              'assets/images/load.gif',
              fit: BoxFit.cover,
              height: 15.sp,
            )
          : Icon(
              icon,
              size: 15.sp,
              color: AdaptiveTheme.of(context).mode.isDark?Colors.white:Colors.black,
            ),
      onTap: onTap,
    );
  }
}

class SectiontitleSwitchComponent extends StatelessWidget {
  final String title;
  final bool valueSwitch;
  final Function(bool) onChangedSwitch;
  const SectiontitleSwitchComponent(
      {super.key,
      required this.title,
      required this.valueSwitch,
      required this.onChangedSwitch});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 15.sp),
      ),
      trailing: CupertinoSwitch(
        activeTrackColor: AdaptiveTheme.of(context).theme.primaryColor,
        value: valueSwitch,
        onChanged: onChangedSwitch,
      ),
    );
  }
}
