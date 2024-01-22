import 'package:app_admin/blocs/admin_bloc.dart';
import 'package:app_admin/configs/config.dart';
import 'package:app_admin/pages/verify_info.dart';
import 'package:app_admin/utils/custom_dialog.dart';
import 'package:app_admin/utils/next_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../services/auth_service.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  var passwordCtrl = TextEditingController();
  var emailCtrl = TextEditingController();
  var formKey = GlobalKey<FormState>();
  String? password;

  final _btnCtlr = RoundedLoadingButtonController();

  void _handleSignIn() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      _btnCtlr.start();
      await AuthService().loginWithEmailPassword(emailCtrl.text, passwordCtrl.text).then((UserCredential? user) async {
        if (user != null) {
          debugPrint(user.user!.uid);
          debugPrint('Login Success');
          await AuthService().checkUserRole(user.user!.uid).then((String? userRole) async {
            if (userRole != null && userRole == 'admin' || userRole == 'editor') {
              await context.read<AdminBloc>().setUserRole(userRole!);
              _btnCtlr.success();
              await Future.delayed(const Duration(seconds: 1)).then((value) => NextScreen.nextScreenNormal(context, const VerifyInfo()));
            } else {
              await AuthService().adminLogout();
              _btnCtlr.reset();
              // ignore: use_build_context_synchronously
              openCustomDialog(context, 'The email is not authorized as an admin', '');
            }
          });
        } else {
          _btnCtlr.reset();
          debugPrint('SignInErorr');
          openCustomDialog(context, 'Sign In Error! Please try again.', 'Email/Password is invalid');
        }
      });
    }
  }



  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        body: Center(
          child: Container(
            //height: 520,
            width: 600,
            padding: const EdgeInsets.fromLTRB(40, 70, 40, 70),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(Config.logo, width: 200,),
                const SizedBox(height: 5,),
                const Text(
                  'Welcome to Admin Panel',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40, right: 40),
                  child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              'Email Address',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          TextFormField(
                            controller: emailCtrl,
                            decoration: InputDecoration(
                                hintText: 'Enter Admin Email',
                                border: const OutlineInputBorder(),
                                contentPadding:
                                    const EdgeInsets.only(right: 0, left: 10),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Colors.grey[300],
                                    child: IconButton(
                                        icon: const Icon(Icons.close, size: 15),
                                        onPressed: () {
                                          emailCtrl.clear();
                                        }),
                                  ),
                                )),
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return "Password can't be empty";
                              }

                              return null;
                            },
                            onChanged: (String value) {
                              setState(() {
                                password = value;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              'Password',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          TextFormField(
                            controller: passwordCtrl,
                            obscureText: true,
                            decoration: InputDecoration(
                                hintText: 'Enter Password',
                                border: const OutlineInputBorder(),
                                contentPadding:
                                    const EdgeInsets.only(right: 0, left: 10),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Colors.grey[300],
                                    child: IconButton(
                                        icon: const Icon(Icons.close, size: 15),
                                        onPressed: () {
                                          passwordCtrl.clear();
                                        }),
                                  ),
                                )),
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return "Password can't be empty";
                              }

                              return null;
                            },
                            onChanged: (String value) {
                              setState(() {
                                password = value;
                              });
                            },
                          ),
                        ],
                      )),
                ),
                const SizedBox(
                  height: 30,
                ),

                RoundedLoadingButton(
                  controller: _btnCtlr,
                  color: Theme.of(context).primaryColor,
                  animateOnTap: false,
                  onPressed: ()=> _handleSignIn(),
                  child: const Text('Sign In'),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ));
  }
}
