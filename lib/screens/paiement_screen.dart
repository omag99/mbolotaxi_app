import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_widget/barcode_widget.dart'; // Pour le code-barres

class PaiementPage extends StatefulWidget {
  @override
  _PaiementPageState createState() => _PaiementPageState();
}

class _PaiementPageState extends State<PaiementPage> {
  double _montant = 0;
  bool _paiementEnCours = false;
  bool _paiementReussi = false;

  // Simulateur d'ID du taxi/chauffeur (à remplacer par une valeur réelle)
  final String _taxiId = "TAXI-1234";

  Future<void> _simulerPaiement(BuildContext context) async {
    setState(() {
      _paiementEnCours = true;
    });

    // Simuler un délai de traitement (par exemple, 2 secondes)
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _paiementEnCours = false;
      _paiementReussi = true;
    });

    // Afficher une boîte de dialogue de succès
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Paiement Réussi'),
          content: Text('Le paiement de $_montant a été effectué avec succès pour le taxi $_taxiId.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paiement', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red, // Titre en rouge
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Montant à payer:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            TextFormField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Entrez le montant',
                border: OutlineInputBorder(),
              ),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              onChanged: (value) {
                setState(() {
                  _montant = double.tryParse(value) ?? 0;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _montant > 0 && !_paiementEnCours
                  ? () => _simulerPaiement(context)
                  : null,
              child: _paiementEnCours
                  ? CircularProgressIndicator()
                  : Text('Payer via Airtel Money (USSD)'),
            ),
            SizedBox(height: 20),
            Text('Ou payer avec un code-barres:'),
            SizedBox(height: 10),
            BarcodeWidget(
              barcode: Barcode.code128(), // Type de code-barres
              data: 'TAXI:$_taxiId-MONTANT:$_montant', // Données du code-barres (Taxi ID + Montant)
              width: 200,
              height: 80,
              drawText: false, // Ne pas afficher le texte sous le code-barres
            ),
            SizedBox(height: 10),
            Text('Scannez ce code avec votre application Airtel Money'),
          ],
        ),
      ),
    );
  }
}