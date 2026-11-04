import 'package:aullet/viewmodel/statistic_viewmodel.dart';
import 'package:aullet/views/statistics/confronto_statistic.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticViewmodel>().loadExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StatisticViewmodel>();
    final yearList = vm.allExpenses.map((e) => e.date.year).toSet().toList()
      ..sort();
    final monthlyData = vm.calculateMonthlyExpenses(_selectedYear);
    if (!yearList.contains(_selectedYear)) {
      yearList.insert(0, _selectedYear);
    }
    final categoryData = vm.calculateExpensesByCategory(_selectedYear);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiche mensili'),
        centerTitle: true,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ConfrontoStatistic()),
                      );
                    },
                    child: const Text('Vai alle comparazioni'),
                  ),
                  // selettore anno
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          value: _selectedYear,
                          items: yearList.map((year) {
                            return DropdownMenuItem<int>(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedYear = newValue;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<int?>(
                          value: vm.monthFilter,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Tutti i mesi'),
                            ),
                            ...<int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].map(
                              (m) {
                                const monthNames = [
                                  'Gennaio',
                                  'Febbraio',
                                  'Marzo',
                                  'Aprile',
                                  'Maggio',
                                  'Giugno',
                                  'Luglio',
                                  'Agosto',
                                  'Settembre',
                                  'Ottobre',
                                  'Novembre',
                                  'Dicembre',
                                ];
                                return DropdownMenuItem(
                                  value: m,
                                  child: Text(monthNames[m - 1]),
                                );
                              },
                            ),
                          ],
                          onChanged: (m) => vm.setMonthFilter(m),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                  SizedBox(
                    height: 300,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barGroups: List.generate(12, (index) {
                          int months = index + 1;
                          double totalForMonth = monthlyData[months] ?? 0.0;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: totalForMonth,
                                color: Colors.blue,
                                width: 14,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 300,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barGroups: List.generate(vm.allCategories.length, (
                          index,
                        ) {
                          final categories = vm.allCategories[index];
                          double totalForCategory =
                              categoryData[categories] ?? 0.0;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: totalForCategory,
                                color: Colors.blue,
                                width: 14,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
