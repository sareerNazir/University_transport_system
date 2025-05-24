import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isEmailSent = false;
  String? _errorMessage;

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      setState(() => _isEmailSent = true);
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _getErrorMessage(e.code));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'invalid-email':
        return 'Please enter a valid email address';
      default:
        return 'An error occurred. Please try again';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isEmailSent)
                _buildSuccessMessage()
              else
                _buildEmailForm(),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        const Icon(Icons.check_circle, size: 80, color: Colors.teal),
        const SizedBox(height: 20),
        const Text(
          'Password Reset Email Sent',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'We\'ve sent instructions to ${_emailController.text}. Please check your email.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Return to Login'),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Column(
      children: [
        const Icon(Icons.lock_reset, size: 80, color: Colors.teal),
        const SizedBox(height: 20),
        const Text(
          'Forgot Your Password?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        const Text(
          'Enter your email address and we\'ll send you a link to reset your password.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 30),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your registered email',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _sendResetEmail,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Send Reset Link'),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Remember your password? Sign In',
            style: TextStyle(color: Colors.teal),
          ),
        ),
      ],
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class ForgotPasswordPage extends StatefulWidget {
//   const ForgotPasswordPage({super.key});
//
//   @override
//   State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
// }
//
// class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   bool _isLoading = false;
//   bool _isEmailSent = false;
//   String? _errorMessage;
//
//   Future<void> _sendResetEmail() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//
//     try {
//       await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
//       setState(() => _isEmailSent = true);
//     } on FirebaseAuthException catch (e) {
//       setState(() => _errorMessage = _getErrorMessage(e.code));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   String _getErrorMessage(String code) {
//     switch (code) {
//       case 'user-not-found':
//         return 'No user found with this email';
//       case 'invalid-email':
//         return 'Please enter a valid email address';
//       default:
//         return 'An error occurred. Please try again';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Forgot Password'),
//         backgroundColor: Colors.teal,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               if (_isEmailSent) ...[
//                 const Icon(Icons.check_circle, size: 80, color: Colors.teal),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Password Reset Email Sent',
//                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   'We\'ve sent instructions to ${_emailController.text}.',
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 30),
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Return to Login'),
//                 ),
//               ] else ...[
//                 const Icon(Icons.lock_reset, size: 80, color: Colors.teal),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Forgot Your Password?',
//                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   'Enter your email address to receive a reset link',
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 30),
//                 TextFormField(
//                   controller: _emailController,
//                   decoration: const InputDecoration(
//                     labelText: 'Email',
//                     prefixIcon: Icon(Icons.email),
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) return 'Enter your email';
//                     if (!value.contains('@')) return 'Enter a valid email';
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 if (_errorMessage != null)
//                   Text(
//                     _errorMessage!,
//                     style: const TextStyle(color: Colors.red),
//                   ),
//                 const SizedBox(height: 20),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _sendResetEmail,
//                     child: _isLoading
//                         ? const CircularProgressIndicator()
//                         : const Text('Send Reset Link'),
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Remember password? Sign in'),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     super.dispose();
//   }
// }
//
//
//
//
//
// // import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// //
// // class ForgotPasswordScreen extends StatefulWidget {
// //   const ForgotPasswordScreen({super.key});
// //
// //   @override
// //   _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
// // }
// //
// // class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   final _formKey = GlobalKey<FormState>();
// //   final _emailController = TextEditingController();
// //   bool _isLoading = false;
// //   bool _isEmailSent = false;
// //   String? _errorMessage;
// //
// //   Future<void> _sendResetEmail() async {
// //     if (!_formKey.currentState!.validate()) return;
// //
// //     setState(() {
// //       _isLoading = true;
// //       _errorMessage = null;
// //     });
// //
// //     try {
// //       await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
// //       setState(() => _isEmailSent = true);
// //     } on FirebaseAuthException catch (e) {
// //       setState(() => _errorMessage = _getErrorMessage(e.code));
// //     } finally {
// //       setState(() => _isLoading = false);
// //     }
// //   }
// //
// //   String _getErrorMessage(String code) {
// //     switch (code) {
// //       case 'user-not-found':
// //         return 'No user found with this email';
// //       case 'invalid-email':
// //         return 'Please enter a valid email address';
// //       default:
// //         return 'An error occurred. Please try again';
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     _emailController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Forgot Password'),
// //         backgroundColor: Colors.teal,
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Form(
// //           key: _formKey,
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             crossAxisAlignment: CrossAxisAlignment.stretch,
// //             children: [
// //               if (_isEmailSent)
// //                 _buildSuccessMessage()
// //               else
// //                 _buildEmailForm(),
// //               if (_errorMessage != null)
// //                 Padding(
// //                   padding: const EdgeInsets.only(top: 16.0),
// //                   child: Text(
// //                     _errorMessage!,
// //                     style: const TextStyle(color: Colors.red),
// //                     textAlign: TextAlign.center,
// //                   ),
// //                 ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildSuccessMessage() {
// //     return Column(
// //       children: [
// //         const Icon(Icons.check_circle, size: 80, color: Colors.teal),
// //         const SizedBox(height: 20),
// //         const Text(
// //           'Password Reset Email Sent',
// //           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
// //           textAlign: TextAlign.center,
// //         ),
// //         const SizedBox(height: 10),
// //         Text(
// //           'We\'ve sent instructions to ${_emailController.text}. Please check your email.',
// //           textAlign: TextAlign.center,
// //           style: const TextStyle(fontSize: 16),
// //         ),
// //         const SizedBox(height: 30),
// //         ElevatedButton(
// //           onPressed: () => Navigator.pop(context),
// //           style: ElevatedButton.styleFrom(
// //             backgroundColor: Colors.teal,
// //             padding: const EdgeInsets.symmetric(vertical: 16),
// //           ),
// //           child: const Text('Return to Login'),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildEmailForm() {
// //     return Column(
// //       children: [
// //         const Icon(Icons.lock_reset, size: 80, color: Colors.teal),
// //         const SizedBox(height: 20),
// //         const Text(
// //           'Forgot Your Password?',
// //           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
// //           textAlign: TextAlign.center,
// //         ),
// //         const SizedBox(height: 10),
// //         const Text(
// //           'Enter your email address and we\'ll send you a link to reset your password.',
// //           textAlign: TextAlign.center,
// //           style: TextStyle(fontSize: 16),
// //         ),
// //         const SizedBox(height: 30),
// //         TextFormField(
// //           controller: _emailController,
// //           keyboardType: TextInputType.emailAddress,
// //           decoration: const InputDecoration(
// //             labelText: 'Email',
// //             hintText: 'Enter your registered email',
// //             prefixIcon: Icon(Icons.email),
// //             border: OutlineInputBorder(),
// //             filled: true,
// //             fillColor: Colors.white,
// //           ),
// //           validator: (value) {
// //             if (value == null || value.isEmpty) {
// //               return 'Please enter your email';
// //             }
// //             if (!value.contains('@')) {
// //               return 'Please enter a valid email';
// //             }
// //             return null;
// //           },
// //         ),
// //         const SizedBox(height: 20),
// //         ElevatedButton(
// //           onPressed: _isLoading ? null : _sendResetEmail,
// //           style: ElevatedButton.styleFrom(
// //             backgroundColor: Colors.teal,
// //             padding: const EdgeInsets.symmetric(vertical: 16),
// //           ),
// //           child: _isLoading
// //               ? const CircularProgressIndicator(color: Colors.white)
// //               : const Text('Send Reset Link'),
// //         ),
// //         const SizedBox(height: 20),
// //         TextButton(
// //           onPressed: () => Navigator.pop(context),
// //           child: const Text(
// //             'Remember your password? Sign In',
// //             style: TextStyle(color: Colors.teal),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
//
//
//
//
//
//
// // import 'package:flutter/material.dart';
// //
// // class ForgotPasswordScreen extends StatefulWidget {
// //   final String? prefilledEmail;
// //
// //   const ForgotPasswordScreen({super.key, this.prefilledEmail});
// //
// //   @override
// //   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// // }
// //
// // class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
// //   final TextEditingController _emailController = TextEditingController();
// //   final TextEditingController _otpController = TextEditingController();
// //   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
// //
// //   bool _emailSubmitted = false;
// //   bool _otpSubmitted = false;
// //   bool _isLoading = false;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     if (widget.prefilledEmail != null) {
// //       _emailController.text = widget.prefilledEmail!;
// //       WidgetsBinding.instance.addPostFrameCallback((_) {
// //         _submitEmail();
// //       });
// //     }
// //   }
// //
// //   void _submitEmail() {
// //     if (!_formKey.currentState!.validate()) return;
// //
// //     final email = _emailController.text.trim();
// //     setState(() {
// //       _isLoading = true;
// //     });
// //
// //     // Simulate backend sending OTP
// //     Future.delayed(const Duration(seconds: 1), () {
// //       setState(() {
// //         _isLoading = false;
// //         _emailSubmitted = true;
// //       });
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text("OTP sent to $email")),
// //       );
// //     });
// //   }
// //
// //   void _submitOtp() {
// //     final otp = _otpController.text.trim();
// //
// //     if (otp.isEmpty || otp.length != 6) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text("Please enter a valid 6-digit OTP")),
// //       );
// //       return;
// //     }
// //
// //     // Simulate OTP verification
// //     setState(() {
// //       _otpSubmitted = true;
// //     });
// //
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text("OTP $otp verified successfully!")),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Center(
// //         child: Form(
// //           key: _formKey,
// //           child: Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 24.0),
// //             child: SingleChildScrollView(
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   const Text(
// //                     'Forgot Password',
// //                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// //                   ),
// //                   const SizedBox(height: 30),
// //
// //                   // Email field
// //                   TextFormField(
// //                     controller: _emailController,
// //                     keyboardType: TextInputType.emailAddress,
// //                     decoration: const InputDecoration(
// //                       labelText: 'Email',
// //                       hintText: 'Enter your email',
// //                       prefixIcon: Icon(Icons.email),
// //                       border: OutlineInputBorder(
// //                         borderRadius: BorderRadius.all(Radius.circular(10)),
// //                       ),
// //                     ),
// //                     validator: (value) {
// //                       if (value == null || value.isEmpty) {
// //                         return 'Please enter your email';
// //                       }
// //                       if (!value.contains('@') || !value.contains('.')) {
// //                         return 'Enter a valid email';
// //                       }
// //                       return null;
// //                     },
// //                   ),
// //                   const SizedBox(height: 20),
// //
// //                   // Email submit button
// //                   MaterialButton(
// //                     minWidth: double.infinity,
// //                     onPressed: _isLoading ? null : _submitEmail,
// //                     color: Colors.teal,
// //                     textColor: Colors.white,
// //                     padding: const EdgeInsets.symmetric(vertical: 14),
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: _isLoading
// //                         ? const CircularProgressIndicator(color: Colors.white)
// //                         : const Text('Submit Email', style: TextStyle(fontSize: 16)),
// //                   ),
// //
// //                   // OTP Field (after email submitted)
// //                   if (_emailSubmitted) ...[
// //                     const SizedBox(height: 30),
// //                     TextFormField(
// //                       controller: _otpController,
// //                       keyboardType: TextInputType.number,
// //                       decoration: const InputDecoration(
// //                         labelText: 'Enter OTP',
// //                         hintText: '6-digit code',
// //                         prefixIcon: Icon(Icons.lock),
// //                         border: OutlineInputBorder(
// //                           borderRadius: BorderRadius.all(Radius.circular(10)),
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 20),
// //                     MaterialButton(
// //                       minWidth: double.infinity,
// //                       onPressed: _submitOtp,
// //                       color: Colors.deepPurple,
// //                       textColor: Colors.white,
// //                       padding: const EdgeInsets.symmetric(vertical: 14),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                       child: const Text('Submit OTP', style: TextStyle(fontSize: 16)),
// //                     ),
// //                   ],
// //
// //                   if (_otpSubmitted) ...[
// //                     const SizedBox(height: 20),
// //                     const Text(
// //                       'OTP Verified ✅',
// //                       style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
// //                     ),
// //                   ],
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
