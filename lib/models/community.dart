class Community {
  final String id;
  final String name;
  final String description;
  final bool isMember;
  final int members;
  final int likes;
  final String imageUrl;
  final String type; // 🟢 النوع (عام / خاص)
  final String specialization; // 🟢 التخصص

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.isMember,
    required this.members,
    required this.likes,
    required this.imageUrl,
    required this.type,
    required this.specialization,
  });

  Community copyWith({
    String? id,
    String? name,
    String? description,
    bool? isMember,
    int? members,
    int? likes,
    String? imageUrl,
    String? type,
    String? specialization,
  }) {
    return Community(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isMember: isMember ?? this.isMember,
      members: members ?? this.members,
      likes: likes ?? this.likes,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      specialization: specialization ?? this.specialization,
    );
  }

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isMember: json['is_member'] ?? false,
      members: json['members_count'] ?? 0,
      likes: json['likes_count'] ?? 0,
      imageUrl: json['image'] ?? '',
      type: json['type'] ?? 'public',
      specialization: json['specialization'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_member': isMember,
      'members_count': members,
      'likes_count': likes,
      'image': imageUrl,
      'type': type,
      'specialization': specialization,
    };
  }
}
