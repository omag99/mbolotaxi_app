import 'package:mbolotaxi_app/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:mbolotaxi_app/models/user.dart'; // Assure-toi que le chemin est correct
import 'package:provider/provider.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Exemple d'inscription
                final authService = Provider.of<AuthService>(context, listen: false);
                User? user = await authService.signInWithEmailAndPassword(
                  'test@example.com',
                  'password123',
                  //'Test User',
                  //'123-456-7890',
                  //'client',
                );
                if (user != null) {
                  print('Inscription réussie: ${user.email}');
                } else {
                  print('Inscription échouée.');
                }
              },
              child: const Text('Sign Up'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Exemple de connexion
                final authService = Provider.of<AuthService>(context, listen: false);
                User? user = await authService.signInWithEmailAndPassword(
                  'test@example.com',
                  'password123',
                );
                if (user != null) {
                  print('Connexion réussie: ${user.email}');
                } else {
                  print('Connexion échouée.');
                }
              },
              child: const Text('Sign In'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Exemple de déconnexion
                final authService = Provider.of<AuthService>(context, listen: false);
                await authService.signOut();
                print('Déconnexion réussie.');
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthService {
  signInWithEmailAndPassword(String s, String t) {}

  signOut() {}
}