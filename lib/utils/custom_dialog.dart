import 'package:app_admin/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

void openCustomDialog(context, title, message) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return PointerInterceptor(
          child: SimpleDialog(
            contentPadding: const EdgeInsets.all(50),
            elevation: 0,
            children: <Widget>[
              Text(title,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w700)),
              const SizedBox(
                height: 10,
              ),
              Text(message,
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w400)),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: TextButton(
                  style: buttonStyle(Colors.deepPurpleAccent),
                  child: const Text(
                    'Okay',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              )
            ],
          ),
        );
      });
}

// void openCustomDialogWithOptions(context, String title, String message, VoidCallback onPressed) {
//   showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return SimpleDialog(
//           contentPadding: EdgeInsets.all(50),
//           elevation: 0,
//           children: <Widget>[
//             Text(title,
//                 style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w900)),
//             SizedBox(
//               height: 10,
//             ),
//             Text(message,
//                 style: TextStyle(
//                     color: Colors.grey[900],
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700)),
//             SizedBox(
//               height: 30,
//             ),
//             Center(
//                 child: Row(
//               children: <Widget>[
//                 TextButton(
//                     style: buttonStyle(Colors.redAccent),
//                     child: Text(
//                       'Yes',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600),
//                     ),
//                     onPressed: ()async{
//                       await onPressed;
//                       Navigator.pop(context);
//                     }),
//                 SizedBox(width: 10),
//                 TextButton(
//                   style: buttonStyle(Colors.deepPurpleAccent),
//                   child: Text(
//                     'No',
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600),
//                   ),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ],
//             ))
//           ],
//         );
//       });
// }
