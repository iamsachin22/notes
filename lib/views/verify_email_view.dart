import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  _VerifyEmailViewState createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verfiy Email'),
      ),
      body: Column(
        children: [
          const Text('Sent verification email. Please verify Email to proceed Further'),
          const Text('If you have not recived a verification Email, press below button to verify'),
          TextButton(
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              user?.sendEmailVerification();
            },
             child: const Text('Send Email Verification'),
             ),
             TextButton(onPressed: (() async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute, 
                (route) => false,
                );
             }),
             child: Text('Restart'),
             ),
        ],
      ),
    );
  }
}
