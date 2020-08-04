import 'package:flutter/material.dart';

/// 天氣列表，顯示/離開 動畫
class WeatherInfoListHeightTransition extends StatelessWidget {

  const WeatherInfoListHeightTransition({
    Key key,
    this.child,
    this.animation
  }) : super(key: key);

  final Widget child;
  final Animation animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      child: child,
      animation: animation,
      builder: (BuildContext context, Widget child) {
        return Container(
          height: animation.value,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              style: BorderStyle.none,
          ),
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(8.0),
            ),
          ),
          child: child,
        );
      },
    );
  }
}