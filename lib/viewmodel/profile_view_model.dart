import 'dart:io';

import 'package:aullet/models/profile.dart';
import 'package:aullet/repositories/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileViewModel extends ChangeNotifier {
  final _repo = ProfileRepository();

  Profile? _profile;
  bool _isLoading = false;
  String? _error;
  File? _selectedFile;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  File? get selectedFile => _selectedFile;
  set selectedFile(File file) => _selectedFile = file;

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
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile == null) return;
    selectedFile = File(pickedFile.path);
  }

  Future<void> updateDisplayName() async {}

  void _setLoading(bool value) {
    _isLoading = value;
    // azzero l'errore
    if (value) _error = null;
    notifyListeners();
  }
}
