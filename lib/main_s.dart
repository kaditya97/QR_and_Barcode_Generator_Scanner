import 'package:flutter/material.dart';
import 'package:Qrcode/share_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Receiving Shared Text',
      home: MyHomePage(title: 'Shared Text'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _sharedText = "";
  dynamic _sharedImage;

  @override
  void initState() {
    super.initState();

    // Create the share service
    ShareService()
      // Register a callback so that we handle shared data if it arrives while the
      // app is running
      ..onDataReceived = _handleSharedData

      // Check to see if there is any shared data already, meaning that the app
      // was launched via sharing.
      ..getSharedData().then(_handleSharedData);
    ShareService().getSharedImage().then(_handleSharedImage);
  }

  /// Handles any shared data we may receive.
  void _handleSharedData(String sharedData) {
    setState(() {
      _sharedText = sharedData;
    });
  }

  /// Handles any shared data we may receive.
  void _handleSharedImage(dynamic sharedImage) {
    setState(() {
      _sharedImage = sharedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _sharedText != ""? Text(
              'The shared text that you received is:',
            ): Text(""),
            Text(
              _sharedText,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              child: _sharedImage != null ? Image.memory(_sharedImage) : Text("No Data"),
            )
          ],
        ),
      ),
    );
  }
}
