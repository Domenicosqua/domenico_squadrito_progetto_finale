import 'package:aullet/models/category.dart';
import 'package:aullet/models/expense.dart';
import 'package:aullet/viewmodel/category_view_model.dart';
import 'package:aullet/viewmodel/expense_view_model.dart';

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
  bool _didScheduleLoad = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descrController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didScheduleLoad) {
      _didScheduleLoad = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final vm = context.read<CategoryViewModel>();
        await vm.loadCategories();
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final newExpense = Expense(
        id: userId,
        userId: userId,
        categoryId: _selectedCategory!.id,
        amout: double.parse(_amountController.text.trim()),
        date: _date ?? DateTime.now(),
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

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _date = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final catVM = context.watch<CategoryViewModel>();
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
              const SizedBox(height: 16),
              DropdownButtonFormField<Category>(
                decoration: InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                items: catVM.categories
                    .map(
                      (category) => DropdownMenuItem<Category>(
                        value: category,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: (Category? value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Inserire categoria' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,

                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Data',
                    border: OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_month),
                  ),
                  child: Text(
                    _date == null
                        ? 'Seleziona data'
                        : '${_date!.day}/${_date!.month}/${_date!.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _submitForm,
                label: const Text('Salva'),
                icon: const Icon(Icons.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
