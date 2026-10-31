import 'dart:io';

import 'package:aullet/models/profile.dart';
import 'package:aullet/viewmodel/auth_view_model.dart';
import 'package:aullet/viewmodel/profile_view_model.dart';
import 'package:aullet/views/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameCtrl = TextEditingController();
  File? _pickedFile;
  bool _didScheduleLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didScheduleLoad) {
      _didScheduleLoad = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final vm = context.read<ProfileViewModel>();
        await vm.loadProfile();
        if (mounted && vm.profile != null) {
          _nameCtrl.text = vm.profile!.displayName;
        }
      });
    }
  }

  //! in questo modo l'initState chiamava un notifyListener innescando la ricostruzione del widget mentre ancora in costruzione creando quindi un errore.
  /* @override
  void initState() {
    super.initState();
    final vm = context.read<ProfileViewModel>();
    vm.loadProfile().then((_) {
      if (vm.profile != null) {
        _nameCtrl.text = vm.profile!.displayName;
      }
    });
  } */

  Future<void> pickAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _pickedFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final authVM = context.read<AuthViewModel>();
    final profile = vm.profile;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilo'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await authVM.logOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: pickAvatar,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _pickedFile != null
                              ? FileImage(_pickedFile!) as ImageProvider
                              : (vm.profile?.avatarUrl != null &&
                                    vm.profile!.avatarUrl!.trim().isNotEmpty &&
                                    vm.profile!.avatarUrl!.startsWith('http'))
                              ? NetworkImage(vm.profile!.avatarUrl!)
                              : null,
                          child:
                              (_pickedFile == null &&
                                  (vm.profile?.avatarUrl == null ||
                                      vm.profile!.avatarUrl!.trim().isEmpty ||
                                      !vm.profile!.avatarUrl!.startsWith(
                                        'http',
                                      )))
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: pickAvatar,
                    child: const Text('Cambia Immagine'),
                  ),
                  /* ElevatedButton.icon(
                    onPressed: () async {
                      await authVM.logOut();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      ); 
                    },
                    label: const Text('Logout'),
                    icon: const Icon(Icons.logout),
                  ),*/
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nome'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (vm.profile == null) return;
                      String avatarUrl = vm.profile!.avatarUrl ?? '';
                      if (_pickedFile != null) {
                        final uploadedUrl = await vm.uploadAvatar(_pickedFile!);
                        if (uploadedUrl != null) {
                          avatarUrl = uploadedUrl;
                        }
                      }

                      final updatedProfile = Profile(
                        id: vm.profile!.id,
                        userId: Supabase.instance.client.auth.currentUser!.id,
                        displayName: _nameCtrl.text.trim(),
                        avatarUrl: avatarUrl,
                      );
                      await vm.updateUserProfile(updatedProfile);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profilo salvato con successo'),
                        ),
                      );
                    },
                    child: const Text('Salva'),
                  ),
                  if (vm.error != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      vm.error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
