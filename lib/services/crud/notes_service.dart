import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:notes/extentions/list/filter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

import 'crud_exceptions.dart';

class NoteService {

  Database? _db;

  List<DatabaseNote> _notes = [];

  DatabaseUser? _user;

  static final NoteService _shared=NoteService._sharedInstance();

  NoteService._sharedInstance() {
    _notesStreamControler = StreamController<List<DatabaseNote>>.broadcast(
      onListen:() {
        _notesStreamControler.sink.add(_notes);
      }
    );
  }

  factory NoteService() => _shared;

  late final StreamController<List<DatabaseNote>> _notesStreamControler;
 
  Stream<List<DatabaseNote>> get allNotes => 
  _notesStreamControler.stream.filter((note) {
    final currentUser = _user;
    if(currentUser != null){
      return note.userId == currentUser.id;
    }
    else{
      throw UserShouldBeSetBeforeReadingNotes();
    }
  });
  
  Future<void> _ensureDbIsOpen() async{
      try{
          await open();
      } on DatabaseAlreadyOpenException{
         
      }
  }

  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true}) async{
    try{
          final user = await getuser(email: email);
          if(setAsCurrentUser){
            _user=user;
          }
          return user;
    } on CouldNotFindUser {
          final createdUser = await createUser(email: email);
          if(setAsCurrentUser){
            _user=createdUser; 
          }
          return createdUser;
    }
    catch(e) {
      rethrow;
    }

  }

  Future<void> _cacheNotes() async{
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamControler.add(_notes);
  }

  Future<DatabaseNote> updateNote ({required DatabaseNote note, required String text}) async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    //check note exist
    await getNote(id: note.id);

     //update DB
     final updateCount = await db.update(noteTable,{
      textColumn: text,
      isSyncedWithColumn:0,
      }, where: 'id = ? ',
      whereArgs: [note.id]);

      if(updateCount == 0) {
        throw ColudNotUpdateNotes();
      }
      else{
        final updatedNote =  await getNote(id: note.id);
        _notes.removeWhere((note) => note.id == updatedNote.id);
        _notes.add(updatedNote);
        _notesStreamControler.add(_notes);
        return updatedNote;
      }
      
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable
    );

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id}) async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if(notes.isEmpty){
      throw ColudNotFindNotes();
    }
    else{
      final note =DatabaseNote.fromRow(notes.first);
      _notes.removeWhere((note) => note.id==id);
      _notes.add(note);
      _notesStreamControler.add(_notes);
      return note;
    }
  }
  
  Future<int> deleteAllNotes() async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final countOfDeletion = await db.delete(noteTable);
    _notes=[];
    _notesStreamControler.add(_notes);
    return countOfDeletion;
  }

  Future<void> deleteNote({required int id}) async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs:[id],
      );
      if(deletedCount == 0) {
        throw ColudNotDeleteNote();
      }
      else{
        _notes.removeWhere((note) => note.id == id);
        _notesStreamControler.add(_notes);

      }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    // make sure user exists in db
    final dbuser = await getuser(email: owner.email);

    if(dbuser != owner){
      throw CouldNotFindUser();
    }

    const text = '';
    //create the note
    final noteID=await db.insert(noteTable, {
      userIdColumn:owner.id,
      textColumn:text,
      isSyncedWithColumn:1
    });

    final note = DatabaseNote(
      id: noteID, 
      userId: owner.id, 
      text: text, 
      isSyncedWithCloud: true,
      );

    _notes.add(note);
    _notesStreamControler.add(_notes);

    return note;
  }

  Future<DatabaseUser> getuser({required String email}) async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

      final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      );

      if(results.isEmpty){
        throw CouldNotFindUser();
      }
      else{
        return DatabaseUser.fromRow(results.first);
      }
  }

  Future<DatabaseUser> createUser({required String email}) async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      );
      if(results.isNotEmpty){
        throw UserAlreadyExists();
      }

      final userId = await db.insert(userTable, {
        emailColumn: email.toLowerCase(),
      });

      return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if(deleteCount != 1){
      throw ColudNotDeleteUser();
    }
  }

Database _getDatabaseOrThrow() {
  final db = _db;
  if(db == null){
    throw DatabaseIsNotOpen();
  }
  else{
    return db;
  }
}

 Future<void> close() async{
   final db = _db;
   if(db ==null){
     throw DatabaseIsNotOpen();
   }
   else{
     await db.close();
     _db = null;
   }

 }

  Future<void> open() async{

  Future<void> _ensureDBIsOpen() async{
      try{
          await open();

      } on DatabaseAlreadyOpenException{
        //
      }
  }


    if(_db !=null){
      throw DatabaseAlreadyOpenException();
    }

    try{
      final docsPath = await getApplicationDocumentsDirectory();
      final dbpath = join(docsPath.path, dbName);
      final db = await openDatabase(dbpath);
       _db = db;

       // create user table
         await db.execute(creatUserTable);

        //create note table
         await db.execute(creatNoteTable);
         
         //cache all notes
         await _cacheNotes();

    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory();
    }
  }
}


@immutable
class DatabaseUser{
  final int id;
  final String email;

  const DatabaseUser({
    required this.id, 
    required this.email,
    });

  DatabaseUser.fromRow(Map<String,Object?> map) 
  : id = map[idColumn] as int,
    email = map[emailColumn] as String;  

    @override
  String toString() => 'Person, ID = $id , email=$email';

   @override  
   bool operator ==( covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;

}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({required this.id,required this.userId,required this.text,required this.isSyncedWithCloud});

  DatabaseNote.fromRow(Map<String, Object?> map) 
  : id = map[idColumn] as int,
  userId = map[userIdColumn] as int,
  text = map[textColumn] as String,
  isSyncedWithCloud = (map[isSyncedWithColumn] as int) == 1 ? true : false;

  @override
  String toString() => 'Note, ID = $id, userId = $userId, isSyncedWithCloude =$isSyncedWithCloud, text = $text';

  @override  
   bool operator ==( covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
  
}

const dbName = 'notes.db';
const userTable = 'user';
const noteTable = 'note';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithColumn = 'is_synced_with_cloud';

const creatUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
            "id" INTEGER NOT NULL,
            "email" TEXT NOT NULL UNIQUE,
            PRIMARY KEY("id" AUTOINCREMENT)
         );''';

const creatNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY("user_id") REFERENCES "user"("id"),
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';

