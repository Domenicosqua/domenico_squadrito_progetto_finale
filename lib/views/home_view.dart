import 'package:aullet/models/category.dart';
import 'package:aullet/utils/color_utils.dart';
import 'package:aullet/utils/icon_utils.dart';
import 'package:aullet/viewmodel/category_view_model.dart';
import 'package:aullet/viewmodel/expense_view_model.dart';
import 'package:aullet/views/new_expense_page.dart';
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewExpensePage()),
          ).then((_) {
            context.read<ExpenseViewModel>().loadExpenses();
          });
        },
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
              Navigator.pushNamed(
                context,
                '/new-expense',
              ).then((_) => context.read<ExpenseViewModel>().loadExpenses());
            },
            label: const Text('Aggiungi spesa'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
  return ListView.separated(
    separatorBuilder: (_, __) => const Divider(),
    itemCount: expenseVM.expenses.length,
    itemBuilder: (context, index) {
      final expense = expenseVM.expenses[index];
      final category = catVM.categories.firstWhere(
        (cat) => cat.id == expense.categoryId,
        orElse: () => Category(
          id: '',
          name: 'Unknown',
          icon: 'category',
          color: 'FF000000',
        ),
      );
      final iconData = iconMap[category.icon] ?? Icons.category;
      final color = parsHexColor(category.color);
      final date = expense.date;
      final formattedDate =
          '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
      return ListTile(
        leading: Icon(iconData, color: color),
        title: Text(
          expense.amout.toStringAsFixed(2),
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$formattedDate ${expense.description != null && expense.description!.isNotEmpty ? '\n ${expense.description}' : ''}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => NewExpensePage(exp: expense),
                );
              },
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () {
                expenseVM.deleteExpense(expense.id);
              },
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
      );
    },
  );
}
