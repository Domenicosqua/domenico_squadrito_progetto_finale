import 'package:aullet/viewmodel/auth_view_model.dart';
import 'package:aullet/viewmodel/category_view_model.dart';
import 'package:aullet/viewmodel/expense_view_model.dart';
import 'package:aullet/viewmodel/profile_view_model.dart';
import 'package:aullet/views/auth/login_page.dart';
import 'package:aullet/views/auth/sign_up_page.dart';
import 'package:aullet/views/home_view.dart';
import 'package:aullet/views/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // caricamento file .env
  await dotenv.load(fileName: '.env');

  // variabili url db e chiave
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_PUBLISHABLE_KEY'];

  // se una chiave non è definita lancia eccezione
  if (supabaseUrl == null || supabaseKey == null) {
    throw Exception('Errore, manca url o key');
  }
  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // uso il multi provider per lo state management dell'app, in providers inserisco tutti i provider che gestiranno i cambiamenti di stato
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
        ChangeNotifierProvider(create: (_) => ExpenseViewModel()),
      ],
      // wrappo la material app con un consumer che ha valore in ingresso AuthViewModel
      child: Consumer<AuthViewModel>(
        builder: (context, authVM, _) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: .fromSeed(seedColor: Colors.deepPurple),
            ),
            // creo un ternario dove verifico se è loggato o meno così so dove inviarlo
            home: authVM.isLoggedIn ? const HomeView() : const LoginPage(),
            // gestione rotte
            routes: {
              '/login': (_) => const LoginPage(),
              '/signup': (_) => const SignUpPage(),
              '/home': (_) => const HomeView(),
              '/profile': (_) => const ProfilePage(),
            },
          );
        },
      ),
    );
  }
}
