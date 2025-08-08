class Community {
  final String id;
  final String name;
  final String description;
  final bool isMember;
  final int members;
  final int likes;
  final String imageUrl;

  const Community({
    required this.id,
    required this.name,
    required this.description,
    required this.isMember,
    required this.members,
    required this.likes,
    required this.imageUrl,
  });
}
