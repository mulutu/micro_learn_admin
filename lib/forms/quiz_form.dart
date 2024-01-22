import 'package:app_admin/components/custom_textfields.dart';
import 'package:app_admin/components/html_editor.dart';
import 'package:app_admin/configs/config.dart';
import 'package:app_admin/configs/constants.dart';
import 'package:app_admin/models/quiz.dart';
import 'package:app_admin/services/app_service.dart';
import 'package:app_admin/utils/custom_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../blocs/admin_bloc.dart';
import '../models/category.dart';
import '../services/firebase_service.dart';

class QuizForm extends StatefulWidget {
  const QuizForm({Key? key, required this.quiz}) : super(key: key);

  final Quiz? quiz;

  @override
  State<QuizForm> createState() => _QuizFormState();
}

class _QuizFormState extends State<QuizForm> {
  late String _submitBtnText;
  late String _dialogText;
  var nameCtlr = TextEditingController();
  var thumbnailUrlCtlr = TextEditingController();
  var timeCtlr = TextEditingController();
  var pointsReqCtlr = TextEditingController();
  final _btnCtlr = RoundedLoadingButtonController();
  var formKey = GlobalKey<FormState>();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collectionName = 'quizes';

  final HtmlEditorController controller = HtmlEditorController();

  late Future _categories;
  String? _selectedCategoryId;
  bool _timer = true;
  final int _defaultQuizTime = 2; //2 minutes as default
  XFile? _selectedImage;
  String? _qOrderString;

  _onPickImage() async {
    XFile? image = await AppService().pickImage();
    if (image != null) {
      setState(() {
        _selectedImage = image;
        thumbnailUrlCtlr.text = image.name;
      });
    }
  }

  initData() {
    if (widget.quiz == null) {
      _categories = FirebaseService().getCategories();
      timeCtlr.text = _defaultQuizTime.toString();
    } else {
      _categories = FirebaseService().getCategories();
      _selectedCategoryId = widget.quiz!.parentId;
      _timer = widget.quiz!.timer!;
      timeCtlr.text = widget.quiz!.quizTime.toString();
      nameCtlr.text = widget.quiz!.name!;
      thumbnailUrlCtlr.text = widget.quiz!.thumbnailUrl!;
      timeCtlr.text = widget.quiz!.quizTime.toString();
      pointsReqCtlr.text = widget.quiz!.pointsRequired.toString();
      _qOrderString = AppService.setQuestionOrderString(widget.quiz!.questionOrder);
    }
  }

  @override
  void initState() {
    _submitBtnText = widget.quiz == null ? 'Upload Quiz' : 'Update Quiz';
    _dialogText = widget.quiz == null ? 'Uploaded Successfully!' : 'Updated Successfully!';
    initData();
    super.initState();
  }

