// import 'package:flutter/material.dart';

// enum DialogsAction { yes, cancel }

// class AlertDialogs {
//   static Future<DialogsAction> yesCancelDialog(
//     BuildContext context,
//     String title,
//     String body,
//   ) async {
//     final action = await showDialog(
//       context: context,
//       // barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(title),
//           content: Text(body),
//           actions: <Widget>[FlatButton()],
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';

enum DialogsAction { yes, cancel }

class AlertDialogs {
  static Future<DialogsAction> yesCancelDialog(
    BuildContext context,
    String title,
    String body,
  ) async {
    final action = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(DialogsAction.cancel),
              child: const Text(
                'Cancel',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(DialogsAction.yes),
              child: const Text(
                'Confirm',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
    return (action != null) ? action : DialogsAction.cancel;
  }
}
