import 'package:app_admin/configs/config.dart';
import 'package:app_admin/models/quiz.dart';
import 'package:app_admin/services/firebase_service.dart';
import 'package:app_admin/utils/custom_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../blocs/admin_bloc.dart';
import '../models/category.dart';

class SetQuizOrder extends StatefulWidget {
  const SetQuizOrder({Key? key}) : super(key: key);

  @override
  State<SetQuizOrder> createState() => _SetQuizOrderState();
}

class _SetQuizOrderState extends State<SetQuizOrder> {
  late Future _categories;
  String? _selectedCategoryId;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Quiz> _quizzes = [];
  final _btnCtlr = RoundedLoadingButtonController();

  Future _getQuizzesAfterCategorySelection() async {
    await FirebaseService().getCategoryBasedQuizes(_selectedCategoryId!).then((List<Quiz> value) {
      bool hasIndex = value.isEmpty
          ? false
          : value[0].index != null
              ? true
              : false;
      debugPrint('has index: $hasIndex');
      setState(() {
        _quizzes = value;
        if (hasIndex) {
          _quizzes.sort((a, b) => a.index!.compareTo(b.index!));
        }
      });
    });
  }

  _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final Quiz quiz = _quizzes.removeAt(oldIndex);
    _quizzes.insert(newIndex, quiz);
    setState(() {});
  }

  Future _updateIndexAtDatabase() async {
    final batch = FirebaseFirestore.instance.batch();
    for (int i = 0; i < _quizzes.length; i++) {
      final docRef = firestore.collection('quizes').doc(_quizzes[i].id);
      batch.update(docRef, {'index': i});
    }
    await batch.commit();
  }

  _handleUpdateIndex() async {
    String? userRole = context.read<AdminBloc>().userRole;
    final bool hasAccess = userRole != null && userRole == 'admin' || userRole == 'editor';
    if (hasAccess) {
      if (_selectedCategoryId != null && _quizzes.isNotEmpty) {
        _btnCtlr.start();
        await _updateIndexAtDatabase().then((value) => _getQuizzesAfterCategorySelection().then((value) {
              _btnCtlr.reset();
              openCustomDialog(context, 'Updated Successfully', '');
            }));
      } else {
        openCustomDialog(context, 'Problem in updating index', '');
      }
    }else{
      openCustomDialog(context, Config.testingDialog, '');
    }
  }

  @override
  void initState() {
    _categories = FirebaseService().getCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        centerTitle: false,
        leadingWidth: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Set Quiz Order',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            padding: const EdgeInsets.only(left: 20, right: 20),
            icon: const Icon(
              Icons.close,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      bottomNavigationBar: _bottomBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: _categories,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  List<Category> categories = snapshot.data;
                  return _categoryDropdown(categories);
                }

                return const CircularProgressIndicator();
              },
            ),
            const SizedBox(
              height: 20,
            ),
            _selectedCategoryId == null
                ? const Center(
                    child: Text('Please Select A Category First!'),
                  )
                : _quizzes.isEmpty
                    ? const Center(
                        child: Text('No quizzes found!'),
                      )
                    : ReorderableListView(
                        shrinkWrap: true,
                        onReorder: (int oldIndex, int newIndex) => _onReorder(oldIndex, newIndex),
                        children: List.generate(
                            _quizzes.length,
                            (index) => ListTile(
                                  key: UniqueKey(),
                                  contentPadding: const EdgeInsets.only(top: 5, bottom: 5),
                                  leading: CircleAvatar(
                                    child: Text('${index + 1}'),
                                  ),
                                  title: Text(_quizzes[index].name.toString()),
                                )),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, top: 15),
      child: Visibility(
        visible: _selectedCategoryId != null,
        child: RoundedLoadingButton(
          animateOnTap: false,
          borderRadius: 5,
          width: 300,
          controller: _btnCtlr,
          onPressed: () => _handleUpdateIndex(),
          color: Theme.of(context).primaryColor,
          elevation: 0,
          child: const Wrap(
            children: [
              Text(
                'Update Order',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryDropdown(List<Category> categories) {
    return Container(
        height: 50,
        padding: const EdgeInsets.only(left: 15, right: 15),
        decoration: BoxDecoration(color: Colors.grey[200], border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(30)),
        child: DropdownButtonFormField(
            itemHeight: 50,
            decoration: const InputDecoration(border: InputBorder.none),
            onChanged: (dynamic value) {
              setState(() {
                _selectedCategoryId = value;
              });
              _getQuizzesAfterCategorySelection();
            },
            value: _selectedCategoryId,
            hint: const Text('Select Category'),
            items: categories.map((f) {
              return DropdownMenuItem(
                value: f.id,
                child: Text(f.name!),
              );
            }).toList()));
  }
}
