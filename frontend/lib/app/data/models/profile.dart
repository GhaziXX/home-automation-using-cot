class Profile {
  final bool authorized;
  final String forename;
  final String surname;
  final String email;
  final String username;
  final int permission;
  final String fullname;
  final String id;

  Profile({
    required this.authorized,
    required this.forename,
    required this.surname,
    required this.email,
    required this.username,
    required this.permission,
    required this.fullname,
    required this.id,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      authorized: json["ok"],
      forename: json.containsKey("message")
          ? json["message"].containsKey("forename")
              ? json["message"]["forename"]
              : ""
          : "",
      surname: json.containsKey("message")
          ? json["message"].containsKey("surname")
              ? json["message"]["surname"]
              : ""
          : "",
      email: json.containsKey("message")
          ? json["message"].containsKey("email")
              ? json["message"]["email"]
              : ""
          : "",
      username: json.containsKey("message")
          ? json["message"].containsKey("username")
              ? json["message"]["username"]
              : ""
          : "",
      permission: json.containsKey("message")
          ? json["message"].containsKey("permissions")
              ? json["message"]["permissions"]
              : -1
          : -1,
      fullname: json.containsKey("message")
          ? json["message"].containsKey("fullname")
              ? json["message"]["fullname"]
              : ""
          : "",
      id: json.containsKey("message")
          ? json["message"].containsKey("id")
              ? json["message"]["id"]
              : ""
          : "",
    );
  }
}
