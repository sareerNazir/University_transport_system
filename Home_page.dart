import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:university_transport_system/services/notification_service.dart';
import 'Login_page.dart';
import 'SignUp_page.dart';
import 'Main_page.dart';

class HomePage extends StatelessWidget {

   HomePage({super.key});


  // Check if user is already logged in
  Future<void> _checkAuthStatus(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Check if user has completed profile
      DataSnapshot snapshot = await FirebaseDatabase.instance
          .ref()
          .child('users/${user.uid}/profileCompleted')
          .get();

      if (snapshot.exists && snapshot.value == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      }
    }
  }
  //notification
  // NotificationService notificationService = NotificationService();
  // @override
  // void initState() {
  //   initState();
  //   notificationService.requestNotificationPermission();
  // }


  @override
  Widget build(BuildContext context) {
    // Check auth status when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus(context);
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://th.bing.com/th/id/OIP.pg83sqj7uWIMBgNjrdlD2gHaE7?rs=1&pid=ImgDetMain',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 90),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 50,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAuthButton(
                      context,
                      'Login',
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      ),
                    ),
                    const SizedBox(width: 20),
                    _buildAuthButton(
                      context,
                      'Sign up',
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUp()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButton(
      BuildContext context, String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'login_page.dart';
// import 'signup_page.dart';
//
// class HomePage extends StatelessWidget {
//   const HomePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: NetworkImage('https://example.com/background.jpg'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Padding(
//                 padding: EdgeInsets.only(top: 90),
//                 child: CircleAvatar(
//                   radius: 60,
//                   backgroundColor: Colors.white,
//                   child: Icon(Icons.directions_bus, size: 50, color: Colors.teal),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 100),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildAuthButton(
//                       context,
//                       'Login',
//                           () => Navigator.pushNamed(context, '/login'),
//                     ),
//                     const SizedBox(width: 20),
//                     _buildAuthButton(
//                       context,
//                       'Sign up',
//                           () => Navigator.pushNamed(context, '/signup'),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAuthButton(BuildContext context, String text, VoidCallback onPressed) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.teal,
//         padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(color: Colors.white),
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
//
// // import 'package:flutter/material.dart';
// //
// // import 'Login_page.dart';
// // import 'SignUp_page.dart';
// // //import 'screens/Login_page.dart';
// // //import 'screens/Signup_page.dart';
// //
// // class HomePage extends StatelessWidget {
// //   const HomePage({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //         body: Container(
// //             decoration: const BoxDecoration(
// //               image: DecorationImage(
// //                 image: NetworkImage(
// //                     'https://th.bing.com/th/id/OIP.pg83sqj7uWIMBgNjrdlD2gHaE7?rs=1&pid=ImgDetMain'),
// //                 fit: BoxFit.cover,
// //               ),
// //             ),
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 const Padding(
// //                   padding: EdgeInsets.only(top: 90),
// //                   child: CircleAvatar(
// //                     radius: 60,
// //                     backgroundColor: Colors.white,
// //                     child: Icon(
// //                       Icons.person,
// //                       size: 50,
// //                     ),
// //                   ),
// //                 ),
// //                 Row(
// //                   //crossAxisAlignment: CrossAxisAlignment.center,
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     ElevatedButton(
// //                         onPressed: () => Navigator.push(
// //                           context,
// //                           MaterialPageRoute(
// //                               builder: (context) => LoginPage()),
// //                         ),
// //                         style: ElevatedButton.styleFrom(
// //                             backgroundColor: Colors.blue,
// //                             padding: const EdgeInsets.symmetric(
// //                                 vertical: 20, horizontal: 50)),
// //                         child: const Text(
// //                           " Login ",
// //                           style: TextStyle(color: Colors.white),
// //                         )),
// //                     const SizedBox(
// //                       width: 20,
// //                     ),
// //                     ElevatedButton(
// //                         onPressed: () => Navigator.push(
// //                           context,
// //                           MaterialPageRoute(builder: (context) => const SignUp()),
// //                         ),
// //                         style: ElevatedButton.styleFrom(
// //                             backgroundColor: Colors.blue,
// //                             padding: const EdgeInsets.symmetric(
// //                                 vertical: 20, horizontal: 50)),
// //                         child: const Text(
// //                           "Sign up",
// //                           style: TextStyle(color: Colors.white),
// //                         )),
// //                     const SizedBox(
// //                       height: 200,
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             )));
// //   }
// // }
