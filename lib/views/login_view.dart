import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/auth/auth_exceptions.dart';
import '../services/auth/bloc/auth_bloc.dart';
import '../services/auth/bloc/auth_event.dart';
import '../services/auth/bloc/auth_state.dart';
import '../utilities/dialog/error_dialog.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async{
        if (state is AuthStateLoggedOut) {
                    if (state.exception is UserNotFoundAuthException) {
                      await showErrorDialog(context, 'User not found');
                 } else if (state.exception is WrongPasswordAuthException) {
                  await showErrorDialog(context, 'Wrong credentials');
                } else if (state.exception is GenericAuthException) {
                  await showErrorDialog(context, 'Authentication error');
                }
              }
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Login'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                //Image.asset('images/avatar.png'),
                TextField(
                  controller: _email,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
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
                  Icons.lock,
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
                          AuthEventLogIn(
                            email,
                            password,
                          ),
                        );
                  },
                  child: const Text('Login'),
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
              onPressed: () {
                context.read<AuthBloc>().add(
                  const AuthEventForgotPassword(),
                );
              },
              child: const Text('Forgot Password',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.deepPurple,
                fontStyle: FontStyle.italic
              ),
              ),
            ),    
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(
                  const AuthEventShouldRegister(),
                );
              },
              child: const Text('Not registered yet? Register here!',
              style: TextStyle(
                fontSize: 20.0,
                fontStyle: FontStyle.italic,
              ),),
            )
        ],
      ),
          ),
      ),
    );
  }
}