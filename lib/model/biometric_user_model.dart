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
    this.biometricComplement = false,
    this.biometricVirtualOfficine = false,
    this.affiliateId,
    this.userComplement,
    this.userVirtualOfficine,
  });

  bool? biometricComplement;
  bool? biometricVirtualOfficine;
  int? affiliateId;
  UserComplement? userComplement;
  UserVirtualOfficine? userVirtualOfficine;

  BiometricUserModel copyWith({
    bool? biometricComplement,
    bool? biometricVirtualOfficine,
    int? affiliateId,
    UserComplement? userComplement,
    UserVirtualOfficine? userVirtualOfficine,
  }) =>
      BiometricUserModel(
        biometricComplement: biometricComplement ?? this.biometricComplement,
        biometricVirtualOfficine:
            biometricVirtualOfficine ?? this.biometricVirtualOfficine,
        affiliateId: affiliateId ?? this.affiliateId,
        userComplement: userComplement ?? this.userComplement,
        userVirtualOfficine: userVirtualOfficine ?? this.userVirtualOfficine,
      );

  factory BiometricUserModel.fromJson(Map<String, dynamic> json) =>
      BiometricUserModel(
        biometricComplement: json["biometric_complement"],
        biometricVirtualOfficine: json["biometric_virtual_officine"],
        affiliateId: json["affiliate_id"],
        userComplement: UserComplement.fromJson(json["user_complement"]),
        userVirtualOfficine:
            UserVirtualOfficine.fromJson(json["user_virtual_officine"]),
      );

  Map<String, dynamic> toJson() => {
        "biometric_complement": biometricComplement,
        "biometric_virtual_officine": biometricVirtualOfficine,
        "affiliate_id": affiliateId,
        "user_complement": userComplement!.toJson(),
        "user_virtual_officine": userVirtualOfficine!.toJson(),
      };
}

class UserComplement {
  UserComplement({
    this.identityCard,
    this.dateBirth,
  });

  String? identityCard;
  String? dateBirth;

  UserComplement copyWith({
    String? identityCard,
    String? dateBirth,
  }) =>
      UserComplement(
        identityCard: identityCard ?? this.identityCard,
        dateBirth: dateBirth ?? this.dateBirth,
      );

  factory UserComplement.fromJson(Map<String, dynamic> json) => UserComplement(
        identityCard: json["identity_card"],
        dateBirth: json["date_birth"],
      );

  Map<String, dynamic> toJson() => {
        "identity_card": identityCard,
        "date_birth": dateBirth,
      };
}

class UserVirtualOfficine {
  UserVirtualOfficine({
    this.identityCard,
    this.password,
  });

  String? identityCard;
  String? password;

  UserVirtualOfficine copyWith({
    String? identityCard,
    String? password,
  }) =>
      UserVirtualOfficine(
        identityCard: identityCard ?? this.identityCard,
        password: password ?? this.password,
      );

  factory UserVirtualOfficine.fromJson(Map<String, dynamic> json) =>
      UserVirtualOfficine(
        identityCard: json["identity_card"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "identity_card": identityCard,
        "password": password,
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
