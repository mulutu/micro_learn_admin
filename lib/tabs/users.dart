import 'package:app_admin/components/card_wrapper.dart';
import 'package:app_admin/components/responsive.dart';
import 'package:app_admin/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components/user_data_source.dart';

class Users extends StatefulWidget {
  const Users({Key? key}) : super(key: key);

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collectionName = 'users';
  final int _itemPerPage = 11;

  final _searchCtlr = TextEditingController();
  late Query<Map<String, dynamic>> query;

  
  String? _sortByText;

  @override
  void initState() {
    _sortByText = 'Newest First';
    query = firestore.collection(collectionName).orderBy('created_at', descending: true);
    super.initState();
  }

  final List<DataColumn> _columns = const [
    DataColumn(
      label: Text('Name'),
    ),
    DataColumn(
      label: Text('Points'),
    ),
    DataColumn(
      label: Text('Strength'),
    ),
    DataColumn(
      label: Text('Email'),
    ),
    DataColumn(
      label: Text('User Access'),
    ),
    DataColumn(
      label: Text('Role'),
    ),
    DataColumn(
      label: Text('Actions'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CardWrapper(
        child: FirestoreQueryBuilder<Map<String, dynamic>>(
          pageSize: _itemPerPage,
          query: query,
          builder: (context, snapshot, _) {
            List<UserModel> users = [];
            users = snapshot.docs.map((e) => UserModel.fromFirestore(e)).toList();
            DataTableSource source = UsersDataSource(users, context);
      
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PaginatedDataTable2(
                  rowsPerPage: _itemPerPage - 1,
                  source: source,
                  header: Text('All Users', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                  empty: const Center(child: Text('No Users Found')),
                  minWidth: 1200,
                  wrapInCard: false,
                  horizontalMargin: 20,
                  columnSpacing: 20,
                  fit: FlexFit.tight,

                  dataRowHeight: Responsive.isMobile(context) ? 90 : 65,
                  actions: [
                    Visibility(
                      visible: !Responsive.isMobile(context),
                      child: _serachBox()),
                    _sortButton(),
                  ],
                  onPageChanged: (_) => snapshot.fetchMore(),
                  columns: _columns),
            );
          },
        ),
      ),
    );
  }


  Widget _serachBox (){
    return SizedBox(
      height: 40,
      width: 250,
      child: TextField(
      controller: _searchCtlr,
      decoration: InputDecoration(
        hintText: 'Search by name',
        contentPadding: const EdgeInsets.only(left: 10, right: 10),
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: (){
            _searchCtlr.clear();
            setState(() {
              _sortByText = 'Newest First';
              query = firestore.collection(collectionName).orderBy('created_at', descending: true);
            });
          },
        )
      ),
      onSubmitted: (String value){
        if(value.isNotEmpty){
          setState(() {
            _sortByText = 'None';
            query = firestore.collection(collectionName).orderBy('name').startAt([_searchCtlr.text]).endAt(['${_searchCtlr.text}\uf8ff']);
          });
        }
      },
    )
    );
  }

  Widget _sortButton() {
    return PopupMenuButton(
      child: Container(
        height: 40,
        padding: const EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(30)),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.sort_down,
              color: Colors.grey[800],
            ),
            Visibility(
              visible: !Responsive.isMobile(context),
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Sort By - $_sortByText',
                    style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem>[
          const PopupMenuItem(
            value: 'new',
            child: Text('Newest First'),
          ),
          const PopupMenuItem(
            value: 'old',
            child: Text('Oldest First'),
          ),
          const PopupMenuItem(
            value: 'top',
            child: Text('Top Rank'),
          ),
          const PopupMenuItem(
            value: 'low',
            child: Text('Low Rank'),
          ),
          const PopupMenuItem(
            value: 'disabled',
            child: Text('Disabled'),
          ),
          const PopupMenuItem(
            value: 'admin',
            child: Text('Admins'),
          ),
          const PopupMenuItem(
            value: 'editor',
            child: Text('Editors'),
          ),
        ];
      },
      onSelected: (dynamic value) {
        if (value == 'new') {
          setState(() {
            _sortByText = 'Newest First';
            query = firestore.collection(collectionName).orderBy('created_at', descending: true);
          });
        } else if (value == 'old') {
          setState(() {
            _sortByText = 'Oldest First';
            query = firestore.collection(collectionName).orderBy('created_at', descending: false);
          });
        } else if (value == 'top') {
          setState(() {
            _sortByText = 'Top Ranks';
            query = firestore.collection(collectionName).orderBy('points', descending: true);
          });
        } else if (value == 'low') {
          setState(() {
            _sortByText = 'Low Rank';
            query = firestore.collection(collectionName).orderBy('points', descending: false);
          });
        } else if (value == 'disabled') {
          setState(() {
            _sortByText = 'Disabled';
            query = firestore.collection(collectionName).where('disabled', isEqualTo: true);
          });
        } else if (value == 'admin') {
          setState(() {
            _sortByText = 'Admins';
            query = firestore.collection(collectionName).where('role', arrayContains: 'admin');
          });
        } else if (value == 'editor') {
          setState(() {
            _sortByText = 'Editors';
            query = firestore.collection(collectionName).where('role', arrayContains: 'editor');
          });
        }
      },
    );
  }
}


