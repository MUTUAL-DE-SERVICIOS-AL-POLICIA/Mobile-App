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
    this.biometricUser = false,
    this.userAppMobile,
  });

  int? affiliateId;
  bool? biometricUser;
  UserAppMobile? userAppMobile;

  BiometricUserModel copyWith({
    int? affiliateId,
    bool? biometricUser,
    UserAppMobile? userAppMobile,
  }) =>
      BiometricUserModel(
        affiliateId: affiliateId ?? this.affiliateId,
        biometricUser: biometricUser ?? this.biometricUser,
        userAppMobile: userAppMobile ?? this.userAppMobile,
      );

  factory BiometricUserModel.fromJson(Map<String, dynamic> json) =>
      BiometricUserModel(
          biometricUser: json["biometric"],
          affiliateId: json["affiliate_id"],
          userAppMobile: json["user_app_mobile"] != null
              ? UserAppMobile.fromJson(json["user_app_mobile"])
              : null);

  Map<String, dynamic> toJson() => {
        "biometric": biometricUser,
        "affiliate_id": affiliateId,
        "user_app_mobile": userAppMobile!.toJson(),
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
