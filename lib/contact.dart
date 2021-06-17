import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:vimigo_assessment/contact_list.dart';
import 'package:vimigo_assessment/widget/loading_widget.dart';
import 'package:vimigo_assessment/widget/pullToRefresh_widget.dart';
import 'package:vimigo_assessment/widget/search_widget.dart';
import 'package:vimigo_assessment/widget/title_widget.dart';
import 'contact_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyContacts extends StatefulWidget {
  final Contact contact;

  const MyContacts({Key key, this.contact}) : super(key: key);

  @override
  _MyContactsState createState() => _MyContactsState();
}

class _MyContactsState extends State<MyContacts> {
  bool isSwitched = false;
  List<Contact> contacts = [];
  String query = '';
  int newItemCount = 15;
  Future loading;

  @override
  void initState() {
    super.initState();
    contacts = allContacts;
    loading = _buildFuture();
    getSwitchValue();
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Future<void> _buildFuture() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    print("future");
  }

  getSwitchValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isSwitched = prefs.getBool('isSwitched') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      body: _buildBody(),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      actions: [
        Switch.adaptive(
            activeColor: Colors.purple,
            value: isSwitched,
            onChanged: (value) => setState(() => this.isSwitched = value)),
        IconButton(
            icon: Icon(Icons.sort, color: Colors.purple),
            onPressed: () {
              sortContact(context);
            }),
      ],
    );
  }

  Widget _buildBody() {
    return LoadingWidget(
      future:loading,
      child: PullToRefreshWidget(
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child:  _buildContactList(),
      ),
    );
  }

  Widget _buildContactList() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleWidget(titleText: "My Contacts"),
          SearchWidget(
            text: query,
            hintText: 'Search',
            onChanged: searchContact,
          ),
          ListView.builder(
            primary: false,
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: newItemCount,
            itemBuilder: (context, index) => ContactList(
              contact: contacts[index],
              isSwitched: this.isSwitched,
            ),
            itemExtent: 100.00,
          ),
        ],
      ),
    );
  }

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      if (newItemCount < contacts.length) {
        newItemCount = newItemCount + 15;
      } else {
        print("no item left");
      }
    });

    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    if (mounted)
      setState(() {
        if (newItemCount < contacts.length) {
          newItemCount = newItemCount + 15;
        } else {
          print("no item left");
        }
      });
    _refreshController.loadComplete();
  }

  void searchContact(String query) {
    final contacts = allContacts.where((contact) {
      final userLower = contact.user.toLowerCase();
      final searchLower = query.toLowerCase();

      return userLower.startsWith(searchLower);
    }).toList();

    setState(() {
      newItemCount = contacts.length;
      this.query = query;
      this.contacts = contacts;
    });
  }

void sortContact(BuildContext context) {
  return setState(() {
    allContacts
        .map((Contact contacts) => ContactList())
        .toList();
    allContacts.sort((a, b) => b.checkIn.compareTo(a.checkIn));
  });
}
}
