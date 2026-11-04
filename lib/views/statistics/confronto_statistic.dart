import 'package:aullet/viewmodel/statistic_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfrontoStatistic extends StatefulWidget {
  const ConfrontoStatistic({super.key});

  @override
  State<ConfrontoStatistic> createState() => _ConfrontoStatisticState();
}

class _ConfrontoStatisticState extends State<ConfrontoStatistic> {
  int _selectedYear = DateTime.now().year;
  int _year1 = DateTime.now().year;
  int? _month1;
  int _year2 = DateTime.now().year;
  int? _month2;

  Map<String, dynamic>? _comparison;

  final List _monthName = [
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticViewmodel>().loadExpenses();
    });
  }

  Future<void> _doCompare() async {
    final vm = context.read<StatisticViewmodel>();
    final result = await vm.comparePeriods(_year1, _month1, _year2, _month2);
    setState(() => _comparison = result);
  }

  Widget _buildYearDropdown({required bool isFirst}) {
    final vm = context.watch<StatisticViewmodel>();
    final years = vm.allExpenses.map((e) => e.date.year).toSet().toList()
      ..sort();
    final value = isFirst ? _year1 : _year2;
    return DropdownButton<int>(
      value: value,
      items: years
          .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
          .toList(),
      onChanged: (y) {
        if (y != null) setState(() => isFirst ? _year1 = y : _year2 = y);
      },
    );
  }

  Widget _buildMonthDropdown({required bool isFirst}) {
    final value = isFirst ? _month1 : _month2;
    return DropdownButton<int?>(
      value: value,
      items: [
        const DropdownMenuItem(value: null, child: Text('tutti i mesi')),
        ...List.generate(
          12,
          (i) => i + 1,
        ).map((m) => DropdownMenuItem(value: m, child: Text(_monthName[m]))),
      ],
      onChanged: (m) {
        if (isFirst) {
          _month1 = m;
        } else {
          _month2 = m;
        }
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StatisticViewmodel>();
    final yearList = vm.allExpenses.map((e) => e.date.year).toSet().toList()
      ..sort();

    if (!yearList.contains(_selectedYear)) {
      yearList.insert(0, _selectedYear);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiche mensili'),
        centerTitle: true,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildYearDropdown(isFirst: true)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildMonthDropdown(isFirst: true)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildYearDropdown(isFirst: false)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildMonthDropdown(isFirst: false)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _doCompare,
                    child: const Text('Confronta'),
                  ),
                  const SizedBox(height: 24),
                  if (_comparison != null) ...[
                    Text(
                      'Totale Periodo 1: €${_comparison!['period1'].toStringAsFixed(2)}',
                    ),
                    Text(
                      'Totale Periodo 2: €${_comparison!['period2'].toStringAsFixed(2)}',
                    ),
                    Text(
                      'Differenza: €${_comparison!['difference'].toStringAsFixed(2)}',
                    ),
                    Text(
                      'Variazione%: €${_comparison!['percentChange'].toStringAsFixed(1)}',
                    ),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(show: false),
                          alignment: BarChartAlignment.spaceAround,
                          maxY:
                              [
                                _comparison!['period1'] as double,
                                _comparison!['period2'] as double,
                              ].reduce((a, b) => a > b ? a : b) *
                              1.2,
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (x, meta) {
                                  if (x.toInt() == 0) return const Text('P1');
                                  return const Text('P2');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: _comparison!['period2'],
                                  width: 20,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
