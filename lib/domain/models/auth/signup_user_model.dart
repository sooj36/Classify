
class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String status;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    this.status = "approved",
  });
}