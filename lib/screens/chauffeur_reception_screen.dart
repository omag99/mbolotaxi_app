import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class ChauffeurReceptionPage extends StatefulWidget {
  @override
  _ChauffeurReceptionPageState createState() => _ChauffeurReceptionPageState();
}

class _ChauffeurReceptionPageState extends State<ChauffeurReceptionPage> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  StreamSubscription<QuerySnapshot>? _demandesSubscription;
  String? chauffeurId;
  LatLng? chauffeurPosition;
  List<DocumentSnapshot> demandesEnAttente = [];

  @override
  void initState() {
    super.initState();
    _initializeChauffeur();
  }

  @override
  void dispose() {
    _demandesSubscription?.cancel();
    super.dispose();
  }

  /// Récupère l'ID du chauffeur et démarre l'écoute des commandes
  void _initializeChauffeur() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        chauffeurId = user.uid;
      });
      print("✅ Chauffeur ID: $chauffeurId");
      _startListeningForDemandes();
      _startTrackingChauffeurPosition();
    } else {
      print("❌ Aucun utilisateur connecté !");
    }
  }

  /// Écoute les commandes en attente
  void _startListeningForDemandes() {
    if (chauffeurId == null) return;

    _demandesSubscription = FirebaseFirestore.instance
        .collection('demandes')
        .where('statut', isEqualTo: 'En attente')
        .where('chauffeur_id', isEqualTo: chauffeurId)  // 🔴 Retiré temporairement pour voir toutes les demandes
        .snapshots()
        .listen((snapshot) {
      print("🔄 Nombre de demandes en attente: ${snapshot.docs.length}");
      setState(() {
        demandesEnAttente = snapshot.docs;
      });
    }, onError: (error) {
      print("❌ Erreur lors de la récupération des demandes: $error");
    });
  }

  /// Récupère la position du chauffeur et met à jour la carte
  Future<void> _startTrackingChauffeurPosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print("❌ Permission de localisation refusée !");
      return;
    }

    Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        chauffeurPosition = LatLng(position.latitude, position.longitude);
        _updateChauffeurMarker();
      });
    });
  }

  /// Met à jour le marqueur du chauffeur sur la carte
  void _updateChauffeurMarker() {
    if (chauffeurPosition == null || mapController == null) return;

    setState(() {
      markers.removeWhere((marker) => marker.markerId == MarkerId('chauffeur'));
      markers.add(Marker(
        markerId: MarkerId('chauffeur'),
        position: chauffeurPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: "Votre Position"),
      ));
    });

    mapController?.animateCamera(CameraUpdate.newLatLng(chauffeurPosition!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réception des commandes')),
      body: Stack(
        children: [
          // Carte Google Maps
          Positioned.fill(
            child: GoogleMap(
              onMapCreated: (controller) => mapController = controller,
              initialCameraPosition: const CameraPosition(
                target: LatLng(0.3934, 9.4537), // Libreville, Gabon
                zoom: 12.0,
              ),
              markers: markers,
              myLocationEnabled: true,
            ),
          ),

          // Card affichant les informations de la première commande
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.all(12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              width: double.infinity,
              height: 160, // Ajuster la hauteur si nécessaire
              child: (demandesEnAttente.isNotEmpty)
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nouvelle demande en attente',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Nom: ${demandesEnAttente[0]['client_name']}'),
                  Text('Numéro: ${demandesEnAttente[0]['client_phone']}'),
                  Text('Destination: ${demandesEnAttente[0]['destination']}'),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await demandesEnAttente[0].reference.update({'statut': 'acceptee'});
                          setState(() {
                            demandesEnAttente.removeAt(0);
                          });
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: Text('Accepter'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await demandesEnAttente[0].reference.update({'statut': 'refusee'});
                          setState(() {
                            demandesEnAttente.removeAt(0);
                          });
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: Text('Refuser'),
                      ),
                    ],
                  ),
                ],
              )
                  : Center(child: Text('Aucune demande en attente')),
            ),
          ),
        ],
      ),
    );
  }
}
