import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettingsBloc extends ChangeNotifier{

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  int _correctAnsReward = 0;
  int get correctAnsReward => _correctAnsReward;

  int _incorrectAnsPenalty = 0;
  int get incorrectAnsPenalty => _incorrectAnsPenalty;

  int _requiredPointsPlaySelfChallengeMode = 0;
  int get requiredPointsPlaySelfChallengeMode => _requiredPointsPlaySelfChallengeMode;

  int _initalRewardToNewUser = 0;
  int get initialRewardToNewUser => _initalRewardToNewUser;

  bool _selfChallengeModeEnabled = true;
  bool get selfChallengeModeEnabled => _selfChallengeModeEnabled;


  Future getSettingsData ()async{
    DocumentSnapshot snap = await firestore.collection('settings').doc('points').get();
    if(snap.exists){
      _correctAnsReward = snap.get('correct_ans_reward') ?? 0;
      _incorrectAnsPenalty = snap.get('incorrect_ans_penalty') ?? 0;
      _requiredPointsPlaySelfChallengeMode = snap.get('points_req_self_chl_mode') ?? 0;
      _initalRewardToNewUser = snap.get('new_user_reward') ?? 0;
      _selfChallengeModeEnabled = snap.get('self_challenge_mode') ?? true;

    }else{
      await firestore.collection('settings').doc('points').set({
        'correct_ans_reward': 0,
        'incorrect_ans_penalty': 0,
        'points_req_self_chl_mode': 0,
        'new_user_reward': 50,
        'self_challenge_mode': true,
      });
    }

    debugPrint('settings data got');
    notifyListeners();
  }


  Future updateSettingsData (context, int reward, int penalty, int selfChallengeReq, int newUserReward) async{
    await firestore.collection('settings').doc('points').update({
      'correct_ans_reward': reward,
      'incorrect_ans_penalty': penalty,
      'points_req_self_chl_mode': selfChallengeReq,
      'new_user_reward': newUserReward,
      'self_challenge_mode': _selfChallengeModeEnabled
    }).then((_){
      _correctAnsReward = reward;
      _incorrectAnsPenalty = penalty;
      _requiredPointsPlaySelfChallengeMode = selfChallengeReq;
      _initalRewardToNewUser = newUserReward;
      _selfChallengeModeEnabled = _selfChallengeModeEnabled;
      notifyListeners();
    });
  }


  controlSelfChallengeMode (bool value){
    _selfChallengeModeEnabled = value;
    notifyListeners();
  }


}