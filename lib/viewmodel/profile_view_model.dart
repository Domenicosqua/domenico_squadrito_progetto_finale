import 'package:aullet/models/profile.dart';
import 'package:aullet/repositories/profile_repository.dart';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileViewModel extends ChangeNotifier {
  final _repo = ProfileRepository();

  Profile? _profile;
  bool _isLoading = false;
  String? _error;

  Profile? get profile => _profile;
  set profile(Profile profile) => _profile = profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // carichiamo il profilo dell'utente corrente
  Future<void> loadProfile() async {
    _setLoading(true);

    try {
      final user = Supabase.instance.client.auth.currentUser!;
      _profile = await _repo.fetchProfile(user.id);
      // se non esiste creane uno di default
      if (_profile == null) {
        _profile = Profile(
          userId: user.id,
          displayName: user.email!.split('@')[0],
        );
        await _repo.createProfile(_profile!);
        _profile = await _repo.fetchProfile(user.id);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createUserProfile(String name, String avatarUrl) async {
    final id = Supabase.instance.client.auth.currentUser?.id;
    if (id == null) return;

    final newProfile = Profile(
      userId: id,
      displayName: name,
      avatarUrl: avatarUrl,
    );
    try {
      await _repo.createProfile(newProfile);
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateUserProfile(Profile updatedProfile) async {
    try {
      await _repo.updateProfile(updatedProfile);
      profile = updatedProfile;
    } catch (e) {
      _error = e.toString();
      print(_error);
      rethrow;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    // azzero l'errore
    if (value) _error = null;
    notifyListeners();
  }
}
