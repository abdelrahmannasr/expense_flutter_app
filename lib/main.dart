// import 'package:flutter/services.dart';

import 'dart:io';

import 'package:flutter/cupertino.dart';

import './widgets/chart.dart';
import './widgets/new_transaction.dart';
import 'package:flutter/material.dart';
import 'models/transaction.dart';
import 'widgets/transaction_list.dart';

void main() {
  runApp(MyApp());
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses',
      theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.amber,
          fontFamily: 'QuickSand',
          textTheme: ThemeData.light().textTheme.copyWith(
                  title: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
          appBarTheme: AppBarTheme(
            textTheme: ThemeData.light().textTheme.copyWith(
                title: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                button: TextStyle(
                  color: Colors.white,
                )),
          )),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final List<Transaction> _usertransactions = [
    // Transaction(
    //   id: 't1',
    //   title: 'New Shoes',
    //   amount: 69.99,
    //   date: DateTime.now(),
    // ),
    // Transaction(
    //   id: 't2',
    //   title: 'Weekly Grocery',
    //   amount: 16.55,
    //   date: DateTime.now(),
    // ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  var _showChart = false;

  List<Transaction> get _recentTranasctions {
    return _usertransactions.where((tx) {
      return tx.date.isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
  }

  void _addNewTransaction(
      String txTitle, double txAmount, DateTime txDateTime) {
    final newTx = Transaction(
      id: DateTime.now().toString(),
      title: txTitle,
      amount: txAmount,
      date: txDateTime,
    );

    setState(() {
      _usertransactions.add(newTx);
    });
  }

  void _deleteTransaction(String id) {
    if (_usertransactions.length == 0) {
      return;
    }
    setState(() {
      _usertransactions.removeWhere((tx) => tx.id == id);
    });
  }

  void _openAddNewTxBottomSheat(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return NewTransaction(
          _addNewTransaction,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandScape = mediaQuery.orientation == Orientation.landscape;
    final PreferredSizeWidget appBar = _buildAppBar();
    final transactionListWidget = Container(
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
              mediaQuery.padding.top) *
          0.7,
      child: TransactionList(
        transactions: _usertransactions,
        deleteTransaction: _deleteTransaction,
      ),
    );
    final bodyWidget = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (isLandScape)
              ..._buildLandScapeConent(
                mediaQuery,
                appBar,
                transactionListWidget,
              ),
            if (!isLandScape)
              ..._buildPorteratContent(
                mediaQuery,
                appBar,
                transactionListWidget,
              ),
          ],
        ),
      ),
    );
    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: bodyWidget,
            navigationBar: appBar,
          )
        : Scaffold(
            appBar: appBar,
            body: bodyWidget,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Platform.isIOS
                ? Container()
                : FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () => _openAddNewTxBottomSheat(context),
                  ),
          );
  }

  PreferredSizeWidget _buildAppBar() {
    return Platform.isIOS ? _buildIosAppBarr() : _buildAndroidAppBar();
  }

  Widget _buildIosAppBarr() {
    return CupertinoNavigationBar(
      middle: Text('Personal Expenses'),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        GestureDetector(
          onTap: () => _openAddNewTxBottomSheat(context),
          child: Icon(CupertinoIcons.add),
        ),
      ]),
    );
  }

  Widget _buildAndroidAppBar() {
    return AppBar(
      title: Text('Personal Expenses'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => _openAddNewTxBottomSheat(context),
        )
      ],
    );
  }

  List<Widget> _buildLandScapeConent(
    MediaQueryData mediaQuery,
    AppBar appBar,
    Widget transactionListWidget,
  ) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Show Chart',
            style: Theme.of(context).textTheme.title,
          ),
          Switch.adaptive(
              value: _showChart,
              onChanged: (value) {
                setState(() {
                  _showChart = value;
                });
              }),
        ],
      ),
      _showChart
          ? Container(
              height: (mediaQuery.size.height -
                      appBar.preferredSize.height -
                      mediaQuery.padding.top) *
                  0.7,
              child: Chart(recentTransactions: _recentTranasctions))
          : transactionListWidget,
    ];
  }

  List<Widget> _buildPorteratContent(
    MediaQueryData mediaQuery,
    AppBar appBar,
    Widget transactionListWidget,
  ) {
    return [
      Container(
          height: (mediaQuery.size.height -
                  appBar.preferredSize.height -
                  mediaQuery.padding.top) *
              0.3,
          child: Chart(recentTransactions: _recentTranasctions)),
      transactionListWidget
    ];
  }
}
