import 'package:app_admin/models/quiz.dart';
import 'package:app_admin/models/sp_category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/category.dart';

class FirebaseService {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<int> getTotalDocuments (String documentName) async {
    const String fieldName = 'count';
    final DocumentReference ref = firestore.collection('item_count').doc(documentName);
      DocumentSnapshot snap = await ref.get();
      if(snap.exists == true){
        int itemCount = snap[fieldName] ?? 0;
        return itemCount;
      }
      else{
        await ref.set({
          fieldName : 0
        });
        return 0;
      }
  }

  Future increaseCount (String documentName, int? itemSize) async {
    final int size = itemSize ?? 1;
    await getTotalDocuments(documentName)
    .then((int documentCount)async {
      await firestore.collection('item_count')
      .doc(documentName)
      .update({
        'count' : documentCount + size
      });
    });
  }



  Future decreaseCount (String documentName, int? itemSize) async {
    int size = itemSize ?? 1;
    await getTotalDocuments(documentName)
    .then((int documentCount)async {
      await firestore.collection('item_count')
      .doc(documentName)
      .update({
        'count' : documentCount - size
      });
    });
  }



  Future deleteContent(String collectionName, String documentName) async {
    await firestore.collection(collectionName).doc(documentName).delete();
  }

  Future<String?> getCategoryName (String catId) async {
    String? categoryName;
    await firestore.collection('categories').doc(catId).get().then((DocumentSnapshot snap){
      categoryName = snap['name'];
    });
    return categoryName;
    
  }

  Future<String?> getQuizName (String quizId) async {
    String? quizName;
    await firestore.collection('quizes').doc(quizId).get().then((DocumentSnapshot snap){
      quizName = snap['name'];
    });
    return quizName;
    
  }


  Future increaseQuestionCountInQuiz (String quizId, int? itemSize) async {
    final int size = itemSize ?? 1;
    await firestore.collection('quizes').doc(quizId).get().then((DocumentSnapshot snap)async{
      int count = snap.get('question_count') ?? 0;
      await firestore.collection('quizes').doc(quizId).update({
        'question_count': count + size
      });
    });
  }

  Future decreaseQuestionCountInQuiz (String quizId) async {
    await firestore.collection('quizes').doc(quizId).get().then((DocumentSnapshot snap)async{
      int count = snap.get('question_count') ?? 0;
      await firestore.collection('quizes').doc(quizId).update({
        'question_count': count - 1
      });
    });
  }

  Future increaseQuizCountInCategory (String categoryId) async {
    await firestore.collection('categories').doc(categoryId).get().then((DocumentSnapshot snap)async{
      int count = snap.get('quiz_count') ?? 0;
      await firestore.collection('categories').doc(categoryId).update({
        'quiz_count': count + 1
      });
    });
  }

  Future decreaseQuizCountInCategory (String categoryId) async {
    await firestore.collection('categories').doc(categoryId).get().then((DocumentSnapshot snap)async{
      int count = snap.get('quiz_count') ?? 0;
      await firestore.collection('categories').doc(categoryId).update({
        'quiz_count': count - 1
      });
    });
  }



  Future removeQuizFromFeatured(String documentName) async {
    return firestore.collection('quizes').doc(documentName).update({
      'featured': false
    });
  }

  Future addQuizToFeatured(String documentName) async {
    return firestore.collection('quizes').doc(documentName).update({
      'featured': true
    });
  }

  Future deleteRelatedQuizesAndQuestions (String catId)async{
    WriteBatch batch = firestore.batch();
    await firestore.collection('quizes').where('parent_id', isEqualTo: catId).get().then((QuerySnapshot snapshot)async{
      if(snapshot.size != 0){
        // ignore: avoid_function_literals_in_foreach_calls
        snapshot.docs.forEach((doc)async{
          batch.delete(doc.reference);
          await deleteRelatedQuestionsAssociatedWithQuiz(doc.id);
        });
        await decreaseCount('quizes_count', snapshot.size);
        return batch.commit();
      }
    });
  }

