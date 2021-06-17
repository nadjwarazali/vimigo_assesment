import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final Future future;
  final Widget child;

  const LoadingWidget({Key key, this.future, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
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
            return child;
          }
        }
      },
    );
  }
}
