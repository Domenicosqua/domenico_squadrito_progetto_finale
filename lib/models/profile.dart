class Profile {
  // cosa compone l'oggetto
  final String id;
  final String userId;
  String displayName;
  String? avatarUrl;

  // costruttore
  Profile({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.id,
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
    //'user_id': userId,
    // il servizio supabase riesce già a catturare questa informazione da solo senza che i vado a farlo trasformare in map
    // Posso esplicitarlo come no. Funziona lo stesso. Scriverlo lo rende più sicuro obbligando l'app a scrivere ciò che decido io.
    'display_name': displayName,
    'avatar_url': avatarUrl,
  };
}
