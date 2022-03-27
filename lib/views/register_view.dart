import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_service.dart';

import '../utilities/dialog/error_dialog.dart';


class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {

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
        title: const Text('Register'),
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

                    await AuthService.firebase().createUser(
                      email: email, 
                      password: password,
                      );  
                    AuthService.firebase().sendEmailVerification();
                    Navigator.of(context).pushNamed(verifyEmailRoute);
                    } on WeakPasswordAuthException{
                      await showErrorDialog(
                          context, 
                          'weak password',
                          );
                    } on EmailAlreadyInUseAuthException{
                      await showErrorDialog(
                          context, 
                          'Email is Already in Use',
                          );
                    } on InvalidEmailAuthException{
                      await showErrorDialog(
                          context, 
                          'Please enter the valid Email Address',
                          );
                    } on GenericAuthException{
                      await showErrorDialog(
                          context, 
                          'Failed to Register',
                          );
                    }
                  },
                  child: const Text('Register'),
                ),
                TextButton(
                  onPressed: () => {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                       (route) => false,
                       )
                  },
                   child: const Text('Already Registred ? Login here !'),
                   ),
            ],
          ),
    );
  }
}


