import 'package:aullet/models/expense.dart';
import 'package:aullet/repositories/expense_repository.dart';
import 'package:aullet/viewmodel/expense_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewExpensePage extends StatefulWidget {
  const NewExpensePage({super.key});

  @override
  State<NewExpensePage> createState() => _NewExpensePageState();
}

class _NewExpensePageState extends State<NewExpensePage> {
  final _formKey = GlobalKey<FormState>();
  Category? _selectedCategory;
  final _amountController = TextEditingController();
  DateTime? _date;
  final _descrController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _descrController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final newExpense = Expense(
        id: userId,
        userId: userId,
        categoryId: _selectedCategory.toString(),
        amout: double.parse(_amountController.text.trim()),
        date: _date!,
      );
      try {
        await Provider.of<ExpenseViewModel>(
          context,
          listen: false,
        ).addExpense(newExpense);
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          Navigator.pop(context);
          messenger.showSnackBar(SnackBar(content: Text('Spesa salvata')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Errore $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuova Spesa'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: '€',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Campo obbligatorio'
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
