import 'dart:io';

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
          id: '',
          userId: user.id,
          displayName: user.email!.split('@')[0],
        );
        await _repo.createProfile(_profile!);
        _profile = await _repo.fetchProfile(user.id);
      }
    } catch (e, stackTrace) {
      _error = e.toString();
      print('ERRORE IN LOAD PROFILE: $e'); // <-- Stampalo qui
      print(stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> uploadAvatar(File url) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final fileExt = url.path.split('.').last;
      final fileName =
          '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = fileName;

      await Supabase.instance.client.storage
          .from('image')
          .upload(filePath, url);
      final imageUrl = Supabase.instance.client.storage
          .from('image')
          .getPublicUrl(filePath);
      return imageUrl;
    } catch (e) {
      print("ATTENZIONE: L'upload su Supabase ha restituito null!");
      print('ERRORE UPLOAD AVATAR: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(Profile updatedProfile) async {
    print('--- INIZIO SALVATAGGIO PROFILO ---');
    try {
      await _repo.updateProfile(updatedProfile);
      profile = updatedProfile;
      print('--- PROFILO SALVATO CON SUCCESSO ---');
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
