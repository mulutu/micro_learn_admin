import 'package:app_admin/components/image_preview.dart';
import 'package:app_admin/components/responsive.dart';
import 'package:app_admin/configs/config.dart';
import 'package:app_admin/configs/constants.dart';
import 'package:app_admin/forms/question_form.dart';
import 'package:app_admin/services/app_service.dart';
import 'package:app_admin/utils/next_screen.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../blocs/admin_bloc.dart';
import '../models/question.dart';
import '../services/firebase_service.dart';
import '../utils/cached_image.dart';
import '../utils/custom_dialog.dart';
import '../utils/styles.dart';

class QuestionDataSource extends DataTableSource {
  final List<Question> qList;
  final BuildContext context;

  QuestionDataSource(this.context, this.qList);

  final String collectionName = 'questions';
  final _deleteBtnCtlr = RoundedLoadingButtonController();

  _onEditPressed(Question q) {
    if (Responsive.isMobile(context)) {
      NextScreen().nextScreenPopup(context, QuestionForm(q: q));
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(child: QuestionForm(q: q));
          });
    }
    
  }

  _handleDelete(Question q) async {
    _deleteBtnCtlr.start();
    await FirebaseService()
        .deleteContent(collectionName, q.id!)
        .then((value) async => await FirebaseService().decreaseCount('questions_count', null))
        .then((value) async => await FirebaseService().decreaseQuestionCountInQuiz(q.quizId!).then((value) {
              _deleteBtnCtlr.success();
              Navigator.pop(context);
              openCustomDialog(context, 'Deleted Successfully!', '');
            }));
  }

  _onDeletePressed(Question q) async {
    String? userRole = context.read<AdminBloc>().userRole;
    final bool hasAccess = userRole != null && userRole == 'admin' || userRole == 'editor';
    if (hasAccess) {
      _openDeleteDialog(q);
    } else {
      openCustomDialog(context, Config.testingDialog, '');
    }
  }

  _openDeleteDialog(Question q) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.all(50),
            elevation: 0,
            children: <Widget>[
              const Text('Delete This Question?', style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1), fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(
                height: 10,
              ),
              Text("Do you really want to delete this question?\nWarning: This action can't be undone!",
                  style: TextStyle(color: Colors.grey[700], fontSize: 16, fontWeight: FontWeight.w400)),
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
                    onPressed: ()=> _handleDelete(q),
                    child: const Text('Delete', style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold
                    ),),
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
      DataCell(Text(
        qList[index].questionTitle!,
        style: defaultTextStyle(context),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      )),
      _options(qList[index]),
      _questionTypes(qList[index]),
      DataCell(
        FutureBuilder(
          future: FirebaseService().getQuizName(qList[index].quizId!),
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
      DataCell(_actions(qList[index])),
    ], index: index);
  }

  DataCell _options(Question q) {
    if (q.optionsType == null ||
        q.optionsType == Constants.optionTypes.keys.elementAt(0) ||
        q.optionsType == Constants.optionTypes.keys.elementAt(1)) {
      return DataCell(Text(
        q.options.toString(),
        style: defaultTextStyle(context),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ));
    } else if (q.optionsType == Constants.optionTypes.keys.elementAt(2)) {
      return DataCell(Wrap(
          children: q.options!
              .map((e) => InkWell(
                    onTap: () => openImagePreview(context, e),
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      height: 30,
                      width: 40,
                      child: CustomCacheImage(imageUrl: e, radius: 2),
                    ),
                  ))
              .toList()));
    } else {
      return DataCell(Container());
    }
  }

  DataCell _questionTypes(Question q) {
    if (q.questionType == Constants.questionTypes.keys.elementAt(0)) {
      return DataCell(Text(
        'Text Only',
        style: defaultTextStyle(context),
      ));
    } else if (q.questionType == Constants.questionTypes.keys.elementAt(1)) {
      return DataCell(InkWell(
        onTap: () => openImagePreview(context, q.questionImageUrl!),
        child: SizedBox(height: 40, width: 60, child: CustomCacheImage(imageUrl: q.questionImageUrl, radius: 3)),
      ));
    } else if (q.questionType == Constants.questionTypes.keys.elementAt(2)) {
      return DataCell(InkWell(
        onTap: () => AppService().openLink(context, q.questionAudioUrl.toString()),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.shade300,
          child: Icon(LineIcons.audioFile, size: 22, color: Theme.of(context).primaryColor),
        ),
      ));
    } else if (q.questionType == Constants.questionTypes.keys.elementAt(3)) {
      return DataCell(InkWell(
        onTap: () => AppService().openLink(context, q.questionVideoUrl.toString()),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.shade300,
          child: Icon(LineIcons.videoFile, size: 22, color: Theme.of(context).primaryColor),
        ),
      ));
    } else {
      return DataCell(Container());
    }
  }

  Row _actions(Question q) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          child: IconButton(
            alignment: Alignment.center,
            iconSize: 16,
            tooltip: 'Edit',
            icon: const Icon(Icons.edit),
            onPressed: () => _onEditPressed(q),
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
            onPressed: () => _onDeletePressed(q),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => qList.length;

  @override
  int get selectedRowCount => 0;
}
