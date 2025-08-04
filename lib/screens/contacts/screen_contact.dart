import 'package:flutter/material.dart';
import 'package:muserpol_pvt/components/headers.dart';
import 'package:muserpol_pvt/model/contacts_model.dart';
import 'package:muserpol_pvt/screens/contacts/card_contact.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';

class ScreenContact extends StatefulWidget {
  const ScreenContact({super.key});

  @override
  State<ScreenContact> createState() => _ScreenContactState();
}

class _ScreenContactState extends State<ScreenContact> {
  ContactsModel? contact;

  @override
  void initState() {
    super.initState();
    getContacts();
  }

  getContacts() async {
    var response = await serviceMethod(
      mounted,
      context,
      'get',
      null,
      serviceGetContacts(),
      false,
      false,
    );
    if (response != null) {
      setState(() => contact = contactsModelFromJson(response.body));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: Column(
          children: [
            const HedersComponent(title: 'Contactos a nivel nacional'),
            contact != null
                ? Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(
                          contact!.data!.cities!.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: CardContact(
                              city: contact!.data!.cities![index],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const Expanded(
                    child: Center(
                      child: SizedBox(
                        height: 20,
                        child: Image(
                          image: AssetImage('assets/images/load.gif'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
