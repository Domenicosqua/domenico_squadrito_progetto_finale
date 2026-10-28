import 'package:aullet/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends ChangeNotifier {
  final _authService = AuthServices();

  // private
  bool _isLoading = false;
  String? _errorMessage;

  // parametro per verificare lo stato dell'utente _privato
  bool _isLoggedIn = false;

  // getter
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  // getter
  bool get isLoggedIn => _isLoggedIn;

  // costruttore per il controllo automatico dell'istanza di un utente loggato
  AuthViewModel() {
    checkCurrentUser(); // controllo automatico dell'istanza
  }

  // Metodo per controllare se c'è un utente loggato in Supabase
  void checkCurrentUser() {
    _isLoggedIn = _authService.currentUser != null;
    notifyListeners();
  }

  //* registrazione utente
  Future<void> register(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signUp(email: email, password: password);
      // success, nessun errore. Loggiamo l'utente ->
      _isLoggedIn = true;
    } on AuthException catch (error) {
      // Ho un errore con AuthException, lo catturo
      _errorMessage = error.message;
    } catch (e) {
      // catturo altri tipi di errore
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  //* accesso utente
  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signIn(email: email, password: password);
      // se successo vado avanti a loggare l'utente ->
      _isLoggedIn = true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  //* logout utente
  Future<void> logOut() async {
    await _authService.signOut();
    // dico all'applicazione di segnare l'utente come non loggato
    _isLoggedIn = false;
    notifyListeners();
  }

  //* funzione per impostare isLoading e notificare i widget in ascolto
  void _setLoading(bool value) {
    _isLoading = value;
    // azzero l'errore
    if (value) _errorMessage = null;
    notifyListeners();
  }
}
