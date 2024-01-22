import 'package:app_admin/services/sp_service.dart';
import 'package:flutter/material.dart';

class AdminBloc extends ChangeNotifier{

  AdminBloc (){
    checkUserRole();
  }

  String? _userRole;
  String? get userRole => _userRole;



  checkUserRole ()async{
    await SPService().getUserRole().then((String role){
      _userRole = role;
      debugPrint('USER ROLE: $role');
      notifyListeners();
    });
  }


  setUserRole (String role) async{
    await SPService().setUserType(role);
    _userRole = role;
    notifyListeners();
  }

  Future clearLocalData ()async{
    await SPService().clearUserType();
    _userRole = null;
    notifyListeners();
  }

}