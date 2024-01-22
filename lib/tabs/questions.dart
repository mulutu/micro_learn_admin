import 'package:app_admin/components/card_wrapper.dart';
import 'package:app_admin/components/responsive.dart';
import 'package:app_admin/configs/constants.dart';
import 'package:app_admin/models/category.dart';
import 'package:app_admin/models/quiz.dart';
import 'package:app_admin/services/firebase_service.dart';
import 'package:app_admin/utils/next_screen.dart';
import 'package:app_admin/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../components/question_data_source.dart';
import '../forms/question_form.dart';
import '../models/question.dart';

class Questions extends StatefulWidget {
  const Questions({Key? key}) : super(key: key);

  @override
  State<Questions> createState() => _QuestionsState();
}

class _QuestionsState extends State<Questions> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collectionName = 'questions';
  final int _itemPerPage = 11;
  String? _sortByText;

  late Query<Map<String, dynamic>> query;

  @override
  void initState() {
    _sortByText = 'Newest First';
    query = firestore.collection(collectionName).orderBy('created_at', descending: true);
    super.initState();
  }

  _openAddQuestionForm() {
    if(Responsive.isMobile(context)){
      NextScreen().nextScreenPopup(context, const QuestionForm(q: null,));
    }else{
      showDialog(
        context: context,
        builder: (context) {
          return const Dialog(
            child: QuestionForm(q: null,),
          );
        });
    }
  }

  final List<DataColumn> _columns = [
    const DataColumn(
      label: Text('Question Title'),
    ),
    const DataColumn(
      label: Text('Options'),
    ),
    const DataColumn(
      label: Text('Question Type'),
    ),
    const DataColumn(
      label: Text('Quiz Name'),
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
          query: query,
          builder: (context, snapshot, _) {
            List<Question> qList = [];
            qList = snapshot.docs.map((e) => Question.fromFirestore(e)).toList();
            DataTableSource source = QuestionDataSource(context, qList);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PaginatedDataTable2(
                rowsPerPage: _itemPerPage - 1,
                source: source,
                header: Text('All Questions', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                empty: const Center(child: Text('No Questions Found')),
                minWidth: 900,
                wrapInCard: false,
                horizontalMargin: 20,
                columnSpacing: 20,
                dataRowHeight: 90,
                onPageChanged: (_) {
                  snapshot.fetchMore();
                },
                actions: [
                  _addQuestionBtn(context),
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

  TextButton _addQuestionBtn(BuildContext context) {
    return TextButton.icon(
            icon: const Icon(
              Icons.add,
              color: Colors.white
            ),
            label: Visibility(
              visible: Responsive.isMobile(context) ? false : true,
              child: Text("Add Question",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500)),
            ),
            style: buttonStyle(Theme.of(context).primaryColor),
            onPressed: _openAddQuestionForm,
          );
  }

  Widget _sortButton() {
    return PopupMenuButton(
      child: Container(
        height: 40,
        padding: const EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(30)),
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
                    style: TextStyle(color: Colors.grey.shade800, fontSize: 14,),
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
            value: 'new',
            child: Text('Newest First'),
          ),
          const PopupMenuItem(
            value: 'old',
            child: Text('Oldest First'),
          ),
          const PopupMenuItem(
            value: 'four',
            child: Text('Four Options'),
          ),
          const PopupMenuItem(
            value: 'tf',
            child: Text('True/False'),
          ),
          const PopupMenuItem(
            value: 'text',
            child: Text('Text Only Questions'),
          ),
          const PopupMenuItem(
            value: 'image',
            child: Text('Image Questions'),
          ),
          const PopupMenuItem(
            value: 'audio',
            child: Text('Audio Questions'),
          ),
          const PopupMenuItem(
            value: 'video',
            child: Text('Video Questions'),
          ),
          const PopupMenuItem(
            value: 'quiz',
            child: Text('Sort By Quiz'),
          ),
          const PopupMenuItem(
            value: 'category',
            child: Text('Sort By Category'),
          ),
        ];
      },
      onSelected: (dynamic value) {
        if (value == 'new') {
          setState(() {
            _sortByText = 'Newest First';
            query = firestore.collection(collectionName).orderBy('created_at', descending: true);
          });
        } else if (value == 'old') {
          setState(() {
            _sortByText = 'Oldest First';
            query = firestore.collection(collectionName).orderBy('created_at', descending: false);
          });
        }else if(value == 'four'){
          setState(() {
            _sortByText = 'Four Options';
            query = firestore.collection(collectionName).where('has_four_options', isEqualTo: true);
          });
        }else if(value == 'tf'){
          setState(() {
            _sortByText = 'True/False';
            query = firestore.collection(collectionName).where('has_four_options', isEqualTo: false);
          });
        }else if(value == 'text'){
          setState(() {
            _sortByText = 'Text Only';
            query = firestore.collection(collectionName).where('question_type', isEqualTo: Constants.questionTypes.keys.elementAt(0));
          });
        }else if(value == 'image'){
          setState(() {
            _sortByText = 'Image Questions';
            query = firestore.collection(collectionName).where('question_type', isEqualTo: Constants.questionTypes.keys.elementAt(1));
          });
        }else if(value == 'audio'){
          setState(() {
            _sortByText = 'Audio Questions';
            query = firestore.collection(collectionName).where('question_type', isEqualTo: Constants.questionTypes.keys.elementAt(2));
          });
        }else if(value == 'video'){
          setState(() {
            _sortByText = 'Video Questions';
            query = firestore.collection(collectionName).where('question_type', isEqualTo: Constants.questionTypes.keys.elementAt(3));
          });
        }else if(value == 'quiz'){
          _openQuizDialog();
        }else if(value == 'category'){
          _openCategoryDialog();
        }
      },
    );
  }

  _openQuizDialog ()async{
    await FirebaseService().getQuizes().then((List<Quiz> qList){
      showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: const Text('Select Quiz'),
            content: SizedBox(
              height: 300,
              width: 300,
              child: ListView.separated(
                itemCount: qList.length,
                shrinkWrap: true,
                separatorBuilder: (BuildContext context, int index) => const Divider(),
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    title: Text('${index + 1}. ${qList[index].name!}'),
                    onTap: (){
                      setState(() {
                        _sortByText = qList[index].name!;
                        query = firestore.collection('questions').where('quiz_id', isEqualTo: qList[index].id);
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          );
        }
      );
    });
  }

  _openCategoryDialog ()async{
    await FirebaseService().getCategories().then((List<Category> cList){
      showDialog(
        context: context,
        builder: (context){
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
                    onTap: (){
                      setState(() {
                        _sortByText = cList[index].name!;
                        query = firestore.collection('questions').where('cat_id', isEqualTo: cList[index].id);
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          );
        }
      );
    });
  }
}
