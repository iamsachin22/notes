import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_providers.dart';
import 'package:notes/services/auth/auth_user.dart';
import 'package:test/test.dart';
void main() {
  group('Mock Authorization', () {
    final provider = MockAuthProvider();
    test('Not to be intialized',() {
      // to check intilized it must be false otherwise all test gets fail
      expect(provider.isIntialized, false);
    });

    test('Must be log in to Logout',() {
      expect(
        provider.logOut(), 
        throwsA(const TypeMatcher<NotIntializedExceptions>()),
      );
    });

    test('Must be intialized', () async {
    await provider.initialize();
    expect(provider.isIntialized, true);
  });

  test('user should be null after intialized', () {
      expect(provider.currentUser,null);
  });

  test('to be intialized in 2 seconds', () async{
    await provider.initialize();
    expect(provider.isIntialized, true); 
  },
  timeout: const Timeout(Duration (seconds : 2)),

  );

  test('Create user delegate to login', () async{
    final wrongEmailUser = provider.createUser(
      email: 'abcd@test.com', 
      password: '1234',
      );
      expect(wrongEmailUser, throwsA(const TypeMatcher<UserNotFoundAuthException>(),),);

      final wrongPasswordUser = provider.createUser(
        email: 'user@test.com', 
        password: '1234',
        );

      expect(wrongPasswordUser, throwsA(const TypeMatcher<WrongPasswordAuthException>(),),);

      final user = await provider.createUser(
        email: 'test', 
        password: '1111',
        );
        expect(provider.currentUser, user);
        expect(user.isEmailVerified, false);
  });
        test('Verify Logged in User',() {
          provider.sendEmailVerification();
          final user = provider.currentUser;
          expect(user, isNotNull);
          expect(user!.isEmailVerified, true);
        });

        test('user musst login and logout',() async {
          await provider.logOut();
          await provider.logIn(email: 'email', password: 'password');
        });

        final user = provider.currentUser;
        expect(user, isNotNull);
  });

  
}
class NotIntializedExceptions implements Exception {}


class MockAuthProvider implements AuthProvider {
  AuthUser?_user;
  var _isIntialized = false;
  bool get isIntialized => _isIntialized;
  @override
  Future<AuthUser> createUser({
  required String email, 
  required String password,
  }) async{
          if(!isIntialized) throw NotIntializedExceptions();

          await Future.delayed(const Duration(seconds:1));
           return logIn(
             email: email, 
             password: password,
             );          
    }
  
    @override
    AuthUser? get currentUser => _user;
  
    @override
    Future<void> initialize() async{
      await Future.delayed(const Duration(seconds:1));
      _isIntialized = true;
    }
  
    @override
    Future<AuthUser> logIn({required String email, required String password}) {
   if(!isIntialized) throw NotIntializedExceptions();
   if(email == 'xyz@test.com') throw UserNotFoundAuthException();
   if(password == '1234') throw WrongPasswordAuthException();
   const user = AuthUser(id:"123",isEmailVerified: false, email: 'abc@test.com');
   _user=user;
   return Future.value(user);
  }

  @override
  Future<void> logOut() async{
       if(!isIntialized) throw NotIntializedExceptions();
       if (_user == null) throw UserNotFoundAuthException();
       await Future.delayed(const Duration(seconds:1));
       _user = null;
  }

  @override
  Future<void> sendEmailVerification() async{
           if(!isIntialized) throw NotIntializedExceptions();
           final user = _user;
           if(user == null) throw UserNotFoundAuthException();
           const newUser = AuthUser(id:"123",isEmailVerified: true, email: 'abc@test.com');
           _user = newUser;

  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) {
    throw UnimplementedError();
  }

}