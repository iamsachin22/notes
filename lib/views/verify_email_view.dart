import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';

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
            onPressed: (){
              context.read<AuthBloc>().add(
                const AuthEventSendEmailVerification(),
              );
            },
             child: const Text('Send Email Verification'),
             ),
             TextButton(onPressed: (() {
              context.read<AuthBloc>().add(
                const AuthEventLogOut(),
              );
             }),
             child: const Text('Restart'),
             ),
        ],
      ),
    );
  }
}
