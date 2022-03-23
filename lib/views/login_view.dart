import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_service.dart';

import '../utilities/show_error_dialog.dart';


class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
            children: [
              TextField(
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                controller: _email,
                decoration: const InputDecoration(
                  hintText: 'Enter your Email',
                ),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText: 'Enter your Password',
                ),
              ),
              TextButton(
                  onPressed: () async {
                    final email = _email.text;
                    final password = _password.text;
                    try{
                    await AuthService.firebase().logIn(
                      email: email, 
                      password: password,
                      );

                    final user = AuthService.firebase().currentUser;
                    if(user?.isEmailVerified ?? false){
                      //user email is verified
                      Navigator.of(context).pushNamedAndRemoveUntil(
                      notesRoute,
                      (route) => false,
                      );
                    }
                    else{
                      //user email not verified
                      Navigator.of(context).pushNamedAndRemoveUntil(
                      verifyEmailRoute,
                      (route) => false,
                      );
                    }  
                  
                    } on UserNotFoundAuthException{
                      await showErrorDialog(context, 
                        'User not Found',
                        );
                    } on WrongPasswordAuthException{
                      await showErrorDialog(context, 
                        'Wrong Password',
                        );
                    } on GenericAuthException{
                      await showErrorDialog(context, 
                        'Authentication Error',
                        );
                    }
                  },
                  child: const Text('Login'),
                ),
                TextButton(
                  onPressed: () => {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      registerRoute,
                       (route) => false,
                       )
                  },
                   child: const Text('Not Registred yet  ? Register here !'),
                   ),
            ],
          ),
    );
  }
}

