import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CourseEnCoursPage extends StatefulWidget {
  const CourseEnCoursPage({super.key});

  @override
  State<CourseEnCoursPage> createState() => _CourseEnCoursPageState();
}

class _CourseEnCoursPageState extends State<CourseEnCoursPage> {
  final User? _chauffeur = FirebaseAuth.instance.currentUser;
  GoogleMapController? _mapController;
  LatLng? _positionChauffeur;
  LatLng? _positionClient;
  final Set<Marker> _markers = {};
  String? googleApiKey;
  Map<String, dynamic>? _commandeEnCours;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
    _getCurrentLocation();
    _getCourseEnCours();
  }

  Future<void> _loadApiKey() async {
    try {
      await dotenv.load();
      googleApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
      if (googleApiKey == null || googleApiKey!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Clé API Google Maps non trouvée dans .env")),
        );
      }
    } catch (e) {
      print("Erreur lors du chargement du fichier .env : $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Activez la localisation")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission de localisation refusée")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Activez la localisation dans les paramètres")),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (mounted) {
      setState(() {
        _positionChauffeur = LatLng(position.latitude, position.longitude);
      });
      _updateMarkers();
      _centerMap();
    }
  }

  Future<void> _getCourseEnCours() async {
    if (_chauffeur == null) return;

    FirebaseFirestore.instance
        .collection('commandes')
        .where('chauffeurId', isEqualTo: _chauffeur!.uid)
        .where('statut', isEqualTo: 'en cours')
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var commande = snapshot.docs.first;
        Map<String, dynamic> data = commande.data();
        print("Commande en cours : $data");

        setState(() {
          _positionClient = LatLng(data['clientLatitude'], data['clientLongitude']);
          _commandeEnCours = data;
        });
        _updateMarkers();
        _centerMap();
      } else {
        print("Aucune commande en cours pour ce chauffeur");
      }
    }).catchError((error) {
      print("Erreur lors de la récupération des commandes en cours : $error");
    });
  }

  void _updateMarkers() {
    if (!mounted) return;

    setState(() {
      _markers.clear();

      if (_positionChauffeur != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId("chauffeur"),
            position: _positionChauffeur!,
            infoWindow: const InfoWindow(title: "Votre position"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      }

      if (_positionClient != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId("client"),
            position: _positionClient!,
            infoWindow: const InfoWindow(title: "Client"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }
    });
  }

  void _centerMap() {
    if (_mapController != null && _positionChauffeur != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_positionChauffeur!, 14),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mes courses en cours")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 14,
            ),
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _centerMap();
            },
          ),
          if (_commandeEnCours != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Client: ${_commandeEnCours!['clientNom']}",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text("Destination: ${_commandeEnCours!['destination']}",
                          style: TextStyle(fontSize: 14)),
                      Text("Prix: ${_commandeEnCours!['prix']} cfa",
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
