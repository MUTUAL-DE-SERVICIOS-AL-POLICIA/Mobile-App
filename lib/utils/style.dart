import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

ThemeData styleLigth() {
  return ThemeData.light(useMaterial3: true).copyWith(
      floatingActionButtonTheme: ThemeData.light()
          .floatingActionButtonTheme
          .copyWith(
            backgroundColor: const Color(0xff419388),
            splashColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
      dividerTheme: const DividerThemeData(
        color: Color(0xff419388),
      ),
      drawerTheme: ThemeData.dark().drawerTheme.copyWith(
          elevation: 0,
          backgroundColor: const Color(0xfff2f2f2),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
          )),
      inputDecorationTheme: ThemeData.light().inputDecorationTheme.copyWith(
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Color(0xff419388),
              ),
            ),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.grey, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Color(0xff419388),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 2.0,
              ),
            ),
            iconColor: Colors.black,
            errorStyle: TextStyle(fontSize: 15.sp).apply(
              color: Colors.red,
              fontFamily: 'Poppins',
            ),
          ),
      buttonTheme: ThemeData.light().buttonTheme.copyWith(
            padding: const EdgeInsets.all(0),
            splashColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
      textTheme: ThemeData.light()
          .textTheme
          .copyWith(
            bodyLarge:
                TextStyle(color: const Color(0xff21232A), fontSize: 17.sp),
            bodyMedium:
                TextStyle(color: const Color(0xff21232A), fontSize: 17.sp),
            labelLarge: TextStyle(fontSize: 17.sp),
          )
          .apply(
            fontFamily: 'Poppins',
          ),
      primaryTextTheme: ThemeData.light().primaryTextTheme.copyWith(
            bodyLarge: TextStyle(fontSize: 20.sp),
            bodyMedium: TextStyle(fontSize: 20.sp).apply(fontFamily: 'Poppins'),
          ),
      colorScheme: ThemeData.light().colorScheme.copyWith(
            primary: const Color(0xff419388),
            secondary: const Color(0xff419388),
          ),
      primaryColor: const Color(0xff419388),
      cardColor: const Color(0xfff2f2f2),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      // dialogBackgroundColor: const Color(0xfff2f2f2),
      // dialogTheme: ThemeData.light().dialogTheme.copyWith(surfaceTintColor: const Color(0xfff2f2f2)),
      dialogTheme: ThemeData.light().dialogTheme.copyWith(
            backgroundColor: const Color(0xfff2f2f2),
            surfaceTintColor: const Color(0xfff2f2f2),
          ),
      scaffoldBackgroundColor: const Color(0xfff2f2f2),
      primaryColorDark: const Color(0xff21232A),
      iconTheme: const IconThemeData(color: Color(0xff419388)),
      appBarTheme: ThemeData.light().appBarTheme.copyWith(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: const TextStyle(color: Colors.black),
          iconTheme: const IconThemeData(color: Colors.black)));
}

ThemeData styleDark() {
  return ThemeData.dark(useMaterial3: true).copyWith(
      floatingActionButtonTheme: ThemeData.light()
          .floatingActionButtonTheme
          .copyWith(
            backgroundColor: const Color(0xff419388),
            splashColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
      drawerTheme: ThemeData.dark().drawerTheme.copyWith(
          elevation: 0,
          backgroundColor: const Color(0xff132c29),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
          )),
      inputDecorationTheme: ThemeData.light().inputDecorationTheme.copyWith(
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Color(0xff419388)),
            ),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Color(0xffE8EAED)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Color(0xff419388),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 2.0,
              ),
            ),
            iconColor: Colors.white,
            errorStyle: TextStyle(fontSize: 15.sp).apply(
              color: Colors.red,
              fontFamily: 'Poppins',
            ),
          ),
      buttonTheme: ThemeData.dark().buttonTheme.copyWith(
            padding: const EdgeInsets.all(0),
            splashColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
      textTheme: ThemeData.dark()
          .textTheme
          .copyWith(
            bodyLarge: TextStyle(fontSize: 17.sp),
            bodyMedium: TextStyle(fontSize: 17.sp),
            labelLarge: TextStyle(fontSize: 17.sp),
          )
          .apply(
            fontFamily: 'Poppins',
          ),
      primaryTextTheme: ThemeData.dark()
          .primaryTextTheme
          .copyWith(
            bodyLarge: TextStyle(fontSize: 20.sp),
            bodyMedium: TextStyle(fontSize: 20.sp),
          )
          .apply(
            fontFamily: 'Poppins',
          ),
      colorScheme: ThemeData.dark().colorScheme.copyWith(
            primary: const Color(0xff419388),
            secondary: const Color(0xff419388),
          ),
      primaryColor: const Color(0xff419388),
      cardColor: const Color(0xff132c29),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      // dialogBackgroundColor: const Color(0xff132c29),
      // dialogTheme: ThemeData.light()
      //     .dialogTheme
      //     .copyWith(surfaceTintColor: const Color(0xff132c29)),
      dialogTheme: ThemeData.dark().dialogTheme.copyWith(
            backgroundColor:
                const Color(0xff132c29), 
            surfaceTintColor: const Color(0xff132c29),
          ),
      scaffoldBackgroundColor: const Color(0xff132c29),
      primaryColorDark: const Color(0xfff2f2f2),
      iconTheme: const IconThemeData(color: Color(0xff419388)),
      appBarTheme: ThemeData.dark().appBarTheme.copyWith(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: const TextStyle(color: Color(0xfff2f2f2)),
          iconTheme: const IconThemeData(color: Color(0xfff2f2f2))));
}
