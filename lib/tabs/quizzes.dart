import 'package:app_admin/components/responsive.dart';
import 'package:app_admin/components/set_quiz_order.dart';
import 'package:app_admin/services/firebase_service.dart';
import 'package:app_admin/utils/next_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import '../components/card_wrapper.dart';
import '../components/quiz_data_source.dart';
import '../forms/quiz_form.dart';
import '../models/category.dart';
import '../models/quiz.dart';
import '../utils/styles.dart';

class Quizzes extends StatefulWidget {
  const Quizzes({Key? key}) : super(key: key);

  @override
  State<Quizzes> createState() => _QuizzesState();
}

class _QuizzesState extends State<Quizzes> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final String collectionName = 'quizes';
  late Query<Map<String, dynamic>> _query;
  String? _sortByText;
  final int _itemPerPage = 11;

  @override
  void initState() {
    _sortByText = 'All';
    _query = firestore.collection(collectionName);
    super.initState();
  }

  _openAddQuizForm() {
    if (Responsive.isMobile(context)) {
      NextScreen().nextScreenPopup(
          context,
          const QuizForm(
            quiz: null,
          ));
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return const Dialog(
              child: QuizForm(
                quiz: null,
              ),
            );
          });
    }
  }

  final List<DataColumn> _columns = [
    const DataColumn(
      label: Text('Thumbnail')
    ),
    const DataColumn(
      label: Text('Quiz Name'),
    ),
    const DataColumn(
      label: Text('Questions Amount'),
    ),
    const DataColumn(
      label: Text('Category'),
    ),
    const DataColumn(
      label: Text('Actions'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CardWrapper(
        child: FirestoreQueryBuilder<Map<String, dynamic>>(
          pageSize: _itemPerPage,
          query: _query,
          builder: (context, snapshot, _) {
            List<Quiz> quizList = [];
            quizList = snapshot.docs.map((e) => Quiz.fromFirestore(e)).toList();
            DataTableSource source = QuizDataSource(context, quizList);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PaginatedDataTable2(
                rowsPerPage: _itemPerPage - 1,
                source: source,
                header: Text('All Quizzes', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                empty: const Center(child: Text('No Quizzes Found')),
                minWidth: 600,
                wrapInCard: false,
                horizontalMargin: 20,
                columnSpacing: 20,
                dataRowHeight: 70,
                onPageChanged: (_) {
                  snapshot.fetchMore();
                },
                actions: [
                  _addQuizBtn(),
                  _setOrderButton(),
                  _sortButton(),
                ],
                columns: _columns,
                fixedTopRows: 1,
              ),
            );
          },
        ),
      ),
    );
  }

  Padding _addQuizBtn() {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: TextButton.icon(
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: Visibility(
          visible: !Responsive.isMobile(context),
          child: Text("Add Quiz", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w500)),
        ),
        style: buttonStyle(Theme.of(context).primaryColor),
        onPressed: _openAddQuizForm,
      ),
    );
  }

  Widget _sortButton() {
    return PopupMenuButton(
      child: Container(
        height: 40,
        padding: const EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(color: Colors.grey[100], border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(30)),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.sort_down,
              color: Colors.grey[800],
            ),
            Visibility(
              visible: Responsive.isMobile(context) ? false : true,
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Sort By - $_sortByText',
                    style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem>[
          const PopupMenuItem(
            value: 'all',
            child: Text('All'),
          ),
          const PopupMenuItem(
            value: 'category',
            child: Text('Sort By Category'),
          ),
        ];
      },
      onSelected: (dynamic value) {
        if (value == 'all') {
          setState(() {
            _sortByText = 'All';
            _query = firestore.collection(collectionName);
          });
        } else if (value == 'category') {
          _openCategoryDialog();
        }
      },
    );
  }

  Widget _setOrderButton() {
    return InkWell(
      onTap: () => _openOrderDialog(),
      child: Container(
        height: 40,
        padding: const EdgeInsets.only(left: 20, right: 20),
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(30)),
        child: Row(
          children: [
            const Icon(
              LineIcons.sortNumericDown,
              color: Colors.white,
            ),
            Visibility(
              visible: Responsive.isMobile(context) ? false : true,
              child: const Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Set Order',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _openCategoryDialog() async {
    await FirebaseService().getCategories().then((List<Category> cList) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Select Category'),
              content: SizedBox(
                height: 300,
                width: 300,
                child: ListView.separated(
                  itemCount: cList.length,
                  shrinkWrap: true,
                  separatorBuilder: (BuildContext context, int index) => const Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      title: Text('${index + 1}. ${cList[index].name!}'),
                      onTap: () {
                        setState(() {
                          _sortByText = cList[index].name!;
                          _query = firestore.collection(collectionName).where('parent_id', isEqualTo: cList[index].id);
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            );
          });
    });
  }

  _openOrderDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return const Dialog(
            child: SetQuizOrder(),
          );
        });
  }
}
