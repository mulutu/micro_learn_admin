import 'package:app_admin/services/firebase_service.dart';
import 'package:app_admin/utils/custom_dialog.dart';
import 'package:app_admin/utils/user_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import '../blocs/admin_bloc.dart';
import '../models/user.dart';
import '../utils/styles.dart';

import '../utils/user_info_dialog.dart';

class UsersDataSource extends DataTableSource {
  final List<UserModel> users;
  final BuildContext context;
  UsersDataSource(this.users, this.context);

  _onCopyButtonPressed(String id) async {
    String? userRole = context.read<AdminBloc>().userRole;
    final bool hasAccess = userRole != null && (userRole == 'admin' || userRole == 'editor');
    if (hasAccess) {
      await Clipboard.setData(ClipboardData(text: id)).then((value) => openCustomDialog(context, 'User Id copied to the clipboard', ''));
    } else {
      openCustomDialog(context, 'Disabled in testing mode', '');
    }
  }

  _onChangedUserAccess(UserModel user) async {
    String? userRole = context.read<AdminBloc>().userRole;
    final bool hasAccess = userRole != null && userRole == 'admin';
    if (hasAccess) {
      _openUserAccessDailog(user);
    } else {
      openCustomDialog(context, 'Only Admin has the control over this!', '');
    }
  }

