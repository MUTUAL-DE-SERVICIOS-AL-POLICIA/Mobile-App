import 'package:flutter/material.dart';
import 'package:muserpol_pvt/bloc/procedure/procedure_bloc.dart';
import 'package:muserpol_pvt/components/inputs/phone.dart';
import 'package:muserpol_pvt/components/table_row.dart';
import 'package:muserpol_pvt/provider/app_state.dart';
import 'package:provider/provider.dart';

class TabInfoEconomicComplement extends StatefulWidget {
  final TextEditingController phoneCtrl;
  final Function() onEditingComplete;
  const TabInfoEconomicComplement({super.key, required this.phoneCtrl, required this.onEditingComplete});

  @override
  State<TabInfoEconomicComplement> createState() => _TabInfoEconomicComplementState();
}

class _TabInfoEconomicComplementState extends State<TabInfoEconomicComplement> {
  @override
  Widget build(BuildContext context) {
    final procedureBloc = Provider.of<ProcedureBloc>(context, listen: true).state;
    final loadingState = Provider.of<LoadingState>(context, listen: true);
    return procedureBloc.existInfoComplementInfo && loadingState.stateLoadingProcedure
        ? Column(
            children: [
              PhoneNumber(focusState:true,phoneCtrl: widget.phoneCtrl, onEditingComplete: () => widget.onEditingComplete()),
              Table(
                  columnWidths: const {
                    0: FlexColumnWidth(6),
                    1: FlexColumnWidth(0.3),
                    2: FlexColumnWidth(6),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: const TableBorder(
                    horizontalInside: BorderSide(
                      width: 0.5,
                      color: Colors.grey,
                      style: BorderStyle.solid,
                    ),
                  ),
                  children: [for (var item in procedureBloc.economicComplementInfo!.data!.display!) tableInfo(item.key!, Text('${item.value}'))]),
            ],
          )
        : Center(
            child: Image.asset(
            'assets/images/load.gif',
            fit: BoxFit.cover,
            height: 20,
          ));
  }
}
