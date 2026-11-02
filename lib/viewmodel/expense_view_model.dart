import 'package:aullet/models/expense.dart';
import 'package:aullet/repositories/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseViewModel extends ChangeNotifier {
  final _repo = ExpenseRepository();
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get errorMessagge => _errorMessage;

  // carico le spese dell'utente
  Future<void> loadExpenses() async {
    _setIsLoading(true);
    try {
      final user = Supabase.instance.client.auth.currentUser!;
      _expenses = await _repo.fetchExpenses(user.id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setIsLoading(false);
    }
  }

  // inserimento spese utente
  Future<void> addExpense(Expense exp) async {
    try {
      await _repo.insertExpense(exp);
      _expenses.insert(0, exp);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      print(e);
      rethrow;
    }
  }

  // modifica spesa
  Future<void> updateExpense(Expense updatedExpense) async {
    _setIsLoading(true);
    _errorMessage = null;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Utente non autenticato');
      await _repo.updateExpense(updatedExpense);
      _expenses = await _repo.fetchExpenses(user.id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setIsLoading(false);
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    _setIsLoading(true);
    _errorMessage = null;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Utente non autenticato');
      await _repo.deleteExpense(expenseId);
      _expenses = await _repo.fetchExpenses(user.id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setIsLoading(false);
    }
  }

  void _setIsLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = null;
    notifyListeners();
  }
}
