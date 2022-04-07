
import 'package:flutter/material.dart';
import 'package:notes/utilities/dialog/generic_dialog.dart';

Future<void> showPasswordResetDialog(BuildContext context){
 return showGenericDialog(context: context, 
 title: 'Password Reste', 
 content: 'We have now sent a password reset link. Please check you email', 
 optionsBuilder: () =>{
   'OK':null,
 },
 );
}