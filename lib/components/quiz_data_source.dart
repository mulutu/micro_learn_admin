import 'package:app_admin/components/image_preview.dart';
import 'package:app_admin/components/responsive.dart';
import 'package:app_admin/utils/next_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../blocs/admin_bloc.dart';
import '../configs/config.dart';
import '../forms/quiz_form.dart';
import '../models/quiz.dart';
import '../services/firebase_service.dart';
import '../utils/cached_image.dart';
import '../utils/custom_dialog.dart';
import '../utils/styles.dart';

class QuizDataSource extends DataTableSource {
  final List<Quiz> quizList;
  final BuildContext context;

  QuizDataSource(this.context, this.quizList);

  final String collectionName = 'quizes';
  final _deleteBtnCtlr = RoundedLoadingButtonController();

  _onEditPressed(Quiz quiz) {
    if (Responsive.isMobile(context)) {
      NextScreen().nextScreenPopup(context, QuizForm(quiz: quiz,));
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(child: QuizForm(quiz: quiz,));
          });
    }
  }

  _handleDelete(Quiz d) async {
    _deleteBtnCtlr.start();
    await _onDelete(d).then((value) {
      _deleteBtnCtlr.reset();
      Navigator.pop(context);
      openCustomDialog(context, 'Deleted Successfully!', '');
    });
  }

  Future _onDelete(Quiz d) async {
    await FirebaseService().deleteContent(collectionName, d.id!);
    await FirebaseService().decreaseCount('quizes_count', null);
    await FirebaseService().decreaseQuizCountInCategory(d.parentId!);
    await FirebaseService().deleteRelatedQuestionsAssociatedWithQuiz(d.id!);
  }

  _onDeletePressed(Quiz d) async {
    String? userRole = context.read<AdminBloc>().userRole;
    final bool hasAccess = userRole != null && userRole == 'admin' || userRole == 'editor';
    if (hasAccess) {
      _openDeteleDialog(context, d);
    } else {
      openCustomDialog(context, Config.testingDialog, '');
    }
  }

  void _openDeteleDialog(context, Quiz d) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.all(50),
            elevation: 0,
            children: <Widget>[
              const Text('Delete This Quiz?', style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(
                height: 10,
              ),
              Text("Do you want to delete this quiz and it's contents?\nWarning: All of the questions included to this quiz will be deleted too!",
                  style: TextStyle(color: Colors.grey[700], fontSize: 15, fontWeight: FontWeight.w400)),
              const SizedBox(
                height: 30,
              ),
              Center(
                  child: Row(
                children: <Widget>[
                  RoundedLoadingButton(
                    animateOnTap: false,
                    elevation: 0,
                    width: 110,
                    controller: _deleteBtnCtlr,
                    color: Colors.redAccent,
                    onPressed: () => _handleDelete(d),
                    child: const Text(
                      'Yes',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  RoundedLoadingButton(
                    animateOnTap: false,
                    elevation: 0,
                    width: 110,
                    controller: RoundedLoadingButtonController(),
                    color: Theme.of(context).primaryColor,
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'No',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ))
            ],
          );
        });
  }

  @override
  DataRow getRow(int index) {
    return DataRow.byIndex(cells: [

      DataCell(
        SizedBox(
          height: 40,
          width: 60,
          child: InkWell(
            onTap: ()=> openImagePreview(context, quizList[index].thumbnailUrl!),
            child: CustomCacheImage(imageUrl: quizList[index].thumbnailUrl, radius: 3)),
        )
      ),
      
      DataCell(Text(
        quizList[index].name.toString(),
        style: defaultTextStyle(context),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      )),
      

      DataCell(Text(
        quizList[index].questionCount.toString(),
        style: defaultTextStyle(context),
      )),
      
      DataCell(
        FutureBuilder(
          future: FirebaseService().getCategoryName(quizList[index].parentId!),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return Text(
                snapshot.data,
                style: defaultTextStyle(context),
              );
            }
            return const Text('---');
          },
        ),
      ),
      DataCell(_actions(quizList[index])),
    ], index: index);
  }

  


  Row _actions(Quiz quiz) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          child: IconButton(
            alignment: Alignment.center,
            iconSize: 16,
            tooltip: 'Edit',
            icon: const Icon(Icons.edit),
            onPressed: () => _onEditPressed(quiz),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.redAccent,
          child: IconButton(
            iconSize: 16,
            tooltip: 'Delete',
            icon: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
            onPressed: () => _onDeletePressed(quiz),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => quizList.length;

  @override
  int get selectedRowCount => 0;
}
