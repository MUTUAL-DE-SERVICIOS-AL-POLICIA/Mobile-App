import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:muserpol_pvt/provider/app_state.dart';
import 'package:provider/provider.dart';

class CardObservation extends StatelessWidget {
  const CardObservation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: true);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
          decoration: new BoxDecoration(
            boxShadow: <BoxShadow>[
              new BoxShadow(
                color: Color(0xffffdead),
                blurRadius: 4.0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                        child: Text(
                      json.decode(appState.messageObservation!)['message'],
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                    ))
                  ],
                ),
                if (json
                        .decode(appState.messageObservation!)['data']['display']
                        .length >
                    0)
                  Table(
                      columnWidths: {
                        0: FlexColumnWidth(5),
                        1: FlexColumnWidth(0.3),
                        2: FlexColumnWidth(5),
                      },
                      border: TableBorder(
                        horizontalInside: BorderSide(
                          width: 0.5,
                          color: Colors.grey,
                          style: BorderStyle.solid,
                        ),
                      ),
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        for (var itemx
                            in json.decode(appState.messageObservation!)['data']
                                ['display'])
                          TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 10),
                              child: Text(
                                '${itemx['key']!}',
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Text(':'),
                            itemx['value'] is List
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (var itemy in itemx['value'])
                                        Text('• $itemy')
                                    ],
                                  )
                                : Text('${itemx['value']}'),
                          ]),
                      ]),
              ],
            ),
          )),
    );
  }
}
