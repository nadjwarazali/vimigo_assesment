import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share/share.dart';
import 'package:vimigo_assessment/search_widget.dart';
import 'contact_model.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: _buildLoadingIndicator());
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      actions: [
        buildSwitchListTile(),
        IconButton(
            icon: Icon(Icons.sort, color: Colors.purple),
            onPressed: () {
              // sortContact(context);
            }),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return FutureBuilder(
      future: loading,
      builder: (context, dataSnapshot) {
        if (dataSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (dataSnapshot.error != null) {
            return Center(
              child: Text('An error occured'),
            );
          } else {
            print("build");
            return _buildPullToRefresh();
          }
        }
      },
    );
  }

  Widget _buildTitle() {
    return Padding(
        padding: EdgeInsets.only(left: 20, top: 40),
        child: Text(
          "My Contacts",
          style: TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
            fontSize: 40,
          ),
          textAlign: TextAlign.left,
        ));
  }

  Future<void> _buildFuture() async {
    await Future.delayed(const Duration(seconds: 5));
    print("future");
  }

  Widget _buildPullToRefresh() => Container(
        height: MediaQuery.of(context).size.height,
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: WaterDropHeader(),
          footer: CustomFooter(
            builder: (BuildContext context, LoadStatus mode) {
              Widget body;
              if (mode == LoadStatus.idle) {
                body = Text("No item left");
              } else if (mode == LoadStatus.loading) {
                body = CupertinoActivityIndicator();
              } else if (mode == LoadStatus.failed) {
                body = Text("Load Failed!Click retry!");
              } else if (mode == LoadStatus.canLoading) {
                body = Text("release to load more");
              } else {
                body = Text("No more Data");
              }
              return Container(
                height: 55.0,
                child: Center(child: body),
              );
            },
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: _buildContactList(),
        ),
      );

  Widget _buildContactList() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          _buildSearch(),
          ListView.builder(
            primary: false,
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: newItemCount,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return buildContact(index, contact);
            },
            itemExtent: 100.00,
          ),
        ],
      ),
    );
  }

  Widget buildContact(int index, Contact contact) => Column(
        children: [
          ListTile(
            key: ValueKey(contact),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(contact.user,
                    style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.w600,
                        fontSize: 18)),
                Text(toggleSwitch(contact),
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
            subtitle: Text("0" + contact.phone.toString(),
                style: TextStyle(color: Colors.grey, fontSize: 16)),
            onTap: () => share(context, contact),
          ),
          Divider()
        ],
      );

  Widget buildSwitchListTile() {
    return Switch.adaptive(
        activeColor: Colors.purple,
        value: isSwitched,
        onChanged: (value) => setState(() => this.isSwitched = value));
  }

  String toggleSwitch(Contact contact) {
    String normal = DateFormat.yMd().add_jm().format(contact.checkIn);
    String formatted = timeago.format(contact.checkIn);

    if (isSwitched == false) {
      setSwitchValue(false);
      return formatted;
    } else {
      setSwitchValue(true);
      return normal;
    }
  }

  setSwitchValue(bool isSwitched) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isSwitched', isSwitched);
  }

  getSwitchValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    isSwitched = prefs.getBool('isSwitched') ?? false;

  }

  // void sortContact(BuildContext context) {
  //   return setState(() {
  //     allContacts
  //         .map((Contact contacts) => Card(
  //               child: ListTile(
  //                 title: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Text(contacts.user,
  //                         style: TextStyle(
  //                             color: Colors.black,
  //                             fontWeight: FontWeight.bold,
  //                             fontSize: 16)),
  //                     Text(toggleSwitch(isSwitched, contacts)),
  //                   ],
  //                 ),
  //                 subtitle: Text("0" + contacts.phone.toString()),
  //                 onTap: () => share(context, contacts),
  //               ),
  //             ))
  //         .toList();
  //     allContacts.sort((a, b) => b.checkIn.compareTo(a.checkIn));
  //   });
  // }

  Widget _buildSearch() => SearchWidget(
        text: query,
        hintText: 'Search',
        onChanged: searchContact,
      );

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

  void share(BuildContext context, Contact contact) {
    final RenderBox box = context.findRenderObject();
    final String text = "${contact.user}";

    Share.share(text,
        subject: contact.phone.toString(),
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }
}
