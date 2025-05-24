import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  LocationPage({super.key});

  Stream<DocumentSnapshot> _getBusLocation(String busNumber) {
    return _firestore.collection('bus_locations')
        .doc(busNumber)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    // Replace with actual bus number from user data
    const String busNumber = 'A-1346';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Location'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _getBusLocation(busNumber),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Bus location not available'));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          LatLng busLocation = LatLng(data['latitude'], data['longitude']);

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: busLocation,
              zoom: 15,
            ),
            markers: {
              Marker(
                markerId: MarkerId(busNumber),
                position: busLocation,
                infoWindow: InfoWindow(title: 'Bus $busNumber'),
              ),
            },
          );
        },
      ),
    );
  }
}







// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class LocationPage extends StatefulWidget {
//   const LocationPage({super.key});
//
//   @override
//   State<LocationPage> createState() => _LocationPageState();
// }
//
// class _LocationPageState extends State<LocationPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   late GoogleMapController _mapController;
//   String? _busNumber;
//   Set<Marker> _markers = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _loadBusNumber();
//   }
//
//   Future<void> _loadBusNumber() async {
//     final user = _auth.currentUser;
//     if (user == null) return;
//
//     final userDoc = await _firestore.collection('users').doc(user.uid).get();
//     setState(() => _busNumber = userDoc.data()?['busNumber']);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Bus Location'),
//         backgroundColor: Colors.teal,
//       ),
//       body: _busNumber == null
//           ? const Center(child: Text('No bus assigned'))
//           : StreamBuilder<DocumentSnapshot>(
//         stream: _firestore.collection('bus_locations')
//             .doc(_busNumber)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           final location = snapshot.data!.data() as Map<String, dynamic>?;
//           if (location == null) {
//             return const Center(child: Text('Location not available'));
//           }
//
//           final latLng = LatLng(location['latitude'], location['longitude']);
//
//           if (_markers.isEmpty) {
//             _markers.add(
//               Marker(
//                 markerId: MarkerId(_busNumber!),
//                 position: latLng,
//                 infoWindow: InfoWindow(title: 'Bus $_busNumber'),
//               ),
//             );
//           } else {
//             _mapController.animateCamera(CameraUpdate.newLatLng(latLng));
//           }
//
//           return GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: latLng,
//               zoom: 15,
//             ),
//             markers: _markers,
//             onMapCreated: (controller) => _mapController = controller,
//           );
//         },
//       ),
//     );
//   }
// }
//
//
//
// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// //
// // class LocationPage extends StatelessWidget {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //
// //    LocationPage({super.key});
// //
// //   Stream<DocumentSnapshot> _getBusLocation(String busNumber) {
// //     return _firestore.collection('bus_locations')
// //         .doc(busNumber)
// //         .snapshots();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     // Replace with actual bus number from user data
// //     const String busNumber = 'A-1346';
// //
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Bus Location'),
// //         backgroundColor: Colors.teal,
// //       ),
// //       body: StreamBuilder<DocumentSnapshot>(
// //         stream: _getBusLocation(busNumber),
// //         builder: (context, snapshot) {
// //           if (snapshot.hasError) {
// //             return Center(child: Text('Error: ${snapshot.error}'));
// //           }
// //
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return const Center(child: CircularProgressIndicator());
// //           }
// //
// //           if (!snapshot.hasData || !snapshot.data!.exists) {
// //             return const Center(child: Text('Bus location not available'));
// //           }
// //
// //           var data = snapshot.data!.data() as Map<String, dynamic>;
// //           LatLng busLocation = LatLng(data['latitude'], data['longitude']);
// //
// //           return GoogleMap(
// //             initialCameraPosition: CameraPosition(
// //               target: busLocation,
// //               zoom: 15,
// //             ),
// //             markers: {
// //               Marker(
// //                 markerId: MarkerId(busNumber),
// //                 position: busLocation,
// //                 infoWindow: InfoWindow(title: 'Bus $busNumber'),
// //               ),
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }