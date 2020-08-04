import 'dart:ui';

import 'package:flutter/cupertino.dart';

class FixImage extends StatelessWidget {

  final Size size;
  final Widget child;

  const FixImage({
    Key key,
    @required this.size,
    @required this.child,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      child: child,
    );
  }
}