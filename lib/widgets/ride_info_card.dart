import 'package:flutter/material.dart';
import 'package:mbolotaxi_app/widgets/rider_info_card.dart'; // Assure-toi du bon chemin
import '../screens/ride_info_screen.dart';

class ExemplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Exemple')),
      body: Center(
        child: RiderInfoCard(
          riderName: 'John Doe',
          riderPhotoUrl: 'https://example.com/john_doe.jpg', // Remplace par une URL réelle
          rating: 4.5,
        ),
      ),
    );
  }
}