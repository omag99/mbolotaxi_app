import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbolotaxi_app/screens/chauffeur_page.dart';
import 'package:mbolotaxi_app/screens/position_chauffeur_page.dart';
import 'package:mbolotaxi_app/screens/paiement_screen.dart';
import 'package:mbolotaxi_app/screens/course_en_cours_screen.dart';
import 'package:mbolotaxi_app/screens/clients_page.dart';
import 'package:mbolotaxi_app/screens/profil_screen.dart';
import 'chauffeur_reception_screen.dart';
import 'course_termine_dart.dart';
import 'gestionchauffeur.dart';

class AccueilPage extends StatefulWidget {
  @override
  _AccueilPageState createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  int _selectedIndex = 0;
  GoogleMapController? mapController;
  LatLng _currentPosition = const LatLng(0, 0);
  bool _isLoadingLocation = true;
  TextEditingController _searchController = TextEditingController();
  String? selectedChauffeurId;
  String? userRole;
  bool _isLoadingRole = true; // Ajout d'un indicateur de chargement du rôle

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getUserRole();
  }

  // Fonction pour récupérer le rôle de l'utilisateur
  Future<void> _getUserRole() async {
    setState(() {
      _isLoadingRole = true; // Indique que le chargement du rôle a commencé
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            userRole = userDoc['role'];
          });
          print("Rôle de l'utilisateur récupéré : $userRole");
        } else {
          print("Document utilisateur non trouvé pour l'UID: ${user.uid}");
          userRole = null; // Ou une valeur par défaut si aucun rôle n'est trouvé
        }
      } catch (e) {
        print("Erreur lors de la récupération du rôle de l'utilisateur: $e");
        userRole = null; // Gérer l'erreur et définir une valeur par défaut
      }
    } else {
      print("Aucun utilisateur connecté.");
      userRole = null; // Gérer le cas où aucun utilisateur n'est connecté
    }
    setState(() {
      _isLoadingRole = false; // Indique que le chargement du rôle est terminé
    });
  }

  // Fonction pour obtenir la position actuelle de l'utilisateur
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition, 15));
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRole) {
      // Afficher un indicateur de chargement tant que le rôle est en cours de récupération
      return Scaffold(
        appBar: AppBar(title: const Text('Mbolotaxi'), backgroundColor: Colors.blue),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mbolotaxi'), backgroundColor: Colors.blue),
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Mbolotaxi',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            // Options communes aux clients et aux chauffeurs
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Gestion du profil'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage()));
              },
            ),

            // Afficher un indicateur de chargement pendant la récupération du rôle
            if (_isLoadingRole)
              const CircularProgressIndicator()
            else if (userRole == null)
              const ListTile(
                leading: Icon(Icons.error),
                title: Text('Rôle non défini'),
              )
            else
            // Options selon le rôle
              ...[
                if (userRole == 'client') ...[
                  ListTile(
                    leading: const Icon(Icons.payment),
                    title: const Text('Paiement'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PaiementPage()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text('Position Chauffeur'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PositionChauffeurPage()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('commander un taxis'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CommandeTaxiPage()));
                    },
                  ),
                ]
                else if (userRole == 'chauffeur') ...[
                  ListTile(
                    leading: const Icon(Icons.directions),
                    title: const Text('Course en Cours'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CourseEnCoursPage()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.done),
                    title: const Text('Course Terminée'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CourseTerminePage()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.drive_eta),
                    title: const Text('Enregistrer mon véhicule'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChauffeurPage()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.manage_history),
                    title: const Text('Gestion Chauffeur'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => GestionChauffeursPage()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.call_received),
                    title: const Text('Réception'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChauffeurReceptionPage()));
                    },
                  ),
                ]
                else
                  const ListTile(
                    leading: Icon(Icons.error),
                    title: Text('Rôle non défini'),
                  ),
              ],
          ],
        ),
      ),
      body: Center(
        child: _isLoadingLocation
            ? const CircularProgressIndicator()
            : GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 15),
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
          },
          markers: {
            Marker(
              markerId: MarkerId("currentLocation"),
              position: _currentPosition,
              infoWindow: InfoWindow(title: "Votre Position"),
            ),
          },
        ),
      ),
    );
  }
}
