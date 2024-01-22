import 'package:cloud_firestore/cloud_firestore.dart';

class LiveQuiz {
  String? name;
  String? id;
  String? thumbnailUrl;
  bool? timer;
  int? quizTime;
  int? questionCount;
  String? description;
  int? pointsRequired;
  String? questionOrder;
  // ignore: prefer_typing_uninitialized_variables
  var createdAt;
  // ignore: prefer_typing_uninitialized_variables
  var updatedAt;
  // ignore: prefer_typing_uninitialized_variables
  var startAt;
  // ignore: prefer_typing_uninitialized_variables
  var endAt;
  String? status;

  LiveQuiz({
    required this.name,
    required this.id,
    required this.thumbnailUrl,
    required this.timer,
    this.quizTime,
    this.questionCount,
    required this.description,
    required this.pointsRequired,
    this.questionOrder,
    this.createdAt,
    this.updatedAt,
    this.startAt,
    this.endAt,
    this.status
  });

  factory LiveQuiz.fromFirestore(DocumentSnapshot snap) {
    Map d = snap.data() as Map<dynamic, dynamic>;
    return LiveQuiz(
        name: d['name'],
        id: d['id'],
        thumbnailUrl: d['image_url'],
        timer: d['timer'],
        quizTime: d['quiz_time'],
        questionCount: d['question_count'],
        description: d['description'],
        pointsRequired: d['points_required'],
        questionOrder: d['question_order'],
        createdAt: d['created_at'],
        updatedAt: d['updated_at'],
        startAt: d['start_at'],
        endAt: d['end_at'],
        status: d['status']
    );
  }

  static Map<String, dynamic> getMap(LiveQuiz d) {
    return {
      'name': d.name,
      'id': d.id,
      'image_url': d.thumbnailUrl,
      'timer': d.timer,
      'quiz_time': d.quizTime,
      'question_count': d.questionCount,
      'description': d.description,
      'points_required': d.pointsRequired,
      'question_order': d.questionOrder,
      'created_at': d.createdAt,
      'updated_at': d.updatedAt,
      'start_at': d.startAt,
      'end_at': d.endAt 
    };
  }
}
