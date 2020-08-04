import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather/model/setting.dart';
import 'package:weather/provider/dark_mode_provider.dart';
import 'package:weather/tool/palette.dart';
import 'package:weather/widgets/fix_image.dart';

class SettingPage extends StatefulWidget {

  const SettingPage({Key key}): super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  final List<SettingType> types = [
    SettingType.mapStyle,
    SettingType.api,
    SettingType.version
  ];

  List<Setting> items;

  @override
  void initState() {
    super.initState();

    items = types.map((type) => Setting(type)).toList();
  }

  @override
  Widget build(BuildContext context) {
    var darkMode = Provider.of<DarkMode>(context);
    items[0].darkMode(darkMode.isDark);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "設定",
          textScaleFactor: 1.0,
        ),
        centerTitle: true,
        toolbarOpacity: 0.8,
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int position) {
          return _settingItem(context, position, onTap: () {
            _click(context, items[position].type);
          });
        },
      ),
    );
  }

  Widget _settingItem(BuildContext context, int position, {Function() onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Container(
            height: 60.0,
            child: Row(
              children: <Widget>[
                FixImage(
                  size: Size(30.0, 30.0),
                  child: items[position].image,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 25.0),
                  child: Text(
                    items[position].title,
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                        color: Palette.on699ad0
                    ),
                    textScaleFactor: 1.0,
                  ),
                )
              ],
            ),
          ),
          Divider(
            height: 1.0,
            color: Palette.on464646,
          ),
        ].map((e) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: e,
          );
        }).toList(),
      ),
    );
  }

  void _click(BuildContext context, SettingType type) async {
    switch (type) {
      case SettingType.api:
        final url = "https://openweathermap.org/api";
        if (await canLaunch(url)) {
          await launch(
            url,
            forceSafariVC: true,
            forceWebView: true
          );
        } else {
          throw "$url can't launch.";
        }
        break;
      case SettingType.version:
      case SettingType.none:
        break;
      case SettingType.mapStyle:
        Provider.of<DarkMode>(context, listen: false).change();
        break;
    }
  }
}