import 'package:app_admin/blocs/settings_bloc.dart';
import 'package:app_admin/components/card_wrapper.dart';
import 'package:app_admin/components/responsive.dart';
import 'package:app_admin/components/top_title.dart';
import 'package:app_admin/models/sp_category.dart';
import 'package:app_admin/utils/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../blocs/admin_bloc.dart';
import '../models/category.dart';
import '../services/firebase_service.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final formKey = GlobalKey<FormState>();
  final newUserRewardCtlr = TextEditingController();
  final rewardCtlr = TextEditingController();
  final penaltyCtlr = TextEditingController();
  final selfChallengeCtlr = TextEditingController();
  final _pointsUpdateBtnCtlr = RoundedLoadingButtonController();
  final _categoriesUpdateBtnCtlr = RoundedLoadingButtonController();

  final rewardAdpointsCtlr = TextEditingController();
  late Future _categories;
  SpecialCategory _specialCategory =
      SpecialCategory(enabled: false, id1: null, id2: null);

  _onPointsUpdatePressed() async {
    String? userRole = context.read<AdminBloc>().userRole;
    final bool hasAccess = userRole != null && userRole == 'admin';
    if (hasAccess) {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        _pointsUpdateBtnCtlr.start();
        await context
            .read<SettingsBloc>()
            .updateSettingsData(
                context,
                int.parse(rewardCtlr.text),
                int.parse(penaltyCtlr.text),
                int.parse(selfChallengeCtlr.text),
                int.parse(newUserRewardCtlr.text))
            .then((value) {
          _pointsUpdateBtnCtlr.reset();
          openCustomDialog(context, 'Update Complete', '');
        });
      }
    } else {
      openCustomDialog(context, 'Only admin can modify settings data', '');
    }
  }

  _onCategoriesUpdatePressed() async {
    String? userRole = context.read<AdminBloc>().userRole;
    final bool hasAccess = userRole != null && userRole == 'admin';
    if(hasAccess){
      if (_specialCategory.enabled) {
      if (_specialCategory.id1 != null && _specialCategory.id2 != null) {
        _categoriesUpdateBtnCtlr.start();
        await FirebaseService().saveSpecialCategory(_specialCategory);
        _categoriesUpdateBtnCtlr.reset();
        // ignore: use_build_context_synchronously
        openCustomDialog(context, 'Updated Successfully!', '');
      } else {
        openCustomDialog(context, 'Please select your special categories!', '');
      }
    } else {
      _categoriesUpdateBtnCtlr.start();
      await FirebaseService().saveSpecialCategory(_specialCategory).then((value){
        _categoriesUpdateBtnCtlr.reset();
        openCustomDialog(context, 'Updated Successfully!', '');
      });
      
    }
    }else{
      openCustomDialog(context, 'Only admin can modify settings data', '');
    }
  }

  _getSpecialCategories() async {
    _specialCategory = await FirebaseService().getSpecialCategory();
  }

  _getPointsData() {
    final sb = context.read<SettingsBloc>();
    newUserRewardCtlr.text = sb.initialRewardToNewUser.toString();
    rewardCtlr.text = sb.correctAnsReward.toString();
    penaltyCtlr.text = sb.incorrectAnsPenalty.toString();
    selfChallengeCtlr.text = sb.requiredPointsPlaySelfChallengeMode.toString();
    context.read<SettingsBloc>().getSettingsData();
  }

  @override
  void initState() {
    _categories = FirebaseService().getCategories();
    _getSpecialCategories();
    _getPointsData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final SettingsBloc sb = context.watch<SettingsBloc>();
    double width = Responsive.isDesktop(context)
        ? MediaQuery.of(context).size.width * 0.60
        : double.infinity;
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
          child: SizedBox(
        width: width,
        child: Wrap(
          children: [
            Form(
              key: formKey,
              child: CardWrapper(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: TopTitle(title: 'Points Settings'),
                    ),
                    ListTile(
                      title: const Text('New User Reward'),
                      trailing: _textfield(newUserRewardCtlr),
                    ),
                    ListTile(
                        title: const Text('Correct Answer Reward Per Question'),
                        trailing: _textfield(rewardCtlr)),
                    ListTile(
                        title:
                            const Text('Incorrect Answer Penalty Per Question'),
                        trailing: _textfield(penaltyCtlr)),
                    ListTile(
                        title: const Text('Self Challenge Mode Enabled'),
                        trailing: Switch(
                          value: sb.selfChallengeModeEnabled,
                          onChanged: (bool value) {
                            context
                                .read<SettingsBloc>()
                                .controlSelfChallengeMode(value);
                          },
                        )),
                    ListTile(
                      title:
                          const Text('Required Points to Play Self Challenge'),
                      trailing: _textfield(selfChallengeCtlr),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    RoundedLoadingButton(
                      controller: _pointsUpdateBtnCtlr,
                      height: 50,
                      color: Theme.of(context).primaryColor,
                      elevation: 0,
                      animateOnTap: false,
                      child: const Text('Update Data'),
                      onPressed: () => _onPointsUpdatePressed(),
                    )
                  ],
                ),
              ),
            ),
            CardWrapper(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: TopTitle(title: 'Special Categories'),
                  ),
                  ListTile(
                    title: const Text('Special Category Enabled'),
                    trailing: Switch(
                      value: _specialCategory.enabled,
                      onChanged: (bool value) {
                        setState(() {
                          _specialCategory.enabled = value;
                        });
                      },
                    ),
                  ),
                  Visibility(
                    visible: _specialCategory.enabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(
                          height: 20,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text('Category 1'),
                        ),
                        FutureBuilder(
                          future: _categories,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              List<Category> categories = snapshot.data;
                              return _category1Dropdown(categories);
                            }

                            return const CircularProgressIndicator();
                          },
                        ),
                        const Divider(
                          height: 40,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text('Category 2'),
                        ),
                        FutureBuilder(
                          future: _categories,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              List<Category> categories = snapshot.data;
                              return _category2Dropdown(categories);
                            }

                            return const CircularProgressIndicator();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  RoundedLoadingButton(
                    controller: _categoriesUpdateBtnCtlr,
                    height: 50,
                    color: Theme.of(context).primaryColor,
                    elevation: 0,
                    animateOnTap: false,
                    child: const Text('Update Data'),
                    onPressed: () => _onCategoriesUpdatePressed(),
                  )
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  Container _textfield(TextEditingController controller) {
    return Container(
      width: 60,
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3)
        ],
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.only(left: 5, right: 5),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _category1Dropdown(List<Category> categories) {
    return Container(
        padding: const EdgeInsets.only(left: 15, right: 15),
        decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(30)),
        child: DropdownButtonFormField(
            itemHeight: 50,
            decoration: const InputDecoration(border: InputBorder.none),
            onChanged: (dynamic value) {
              setState(() {
                _specialCategory.id1 = value;
              });
            },
            value: _specialCategory.id1,
            hint: const Text('Choose A Category'),
            items: categories.map((f) {
              return DropdownMenuItem(
                value: f.id,
                child: Text(f.name!),
              );
            }).toList()));
  }

  Widget _category2Dropdown(List<Category> categories) {
    return Container(
        padding: const EdgeInsets.only(left: 15, right: 15),
        decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(30)),
        child: DropdownButtonFormField(
            itemHeight: 50,
            decoration: const InputDecoration(border: InputBorder.none),
            onChanged: (dynamic value) {
              setState(() {
                _specialCategory.id2 = value;
              });
            },
            value: _specialCategory.id2,
            hint: const Text('Choose A Category'),
            items: categories.map((f) {
              return DropdownMenuItem(
                value: f.id,
                child: Text(f.name!),
              );
            }).toList()));
  }
}
