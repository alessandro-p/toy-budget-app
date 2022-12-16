import 'package:flutter/material.dart';

import '../models/transaction.model.dart';
import 'transaction_item.dart';

class TransactionsList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final Function deleteTransaction;

  const TransactionsList({
    Key? key,
    required this.transactions,
    required this.deleteTransaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: transactions.isEmpty
          ? LayoutBuilder(builder: (context, constraints) {
              return Column(
                children: <Widget>[
                  Text(
                    'No Transactions added yet',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: constraints.maxHeight * 0.6,
                    child: Image.asset(
                      'assets/images/waiting.png',
                      fit: BoxFit.cover,
                    ),
                  )
                ],
              );
            })
          : ListView.builder(
              itemBuilder: (itemBuilderContext, index) {
                return TransactionItem(
                    // Flutter also has Unique keys, but they do not accept a value
                    // and re-calculate a random value at every build
                    key: ValueKey(transactions[index].id),
                    transaction: transactions[index],
                    deleteTransaction: deleteTransaction);
              },
              itemCount: transactions.length,
            ),
    );
  }
}
