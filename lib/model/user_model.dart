import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

User userFromJson(String str) => User.fromJson(json.decode(str));

class UserModel {
  UserModel({
    this.apiToken,
    this.user,
  });

  String? apiToken;
  User? user;

  UserModel copyWith({
    String? apiToken,
    User? user,
  }) =>
      UserModel(
        apiToken: apiToken ?? this.apiToken,
        user: user ?? this.user,
      );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        apiToken: json["api_token"],
        user: User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "api_token": apiToken,
        "user": user?.toJson(),
      };
}

class User {
  User(
      {
      this.fullName,
      this.isPolice,
      this.kinship,
      this.affiliateId,
      this.identityCard,
      this.pensionEntity,
      this.degree,
      this.category,
      this.isDoblePerception,
      this.isEconomicComplement,
      this.messageEcoCom,
      this.enrolled,
      this.verified});

  String? fullName;
  bool? isPolice;
  String? kinship;
  int? affiliateId;
  String? identityCard;
  String? pensionEntity;
  String? degree;
  String? category;
  bool? isDoblePerception;
  bool? isEconomicComplement;
  String? messageEcoCom;
  bool? enrolled;
  bool? verified;

  User copyWith({
    String? fullName,
    bool? isPolice,
    String? kinship,
    int? affiliateId,
    String? identityCard,
    String? pensionEntity,
    String? degree,
    String? category,
    bool? isDoblePerception,
    bool? isEconomicComplement,
    String? messageEcoCom,
    bool? enrolled,
    bool? verified,
  }) =>
      User(
        fullName: fullName ?? this.fullName,
        isPolice: isPolice ?? this.isPolice,
        kinship: kinship ?? this.kinship,
        affiliateId: affiliateId ?? this.affiliateId,
        identityCard: identityCard ?? this.identityCard,
        pensionEntity: pensionEntity ?? this.pensionEntity,
        degree: degree ?? this.degree,
        category: category ?? this.category,
        isDoblePerception: isDoblePerception ?? this.isDoblePerception,
        isEconomicComplement: isEconomicComplement ?? this.isEconomicComplement,
        messageEcoCom: messageEcoCom ?? this.messageEcoCom,
        enrolled: enrolled ?? this.enrolled,
        verified: verified ?? this.verified,
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
        fullName: json["fullName"],
        isPolice: json['isPolice'],
        kinship: json["kinship"],
        affiliateId: json["affiliateId"],
        identityCard: json["identityCard"],
        pensionEntity: json["pensionEntity"],
        degree: json["degree"],
        category: json["category"],
        isDoblePerception: json["isDoblePerception"],
        isEconomicComplement: json["isEconomicComplement"],
        messageEcoCom: json["messageEcoCom"],
        enrolled: json["enrolled"],
        verified: json["verified"],
      );

  Map<String, dynamic> toJson() => {
        "fullName": fullName,
        "isPolice": isPolice,
        "kinship": kinship,
        "affiliateId": affiliateId,
        "identityCard": identityCard,
        "pensionEntity": pensionEntity,
        "degree": degree,
        "category": category,
        "isDoblePerception": isDoblePerception,
        "isEconomicComplement": isEconomicComplement,
        "messageEcoCom": messageEcoCom,
        "enrolled": enrolled,
        "verified": verified,
      };
}
