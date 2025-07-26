import 'package:flutter/material.dart';
import 'package:mbolotaxi_app/screens/signup_screen.dart';
import 'package:mbolotaxi_app/screens/custom_button_screen.dart'; // Assurez-vous qu'il est correctement stylisé
import 'login_screen.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Conserver la couleur de fond
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Logo (légèrement agrandi et avec une ombre subtile)
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo_mysalesoft.png',
                  height: 160, // Légèrement plus grand
                ),
              ),
              const SizedBox(height: 30),

              // Titre (style existant, mais avec une couleur plus riche)
              Text(
                'Bienvenue dans votre application Mbolotaxi !',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800], // Couleur plus riche
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Boutons (avec un dégradé subtil et une bordure arrondie)
              CustomButton(
                text: 'S\'inscrire',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  );
                },
                backgroundColor: Colors.blue[700], // Laisser la couleur gérée par CustomButton
                // Ajout d'un style de dégradé au CustomButton (nécessite une modification du CustomButton)
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[500]!],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: 10.0, // Bordure arrondie
                textColor: Colors.white, // Assurez-vous que CustomButton le prend en charge
              ),
              const SizedBox(height: 10),

              CustomButton(
                text: 'Se connecter',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                backgroundColor: Colors.blue[700], // Laisser la couleur gérée par CustomButton
                // Ajout d'un style de dégradé au CustomButton (nécessite une modification du CustomButton)
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[500]!],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: 10.0, // Bordure arrondie
                textColor: Colors.white, // Assurez-vous que CustomButton le prend en charge
              ),
            ],
          ),
        ),
      ),
    );
  }
}