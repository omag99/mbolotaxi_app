import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mbolotaxi_app/screens/home_screen.dart';
import 'package:mbolotaxi_app/screens/login_screen.dart';
import 'package:mbolotaxi_app/screens/paiement_screen.dart';
import 'package:mbolotaxi_app/screens/signup_screen.dart';
import 'firebase_options.dart';
import 'package:mbolotaxi_app/screens/accueil_page.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les variables d'environnement
  // await dotenv.load();

  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Vérification de la plateforme et chargement de la clé API appropriée
  // String? googleApiKey = (kIsWeb)
  //   ? dotenv.env['GOOGLE_MAPS_API_KEY_WEB'];
  //     : dotenv.env['GOOGLE_MAPS_API_KEY_ANDROID'];

  // Vérification de la clé API
  ////if (googleApiKey == null || googleApiKey.isEmpty) {
  // print("Clé API Google Maps manquante");
  //} else {
  // print("Clé API Google Maps chargée : $googleApiKey");
  // }//

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mbolo Taxi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      routes: {
        '/signup': (context) => SignUpPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/accueil': (context) => AccueilPage(),
      },
      debugShowCheckedModeBanner: false, // Ajout de cette ligne
    );
  }
}