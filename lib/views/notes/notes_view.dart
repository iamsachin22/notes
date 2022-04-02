import 'package:flutter/material.dart';
import 'package:notes/cloude/cloude_note.dart';
import 'package:notes/cloude/firebase_cloude_storage.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/views/notes/notes_list_view.dart';

import '../../constants/routes.dart';
import '../../enums/menu_action.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  _NotesViewState createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _noteService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _noteService = FirebaseCloudStorage();
    super.initState();
  }

  // @override
  // void dispose() {
  //   _noteService.close();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(onPressed: () {
            Navigator.pushNamed(context,createOrUpdateNoteRoute);
          }, 
          icon: const Icon(Icons.add),
          ),
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
      body: StreamBuilder(
                stream: _noteService.allNotes(ownerUserId: userId),
                builder: (context, snapshot){
                  switch(snapshot.connectionState){
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                    if(snapshot.hasData){
                      final allNotes = snapshot.data as Iterable<CloudNote>;
                      return NotesListView(
                        notes: allNotes, 
                        onDeleteNote:(note) async{
                          await _noteService.deleteNote(documentId: note.documentId);
                        },
                        onTap: (note) async{
                          Navigator.of(context).pushNamed(
                            createOrUpdateNoteRoute,
                            arguments: note,
                            );
                        },
                        );
                    }
                    else{
                      return const CircularProgressIndicator();

                    }
                    
                    default:
                    return const CircularProgressIndicator();
                  }
                },
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
