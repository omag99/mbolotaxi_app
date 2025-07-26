import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbolotaxi_app/screens/accueil_page.dart'; // Assurez-vous que ce chemin est correct
import 'package:firebase_auth/firebase_auth.dart'; // Importez Firebase Auth


class ChauffeurPage extends StatefulWidget {
  @override
  _ChauffeurPageState createState() => _ChauffeurPageState();
}

class _ChauffeurPageState extends State<ChauffeurPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _modeleController = TextEditingController();
  final TextEditingController _matriculeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text('Information sur le vehicule', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const SizedBox(height: 10),
                        Text(
                          'Informations du chauffeur',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: TextFormField(
                            controller: _nomController,
                            decoration: InputDecoration(
                              labelText: 'Nom du chauffeur',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer le nom du chauffeur';
                              }
                              return null;
                            },
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: TextFormField(
                            controller: _numeroController,
                            decoration: InputDecoration(
                              labelText: 'Numéro de téléphone',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer le numéro de téléphone';
                              }
                              return null;
                            },
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.directions_car),
                          title: TextFormField(
                            controller: _modeleController,
                            decoration: InputDecoration(
                              labelText: 'Modèle du véhicule',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer le modèle du véhicule';
                              }
                              return null;
                            },
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.local_police),
                          title: TextFormField(
                            controller: _matriculeController,
                            decoration: InputDecoration(
                              labelText: 'Matricule du véhicule',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer le matricule du véhicule';
                              }
                              return null;
                            },
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Adresse email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer une adresse email';
                              }
                              if (!value.contains('@')) {
                                return 'Veuillez entrer une adresse email valide';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: _isLoading ? null : () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              setState(() {
                                _isLoading = true;
                              });

                              try {
                                // Utiliser l'UID de l'utilisateur connecté comme ID du chauffeur
                                final User? user = FirebaseAuth.instance.currentUser;
                                if (user == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Aucun utilisateur connecté. Veuillez vous connecter.')),
                                  );
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  return;
                                }

                                final String chauffeurId = user.uid;

                                await FirebaseFirestore.instance.collection('Taxis').doc(chauffeurId).set({
                                  'id': chauffeurId,
                                  'nom': _nomController.text,
                                  'numero': _numeroController.text,
                                  'modele': _modeleController.text,
                                  'matricule': _matriculeController.text,
                                  'email': _emailController.text,
                                  'estConnecte': false,
                                  'latitude': 0.0,
                                  'longitude': 0.0,
                                  'distance': "0",
                                  'disponible': true,
                                });

                                // Afficher un message de succès
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Chauffeur ajouté avec succès !')),
                                );

                                // Après l'ajout du chauffeur, naviguer vers l'AccueilPage
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => AccueilPage()),
                                );


                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erreur lors de l\'ajout du chauffeur : $e')),
                                );
                              } finally {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            textStyle: const TextStyle(fontSize: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                              : const Text('Sauvegarder', style: TextStyle(color: Colors.white)),

                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _numeroController.dispose();
    _modeleController.dispose();
    _matriculeController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}