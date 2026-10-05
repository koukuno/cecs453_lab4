import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'mortgage.dart';

void main() {
  runApp(const MortgageApp());
}

class MortgageApp extends StatelessWidget {
  const MortgageApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mortgage App',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.pinkAccent, brightness: Brightness.dark),
      ),
      home: const MortgageHomePage(),
    );
  }
}

class MortgageHomePage extends StatefulWidget {
  const MortgageHomePage({super.key});

  @override
  State<MortgageHomePage> createState() => _MortgagePageState();
}

class _MortgagePageState extends State<MortgageHomePage> {
  var _mortgage = Mortgage(amount: Decimal.parse("400000"), rate: Decimal.parse("0.08"), years: 30);

  void _updateMortgage({required Decimal amount, required Decimal rate, required int years}) {
    setState(() {
      _mortgage = Mortgage(amount: amount, rate: rate, years: years);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Home"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text("Principal Amount: \$${_mortgage.amount.toStringAsFixed(2)}"),
            Text("Rate: ${_mortgage.rate * Decimal.parse("100.0")}%"),
            Text("Years: ${_mortgage.years}"),
            Text("Monthly Payment: \$${_mortgage.formatMonthlyPayment()}"),
            Text("Total Payment: \$${_mortgage.formatTotalPayment()}"),
          ],
        ),
      )
    );
  }
}
