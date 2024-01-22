// import 'package:app_admin/components/responsive.dart';
// import 'package:app_admin/components/set_quiz_order.dart';
// import 'package:app_admin/components/top_title.dart';
// import 'package:app_admin/configs/config.dart';
// import 'package:app_admin/services/app_service.dart';
// import 'package:app_admin/services/firebase_service.dart';
// import 'package:app_admin/utils/custom_dialog.dart';
// import 'package:app_admin/utils/next_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:line_icons/line_icons.dart';
// import 'package:provider/provider.dart';
// import '../blocs/admin_bloc.dart';
// import '../forms/quiz_form.dart';
// import '../models/category.dart';
// import '../models/live_quiz.dart';
// import '../utils/cached_image.dart';
// import '../utils/styles.dart';

// class LiveQuizzes extends StatefulWidget {
//   const LiveQuizzes({Key? key}) : super(key: key);

//   @override
//   State<LiveQuizzes> createState() => _LiveQuizzesState();
// }

// class _LiveQuizzesState extends State<LiveQuizzes> {
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//   final scaffoldKey = GlobalKey<ScaffoldState>();
//   final String collectionName = 'live_quizzes';
//   late Query<Map<String, dynamic>> _query;
//   String? _sortByText;

//   @override
//   void initState() {
//     _sortByText = 'All';
//     _query = firestore.collection(collectionName).orderBy('created_at', descending: true);
//     super.initState();
//   }

//   _onEditPressed(LiveQuiz quiz) {
//     if (Responsive.isMobile(context)) {
//       NextScreen().nextScreenPopup(context, LiveQuizForm(quiz: quiz));
//     } else {
//       showDialog(
//           context: context,
//           builder: (context) {
//             return Dialog(
//               child: LiveQuizForm(quiz: quiz)
//             );
//           });
//     }
//   }

//   //delete ----

//   _onDeletePressed(LiveQuiz d) {
//     String? userRole = context.read<AdminBloc>().userRole;
//     final bool hasAccess = userRole != null && userRole == 'admin' || userRole == 'editor';
//     if (hasAccess) {
//       _openDeteleDialog(context, d);
//     } else {
//       openCustomDialog(context, Config.testingDialog, '');
//     }
//   }

//   Future _onDelete(LiveQuiz d) async {
//     await FirebaseService().deleteContent(collectionName, d.id!);
//     await FirebaseService().decreaseCount('live_quizzes_count', null);
//     //await FirebaseService().decreaseQuizCountInCategory(d.parentId!);
//     await FirebaseService().deleteRelatedQuestionsAssociatedWithQuiz(d.id!);
//   }

//   _handleDelete(LiveQuiz d) async {
//     await _onDelete(d).then((value) => Navigator.pop(context));
//   }

//   //---delete ---end

//   _openAddQuizForm() {
//     if (Responsive.isMobile(context)) {
//       NextScreen().nextScreenPopup(
//           context,
//           const QuizForm(
//             quiz: null,
//           ));
//     } else {
//       showDialog(
//           context: context,
//           builder: (context) {
//             return const Dialog(
//               child: LiveQuizForm(
//                 quiz: null,
//               ),
//             );
//           });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.only(left: 10),
//                   child: TopTitle(
//                     title: 'Live Quizzes',
//                     dividerWidth: 100,
//                   ),
//                 ),
//                 const Spacer(),
//                 Padding(
//                   padding: const EdgeInsets.only(right: 10),
//                   child: TextButton.icon(
//                     icon: const Icon(
//                       Icons.add,
//                       color: Colors.white,
//                     ),
//                     label: Visibility(
//                       visible: !Responsive.isMobile(context),
//                       child: Text("Add Live Quiz",
//                           style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w500)),
//                     ),
//                     style: buttonStyle(Theme.of(context).primaryColor),
//                     onPressed: _openAddQuizForm,
//                   ),
//                 ),
//                 _setOrderButton(),
//                 _sortButton(),
//               ],
//             ),
//             FirestoreQueryBuilder<Map<String, dynamic>>(
//               query: _query,
//               builder: ((context, FirestoreQueryBuilderSnapshot<Map<String, dynamic>> snapshot, _) {
//                 if (snapshot.isFetching) {
//                   return const CircularProgressIndicator();
//                 }

//                 if (snapshot.hasError) {
//                   return Center(child: Text('Something went wrong! ${snapshot.error}'));
//                 }

//                 if (snapshot.docs.isEmpty) {
//                   return const Center(child: Text('No quizes found!'));
//                 }

