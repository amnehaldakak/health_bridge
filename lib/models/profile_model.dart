class ProfileModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? profilePicture;
  final String? phone;
  final String? specialization;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profilePicture,
    this.phone,
    this.specialization,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      profilePicture: json['profile_picture'],
      phone: json['phone'],
      specialization: json['specialization'],
    );
  }
}
