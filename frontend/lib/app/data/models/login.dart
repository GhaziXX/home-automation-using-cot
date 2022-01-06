class Login {
  final bool loggedIn;
  final String message;

  Login({
    required this.loggedIn,
    required this.message,
  });

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(loggedIn: json["ok"] ?? false, message: json["message"] ?? "");
  }

  @override
  String toString() {
    return "the user is $loggedIn with a message $message";
  }
}
