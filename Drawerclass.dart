import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:university_transport_system/qr_code.dart';
import 'Apply_page.dart';
import 'Attendence_page.dart';
//import 'Bus_driver_detail.dart';
import 'Inovice_page.dart';
import 'Profile_page.dart';
import 'Bus_driver_detail.dart';
import 'location_page.dart';
//import 'Invoice_page.dart'; // Make sure to import the InvoicePage

class DrawerClass extends StatefulWidget {
  const DrawerClass({super.key});

  @override
  State<DrawerClass> createState() => _DrawerClassState();
}

class _DrawerClassState extends State<DrawerClass> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _name = 'Loading...';
  String _email = 'Loading...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _name = doc['name'] ?? 'No Name';
          _email = user.email ?? 'No Email';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
              (route) => false
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Drawer(
      width: screenSize.width * 0.75,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.teal,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.teal)
                  : const Icon(Icons.person, size: 42, color: Colors.teal),
            ),
            accountName: Text(_name, style: const TextStyle(fontSize: 18)),
            accountEmail: Text(_email),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildDrawerItem(
                  icon: CupertinoIcons.person,
                  text: 'Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.app_registration_rounded,
                  text: 'Apply for Bus',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ApplyPage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: CupertinoIcons.check_mark_circled,
                  text: 'Attendance',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AttendancePage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.directions_bus_filled_rounded,
                  text: 'Bus/Driver Details',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>  DriverDetailPage(), // Provide actual bus number
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: CupertinoIcons.bell,
                  text: 'Notifications',
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: Icons.request_page,
                  text: 'Invoice',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InvoicePage(
                          studentName: _name, // Use the loaded user name
                          rollNumber: '302-211098', // Replace with actual roll number from your database
                          route: 'Mansehra', // Replace with actual route from your database
                          busNumber: '1346', // Replace with actual bus number from your database
                        ),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.my_location,
                  text: 'Location',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LocationPage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.qr_code,  // Using the QR code icon from Material Icons
                  text: 'QR Code',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QRScannerPage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: CupertinoIcons.square_arrow_right,
                  text: 'Logout',
                  onTap: () => _logout(context),
                ),
                const SizedBox(height: 20),
                _buildQrSection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
      onTap: onTap,
    );
  }

  Widget _buildQrSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: Colors.teal.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _navigateToQrScanner(context),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.qr_code_2, size: 32, color: Colors.teal),
              ),
              const SizedBox(width: 16),
              const Text(
                'Show QR Code',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToQrScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerPage()),
    );
  }
}

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  _QrScannerPageState createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null) {
        await _recordAttendance(scanData.code!);
        controller.dispose();
        Navigator.pop(context);
      }
    });
  }

  Future<void> _recordAttendance(String qrCode) async {
    try {
      await _firestore.collection('attendance').add({
        'qrCode': qrCode,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'verified'
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance recorded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}






// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'Apply_page.dart';
// //import 'Attendance_page.dart';
// import 'Attendence_page.dart';
// import 'Bus_driver_detail.dart';
// import 'Profile_page.dart';
// import 'location_page.dart';
//
// class DrawerClass extends StatefulWidget {
//   const DrawerClass({super.key});
//
//   @override
//   State<DrawerClass> createState() => _DrawerClassState();
// }
//
// class _DrawerClassState extends State<DrawerClass> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   String _name = 'Loading...';
//   String _email = 'Loading...';
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }
//
//   Future<void> _loadUserData() async {
//     User? user = _auth.currentUser;
//     if (user != null) {
//       DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
//       if (doc.exists) {
//         setState(() {
//           _name = doc['name'] ?? 'No Name';
//           _email = user.email ?? 'No Email';
//           isLoading = false;
//         });
//       }
//     }
//   }
//
//   Future<void> _logout(BuildContext context) async {
//     try {
//       await _auth.signOut();
//       Navigator.pushNamedAndRemoveUntil(
//           context,
//           '/login',
//               (route) => false
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Logout failed: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final Size screenSize = MediaQuery.of(context).size;
//     return Drawer(
//       width: screenSize.width * 0.75,
//       child: Column(
//         children: [
//           UserAccountsDrawerHeader(
//             decoration: const BoxDecoration(
//               color: Colors.teal,
//             ),
//             currentAccountPicture: CircleAvatar(
//               backgroundColor: Colors.white,
//               child: isLoading
//                   ? const CircularProgressIndicator(color: Colors.teal)
//                   : const Icon(Icons.person, size: 42, color: Colors.teal),
//             ),
//             accountName: Text(_name, style: const TextStyle(fontSize: 18)),
//             accountEmail: Text(_email),
//           ),
//           Expanded(
//             child: ListView(
//               children: [
//                 _buildDrawerItem(
//                   icon: CupertinoIcons.person,
//                   text: 'Profile',
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const ProfilePage()),
//                     );
//                   },
//                 ),
//                 _buildDrawerItem(
//                   icon: Icons.app_registration_rounded,
//                   text: 'Apply for Bus',
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const ApplyPage()),
//                     );
//                   },
//                 ),
//                 _buildDrawerItem(
//                   icon: CupertinoIcons.check_mark_circled,
//                   text: 'Attendance',
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const AttendancePage()),
//                     );
//                   },
//                 ),
//                 _buildDrawerItem(
//                   icon: Icons.directions_bus_filled_rounded,
//                   text: 'Bus/Driver Details',
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => DriverDetailPage()),
//                     );
//                   },
//                 ),
//                 _buildDrawerItem(
//                   icon: CupertinoIcons.bell,
//                   text: 'Notifications',
//                   onTap: () => Navigator.pop(context),
//                 ),
//                 _buildDrawerItem(
//                   icon: Icons.request_page,
//                   text: 'Invoice',
//                   onTap: () => Navigator.pop(context),
//                 ),
//                 _buildDrawerItem(
//                   icon: Icons.my_location,
//                   text: 'Location',
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => LocationPage()),
//                     );
//                   },
//                 ),
//                 _buildDrawerItem(
//                   icon: CupertinoIcons.square_arrow_right,
//                   text: 'Logout',
//                   onTap: () => _logout(context),
//                 ),
//                 const SizedBox(height: 20),
//                 _buildQrSection(context),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDrawerItem({
//     required IconData icon,
//     required String text,
//     required VoidCallback onTap,
//   }) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.teal),
//       title: Text(
//         text,
//         style: const TextStyle(fontSize: 16),
//       ),
//       onTap: onTap,
//     );
//   }
//
//   Widget _buildQrSection(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(12.0),
//       child: Container(
//         height: 65,
//         decoration: BoxDecoration(
//           color: Colors.teal.shade700,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: InkWell(
//           onTap: () => _navigateToQrScanner(context),
//           child: Row(
//             children: [
//               const SizedBox(width: 12),
//               Container(
//                 width: 48,
//                 height: 48,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Icon(Icons.qr_code_2, size: 32, color: Colors.teal),
//               ),
//               const SizedBox(width: 16),
//               const Text(
//                 'Show QR Code',
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _navigateToQrScanner(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const QrScannerPage()),
//     );
//   }
// }
//
// class QrScannerPage extends StatefulWidget {
//   const QrScannerPage({super.key});
//
//   @override
//   _QrScannerPageState createState() => _QrScannerPageState();
// }
//
// class _QrScannerPageState extends State<QrScannerPage> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   QRViewController? controller;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Scan QR Code')),
//       body: QRView(
//         key: qrKey,
//         onQRViewCreated: _onQRViewCreated,
//       ),
//     );
//   }
//
//   void _onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) async {
//       if (scanData.code != null) {
//         await _recordAttendance(scanData.code!);
//         controller.dispose();
//         Navigator.pop(context);
//       }
//     });
//   }
//
//   Future<void> _recordAttendance(String qrCode) async {
//     try {
//       await _firestore.collection('attendance').add({
//         'qrCode': qrCode,
//         'timestamp': FieldValue.serverTimestamp(),
//         'status': 'verified'
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Attendance recorded successfully!')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
// }






// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:university_transport_system/qr_code.dart';
// import 'Apply_page.dart';
// import 'Attendence_page.dart';
// import 'Bus_driver_detail.dart';
// import 'Profile_page.dart';
// import 'location_page.dart';
// //import 'pages/profile_page.dart';
// //import 'pages/apply_page.dart';
// //import 'pages/attendance_page.dart';
// //import 'pages/bus_driver_detail.dart';
// //import 'pages/location_page.dart';
// //import 'pages/qr_generator.dart';
// //import 'login_page.dart';
//
// class Drawerclass extends StatefulWidget {
//   const Drawerclass({super.key});
//
//   @override
//   State<Drawerclass> createState() => _DrawerClassState();
// }
//
// class _DrawerClassState extends State<Drawerclass> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   String _name = 'Loading...';
//   String _email = 'Loading...';
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }
//
//   Future<void> _loadUserData() async {
//     final user = _auth.currentUser;
//     if (user == null) {
//       setState(() => _isLoading = false);
//       return;
//     }
//
//     final userDoc = await _firestore.collection('users').doc(user.uid).get();
//     setState(() {
//       _name = userDoc.data()?['name'] ?? 'No Name';
//       _email = user.email ?? 'No Email';
//       _isLoading = false;
//     });
//   }
//
//   Future<void> _logout(BuildContext context) async {
//     try {
//       await _auth.signOut();
//       Navigator.pushNamedAndRemoveUntil(
//         context,
//         '/login',
//             (route) => false,
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Logout failed: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: Column(
//         children: [
//           UserAccountsDrawerHeader(
//             decoration: const BoxDecoration(color: Colors.teal),
//             accountName: Text(_name),
//             accountEmail: Text(_email),
//             currentAccountPicture: CircleAvatar(
//               backgroundColor: Colors.white,
//               child: _isLoading
//                   ? const CircularProgressIndicator()
//                   : const Icon(Icons.person, color: Colors.teal),
//             ),
//           ),
//           Expanded(
//             child: ListView(
//               children: [
//                 _buildDrawerItem(
//                   icon: Icons.home,
//                   text: 'Home',
//                   onTap: () => Navigator.pop(context),
//                 ),
//                 _buildDrawerItem(
//                   icon: Icons.person,
//                   text: 'Profile',
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const ProfilePage()),
//                   ),
//                 ),
//                 _buildDrawerItem(
//                   icon: Icons.directions_bus,
//                   text: 'Bus Application',
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const ApplyPage()),
//                   ),
//                 ),
//                 _buildDrawerItem(
//                   icon: Icons.check_circle,
//                   text: 'Attendance',
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const AttendancePage()),
//                   ),
//                 ),
//                 _buildDrawerItem(
//                   icon: Icons.people,
//                   text: 'Bus & Driver',
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const BusDriverDetailPage()),
//                   ),
//                 ),
//                 _buildDrawerItem(
//                   icon: Icons.location_on,
//                   text: 'Bus Location',
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const LocationPage()),
//                   ),
//                 ),
//                 _buildDrawerItem(
//                   icon: Icons.qr_code,
//                   text: 'My QR Code',
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const QrGeneratorPage()),
//                   ),
//                 ),
//                 const Divider(),
//                 _buildDrawerItem(
//                   icon: Icons.logout,
//                   text: 'Logout',
//                   onTap: () => _logout(context),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDrawerItem({
//     required IconData icon,
//     required String text,
//     required VoidCallback onTap,
//   }) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.teal),
//       title: Text(text),
//       onTap: onTap,
//     );
//   }
// }
//
//
//
//
// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:qr_code_scanner/qr_code_scanner.dart';
// // import 'Apply_page.dart';
// // //import 'Attendance_page.dart';
// // import 'Attendence_page.dart';
// // import 'Bus_driver_detail.dart';
// // import 'Profile_page.dart';
// // import 'location_page.dart';
// //
// // class DrawerClass extends StatefulWidget {
// //   const DrawerClass({super.key});
// //
// //   @override
// //   State<DrawerClass> createState() => _DrawerClassState();
// // }
// //
// // class _DrawerClassState extends State<DrawerClass> {
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //
// //   String _name = 'Loading...';
// //   String _email = 'Loading...';
// //   bool isLoading = true;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadUserData();
// //   }
// //
// //   Future<void> _loadUserData() async {
// //     User? user = _auth.currentUser;
// //     if (user != null) {
// //       DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
// //       if (doc.exists) {
// //         setState(() {
// //           _name = doc['name'] ?? 'No Name';
// //           _email = user.email ?? 'No Email';
// //           isLoading = false;
// //         });
// //       }
// //     }
// //   }
// //
// //   Future<void> _logout(BuildContext context) async {
// //     try {
// //       await _auth.signOut();
// //       Navigator.pushNamedAndRemoveUntil(
// //           context,
// //           '/login',
// //               (route) => false
// //       );
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Logout failed: $e')),
// //       );
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final Size screenSize = MediaQuery.of(context).size;
// //     return Drawer(
// //       width: screenSize.width * 0.75,
// //       child: Column(
// //         children: [
// //           UserAccountsDrawerHeader(
// //             decoration: const BoxDecoration(
// //               color: Colors.teal,
// //             ),
// //             currentAccountPicture: CircleAvatar(
// //               backgroundColor: Colors.white,
// //               child: isLoading
// //                   ? const CircularProgressIndicator(color: Colors.teal)
// //                   : const Icon(Icons.person, size: 42, color: Colors.teal),
// //             ),
// //             accountName: Text(_name, style: const TextStyle(fontSize: 18)),
// //             accountEmail: Text(_email),
// //           ),
// //           Expanded(
// //             child: ListView(
// //               children: [
// //                 _buildDrawerItem(
// //                   icon: CupertinoIcons.person,
// //                   text: 'Profile',
// //                   onTap: () {
// //                     Navigator.push(
// //                       context,
// //                       MaterialPageRoute(builder: (_) => const ProfilePage()),
// //                     );
// //                   },
// //                 ),
// //                 _buildDrawerItem(
// //                   icon: Icons.app_registration_rounded,
// //                   text: 'Apply for Bus',
// //                   onTap: () {
// //                     Navigator.push(
// //                       context,
// //                       MaterialPageRoute(builder: (_) => const ApplyPage()),
// //                     );
// //                   },
// //                 ),
// //                 _buildDrawerItem(
// //                   icon: CupertinoIcons.check_mark_circled,
// //                   text: 'Attendance',
// //                   onTap: () {
// //                     Navigator.push(
// //                       context,
// //                       MaterialPageRoute(builder: (_) => const AttendancePage()),
// //                     );
// //                   },
// //                 ),
// //                 _buildDrawerItem(
// //                   icon: Icons.directions_bus_filled_rounded,
// //                   text: 'Bus/Driver Details',
// //                   onTap: () {
// //                     Navigator.push(
// //                       context,
// //                       MaterialPageRoute(builder: (_) => DriverDetailPage()),
// //                     );
// //                   },
// //                 ),
// //                 _buildDrawerItem(
// //                   icon: CupertinoIcons.bell,
// //                   text: 'Notifications',
// //                   onTap: () => Navigator.pop(context),
// //                 ),
// //                 _buildDrawerItem(
// //                   icon: Icons.request_page,
// //                   text: 'Invoice',
// //                   onTap: () => Navigator.pop(context),
// //                 ),
// //                 _buildDrawerItem(
// //                   icon: Icons.my_location,
// //                   text: 'Location',
// //                   onTap: () {
// //                     Navigator.push(
// //                       context,
// //                       MaterialPageRoute(builder: (_) => LocationPage()),
// //                     );
// //                   },
// //                 ),
// //                 _buildDrawerItem(
// //                   icon: CupertinoIcons.square_arrow_right,
// //                   text: 'Logout',
// //                   onTap: () => _logout(context),
// //                 ),
// //                 const SizedBox(height: 20),
// //                 _buildQrSection(context),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildDrawerItem({
// //     required IconData icon,
// //     required String text,
// //     required VoidCallback onTap,
// //   }) {
// //     return ListTile(
// //       leading: Icon(icon, color: Colors.teal),
// //       title: Text(
// //         text,
// //         style: const TextStyle(fontSize: 16),
// //       ),
// //       onTap: onTap,
// //     );
// //   }
// //
// //   Widget _buildQrSection(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.all(12.0),
// //       child: Container(
// //         height: 65,
// //         decoration: BoxDecoration(
// //           color: Colors.teal.shade700,
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //         child: InkWell(
// //           onTap: () => _navigateToQrScanner(context),
// //           child: Row(
// //             children: [
// //               const SizedBox(width: 12),
// //               Container(
// //                 width: 48,
// //                 height: 48,
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(10),
// //                 ),
// //                 child: const Icon(Icons.qr_code_2, size: 32, color: Colors.teal),
// //               ),
// //               const SizedBox(width: 16),
// //               const Text(
// //                 'Show QR Code',
// //                 style: TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 15,
// //                     fontWeight: FontWeight.w600),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   void _navigateToQrScanner(BuildContext context) {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(builder: (context) => const QrScannerPage()),
// //     );
// //   }
// // }
// //
// // class QrScannerPage extends StatefulWidget {
// //   const QrScannerPage({super.key});
// //
// //   @override
// //   _QrScannerPageState createState() => _QrScannerPageState();
// // }
// //
// // class _QrScannerPageState extends State<QrScannerPage> {
// //   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   QRViewController? controller;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Scan QR Code')),
// //       body: QRView(
// //         key: qrKey,
// //         onQRViewCreated: _onQRViewCreated,
// //       ),
// //     );
// //   }
// //
// //   void _onQRViewCreated(QRViewController controller) {
// //     this.controller = controller;
// //     controller.scannedDataStream.listen((scanData) async {
// //       if (scanData.code != null) {
// //         await _recordAttendance(scanData.code!);
// //         controller.dispose();
// //         Navigator.pop(context);
// //       }
// //     });
// //   }
// //
// //   Future<void> _recordAttendance(String qrCode) async {
// //     try {
// //       await _firestore.collection('attendance').add({
// //         'qrCode': qrCode,
// //         'timestamp': FieldValue.serverTimestamp(),
// //         'status': 'verified'
// //       });
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('Attendance recorded successfully!')),
// //       );
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Error: $e')),
// //       );
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     controller?.dispose();
// //     super.dispose();
// //   }
// // }
//
//
//
//
//
// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// // import 'Apply_page.dart';
// // //import 'Attendance_page.dart';
// // import 'Attendence_page.dart';
// // import 'Bus_driver_detail.dart';
// // import 'Profile_page.dart';
// //
// // class DrawerClass extends StatefulWidget {
// //   const DrawerClass({super.key});
// //
// //   @override
// //   State<DrawerClass> createState() => _DrawerClassState();
// // }
// //
// // class _DrawerClassState extends State<DrawerClass> {
// //   bool isLoading = false;
// //   String _name = 'Sareer Nazir'; // Dummy name for preview
// //   String _email = 'sareer@example.com';
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final Size screenSize = MediaQuery.of(context).size;
// //     return Drawer(
// //       width: screenSize.width * 0.75,
// //       child: Column(
// //         children: [
// //           UserAccountsDrawerHeader(
// //             decoration: const BoxDecoration(
// //               color: Colors.teal,
// //             ),
// //             currentAccountPicture: const CircleAvatar(
// //               backgroundColor: Colors.white,
// //               child: Icon(Icons.person, size: 42, color: Colors.teal),
// //             ),
// //             accountName: Text(_name),
// //             accountEmail: Text(_email),
// //           ),
// //           Expanded(
// //             child: ListView(
// //               children: [
// //                 _buildDrawerItem(
// //                   icon: CupertinoIcons.person,
// //                   text: 'Profile',
// //                   onTap: () {
// //                     Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
// //                   },
// //                 ),
// //                 _buildDrawerItem(
// //                   icon: Icons.app_registration_rounded,
// //                   text: 'Apply for Bus',
// //                   onTap: () {
// //                     Navigator.push(context, MaterialPageRoute(builder: (_) => const ApplyPage()));
// //                   },
// //                 ),
// //                 _buildDrawerItem(
// //                   icon: CupertinoIcons.check_mark_circled,
// //                   text: 'Attendance',
// //                   onTap: () {
// //                     Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendancePage()));
// //                   },
// //                 ),
// //                 _buildDrawerItem(
// //                   icon: Icons.directions_bus_filled_rounded,
// //                   text: 'Bus/Driver Details',
// //                   onTap: () {
// //                     Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverDetailPage()));
// //                   },
// //                 ),
// //                 _buildDrawerItem(
// //                   icon: CupertinoIcons.bell,
// //                   text: 'Notifications',
// //                   onTap: () {
// //                     Navigator.pop(context);
// //                   },
// //                 ),
// //                 _buildDrawerItem(
// //                   icon: Icons.request_page,
// //                   text: 'Invoice',
// //                   onTap: () {
// //                     Navigator.pop(context);
// //                   },
// //                 ),
// //                 _buildDrawerItem(
// //                   icon: Icons.my_location,
// //                   text: 'Location',
// //                   onTap: () {},
// //                 ),
// //                 _buildDrawerItem(
// //                   icon: CupertinoIcons.square_arrow_right,
// //                   text: 'Logout',
// //                   onTap: () {
// //                     // Logout logic
// //                   },
// //                 ),
// //                 const SizedBox(height: 20),
// //                 _buildQrSection(),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildDrawerItem({
// //     required IconData icon,
// //     required String text,
// //     required VoidCallback onTap,
// //   }) {
// //     return ListTile(
// //       leading: Icon(icon, color: Colors.teal),
// //       title: Text(
// //         text,
// //         style: const TextStyle(
// //           fontSize: 16,
// //         ),
// //       ),
// //       onTap: onTap,
// //     );
// //   }
// //
// //   Widget _buildQrSection() {
// //     return Padding(
// //       padding: const EdgeInsets.all(12.0),
// //       child: Container(
// //         height: 65,
// //         decoration: BoxDecoration(
// //           color: Colors.teal.shade700,
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //         child: InkWell(
// //           onTap: () {
// //             // Navigate or show QR Code
// //           },
// //           child: Row(
// //             children: [
// //               const SizedBox(width: 12),
// //               Container(
// //                 width: 48,
// //                 height: 48,
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(10),
// //                 ),
// //                 child: const Icon(Icons.qr_code_2, size: 32, color: Colors.teal),
// //               ),
// //               const SizedBox(width: 16),
// //               const Text(
// //                 'Show QR Code',
// //                 style: TextStyle(
// //                   color: Colors.white,
// //                   fontSize: 15,
// //                   fontWeight: FontWeight.w600,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
