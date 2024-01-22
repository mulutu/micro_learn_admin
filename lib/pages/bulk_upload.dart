// // ignore_for_file: avoid_function_literals_in_foreach_calls

// import 'dart:convert';

// import 'package:app_admin/configs/constants.dart';
// import 'package:app_admin/services/firebase_service.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class BulkUpload extends StatefulWidget {
//   const BulkUpload({Key? key}) : super(key: key);

//   @override
//   State<BulkUpload> createState() => _BulkUploadState();
// }

// class _BulkUploadState extends State<BulkUpload> {
//   _onPressed() {
//     //uploadJsonData();
//     updateExplainationToAllQuestions();
//   }

//   final FirebaseFirestore firestore = FirebaseFirestore.instance;

//   Future uploadJsonData() async {
//     String catId = "W9ZuxmEIm6MGLYlOuR1b";
//     String quizId = "I3uOHNGesNdl74yf3aon";
//     final String response = await rootBundle.loadString('assets/questions.json');
//     final data = await json.decode(response);
//     List questions = data['questions'];
//     debugPrint(questions.length.toString());
//     questions.forEach((element) async {
//       await Future.delayed(const Duration(seconds: 1)).then((value) async {
//         String docId = firestore.collection('questions').doc().id;
//         await firestore.collection('questions').doc(docId).set({
//           'id': docId,
//           'cat_id': catId,
//           'quiz_id': quizId,
//           'created_at': DateTime.now(),
//           'updated_at': null,
//           'question_title': element['question'],
//           'options': element['options'],
//           'correct_ans_index': element['correct_answer_index'],
//           'options_type': Constants.optionTypes.keys.elementAt(0),
//           'question_type': Constants.questionTypes.keys.elementAt(0),
//         });
//       });
//     });
//     await FirebaseService().increaseCount('questions_count', questions.length);
//     await FirebaseService().increaseQuestionCountInQuiz(quizId, questions.length);
//     debugPrint('Complete');
//   }


//   Future updateExplainationToAllQuestions () async{
//     String explanation = '''<pre class="ql-syntax" spellcheck="false"><p style="font-family: sans-serif; white-space: normal;">This is a demo explanation to show how the question explanation will work. You can enable or disbale it for each questions.</p><p style="font-family: sans-serif; white-space: normal;">Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took.<br></p><img src="https://www.mrb-lab.com/wp-content/uploads/2023/01/inline_preview-1.png" data-filename="" style="font-family: sans-serif; white-space: normal;"><br style="font-family: sans-serif; white-space: normal;"><p style="font-family: sans-serif; white-space: normal;">The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from "de Finibus Bonorum et Malorum" by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.</p><h2 style="font-family: sans-serif; white-space: normal;">Where does it come from?</h2><p style="font-family: sans-serif; white-space: normal;">Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia.</p><h2 style="font-family: sans-serif; white-space: normal;">Why do we use it?</h2><p style="font-family: sans-serif; white-space: normal;">It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).</p><p style="font-family: sans-serif; white-space: normal;">To check the links, Click on the link here:&nbsp;<a href="https://www.mrb-lab.com/">MRB Lab</a></p><h3 style="font-family: sans-serif; white-space: normal;">Where can I get some?</h3><p style="font-family: sans-serif; white-space: normal;">There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don't look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn't anything embarrassing hidden in the middle of text.&nbsp;</p></pre>''';
//     final FirebaseFirestore firestore = FirebaseFirestore.instance;
//     final WriteBatch batch = firestore.batch();
//     final ref = firestore.collection('questions');
//     await ref.get().then((QuerySnapshot snapshot){
//       snapshot.docs.forEach((element) {
//         batch.update(element.reference, {
//           'explaination' : explanation
//         });
//       });
//       batch.commit();
//     });

//     debugPrint('update done');
//   }



//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: Center(
//         child: ElevatedButton(
//           child: const Text("Upload"),
//           onPressed: () => _onPressed(),
//         ),
//       ),
//     );
//   }
// }