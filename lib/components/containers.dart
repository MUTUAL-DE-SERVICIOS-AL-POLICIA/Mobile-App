import 'package:flutter/material.dart';

class ContainerComponent extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final Color color;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const ContainerComponent({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.color = Colors.transparent,
    this.margin,
    this.padding,
    this.borderRadius = 8.0,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 5),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        border: border ?? Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}
