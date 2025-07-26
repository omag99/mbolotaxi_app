import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GestionChauffeursPage extends StatefulWidget {
  @override
  _GestionChauffeursPageState createState() => _GestionChauffeursPageState();
}

class _GestionChauffeursPageState extends State<GestionChauffeursPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? _currentUser;

  final CollectionReference chauffeursCollection =
  FirebaseFirestore.instance.collection('Taxis'); // Collection "Taxis"

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Center(child: Text('Aucun utilisateur connecté'));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text('Gestion des Chauffeurs', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: chauffeursCollection.where('id', isEqualTo: _currentUser!.uid).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Une erreur s\'est produite'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Aucun chauffeur trouvé.'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = snapshot.data!.docs[index];
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15.0),
                    title: Text(
                      data['nom'] ?? 'Nom inconnu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 20, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text('Téléphone: ${data['numero'] ?? 'Non renseigné'}'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.car_repair, size: 20, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text('Modèle de véhicule: ${data['modele'] ?? 'Non renseigné'}'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.confirmation_number, size: 20, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text('Matricule: ${data['matricule'] ?? 'Non renseigné'}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
