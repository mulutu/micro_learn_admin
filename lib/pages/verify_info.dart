import 'dart:convert';
import 'package:app_admin/services/app_service.dart';
import 'package:app_admin/services/firebase_service.dart';
import 'package:app_admin/utils/custom_dialog.dart';
import 'package:app_admin/utils/loading_animation.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:http/http.dart' as http;
import '../utils/next_screen.dart';
import 'home.dart';

class VerifyInfo extends StatefulWidget {
  const VerifyInfo({Key? key}) : super(key: key);

  @override
  State<VerifyInfo> createState() => _VerifyInfoState();
}

class _VerifyInfoState extends State<VerifyInfo> {
  var codeCtrl = TextEditingController();
  var formKey = GlobalKey<FormState>();

  final int itemId = 42890213;
  final _btnCtlr = RoundedLoadingButtonController();
  bool _isLoading = true;

  _checkVerification() async {
    bool valid = await FirebaseService().checkVerificationInfo();
    if (valid) {
      debugPrint('valid');
      await Future.delayed(const Duration(seconds: 1)).then((value) => NextScreen().nextScreenCloseOthersAnimation(context, const HomePage()));
    } else {
      debugPrint('invalid');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    _checkVerification();
    super.initState();
  }

  void _handleVerification() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      _btnCtlr.start();
      bool valid = await verifyPurchaseCode(codeCtrl.text.trim());
      if (valid) {
        await FirebaseService().saveVerificationInfo();
        _btnCtlr.success();
        await Future.delayed(const Duration(seconds: 1)).then((value) => NextScreen().nextScreenCloseOthersAnimation(context, const HomePage()));
      } else {
        _btnCtlr.reset();
        // ignore: use_build_context_synchronously
        openCustomDialog(context, 'Invalid purchase code!', '');
      }
    }
  }

  Future<bool> verifyPurchaseCode(String purchaseCode) async {
    final String url = 'https://www.mrb-lab.com/wp-json/envato/v1/verify-purchase/$purchaseCode';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        if (decodedData['validated'] == true && decodedData['purchase'] != null) {
          final int verifiedItemId = decodedData['purchase']['item']['id'];
          if (verifiedItemId == itemId) {
            return true;
          } else {
            return false;
          }
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }

  @override
  void dispose() {
    codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        body: Center(
          child: _isLoading
              ? const LoadingAnimation()
              : Container(
                  width: 600,
                  padding: const EdgeInsets.fromLTRB(40, 70, 40, 70),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text(
                        'Verify Your Envato Purchase Code',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Where Is My Purchase Code?',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () => AppService()
                                .openLink(context, 'https://help.market.envato.com/hc/en-us/articles/202822600-Where-Is-My-Purchase-Code-'),
                            child: const Text(
                              'Check',
                              style: TextStyle(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.w500, decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
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
                                    'Purchase Code',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                TextFormField(
                                  controller: codeCtrl,
                                  decoration: InputDecoration(
                                      hintText: 'Enter your envato purchase code',
                                      border: const OutlineInputBorder(),
                                      contentPadding: const EdgeInsets.only(right: 0, left: 10),
                                      suffixIcon: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CircleAvatar(
                                          radius: 15,
                                          backgroundColor: Colors.grey[300],
                                          child: IconButton(
                                              icon: const Icon(Icons.close, size: 15),
                                              onPressed: () {
                                                codeCtrl.clear();
                                              }),
                                        ),
                                      )),
                                  validator: (String? value) {
                                    if (value!.isEmpty) {
                                      return "value can't be empty";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 15,
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
                        onPressed: () => _handleVerification(),
                        child: const Text('Verify'),
                      ),
                    ],
                  ),
                ),
        ));
  }
}
