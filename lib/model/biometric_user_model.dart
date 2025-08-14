// To parse this JSON data, do
//
//     final biometricUserModel = biometricUserModelFromJson(jsonString);

import 'dart:convert';

BiometricUserModel biometricUserModelFromJson(String str) => BiometricUserModel.fromJson(json.decode(str));

String biometricUserModelToJson(BiometricUserModel data) => json.encode(data.toJson());

class BiometricUserModel {
  BiometricUserModel({
    this.affiliateId,
    this.biometricUser = false,
  });

  int? affiliateId;
  bool? biometricUser;

  BiometricUserModel copyWith({
    int? affiliateId,
    bool? biometricUser,
  }) =>
      BiometricUserModel(
        affiliateId: affiliateId ?? this.affiliateId,
        biometricUser: biometricUser ?? this.biometricUser,
      );

  factory BiometricUserModel.fromJson(Map<String, dynamic> json) =>
      BiometricUserModel(
        biometricUser: json["biometric"],
        affiliateId: json["affiliate_id"],
      );

  Map<String, dynamic> toJson() => {
        "biometricUser": biometricUser,
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
        numberPhone: json["numberPhone"],
      );

  Map<String, dynamic> toJson() => {
        "identity_card": identityCard,
        "numberPhone": numberPhone,
      };
}
