import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
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
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                  children: [
                    TextField(
                      enableSuggestions: false,
                      autocorrect: false,
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      
                      controller: _email,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                    Icons.person,
                    color: Colors.pink,
                  ),
                  border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                        hintText: 'Enter Email ID',
                        hintStyle: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                      ),
                    ),
                    const SizedBox(height: 30,),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                    Icons.person,
                    color: Colors.pink,
                  ),
                  border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                        hintText: 'Enter Password',
                        hintStyle: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                      ),
                    ),
                      const SizedBox(height: 30,),
                      ElevatedButton(
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
                    style: ElevatedButton.styleFrom(
                    primary: Colors.pink,
                    padding: const EdgeInsets.symmetric(horizontal: 100,vertical: 20),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    )
                  ),
                  ),
                  TextButton(
                    onPressed: () => {
                      context.read<AuthBloc>().add(
                        const AuthEventLogOut(),
                      ),
                    },
                     child: const Text('Already Registred ? Login here !',
                     style: TextStyle(
                fontSize: 20.0,
                color: Colors.deepPurple,
                fontStyle: FontStyle.italic
              ),),
                     
                     ),
              ],
            ),
          ),
      ),
    );
  }
}


