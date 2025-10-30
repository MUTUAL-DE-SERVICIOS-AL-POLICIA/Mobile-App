import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:muserpol_pvt/components/button.dart';
import 'package:muserpol_pvt/components/containers.dart';
import 'package:muserpol_pvt/model/loan_model.dart';
import 'package:muserpol_pvt/screens/pages/loans_pages/card_expanded.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

class CardLoanNew extends StatefulWidget {
  final InProcess? itemProcess;
  final Color? color;
  final Current? itemCurrent;
  const CardLoanNew(
      {super.key, this.itemProcess, this.color, this.itemCurrent});

  @override
  State<CardLoanNew> createState() => _CardLoanState();
}

class _CardLoanState extends State<CardLoanNew> {
  late ValueNotifier<double> valueNotifier;
  @override
  void initState() {
    super.initState();
    if (widget.itemCurrent != null) {
      valueNotifier = ValueNotifier(widget.itemCurrent!.percentagePaid!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Hero(
          transitionOnUserGestures: true,
          tag: widget.itemProcess != null
              ? widget.itemProcess!.code!
              : widget.itemCurrent!.code!,
          child: Material(
              type: MaterialType.transparency,
              child: ContainerComponent(
                  color: widget.color ??
                      AdaptiveTheme.of(context).theme.scaffoldBackgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        if (widget.itemCurrent != null)
                          Expanded(
                            flex: 1,
                            child: SimpleCircularProgressBar(
                              valueNotifier: valueNotifier,
                              mergeMode: true,
                              animationDuration: 3,
                              progressColors: const [
                                Color(0xff419388),
                              ],
                              onGetText: (double value) {
                                return Text('${value.toInt()}%');
                              },
                            ),
                          ),
                        if (widget.itemCurrent != null)
                          const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.itemProcess != null
                                          ? widget.itemProcess!.stateName!
                                          : widget.itemCurrent!.state!,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: widget.color != null
                                              ? Colors.black
                                              : null),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                  widget.itemProcess != null
                                      ? widget.itemProcess!.code!
                                      : widget.itemCurrent!.code!,
                                  style: widget.color != null
                                      ? const TextStyle(color: Colors.black)
                                      : null),
                              ButtonIconComponent(
                                text: 'DETALLES',
                                onPressed: () => onPressed(context),
                                icon: Container(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )))),
      onTap: () => onPressed(context),
    );
  }

  onPressed(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => CardExpandedNew(
            tag: widget.itemProcess != null
                ? widget.itemProcess!.code!
                : widget.itemCurrent!.code!,
            inProcess: widget.itemProcess,
            itemCurrent: widget.itemCurrent),
      ),
    );
  }
}
