import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import 'package:Qrcode/generate.dart';
import 'package:Qrcode/homePage.dart';
import 'package:Qrcode/scan.dart';
import 'package:Qrcode/share_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = await PrefServiceShared.init(
    defaults: {
      'start_page': 'posts',
      'ui_theme': 'light',
    },
  );

  runApp(
    PrefService(
      service: service,
      child: MaterialApp(
        home: MyApp(service: service),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final dynamic service;
  MyApp({this.service});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _sharedText = "";
  dynamic _sharedImage;

  @override
  void initState() {
    super.initState();
    ShareService()
      ..onDataReceived = _handleSharedData
      ..getSharedData().then(_handleSharedData);
    ShareService().getSharedImage().then(_handleSharedImage);
  }

  void _handleSharedData(String sharedData) {
    setState(() {
      _sharedText = sharedData;
    });
  }

  void _handleSharedImage(dynamic sharedImage) {
    setState(() {
      _sharedImage = sharedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _sharedText != ""
        ? GeneratePage(
            sharedText: _sharedText,
          )
        : _sharedImage != null
            ? ScanPage(
                sharedImage: _sharedImage,
              )
            : HomePage();
  }
}
