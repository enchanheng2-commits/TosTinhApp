import 'dart:convert';

class UserAccount {
  final String fullName;
  final String email;
  final String password;
  final String phoneNumber;
  final String address;
  final DateTime createdAt;

  const UserAccount({
    required this.fullName,
    required this.email,
    required this.password,
    this.phoneNumber = '',
    this.address = '',
    required this.createdAt,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      address: json['address'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String toEncodedJson() => jsonEncode(toJson());

  static UserAccount fromEncodedJson(String source) {
    return UserAccount.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }
}
