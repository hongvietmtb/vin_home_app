class AccountPublic {
  int? id;
  String? name;
  String? avatar;

  AccountPublic({
    this.id,
    this.name,
    this.avatar});

  AccountPublic.fromJson(dynamic json) {
    id = json["id"];
    name = json["name"];
    avatar = json["avatar"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["name"] = name;
    map["avatar"] = avatar;
    return map;
  }

}