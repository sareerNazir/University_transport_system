import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'Apply_page.dart';
//import 'Dashboard.dart';
//import 'Bus_driver_detail.dart';
import 'Main_page.dart';
import 'attendence_page.dart';
import 'firebase_options.dart'; // Generated file
import 'home_page.dart';
import 'login_page.dart';
import 'signUp_page.dart';
import 'profile_page.dart';
import 'apply_page.dart';
import 'Bus_driver_detail.dart';
import 'forgotPasswordScreen.dart';
import 'Drawerclass.dart';
import 'location_page.dart';
import 'main.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const UniversityTransportApp());
}

class UniversityTransportApp extends StatelessWidget {
  const UniversityTransportApp({super.key});





  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'University Transport System',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          centerTitle: true,
          elevation: 4,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.teal),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.teal, width: 1.5),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) =>  HomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUp(),
        '/main': (context) => const MainPage(),
        '/profile': (context) => const ProfilePage(),
        '/apply': (context) =>const ApplyPage(),
        '/driver-details': (context) =>  DriverDetailPage(),
        '/attendance': (context) => const AttendancePage(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/location': (context) =>  LocationPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
//
//
//
//
//
//
// // import 'package:flutter/material.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'Attendence_page.dart';
// // import 'firebase_options.dart'; // Generated file
// // import 'Home_page.dart';
// // import 'Login_page.dart';
// // import 'SignUp_page.dart';
// // import 'Main_page.dart';
// // import 'Profile_page.dart';
// // import 'Apply_page.dart';
// // import 'Bus_driver_detail.dart';
// // //import 'Attendance_page.dart';
// // import 'ForgotPasswordScreen.dart';
// // import 'Drawerclass.dart';
// // import 'location_page.dart';
// //
// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //
// //   // Initialize Firebase
// //   await Firebase.initializeApp(
// //     options: DefaultFirebaseOptions.currentPlatform,
// //   );
// //
// //   runApp(const UniversityTransportApp());
// // }
// //
// // class UniversityTransportApp extends StatelessWidget {
// //   const UniversityTransportApp({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'University Transport System',
// //       theme: ThemeData(
// //         primarySwatch: Colors.teal,
// //         scaffoldBackgroundColor: const Color(0xFFF5F7FA),
// //         appBarTheme: const AppBarTheme(
// //           backgroundColor: Colors.teal,
// //           centerTitle: true,
// //           elevation: 4,
// //           titleTextStyle: TextStyle(
// //             fontSize: 20,
// //             fontWeight: FontWeight.bold,
// //             color: Colors.white,
// //           ),
// //         ),
// //         inputDecorationTheme: InputDecorationTheme(
// //           filled: true,
// //           fillColor: Colors.white,
// //           contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
// //           border: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(15),
// //             borderSide: const BorderSide(color: Colors.teal),
// //           ),
// //           focusedBorder: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(15),
// //             borderSide: const BorderSide(color: Colors.teal, width: 1.5),
// //           ),
// //         ),
// //       ),
// //       initialRoute: '/',
// //       routes: {
// //         '/': (context) =>  HomePage(),
// //         '/login': (context) =>  LoginPage(),
// //         '/signup': (context) => const SignUp(),
// //         '/main': (context) => const MainPage(),
// //         '/profile': (context) => const ProfilePage(),
// //         '/apply': (context) => const ApplyPage(),
// //         '/driver-details': (context) =>  DriverDetailPage(),
// //         '/attendance': (context) => const AttendancePage(),
// //         '/forgot-password': (context) => const ForgotPasswordScreen(),
// //         '/location': (context) =>  LocationPage(),
// //       },
// //       debugShowCheckedModeBanner: false,
// //     );
// //   }
// // }
//
// // Add this to your android/app/build.gradle:
// // apply plugin: 'com.google.gms.google-services'
// //
// // Add this to your android/build.gradle:
// // classpath 'com.google.gms:google-services:4.3.15'
//
//
//
//
//
//
// // import 'package:flutter/material.dart';
// //
// // import 'Home_page.dart';
// //
// // void main() {
// //   runApp(const MyApp());
// // }
// //
// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});
// //
// //   // This widget is the root of your application.
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: HomePage(),
// //
// //     );
// //   }
// // }
// //
