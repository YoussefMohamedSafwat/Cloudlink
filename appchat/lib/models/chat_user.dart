class ChatUser {
  ChatUser({
    required this.name,
    required this.about,
    required this.createdAt,
    required this.isOnline,
    required this.lastActive,
    required this.id,
    required this.pushToken,
    required this.email,
    required this.image,
  });
  late String name;
  late String about;
  late String createdAt;
  late bool isOnline;
  late String lastActive;
  late String id;
  late String pushToken;
  late String email;
  late String image;

  ChatUser.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    about = json['about'] ?? '';
    createdAt = json['created_at'] ?? '';
    isOnline = json['is_online'] ?? '';
    lastActive = json['last_active'] ?? '';
    id = json['id'] ?? '';
    pushToken = json['push_token'] ?? '';
    email = json['email'] ?? '';
    image = json['image'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['about'] = about;
    data['created_at'] = createdAt;
    data['is_online'] = isOnline;
    data['last_active'] = lastActive;
    data['id'] = id;
    data['push_token'] = pushToken;
    data['email'] = email;
    data['image'] = image;
    return data;
  }
}

List<ChatUser> userlist = [];
