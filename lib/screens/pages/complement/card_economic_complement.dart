import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:muserpol_pvt/components/button.dart';
import 'package:muserpol_pvt/components/containers.dart';
import 'package:muserpol_pvt/components/table_row.dart';
import 'package:muserpol_pvt/model/procedure_model.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:muserpol_pvt/utils/save_document.dart';
// import 'package:open_file_safe/open_file_safe.dart';
// import 'package:open_file_safe_plus/open_file_safe_plus.dart';
import 'package:open_filex/open_filex.dart';

class CardEc extends StatefulWidget {
  final Datum? item;
  const CardEc({super.key, this.item});

  @override
  State<CardEc> createState() => _CardEcState();
}

class _CardEcState extends State<CardEc> {
  bool btnAccess = true;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: ContainerComponent(
          color: Colors.transparent,
          child: Container(
              padding: const EdgeInsets.all(5),
              
              child: Row(children: [
                Expanded(
                    child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: (widget.item!.subtitle! != '')
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            widget.item!.title!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: widget.item!.subtitle! != ''
                                ? TextAlign.center
                                : TextAlign.left,
                          ),
                        ),
                        if (widget.item!.subtitle! != '')
                          Flexible(
                            child: Text(
                              widget.item!.subtitle!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w300,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Table(
                        columnWidths: const {
                          0: FlexColumnWidth(5),
                          1: FlexColumnWidth(0.3),
                          2: FlexColumnWidth(5),
                        },
                        border: const TableBorder(
                          horizontalInside: BorderSide(
                            width: 0.5,
                            color: Colors.grey,
                            style: BorderStyle.solid,
                          ),
                        ),
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: [
                          for (var itemx in widget.item!.display!)
                            tableInfo(
                                itemx.key!,
                                itemx.value is List
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          for (var itemy in itemx.value)
                                            Text(
                                              '• $itemy',
                                              style: const TextStyle(
                                                  fontFamily: 'Manrope'),
                                            )
                                        ],
                                      )
                                    : Text(
                                        '${itemx.value}',
                                        style: const TextStyle(
                                            fontFamily: 'Manrope'),
                                      )),
                          if (widget.item!.printable!)
                            tableInfo(
                                'Solicitud de pago',
                                ButtonIconComponent(
                                  stateLoading: !btnAccess,
                                  text: 'Documento PDF',
                                  icon: SvgPicture.asset(
                                    'assets/icons/printer.svg',
                                    height: 30.0,
                                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                  ),
                                  onPressed: () => printDocument(context),
                                ))
                        ])
                  ],
                ))
              ]))),
    );
  }

  printDocument(BuildContext context) async {
    setState(() => btnAccess = false);
    var response = await serviceMethod(mounted, context, 'get', null,
        serviceGetPDFEC(widget.item!.id!), true, true);
    setState(() => btnAccess = true);
    if (response != null) {
      String pathFile = await saveFile(
          'Documents',
          'eco_com_${widget.item!.title!.replaceAll(' ', '_').replaceAll('/', '_').toLowerCase()}.pdf',
          response.bodyBytes);
      await OpenFilex.open(pathFile);
    }
  }
}
