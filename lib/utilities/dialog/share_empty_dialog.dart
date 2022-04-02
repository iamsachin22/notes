import 'package:flutter/material.dart';
import 'package:notes/utilities/dialog/generic_dialog.dart';

Future<void> showShareEmptyDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Sharing',
    content: 'You cannot share an empty note!',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}