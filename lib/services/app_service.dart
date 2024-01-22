import 'package:app_admin/components/responsive.dart';
import 'package:app_admin/configs/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/toast.dart';

class AppService{
  static int getCrossAxisCount (context){
    if(Responsive.isDesktop(context)){
      return 4;
    }else if(Responsive.isMobile(context)){
      return 1;
    }else{
      return 3;
    }
  }

  static double getChildAspectRatio (context){
    if(Responsive.isDesktop(context)){
      return 1.8;
    }else if(Responsive.isMobile(context)){
      return 2.9;
    }else{
      return 2.0;
    }
  }

  static String getQuestionOrder(String? questionOrderString){
    if(questionOrderString == null || questionOrderString == Constants.questionOrders[1]){
      return 'ascending';
    }else if (questionOrderString == Constants.questionOrders[2]){
      return 'descending';
    }else{
      return 'random';
    }
  }

  static String setQuestionOrderString(String? questionOrder){
    if(questionOrder == null || questionOrder == 'ascending'){
      return Constants.questionOrders[1];
    }else if (questionOrder == 'descending'){
      return Constants.questionOrders[2];
    }else{
      return Constants.questionOrders[0];
    }
  }

  static String getQuizOrder(String? quizOrderString){
    if(quizOrderString == null || quizOrderString == Constants.quizOrders[1]){
      return 'count';
    }else if (quizOrderString == Constants.quizOrders[2]){
      return 'descending';
    }else if (quizOrderString == Constants.quizOrders[3]){
      return 'ascending';
    }else{
      return 'random';
    }
  }

  static String setQuizOrderString(String? quizOrder){
    if(quizOrder == null || quizOrder == 'count'){
      return Constants.quizOrders[1];
    }else if (quizOrder == 'descending'){
      return Constants.quizOrders[2];
    }else if(quizOrder == 'ascending'){
      return Constants.quizOrders[3];
    }else{
      return Constants.quizOrders[0];
    }
  }

  Future<XFile?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery, maxHeight: 600, maxWidth: 1000);
    return image;
  }

  Future<FilePickerResult?> pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowedExtensions: ['mp3', 'wav'],
      type: FileType.custom
    );
    return result;
  }

  static bool isURLValid (String url){
    return Uri.parse(url).isAbsolute;
  }

  Future openLink(context, String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      launchUrl(uri);
    } else {
      openToast("Can't launch the url", context);
    }
  }
  
}