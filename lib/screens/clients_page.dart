import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // Import pour lancer l'URL

class CommandeTaxiPage extends StatefulWidget {
  const CommandeTaxiPage({super.key});

  @override
  _CommandeTaxiPageState createState() => _CommandeTaxiPageState();
}

class _CommandeTaxiPageState extends State<CommandeTaxiPage> {
  final _formKey = GlobalKey<FormState>();
  String _typeService = 'Course seule';
  String _nomClient = '';
  String _telephone = '';
  DateTime? _dateHeure;
  String _lieuDepart = '';
  String _destination = '';
  double _montant = 0.0;
  bool _autorisationContact = false;
  LatLng? _positionActuelle;
  bool _isLoading = false;
  bool _commandeEnvoyee = false;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _montantController = TextEditingController(); // Controller pour le montant proposé.

  // Variables pour la sélection du chauffeur
  String? _chauffeurSelectionne;
  List<String> _chauffeurs = [];
  Map<String, dynamic>? _chauffeurInfo;
  String? _chauffeurId;

  // Variables pour le mode de paiement
  String _modePaiement = 'Entrer le montant'; // Valeur par défaut
  double? _montantPropose; // Variable pour stocker le montant proposé

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadChauffeurs();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permission de localisation refusée.")),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _positionActuelle = LatLng(position.latitude, position.longitude);
      _lieuDepart = "${position.latitude}, ${position.longitude}";
    });
  }

  Future<void> _loadChauffeurs() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'chauffeur')
          .get();

      List<String> chauffeursList = [];
      for (var doc in querySnapshot.docs) {
        chauffeursList.add(doc['name'] ?? 'Nom inconnu');
      }

      setState(() {
        _chauffeurs = chauffeursList;
      });
    } catch (e) {
      print("Erreur lors du chargement des chauffeurs: $e");
    }
  }

  Future<void> _loadChauffeurInfo(String chauffeurNom) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: chauffeurNom)
          .where('role', isEqualTo: 'chauffeur')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot chauffeurDoc = querySnapshot.docs.first;
        setState(() {
          _chauffeurId = chauffeurDoc.id;
        });

        _loadChauffeurVehicleInfo();
      }
    } catch (e) {
      print("Erreur lors du chargement des informations du chauffeur: $e");
    }
  }

  Future<void> _loadChauffeurVehicleInfo() async {
    if (_chauffeurId == null) return;

    try {
      DocumentSnapshot vehicleDoc = await FirebaseFirestore.instance
          .collection('Taxis')
          .doc(_chauffeurId)
          .get();

      if (vehicleDoc.exists) {
        setState(() {
          _chauffeurInfo = {
            'modele': vehicleDoc['modele'] ?? 'Modèle non disponible',
            'matricule': vehicleDoc['matricule'] ?? 'Matricule non disponible',
            'numero': vehicleDoc['numero'] ?? 'Numéro non disponible',
          };
        });
      }
    } catch (e) {
      print("Erreur lors du chargement des informations du véhicule: $e");
    }
  }


  //Fonction pour lancer Airtel Money
  Future<void> _lancerAirtelMoney() async {
    //TODO : Ajouter la logique et l'URL d'airtel money pour lancer le paiement via airtel money
    final Uri airtelMoneyUri = Uri(
      scheme: 'https',
      host: 'www.example.com',//Remplacer par l'URL d'airtel money
      path: '/payment',
      queryParameters: {
        'amount': _montantPropose?.toString() ?? '0.0',
        'telephone': _telephone,
      },
    );

    if (await canLaunchUrl(airtelMoneyUri)) {
      await launchUrl(airtelMoneyUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de lancer Airtel Money.')),
      );
    }
  }


  void _envoyerCommande() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final commande = {
        'type_service': _typeService,
        'nom_client': _nomClient,
        'telephone': _telephone,
        'date_heure': _dateHeure?.toIso8601String(),
        'lieu_depart': _lieuDepart,
        'destination': _destination,
        'montant': _montant,
        'autorisation_contact': _autorisationContact,
        'chauffeur': _chauffeurSelectionne,
        'position': _positionActuelle != null ? {'lat': _positionActuelle!.latitude, 'lng': _positionActuelle!.longitude} : null,
        'status': 'En attente',
        'mode_paiement': _modePaiement,  // Enregistrer le mode de paiement
        'montant_propose': _montantPropose, // Enregistrer le montant proposé
      };

      await FirebaseFirestore.instance.collection('commandes').add(commande);

      setState(() {
        _commandeEnvoyee = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Commande envoyée avec succès !")));
    } catch (e) {
      print("Erreur lors de l'envoi de la commande : $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur lors de l'envoi de la demande.")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text('Commande Taxi', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (!_commandeEnvoyee) ...[
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Détails de la commande',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: _typeService,
                          onChanged: (value) => setState(() => _typeService = value!),
                          items: ['Course seule', 'Course partagée'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          decoration: InputDecoration(labelText: 'Type de service'),
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Nom du client'),
                          validator: (value) => value!.isEmpty ? 'Veuillez entrer votre nom' : null,
                          onSaved: (value) => _nomClient = value!,
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Numéro de téléphone'),
                          keyboardType: TextInputType.phone,
                          validator: (value) => value!.isEmpty ? 'Veuillez entrer un numéro valide' : null,
                          onSaved: (value) => _telephone = value!,
                        ),
                        TextFormField(
                          controller: _dateController,
                          decoration: InputDecoration(labelText: 'Date et heure'),
                          readOnly: true,
                          onTap: () async {
                            DateTime? selectedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2101));
                            if (selectedDate != null) {
                              TimeOfDay? selectedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                              if (selectedTime != null) {
                                setState(() {
                                  _dateHeure = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
                                  _dateController.text = DateFormat('yyyy-MM-dd HH:mm').format(_dateHeure!);
                                });
                              }
                            }
                          },
                        ),
                        ElevatedButton(onPressed: _getCurrentLocation, child: Text('Obtenir ma position actuelle')),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Destination'),
                          validator: (value) => value!.isEmpty ? 'Veuillez entrer une destination' : null,
                          onSaved: (value) => _destination = value!,
                        ),
                        DropdownButtonFormField<String>(
                          value: _chauffeurSelectionne,
                          onChanged: (value) {
                            setState(() {
                              _chauffeurSelectionne = value;
                              if (value != null) {
                                _loadChauffeurInfo(value);
                              }
                            });
                          },
                          items: _chauffeurs.map((chauffeur) => DropdownMenuItem(value: chauffeur, child: Text(chauffeur))).toList(),
                          decoration: InputDecoration(labelText: 'Choisir un chauffeur'),
                        ),
                        SizedBox(height: 10),

                        // Champs pour le mode de paiement
                        DropdownButtonFormField<String>(
                          value: _modePaiement,
                          onChanged: (value) => setState(() => _modePaiement = value!),
                          items: ['Entrer le montant', 'Airtel Money']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          decoration: InputDecoration(labelText: 'Mode de Paiement'),
                        ),
                        SizedBox(height: 10),

                        //Champ pour le montant propose
                        if (_modePaiement == 'Entrer le montant')
                          TextFormField(
                            controller: _montantController,
                            decoration: InputDecoration(labelText: 'Montant proposé'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un montant.';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Veuillez entrer un nombre valide.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _montantPropose = double.tryParse(value!) ?? 0.0;
                            },
                          ),
                        SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: () {
                            if (_modePaiement == 'Airtel Money') {
                              // Lancer le processus de paiement Airtel Money
                              _formKey.currentState!.save(); // Sauvegarder le montant proposé avant de lancer Airtel Money
                              _montantPropose = double.tryParse(_montantController.text) ?? 0.0;
                              _lancerAirtelMoney();
                            } else {
                              // Envoyer la commande normalement
                              _envoyerCommande();
                            }
                          },
                          child: _isLoading
                              ? CircularProgressIndicator()
                              : Text(_modePaiement == 'Airtel Money' ? 'Payer avec Airtel Money' : 'Envoyer ma commande'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            padding: EdgeInsets.symmetric(vertical: 15),
                            textStyle: TextStyle(fontSize: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Confirmation après l'envoi de la commande
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Commande envoyée avec succès!\n\nVoici un récapitulatif de votre commande:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  title: Text('Type de service'),
                  subtitle: Text(_typeService),
                ),
                ListTile(
                  title: Text('Nom du client'),
                  subtitle: Text(_nomClient),
                ),
                ListTile(
                  title: Text('Téléphone'),
                  subtitle: Text(_telephone),
                ),
                ListTile(
                  title: Text('Date et Heure'),
                  subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(_dateHeure!)),
                ),
                ListTile(
                  title: Text('Lieu de départ'),
                  subtitle: Text(_lieuDepart),
                ),
                ListTile(
                  title: Text('Destination'),
                  subtitle: Text(_destination),
                ),
                ListTile(
                  title: Text('Chauffeur'),
                  subtitle: Text(_chauffeurSelectionne ?? 'Non sélectionné'),
                ),
                if (_chauffeurInfo != null) ...[
                  ListTile(
                    title: Text('Véhicule'),
                    subtitle: Text('Modèle: ${_chauffeurInfo!['modele']}, Matricule: ${_chauffeurInfo!['matricule']}'),
                  ),
                ],
                ListTile(
                  title: Text('Mode de Paiement'),
                  subtitle: Text(_modePaiement),
                ),
                if (_montantPropose != null)
                  ListTile(
                    title: Text('Montant Proposé'),
                    subtitle: Text('${_montantPropose}'),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}