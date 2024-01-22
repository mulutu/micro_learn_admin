import 'package:app_admin/components/html_editor.dart';
import 'package:app_admin/components/top_title.dart';
import 'package:app_admin/configs/constants.dart';
import 'package:app_admin/services/firebase_service.dart';
import 'package:app_admin/services/notification_service.dart';
import 'package:app_admin/utils/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../blocs/admin_bloc.dart';
import '../utils/styles.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  var formKey = GlobalKey<FormState>();
  var titleCtrl = TextEditingController();
  String? date;
  final _btnCtlr = RoundedLoadingButtonController();
  final String _targetUsers = Constants.fcmSubscriptionTopicForAllUsers;

  final HtmlEditorController controller = HtmlEditorController();

  _handleSendNotification() async {
    String? userRole = context.read<AdminBloc>().userRole;
    final bool hasAccess = userRole != null && userRole == 'admin';
    if(hasAccess){
      if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (await controller.getText() != '') {
        _btnCtlr.start();
        String description = await controller.getText();
        await NotificationService()
            .sendCustomNotificationByTopic(
                titleCtrl.text, description, _targetUsers)
            .then((value) async => await FirebaseService()
                    .increaseCount('notifications_count', null)
                    .then((value) {
                  _btnCtlr.reset();
                  clearTextfields();
                  openCustomDialog(
                      context, "Notification Sent Successfully!", '');
                  controller.clearFocus();
                }));
      } else {
        // ignore: use_build_context_synchronously
        openCustomDialog(context, "Description can't be empty", '');
      }
    }
    }else{
      openCustomDialog(context, 'Only admin can send notifications!', '');
    }
  }

  clearTextfields() {
    titleCtrl.clear();
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 15),
        child: RoundedLoadingButton(
          animateOnTap: false,
          borderRadius: 20,
          controller: _btnCtlr,
          onPressed: () => _handleSendNotification(),
          color: Theme.of(context).primaryColor,
          elevation: 0,
          width: MediaQuery.of(context).size.width * 0.40,
          child: const Wrap(
            children: [
              Text(
                'Send Now',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              )
            ],
          ),
        ),
      ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const TopTitle(title: 'Send A Notification To Users'),
              //_targetUserWidget(context),
              // SizedBox(
              //   height: 20,
              // ),
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        'Notification Title',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: TextFormField(
                        decoration: inputDecoration(
                            'Enter Notification Title', titleCtrl),
                        controller: titleCtrl,
                        validator: (value) {
                          if (value!.isEmpty) return 'Title is empty';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        'Notification Description',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border:
                                Border.all(color: Colors.grey[300]!, width: 2)),
                        height: 500,
                        child: CustomHtmlEditor(
                          controller: controller,
                          initialText: '',
                        )),
                    const SizedBox(
                      height: 50,
                    ),
                    
                    const SizedBox(
                      height: 200,
                    )
                  ],
                ),
              ),
            ])));
  }

  // Row _targetUserWidget(BuildContext context) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.start,
  //     children: [
  //       Radio(
  //         value: 0,
  //         groupValue: _selectedUserIndex,
  //         activeColor: Theme.of(context).primaryColor,
  //         onChanged: (value) {
  //           setState(() {
  //             _targetUsers = Constants.fcmSubscriptionTopicForAllUsers;
  //             _selectedUserIndex = 0;
  //           });
  //         },
  //       ),
  //       Text('All Users'),
  //       SizedBox(
  //         width: 10,
  //       ),
  //       Radio(
  //         value: 1,
  //         groupValue: _selectedUserIndex,
  //         activeColor: Theme.of(context).primaryColor,
  //         onChanged: (value) {
  //           setState(() {
  //             _selectedUserIndex = 1;
  //             _targetUsers = Constants.fcmSubscriptionTopicForRegularUsers;
  //           });
  //         },
  //       ),
  //       Text('Regular Users'),
  //       SizedBox(
  //         width: 10,
  //       ),
  //       Radio(
  //         value: 2,
  //         groupValue: _selectedUserIndex,
  //         activeColor: Theme.of(context).primaryColor,
  //         onChanged: (value) {
  //           setState(() {
  //             _selectedUserIndex = 2;
  //             _targetUsers = Constants.fcmSubscriptionTopicForPremiumUsers;
  //           });
  //         },
  //       ),
  //       Text('Premium Users'),
  //     ],
  //   );
  // }
}
