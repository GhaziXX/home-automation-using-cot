class SignUp {
  final bool signedUp;
  final String message;
  final String userId;

  SignUp({
    required this.signedUp,
    required this.message,
    required this.userId,
  });

  factory SignUp.fromJson(Map<String, dynamic> json) {
    return SignUp(
        signedUp: json["ok"] ?? false,
        message: json["message"] ?? "",
        userId: json["id"] ?? "");
  }

  @override
  String toString() {
    return "the user $userId is $signedUp with a message $message";
  }
}
