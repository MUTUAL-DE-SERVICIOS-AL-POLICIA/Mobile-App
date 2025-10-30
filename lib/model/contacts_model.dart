// To parse this JSON data, do
//
//     final contactsModel = contactsModelFromJson(jsonString);
import 'dart:convert';

ContactsModel contactsModelFromJson(String str) =>
    ContactsModel.fromJson(json.decode(str));

String contactsModelToJson(ContactsModel data) => json.encode(data.toJson());

class ContactsModel {
  ContactsModel({
    this.serviceStatus,
    this.message,
    this.data,
  });

  bool? serviceStatus;
  String? message;
  List<City>? data;

  factory ContactsModel.fromJson(Map<String, dynamic> json) => ContactsModel(
        serviceStatus: json["serviceStatus"],
        message: json["message"],
        data: json["data"] != null
            ? List<City>.from(json["data"].map((x) => City.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "serviceStatus": serviceStatus,
        "message": message,
        "data": data != null
            ? List<dynamic>.from(data!.map((x) => x.toJson()))
            : [],
      };
}

class City {
  City({
    this.id,
    this.name,
    this.latitude,
    this.longitude,
    this.companyAddress,
    this.phonePrefix,
    this.companyPhones,
    this.companyCellphones,
  });

  int? id;
  String? name;
  double? latitude;
  double? longitude;
  String? companyAddress;
  int? phonePrefix;
  String? companyPhones;
  String? companyCellphones;

  factory City.fromJson(Map<String, dynamic> json) => City(
        id: json["id"],
        name: json["name"],
        latitude: double.tryParse(json["latitude"].toString()),
        longitude: double.tryParse(json["longitude"].toString()),
        companyAddress: json["companyAddress"],
        phonePrefix: json["phonePrefix"],
        companyPhones: json["companyPhones"],
        companyCellphones: json["companyCellphones"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "latitude": latitude,
        "longitude": longitude,
        "companyAddress": companyAddress,
        "phonePrefix": phonePrefix,
        "companyPhones": companyPhones,
        "companyCellphones": companyCellphones,
      };
}
