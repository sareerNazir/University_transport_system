import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  QRViewController? controller;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.teal,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: MediaQuery.of(context).size.width * 0.8,
            ),
          ),
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (_isProcessing) return;

      setState(() => _isProcessing = true);

      try {
        final user = _auth.currentUser;
        if (user == null) return;

        // Check if attendance was already marked today
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day);

        final existingAttendance = await _firestore.collection('attendance')
            .where('userId', isEqualTo: user.uid)
            .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
            .where('type', isEqualTo: 'boarding')
            .get();

        if (existingAttendance.docs.isEmpty) {
          // Mark boarding attendance
          await _firestore.collection('attendance').add({
            'userId': user.uid,
            'type': 'boarding',
            'timestamp': FieldValue.serverTimestamp(),
            'qrCode': scanData.code,
          });

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Boarding attendance recorded!')),
          );
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Attendance already marked today')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() => _isProcessing = false);
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}





// Add these imports at the top
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class QRScannerPage extends StatefulWidget {
//   const QRScannerPage({super.key});
//
//   @override
//   _QRScannerPageState createState() => _QRScannerPageState();
// }
//
// class _QRScannerPageState extends State<QRScannerPage> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   QRViewController? controller;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
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
//       // Mark attendance in Firestore
//       await _firestore.collection('attendance').add({
//         'qrCode': scanData.code,
//         'scannedAt': FieldValue.serverTimestamp(),
//         'userId': 'currentUserId', // Replace with actual user ID
//       });
//
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Attendance recorded!')),
//       );
//     });
//   }
//
//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
// }





// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class QrGeneratorPage extends StatefulWidget {
//   const QrGeneratorPage({super.key});
//
//   @override
//   State<QrGeneratorPage> createState() => _QrGeneratorPageState();
// }
//
// class _QrGeneratorPageState extends State<QrGeneratorPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   String? _invoiceNumber;
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadInvoiceNumber();
//   }
//
//   Future<void> _loadInvoiceNumber() async {
//     final user = _auth.currentUser;
//     if (user == null) {
//       setState(() => _isLoading = false);
//       return;
//     }
//
//     final userDoc = await _firestore.collection('users').doc(user.uid).get();
//     setState(() {
//       _invoiceNumber = userDoc.data()?['invoiceNumber'];
//       _isLoading = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My QR Code'),
//         backgroundColor: Colors.teal,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (_invoiceNumber != null) ...[
//               QrImageView(
//                 data: 'UTS-INV-$_invoiceNumber',
//                 version: QrVersions.auto,
//                 size: 200,
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'Invoice Number: $_invoiceNumber',
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ] else
//               const Text('No invoice number found'),
//             const SizedBox(height: 30),
//             const Text(
//               'Show this QR code to the driver when boarding the bus',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
//
//
// // import 'package:flutter/material.dart';
// // import 'package:qr_flutter/qr_flutter.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// //
// // class QrGeneratorPage extends StatefulWidget {
// //   const QrGeneratorPage({super.key});
// //
// //   @override
// //   State<QrGeneratorPage> createState() => _QrGeneratorPageState();
// // }
// //
// // class _QrGeneratorPageState extends State<QrGeneratorPage> {
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   String? _invoiceNumber;
// //   bool _isLoading = true;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadInvoiceNumber();
// //   }
// //
// //   Future<void> _loadInvoiceNumber() async {
// //     final user = _auth.currentUser;
// //     if (user == null) {
// //       setState(() => _isLoading = false);
// //       return;
// //     }
// //
// //     final userDoc = await _firestore.collection('users').doc(user.uid).get();
// //     setState(() {
// //       _invoiceNumber = userDoc.data()?['invoiceNumber'];
// //       _isLoading = false;
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('My QR Code'),
// //         backgroundColor: Colors.teal,
// //       ),
// //       body: _isLoading
// //           ? const Center(child: CircularProgressIndicator())
// //           : Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             if (_invoiceNumber != null) ...[
// //               QrImageView(
// //                 data: 'UTS-INV-$_invoiceNumber',
// //                 version: QrVersions.auto,
// //                 size: 200,
// //               ),
// //               const SizedBox(height: 20),
// //               Text(
// //                 'Invoice Number: $_invoiceNumber',
// //                 style: const TextStyle(fontSize: 16),
// //               ),
// //             ] else
// //               const Text('No invoice number found'),
// //             const SizedBox(height: 30),
// //             const Padding(
// //               padding: EdgeInsets.symmetric(horizontal: 20),
// //               child: Text(
// //                 'Show this QR code to the driver when boarding the bus',
// //                 textAlign: TextAlign.center,
// //                 style: TextStyle(color: Colors.grey),
// //               ),
// //             ),
// //           ],
// //         ),
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
// // // // Add these imports at the top
// // // import 'package:flutter/cupertino.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:qr_code_scanner/qr_code_scanner.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // //
// // // class QRScannerPage extends StatefulWidget {
// // //   const QRScannerPage({super.key});
// // //
// // //   @override
// // //   _QRScannerPageState createState() => _QRScannerPageState();
// // // }
// // //
// // // class _QRScannerPageState extends State<QRScannerPage> {
// // //   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
// // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// // //   QRViewController? controller;
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       body: QRView(
// // //         key: qrKey,
// // //         onQRViewCreated: _onQRViewCreated,
// // //       ),
// // //     );
// // //   }
// // //
// // //   void _onQRViewCreated(QRViewController controller) {
// // //     this.controller = controller;
// // //     controller.scannedDataStream.listen((scanData) async {
// // //       // Mark attendance in Firestore
// // //       await _firestore.collection('attendance').add({
// // //         'qrCode': scanData.code,
// // //         'scannedAt': FieldValue.serverTimestamp(),
// // //         'userId': 'currentUserId', // Replace with actual user ID
// // //       });
// // //
// // //       Navigator.pop(context);
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(content: Text('Attendance recorded!')),
// // //       );
// // //     });
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     controller?.dispose();
// // //     super.dispose();
// // //   }
// // // }