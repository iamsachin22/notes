import 'package:bloc/bloc.dart';

import '../auth_providers.dart';
import 'auth_event.dart';
import 'auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUnIntialized(isLoading: true)) {
    on<AuthEventShouldRegister>(((event, emit) {
      emit(const AuthStateRegistering(
        exception: null, 
        isLoading: false,));

    }));
    // forgot password
    on<AuthEventForgotPassword> (((event, emit) async {
      emit(const AuthStateForgotPassword(
        exception: null, 
        hasSentEmail: false, 
        isLoading: false));

        final email=event.email;
        if(email == null){
          return;
        }

        emit(const AuthStateForgotPassword(
          exception: null, 
          hasSentEmail: false, 
          isLoading: true));

          bool didSendEmail;
          Exception? exception;
          try{
              await provider.sendPasswordReset(toEmail: email);
              didSendEmail =  true;
              exception = null;
          }on Exception catch(e){
            didSendEmail = false;
            exception = e;

          }

        emit(AuthStateForgotPassword(
          exception: exception, 
          hasSentEmail: didSendEmail, 
          isLoading: false));

    }));
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
          emit(const AuthStateNeedsVerification(isLoading: false));
       } on Exception catch(e){
         emit(AuthStateRegistering(exception: e,isLoading: false));
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
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        emit(AuthStateLoggedIn(user:user,isLoadin: false));
      }
    });
    // log in
    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthStateLoggedOut(
        exception: null, 
        isLoading: true,
        loadinText: 'Please wait while LogIn'
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
          emit(const AuthStateNeedsVerification(isLoading: false));
      } else{
        emit(const AuthStateLoggedOut(
          exception: null, 
          isLoading: false
          ),
          );
        emit(AuthStateLoggedIn(user:user,isLoadin: false));
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