//                 return GridView.builder(
//                   physics: const NeverScrollableScrollPhysics(),
//                   shrinkWrap: true,
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: AppService.getCrossAxisCount(context), childAspectRatio: AppService.getChildAspectRatio(context)),
//                   itemCount: snapshot.docs.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
//                       snapshot.fetchMore();
//                     }
//                     List<LiveQuiz> catList = snapshot.docs.map((e) => LiveQuiz.fromFirestore(e)).toList();
//                     final LiveQuiz d = catList[index];
//                     return GridTile(
//                         header: Padding(
//                           padding: const EdgeInsets.all(25),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               InkWell(
//                                   child: const CircleAvatar(
//                                     radius: 18,
//                                     child: Icon(
//                                       Icons.edit,
//                                       size: 18,
//                                     ),
//                                   ),
//                                   onTap: () => _onEditPressed(d)),
//                               const SizedBox(
//                                 width: 5,
//                               ),
//                               InkWell(
//                                   radius: 18,
//                                   child: const CircleAvatar(
//                                     child: Icon(
//                                       Icons.delete,
//                                       size: 18,
//                                     ),
//                                   ),
//                                   onTap: () => _onDeletePressed(d)),
//                             ],
//                           ),
//                         ),
//                         child: Stack(
//                           children: [
//                             Container(
//                               margin: const EdgeInsets.all(10),
//                               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
//                               child: CustomCacheImage(imageUrl: d.thumbnailUrl, radius: 10),
//                             ),
//                             Align(
//                               alignment: Alignment.bottomLeft,
//                               child: Padding(
//                                 padding: const EdgeInsets.only(left: 30, bottom: 30),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       d.name!,
//                                       style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
//                                     ),
//                                     Text(
//                                       'Question Count: ${d.questionCount}',
//                                       style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             )
//                           ],
//                         ));
//                   },
//                 );
//               }),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _openDeteleDialog(context, LiveQuiz d) {
//     showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return SimpleDialog(
//             contentPadding: const EdgeInsets.all(50),
//             elevation: 0,
//             children: <Widget>[
//               const Text('Delete This Live Quiz?', style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w700)),
//               const SizedBox(
//                 height: 10,
//               ),
//               Text("Do you want to delete this live quiz and it's contents?\nWarning: All of the questions included to this quiz will be deleted too!",
//                   style: TextStyle(color: Colors.grey[700], fontSize: 15, fontWeight: FontWeight.w400)),
//               const SizedBox(
//                 height: 30,
//               ),
//               Center(
//                   child: Row(
//                 children: <Widget>[
//                   TextButton(
//                       style: buttonStyle(Colors.redAccent),
//                       child: const Text(
//                         'Yes',
//                         style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
//                       ),
//                       onPressed: () => _handleDelete(d)),
//                   const SizedBox(width: 10),
//                   TextButton(
//                     style: buttonStyle(Colors.deepPurpleAccent),
//                     child: const Text(
//                       'No',
//                       style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
//                     ),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ))
//             ],
//           );
//         });
//   }

//   Widget _sortButton() {
//     return PopupMenuButton(
//       child: Container(
//         height: 40,
//         padding: const EdgeInsets.only(left: 20, right: 20),
//         decoration: BoxDecoration(color: Colors.grey[100], border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(30)),
//         child: Row(
//           children: [
//             Icon(
//               CupertinoIcons.sort_down,
//               color: Colors.grey[800],
//             ),
//             Visibility(
//               visible: Responsive.isMobile(context) ? false : true,
//               child: Row(
//                 children: [
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   Text(
//                     'Sort By - $_sortByText',
//                     style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//       itemBuilder: (BuildContext context) {
//         return <PopupMenuItem>[
//           const PopupMenuItem(
//             value: 'all',
//             child: Text('All'),
//           ),
//           const PopupMenuItem(
//             value: 'category',
//             child: Text('Sort By Category'),
//           ),
//         ];
//       },
//       onSelected: (dynamic value) {
//         if (value == 'all') {
//           setState(() {
//             _sortByText = 'All';
//             _query = firestore.collection(collectionName);
//           });
//         } else if (value == 'category') {
//           _openCategoryDialog();
//         }
//       },
//     );
//   }

//   Widget _setOrderButton() {
//     return InkWell(
//       onTap: () => _openOrderDialog(),
//       child: Container(
//         height: 40,
//         padding: const EdgeInsets.only(left: 20, right: 20),
//         margin: const EdgeInsets.only(right: 10),
//         decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(30)),
//         child: Row(
//           children: [
//             const Icon(
//               LineIcons.sortNumericDown,
//               color: Colors.white,
//             ),
//             Visibility(
//               visible: Responsive.isMobile(context) ? false : true,
//               child: Row(
//                 children: const [
//                   SizedBox(
//                     width: 10,
//                   ),
//                   Text(
//                     'Set Order',
//                     style: TextStyle(color: Colors.white, fontSize: 14),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   _openCategoryDialog() async {
//     await FirebaseService().getCategories().then((List<Category> cList) {
//       showDialog(
//           context: context,
//           builder: (context) {
//             return AlertDialog(
//               title: const Text('Select Category'),
//               content: SizedBox(
//                 height: 300,
//                 width: 300,
//                 child: ListView.separated(
//                   itemCount: cList.length,
//                   shrinkWrap: true,
//                   separatorBuilder: (BuildContext context, int index) => const Divider(),
//                   itemBuilder: (BuildContext context, int index) {
//                     return ListTile(
//                       contentPadding: const EdgeInsets.all(0),
//                       title: Text('${index + 1}. ${cList[index].name!}'),
//                       onTap: () {
//                         setState(() {
//                           _sortByText = cList[index].name!;
//                           _query = firestore.collection(collectionName).where('parent_id', isEqualTo: cList[index].id);
//                         });
//                         Navigator.pop(context);
//                       },
//                     );
//                   },
//                 ),
//               ),
//             );
//           });
//     });
//   }

//   _openOrderDialog() {
//     showDialog(
//         context: context,
//         builder: (context) {
//           return const Dialog(
//             child: SetQuizOrder(),
//           );
//         });
//   }
// }
