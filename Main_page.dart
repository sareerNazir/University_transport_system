import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Drawerclass.dart';
import 'Profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? userData;
  int _selectedIndex = 0;

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
          userData = doc.data() as Map<String, dynamic>?;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget infoCard(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('University Transport System'),
        centerTitle: true,
      ),
      drawer: const DrawerClass(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.teal,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                infoCard('Name', userData?['name'] ?? 'Loading...'),
                infoCard('Department', userData?['department'] ?? 'Loading...'),
              ],
            ),
            Row(
              children: [
                infoCard('Route', userData?['route'] ?? 'Not assigned'),
                infoCard('Bus Number', userData?['busNumber'] ?? 'Not assigned'),
              ],
            ),
            Row(
              children: [
                infoCard("Today's Schedule", '7:30 AM'),
                infoCard('Departure', '4:30 PM'),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Location',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              icon: const Icon(Icons.person),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}







// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'Drawerclass.dart';
// //import 'drawer_class.dart';
//
// class Dashboard extends StatefulWidget {
//   const Dashboard({super.key});
//
//   @override
//   State<Dashboard> createState() => _MainPageState();
// }
//
// class _MainPageState extends State<Dashboard> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   Map<String, dynamic>? _userData;
//   int _selectedIndex = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }
//
//   Future<void> _loadUserData() async {
//     final user = _auth.currentUser;
//     if (user == null) return;
//
//     final userDoc = await _firestore.collection('users').doc(user.uid).get();
//     final busQuery = await _firestore.collection('bus_applications')
//         .where('userId', isEqualTo: user.uid)
//         .limit(1)
//         .get();
//
//     setState(() {
//       _userData = userDoc.data();
//       if (busQuery.docs.isNotEmpty) {
//         _userData?.addAll(busQuery.docs.first.data());
//       }
//     });
//   }
//
//   Widget _buildInfoCard(String title, String value) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('University Transport System'),
//         backgroundColor: Colors.teal,
//       ),
//       drawer: const Drawerclass(),
//       body: _userData == null
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             const CircleAvatar(
//               radius: 50,
//               backgroundColor: Colors.teal,
//               child: Icon(Icons.person, size: 50, color: Colors.white),
//             ),
//             const SizedBox(height: 20),
//             GridView.count(
//               crossAxisCount: 2,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               childAspectRatio: 1.5,
//               children: [
//                 _buildInfoCard('Name', _userData!['name'] ?? 'N/A'),
//                 _buildInfoCard('Roll No', _userData!['rollNo'] ?? 'N/A'),
//                 _buildInfoCard('Department', _userData!['department'] ?? 'N/A'),
//                 _buildInfoCard('Bus No', _userData!['busNumber'] ?? 'Not assigned'),
//                 _buildInfoCard('Route', _userData!['route'] ?? 'Not assigned'),
//                 _buildInfoCard('Status', _userData!['status'] ?? 'Pending'),
//               ],
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: (index) {
//           if (index == 3) {
//             Navigator.pushNamed(context, '/profile');
//           } else {
//             setState(() => _selectedIndex = index);
//           }
//         },
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.directions_bus), label: 'Bus'),
//           BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Location'),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//         ],
//       ),
//     );
//   }
// }
//
//
//
//
//
//
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:university_transport_system/qr_code.dart';
// // import 'apply_page.dart';
// // import 'attendence_page.dart';
// // import 'bus_driver_detail.dart';
// // import 'forgotPasswordScreen.dart';
// // import 'home_page.dart';
// // import 'login_page.dart';
// // import 'profile_page.dart';
// // import 'signUp_page.dart';
// // import 'firebase_options.dart';
// // import 'location_page.dart';
// // import 'Drawerclass.dart';
// // import 'main.dart';
// // //import 'pages/home_page.dart';
// // //import 'pages/login_page.dart';
// // //import 'pages/signup_page.dart';
// // //import 'pages/main_page.dart';
// // //import 'pages/profile_page.dart';
// // //import 'pages/apply_page.dart';
// // //import 'pages/bus_driver_detail.dart';
// // //import 'pages/attendance_page.dart';
// // //import 'pages/forgot_password.dart';
// // //import 'pages/location_page.dart';
// // //import 'pages/qr_generator.dart';
// //
// // //
// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'drawerclass.dart';
// // import 'profile_page.dart';
// //
// // class Dashborad extends StatefulWidget {
// //   const Dashborad({super.key});
// //
// //   @override
// //   State<Dashborad> createState() => _MainPageState();
// // }
// //
// // class _MainPageState extends State<Dashborad> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   Map<String, dynamic>? _userData;
// //   int _selectedIndex = 0;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadUserData();
// //   }
// //
// //   Future<void> _loadUserData() async {
// //     final user = _auth.currentUser;
// //     if (user == null) return;
// //
// //     final userDoc = await _firestore.collection('users').doc(user.uid).get();
// //     final busQuery = await _firestore.collection('bus_applications')
// //         .where('userId', isEqualTo: user.uid)
// //         .limit(1)
// //         .get();
// //
// //     setState(() {
// //       _userData = userDoc.data();
// //       if (busQuery.docs.isNotEmpty) {
// //         _userData?.addAll(busQuery.docs.first.data());
// //       }
// //     });
// //   }
// //
// //   Widget _buildInfoCard(String title, String value) {
// //     return Card(
// //       elevation: 2,
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               title,
// //               style: const TextStyle(
// //                 fontSize: 14,
// //                 color: Colors.grey,
// //               ),
// //             ),
// //             const SizedBox(height: 4),
// //             Text(
// //               value,
// //               style: const TextStyle(
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('University Transport System'),
// //         backgroundColor: Colors.teal,
// //       ),
// //       drawer: const Drawerclass(),
// //       body: _userData == null
// //           ? const Center(child: CircularProgressIndicator())
// //           : SingleChildScrollView(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           children: [
// //             const CircleAvatar(
// //               radius: 50,
// //               backgroundColor: Colors.teal,
// //               child: Icon(Icons.person, size: 50, color: Colors.white),
// //             ),
// //             const SizedBox(height: 20),
// //             GridView.count(
// //               crossAxisCount: 2,
// //               shrinkWrap: true,
// //               physics: const NeverScrollableScrollPhysics(),
// //               childAspectRatio: 1.5,
// //               children: [
// //                 _buildInfoCard('Name', _userData!['name'] ?? 'N/A'),
// //                 _buildInfoCard('Roll No', _userData!['rollNo'] ?? 'N/A'),
// //                 _buildInfoCard('Department', _userData!['department'] ?? 'N/A'),
// //                 _buildInfoCard('Bus No', _userData!['busNumber'] ?? 'Not assigned'),
// //                 _buildInfoCard('Route', _userData!['route'] ?? 'Not assigned'),
// //                 _buildInfoCard('Status', _userData!['status'] ?? 'Pending'),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //       bottomNavigationBar: BottomNavigationBar(
// //         currentIndex: _selectedIndex,
// //         onTap: (index) {
// //           if (index == 3) {
// //             Navigator.pushNamed(context, '/profile');
// //           } else {
// //             setState(() => _selectedIndex = index);
// //           }
// //         },
// //         items: const [
// //           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
// //           BottomNavigationBarItem(icon: Icon(Icons.directions_bus), label: 'Bus'),
// //           BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Location'),
// //           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
//
//
//
//
//
//
// // import 'package:flutter/material.dart';
// // import 'Drawerclass.dart';
// // import 'Profile_page.dart';
// //
// // class MainPage extends StatefulWidget {
// //   const MainPage({super.key});
// //
// //   @override
// //   State<MainPage> createState() => _MainPageState();
// // }
// //
// // class _MainPageState extends State<MainPage> {
// //   int _selectedIndex = 0;
// //
// //   void _onItemTapped(int index) {
// //     setState(() {
// //       _selectedIndex = index;
// //     });
// //   }
// //
// //   Widget infoCard(String title, String value) {
// //     return Expanded(
// //       child: Container(
// //         margin: const EdgeInsets.all(8.0),
// //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
// //         decoration: BoxDecoration(
// //           color: Colors.grey.shade100,
// //           borderRadius: BorderRadius.circular(12),
// //           boxShadow: const [
// //             BoxShadow(
// //               color: Colors.black12,
// //               blurRadius: 4,
// //               offset: Offset(0, 2),
// //             ),
// //           ],
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(title,
// //                 style: const TextStyle(
// //                     fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
// //             const SizedBox(height: 6),
// //             Text(value,
// //                 style: const TextStyle(
// //                     fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         backgroundColor: Colors.teal,
// //         title: const Text('University Transport System'),
// //         centerTitle: true,
// //       ),
// //       drawer: const DrawerClass(),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           children: [
// //             const SizedBox(height: 10),
// //             const CircleAvatar(
// //               radius: 40,
// //               backgroundColor: Colors.teal,
// //               child: Icon(Icons.person, size: 40, color: Colors.white),
// //             ),
// //             const SizedBox(height: 20),
// //             Row(
// //               children: [
// //                 infoCard('Name', 'Sareer Nazir'),
// //                 infoCard('Department', 'Software Eng.'),
// //               ],
// //             ),
// //             Row(
// //               children: [
// //                 infoCard('Route', 'Mansehra'),
// //                 infoCard('Bus Number', 'A-1346'),
// //               ],
// //             ),
// //             Row(
// //               children: [
// //                 infoCard('Arrived', '7:30 AM'),
// //                 infoCard('Departure', '4:30 PM'),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //       bottomNavigationBar: BottomNavigationBar(
// //         currentIndex: _selectedIndex,
// //         onTap: _onItemTapped,
// //         type: BottomNavigationBarType.fixed,
// //         selectedItemColor: Colors.teal,
// //         unselectedItemColor: Colors.grey,
// //         items: [
// //           const BottomNavigationBarItem(
// //             icon: Icon(Icons.home),
// //             label: 'Home',
// //           ),
// //           const BottomNavigationBarItem(
// //             icon: Icon(Icons.dashboard),
// //             label: 'Dashboard',
// //           ),
// //           const BottomNavigationBarItem(
// //             icon: Icon(Icons.location_on),
// //             label: 'Location',
// //           ),
// //           BottomNavigationBarItem(
// //             icon: IconButton(
// //               onPressed: () {
// //                 Navigator.push(
// //                     context, MaterialPageRoute(builder: (context) => const ProfilePage()));
// //               },
// //               icon: const Icon(Icons.person),
// //             ),
// //             label: 'Profile',
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
