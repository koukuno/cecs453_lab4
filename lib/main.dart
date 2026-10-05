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
  Mortgage? _mortgage;

  void _updateMortgage({required Decimal amount, required Decimal rate, required int years}) {
    setState(() {
      _mortgage = Mortgage(amount: amount, rate: rate, years: years);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> infoWidgets = [];

    if (_mortgage != null) {
      infoWidgets.add(Text("Principal Amount: \$${_mortgage!.amount.toStringAsFixed(2)}"));
      infoWidgets.add(Text("Rate: ${_mortgage!.rate * Decimal.parse("100.0")}%"));
      infoWidgets.add(Text("Years: ${_mortgage!.years}"));
      infoWidgets.add(Text("Monthly Payment: \$${_mortgage!.formatMonthlyPayment()}"));
      infoWidgets.add(Text("Total Payment: \$${_mortgage!.formatTotalPayment()}"));
    } else {
      infoWidgets.add(const Text("Please set a Mortgage by tapping on Update Mortgage below"));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Home"),
      ),
      body: Column(
        mainAxisAlignment: .center,
        children: infoWidgets + [
          Row(mainAxisAlignment: .center, children: [
            Checkbox(value: false, semanticLabel: "Terms and Conditions", onChanged: (bool? value) {
            }),
            const Text("Terms and Conditions"),
          ]),
          TextButton(child: const Text("Modify Data"), onPressed: () {
          }),
        ],
      ),
    );
  }
}
