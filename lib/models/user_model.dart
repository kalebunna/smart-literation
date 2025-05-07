class User {
  final int id;
  final String name;
  final String email;
  final String profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profile_image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image': profileImage,
    };
  }
}
