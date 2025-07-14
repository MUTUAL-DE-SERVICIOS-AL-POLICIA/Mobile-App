import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muserpol_pvt/bloc/procedure/procedure_bloc.dart';
import 'package:muserpol_pvt/model/procedure_model.dart';
import 'package:muserpol_pvt/screens/pages/complement/card_economic_complement.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';

class ScreenHistoryComplement extends StatefulWidget {
  const ScreenHistoryComplement({super.key});

  @override
  State<ScreenHistoryComplement> createState() =>
      _ScreenHistoryComplementState();
}

class _ScreenHistoryComplementState extends State<ScreenHistoryComplement> {
  final ScrollController _scrollController = ScrollController();

  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !_isLoading &&
          _hasMore) {
        _fetchHistory();
      }
    });
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);

    final response = await serviceMethod(
      mounted,
      context,
      'get',
      null,
      serviceGetEconomicComplements(_page, false),
      true,
      true,
    );

    if (response != null) {
      final data = procedureModelFromJson(response.body);
      final List<Datum> newItems = data.data?.data ?? [];

      if (newItems.isNotEmpty) {
        BlocProvider.of<ProcedureBloc>(context)
            .add(AddHistoryProcedures(newItems));
        setState(() => _page++);
      } else {
        setState(() => _hasMore = false);
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProcedureBloc, ProcedureState>(
      builder: (context, state) {
        final List<Datum> history = state.historicalProcedures ?? [];

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Historial de Trámites',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontSize: 18.sp,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: history.isEmpty && !_isLoading
                  ? const Center(child: Text("No hay trámites previos"))
                  : ListView.separated(
                      controller: _scrollController,
                      itemCount: history.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < history.length) {
                          final item = history[index];
                          return CardEc(item: item);
                        } else {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                      },
                      separatorBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: Divider(color: Colors.grey.shade300),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
