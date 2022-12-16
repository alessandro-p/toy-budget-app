import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jot_it/models/transaction.model.dart';
import 'package:jot_it/widgets/chart/chart_bar.dart';

class Chart extends StatelessWidget {
  final List<TransactionModel> recentTransactions;

  const Chart({Key? key, required this.recentTransactions}) : super(key: key);

  List<Map<String, Object>> get groupedTransactionValues {
    return List.generate(7, (index) {
      final weekDay = DateTime.now().subtract(
        Duration(days: index),
      );
      final amount =
          recentTransactions.fold<double>(0.0, (previousValue, element) {
        final isCurrentWeekDay = element.date.day == weekDay.day &&
            element.date.month == weekDay.month &&
            element.date.year == weekDay.year;

        return isCurrentWeekDay
            ? previousValue + element.amount
            : previousValue;
      });

      return {
        'day': DateFormat.E().format(weekDay).substring(0, 1),
        'amount': amount,
      };
    }).reversed.toList();
  }

  double get totalSpending {
    return groupedTransactionValues.fold<double>(
        0.0,
        (previousValue, element) =>
            previousValue + (element['amount'] as double));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: groupedTransactionValues.map((data) {
              // Expanded is the same as Flexible but with FlexFit always tight
              return Flexible(
                fit: FlexFit.tight,
                child: ChartBar(
                  label: data['day'] as String,
                  spendingAmount: data['amount'] as double,
                  spendingPercentageOfTotal: totalSpending == 0
                      ? 0.0
                      : (data['amount'] as double) / totalSpending,
                ),
              );
            }).toList()),
      ),
    );
  }
}
