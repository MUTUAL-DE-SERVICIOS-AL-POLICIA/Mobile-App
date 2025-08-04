import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef LetIndexPage = bool Function(int value);

int _currentIndex = 0;

class CurvedNavigationBar extends StatefulWidget {
  final List<CurvedNavigationBarItem> items;
  final int index;
  final ValueChanged<int>? onTap;
  final LetIndexPage letIndexChange;
  final Curve animationCurve;
  final Duration animationDuration;
  final double height;

  CurvedNavigationBar({
    super.key,
    required this.items,
    this.index = 0,
    this.onTap,
    LetIndexPage? letIndexChange,
    this.animationCurve = Curves.easeOut,
    this.animationDuration = const Duration(milliseconds: 600),
    this.height = 68.0,
  })  : letIndexChange = letIndexChange ?? ((_) => true),
        assert(items.isNotEmpty),
        assert(0 <= index && index < items.length),
        assert(0 <= height && height <= height);

  @override
  CurvedNavigationBarState createState() => CurvedNavigationBarState();
}

class CurvedNavigationBarState extends State<CurvedNavigationBar>
    with SingleTickerProviderStateMixin {
  late double _startingPos;
  int _endingIndex = 0;
  late double _pos;
  double _buttonHide = 0;
  late Widget _icon;
  late String _label;
  late AnimationController _animationController;
  late int _length;

  @override
  void initState() {
    super.initState();

    _icon = widget.items[widget.index].icon;
    _label = widget.items[widget.index].label;
    _length = widget.items.length;
    _pos = widget.index / _length;
    _startingPos = widget.index / _length;

    _animationController = AnimationController(vsync: this, value: _pos);
    _animationController.addListener(() {
      setState(() {
        _pos = _animationController.value;
        final endingPos = _endingIndex / widget.items.length;
        final middle = (endingPos + _startingPos) / 2;
        if ((endingPos - _pos).abs() < (_startingPos - _pos).abs()) {
          _icon = widget.items[_endingIndex].icon;
          _label = widget.items[_endingIndex].label;
        }
        _buttonHide =
            (1 - ((middle - _pos) / (_startingPos - middle)).abs()).abs();
      });
    });
  }

  @override
  void didUpdateWidget(CurvedNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      final newPosition = widget.index / _length;
      _startingPos = _pos;
      _endingIndex = widget.index;
      _animationController.animateTo(newPosition,
          duration: widget.animationDuration, curve: widget.animationCurve);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _length = widget.items.length;
    Size size = MediaQuery.of(context).size;

    // Aseguramos que el tamaño de los iconos se ajuste dinámicamente
    // double iconSize = size.width < 600
    //     ? 20.sp
    //     : 25.sp; // Tamaño más pequeño para pantallas pequeñas

    _icon = widget.items[_endingIndex].icon;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Aseguramos que la altura de la barra sea adaptable
          double navBarHeight = constraints.maxHeight > 600
              ? 50.h
              : 40.h; // Menor altura para pantallas pequeñas

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                bottom: -40 - (75.0 - navBarHeight),
                left: Directionality.of(context) == TextDirection.rtl
                    ? null
                    : _pos * size.width,
                right: Directionality.of(context) == TextDirection.rtl
                    ? _pos * size.width
                    : null,
                width: size.width / _length,
                child: Center(
                  child: Transform.translate(
                    offset: Offset(0, -(1 - _buttonHide) * 80),
                    child: Material(
                      color: Theme.of(context).cardColor,
                      type: MaterialType.circle,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _icon,
                      ),
                    ),
                  ),
                ),
              ),
              CustomPaint(
                painter:
                    NavCustomPainter(_pos, _length, Directionality.of(context)),
                child: Container(
                  height: navBarHeight,
                ),
              ),
              Positioned(
                left: Directionality.of(context) == TextDirection.rtl
                    ? null
                    : _pos * size.width,
                right: Directionality.of(context) == TextDirection.rtl
                    ? _pos * size.width
                    : null,
                width: size.width / _length,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      _label,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: navBarHeight,
                child: Row(
                  children: widget.items.map(
                    (item) {
                      return NavButton(
                        onTap: _buttonTap,
                        position: _pos,
                        length: _length,
                        index: widget.items.indexOf(item),
                        height: navBarHeight,
                        child: Center(
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: item.icon,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Text(
                                    item.label,
                                    style: const TextStyle(color: Colors.white),
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  setPage(int index) {
    _buttonTap(index);
  }

  _buttonTap(int index) {
    if (widget.onTap != null) {
      widget.onTap!(index);
    }

    if (_endingIndex != index) {
      if (!widget.letIndexChange(index)) {
        return;
      }

      final newPosition = index / _length;
      setState(() {
        _startingPos = _pos;
        _endingIndex = index;
        _currentIndex = index;
        _animationController.animateTo(newPosition,
            duration: widget.animationDuration, curve: widget.animationCurve);
      });
    }
  }
}

class CurvedNavigationBarItem {
  final Widget icon;
  final String label;

  CurvedNavigationBarItem({required this.icon, required this.label});
}

class NavButton extends StatelessWidget {
  final double position;
  final int length;
  final int index;
  final ValueChanged<int> onTap;
  final Widget child;
  final double height;

  const NavButton({
    super.key,
    required this.onTap,
    required this.position,
    required this.length,
    required this.index,
    required this.child,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final desiredPosition = 1.0 / length * index;
    final difference = (position - desiredPosition).abs();
    final verticalAlignment = 1 - length * difference;
    final opacity = length * difference;

    return Expanded(
      child: _currentIndex != index
          ? InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                onTap(index);
              },
              child: SizedBox(
                height: height,
                child: Transform.translate(
                  offset: Offset(0,
                      difference < 1.0 / length ? verticalAlignment * 40 : 0),
                  child: Opacity(
                      opacity: difference < 1.0 / length * 0.99 ? opacity : 1.0,
                      child: child),
                ),
              ),
            )
          : GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                onTap(index);
              },
              child: SizedBox(
                height: height,
                child: Transform.translate(
                  offset: Offset(0,
                      difference < 1.0 / length ? verticalAlignment * 40 : 0),
                  child: Opacity(
                      opacity: difference < 1.0 / length * 0.99 ? opacity : 1.0,
                      child: child),
                ),
              ),
            ),
    );
  }
}

class NavCustomPainter extends CustomPainter {
  late double loc;
  late double s;
  TextDirection textDirection;

  NavCustomPainter(double startingLoc, int itemsLength, this.textDirection) {
    final span = 1.0 / itemsLength;
    s = 0.2;
    double l = startingLoc + (span - s) / 2;
    loc = textDirection == TextDirection.rtl ? 0.8 - l : l;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xff419388)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo((loc - 0.1) * size.width, 0)
      ..cubicTo(
        (loc + s * 0.20) * size.width,
        size.height * 0.05,
        loc * size.width,
        size.height * 0.60,
        (loc + s * 0.50) * size.width,
        size.height * 0.60,
      )
      ..cubicTo(
        (loc + s) * size.width,
        size.height * 0.60,
        (loc + s - s * 0.20) * size.width,
        size.height * 0.05,
        (loc + s + 0.1) * size.width,
        0,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}