  Future deleteRelatedQuestionsAssociatedWithQuiz (String quizId)async{
    WriteBatch batch = firestore.batch();
    await firestore.collection('questions').where('quiz_id', isEqualTo: quizId).get().then((QuerySnapshot snapshot)async{
      if(snapshot.size != 0){

        // ignore: avoid_function_literals_in_foreach_calls
        snapshot.docs.forEach((doc) => batch.delete(doc.reference));
        await decreaseCount('questions_count', snapshot.size);
        return batch.commit();   
      }
    });
  }

  Future<List<Category>> getCategories() async {
    List<Category> data = [];
    await firestore.collection('categories').get().then((QuerySnapshot? snapshot){
      data = snapshot!.docs.map((e) => Category.fromFirestore(e)).toList();
    });
    return data;
  }

  Future<List<Quiz>> getQuizes() async {
    List<Quiz> data = [];
    await firestore.collection('quizes').get().then((QuerySnapshot? snapshot){
      data = snapshot!.docs.map((e) => Quiz.fromFirestore(e)).toList();
    });
    return data;
  }

  Future<List<Quiz>> getCategoryBasedQuizes(String catId) async {
    List<Quiz> data = [];
    await firestore.collection('quizes').where('parent_id', isEqualTo: catId).get().then((QuerySnapshot? snapshot){
      data = snapshot!.docs.map((e) => Quiz.fromFirestore(e)).toList();
    });
    return data;
  }


  Future updateUserAccess (String userId, bool isDisabled) async{
    return await firestore.collection('users').doc(userId).update({'disabled': isDisabled });
  }

  Future removeEditorAccess (String userId) async{
    return await firestore.collection('users').doc(userId).set({'role': null}, SetOptions(merge: true));
  }

  Future assignEditorAccess (String userId) async{
    return await firestore.collection('users').doc(userId).set({'role': ['editor']}, SetOptions(merge: true));
  }

  Future removeCategoryFromFeatured(String documentName) async {
    return firestore.collection('categories').doc(documentName).update({
      'featured': false
    });
  }

  Future addCategoryToFeatured(String documentName) async {
    return firestore.collection('categories').doc(documentName).update({
      'featured': true
    });
  }

  Future<SpecialCategory> getSpecialCategory () async{
    SpecialCategory specialCategory;
    final DocumentReference ref = firestore.collection('settings').doc('special_categories');
    DocumentSnapshot snapshot = await ref.get();
    if(snapshot.exists){
      debugPrint('true');
      specialCategory = SpecialCategory.fromFirestore(snapshot);
    }else{
      debugPrint('false');
      specialCategory = SpecialCategory(enabled: false, id1: null, id2: null);
    }
    debugPrint(specialCategory.id2);
    return specialCategory;
  }

  Future saveSpecialCategory (SpecialCategory specialCategory) async{
    Map<String, dynamic> data = SpecialCategory.getMap(specialCategory);
    final DocumentReference ref = firestore.collection('settings').doc('special_categories');
    DocumentSnapshot snapshot = await ref.get();
    if(snapshot.exists){
      debugPrint('true');
      await ref.update(data);
    }else{
      debugPrint('false');
      await ref.set(data);
    }
  }

  Future<String> uploadImageToFirebaseHosting(XFile image, String folderName) async {
    //return download link
    Uint8List imageData = await XFile(image.path).readAsBytes();
    final Reference storageReference = FirebaseStorage.instance.ref().child('$folderName/${image.name}.png');
    final SettableMetadata metadata = SettableMetadata(contentType: 'image/png');
    final UploadTask uploadTask = storageReference.putData(imageData, metadata);
    final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    String imageUrl = await snapshot.ref.getDownloadURL();
    return imageUrl;
  }

  Future updateUserPoints (String userId, int newPoints)async{
    final docRef = firestore.collection("users").doc(userId);
    return await docRef.update({
      'points': newPoints
    }); 
  }

  Future<bool> checkVerificationInfo () async{
    final DocumentReference ref = firestore.collection('settings').doc('info');
    DocumentSnapshot snapshot = await ref.get();
    if(snapshot.exists){
      bool valid = snapshot['valid'] ?? false;
      return valid;
    }else{
      return false;
    }
  }

  Future saveVerificationInfo () async{
    final DocumentReference ref = firestore.collection('settings').doc('info');
    await ref.set({'valid': true});
  }


}