  void _handleSubmit() async {
    String? userRole = context.read<AdminBloc>().userRole;
    final bool hasAccess = userRole != null && userRole == 'admin' || userRole == 'editor';
    if (hasAccess) {
      if (_selectedCategoryId != null) {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          if (await controller.getText() != '') {
            if (_selectedImage != null) {
              //local image
              _btnCtlr.start();
              await FirebaseService().uploadImageToFirebaseHosting(_selectedImage!, 'quiz_thumbnails').then((String? imageUrl) {
                if (imageUrl != null) {
                  setState(() => thumbnailUrlCtlr.text = imageUrl);
                  _uploadProcedure();
                } else {
                  setState(() {
                    _selectedImage = null;
                    thumbnailUrlCtlr.clear();
                    _btnCtlr.reset();
                  });
                }
              });
            } else {
              //netwok image
              _btnCtlr.start();
              _uploadProcedure();
            }
          } else {
            // ignore: use_build_context_synchronously
            openCustomDialog(context, "Description can't be empty", '');
          }
        }
      } else {
        openCustomDialog(context, 'Select A Category First', '');
      }
    } else {
      openCustomDialog(context, Config.testingDialog, '');
    }
  }

  _uploadProcedure() async {
    await uploadQuiz().then((value) async {
      if(widget.quiz == null){
        await FirebaseService().increaseCount('quizes_count', null)
        .then((value) async => await FirebaseService().increaseQuizCountInCategory(_selectedCategoryId!));
      }
      _btnCtlr.success();
      debugPrint('Upload Complete');
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      openCustomDialog(context, _dialogText, '');
    });
  }

  Future uploadQuiz() async {
    String docId = widget.quiz == null ? firestore.collection(collectionName).doc().id : widget.quiz!.id!;
    final String qOrder = AppService.getQuestionOrder(_qOrderString);
    final String description = await controller.getText();
    final int questionCount = widget.quiz == null ? 0: widget.quiz!.questionCount!;
    Quiz d = Quiz(
        id: docId,
        name: nameCtlr.text,
        thumbnailUrl: thumbnailUrlCtlr.text,
        timer: _timer,
        parentId: _selectedCategoryId,
        quizTime: _timer ? int.parse(timeCtlr.text) : 0,
        questionCount: questionCount,
        pointsRequired: int.parse(pointsReqCtlr.text),
        description: description,
        questionOrder: qOrder);
    Map<String, dynamic> data = Quiz.getMap(d);
    await firestore.collection(collectionName).doc(docId).set(data, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20),
          child: InkWell(
            child: const CircleAvatar(
              radius: 20,
              child: Icon(Icons.close),
            ),
            onTap: () => Navigator.pop(context),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 15, top: 15),
        child: RoundedLoadingButton(
          animateOnTap: false,
          borderRadius: 5,
          width: 300,
          controller: _btnCtlr,
          onPressed: () => _handleSubmit(),
          color: Theme.of(context).primaryColor,
          elevation: 0,
          child: Wrap(
            children: [
              Text(
                _submitBtnText,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            'Category',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
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
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            'Quiz Name',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextFormField(
                            controller: nameCtlr,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                hintText: 'Enter Quiz Title',
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => nameCtlr.clear(),
                                )),
                            validator: (value) {
                              if (value!.isEmpty) return 'Value is empty';
                              return null;
                            }),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            'Quiz Thumbnail Image',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        imageTextField(thumbnailUrlCtlr, _selectedImage, () {
                          setState(() {
                            _selectedImage = null;
                          });
                        }, _onPickImage)
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            'Points Required To Play This Quiz',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: TextFormField(
                              controller: pointsReqCtlr,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  hintText: 'Enter Points',
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => nameCtlr.clear(),
                                  )),
                              validator: (value) {
                                if (value!.isEmpty) return 'Value is empty';
                                return null;
                              }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  'Question Order',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              _questionOrderDropdown(),
              const SizedBox(
                height: 30,
              ),
              _timerWidget(context),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  'Enter Quiz Description',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                  decoration: BoxDecoration(color: Colors.grey[100], border: Border.all(width: 2, color: Colors.grey[300]!)),
                  child: CustomHtmlEditor(
                    controller: controller,
                    initialText: widget.quiz == null ? '' : widget.quiz!.description.toString(),
                  )),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row _timerWidget(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          CupertinoIcons.timer,
          size: 20,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(
          width: 5,
        ),
        const Text('Timer: '),
        const SizedBox(
          width: 30,
        ),
        Radio(
          value: true,
          groupValue: _timer,
          activeColor: Theme.of(context).primaryColor,
          onChanged: (value) {
            setState(() {
              _timer = true;
            });
          },
        ),
        const Text('On'),
        const SizedBox(
          width: 10,
        ),
        Radio(
          value: false,
          groupValue: _timer,
          activeColor: Theme.of(context).primaryColor,
          onChanged: (value) {
            setState(() {
              _timer = false;
            });
          },
        ),
        const Text('Off'),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: Visibility(
            visible: _timer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    'Timer In Minutes Per Complete Quiz',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: TextFormField(
                      controller: timeCtlr,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                      decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          hintText: 'Timer in Minutes',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => timeCtlr.clear(),
                          )),
                      validator: (value) {
                        if (value!.isEmpty) return 'Value is empty';
                        return null;
                      }),
                ),
              ],
            ),
          ),
        ),
      ],
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

  Widget _questionOrderDropdown() {
    return Container(
        height: 50,
        padding: const EdgeInsets.only(left: 15, right: 15),
        decoration: BoxDecoration(color: Colors.grey[200], border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(30)),
        child: DropdownButtonFormField(
            itemHeight: 50,
            decoration: const InputDecoration(border: InputBorder.none),
            onChanged: (dynamic value) {
              setState(() {
                _qOrderString = value;
              });
            },
            value: _qOrderString,
            hint: const Text('Select Question Order'),
            items: Constants.questionOrders.map((f) {
              return DropdownMenuItem(
                value: f,
                child: Text(f),
              );
            }).toList()));
  }
}
