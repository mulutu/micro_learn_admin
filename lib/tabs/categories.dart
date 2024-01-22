import 'package:app_admin/components/responsive.dart';
import 'package:app_admin/components/top_title.dart';
import 'package:app_admin/configs/config.dart';
import 'package:app_admin/models/category.dart';
import 'package:app_admin/services/app_service.dart';
import 'package:app_admin/services/firebase_service.dart';
import 'package:app_admin/utils/cached_image_filter.dart';
import 'package:app_admin/utils/custom_dialog.dart';
import 'package:app_admin/utils/loading_animation.dart';
import 'package:app_admin/utils/next_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../blocs/admin_bloc.dart';
import '../forms/category_form.dart';
import '../utils/styles.dart';

class Categories extends StatefulWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final String collectionName = 'categories';
  final _deleteBtnCtlr = RoundedLoadingButtonController();
  final _addFeaturedBtnCtlr = RoundedLoadingButtonController();
  late Query<Map<String, dynamic>> _query;

  @override
  void initState() {
    _query = firestore.collection('categories');
    super.initState();
  }


  _onEditPressed(Category category) {
    if (Responsive.isMobile(context)) {
      NextScreen().nextScreenPopup(context, CategoryForm(category: category));
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: CategoryForm(
                category: category,
              ),
            );
          });
    }
  }

  Future _onDelete(Category d) async {
    await FirebaseService().deleteContent(collectionName, d.id!);
    await FirebaseService().deleteRelatedQuizesAndQuestions(d.id!);
    await FirebaseService().decreaseCount('cats_count', null);
  }

  _handleDelete(Category d) async {
    String? userRole = context.read<AdminBloc>().userRole;
    final bool hasAccess = userRole != null && userRole == 'admin' || userRole == 'editor';
    if (hasAccess) {
      _deleteBtnCtlr.start();
      await _onDelete(d).then((value) {
        _deleteBtnCtlr.success();
        Navigator.pop(context);
        openCustomDialog(context, 'Deleted Successfully!', '');
      });
    } else {
      openCustomDialog(context, Config.testingDialog, '');
    }
  }

  _openAddCategoryForm() {
    if (Responsive.isMobile(context)) {
      NextScreen().nextScreenPopup(
          context,
          const CategoryForm(
            category: null,
          ));
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return const Dialog(
              child: CategoryForm(
                category: null,
              ),
            );
          });
    }
  }

  _onAddButtonPressed(Category d) {
    String? userRole = context.read<AdminBloc>().userRole;
    final bool hasAccess = userRole != null && userRole == 'admin' || userRole == 'editor';
    if (hasAccess) {
      _openAddFeaturedDialog(context, d.id!, d);
    } else {
      openCustomDialog(context, Config.testingDialog, '');
    }
  }

  _handleAddToFeatured(String documentName, Category category) async {
    String? userRole = context.read<AdminBloc>().userRole;
    final bool hasAccess = userRole != null && userRole == 'admin';
    if (hasAccess) {
      if (category.featured == false) {
        _addFeaturedBtnCtlr.start();
        await FirebaseService().addCategoryToFeatured(documentName);
        await FirebaseService().increaseCount('featured_category_count', null);
        _addFeaturedBtnCtlr.success();
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        // ignore: use_build_context_synchronously
        openCustomDialog(context, 'Added Successfully', '');
      } else {
        Navigator.pop(context);
        openCustomDialog(context, 'Already Exists!', 'This item is already available in the feature list');
      }
    } else {
      openCustomDialog(context, Config.testingDialog, '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: TopTitle(title: 'Categories'),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: TextButton.icon(
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  label: Text("Add Category",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w500)),
                  style: buttonStyle(Theme.of(context).primaryColor),
                  onPressed: _openAddCategoryForm,
                ),
              ),
            ],
          ),
          FirestoreQueryBuilder<Map<String, dynamic>>(
            query: _query,
            builder: ((context, FirestoreQueryBuilderSnapshot<Map<String, dynamic>> snapshot, _) {
              if (snapshot.isFetching) {
                return const LoadingAnimation();
              }

              if (snapshot.hasError) {
                return Center(child: Text('Something went wrong! ${snapshot.error}'));
              }

              if (snapshot.docs.isEmpty) {
                return const Center(child: Text('No categories found!'));
              }

              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: AppService.getCrossAxisCount(context), childAspectRatio: AppService.getChildAspectRatio(context)),
                itemCount: snapshot.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                    snapshot.fetchMore();
                  }
                  List<Category> catList = snapshot.docs.map((e) => Category.fromFirestore(e)).toList();
                  final Category d = catList[index];
                  return GridTile(
                      header: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                                child: const CircleAvatar(
                                  radius: 18,
                                  child: Icon(
                                    Icons.edit,
                                    size: 18,
                                  ),
                                ),
                                onTap: () => _onEditPressed(d)),
                            const SizedBox(
                              width: 5,
                            ),
                            InkWell(
                                child: const CircleAvatar(
                                  radius: 18,
                                  child: Icon(
                                    Icons.add,
                                    size: 18,
                                  ),
                                ),
                                onTap: () => _onAddButtonPressed(d)),
                            const SizedBox(
                              width: 5,
                            ),
                            InkWell(
                                child: const CircleAvatar(
                                  radius: 18,
                                  child: Icon(
                                    Icons.delete,
                                    size: 18,
                                  ),
                                ),
                                onTap: () => _openDeteleDialog(context, d)),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                            child: CustomCacheImageWithDarkFilterFull(imageUrl: d.thumbnailUrl.toString(), radius: 10),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 30, bottom: 30),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d.name!,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                                  ),
                                  Text(
                                    'Quiz Count: ${d.quizCount}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ));
                },
              );
            }),
          ),
        ],
      ),
    ));
  }

  void _openDeteleDialog(context, Category d) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.all(50),
            elevation: 0,
            children: <Widget>[
              const Text('Delete This Category?', style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(
                height: 10,
              ),
              Text(
                  "Do you want to delete this category and it's contents?\nWarning: All of the quizes and questions included to this category will be deleted too!",
                  style: TextStyle(color: Colors.grey[700], fontSize: 16, fontWeight: FontWeight.w400)),
              const SizedBox(
                height: 30,
              ),
              Center(
                  child: Row(
                children: <Widget>[
                  RoundedLoadingButton(
                    animateOnTap: false,
                    elevation: 0,
                    width: 110,
                    controller: _deleteBtnCtlr,
                    color: Colors.redAccent,
                    onPressed: ()=> _handleDelete(d),
                    child: const Text('Delete', style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold
                    ),),
                  ),
                  const SizedBox(width: 10),
                  RoundedLoadingButton(
                    animateOnTap: false,
                    elevation: 0,
                    width: 110,
                    borderRadius: 20,
                    controller: RoundedLoadingButtonController(),
                    color: Theme.of(context).primaryColor,
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'No',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ))
            ],
          );
        });
  }

  void _openAddFeaturedDialog(context, String documentName, Category category) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.all(50),
            elevation: 0,
            children: <Widget>[
              const Text('Add to featured?', style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(
                height: 10,
              ),
              Text('Do you want to add this category to the featured section?',
                  style: TextStyle(color: Colors.grey[700], fontSize: 15, fontWeight: FontWeight.w400)),
              const SizedBox(
                height: 30,
              ),
              Center(
                  child: Row(
                children: <Widget>[
                  RoundedLoadingButton(
                    animateOnTap: false,
                    elevation: 0,
                    width: 110,
                    controller: _addFeaturedBtnCtlr,
                    color: Theme.of(context).primaryColor,
                    onPressed: ()=> _handleAddToFeatured(documentName, category),
                    child: const Text('Yes', style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold
                    ),),
                  ),
                  const SizedBox(width: 10),
                  RoundedLoadingButton(
                    animateOnTap: false,
                    elevation: 0,
                    width: 110,
                    controller: RoundedLoadingButtonController(),
                    color: Theme.of(context).primaryColor,
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'No',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ))
            ],
          );
        });
  }
}
