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

class MortgageInterestRatePage extends StatefulWidget {
  const MortgageInterestRatePage({super.key});

  @override
  State<MortgageInterestRatePage> createState() => _MortgageInterestRatePageState();
}

class _MortgageInterestRatePageState extends State<MortgageInterestRatePage> {
  Decimal? interestRate;

  @override
  Widget build(BuildContext context) {
    var interestRateRadioButtons = <RadioListTile<Decimal>>[];

    for (Decimal i = Decimal.parse("0.02"); i <= Decimal.parse("0.15"); i += Decimal.parse("0.0025")) {
      Decimal displayInterestRate = i * Decimal.fromInt(100);
      interestRateRadioButtons.add(RadioListTile(value: i, title: Text("${displayInterestRate.toStringAsFixed(2)}%")));
    }

    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: const Text("Select Interest Rate")),
      body: Padding(padding: const EdgeInsets.all(8.0), child: RadioGroup<Decimal>(
        groupValue: interestRate,
        onChanged: (Decimal? value) {
          Navigator.pop(context, value);
        },
        child: ListView(children: interestRateRadioButtons),
      )),
    );
  }
}

class _MortgageFormState extends State<MortgageForm> {
  final _textControllerAmount = TextEditingController();
  Decimal? interestRate;
  int? years = 30;

  @override
  void dispose() {
    _textControllerAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var interestRates = <Decimal>[];

    for (Decimal i = Decimal.fromInt(2); i <= Decimal.fromInt(15); i += Decimal.fromInt(25).pow(-1).toDecimal(scaleOnInfinitePrecision: 4)) {
      interestRates.add(i.pow(-2).toDecimal(scaleOnInfinitePrecision: 6));
    }

    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: const Text("Modify Data")),
      body: Padding(padding: const EdgeInsets.all(8.0), child: Column(mainAxisAlignment: .center, children: [
        TextField(decoration: InputDecoration(labelText: "Principal Amount (\$)", hintText: "Enter principal amount"), controller: _textControllerAmount),
        const SizedBox(height: 12),
        RadioGroup<int>(
          groupValue: years!,
          onChanged: (int? value) {
            setState(() {
              years = value!;
            });
          },
          child: Column(crossAxisAlignment: .start, children: <Widget>[
            Text("Select Term", style: Theme.of(context).textTheme.headlineSmall),
            const RadioListTile(value: 10, title: Text("10 years")),
            const RadioListTile(value: 15, title: Text("15 years")),
            const RadioListTile(value: 30, title: Text("30 years")),
          ]),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: .center, spacing: 12.0, children: [
          ElevatedButton(child: const Text("Select Interest Rate"), onPressed: () async {
            final interestRateYet = await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => MortgageInterestRatePage()));
            if (interestRateYet != null) {
              setState(() {
                interestRate = interestRateYet!;
              });
            }
          }),
          Text("Interest Rate: ${interestRate != null ? (interestRate! * Decimal.fromInt(100)).toStringAsFixed(2)  : "unknown"}%"),
        ]),
        const SizedBox(height: 12),
        ElevatedButton(child: const Text("Done"), onPressed: () {
          try {
            Decimal.parse(_textControllerAmount.text);
          } on FormatException {
            // ignore error
          }

          if (_textControllerAmount.text.isNotEmpty && interestRate != null && years != null) {
            Navigator.pop(context, Mortgage(amount: Decimal.parse(_textControllerAmount.text), rate: interestRate!, years: years!));
            setState(() {
              interestRate = null;
              years = 30;
            });
            return;
          }
        }),
      ])),
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
      infoWidgets.add(Text("Rate: ${_mortgage!.rate * Decimal.fromInt(100)}%"));
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
          ElevatedButton(child: const Text("Modify Data"), onPressed: () async {
            final mortgage = await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => MortgageForm()));
            if (mortgage != null) {
              setState(() {
                _mortgage = mortgage;
              });
            }
          }),
        ],
      ),
    );
  }
}
