import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverDetailPage extends StatefulWidget {
  final String? selectedBusNumber;
  final String? selectedRoute;
  final String? driverName;
  final String? driverContact;

  const DriverDetailPage({
    super.key,
    this.selectedBusNumber,
    this.selectedRoute,
    this.driverName,
    this.driverContact,
  });

  @override
  State<DriverDetailPage> createState() => _DriverDetailPageState();
}

class _DriverDetailPageState extends State<DriverDetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Map<String, dynamic> _driverData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _handleDriverData();
  }

  Future<void> _handleDriverData() async {
    try {
      // Check if we have complete data from ApplyPage
      final hasCompleteData = widget.selectedBusNumber != null &&
          widget.driverName != null &&
          widget.driverContact != null;

      // Try to load existing driver data first
      final query = await _firestore.collection('drivers')
          .where('busNumber', isEqualTo: widget.selectedBusNumber)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        // Use existing data if found
        setState(() {
          _driverData = query.docs.first.data();
          _isLoading = false;
        });
      } else if (hasCompleteData) {
        // Create new driver record if we have complete data but none exists
        final docRef = _firestore.collection('drivers').doc();

        _driverData = {
          'id': docRef.id,
          'driverName': widget.driverName,
          'contactNumber': widget.driverContact,
          'busNumber': widget.selectedBusNumber,
          'route': widget.selectedRoute,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await docRef.set(_driverData);

        setState(() {
          _isLoading = false;
        });
      } else {
        // No existing data and incomplete new data
        setState(() {
          _isLoading = false;
          _driverData = {
            'driverName': widget.driverName,
            'contactNumber': widget.driverContact,
            'busNumber': widget.selectedBusNumber,
            'route': widget.selectedRoute,
          };
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error handling driver data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text("Bus Driver Details"),
        centerTitle: true,
        backgroundColor: Colors.teal.shade700,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Driver Information",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailCard(
                  title: "Driver",
                  content: _driverData['driverName'] ?? 'Not available',
                  icon: Icons.person,
                ),
                _buildDetailCard(
                  title: "Contact",
                  content: _driverData['contactNumber'] ?? 'Not available',
                  icon: Icons.phone,
                ),
                _buildDetailCard(
                  title: "Bus Number",
                  content: _driverData['busNumber'] ?? 'Not available',
                  icon: Icons.directions_bus,
                ),
                _buildDetailCard(
                  title: "Route",
                  content: _driverData['route'] ?? 'Not available',
                  icon: Icons.route,
                ),
                if (_driverData['createdAt'] != null)
                  _buildDetailCard(
                    title: "Since",
                    content: _driverData['createdAt'].toDate().toString().split(' ')[0],
                    icon: Icons.calendar_today,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.teal),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'Main_page.dart';
// import 'DriverDetailPage.dart';
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
//
// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// //
// // class DriverDetailPage extends StatefulWidget {
// //
// //   DriverDetailPage({super.key});
// //
// //   @override
// //   State<DriverDetailPage> createState() => _DriverDetailPageState();
// // }
// //
// // class _DriverDetailPageState extends State<DriverDetailPage> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //
// //   final _formKey = GlobalKey<FormState>();
// //
// //   final driverNameController = TextEditingController();
// //
// //   final contactNumberController = TextEditingController();
// //
// //   final busNumberController = TextEditingController();
// //
// //   final routeController = TextEditingController();
// //
// //   Future<void> _saveDriverDetails() async {
// //     if (_formKey.currentState!.validate()) {
// //       try {
// //         await _firestore.collection('drivers').add({
// //           'driverName': driverNameController.text,
// //           'contactNumber': contactNumberController.text,
// //           'busNumber': busNumberController.text,
// //           'route': routeController.text,
// //           'createdAt': FieldValue.serverTimestamp(),
// //         });
// //
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('Driver details saved successfully')),
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
// //       backgroundColor: const Color(0xFFF4F4F4),
// //       appBar: AppBar(
// //         title: const Text("Driver Details"),
// //         centerTitle: true,
// //         backgroundColor: Colors.teal.shade700,
// //       ),
// //       body: SingleChildScrollView(
// //         child: Padding(
// //           padding: const EdgeInsets.all(20),
// //           child: Card(
// //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
// //             elevation: 4,
// //             child: Padding(
// //               padding: const EdgeInsets.all(20),
// //               child: Form(
// //                 key: _formKey,
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.stretch,
// //                   children: [
// //                     const Text(
// //                       "Enter Driver Information",
// //                       style: TextStyle(
// //                         fontSize: 20,
// //                         fontWeight: FontWeight.w600,
// //                         color: Colors.teal,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 20),
// //                     _buildTextField("Driver Name", Icons.person, TextInputType.name, driverNameController),
// //                     _buildTextField("Contact Number", Icons.phone, TextInputType.phone, contactNumberController),
// //                     _buildTextField("Bus Number", Icons.directions_bus, TextInputType.text, busNumberController),
// //                     _buildTextField("Route", Icons.alt_route, TextInputType.name, routeController),
// //                     const SizedBox(height: 30),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildTextField(String label, IconData icon, TextInputType keyboardType, TextEditingController controller) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 16),
// //       child: TextFormField(
// //         controller: controller,
// //         keyboardType: keyboardType,
// //         decoration: InputDecoration(
// //           labelText: label,
// //           prefixIcon: Icon(icon),
// //           filled: true,
// //           fillColor: Colors.white,
// //           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
// //         ),
// //         validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
// //       ),
// //     );
// //   }
// // }