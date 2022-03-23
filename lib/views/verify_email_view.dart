import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_service.dart';

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
            onPressed: () async {
             await AuthService.firebase().sendEmailVerification();
            },
             child: const Text('Send Email Verification'),
             ),
             TextButton(onPressed: (() async {
              await AuthService.firebase().logOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute, 
                (route) => false,
                );
             }),
             child: const Text('Restart'),
             ),
        ],
      ),
    );
  }
}
