class Profile {
  // cosa compone l'oggetto
  final String id;
  final String userId;
  String displayName;
  String? avatarUrl;

  // costruttore
  Profile({
    required this.id,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
  });

  // trasformiamo da map
  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
    id: map['id'],
    userId: map['user_id'],
    displayName: map['displayName'],
    avatarUrl: map['avatar_url'],
  );

  // trasformiamo in map
  Map<String, dynamic> toMap() => {
    'user_id': userId, // sta cosa va chiarita meglio perché non sto capendo cosa sta succedendo!
    'display_name': displayName,
    'avatar_url': avatarUrl,
  };
}
