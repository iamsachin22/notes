
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes/firebase_options.dart';
import 'package:notes/views/login_view.dart';
import 'package:notes/views/register_view.dart';
import 'package:notes/views/verify_email_view.dart';
import 'dart:developer' as devtools show log;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        '/login/': (context) => const LoginView(),
        '/register/':(context) => const RegisterView(),
        '/notes/':(context) => const NotesView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
            
          ), builder: (BuildContext context, AsyncSnapshot<FirebaseApp> snapshot) {
            switch(snapshot.connectionState){
              case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser; 
              if(user != null){
                if(user.emailVerified){
                  return const NotesView();
                }
                else{
                  return const VerifyEmailView();
                }
              }
              else{
                return const LoginView();
              }
              default:
              return const CircularProgressIndicator();
             // return const Text('Loading..');
            }
            },
        );
  }
}

enum MenuAction { logout } 

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  _NotesViewState createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async{
              switch(value){
                case MenuAction.logout:
                final shouldLogout = await showLogOutDialog(context);
                if(shouldLogout){
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login/',
                     (route) => false,
                     );
                }
                // devtools.log(shouldLogout.toString());
                // break;
              }
            },
            itemBuilder: (BuildContext context) { 
            return const [
              PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Text('Logout'),
            ),
            ];
           },
           )
        ]
        ,
      ),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context){
  return showDialog(
    context: context,
    builder: (context){
     return AlertDialog(
       title: const Text('Sign Out'),
       content: const Text('Are you sure want to sign out?'),
       actions: [
         TextButton(onPressed: () {
           Navigator.of(context).pop(false);
         }, child: const Text('Cancel')),
         TextButton(onPressed: () {
           Navigator.of(context).pop(true);
         }, child: const Text('Log Out')),
       ],
     );
  },
  ).then((value) => value ?? false);
}
