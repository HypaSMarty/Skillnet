import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String? _verificationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Authentication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '+123456789',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendOTP,
              child: Text('Send OTP'),
            ),
            TextField(
              controller: _otpController,
              decoration: InputDecoration(
                labelText: 'Enter OTP',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _verifyOTP,
              child: Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendOTP() async {
    final phone = _phoneController.text.trim();
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Automatically log in if verification is completed
        await FirebaseAuth.instance.signInWithCredential(credential);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Phone verified!')));
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Verification failed: ${e.message}')));
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('OTP sent!')));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Phone verified and logged in!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Invalid OTP: $e')));
    }
  }
}// Phone Authentication Screen 
