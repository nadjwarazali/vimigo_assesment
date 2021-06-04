import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:vimigo_assessment/my_contact/search_widget.dart';
import 'contact_model.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/cupertino.dart';

class ContactWithList extends StatefulWidget {
  final Contact contact;

  const ContactWithList({Key key, this.contact}) : super(key: key);

  @override
  _ContactWithListState createState() => _ContactWithListState();
}

class _ContactWithListState extends State<ContactWithList> {
  bool isSwitched = true;
  List<Contact> contacts = [];
  String query = '';
  GlobalKey<RefreshIndicatorState> refreshKey;
  int itemCount = 15;

  @override
  void initState() {
    super.initState();
    contacts = allContacts;
    refreshKey = GlobalKey<RefreshIndicatorState>();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            buildSwitchListTile(),
            IconButton(
                icon: Icon(Icons.sort, color: Colors.purple),
                onPressed: () {
                  sortContact(context);
                }),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "My Contacts",
                  style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                  textAlign: TextAlign.left,
                )),
            SizedBox(height: 20 / 4),
            _buildSearch(),
            _buildContactList(itemCount)
          ],
        ));
  }

  void sortContact(BuildContext context) {
    return setState(() {
      allContacts
          .map((Contact contacts) => Card(
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(contacts.user,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Text(toggleSwitch(isSwitched, contacts)),
                    ],
                  ),
                  subtitle: Text("0" + contacts.phone.toString()),
                  onTap: () => share(context, contacts),
                ),
              ))
          .toList();
      allContacts.sort((a, b) => b.checkIn.compareTo(a.checkIn));
    });
  }

  Widget _buildSearch() => SearchWidget(
        text: query,
        hintText: 'Search',
        onChanged: searchContact,
      );

  void searchContact(String query) {
    final contacts = allContacts.where((contact) {
      final userLower = contact.user.toLowerCase();
      final phoneLower = contact.phone.toString().toLowerCase();
      final searchLower = query.toLowerCase();

      return userLower.startsWith(searchLower) ||
          phoneLower.startsWith(searchLower);
    }).toList();

    setState(() {
      this.query = query;
      this.contacts = contacts;
    });
  }

  Widget _buildContactList(int itemCount) => Expanded(
          child: RefreshIndicator(
        key: refreshKey,
        onRefresh: () async {
          await refreshList();
        },
        child: ReorderableListView.builder(
            // scrollController: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: itemCount,
            onReorder: (oldIndex, newIndex) => setState(() {
                  final index = newIndex > oldIndex ? newIndex - 1 : newIndex;
                  final contact = contacts.removeAt(oldIndex);
                  contacts.insert(index, contact);
                }
                ),
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return buildContact(index, contact);
            }
            ),
      ));

  Widget buildContact(int index, Contact contact) => ListTile(
        key: ValueKey(contact),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(contact.user,
                  style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.w600,
                      fontSize: 18)),
              Text(toggleSwitch(isSwitched, contact),
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ),
        subtitle: Text("0" + contact.phone.toString(),
            style: TextStyle(color: Colors.grey, fontSize: 16)),
        onTap: () => share(context, contact),
      );

  void share(BuildContext context, Contact contact) {
    final RenderBox box = context.findRenderObject();
    final String text = "${contact.user}";

    Share.share(text,
        subject: contact.phone.toString(),
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  Widget buildSwitchListTile() {
    return Switch.adaptive(
        activeColor: Colors.purple,
        value: isSwitched,
        onChanged: (value) => setState(() => this.isSwitched = value));
  }

  // ignore: missing_return
  String toggleSwitch(bool value, Contact contacts) {
    String normal = DateFormat.yMd().add_jm().format(contacts.checkIn);
    String formatted = timeago.format(contacts.checkIn);

    if (isSwitched == false) {
      return formatted;
    } else {
      return normal;
    }
  }

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      itemCount = itemCount + 15;

    });

    return _buildContactList(itemCount);

  }
}
