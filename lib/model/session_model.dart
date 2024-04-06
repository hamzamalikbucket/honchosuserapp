// To parse this JSON data, do
//
//     final sessionModel = sessionModelFromJson(jsonString);

import 'dart:convert';

SessionModel sessionModelFromJson(String str) => SessionModel.fromJson(json.decode(str));

String sessionModelToJson(SessionModel data) => json.encode(data.toJson());

class SessionModel {
  SessionModel({
    this.session,
  });

  Session? session;

  factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
    session: json["session"] == null ? null : Session.fromJson(json["session"]),
  );

  Map<String, dynamic> toJson() => {
    "session": session?.toJson(),
  };
}

class Session {
  Session({
    this.token,
    this.flash,
    this.otpEmail,
    this.id,
    this.name,
  });

  String? token;
  Flash? flash;
  String? otpEmail;
  int? id;
  String? name;

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    token: json["_token"],
    flash: json["_flash"] == null ? null : Flash.fromJson(json["_flash"]),
    otpEmail: json["otp_email"],
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "_token": token,
    "_flash": flash?.toJson(),
    "otp_email": otpEmail,
    "id": id,
    "name": name,
  };


}

class Flash {
  Flash({
    this.old,
    this.flashNew,
  });

  List<dynamic>? old;
  List<dynamic>? flashNew;

  factory Flash.fromJson(Map<String, dynamic> json) => Flash(
    old: json["old"] == null ? [] : List<dynamic>.from(json["old"]!.map((x) => x)),
    flashNew: json["new"] == null ? [] : List<dynamic>.from(json["new"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "old": old == null ? [] : List<dynamic>.from(old!.map((x) => x)),
    "new": flashNew == null ? [] : List<dynamic>.from(flashNew!.map((x) => x)),
  };
}
