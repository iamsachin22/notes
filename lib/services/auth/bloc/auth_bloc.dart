import 'package:bloc/bloc.dart';

import '../auth_providers.dart';
import 'auth_event.dart';
import 'auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUnIntialized()) {
    //send email verification
    on<AuthEventSendEmailVerification>((event,emit) async{
      await provider.sendEmailVerification();
      emit(state);
    });

    on<AuthEventRegister>((event,emit) async{
       final email = event.email;
       final password= event.password;
       try{
          await provider.createUser(
           email: email, 
           password: password,
           );
          await provider.sendEmailVerification();
          emit(const AuthStateNeedsVerification());
       } on Exception catch(e){
         emit(AuthStateRegistering(e));
       }

    });
    // initialize
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(
          exception: null, 
          isLoading: false),
        );
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });
    // log in
    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthStateLoggedOut(
        exception: null, 
        isLoading: true,
        ),
        );
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(
          email: email,
          password: password,
        );

      if(!user.isEmailVerified){
        emit(const AuthStateLoggedOut(
          exception: null, 
          isLoading: false
          ),
          );
          emit(const AuthStateNeedsVerification());
      } else{
        emit(const AuthStateLoggedOut(
          exception: null, 
          isLoading: false
          ),
          );
        emit(AuthStateLoggedIn(user));
      }

      } on Exception catch (e) {
        emit(AuthStateLoggedOut(
          exception: e, 
          isLoading: false,
          ),
          );
      }
    });

    // log out
    on<AuthEventLogOut>((event, emit) async {
      try{
        provider.logOut();
        emit(const AuthStateLoggedOut(
          exception: null, 
          isLoading: false),
          );

      } on Exception catch (e){
          emit(AuthStateLoggedOut(
            exception: e, 
            isLoading: false),
            );
      } 
    });
  }
}