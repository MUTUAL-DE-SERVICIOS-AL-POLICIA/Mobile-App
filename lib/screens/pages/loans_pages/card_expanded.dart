import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:muserpol_pvt/components/button.dart';
import 'package:muserpol_pvt/components/containers.dart';
import 'package:muserpol_pvt/components/headers.dart';
import 'package:muserpol_pvt/components/table_row.dart';
import 'package:muserpol_pvt/model/loan_model.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:muserpol_pvt/utils/save_document.dart';
import 'package:open_filex/open_filex.dart';

class CardExpandedNew extends StatefulWidget {
  final String tag;
  final InProcess? inProcess;
  final Current? itemCurrent;
  const CardExpandedNew(
      {super.key, required this.tag, this.inProcess, this.itemCurrent});

  @override
  State<CardExpandedNew> createState() => _CardExpandedState();
}

class _CardExpandedState extends State<CardExpandedNew> {
  bool stateLoading = false;
  StepperType stepperType = StepperType.vertical;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent.withValues(alpha: 0.5),
        body: GestureDetector(
          child: Center(
            child: Hero(
                tag: widget.tag,
                child: Material(
                    type: MaterialType.transparency,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ContainerComponent(
                        height: MediaQuery.of(context).size.height / 1.2,
                        width: MediaQuery.of(context).size.width,
                        color: AdaptiveTheme.of(context)
                            .theme
                            .scaffoldBackgroundColor,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                              child: HedersComponent(
                                  title: widget.inProcess != null
                                      ? widget.inProcess!.code!
                                      : widget.itemCurrent!.code!),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Table(
                                              columnWidths: const {
                                                0: FlexColumnWidth(4),
                                                1: FlexColumnWidth(0.3),
                                                2: FlexColumnWidth(6),
                                              },
                                              border: const TableBorder(
                                                horizontalInside: BorderSide(
                                                  width: 0.5,
                                                  color: Colors.grey,
                                                  style: BorderStyle.solid,
                                                ),
                                              ),
                                              defaultVerticalAlignment:
                                                  TableCellVerticalAlignment
                                                      .middle,
                                              children: [
                                                if (widget.inProcess != null)
                                                  tableInfo(
                                                      'Tipo de trámite',
                                                      Text(widget.inProcess!
                                                          .procedureTypeName!)),
                                                if (widget.inProcess != null)
                                                  tableInfo(
                                                      'Modalidad',
                                                      Text(widget.inProcess!
                                                          .procedureModalityName!)),
                                                if (widget.itemCurrent != null)
                                                  tableInfo(
                                                      'Modalidad',
                                                      Text(widget.itemCurrent!
                                                          .procedureModality!)),
                                                if (widget.itemCurrent != null)
                                                  tableInfo(
                                                      'Monto',
                                                      Text(
                                                          '${widget.itemCurrent!.amountRequested!} Bs.')),
                                                if (widget.itemCurrent != null)
                                                  tableInfo(
                                                      'Porcentaje de Interés',
                                                      Text(
                                                          '${widget.itemCurrent!.interest} %')),
                                                if (widget.itemCurrent != null)
                                                  tableInfo(
                                                      'Plazos',
                                                      Text(
                                                          '${widget.itemCurrent!.loanTerm} meses')),
                                                if (widget.itemCurrent != null)
                                                  tableInfo(
                                                      'Tipo de pago',
                                                      Text(widget.itemCurrent!
                                                          .paymentType!)),
                                                if (widget.itemCurrent != null)
                                                  tableInfo(
                                                      'Destino',
                                                      Text(widget.itemCurrent!
                                                          .destinyId!)),
                                                if (widget.itemCurrent != null)
                                                  tableInfo(
                                                      'Apertura',
                                                      Text(DateFormat(
                                                              ' dd, MMMM yyyy ',
                                                              "es_ES")
                                                          .format(widget
                                                              .itemCurrent!
                                                              .requestDate!))),
                                              ]),
                                          if (widget.itemCurrent != null)
                                            !stateLoading
                                                ? Row(
                                                    children: [
                                                      Flexible(
                                                        child:
                                                            ButtonIconComponent(
                                                          text: 'Plan de pagos',
                                                          onPressed: () =>
                                                              getLoanPlan(
                                                                  context,
                                                                  widget
                                                                      .itemCurrent!
                                                                      .id!),
                                                          icon: Container(),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Flexible(
                                                        child:
                                                            ButtonIconComponent(
                                                          text: 'Kardex',
                                                          onPressed: () =>
                                                              getLoanKardex(
                                                                  context,
                                                                  widget
                                                                      .itemCurrent!
                                                                      .id!),
                                                          icon: Container(),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                : Center(
                                                    child: Image.asset(
                                                      'assets/images/load.gif',
                                                      fit: BoxFit.cover,
                                                      height: 15.sp,
                                                    ),
                                                  ),
                                          if (widget.inProcess != null)
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Divider(
                                                    height: 0.03.sh,
                                                    color: Colors.white),
                                                const Text(
                                                    'Ubicación del trámite:',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                          if (widget.inProcess != null)
                                            Center(
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: List.generate(
                                                      widget.inProcess!.flow!
                                                          .length, (index) {
                                                    return Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const Spacer(),
                                                            Expanded(
                                                                flex: 1,
                                                                child: NumberComponent(
                                                                    text:
                                                                        '${index + 1}',
                                                                    iconColor: widget
                                                                            .inProcess!
                                                                            .flow![index]
                                                                            .state!
                                                                        ? true
                                                                        : false)),
                                                            Expanded(
                                                                flex: 2,
                                                                child: Text(widget
                                                                    .inProcess!
                                                                    .flow![
                                                                        index]
                                                                    .displayName!)),
                                                            const Spacer(),
                                                          ],
                                                        ),
                                                        if (index !=
                                                            widget
                                                                    .inProcess!
                                                                    .flow!
                                                                    .length -
                                                                1)
                                                          Row(
                                                            children: [
                                                              const Spacer(),
                                                              const Expanded(
                                                                  flex: 1,
                                                                  child: Center(
                                                                      child: Text(
                                                                          '|'))),
                                                              Expanded(
                                                                  flex: 2,
                                                                  child:
                                                                      Container()),
                                                              const Spacer(),
                                                            ],
                                                          ),
                                                      ],
                                                    );
                                                  })),
                                            )
                                        ])),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  getLoanPlan(BuildContext context, int loanId) async {
    setState(() => stateLoading = true);
    var response = await serviceMethod(
        mounted, context, 'get', null, servicePrintLoans(loanId), true, true);
    setState(() => stateLoading = false);
    if (response != null) {
      String pathFile =
          await saveFile('Loans', 'plandepagos.pdf', response.bodyBytes);
      await OpenFilex.open(pathFile);
    }
  }

  getLoanKardex(BuildContext context, int loanId) async {
    setState(() => stateLoading = true);
    var response = await serviceMethod(
        mounted, context, 'get', null, servicePrintKadex(loanId), true, true);
    setState(() => stateLoading = false);
    if (response != null) {
      String pathFile =
          await saveFile('Loans', 'kardex.pdf', response.bodyBytes);
      await OpenFilex.open(pathFile);
    }
  }
}
