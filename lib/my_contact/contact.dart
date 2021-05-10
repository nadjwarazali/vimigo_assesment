import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'contact_list.dart';
import 'contact_list.dart';
import 'contact_model.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'contact_model.dart';
import 'contact_model.dart';


class ContactWithList extends StatefulWidget {
  final Contact contact;

  const ContactWithList({Key key, this.contact}) : super(key: key);

  @override
  _ContactWithListState createState() => _ContactWithListState();
}

class _ContactWithListState extends State<ContactWithList> {
  bool isSwitched = true;

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
                setState(() {
                  contacts
                      .map((Contact contacts) => Card(
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(contacts.user, style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                          Text(toggleSwitch(isSwitched, contacts)),
                        ],
                      ),
                      subtitle: Text("0" + contacts.phone.toString()),
                      onTap: () => share(context, contacts),
                    ),
                  )).toList();
                  contacts.sort((a,b) => b.checkIn.compareTo(a.checkIn));
                });
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          // child: _buildInboxList(context, contacts)
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "My Contacts",style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                ), textAlign: TextAlign.left,
                )
              ),
              SizedBox(height: 20 / 4),
              Divider(),
              Column(
                  children: contacts
                      .map((Contact contacts) => Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 0.05))
                    ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(contacts.user, style: TextStyle(
                                      color: Colors.purple,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18)),
                                  Text(toggleSwitch(isSwitched, contacts),  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14)),
                                ],
                              ),
                            ),
                            subtitle: Text("0" + contacts.phone.toString(), style: TextStyle(
                                color: Colors.grey,

                                fontSize: 16)),
                            onTap: () => share(context, contacts),
                          ),
                        ),
                      ))
                      .toList()

              ),
            ],
          ),
        ));
  }


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
}
