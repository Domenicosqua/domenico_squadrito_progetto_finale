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
  Future<void> loadExenses() async {
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
    try {
      await _repo.updateExpense(updatedExpense);
      // cerco indice spesa da aggiornare
      final index = _expenses.indexWhere((exp) => exp.id == updatedExpense.id);
      if (index != -1) {
        _expenses[index] = updatedExpense;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      await _repo.deleteExpense(expenseId);
      // cerco nell'array dove sta la spesa e la elimino pure li
      _expenses.removeWhere((exp) => exp.id == expenseId);
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  void _setIsLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = null;
    notifyListeners();
  }
}
