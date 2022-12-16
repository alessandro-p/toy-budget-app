import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jot_it/widgets/chart/chart.dart';
import 'package:jot_it/widgets/new_transaction.dart';
import 'package:jot_it/widgets/transactions_list.dart';

import 'models/transaction.model.dart';

void main() {
  // Force orientation to be Portrait only
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitUp,
  // ]);
  runApp(const MyApp());
}

// WidgetsBindingObserver used to check app life cycle
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jot It',
      theme: ThemeData(
        primarySwatch: Colors.pink, // allows for shades (primaryColor does not)
        fontFamily: 'Quicksand',

        // EXAMPLE OVERRIDING TITLE STYLE
        textTheme: ThemeData.light().textTheme.copyWith(
              headline6: const TextStyle(
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

        // EXAMPLE OVERRIDING STYLE FOR APP BAR
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 20,
          ),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// WidgetsBindingObserver used to check app life cycle
class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  bool _showChart = false;
  final List<TransactionModel> _userTransactions = [
    // TransactionModel(
    //   id: 't1',
    //   title: 'My first transaction',
    //   amount: 21.20,
    //   date: DateTime.now(),
    // ),
    // TransactionModel(
    //   id: 't2',
    //   title: 'My second transaction',
    //   amount: 19.20,
    //   date: DateTime.now(),
    // ),
    // TransactionModel(
    //   id: 't3',
    //   title: 'My third transaction',
    //   amount: 19.20,
    //   date: DateTime.now(),
    // ),
    // TransactionModel(
    //   id: 't4',
    //   title: 'My fourth transaction',
    //   amount: 19.20,
    //   date: DateTime.now(),
    // ),
    // TransactionModel(
    //   id: 't5',
    //   title: 'My fifth transaction',
    //   amount: 19.20,
    //   date: DateTime.now(),
    // ),
    // TransactionModel(
    //   id: 't6',
    //   title: 'My sixth transaction',
    //   amount: 19.20,
    //   date: DateTime.now(),
    // ),
  ];

  @override
  void initState() {
    super.initState();

    // add this as observer. Listener is didChangeAppLifecycleState
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print(state);
  }

  @override
  void dispose() {
    super.dispose();

    // remove this as observer to avoid memory leak
    WidgetsBinding.instance?.removeObserver(this);
  }

  void _openAddTransactionModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return NewTransaction(addNewTransaction: _addNewTransaction);
        });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((element) => element.id == id);
    });
  }

  void _addNewTransaction(
    String newTitle,
    double newAmount,
    DateTime chosenDate,
  ) {
    final newTransaction = TransactionModel(
      id: DateTime.now().toString(),
      title: newTitle,
      amount: newAmount,
      date: chosenDate,
    );

    setState(() {
      _userTransactions.add(newTransaction);
    });
  }

  List<Widget> _buildLandscapeMode(
    MediaQueryData mediaQuery,
    PreferredSizeWidget appBar,
    Widget transactionListWidget,
  ) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Show chart',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Switch.adaptive(
            value: _showChart,
            onChanged: (val) {
              setState(
                () {
                  _showChart = val;
                },
              );
            },
          )
        ],
      ),
      _showChart
          ? SizedBox(
              height: (mediaQuery.size.height -
                      appBar.preferredSize.height -
                      mediaQuery.padding.top) *
                  0.7,
              child: Chart(recentTransactions: _recentTransactions),
            )
          : transactionListWidget,
    ];
  }

  List<Widget> _buildPortraitMode(
    double availableHeight,
    Widget transactionListWidget,
  ) {
    return [
      SizedBox(
        height: availableHeight * 0.4,
        child: Card(
          color: Theme.of(context).primaryColorLight,
          child: Chart(recentTransactions: _recentTransactions),
        ),
      ),
      transactionListWidget
    ];
  }

  List<TransactionModel> get _recentTransactions {
    return _userTransactions.where((transaction) {
      return transaction.date
          .isAfter(DateTime.now().subtract(const Duration(days: 7)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    final PreferredSizeWidget appBar = Platform.isIOS
        ? CupertinoNavigationBar(
            middle: const Text('Jot it'),
            trailing: Row(
                mainAxisSize:
                    MainAxisSize.min, // otherwise it takes all the space
                children: <Widget>[
                  GestureDetector(
                    child: const Icon(CupertinoIcons.add),
                    onTap: () => _openAddTransactionModal(context),
                  )
                ]),
          ) as PreferredSizeWidget
        : AppBar(
            title: const Text('Jot It'),
            actions: <Widget>[
              IconButton(
                onPressed: () => _openAddTransactionModal(context),
                icon: const Icon(Icons.add),
              )
            ],
          );

    final statusBarHeight = mediaQuery.padding.top;
    final availableHeight =
        mediaQuery.size.height - appBar.preferredSize.height - statusBarHeight;

    final transactionListWidget = SizedBox(
      height: availableHeight * 0.6,
      child: TransactionsList(
        transactions: _userTransactions,
        deleteTransaction: _deleteTransaction,
      ),
    );

    final pageBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (isLandscape)
                ..._buildLandscapeMode(
                  mediaQuery,
                  appBar,
                  transactionListWidget,
                ),
              if (!isLandscape)
                ..._buildPortraitMode(
                  availableHeight,
                  transactionListWidget,
                ),
            ]),
      ),
    );

    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: pageBody,
            navigationBar: appBar as ObstructingPreferredSizeWidget,
          )
        : Scaffold(
            appBar: appBar,
            body: pageBody,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => _openAddTransactionModal(context),
            ),
          );
  }
}
