import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if(state is AuthStateRegistering){
          if(state.exception is WeakPasswordAuthException){
            showErrorDialog(context, 'Weak Password');
          } else if(state.exception is EmailAlreadyInUseAuthException){
            showErrorDialog(context, 'Email is Already in Use');
          } else if(state.exception is GenericAuthException){
            showErrorDialog(context, 'Fail to Register');
          } else if(state.exception is InvalidEmailAuthException){
            showErrorDialog(context, 'Invalid Email');
          }
        }
      },
      child: Scaffold(
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
                        context.read<AuthBloc>().add(
                          AuthEventRegister(
                            email,
                            password,

                        ));
                  },
                  child: const Text('Register'),
                ),
                TextButton(
                  onPressed: () => {
                    context.read<AuthBloc>().add(
                      const AuthEventLogOut(),
                    ),
                  },
                   child: const Text('Already Registred ? Login here !'),
                   ),
            ],
          ),
      ),
    );
  }
}


