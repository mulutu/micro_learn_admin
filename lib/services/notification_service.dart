import 'dart:convert';
import 'package:app_admin/configs/config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class NotificationService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future sendCustomNotificationByTopic (String title, String description, String targetUsersTopic) async{
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${Config.firebaseServerToken}',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': "Click to read more details",
            'title': title,
            'sound':'default'
          },
          'priority': 'normal',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'notification_type': 'custom',
            'description': description
          },
          'to': "/topics/$targetUsersTopic",
        },
      ),
    );
  }

  // Future sendPostNotification (String title, String postId, String imageUrl, String contentType) async{
  //   await http.post(
  //     Uri.parse('https://fcm.googleapis.com/fcm/send'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json',
  //       'Authorization': 'key=${AppConfig.firebaseServerToken}',
  //     },
  //     body: jsonEncode(
  //       <String, dynamic>{
  //         'notification': <String, dynamic>{
  //           'body': 'Click here to read more details',
  //           'title': title,
  //           'sound':'default'
  //         },
  //         'priority': 'normal',
  //         'data': <String, dynamic>{
  //           'click_action': 'FLUTTER_NOTIFICATION_CLICK',
  //           'id': '1',
  //           'status': 'done',
  //           'post_id': postId,
  //           'image_url': imageUrl,
  //           'notification_type': 'post',
  //           'content_type': contentType
  //         },
  //         'to': "/topics/${Constants.fcmSubscriptionTopic}",
  //       },
  //     ),
  //   );
  // }
}