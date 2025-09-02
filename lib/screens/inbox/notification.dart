import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muserpol_pvt/bloc/notification/notification_bloc.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/components/paint.dart';
import 'package:muserpol_pvt/components/headers.dart';
import 'package:muserpol_pvt/database/db_provider.dart';

class ScreenNotification extends StatefulWidget {
  const ScreenNotification({super.key});

  @override
  State<ScreenNotification> createState() => _ScreenNotificationState();
}

class _ScreenNotificationState extends State<ScreenNotification> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      if (!mounted) return;
      final notificationBloc = BlocProvider.of<NotificationBloc>(context);
      debugPrint('argumentos ${ModalRoute.of(context)!.settings.arguments}');
      await DBProvider.db.updateNotificationModelByContent(json.encode(ModalRoute.of(context)!.settings.arguments));
      DBProvider.db.getAllNotificationModel().then((res) => notificationBloc.add(UpdateNotifications(res)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProvider.of<UserBloc>(context, listen: true).state.user;
    final args = json.decode(json.encode(ModalRoute.of(context)!.settings.arguments));
    return Scaffold(
        body: Stack(children: [
      if (args['image'].length <= 0) const Formtop(),
      if (args['image'].length <= 0) const FormButtom(),
      Column(children: [
            HedersComponent(title: args!['title'], titleHeader: args['PublicationDate']),
            Expanded(
                child: Center(
              child: SingleChildScrollView(
                  child: Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    args['text']
                        .replaceAll(RegExp('{{full_name}}'), userBloc!.fullName??'')
                        .replaceAll(RegExp('{{identity_card}}'), userBloc.identityCard??'')
                        .replaceAll(RegExp('{{degree}}'), userBloc.degree??'')
                        .replaceAll(RegExp('{{pension_entity}}'), userBloc.pensionEntity??'')
                        .replaceAll(RegExp('{{category}}'), userBloc.category??''),
                    textAlign: TextAlign.justify,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                // if (args['text'].length > 0)
                //   const Divider(
                //     color: Colors.blueGrey,
                //   ),
                if (args['image'].length > 0) InteractiveViewer(minScale: 1, maxScale: 4, child: Image.network(args['image'])),
              ])),
            )),
          ])
    ]));
  }
}
