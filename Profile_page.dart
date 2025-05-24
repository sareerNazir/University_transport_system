import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  File? _imageFile;
  String? _imageUrl;

  // Function to get the correct image provider
  ImageProvider<Object>? _getImageProvider() {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (_imageUrl != null) {
      return NetworkImage(_imageUrl!);
    }
    return null;
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        await _uploadImage();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: ${e.toString()}')),
      );
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null || _auth.currentUser == null) return;

    setState(() => _isLoading = true);
    try {
      final ref = _storage.ref().child('profile_images/${_auth.currentUser!.uid}');
      await ref.putFile(_imageFile!);
      _imageUrl = await ref.getDownloadURL();

      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'profileImageUrl': _imageUrl,
      });

      setState(() {
        _userData?['profileImageUrl'] = _imageUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final busApplication = await _firestore.collection('bus_applications')
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get();

    setState(() {
      _userData = userDoc.data();
      if (busApplication.docs.isNotEmpty) {
        _userData?.addAll(busApplication.docs.first.data());
      }
      _imageUrl = _userData?['profileImageUrl'];
      _isLoading = false;
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.teal),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.teal,
                  backgroundImage: _getImageProvider(),
                  child: _getImageProvider() == null
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      onPressed: _pickImage,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _userData?['name'] ?? 'N/A',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _userData?['email'] ?? 'N/A',
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 30),

            // Rest of the profile information...
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildInfoRow('Roll Number', _userData?['rollNo'] ?? 'N/A'),
            _buildInfoRow('Department', _userData?['department'] ?? 'N/A'),
            _buildInfoRow('Degree', _userData?['degree'] ?? 'Not specified'),
            _buildInfoRow('Session', _userData?['session'] ?? 'Not specified'),
            _buildInfoRow('Gender', _userData?['gender'] ?? 'Not specified'),
            _buildInfoRow('Disability', _userData?['isDisabled'] ?? 'No'),
            const Divider(height: 30),

            if (_userData?['busNumber'] != null ||
                _userData?['route'] != null ||
                _userData?['stop'] != null)
              Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Bus Assignment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_userData?['busNumber'] != null)
                    _buildInfoRow('Assigned Bus', _userData!['busNumber']),
                  if (_userData?['route'] != null)
                    _buildInfoRow('Route', _userData!['route']),
                  if (_userData?['stop'] != null)
                    _buildInfoRow('Bus Stop', _userData!['stop']),
                  const Divider(height: 30),
                ],
              ),

            _buildInfoRow('Status', _userData?['status'] ?? 'Pending'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // QR Code functionality here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                'Show My QR Code',
                style: TextStyle(color: Colors.white),
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
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
//
// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});
//
//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }
//
// class _ProfilePageState extends State<ProfilePage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final ImagePicker _picker = ImagePicker();
//
//   Map<String, dynamic>? _userData;
//   bool _isLoading = true;
//   File? _imageFile;
//   String? _imageUrl;
//
//   Future<void> _pickImage() async {
//     try {
//       final pickedFile = await _picker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 800,
//         maxHeight: 800,
//         imageQuality: 85,
//       );
//
//       if (pickedFile != null) {
//         setState(() {
//           _imageFile = File(pickedFile.path);
//         });
//         await _uploadImage();
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error picking image: ${e.toString()}')),
//       );
//     }
//   }
//
//   Future<void> _uploadImage() async {
//     if (_imageFile == null || _auth.currentUser == null) return;
//
//     setState(() => _isLoading = true);
//     try {
//       // Upload to Firebase Storage
//       final ref = _storage.ref().child('profile_images/${_auth.currentUser!.uid}');
//       await ref.putFile(_imageFile!);
//
//       // Get download URL
//       _imageUrl = await ref.getDownloadURL();
//
//       // Update Firestore with image URL
//       await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
//         'profileImageUrl': _imageUrl,
//       });
//
//       // Update local state
//       setState(() {
//         _userData?['profileImageUrl'] = _imageUrl;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error uploading image: ${e.toString()}')),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
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
//     final busApplication = await _firestore.collection('bus_applications')
//         .where('userId', isEqualTo: user.uid)
//         .limit(1)
//         .get();
//
//     setState(() {
//       _userData = userDoc.data();
//       if (busApplication.docs.isNotEmpty) {
//         _userData?.addAll(busApplication.docs.first.data());
//       }
//       _imageUrl = _userData?['profileImageUrl'];
//       _isLoading = false;
//     });
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           Text(
//             value,
//             style: const TextStyle(color: Colors.teal),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Student Profile'),
//         backgroundColor: Colors.teal,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Stack(
//               children: [
//                 CircleAvatar(
//                   radius: 50,
//                   backgroundColor: Colors.teal,
//                   backgroundImage: _imageFile != null
//                       ? FileImage(_imageFile!)
//                       : _imageUrl != null
//                       ? NetworkImage(_imageUrl!)
//                       : null,
//                   child: _imageFile == null && _imageUrl == null
//                       ? const Icon(Icons.person, size: 50, color: Colors.white)
//                       : null,
//                 ),
//                 Positioned(
//                   bottom: 0,
//                   right: 0,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.teal,
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.white, width: 2),
//                     ),
//                     child: IconButton(
//                       icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
//                       onPressed: _pickImage,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Text(
//               _userData?['name'] ?? 'N/A',
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               _userData?['email'] ?? 'N/A',
//               style: const TextStyle(color: Colors.grey),
//             ),
//             const Divider(height: 30),
//
//             // Rest of your existing profile information
//             const Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Personal Information',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.teal,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             _buildInfoRow('Roll Number', _userData?['rollNo'] ?? 'N/A'),
//             _buildInfoRow('Department', _userData?['department'] ?? 'N/A'),
//             _buildInfoRow('Degree', _userData?['degree'] ?? 'Not specified'),
//             _buildInfoRow('Session', _userData?['session'] ?? 'Not specified'),
//             _buildInfoRow('Gender', _userData?['gender'] ?? 'Not specified'),
//             _buildInfoRow('Disability', _userData?['isDisabled'] ?? 'No'),
//             const Divider(height: 30),
//
//             if (_userData?['busNumber'] != null ||
//                 _userData?['route'] != null ||
//                 _userData?['stop'] != null)
//               Column(
//                 children: [
//                   const Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       'Bus Assignment',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.teal,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   if (_userData?['busNumber'] != null)
//                     _buildInfoRow('Assigned Bus', _userData!['busNumber']),
//                   if (_userData?['route'] != null)
//                     _buildInfoRow('Route', _userData!['route']),
//                   if (_userData?['stop'] != null)
//                     _buildInfoRow('Bus Stop', _userData!['stop']),
//                   const Divider(height: 30),
//                 ],
//               ),
//
//             _buildInfoRow('Status', _userData?['status'] ?? 'Pending'),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () {
//                 // QR Code functionality here
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.teal,
//                 padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//               ),
//               child: const Text(
//                 'Show My QR Code',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:file_picker/file_picker.dart';
// import 'dart:io';
//
//
//
// class TestImagePicker extends StatefulWidget {
//   @override
//   _TestImagePickerState createState() => _TestImagePickerState();
// }
//
// class _TestImagePickerState extends State<TestImagePicker> {
//   File? _image;
//
//   Future getImage() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 30, maxHeight: 40, imageQuality: 250);
//     setState(() {
//       if (pickedFile != null) {
//         _image = File(pickedFile.path);
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           children: [
//             ElevatedButton(
//               onPressed: getImage,
//               child: Text('Pick Image'),
//             ),
//             _image != null
//                 ? Image.file(_image!, height: 200)
//                 : Text('No image selected'),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});
//
//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }
//
// class _ProfilePageState extends State<ProfilePage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final ImagePicker _picker = ImagePicker();
//
//   Map<String, dynamic>? _userData;
//   bool _isLoading = true;
//   File? _imageFile;
//
//   Future<void> _pickImage() async {
//     try {
//       final File? pickedFile = await _picker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 800,
//         maxHeight: 800,
//         imageQuality: 85,
//       );
//
//       if (pickedFile != null) {
//         setState(() {
//           _imageFile = File(pickedFile.path);
//         });
//         // Here you would add code to upload to Firebase Storage
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error picking image: ${e.toString()}')),
//       );
//     }
//   }
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
//     final busApplication = await _firestore.collection('bus_applications')
//         .where('userId', isEqualTo: user.uid)
//         .limit(1)
//         .get();
//
//     setState(() {
//       _userData = userDoc.data();
//       if (busApplication.docs.isNotEmpty) {
//         _userData?.addAll(busApplication.docs.first.data());
//       }
//       _isLoading = false;
//     });
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           Text(
//             value,
//             style: const TextStyle(color: Colors.teal),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Student Profile'),
//         backgroundColor: Colors.teal,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             GestureDetector(
//               onTap: _pickImage,
//               child: CircleAvatar(
//                 radius: 50,
//                 backgroundColor: Colors.teal,
//                 backgroundImage: _imageFile != null
//                     ? FileImage(_imageFile!)
//                     : null,
//                 child: _imageFile == null
//                     ? const Icon(Icons.person, size: 50, color: Colors.white)
//                     : null,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               _userData?['name'] ?? 'N/A',
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               _userData?['email'] ?? 'N/A',
//               style: const TextStyle(color: Colors.grey),
//             ),
//             const Divider(height: 30),
//
//             // Rest of your existing UI remains unchanged
//             const Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Personal Information',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.teal,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             _buildInfoRow('Roll Number', _userData?['rollNo'] ?? 'N/A'),
//             _buildInfoRow('Department', _userData?['department'] ?? 'N/A'),
//             _buildInfoRow('Degree', _userData?['degree'] ?? 'Not specified'),
//             _buildInfoRow('Session', _userData?['session'] ?? 'Not specified'),
//             _buildInfoRow('Gender', _userData?['gender'] ?? 'Not specified'),
//             _buildInfoRow('Disability', _userData?['isDisabled'] ?? 'No'),
//             const Divider(height: 30),
//
//             if (_userData?['busNumber'] != null ||
//                 _userData?['route'] != null ||
//                 _userData?['stop'] != null)
//               Column(
//                 children: [
//                   const Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       'Bus Assignment',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.teal,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   if (_userData?['busNumber'] != null)
//                     _buildInfoRow('Assigned Bus', _userData!['busNumber']),
//                   if (_userData?['route'] != null)
//                     _buildInfoRow('Route', _userData!['route']),
//                   if (_userData?['stop'] != null)
//                     _buildInfoRow('Bus Stop', _userData!['stop']),
//                   const Divider(height: 30),
//                 ],
//               ),
//
//             _buildInfoRow('Status', _userData?['status'] ?? 'Pending'),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () {
//                 // QR Code functionality here
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.teal,
//                 padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//               ),
//               child: const Text(
//                 'Show My QR Code',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class ImagePicker {
//   pickImage({required source, required int maxWidth, required int maxHeight, required int imageQuality}) {}
// }
//
// class ImageSource {
//   static var gallery;
// }




// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});
//
//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }
//
// class _ProfilePageState extends State<ProfilePage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   Map<String, dynamic>? _userData;
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
//     final busApplication = await _firestore.collection('bus_applications')
//         .where('userId', isEqualTo: user.uid)
//         .limit(1)
//         .get();
//
//     setState(() {
//       _userData = userDoc.data();
//       if (busApplication.docs.isNotEmpty) {
//         _userData?.addAll(busApplication.docs.first.data());
//       }
//       _isLoading = false;
//     });
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           Text(
//             value,
//             style: const TextStyle(color: Colors.teal),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Student Profile'),
//         backgroundColor: Colors.teal,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             const CircleAvatar(
//               radius: 50,
//               backgroundColor: Colors.teal,
//               child: Icon(Icons.person, size: 50, color: Colors.white),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               _userData?['name'] ?? 'N/A',
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               _userData?['email'] ?? 'N/A',
//               style: const TextStyle(color: Colors.grey),
//             ),
//             const Divider(height: 30),
//             _buildInfoRow('Roll Number', _userData?['rollNo'] ?? 'N/A'),
//             _buildInfoRow('Department', _userData?['department'] ?? 'N/A'),
//             _buildInfoRow('Gender', _userData?['gender'] ?? 'Not specified'),
//             _buildInfoRow('Disability', _userData?['isDisabled'] ?? 'No'),
//             const Divider(height: 30),
//
//             // Bus Assignment Information Section
//             if (_userData?['busNumber'] != null ||
//                 _userData?['route'] != null ||
//                 _userData?['stop'] != null)
//               Column(
//                 children: [
//                   const Text(
//                     'Bus Assignment',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.teal,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   if (_userData?['busNumber'] != null)
//                     _buildInfoRow('Assigned Bus', _userData!['busNumber']),
//                   if (_userData?['route'] != null)
//                     _buildInfoRow('Route', _userData!['route']),
//                   if (_userData?['stop'] != null)
//                     _buildInfoRow('Bus Stop', _userData!['stop']),
//                   const Divider(height: 30),
//                 ],
//               ),
//
//             _buildInfoRow('Status', _userData?['status'] ?? 'Pending'),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () => Navigator.pushNamed(context, '/qr-generator'),
//               child: const Text('Show My QR Code'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});
//
//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }
//
// class _ProfilePageState extends State<ProfilePage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   Map<String, dynamic>? _userData;
//   bool _isLoading = true;
//   List<String> _availableBuses = [];
//   List<String> _availableRoutes = [];
//   String? _selectedBus;
//   String? _selectedRoute;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//     _loadBusAndRouteData();
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
//       _selectedBus = _userData?['busNumber'];
//       _selectedRoute = _userData?['route'];
//       _isLoading = false;
//     });
//   }
//
//   Future<void> _loadBusAndRouteData() async {
//     final buses = await _firestore.collection('buses').get();
//     final routes = await _firestore.collection('routes').get();
//
//     setState(() {
//       _availableBuses = buses.docs.map((doc) => doc['number'] as String).toList();
//       _availableRoutes = routes.docs.map((doc) => doc['name'] as String).toList();
//     });
//   }
//
//   Future<void> _assignBusAndRoute() async {
//     if (_selectedBus == null || _selectedRoute == null) return;
//
//     setState(() => _isLoading = true);
//     final user = _auth.currentUser;
//
//     if (user != null) {
//       try {
//         // Update user document
//         await _firestore.collection('users').doc(user.uid).update({
//           'busNumber': _selectedBus,
//           'route': _selectedRoute,
//           'status': 'Assigned',
//         });
//
//         // Update bus application if exists
//         final busApp = await _firestore.collection('bus_applications')
//             .where('userId', isEqualTo: user.uid)
//             .limit(1)
//             .get();
//
//         if (busApp.docs.isNotEmpty) {
//           await _firestore.collection('bus_applications')
//               .doc(busApp.docs.first.id)
//               .update({
//             'busNumber': _selectedBus,
//             'route': _selectedRoute,
//             'status': 'Assigned',
//           });
//         }
//
//         // Reload data
//         await _loadUserData();
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Bus and route assigned successfully!')),
//         );
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
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           Text(
//             value,
//             style: const TextStyle(color: Colors.teal),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 4),
//           DropdownButtonFormField<String>(
//             value: value,
//             items: items.map((item) {
//               return DropdownMenuItem(
//                 value: item,
//                 child: Text(item),
//               );
//             }).toList(),
//             onChanged: onChanged,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Student Profile'),
//         backgroundColor: Colors.teal,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             const CircleAvatar(
//               radius: 50,
//               backgroundColor: Colors.teal,
//               child: Icon(Icons.person, size: 50, color: Colors.white),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               _userData?['name'] ?? 'N/A',
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               _userData?['email'] ?? 'N/A',
//               style: const TextStyle(color: Colors.grey),
//             ),
//             const Divider(height: 30),
//             _buildInfoRow('Roll Number', _userData?['rollNo'] ?? 'N/A'),
//             _buildInfoRow('Department', _userData?['department'] ?? 'N/A'),
//             _buildInfoRow('Gender', _userData?['gender'] ?? 'Not specified'),
//             _buildInfoRow('Disability', _userData?['isDisabled'] ?? 'No'),
//             const Divider(height: 30),
//
//             // Bus and Route Assignment Section
//             if (_userData?['status'] != 'Assigned')
//               Column(
//                 children: [
//                   _buildDropdown(
//                     'Select Bus',
//                     _availableBuses,
//                     _selectedBus,
//                         (value) => setState(() => _selectedBus = value),
//                   ),
//                   _buildDropdown(
//                     'Select Route',
//                     _availableRoutes,
//                     _selectedRoute,
//                         (value) => setState(() => _selectedRoute = value),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: _assignBusAndRoute,
//                     child: const Text('Assign Bus & Route'),
//                   ),
//                   const Divider(height: 30),
//                 ],
//               ),
//
//             // Display assigned bus and route
//             _buildInfoRow('Assigned Bus', _userData?['busNumber'] ?? 'Not assigned'),
//             _buildInfoRow('Route', _userData?['route'] ?? 'Not assigned'),
//             _buildInfoRow('Status', _userData?['status'] ?? 'Pending'),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () => Navigator.pushNamed(context, '/qr-generator'),
//               child: const Text('Show My QR Code'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }







// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});
//
//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }
//
// class _ProfilePageState extends State<ProfilePage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   Map<String, dynamic>? _userData;
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
//       _isLoading = false;
//     });
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           Text(
//             value,
//             style: const TextStyle(color: Colors.teal),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Student Profile'),
//         backgroundColor: Colors.teal,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             const CircleAvatar(
//               radius: 50,
//               backgroundColor: Colors.teal,
//               child: Icon(Icons.person, size: 50, color: Colors.white),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               _userData?['name'] ?? 'N/A',
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               _userData?['email'] ?? 'N/A',
//               style: const TextStyle(color: Colors.grey),
//             ),
//             const Divider(height: 30),
//             _buildInfoRow('Roll Number', _userData?['rollNo'] ?? 'N/A'),
//             _buildInfoRow('Department', _userData?['department'] ?? 'N/A'),
//             _buildInfoRow('Gender', _userData?['gender'] ?? 'Not specified'),
//             _buildInfoRow('Disability', _userData?['isDisabled'] ?? 'No'),
//             const Divider(height: 30),
//             _buildInfoRow('Assigned Bus', _userData?['busNumber'] ?? 'Not assigned'),
//             _buildInfoRow('Route', _userData?['route'] ?? 'Not assigned'),
//             _buildInfoRow('Status', _userData?['status'] ?? 'Pending'),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () => Navigator.pushNamed(context, '/qr-generator'),
//               child: const Text('Show My QR Code'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }






// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});
//
//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }
//
// class _ProfilePageState extends State<ProfilePage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   Map<String, dynamic>? _userData;
//   Map<String, dynamic>? _busData;
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }
//
//   Future<void> _loadUserData() async {
//     setState(() => _isLoading = true);
//     try {
//       User? user = _auth.currentUser;
//       if (user != null) {
//         // Get basic user info from signup
//         DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
//         if (userDoc.exists) {
//           setState(() => _userData = userDoc.data() as Map<String, dynamic>);
//         }
//
//         // Get bus assignment info from apply page
//         QuerySnapshot busQuery = await _firestore.collection('bus_applications')
//             .where('userId', isEqualTo: user.uid)
//             .orderBy('appliedAt', descending: true)
//             .limit(1)
//             .get();
//
//         if (busQuery.docs.isNotEmpty) {
//           setState(() => _busData = busQuery.docs.first.data() as Map<String, dynamic>);
//         }
//       }
//     } catch (e) {
//       print('Error loading profile data: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Student Profile"),
//         centerTitle: true,
//         backgroundColor: Colors.teal,
//       ),
//       backgroundColor: const Color(0xFFF2F2F2),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//             elevation: 4,
//             child: Padding(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Stack(
//                     children: [
//                       const CircleAvatar(
//                         radius: 50,
//                         backgroundColor: Colors.teal,
//                         backgroundImage: AssetImage('assets/profile.png'),
//                       ),
//                       Positioned(
//                         bottom: 0,
//                         right: 0,
//                         child: CircleAvatar(
//                           radius: 16,
//                           backgroundColor: Colors.white,
//                           child: Icon(Icons.camera_alt, size: 18, color: Colors.teal),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     _userData?['name'] ?? 'No Name',
//                     style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     _userData?['email'] ?? 'No Email',
//                     style: const TextStyle(fontSize: 16, color: Colors.grey),
//                   ),
//                   const Divider(height: 30, thickness: 1.5),
//                   _buildInfoRow("Roll Number", _userData?['rollNo'] ?? 'Not available'),
//                   const SizedBox(height: 10),
//                   _buildInfoRow("Department", _userData?['department'] ?? 'Not available'),
//                   const SizedBox(height: 10),
//                   _buildInfoRow("Gender", _userData?['gender'] ?? 'Not specified'),
//                   const SizedBox(height: 10),
//                   _buildInfoRow("Disability Status", _userData?['isDisabled'] ?? 'Not specified'),
//                   const Divider(height: 30, thickness: 1.5),
//                   _buildInfoRow("Assigned Bus", _busData?['busNumber'] ?? 'Not assigned'),
//                   const SizedBox(height: 10),
//                   _buildInfoRow("Route", _busData?['route'] ?? 'Not assigned'),
//                   const SizedBox(height: 10),
//                   _buildInfoRow("Bus Stop", _busData?['stop'] ?? 'Not assigned'),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
//         Text(value),
//       ],
//     );
//   }
// }







// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});
//
//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }
//
// class _ProfilePageState extends State<ProfilePage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   Map<String, dynamic>? _userData;
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
//       _isLoading = false;
//     });
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           Text(
//             value,
//             style: const TextStyle(color: Colors.teal),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Student Profile'),
//         backgroundColor: Colors.teal,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             const CircleAvatar(
//               radius: 50,
//               backgroundColor: Colors.teal,
//               child: Icon(Icons.person, size: 50, color: Colors.white),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               _userData?['name'] ?? 'N/A',
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               _userData?['email'] ?? 'N/A',
//               style: const TextStyle(color: Colors.grey),
//             ),
//             const Divider(height: 30),
//             _buildInfoRow('Roll Number', _userData?['rollNo'] ?? 'N/A'),
//             _buildInfoRow('Department', _userData?['department'] ?? 'N/A'),
//             _buildInfoRow('Gender', _userData?['gender'] ?? 'Not specified'),
//             _buildInfoRow('Disability', _userData?['isDisabled'] ?? 'No'),
//             const Divider(height: 30),
//             _buildInfoRow('Assigned Bus', _userData?['busNumber'] ?? 'Not assigned'),
//             _buildInfoRow('Route', _userData?['route'] ?? 'Not assigned'),
//             _buildInfoRow('Status', _userData?['status'] ?? 'Pending'),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () => Navigator.pushNamed(context, '/qr-generator'),
//               child: const Text('Show My QR Code'),
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
//
// // import 'package:flutter/material.dart';
// //
// //
// // class ProfilePage extends StatelessWidget {
// //   const ProfilePage({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     // Sample student info
// //     const String name = "John Doe";
// //     const String email = "john.doe@example.com";
// //     const String rollNumber = "123456";
// //     const String department = "Computer Science";
// //
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("Student Profile"),
// //         centerTitle: true,
// //         backgroundColor: Colors.teal,
// //       ),
// //       backgroundColor: const Color(0xFFF2F2F2),
// //       body: Center(
// //         child: Padding(
// //           padding: const EdgeInsets.all(20),
// //           child: Card(
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(15),
// //             ),
// //             elevation: 4,
// //             child: Padding(
// //               padding: const EdgeInsets.all(24),
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   Stack(
// //                     children: [
// //                       const CircleAvatar(
// //                         radius: 50,
// //                         backgroundColor: Colors.teal,
// //                         backgroundImage: AssetImage('assets/profile.png'), // Add image to assets
// //                       ),
// //                       Positioned(
// //                         bottom: 0,
// //                         right: 0,
// //                         child: CircleAvatar(
// //                           radius: 16,
// //                           backgroundColor: Colors.white,
// //                           child: Icon(Icons.camera_alt, size: 18, color: Colors.teal),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 20),
// //                   Text(
// //                     name,
// //                     style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
// //                   ),
// //                   const SizedBox(height: 8),
// //                   Text(
// //                     email,
// //                     style: const TextStyle(fontSize: 16, color: Colors.grey),
// //                   ),
// //                   const Divider(height: 30, thickness: 1.5),
// //                   _buildInfoRow("Roll Number", rollNumber),
// //                   const SizedBox(height: 10),
// //                   _buildInfoRow("Department", department),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildInfoRow(String label, String value) {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [
// //         Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
// //         Text(value),
// //       ],
// //     );
// //   }
// // }
