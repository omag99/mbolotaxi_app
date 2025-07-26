import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart'; // Assurez-vous que ce fichier est bien importé

class UserProfilePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserProfilePage({super.key});

  Future<Map<String, String>> _getUserData() async {
    User? user = _auth.currentUser;
    if (user == null) {
      print("Aucun utilisateur connecté.");
      return {"name": "Non connecté", "email": "Non connecté"};
    }

    try {
      // Vérification de l'existence du document utilisateur dans Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        print("Données utilisateur récupérées: ${data['name']}");  // Debug
        return {
          "name": data['name'] ?? "Nom inconnu",
          "email": user.email ?? "Email inconnu",
        };
      } else {
        print("Document utilisateur non trouvé.");
        return {"name": "Utilisateur inconnu", "email": user.email ?? "Email inconnu"};
      }
    } catch (e) {
      print("Erreur de récupération des données: $e");
      return {"name": "Erreur de chargement", "email": "Erreur de chargement"};
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Redirection propre
          (Route<dynamic> route) => false, // Supprime toutes les pages précédentes
    );
  }

  Future<void> _resetPassword(BuildContext context) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _auth.sendPasswordResetEmail(email: user.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email de réinitialisation envoyé")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text("Profil utilisateur", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text("Erreur de chargement des données."));
          }

          String name = snapshot.data!["name"]!;
          String email = snapshot.data!["email"]!;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(height: 30),
                      Text(
                        'Mon Profil',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Icon(Icons.account_circle, size: 100, color: Colors.blue),
                      SizedBox(height: 20),
                      Text("Nom: $name", style: TextStyle(fontSize: 18)),
                      Text("Email: $email", style: TextStyle(fontSize: 18)),
                      SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: () => _resetPassword(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          padding: EdgeInsets.symmetric(vertical: 15),
                          textStyle: TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text("Changer de mot de passe", style: TextStyle(color: Colors.white)),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _signOut(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          textStyle: TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text("Se déconnecter", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
