import 'package:cloud_firestore/cloud_firestore.dart';

import 'cloude_note.dart';
import 'cloude_storage_constants.dart';
import 'cloude_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
       final allNotes = notes
      .where(ownerUserIdFieldName, isEqualTo : ownerUserId)
      .snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc)));
          return allNotes;
  }
     

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map(
              (doc) => CloudNote.fromSnapshot(doc),
            ),
          );
    } catch (e) {
      throw CouldNotGetAllNotesException();
          }
        }
      
        Future<CloudNote> createNote({required String ownerUserId}) async {
          final document=await notes.add({
            ownerUserIdFieldName: ownerUserId,
            textFieldName: '',
          });
          final fetchNote = await document.get();
          return CloudNote(
            documentId: fetchNote.id, 
            ownerUserId: ownerUserId, 
            text: '',
            );
        }
      
        static final FirebaseCloudStorage _shared =
            FirebaseCloudStorage._sharedInstance();
        FirebaseCloudStorage._sharedInstance();
        factory FirebaseCloudStorage() => _shared;
      }
      
      class CouldNotGetAllNotesException {
}