import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Bus_driver_detail.dart';
import 'Main_page.dart';


class ApplyPage extends StatefulWidget {
  const ApplyPage({super.key});

  @override
  State<ApplyPage> createState() => _ApplyPageState();
}

class _ApplyPageState extends State<ApplyPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final fatherNameController = TextEditingController();
  final rollNumberController = TextEditingController();
  final departmentController = TextEditingController();
  final stopController = TextEditingController();

  String? selectedRoute;
  String? selectedStop;
  int? selectedSemester;
  String? assignedBusNumber;
  String? driverName;
  String? driverContact;

  final Map<String, Map<String, String>> routeBusMap = {
    "Mansehra": {
      "busNumber": "1346",
      "driverName": "Sareer",
      "driverContact": "03460061242"
    },
    "Abbottabad": {
      "busNumber": "2201",
      "driverName": "Mahaz",
      "driverContact": "03474850345"
    },
    "Attershisha": {
      "busNumber": "3180",
      "driverName": "Kashif",
      "driverContact": "03334567890"
    },
    "Balakot": {"busNumber": "2755"},
    "Khaki": {"busNumber": "1985"},
    "Shinkiari": {"busNumber": "3100"},
    "Qalandarabad": {"busNumber": "1440"},
  };

  Future<void> _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      User? user = _auth.currentUser;
      if (user == null) return;

      try {
        await _firestore.collection('bus_applications').add({
          'userId': user.uid,
          'name': nameController.text,
          'fatherName': fatherNameController.text,
          'rollNumber': rollNumberController.text,
          'department': departmentController.text,
          'semester': selectedSemester,
          'route': selectedRoute,
          'stop': stopController.text,
          'busNumber': assignedBusNumber,
          'driverName': driverName,
          'driverContact': driverContact,
          'status': 'pending',
          'appliedAt': FieldValue.serverTimestamp(),
        });

        await _firestore.collection('users').doc(user.uid).update({
          'busAssigned': true,
          'busNumber': assignedBusNumber,
          'route': selectedRoute,
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DriverDetailPage(
              selectedBusNumber: assignedBusNumber,
              selectedRoute: selectedRoute,
              driverName: driverName,
              driverContact: driverContact,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Apply for Bus"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildInput("Name", nameController),
              _buildInput("Father Name", fatherNameController),
              _buildInput("Roll Number", rollNumberController, inputType: TextInputType.number),
              _buildInput("Department", departmentController),
              const SizedBox(height: 10),
              _buildDropdown<int>(
                hint: "Select Semester",
                value: selectedSemester,
                items: List.generate(
                  10,
                      (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('Semester ${index + 1}'),
                  ),
                ),
                onChanged: (val) => setState(() => selectedSemester = val),
              ),
              const SizedBox(height: 10),
              _buildDropdown<String>(
                hint: "Select Route",
                value: selectedRoute,
                items: routeBusMap.keys.map((route) {
                  return DropdownMenuItem(
                    value: route,
                    child: Text(route),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedRoute = val;
                    assignedBusNumber = routeBusMap[val!]!['busNumber'];
                    driverName = routeBusMap[val]!['driverName'];
                    driverContact = routeBusMap[val]!['driverContact'];
                  });
                },
              ),
              const SizedBox(height: 10),
              _buildInput("Address", stopController),
              TextFormField(
                readOnly: true,
                decoration: _buildDecoration(
                  assignedBusNumber != null
                      ? "Assigned Bus No: $assignedBusNumber"
                      : "Bus Number",
                ),
              ),
              if (driverName != null)
                TextFormField(
                  readOnly: true,
                  decoration: _buildDecoration("Driver: $driverName"),
                ),
              if (driverContact != null)
                TextFormField(
                  readOnly: true,
                  decoration: _buildDecoration("Driver Contact: $driverContact"),
                ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.send),
                  label: const Text("Submit", style: TextStyle(fontSize: 16)),
                  onPressed: _submitApplication,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller,
      {TextInputType? inputType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        decoration: _buildDecoration(label),
        validator: (value) => value!.isEmpty ? "Please enter $label" : null,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      decoration: _buildDecoration(hint),
      value: value,
      items: items,
      onChanged: onChanged,
      validator: (val) => val == null ? 'Please select $hint' : null,
    );
  }

  InputDecoration _buildDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}















// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'Bus_driver_detail.dart';
// import 'Main_page.dart';
// //import 'DriverDetailPage.dart';
//
// class ApplyPage extends StatefulWidget {
//   const ApplyPage({super.key});
//
//   @override
//   State<ApplyPage> createState() => _ApplyPageState();
// }
//
// class _ApplyPageState extends State<ApplyPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final _formKey = GlobalKey<FormState>();
//
//   final nameController = TextEditingController();
//   final fatherNameController = TextEditingController();
//   final rollNumberController = TextEditingController();
//   final departmentController = TextEditingController();
//   final stopController = TextEditingController();
//
//   String? selectedRoute;
//   String? selectedStop;
//   int? selectedSemester;
//   String? assignedBusNumber;
//   String? driverName;
//   String? driverContact;
//
//   final Map<String, Map<String, String>> routeBusMap = {
//     "Mansehra": {
//       "busNumber": "1346",
//       "driverName": "Sareer",
//       "driverContact": "03460061242"
//     },
//     "Abbottabad": {
//       "busNumber": "2201",
//       "driverName": "Mahaz",
//       "driverContact": "03474850345"
//     },
//     "Attershisha": {
//       "busNumber": "3180",
//       "driverName": "Kashif",
//       "driverContact": "03334567890"
//     },
//     "Balakot": {"busNumber": "2755"},
//     "Khaki": {"busNumber": "1985"},
//     "Shinkiari": {"busNumber": "3100"},
//     "Qalandarabad": {"busNumber": "1440"},
//   };
//
//   Future<void> _submitApplication() async {
//     if (_formKey.currentState!.validate()) {
//       User? user = _auth.currentUser;
//       if (user == null) return;
//
//       try {
//         await _firestore.collection('bus_applications').add({
//           'userId': user.uid,
//           'name': nameController.text,
//           'fatherName': fatherNameController.text,
//           'rollNumber': rollNumberController.text,
//           'department': departmentController.text,
//           'semester': selectedSemester,
//           'route': selectedRoute,
//           'stop': stopController.text,
//           'busNumber': assignedBusNumber,
//           'driverName': driverName,
//           'driverContact': driverContact,
//           'status': 'pending',
//           'appliedAt': FieldValue.serverTimestamp(),
//         });
//
//         await _firestore.collection('users').doc(user.uid).update({
//           'busAssigned': true,
//           'busNumber': assignedBusNumber,
//           'route': selectedRoute,
//         });
//
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => DriverDetailPage(
//               selectedBusNumber: assignedBusNumber,
//               selectedRoute: selectedRoute,
//               driverName: driverName,
//               driverContact: driverContact,
//             ),
//           ),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       appBar: AppBar(
//         title: const Text("Apply for Bus"),
//         centerTitle: true,
//         backgroundColor: Colors.teal,
//         elevation: 2,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               const SizedBox(height: 10),
//               _buildInput("Name", nameController),
//               _buildInput("Father Name", fatherNameController),
//               _buildInput("Roll Number", rollNumberController, inputType: TextInputType.number),
//               _buildInput("Department", departmentController),
//               const SizedBox(height: 10),
//               _buildDropdown<int>(
//                 hint: "Select Semester",
//                 value: selectedSemester,
//                 items: List.generate(
//                   10,
//                       (index) => DropdownMenuItem(
//                     value: index + 1,
//                     child: Text('Semester ${index + 1}'),
//                   ),
//                 ),
//                 onChanged: (val) => setState(() => selectedSemester = val),
//               ),
//               const SizedBox(height: 10),
//               _buildDropdown<String>(
//                 hint: "Select Route",
//                 value: selectedRoute,
//                 items: routeBusMap.keys.map((route) {
//                   return DropdownMenuItem(
//                     value: route,
//                     child: Text(route),
//                   );
//                 }).toList(),
//                 onChanged: (val) {
//                   setState(() {
//                     selectedRoute = val;
//                     assignedBusNumber = routeBusMap[val!]!['busNumber'];
//                     driverName = routeBusMap[val]!['driverName'];
//                     driverContact = routeBusMap[val]!['driverContact'];
//                   });
//                 },
//               ),
//               const SizedBox(height: 10),
//               _buildInput("Address", stopController),
//               TextFormField(
//                 readOnly: true,
//                 decoration: _buildDecoration(
//                   assignedBusNumber != null
//                       ? "Assigned Bus No: $assignedBusNumber"
//                       : "Bus Number",
//                 ),
//               ),
//               if (driverName != null)
//                 TextFormField(
//                   readOnly: true,
//                   decoration: _buildDecoration("Driver: $driverName"),
//                 ),
//               if (driverContact != null)
//                 TextFormField(
//                   readOnly: true,
//                   decoration: _buildDecoration("Driver Contact: $driverContact"),
//                 ),
//               const SizedBox(height: 30),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     backgroundColor: Colors.teal,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   icon: const Icon(Icons.send),
//                   label: const Text("Submit", style: TextStyle(fontSize: 16)),
//                   onPressed: _submitApplication,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInput(String label, TextEditingController controller,
//       {TextInputType? inputType}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: inputType,
//         decoration: _buildDecoration(label),
//         validator: (value) => value!.isEmpty ? "Please enter $label" : null,
//       ),
//     );
//   }
//
//   Widget _buildDropdown<T>({
//     required String hint,
//     required T? value,
//     required List<DropdownMenuItem<T>> items,
//     required void Function(T?) onChanged,
//   }) {
//     return DropdownButtonFormField<T>(
//       decoration: _buildDecoration(hint),
//       value: value,
//       items: items,
//       onChanged: onChanged,
//       validator: (val) => val == null ? 'Please select $hint' : null,
//     );
//   }
//
//   InputDecoration _buildDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//       filled: true,
//       fillColor: Colors.white,
//     );
//   }
// }
//
//
//




















// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'Inovice_page.dart';
// import 'Main_page.dart';
//
// class ApplyPage extends StatefulWidget {
//   const ApplyPage({super.key});
//
//   @override
//   State<ApplyPage> createState() => _ApplyPageState();
// }
//
// class _ApplyPageState extends State<ApplyPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final _formKey = GlobalKey<FormState>();
//
//   final nameController = TextEditingController();
//   final fatherNameController = TextEditingController();
//   final rollNumberController = TextEditingController();
//   final departmentController = TextEditingController();
//   final stopController = TextEditingController();
//
//   String? selectedRoute;
//   String? selectedStop;
//   int? selectedSemester;
//   String? assignedBusNumber;
//
//   final Map<String, String> routeBusMap = {
//     "Mansehra": "1346",
//     "Abbottabad": "2201",
//     "Attershisha": "3180",
//     "Balakot": "2755",
//     "Khaki": "1985",
//     "Shinkiari": "3100",
//     "Qalandarabad": "1440",
//   };
//
//   Future<void> _submitApplication() async {
//     if (_formKey.currentState!.validate()) {
//       User? user = _auth.currentUser;
//       if (user == null) return;
//
//       try {
//         await _firestore.collection('bus_applications').add({
//           'userId': user.uid,
//           'name': nameController.text,
//           'fatherName': fatherNameController.text,
//           'rollNumber': rollNumberController.text,
//           'department': departmentController.text,
//           'semester': selectedSemester,
//           'route': selectedRoute,
//           'stop': stopController.text,
//           'busNumber': assignedBusNumber,
//           'status': 'pending',
//           'appliedAt': FieldValue.serverTimestamp(),
//         });
//
//         await _firestore.collection('users').doc(user.uid).update({
//           'busAssigned': true,
//           'busNumber': assignedBusNumber,
//           'route': selectedRoute,
//         });
//
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => InvoicePage(
//               studentName: nameController.text,
//               rollNumber: rollNumberController.text,
//               route: selectedRoute ?? '',
//               busNumber: assignedBusNumber ?? '',
//             ),
//           ),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       appBar: AppBar(
//         title: const Text("Apply for Bus"),
//         centerTitle: true,
//         backgroundColor: Colors.teal,
//         elevation: 2,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               const SizedBox(height: 10),
//               _buildInput("Name", nameController),
//               _buildInput("Father Name", fatherNameController),
//               _buildInput("Roll Number", rollNumberController, inputType: TextInputType.number),
//               _buildInput("Department", departmentController),
//               const SizedBox(height: 10),
//               _buildDropdown<int>(
//                 hint: "Select Semester",
//                 value: selectedSemester,
//                 items: List.generate(
//                   10,
//                       (index) => DropdownMenuItem(
//                     value: index + 1,
//                     child: Text('Semester ${index + 1}'),
//                   ),
//                 ),
//                 onChanged: (val) => setState(() => selectedSemester = val),
//               ),
//               const SizedBox(height: 10),
//               _buildDropdown<String>(
//                 hint: "Select Route",
//                 value: selectedRoute,
//                 items: routeBusMap.keys.map((route) {
//                   return DropdownMenuItem(
//                     value: route,
//                     child: Text(route),
//                   );
//                 }).toList(),
//                 onChanged: (val) {
//                   setState(() {
//                     selectedRoute = val;
//                     assignedBusNumber = routeBusMap[val!];
//                   });
//                 },
//               ),
//               const SizedBox(height: 10),
//               _buildInput("Address", stopController),
//               TextFormField(
//                 readOnly: true,
//                 decoration: _buildDecoration(
//                   assignedBusNumber != null
//                       ? "Assigned Bus No: $assignedBusNumber"
//                       : "Bus Number",
//                 ),
//               ),
//               const SizedBox(height: 30),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     backgroundColor: Colors.teal,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   icon: const Icon(Icons.send),
//                   label: const Text("Submit", style: TextStyle(fontSize: 16)),
//                   onPressed: _submitApplication,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInput(String label, TextEditingController controller,
//       {TextInputType? inputType}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: inputType,
//         decoration: _buildDecoration(label),
//         validator: (value) => value!.isEmpty ? "Please enter $label" : null,
//       ),
//     );
//   }
//
//   Widget _buildDropdown<T>({
//     required String hint,
//     required T? value,
//     required List<DropdownMenuItem<T>> items,
//     required void Function(T?) onChanged,
//   }) {
//     return DropdownButtonFormField<T>(
//       decoration: _buildDecoration(hint),
//       value: value,
//       items: items,
//       onChanged: onChanged,
//       validator: (val) => val == null ? 'Please select $hint' : null,
//     );
//   }
//
//   InputDecoration _buildDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//       filled: true,
//       fillColor: Colors.white,
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
//
// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'Inovice_page.dart';
// // import 'Main_page.dart';
// // //import 'invoice_page.dart'; // Make sure to import the InvoicePage
// //
// // class ApplyPage extends StatefulWidget {
// //   const ApplyPage({super.key});
// //
// //   @override
// //   State<ApplyPage> createState() => _ApplyPageState();
// // }
// //
// // class _ApplyPageState extends State<ApplyPage> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   final _formKey = GlobalKey<FormState>();
// //
// //   final nameController = TextEditingController();
// //   final fatherNameController = TextEditingController();
// //   final rollNumberController = TextEditingController();
// //   final departmentController = TextEditingController();
// //   final stopController = TextEditingController();
// //
// //   String? selectedRoute;
// //   String? selectedStop;
// //   int? selectedSemester;
// //   String? assignedBusNumber;
// //
// //   final Map<String, String> routeBusMap = {
// //     "Mansehra": "1346",
// //     "Abbottabad": "2201",
// //     "Attershisha": "3180",
// //     "Balakot": "2755",
// //     "Khaki": "1985",
// //     "Shinkiari": "3100",
// //     "Qalandarabad": "1440",
// //   };
// //
// //   Future<void> _submitApplication() async {
// //     if (_formKey.currentState!.validate()) {
// //       User? user = _auth.currentUser;
// //       if (user == null) return;
// //
// //       try {
// //         await _firestore.collection('bus_applications').add({
// //           'userId': user.uid,
// //           'name': nameController.text,
// //           'fatherName': fatherNameController.text,
// //           'rollNumber': rollNumberController.text,
// //           'department': departmentController.text,
// //           'semester': selectedSemester,
// //           'route': selectedRoute,
// //           'stop': stopController.text,
// //           'busNumber': assignedBusNumber,
// //           'status': 'pending',
// //           'appliedAt': FieldValue.serverTimestamp(),
// //         });
// //
// //         // Update user document with bus assignment
// //         await _firestore.collection('users').doc(user.uid).update({
// //           'busAssigned': true,
// //           'busNumber': assignedBusNumber,
// //           'route': selectedRoute,
// //         });
// //
// //         // Navigate to InvoicePage instead of MainPage
// //         Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(
// //             builder: (context) => InvoicePage(
// //               studentName: nameController.text,
// //               rollNumber: rollNumberController.text,
// //               route: selectedRoute ?? '',
// //               busNumber: assignedBusNumber ?? '',
// //             ),
// //           ),
// //         );
// //       } catch (e) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Error: $e')),
// //         );
// //       }
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF5F5F5),
// //       appBar: AppBar(
// //         title: const Text("Apply for Bus"),
// //         centerTitle: true,
// //         backgroundColor: Colors.teal,
// //         elevation: 2,
// //       ),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(20),
// //         child: Form(
// //           key: _formKey,
// //           child: Column(
// //             children: [
// //               const SizedBox(height: 10),
// //               _buildInput("Name", nameController),
// //               _buildInput("Father Name", fatherNameController),
// //               _buildInput("Roll Number", rollNumberController, inputType: TextInputType.number),
// //               _buildInput("Department", departmentController),
// //               const SizedBox(height: 10),
// //               _buildDropdown<int>(
// //                 hint: "Select Semester",
// //                 value: selectedSemester,
// //                 items: List.generate(
// //                   10,
// //                       (index) => DropdownMenuItem(
// //                     value: index + 1,
// //                     child: Text('Semester ${index + 1}'),
// //                   ),
// //                 ),
// //                 onChanged: (val) => setState(() => selectedSemester = val),
// //               ),
// //               const SizedBox(height: 10),
// //               _buildDropdown<String>(
// //                 hint: "Select Route",
// //                 value: selectedRoute,
// //                 items: routeBusMap.keys.map((route) {
// //                   return DropdownMenuItem(
// //                     value: route,
// //                     child: Text(route),
// //                   );
// //                 }).toList(),
// //                 onChanged: (val) {
// //                   setState(() {
// //                     selectedRoute = val;
// //                     assignedBusNumber = routeBusMap[val!];
// //                   });
// //                 },
// //               ),
// //               const SizedBox(height: 10),
// //               _buildInput("Address", stopController),
// //               TextFormField(
// //                 readOnly: true,
// //                 decoration: _buildDecoration(
// //                   assignedBusNumber != null
// //                       ? "Assigned Bus No: $assignedBusNumber"
// //                       : "Bus Number",
// //                 ),
// //               ),
// //               const SizedBox(height: 30),
// //               SizedBox(
// //                 width: double.infinity,
// //                 child: ElevatedButton.icon(
// //                   style: ElevatedButton.styleFrom(
// //                     padding: const EdgeInsets.symmetric(vertical: 16),
// //                     backgroundColor: Colors.teal,
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                   ),
// //                   icon: const Icon(Icons.send),
// //                   label: const Text("Submit", style: TextStyle(fontSize: 16)),
// //                   onPressed: _submitApplication,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildInput(String label, TextEditingController controller,
// //       {TextInputType? inputType}) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 12),
// //       child: TextFormField(
// //         controller: controller,
// //         keyboardType: inputType,
// //         decoration: _buildDecoration(label),
// //         validator: (value) => value!.isEmpty ? "Please enter $label" : null,
// //       ),
// //     );
// //   }
// //
// //   Widget _buildDropdown<T>({
// //     required String hint,
// //     required T? value,
// //     required List<DropdownMenuItem<T>> items,
// //     required void Function(T?) onChanged,
// //   }) {
// //     return DropdownButtonFormField<T>(
// //       decoration: _buildDecoration(hint),
// //       value: value,
// //       items: items,
// //       onChanged: onChanged,
// //       validator: (val) => val == null ? 'Please select $hint' : null,
// //     );
// //   }
// //
// //   InputDecoration _buildDecoration(String hint) {
// //     return InputDecoration(
// //       hintText: hint,
// //       contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
// //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
// //       filled: true,
// //       fillColor: Colors.white,
// //     );
// //   }
// // }