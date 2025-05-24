import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final int _recordsPerPage = 15;
  List<Map<String, dynamic>> _attendanceRecords = [];
  bool _isLoading = false;
  bool _hasMoreData = true;
  DateTime? _selectedDate;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadInitialAttendance();
  }

  Future<void> _loadInitialAttendance() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    _attendanceRecords = [];
    _lastDocument = null;
    _hasMoreData = true;

    await _loadMoreAttendance();
    setState(() => _isLoading = false);
  }

  Future<void> _loadMoreAttendance() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() => _isLoading = true);
    User? user = _auth.currentUser;

    if (user != null && _selectedDate != null) {
      final startDate = DateTime(_selectedDate!.year, _selectedDate!.month, 1);
      final endDate = DateTime(_selectedDate!.year, _selectedDate!.month + 1, 0);

      Query query = _firestore.collection('attendance')
          .where('userId', isEqualTo: user.uid)
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: endDate)
          .orderBy('timestamp', descending: true)
          .limit(_recordsPerPage);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _hasMoreData = false;
          _isLoading = false;
        });
        return;
      }

      _lastDocument = querySnapshot.docs.last;

      setState(() {
        _attendanceRecords.addAll(querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            ...data,
            'id': doc.id,
          };
        }).toList());
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      await _loadInitialAttendance();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'Attendance History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showDatePicker,
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          _buildSummaryCard(),

          // Attendance List
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
                    !_isLoading &&
                    _hasMoreData) {
                  _loadMoreAttendance();
                }
                return false;
              },
              child: _attendanceRecords.isEmpty && !_isLoading
                  ? const Center(child: Text('No attendance records found'))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _attendanceRecords.length + (_hasMoreData ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _attendanceRecords.length) {
                    return _buildLoadingIndicator();
                  }

                  final record = _attendanceRecords[index];
                  final dateTime = (record['timestamp'] as Timestamp).toDate();

                  return _buildAttendanceCard(record, dateTime);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final boardingCount = _attendanceRecords.where((r) => r['type'] == 'boarding').length;
    final departureCount = _attendanceRecords.where((r) => r['type'] == 'departure').length;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate != null
                      ? DateFormat('MMMM yyyy').format(_selectedDate!)
                      : 'Select Month',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  count: boardingCount,
                  label: 'Boarded',
                  color: Colors.green,
                ),
                _buildSummaryItem(
                  count: departureCount,
                  label: 'Departed',
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> record, DateTime dateTime) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(dateTime),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 20, thickness: 1.2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatus(
                  icon: Icons.directions_bus,
                  label: 'Boarded',
                  color: Colors.green,
                  status: record['type'] == 'boarding',
                  time: DateFormat('h:mm a').format(dateTime),
                ),
                _buildStatus(
                  icon: Icons.exit_to_app,
                  label: 'Departed',
                  color: Colors.red,
                  status: record['type'] == 'departure',
                  time: record['type'] == 'departure'
                      ? DateFormat('h:mm a').format(dateTime)
                      : 'Not recorded',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildSummaryItem({
    required int count,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatus({
    required IconData icon,
    required String label,
    required Color color,
    required bool status,
    required String time,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(width: 6),
            Icon(
              status ? Icons.check_circle : Icons.cancel,
              color: status ? color : Colors.grey,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            color: status ? color : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}







// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
//
// class AttendancePage extends StatefulWidget {
//   const AttendancePage({super.key});
//
//   @override
//   _AttendancePageState createState() => _AttendancePageState();
// }
//
// class _AttendancePageState extends State<AttendancePage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   List<Map<String, dynamic>> _attendanceRecords = [];
//   bool _isLoading = false;
//   DateTime? _selectedDate;
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedDate = DateTime.now();
//     _loadAttendance();
//   }
//
//   Future<void> _loadAttendance() async {
//     setState(() => _isLoading = true);
//     User? user = _auth.currentUser;
//
//     if (user != null && _selectedDate != null) {
//       final startDate = DateTime(_selectedDate!.year, _selectedDate!.month, 1);
//       final endDate = DateTime(_selectedDate!.year, _selectedDate!.month + 1, 0);
//
//       QuerySnapshot query = await _firestore.collection('attendance')
//           .where('userId', isEqualTo: user.uid)
//           .where('timestamp', isGreaterThanOrEqualTo: startDate)
//           .where('timestamp', isLessThanOrEqualTo: endDate)
//           .orderBy('timestamp', descending: true)
//           .get();
//
//       setState(() {
//         _attendanceRecords = query.docs.map((doc) {
//           final data = doc.data() as Map<String, dynamic>;
//           return {
//             ...data,
//             'id': doc.id,
//           };
//         }).toList();
//         _isLoading = false;
//       });
//     } else {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _showDatePicker() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//     );
//
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//       await _loadAttendance();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.teal,
//         title: const Text(
//           'Attendance History',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//         elevation: 4,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.calendar_today),
//             onPressed: _showDatePicker,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Date and Summary Section
//           Card(
//             margin: const EdgeInsets.all(16),
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         _selectedDate != null
//                             ? DateFormat('MMMM yyyy').format(_selectedDate!)
//                             : 'Select Month',
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const Icon(Icons.calendar_today),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildSummaryItem(
//                         count: _attendanceRecords.where((r) => r['type'] == 'boarding').length,
//                         label: 'Boarded',
//                         color: Colors.green,
//                       ),
//                       _buildSummaryItem(
//                         count: _attendanceRecords.where((r) => r['type'] == 'departure').length,
//                         label: 'Departed',
//                         color: Colors.red,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // Attendance History Section
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : ListView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               itemCount: _attendanceRecords.length,
//               itemBuilder: (context, index) {
//                 final record = _attendanceRecords[index];
//                 final dateTime = (record['timestamp'] as Timestamp).toDate();
//
//                 return Card(
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   margin: const EdgeInsets.only(bottom: 12),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           DateFormat('EEEE, MMMM d, yyyy').format(dateTime),
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const Divider(height: 20, thickness: 1.2),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             _buildStatus(
//                               icon: Icons.directions_bus,
//                               label: 'Boarded',
//                               color: Colors.green,
//                               status: record['type'] == 'boarding',
//                               time: DateFormat('h:mm a').format(dateTime),
//                             ),
//                             _buildStatus(
//                               icon: Icons.exit_to_app,
//                               label: 'Departed',
//                               color: Colors.red,
//                               status: record['type'] == 'departure',
//                               time: record['type'] == 'departure'
//                                   ? DateFormat('h:mm a').format(dateTime)
//                                   : 'Not recorded',
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSummaryItem({
//     required int count,
//     required String label,
//     required Color color,
//   }) {
//     return Column(
//       children: [
//         Text(
//           count.toString(),
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         Text(
//           label,
//           style: const TextStyle(fontWeight: FontWeight.w500),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStatus({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required bool status,
//     required String time,
//   }) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Icon(icon, color: color),
//             const SizedBox(width: 6),
//             Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
//             const SizedBox(width: 6),
//             Icon(
//               status ? Icons.check_circle : Icons.cancel,
//               color: status ? color : Colors.grey,
//             ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         Text(
//           time,
//           style: TextStyle(
//             color: status ? color : Colors.grey,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
// }






// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class AttendancePage extends StatefulWidget {
//   const AttendancePage({super.key});
//
//   @override
//   _AttendancePageState createState() => _AttendancePageState();
// }
//
// class _AttendancePageState extends State<AttendancePage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   List<Map<String, dynamic>> _attendanceRecords = [];
//   bool _isBoarded = false;
//   bool _isDeparted = false;
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAttendance();
//   }
//
//   Future<void> _loadAttendance() async {
//     User? user = _auth.currentUser;
//     if (user != null) {
//       QuerySnapshot query = await _firestore.collection('attendance')
//           .where('userId', isEqualTo: user.uid)
//           .orderBy('timestamp', descending: true)
//           .get();
//
//       setState(() {
//         _attendanceRecords = query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
//       });
//     }
//   }
//
//   Future<void> _markAttendance(String type) async {
//     setState(() => _isLoading = true);
//     User? user = _auth.currentUser;
//
//     if (user != null) {
//       try {
//         await _firestore.collection('attendance').add({
//           'userId': user.uid,
//           'type': type,
//           'timestamp': FieldValue.serverTimestamp(),
//         });
//
//         setState(() {
//           if (type == 'boarding') {
//             _isBoarded = true;
//             _isDeparted = false;
//           } else {
//             _isBoarded = false;
//             _isDeparted = true;
//           }
//         });
//
//         await _loadAttendance(); // Refresh the list
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${e.toString()}')),
//         );
//       } finally {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.teal,
//         title: const Text(
//           'Attendance History',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//         elevation: 4,
//       ),
//       body: Column(
//         children: [
//           // Attendance Marking Section
//           Card(
//             margin: const EdgeInsets.all(16),
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   const Text(
//                     'Mark Your Attendance',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.teal,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       Column(
//                         children: [
//                           Checkbox(
//                             value: _isBoarded,
//                             onChanged: (value) {
//                               if (value == true) {
//                                 _markAttendance('boarding');
//                               }
//                             },
//                             activeColor: Colors.green,
//                           ),
//                           const Text('Boarded', style: TextStyle(fontWeight: FontWeight.w500)),
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           Checkbox(
//                             value: _isDeparted,
//                             onChanged: (value) {
//                               if (value == true) {
//                                 _markAttendance('departure');
//                               }
//                             },
//                             activeColor: Colors.red,
//                           ),
//                           const Text('Departed', style: TextStyle(fontWeight: FontWeight.w500)),
//                         ],
//                       ),
//                     ],
//                   ),
//                   if (_isLoading) const CircularProgressIndicator(),
//                 ],
//               ),
//             ),
//           ),
//
//           // Attendance History Section
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               itemCount: _attendanceRecords.length,
//               itemBuilder: (context, index) {
//                 final record = _attendanceRecords[index];
//                 final dateTime = (record['timestamp'] as Timestamp).toDate();
//
//                 return Card(
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   margin: const EdgeInsets.only(bottom: 12),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           '${dateTime.day}/${dateTime.month}/${dateTime.year}',
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.teal,
//                           ),
//                         ),
//                         const Divider(height: 20, thickness: 1.2),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             _buildStatus(
//                               icon: Icons.login,
//                               label: 'Boarded',
//                               color: Colors.green,
//                               status: record['type'] == 'boarding',
//                             ),
//                             _buildStatus(
//                               icon: Icons.logout,
//                               label: 'Departed',
//                               color: Colors.red,
//                               status: record['type'] == 'departure',
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatus({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required bool status,
//   }) {
//     return Row(
//       children: [
//         Icon(icon, color: color),
//         const SizedBox(width: 6),
//         Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
//         Icon(
//           status ? Icons.check_circle : Icons.cancel,
//           color: status ? color : Colors.grey,
//         ),
//       ],
//     );
//   }
// }







// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class AttendancePage extends StatefulWidget {
//   const AttendancePage({super.key});
//
//   @override
//   _AttendancePageState createState() => _AttendancePageState();
// }
//
// class _AttendancePageState extends State<AttendancePage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   List<Map<String, dynamic>> _attendanceRecords = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAttendance();
//   }
//
//   Future<void> _loadAttendance() async {
//     User? user = _auth.currentUser;
//     if (user != null) {
//       QuerySnapshot query = await _firestore.collection('attendance')
//           .where('userId', isEqualTo: user.uid)
//           .orderBy('timestamp', descending: true)
//           .get();
//
//       setState(() {
//         _attendanceRecords = query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.teal,
//         title: const Text(
//           'Attendance History',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//         elevation: 4,
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: _attendanceRecords.length,
//         itemBuilder: (context, index) {
//           final record = _attendanceRecords[index];
//           final dateTime = (record['timestamp'] as Timestamp).toDate();
//
//           return Card(
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             margin: const EdgeInsets.only(bottom: 12),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     '${dateTime.day}/${dateTime.month}/${dateTime.year}',
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.teal,
//                     ),
//                   ),
//                   const Divider(height: 20, thickness: 1.2),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       _buildStatus(
//                         icon: Icons.login,
//                         label: 'Boarded',
//                         color: Colors.green,
//                         status: record['type'] == 'boarding',
//                       ),
//                       _buildStatus(
//                         icon: Icons.logout,
//                         label: 'Departed',
//                         color: Colors.red,
//                         status: record['type'] == 'departure',
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildStatus({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required bool status,
//   }) {
//     return Row(
//       children: [
//         Icon(icon, color: color),
//         const SizedBox(width: 6),
//         Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
//         Icon(
//           status ? Icons.check_circle : Icons.cancel,
//           color: status ? color : Colors.grey,
//         ),
//       ],
//     );
//   }
// }










// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
//
// class AttendancePage extends StatefulWidget {
//   const AttendancePage({super.key});
//
//   @override
//   State<AttendancePage> createState() => _AttendancePageState();
// }
//
// class _AttendancePageState extends State<AttendancePage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   List<Map<String, dynamic>> _attendanceRecords = [];
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAttendance();
//   }
//
//   Future<void> _loadAttendance() async {
//     final user = _auth.currentUser;
//     if (user == null) return;
//
//     final userDoc = await _firestore.collection('users').doc(user.uid).get();
//     final invoiceNumber = userDoc.data()?['invoiceNumber'];
//
//     if (invoiceNumber == null) {
//       setState(() => _isLoading = false);
//       return;
//     }
//
//     final query = await _firestore.collection('attendance')
//         .where('invoiceNumber', isEqualTo: invoiceNumber)
//         .orderBy('scanTime', descending: true)
//         .get();
//
//     setState(() {
//       _attendanceRecords = query.docs.map((doc) => doc.data()).toList();
//       _isLoading = false;
//     });
//   }
//
//   void _showScanner(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const QrScannerPage()),
//     ).then((_) => _loadAttendance());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Attendance Records'),
//         backgroundColor: Colors.teal,
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showScanner(context),
//         backgroundColor: Colors.teal,
//         child: const Icon(Icons.qr_code_scanner),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _attendanceRecords.isEmpty
//           ? const Center(child: Text('No attendance records found'))
//           : ListView.builder(
//         itemCount: _attendanceRecords.length,
//         itemBuilder: (context, index) {
//           final record = _attendanceRecords[index];
//           final date = (record['scanTime'] as Timestamp).toDate();
//
//           return Card(
//             margin: const EdgeInsets.all(8),
//             child: ListTile(
//               leading: Icon(
//                 record['status'] == 'arrival'
//                     ? Icons.directions_bus
//                     : Icons.exit_to_app,
//                 color: Colors.teal,
//               ),
//               title: Text(
//                 '${date.day}/${date.month}/${date.year}',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               subtitle: Text(
//                 '${date.hour}:${date.minute.toString().padLeft(2, '0')} - '
//                     '${record['status']?.toString().toUpperCase() ?? 'N/A'}',
//               ),
//               trailing: Text(
//                 record['busNumber'] ?? 'N/A',
//                 style: const TextStyle(color: Colors.teal),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class QrScannerPage extends StatefulWidget {
//   const QrScannerPage({super.key});
//
//   @override
//   State<QrScannerPage> createState() => _QrScannerPageState();
// }
//
// class _QrScannerPageState extends State<QrScannerPage> {
//   final MobileScannerController _controller = MobileScannerController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   bool _isProcessing = false;
//
//   void _handleScan(BarcodeCapture capture) async {
//     if (_isProcessing) return;
//     setState(() => _isProcessing = true);
//
//     try {
//       final barcode = capture.barcodes.first;
//       if (barcode.rawValue == null || !barcode.rawValue!.startsWith('UTS-INV-')) {
//         throw Exception('Invalid QR code');
//       }
//
//       final invoiceNumber = barcode.rawValue!.split('-').last;
//
//       // Record attendance
//       await _firestore.collection('attendance').add({
//         'invoiceNumber': invoiceNumber,
//         'scanTime': FieldValue.serverTimestamp(),
//         'status': 'arrival',
//         'scannedBy': FirebaseAuth.instance.currentUser?.uid,
//         'busNumber': 'A-1346', // Replace with actual bus number
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Attendance recorded successfully')),
//       );
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     } finally {
//       setState(() => _isProcessing = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scan QR Code'),
//         backgroundColor: Colors.teal,
//         actions: [
//           IconButton(
//             icon: ValueListenableBuilder(
//               valueListenable: _controller.torchState,
//               builder: (context, state, child) {
//                 switch (state) {
//                   case TorchState.off:
//                     return const Icon(Icons.flash_off, color: Colors.grey);
//                   case TorchState.on:
//                     return const Icon(Icons.flash_on, color: Colors.yellow);
//                 }
//               },
//             ),
//             onPressed: () => _controller.toggleTorch(),
//           ),
//         ],
//       ),
//       body: MobileScanner(
//         controller: _controller,
//         onDetect: _handleScan,
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }
//
//
//
//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class AttendancePage extends StatefulWidget {
//   const AttendancePage({super.key});
//
//   @override
//   State<AttendancePage> createState() => _AttendancePageState();
// }
//
// class _AttendancePageState extends State<AttendancePage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   List<Map<String, dynamic>> _attendanceRecords = [];
//   bool _isLoading = true;
//   Map<String, bool> _attendanceStatus = {}; // To track checkbox status
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAttendance();
//   }
//
//   Future<void> _loadAttendance() async {
//     final user = _auth.currentUser;
//     if (user == null) {
//       setState(() => _isLoading = false);
//       return;
//     }
//
//     final userDoc = await _firestore.collection('users').doc(user.uid).get();
//     final invoiceNumber = userDoc.data()?['invoiceNumber'];
//
//     if (invoiceNumber == null) {
//       setState(() => _isLoading = false);
//       return;
//     }
//
//     final query = await _firestore.collection('attendance')
//         .where('invoiceNumber', isEqualTo: invoiceNumber)
//         .orderBy('scanTime', descending: true)
//         .get();
//
//     setState(() {
//       _attendanceRecords = query.docs.map((doc) {
//         final data = doc.data();
//         _attendanceStatus[doc.id] = data['verified'] ?? false;
//         return data;
//       }).toList();
//       _isLoading = false;
//     });
//   }
//
//   Future<void> _updateAttendanceStatus(String docId, bool isPresent) async {
//     try {
//       await _firestore.collection('attendance').doc(docId).update({
//         'verified': isPresent,
//         'verifiedBy': _auth.currentUser?.uid,
//         'verifiedAt': FieldValue.serverTimestamp(),
//       });
//
//       setState(() {
//         _attendanceStatus[docId] = isPresent;
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Attendance updated successfully')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error updating attendance: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Attendance Records'),
//         backgroundColor: Colors.teal,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _attendanceRecords.isEmpty
//           ? const Center(child: Text('No attendance records found'))
//           : ListView.builder(
//         itemCount: _attendanceRecords.length,
//         itemBuilder: (context, index) {
//           final record = _attendanceRecords[index];
//           final date = (record['scanTime'] as Timestamp).toDate();
//           final docId = record['id'] ?? ''; // Make sure your records have IDs
//
//           return Card(
//             margin: const EdgeInsets.all(8),
//             child: ListTile(
//               leading: Icon(
//                 record['status'] == 'arrival'
//                     ? Icons.directions_bus
//                     : Icons.exit_to_app,
//                 color: Colors.teal,
//               ),
//               title: Text(
//                 '${date.day}/${date.month}/${date.year}',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               subtitle: Text(
//                 '${date.hour}:${date.minute.toString().padLeft(2, '0')} - '
//                     '${record['status']?.toString().toUpperCase() ?? 'N/A'}',
//               ),
//               trailing: Checkbox(
//                 value: _attendanceStatus[docId] ?? false,
//                 onChanged: (bool? value) {
//                   if (value != null) {
//                     _updateAttendanceStatus(docId, value);
//                   }
//                 },
//                 activeColor: Colors.teal,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//}