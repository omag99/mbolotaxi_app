import 'package:flutter/material.dart';

class RiderInfoCard extends StatelessWidget {
  final String riderName;
  final String? riderPhotoUrl; // URL de la photo de profil (optionnelle)
  final double? rating; // Note du client (optionnelle)

  const RiderInfoCard({
    Key? key,
    required this.riderName,
    this.riderPhotoUrl,
    this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Photo de profil
            CircleAvatar(
              radius: 30,
              backgroundImage: riderPhotoUrl != null
                  ? NetworkImage(riderPhotoUrl!)
                  : AssetImage('assets/images/default_profile.png') as ImageProvider, // Image par défaut
            ),
            SizedBox(width: 16.0),
            // Nom et note
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    riderName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (rating != null) // Afficher la note seulement si elle est disponible
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber),
                        Text(
                          rating != null ? rating!.toStringAsFixed(1) : 'N/A', // Afficher "N/A" si rating est null
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}