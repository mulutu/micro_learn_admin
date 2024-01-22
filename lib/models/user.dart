import 'package:app_admin/configs/config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? uid;
  String? name;
  String? email;
  String? avatarString;
  Timestamp? createdAt;
  Timestamp? updatedAt;
  int? points;
  bool? disabled;
  List? savedItems;
  int? totalQuizPlayed;
  int? totalQuestionAnswered;
  int? totalCorrectAns;
  int? totalIncorrectAns;
  double? strength;
  List? userRole;
  String? imageurl;
  List? pointsHistory;

  UserModel(
      {this.uid,
      this.name,
      this.email,
      this.avatarString,
      this.createdAt,
      this.updatedAt,
      this.disabled,
      this.points,
      this.savedItems,
      this.totalQuizPlayed,
      this.totalCorrectAns,
      this.totalIncorrectAns,
      this.totalQuestionAnswered,
      this.strength,
      this.userRole,
      this.imageurl,
      this.pointsHistory
      });

  factory UserModel.fromFirestore(DocumentSnapshot snap) {
    Map d = snap.data() as Map<dynamic, dynamic>;
    return UserModel(
      uid: d['id'],
      name: d['name'],
      email: d['email'],
      avatarString: d['avatar_string'] ?? Config.defaultAvatarString,
      createdAt: d['created_at'],
      updatedAt: d['updated_at'],
      points: d['points'] ?? 0,
      disabled: d['disabled'] ?? false,
      savedItems: d['saved_items'],
      totalQuizPlayed: d['total_quiz_played'] ?? 0,
      totalCorrectAns: d['correct_ans_count'] ?? 0,
      totalIncorrectAns: d['incorrect_ans_count'] ?? 0,
      totalQuestionAnswered: d['question_ans_count'] ?? 0,
      strength: _getStrength(
        d['question_ans_count'],
        d['correct_ans_count'],
      ),
      userRole: d['role'] ?? [],
      imageurl: d['image_url'],
      pointsHistory: d['points_history']
    );
  }
}

double _getStrength(int? questionCount, int? correctAnsCount) {
  int q = questionCount ?? 0;
  int c = correctAnsCount ?? 0;
  double s = c / q * 100;
  if (s.isNaN) {
    return 0.0;
  } else {
    return s;
  }
}
