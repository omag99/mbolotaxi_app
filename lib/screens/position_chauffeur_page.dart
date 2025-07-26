import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PositionChauffeurPage extends StatefulWidget {
  @override
  _PositionChauffeurPageState createState() => _PositionChauffeurPageState();
}

class _PositionChauffeurPageState extends State<PositionChauffeurPage> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<QuerySnapshot>? _chauffeursStreamSubscription;
  List<DocumentSnapshot> _chauffeursList = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndStream();
    _listenToChauffeursPositions();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _chauffeursStreamSubscription?.cancel();
    super.dispose();
  }

  /// Récupère et suit la position du chauffeur connecté
  Future<void> _getCurrentLocationAndStream() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Le service de localisation est désactivé.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Permission de localisation refusée.");
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      print("Permission de localisation refusée définitivement.");
      return;
    }

    Position initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(initialPosition.latitude, initialPosition.longitude);
      _updateMarkers();
    });

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // 🔽 Mettre à jour toutes les 5m
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _updateMarkers();
      });
      _updateFirestoreLocation(_currentPosition!);
    });
  }

  /// Écoute les mises à jour des positions des chauffeurs en temps réel depuis Firestore
  void _listenToChauffeursPositions() {
    _chauffeursStreamSubscription = FirebaseFirestore.instance
        .collection('chauffeurs')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _chauffeursList = snapshot.docs;
        _updateMarkers();
      });
    });
  }

  /// Met à jour la position du chauffeur connecté dans Firestore
  Future<void> _updateFirestoreLocation(LatLng location) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance.collection('chauffeurs').doc(userId).set(
          {'latitude': location.latitude, 'longitude': location.longitude},
          SetOptions(merge: true), // ✅ Merge pour ne pas écraser d'autres données
        );
      }
    } catch (e) {
      print("Erreur lors de la mise à jour de Firestore : $e");
    }
  }

  /// Met à jour les marqueurs sur la carte
  void _updateMarkers() {
    _markers.clear();

    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId("currentLocation"),
          position: _currentPosition!,
          infoWindow: const InfoWindow(title: "Votre position"),
        ),
      );
    }

    for (var chauffeur in _chauffeursList) {
      try {
        final latitude = chauffeur.get('latitude');
        final longitude = chauffeur.get('longitude');
        final chauffeurId = chauffeur.id;
        final nom = chauffeur.get('nom') ?? 'Chauffeur inconnu';

        if (latitude != null && longitude != null) {
          final chauffeurPosition = LatLng(latitude, longitude);
          _markers.add(
            Marker(
              markerId: MarkerId(chauffeurId),
              position: chauffeurPosition,
              infoWindow: InfoWindow(title: nom),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            ),
          );
        }
      } catch (e) {
        print("Erreur lors de l'ajout du marqueur : $e");
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Position Chauffeur'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Barre de recherche
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Recherche',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Carte Google Maps
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition ?? const LatLng(48.8566, 2.3522), // Paris par défaut
                    zoom: 14.0,
                  ),
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    if (_currentPosition != null) {
                      _mapController!.animateCamera(
                        CameraUpdate.newLatLngZoom(_currentPosition!, 15),
                      );
                    }
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Barre de navigation en bas
            Container(
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.home, color: Colors.grey),
                  Icon(Icons.person, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
