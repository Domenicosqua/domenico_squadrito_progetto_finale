import 'package:aullet/models/category.dart';
import 'package:aullet/models/expense.dart';
import 'package:aullet/repositories/category_repository.dart';
import 'package:aullet/repositories/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatisticViewmodel extends ChangeNotifier {
  final _repo = ExpenseRepository();
  final _catRepo = CategoryRepository();

  List<Category> _allCategories = [];
  List<Expense> _allExpenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  int? _monthFilter;

  List<Category> get allCategories => _allCategories;
  List<Expense> get allExpenses => _allExpenses;
  bool get isLoading => _isLoading;
  String? get errorMessagge => _errorMessage;
  int? get monthFilter => _monthFilter;

  //carichiamo le spese dell'utente:
  Future<void> loadExpenses() async {
    _setIsLoading(true);
    _errorMessage = null;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Utente non autenticato');
      _allExpenses = await _repo.fetchExpenses(user.id);
      _allCategories = await _catRepo.fetchAll();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setIsLoading(false);
    }
  }

  void setMonthFilter(int? month) {
    _monthFilter = month;
    notifyListeners();
  }

  // calcoliamo il totale delle spese per mese nell'anno selezionato:
  Map<int, double> calculateMonthlyExpenses(int year) {
    final Map<int, double> totals = {for (var m = 1; m <= 12; m++) m: 0.0};
    for (final exp in _allExpenses) {
      if (exp.date.year == year) {
        totals[exp.date.month] = totals[exp.date.month]! + exp.amout;
      }
    }
    return totals;
  }

  // calcolo spese per categoria
  Map<Category, double> calculateExpensesByCategory(int year) {
    final Map<String, double> temp = {};
    for (final exp in _allExpenses) {
      if (exp.date.year == year &&
          (_monthFilter == null || exp.date.month == monthFilter)) {
        temp.update(
          exp.categoryId,
          (v) => v + exp.amout,
          ifAbsent: () => exp.amout,
        );
      }
    }
    // mappa categoryId -> Category
    final result = <Category, double>{};
    for (final cat in _allCategories) {
      final val = temp[cat.id] ?? 0.0;
      if (val > 0) result[cat] = val;
    }
    return result;
  }

  // calcolo del totale spese per anno/mese specifico
  Future<double> calculateTotalForPeriod(int year, int? month) async {
    double total = 0.0;
    for (final exp in _allExpenses) {
      if (exp.date.year == year && (month == null || exp.date.month == month)) {
        total += exp.amout;
      }
    }
    return total;
  }

  // confronta due periodi (anno1, mese1) vs (anno2, mese2)
  // ritorna una mappa con chiavi perido1 perido2, difference percentChange
  Future<Map<String, dynamic>> comparePeriods(
    int year1,
    int? month1,
    int year2,
    int? month2,
  ) async {
    final total1 = await calculateTotalForPeriod(year1, month1);
    final total2 = await calculateTotalForPeriod(year2, month2);
    final diff = total1 - total2;
    final percent = total2 != 0 ? (diff / total2) * 100 : 0;

    return {
      'period1': total1,
      'period2': total2,
      'difference': diff,
      'percentChange': percent,
    };
  }

  void _setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
