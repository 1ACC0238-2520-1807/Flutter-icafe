class AuthenticatedUser {
  final int id;
  final String email;
  final String token;

  AuthenticatedUser({required this.id, required this.email, required this.token});

  factory AuthenticatedUser.fromJson(Map<String, dynamic> json) => AuthenticatedUser(
    id: json['id'],
    email: json['email'],
    token: json['token'],
  );
}
