import 'data.dart';

class Issue {
  int? code;
  String? message;
  List<Data>? data;

  Issue({
      this.code, 
      this.message, 
      this.data});

  Issue.fromJson(dynamic json) {
    code = json["code"];
    message = json["message"];
    if (json["data"] != null) {
      data = [];
      json["data"].forEach((v) {
        data?.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["code"] = code;
    map["message"] = message;
    if (data != null) {
      map["data"] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}