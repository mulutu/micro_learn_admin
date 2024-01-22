import 'package:app_admin/components/top_title.dart';
import 'package:app_admin/configs/config.dart';
import 'package:app_admin/models/category.dart';
import 'package:app_admin/services/app_service.dart';
import 'package:app_admin/services/firebase_service.dart';
import 'package:app_admin/utils/custom_dialog.dart';
import 'package:app_admin/utils/loading_animation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../blocs/admin_bloc.dart';
import '../utils/cached_image_filter.dart';

class FeaturedCategories extends StatefulWidget {
  const FeaturedCategories({Key? key}) : super(key: key);

  @override
  State<FeaturedCategories> createState() => _FeaturedCategoriesState();
}

class _FeaturedCategoriesState extends State<FeaturedCategories> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final String collectionName = 'categories';
  final _deleteBtnCtlr = RoundedLoadingButtonController();
  late Query<Map<String, dynamic>> _query;

  Future _onDelete(Category d) async {
    await FirebaseService().removeCategoryFromFeatured(d.id!);
    await FirebaseService().decreaseCount('featured_category_count', null);
  }

  _handleDelete(Category d) async {
    String? userRole = context.read<AdminBloc>().userRole;
    final bool hasAccess = userRole != null && userRole == 'admin' || userRole == 'editor';
    if (hasAccess) {
      _deleteBtnCtlr.start();
      await _onDelete(d).then((value) => Navigator.pop(context)).then((value) {
        _deleteBtnCtlr.success();
        openCustomDialog(context, 'Removed Successfully!', '');
      });
    } else {
      openCustomDialog(context, Config.testingDialog, '');
    }
  }

  @override
  void initState() {
    super.initState();
    _query = firestore.collection(collectionName).where('featured', isEqualTo: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10),
              child: TopTitle(title: 'Featured Categories'),
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
                  return const Center(child: Text('No categories found found!'));
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
                          padding: const EdgeInsets.all(25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                  child: const CircleAvatar(
                                    radius: 18,
                                    child: Icon(
                                      Icons.clear,
                                      size: 18,
                                    ),
                                  ),
                                  onTap: () => _openRemoveFeaturedDialog(context, d)),
                            ],
                          ),
                        ),
                        child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                            child: CustomCacheImageWithDarkFilterBottom(imageUrl: d.thumbnailUrl.toString(), radius: 10),
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
      ),
    );
  }

  void _openRemoveFeaturedDialog(context, Category d) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.all(50),
            elevation: 0,
            children: <Widget>[
              const Text('Remove from featured?', style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(
                height: 10,
              ),
              Text('Do you want to remove this quiz from the featured section?',
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
                    onPressed: () => _handleDelete(d),
                    child: const Text(
                      'Yes',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
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
