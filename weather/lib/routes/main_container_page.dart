import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather/provider/control_provider.dart';
import 'package:weather/provider/weather_provider.dart';
import 'package:weather/routes/map_page.dart';
import 'package:weather/routes/setting_page.dart';
import 'package:weather/tool/images.dart';
import 'package:weather/tool/palette.dart';

class MainContainerPage extends StatefulWidget {

  const MainContainerPage({Key key}): super(key: key);

  @override
  _MainContainerPageState createState() => _MainContainerPageState();
}

class _MainContainerPageState extends State<MainContainerPage> {

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final titles = ["地圖", "設定"];
    final List<String> icons = [Images.icMapGrayStr, Images.icSettingsGrayStr];

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CtrlProvider(),),
        ChangeNotifierProvider(create: (context) => WeatherProvider(),),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: <Widget>[
            MapPage(),
            SettingPage()
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: titles.asMap().keys.map((index) {
            return BottomNavigationBarItem(
                title: Text(titles[index]),
                icon: Container(
                  width: 24.0,
                  height: 24.0,
                  child: Image.asset("${icons[index]}"),
                ),
                activeIcon: Container(
                  width: 24.0,
                  height: 24.0,
                  child:  Image.asset(
                    "${icons[index]}",
                    color: Palette.on699ad0,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                )
            );
          }).toList(),
          currentIndex: _currentIndex,
          selectedFontSize: 0.0,
          unselectedFontSize: 0.0,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}