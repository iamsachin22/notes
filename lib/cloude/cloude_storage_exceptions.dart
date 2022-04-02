class CloudeStorageException implements Exception{
  const CloudeStorageException();
}

class CouldNotCreateNoteException extends CloudeStorageException{}  

class CouldNotgetAllNoteException extends CloudeStorageException{}  

class CouldNotUpdateNoteException extends CloudeStorageException{}   

class CouldNotDeleteNoteException extends CloudeStorageException{}   