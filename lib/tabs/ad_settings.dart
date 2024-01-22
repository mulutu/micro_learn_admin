import 'package:app_admin/blocs/ads_bloc.dart';
import 'package:app_admin/components/card_wrapper.dart';
import 'package:app_admin/components/top_title.dart';
import 'package:app_admin/utils/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../blocs/admin_bloc.dart';
import '../components/responsive.dart';

class AdSettings extends StatefulWidget {
  const AdSettings({Key? key}) : super(key: key);

  @override
  State<AdSettings> createState() => _AdSettingsState();
}

class _AdSettingsState extends State<AdSettings> {
  final formKey = GlobalKey<FormState>();
  final _updateBtnCtlr = RoundedLoadingButtonController();

  final rewardAdpointsCtlr = TextEditingController();

  _onUpdatePressed() async {
    String? userRole = context.read<AdminBloc>().userRole;
    final bool hasAccess = userRole != null && userRole == 'admin';
    if(hasAccess){
      if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      _updateBtnCtlr.start();
      await context
          .read<AdsBloc>()
          .updateAdSettings(int.parse(rewardAdpointsCtlr.text))
          .then((value) {
        _updateBtnCtlr.reset();
        openCustomDialog(context, 'Update Complete', '');
      });
    }
    }else{
      openCustomDialog(context, 'Only Admin can update settings', '');
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final ab = context.read<AdsBloc>();
      rewardAdpointsCtlr.text = ab.rewardAdPoint.toString();
      context.read<AdsBloc>().getAdsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AdsBloc ab = context.watch<AdsBloc>();
    double width = Responsive.isDesktop(context)
        ? MediaQuery.of(context).size.width * 0.60
        : double.infinity;
    return Scaffold(
      body: SingleChildScrollView(
        //padding: EdgeInsets.all(20),
        child: SizedBox(
          width: width,
          child: Form(
            key: formKey,
            child: CardWrapper(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: TopTitle(title: 'Ads Settings'),
                  ),
                  ListTile(
                      title: const Text('Banner Ad'),
                      trailing: Switch(
                        value: ab.isBannerEnabled,
                        onChanged: (bool value) {
                          context.read<AdsBloc>().controlBannerAd(value);
                        },
                      )
                  ),
                  ListTile(
                      title: const Text('Interstitial Ad'),
                      trailing: Switch(
                        value: ab.isInterstitialAdEnabled,
                        onChanged: (bool value) {
                          context.read<AdsBloc>().controlInterstitialAd(value);
                        },
                      )
                  ),
                  ListTile(
                      title: const Text('Rewarded Video Ad'),
                      trailing: Switch(
                        value: ab.isRewardedAdEnabled,
                        onChanged: (bool value) {
                          context.read<AdsBloc>().controlRewardedAd(value);
                        },
                      )
                  ),
                  ListTile(
                    title: const Text('Reward Points for Each video ads'),
                    trailing: _textfield(rewardAdpointsCtlr),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  RoundedLoadingButton(
                    controller: _updateBtnCtlr,
                    height: 50,
                    color: Theme.of(context).primaryColor,
                    elevation: 0,
                    animateOnTap: false,
                    child: const Text('Save Data'),
                    onPressed: ()=> _onUpdatePressed(),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
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
}
