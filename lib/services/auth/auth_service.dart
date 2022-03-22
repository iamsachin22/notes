import 'auth_providers.dart';
import 'auth_user.dart';

class AuthService implements AuthProvider{
  
  final AuthProvider provider;

  AuthService(this.provider);

  @override
  Future<AuthUser> createUser({required String email, required String password,}) {
      // TODO: implement createUser
      throw UnimplementedError();
    }
  
    @override
    // TODO: implement currentUser
    AuthUser? get currentUser => throw UnimplementedError();
  
    @override
    Future<AuthUser> logIn({required String email, required String password}) {
    // TODO: implement logIn
    throw UnimplementedError();
  }

  @override
  Future<void> logOut() {
    // TODO: implement logOut
    throw UnimplementedError();
  }

  @override
  Future<void> sendEmailVerification() {
    // TODO: implement sendEmailVerification
    throw UnimplementedError();
  }
}