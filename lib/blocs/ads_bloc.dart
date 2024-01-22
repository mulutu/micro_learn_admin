import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdsBloc extends ChangeNotifier{

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool _isBannerEnabled = false;
  bool get isBannerEnabled => _isBannerEnabled;

  bool _isInterstitialAdEnabled = false;
  bool get isInterstitialAdEnabled => _isInterstitialAdEnabled;

  bool _isRewardedAdEnabled = false;
  bool get isRewardedAdEnabled => _isRewardedAdEnabled;

  int _rewardAdsPoint = 0;
  int get rewardAdPoint => _rewardAdsPoint;


  Future getAdsData () async {
    await firestore.collection('settings').doc('ads').get()
    .then((value)async{
      if(value.exists){
        _isBannerEnabled = value['banner_ad'] ?? false;
        _isInterstitialAdEnabled = value['interstitial_ad'] ?? false;
        _isRewardedAdEnabled = value['rewarded_ad'] ?? false;
        _rewardAdsPoint = value['reward_ad_points'] ?? 0;
      }else{
        await firestore.collection('settings').doc('ads')
        .set({
          'banner_ad' : false,
          'interstitial_ad' : false,
          'rewarded_ad': false,
          'reward_ad_points': 20,
        });
      }
    });
    debugPrint('banner : $_isBannerEnabled, interstitial : $_isInterstitialAdEnabled, rewarded: $_isRewardedAdEnabled');
    notifyListeners();
  }

  Future updateAdSettings (int newRewardAdsPoint)async{
    await firestore.collection('settings').doc('ads').update({
      'banner_ad' : _isBannerEnabled,
      'interstitial_ad' : _isInterstitialAdEnabled,
      'rewarded_ad': _isRewardedAdEnabled,
      'reward_ad_points': newRewardAdsPoint,
    }).then((_){
      _isBannerEnabled =_isBannerEnabled;
      _isInterstitialAdEnabled = _isInterstitialAdEnabled;
      _isRewardedAdEnabled = _isRewardedAdEnabled;
      _rewardAdsPoint = newRewardAdsPoint;
      notifyListeners();
    });
  }

  controlBannerAd (bool value){
    _isBannerEnabled = value;
    notifyListeners();
  }

  controlInterstitialAd (bool value){
    _isInterstitialAdEnabled = value;
    notifyListeners();
  }
  controlRewardedAd (bool value){
    _isRewardedAdEnabled = value;
    notifyListeners();
  }
}