import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'contact_model.dart';

class ContactList extends StatelessWidget {
  final Contact contact;
  final bool isSwitched;

  const ContactList({Key key, this.contact, this.isSwitched}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
                Text(toggleSwitch(),
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
            subtitle: Text("0" + contact.phone.toString(),
                style: TextStyle(color: Colors.grey, fontSize: 16)),
            onTap: () => share(context)),
        Divider()
      ],
    );
  }

  void share(BuildContext context) {
    final RenderBox box = context.findRenderObject();
    final String text = "${contact.user}";

    Share.share(text,
        subject: contact.phone.toString(),
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  setSwitchValue(bool isSwitched) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isSwitched', isSwitched);
  }

  String toggleSwitch() {
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
}
