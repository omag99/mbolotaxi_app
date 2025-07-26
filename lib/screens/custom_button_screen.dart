import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final LinearGradient? gradient; // Ajout de l'argument gradient
  final double borderRadius; // Ajout de l'argument borderRadius
  final Color textColor;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.gradient,
    this.borderRadius = 0.0,
    this.textColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor, // Couleur de fond par défaut
        gradient: gradient, // Applique le dégradé s'il est fourni
        borderRadius: BorderRadius.circular(borderRadius), // Applique la bordure arrondie
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Important: rendre le fond du bouton transparent
          shadowColor: Colors.transparent, // Supprimer l'ombre par défaut du bouton
          padding: EdgeInsets.symmetric(vertical: 16),
          textStyle: TextStyle(fontSize: 18),
          foregroundColor: textColor,
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}