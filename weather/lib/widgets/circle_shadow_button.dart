import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CircleShadowButton extends StatefulWidget {

  final Widget child;
  final double width;
  final double height;
  final Function onTap;

  const CircleShadowButton({
    Key key,
    @required this.child,
    this.width,
    this.height,
    this.onTap
  }): super(key: key);

  @override
  _CircleShadowButtonState createState() => _CircleShadowButtonState();
}

class _CircleShadowButtonState extends State<CircleShadowButton> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: widget.width,
        height: widget.height,
        child: widget.child,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          border: Border.all(
              style: BorderStyle.none
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 0.0,
                blurRadius: 8.0,
                offset: Offset(0.0, 2.0)
            )
          ],
        ),
      ),
      onTap: widget.onTap,
    );
  }
}