  _openUserAccessDailog(UserModel user) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.all(50),
            elevation: 0,
            children: <Widget>[
              const Text('Disable User Access from the app?', style: TextStyle(color: Colors.black, fontSize: 23, fontWeight: FontWeight.w700)),
              const SizedBox(
                height: 10,
              ),
              Text('Warniing: By doing that user can not access the app anymore!',
                  style: TextStyle(color: Colors.grey[900], fontSize: 16, fontWeight: FontWeight.w400)),
              const SizedBox(
                height: 30,
              ),
              Center(
                  child: Row(
                children: <Widget>[
                  TextButton(
                      style: buttonStyle(Colors.redAccent),
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () async {
                        await FirebaseService().updateUserAccess(user.uid!, true).then((value) => Navigator.pop(context));
                      }),
                  const SizedBox(width: 10),
                  TextButton(
                    style: buttonStyle(Colors.deepPurpleAccent),
                    child: const Text(
                      'No',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ))
            ],
          );
        });
  }

  _onPressedUserRole(UserModel user, String role) async {
    String? userRole = context.read<AdminBloc>().userRole;
    final bool hasAccess = userRole != null && userRole == 'admin';
    if (hasAccess) {
      _openEditRoleDialog(user, role);
    } else {
      openCustomDialog(context, 'Only Admin can assign edtior', '');
    }
  }

  _openEditRoleDialog(UserModel user, String role) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.all(50),
            elevation: 0,
            children: <Widget>[
              Text(
                  role == 'user'
                      ? 'Assign As An Editor?'
                      : role == 'editor'
                          ? 'Remove Aceess from Editor?'
                          : '',
                  style: const TextStyle(color: Colors.black, fontSize: 23, fontWeight: FontWeight.w700)),
              const SizedBox(
                height: 10,
              ),
              Text(
                  role == 'user'
                      ? "Do you want to assign this user as an editor?\nWarning: By doing that, the user will have controll over add/edit/delete data"
                      : role == 'editor'
                          ? "Do you want remove the editor access for this user?"
                          : '',
                  style: TextStyle(color: Colors.grey[900], fontSize: 16, fontWeight: FontWeight.w400)),
              const SizedBox(
                height: 30,
              ),
              Center(
                  child: Row(
                children: <Widget>[
                  TextButton(
                      style: buttonStyle(Colors.redAccent),
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () async {
                        if (role == 'editor') {
                          await FirebaseService().removeEditorAccess(user.uid!).then((value) => Navigator.pop(context));
                        } else if (role == 'user') {
                          await FirebaseService().assignEditorAccess(user.uid!).then((value) => Navigator.pop(context));
                        }
                      }),
                  const SizedBox(width: 10),
                  TextButton(
                    style: buttonStyle(Colors.deepPurpleAccent),
                    child: const Text(
                      'No',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ))
            ],
          );
        });
  }

  _openUserInfoDiallog(UserModel user) {
    String? userRole = context.read<AdminBloc>().userRole;
    final bool hasAccess = userRole != null && (userRole == 'admin' || userRole == 'editor');
    showDialog(
      context: context,
      builder: (context) => userInfoDialog(context, user, hasAccess),
    );
  }

  _onPressedEditPoints(UserModel user, String role) async {
    String? userRole = context.read<AdminBloc>().userRole;
    final bool hasAccess = userRole != null && userRole == 'admin';
    if (hasAccess) {
      _openEditPointsDailog(user);
    } else {
      openCustomDialog(context, 'Only admin can edit user points', '');
    }
  }

  _openEditPointsDailog(UserModel user) {
    final formKey = GlobalKey<FormState>();
    final pointsCtlr = TextEditingController();
    pointsCtlr.text = user.points.toString();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.all(0),
            elevation: 0,
            children: <Widget>[
              Container(
                height: 56,
                color: Colors.white,
                padding: const EdgeInsets.only(left: 20, right: 20),
                margin: const EdgeInsets.all(0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit User Points',
                      style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 100, bottom: 50, top: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Form(
                      key: formKey,
                      child: SizedBox(
                        width: 150,
                        child: TextFormField(
                            controller: pointsCtlr,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              hintText: 'Enter Points',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) return 'Value is empty';
                              return null;
                            }),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    TextButton(
                      style: buttonStyle(Colors.deepPurpleAccent),
                      child: const Text(
                        'Update',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.validate();
                          final int newPoints = int.parse(pointsCtlr.text);
                          await FirebaseService().updateUserPoints(user.uid!, newPoints).then((value) {
                            Navigator.pop(context);
                            openCustomDialog(context, 'Updated Successfully', '');
                          });
                        }
                      },
                    ),
                  ],
                ),
              )
            ],
          );
        });
  }

  @override
  DataRow getRow(int index) {
    final bool isDisabled = users[index].disabled != null && users[index].disabled == true ? true : false;
    final String userRole = users[index].userRole!.isNotEmpty && users[index].userRole!.contains('admin')
        ? 'admin'
        : users[index].userRole!.contains('editor')
            ? 'editor'
            : 'user';

    return DataRow.byIndex(cells: [
      DataCell(_userNameCell(index)),
      DataCell(Text(
        users[index].points.toString(),
        style: defaultTextStyle(context),
      )),
      DataCell(Text(
        users[index].strength!.toStringAsFixed(2),
        style: defaultTextStyle(context),
      )),
      DataCell(_getEmail(users[index].email!)),
      //DataCell(Text(_getDateTime(users[index]), style: defaultTextStyle(context),)),
      DataCell(Row(
        children: [
          Transform.scale(
            scale: 0.7,
            child: CupertinoSwitch(
              value: !isDisabled,
              onChanged: (bool value) async {
                if (value == true) {
                  await FirebaseService().updateUserAccess(users[index].uid!, false);
                } else {
                  _onChangedUserAccess(users[index]);
                }
              },
            ),
          ),
          Text(
            isDisabled ? 'Disabled' : 'Enabled',
            style: defaultTextStyle(context),
          )
        ],
      )),
      DataCell(Text(
        userRole,
        style: defaultTextStyle(context),
      )),
      DataCell(_actionsCell(users[index], userRole)),
    ], index: index);
  }

  Text _getEmail(String userEmail) {
    final String? userRole = context.watch<AdminBloc>().userRole;
    final String emailText = userRole != null && userRole != 'user' ? userEmail : '*******@email.com';
    return Text(
      emailText,
      style: defaultTextStyle(context),
    );
  }

  Row _userNameCell(int index) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          height: 30,
          width: 30,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: Colors.green[100], image: getUserImage(context, users[index].imageurl, users[index].avatarString)),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
            child: Text(
          users[index].name!,
          style: defaultTextStyle(context),
        )),
      ],
    );
  }

  Widget _actionsCell(UserModel user, String userRole) {
    return Wrap(
      runSpacing: 8,
      children: [
        CircleAvatar(
          radius: 16,
          child: IconButton(
            icon: const Icon(Icons.copy),
            alignment: Alignment.center,
            iconSize: 16,
            tooltip: 'Copy user id',
            onPressed: () => _onCopyButtonPressed(user.uid!),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        CircleAvatar(
          radius: 16,
          child: IconButton(
              icon: const Icon(LineIcons.eyeAlt),
              alignment: Alignment.center,
              iconSize: 16,
              tooltip: 'View user info',
              onPressed: () => _openUserInfoDiallog(
                    user,
                  )),
        ),
        const SizedBox(
          width: 8,
        ),
        Visibility(
          visible: userRole != 'admin',
          child: CircleAvatar(
            radius: 16,
            child: IconButton(
              icon: const Icon(LineIcons.userEdit),
              alignment: Alignment.center,
              iconSize: 16,
              tooltip: 'Edit user role',
              onPressed: () => _onPressedUserRole(user, userRole),
            ),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        CircleAvatar(
          radius: 16,
          child: IconButton(
            icon: const Icon(LineIcons.editAlt),
            alignment: Alignment.center,
            iconSize: 16,
            tooltip: 'Edit user points',
            onPressed: () => _onPressedEditPoints(user, userRole),
          ),
        )
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => users.length;

  @override
  int get selectedRowCount => 0;
}
