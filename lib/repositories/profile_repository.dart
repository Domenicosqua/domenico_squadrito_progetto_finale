import 'package:aullet/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  final _client = Supabase.instance.client;

  // fetchProfile che restituisce il profilo utente o null se non esiste
  Future<Profile?> fetchProfile(String userId) async {
    // la select viene eseguita semplicemente con await
    final data = await _client
        .from('profiles')
        .select() // così equivale a all
        .eq('user_id', userId)
        .maybeSingle(); // zero o un record

    if (data == null) return null;
    return Profile.fromMap(data);
  }

  // creazione nuovo profilo
  Future<void> createProfile(Profile profile) async {
    // await sul builder fa partire l'insert
    final _ = await _client.from('profiles').insert(profile.toMap());
  }

  // aggiorna profilo utente
  Future<void> updateProfile(Profile profile) async {
    final _ = await _client
        .from('profiles')
        .update(profile.toMap())
        .eq('user_id', profile.userId);
  }
}
