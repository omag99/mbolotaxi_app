import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mbolotaxi_app/models/user.dart' as CustomUser;  // Alias pour le modèle personnalisé

// Enum pour les rôles d'utilisateur
enum UserRole {
  client,
  chauffeur,
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  UserRole _role = UserRole.client; // Par défaut, le rôle est "Client"
  bool _isLoading = false;

  // Fonction d'inscription
  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Créer un nouvel utilisateur avec Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;  // L'utilisateur retourné par Firebase Auth

      if (user != null) {
        // Récupérer la localisation de l'utilisateur
        GeoPoint localisation = await CustomUser.User.getCurrentLocation();

        // Convertir l'enum UserRole en chaîne pour Firestore
        String roleString = _role.toString().split('.').last;

        // Sauvegarder les données de l'utilisateur dans Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': roleString, // Sauvegarde du rôle choisi (sous forme de chaîne)
          'localisation': localisation, // Sauvegarde de la localisation
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Redirection selon le rôle choisi
        if (_role == UserRole.chauffeur) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Erreur lors de l'inscription")),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text("Inscription", style: TextStyle(color: Colors.white)),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: 10),
                      Text(
                        'Créer un compte',
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
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nom',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: const Icon(Icons.lock),
                        title: TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          obscureText: true,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Boutons pour choisir le rôle (Client ou Chauffeur)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: const Text("Client"),
                            selected: _role == UserRole.client,
                            onSelected: (selected) {
                              setState(() {
                                _role = UserRole.client;
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          ChoiceChip(
                            label: const Text("Chauffeur"),
                            selected: _role == UserRole.chauffeur,
                            onSelected: (selected) {
                              setState(() {
                                _role = UserRole.chauffeur;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Bouton d'inscription
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            textStyle: const TextStyle(fontSize: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("S'inscrire", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
