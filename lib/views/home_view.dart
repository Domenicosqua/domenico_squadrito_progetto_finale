import 'package:aullet/viewmodel/category_view_model.dart';
import 'package:aullet/viewmodel/expense_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    print('qualcosa');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseViewModel>().loadExpenses();
      context.read<CategoryViewModel>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseVM = context.watch<ExpenseViewModel>();
    final catVM = context.watch<CategoryViewModel>();

    return Scaffold(
      body: expenseVM.isLoading || catVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(expenseVM, catVM, context),

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.home)),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              icon: const Icon(Icons.person),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildBody(
  ExpenseViewModel expenseVM,
  CategoryViewModel catVM,
  BuildContext context,
) {
  final expenses = expenseVM.expenses;
  if (expenses.isEmpty) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Non ci sono spese inserite',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/new-expense');
            },
            label: const Text('Aggiungi spesa'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
  return ListView.builder(
    itemCount: expenseVM.expenses.length,
    itemBuilder: (context, index) {
      final expense = expenseVM.expenses[index];
      final category = catVM.categories.firstWhere(
        (cat) => cat.id == expense.categoryId,
      );
      return Card(
        margin: const EdgeInsets.all(10),
        child: ListTile(
          title: Text(expense.amout.toString()),
          subtitle: Row(
            children: [Text(category.toString()), Text('${expense.date}')],
          ),
        ),
      );
    },
  );
}
