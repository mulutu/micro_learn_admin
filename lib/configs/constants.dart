class Constants {

  //Do not edit theses

  //subdcription topics for firebase push notifications
  static const String fcmSubscriptionTopicForAllUsers = 'all';
  static const String fcmSubscriptionTopicForRegularUsers = 'regular';
  static const String fcmSubscriptionTopicForPremiumUsers = 'premium';

  //Question Orders
  static const List<String> questionOrders = [
    'Random',
    'Oldest First',
    'Newest First',
  ];

  //Quiz Orders
  static const List<String> quizOrders = [
    'Random',
    'Most Question',
    'Oldest First',
    'Newest First',
  ];

  //Question Types
  static const Map<String, String> questionTypes = {
    "text_only": "Text Only",
    "text_with_image": "Image",
    "text_with_audio": "Audio",
    "text_with_video": "Video",
  };

  //Option Types
  static const Map<String, String> optionTypes = {
    "text_only": "Text Only",
    "t/f": "True/False",
    "image": "Images"
  };
}