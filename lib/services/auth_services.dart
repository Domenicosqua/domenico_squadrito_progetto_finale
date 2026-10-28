import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServices {
  final _supabase = Supabase.instance.client;

  //* registriamo un utente via mail e password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return _supabase.auth.signUp(email: email, password: password);
  }

  //* login con mail e password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _supabase.auth.signInWithPassword(email: email, password: password);
  }

  //* logout
  Future<void> signOut() {
    return _supabase.auth.signOut();
  }

  //* restituisce l'utente attualmente loggato altrimenti null
  User? get currentUser => _supabase.auth.currentUser;
}
