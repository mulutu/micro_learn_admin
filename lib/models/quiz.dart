import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz {
  String? name;
  String? id;
  String? thumbnailUrl;
  String? parentId;
  bool? timer;
  int? quizTime;
  int? questionCount;
  String? description;
  bool? featured;
  int? pointsRequired;
  String? questionOrder;
  int? index;

  Quiz({
    required this.name,
    required this.id,
    required this.thumbnailUrl,
    required this.parentId,
    required this.timer,
    this.quizTime,
    this.questionCount,
    required this.description,
    this.featured,
    required this.pointsRequired,
    this.questionOrder,
    this.index
  });

  factory Quiz.fromFirestore(DocumentSnapshot snap) {
    Map d = snap.data() as Map<dynamic, dynamic>;
    return Quiz(
        name: d['name'],
        id: d['id'],
        thumbnailUrl: d['image_url'],
        parentId: d['parent_id'],
        timer: d['timer'],
        quizTime: d['quiz_time'],
        questionCount: d['question_count'],
        description: d['description'],
        featured: d['featured'],
        pointsRequired: d['points_required'],
        questionOrder: d['question_order'],
        index: d['index']
    );
  }

  static Map<String, dynamic> getMap(Quiz d) {
    return {
      'name': d.name,
      'id': d.id,
      'image_url': d.thumbnailUrl,
      'parent_id': d.parentId,
      'timer': d.timer,
      'quiz_time': d.quizTime,
      'question_count': d.questionCount,
      'description': d.description,
      'featured': d.featured,
      'points_required': d.pointsRequired,
      'question_order': d.questionOrder,
      'index': d.index
    };
  }
}
