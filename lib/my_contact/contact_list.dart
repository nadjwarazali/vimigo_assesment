import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'contact_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class ContactList extends StatefulWidget {
  final Contact contact;
  final Function press;

  ContactList({Key key, this.contact, this.press}) : super(key: key);

  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  bool isSwitched = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.press,
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.contact.user,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  Text(toggleSwitch(isSwitched)),
                ],
              ),
              SizedBox(height: 20 / 4),
              Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Text(
                    "0"+widget.contact.phone.toString(),
                    softWrap: true,
                    maxLines: 1,
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSwitchListTile() {
    return Switch.adaptive(
        activeColor: Colors.white,
        value: isSwitched,
        onChanged: (value) => setState(() => this.isSwitched = value));
  }

  String toggleSwitch(bool value) {
    String normal = DateFormat.yMd().add_jm().format(widget.contact.checkIn);
    String formatted = timeago.format(widget.contact.checkIn);

    if (isSwitched == false) {
      return formatted;
    } else {
      return normal;
    }
  }
}
