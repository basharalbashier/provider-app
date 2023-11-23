import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

AppBar buildAppBar(BuildContext context,titele) {
  // final icon = CupertinoIcons.moon_stars;

  return AppBar(title: Text(titele),
    leading: BackButton(),
    backgroundColor: Colors.transparent,
    elevation: 0,
    // actions: [
    //   IconButton(
    //     icon: Icon(icon),
    //     onPressed: () {},
    //   ),
    // ],
  );
}
