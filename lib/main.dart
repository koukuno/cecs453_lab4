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
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.pinkAccent, brightness: Brightness.dark)),
      home: const MortgageHomePage(),
    );
  }
}

class MortgageHomePage extends StatefulWidget {
  const MortgageHomePage({super.key});

  @override
  State<MortgageHomePage> createState() => _MortgagePageState();
}

class MortgageForm extends StatefulWidget {
  const MortgageForm({super.key});

  @override
  State<MortgageForm> createState() => _MortgageFormState();
}

class _MortgageFormState extends State<MortgageForm> {
  final _textControllerAmount = TextEditingController();

  @override
  void dispose()
  {
    _textControllerAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: const Text("Mortgage Form")),
      body: Column(mainAxisAlignment: .center, children: [
        TextField(controller: _textControllerAmount, decoration: InputDecoration(label: const Text("Principal Amount (\$)"))),
        Row(mainAxisAlignment: .center, children: [
          TextButton(child: const Text("Submit"), onPressed: () => Navigator.pop(context)),
          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(context)),
        ])
      ])
    );
  }
}

class _MortgagePageState extends State<MortgageHomePage> {
  Mortgage? _mortgage;
  bool acceptedTerms = false;

  void _updateMortgage({required Decimal amount, required Decimal rate, required int years}) {
    setState(() {
      _mortgage = Mortgage(amount: amount, rate: rate, years: years);
    });
  }

  Future<bool?> showTermsDialog({required BuildContext context}) async
  {
    return showDialog(context: context, builder: (BuildContext context) { return AlertDialog(
      title: const Text("Alert"),
      content: const Text("Do you agree to the Terms and Conditions?"),
      actions: <Widget>[
        TextButton(child: const Text("Disagree"), onPressed: () => Navigator.pop(context, false)),
        TextButton(child: const Text("Agree"), onPressed: () => Navigator.pop(context, true)),
      ],
    ); });
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
      infoWidgets.add(const Text("Please set a Mortgage by tapping on Modify Data below"));
    }

    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: const Text("Home")),
      body: Column(mainAxisAlignment: .center, children: infoWidgets + [
          CheckboxListTile(title: const Text("Terms and Conditions"), value: acceptedTerms, onChanged: (bool? value) async {
            final accepted = await showTermsDialog(context: context);
            setState(() {
              acceptedTerms = accepted!;
            });
          }),
          TextButton(child: const Text("Modify Data"), onPressed: () async {
            final mortgage = await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => MortgageForm()));
            if (mortgage != null) {
              _mortgage = mortgage;
              return;
            }
          }),
        ],
      ),
    );
  }
}
