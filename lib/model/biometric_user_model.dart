// To parse this JSON data, do
//
//     final biometricUserModel = biometricUserModelFromJson(jsonString);

import 'dart:convert';

BiometricUserModel biometricUserModelFromJson(String str) =>
    BiometricUserModel.fromJson(json.decode(str));

String biometricUserModelToJson(BiometricUserModel data) =>
    json.encode(data.toJson());

class BiometricUserModel {
  BiometricUserModel({
    this.affiliateId,
  });

  int? affiliateId;

  BiometricUserModel copyWith({
    int? affiliateId,
  }) =>
      BiometricUserModel(
        affiliateId: affiliateId ?? this.affiliateId,
      );

  factory BiometricUserModel.fromJson(Map<String, dynamic> json) =>
      BiometricUserModel(
        affiliateId: json["affiliate_id"],
      );

  Map<String, dynamic> toJson() => {
        "affiliate_id": affiliateId,
      };
}

class UserAppMobile {
  UserAppMobile({
    this.identityCard,
    this.numberPhone,
  });

  String? identityCard;
  String? numberPhone;

  UserAppMobile copyWith({
    String? identityCard,
    String? numberPhone,
  }) =>
      UserAppMobile(
        identityCard: identityCard ?? this.identityCard,
        numberPhone: numberPhone ?? this.numberPhone,
      );

  factory UserAppMobile.fromJson(Map<String, dynamic> json) => UserAppMobile(
        identityCard: json["identity_card"],
        numberPhone: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "identity_card": identityCard,
        "password": numberPhone,
      };
}
