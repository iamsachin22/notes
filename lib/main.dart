import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes/firebase_options.dart';
import 'package:notes/views/login_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text("HomePage"),
        ),
        body: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
            
          ), builder: (BuildContext context, AsyncSnapshot<FirebaseApp> snapshot) {
            switch(snapshot.connectionState){
              case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser; 
              if(user?.emailVerified ?? false){
                print("Verified User");
              } 
              else{
                print("Invalid User");
              }
              return const Text('Done');
              default:
              return const Text('Loading..');
            }
            },
        ),
    );
  }
}
