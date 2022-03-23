import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_service.dart';

import '../constants/routes.dart';
import '../enums/menu_action.dart';

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
                  await AuthService.firebase().logOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
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
