import 'dart:io';
import 'package:qrcode/drawer.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_tools/qr_code_tools.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard/clipboard.dart';

class ScanPage extends StatefulWidget {
  final dynamic sharedImage;
  ScanPage({this.sharedImage});
  @override
  _ScanPageState createState() => _ScanPageState(sharedImage: sharedImage);
}

class _ScanPageState extends State<ScanPage> {
  dynamic sharedImage;
  _ScanPageState({this.sharedImage});
  final picker = ImagePicker();
  String qrCodeResult = "Not Yet Scanned";
  bool _validURL = false;

  void initState() {
    super.initState();
    if (sharedImage != null) {
      _showData(sharedImage);
    }
  }

  Future _showData(bytes) async {
    final appDir = await syspaths.getTemporaryDirectory();
    File file = File('${appDir.path}/sth.jpg');
    await file.writeAsBytes(bytes);
    final pickedFile = await QrCodeToolsPlugin.decodeFrom(file.path)
        .onError((error, stackTrace) => "No Useful Information Found");
    setState(() {
      _validURL = Uri.parse(pickedFile).isAbsolute;
      qrCodeResult = pickedFile;
    });
  }

  Future _getPhotoByGallery() async {
    final pickedFile = await picker
        .getImage(source: ImageSource.gallery)
        .then((value) => QrCodeToolsPlugin.decodeFrom(value.path))
        .onError((error, stackTrace) => "No Useful Information Found");
    setState(() {
      _validURL = Uri.parse(pickedFile).isAbsolute;
      qrCodeResult = pickedFile;
    });
  }

  Future<void> _launch(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: Text("Scanner"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                "Result",
                style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                qrCodeResult,
                style: TextStyle(
                  fontSize: 20.0,
                ),
                textAlign: TextAlign.center,
              ),
              qrCodeResult != "Not Yet Scanned" && qrCodeResult != "No Useful Information Found"
                  ? ElevatedButton(
                      onPressed: () => FlutterClipboard.copy(qrCodeResult).then((value) {
                        final snackBar = SnackBar(content: Text('Copied To Clipboard'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }),
                      child: Text("Copy"),
                    )
                  : Container(),
              _validURL
                  ? ElevatedButton(
                      onPressed: () {
                        _launch(qrCodeResult);
                      },
                      child: Text("Click To Visit"),
                    )
                  : Container(),
              SizedBox(
                height: 20.0,
              ),
              FlatButton(
                padding: EdgeInsets.all(15.0),
                onPressed: () async {
                  String codeSanner =
                      await BarcodeScanner.scan(); //barcode scnner
                  setState(() {
                    _validURL = Uri.parse(codeSanner).isAbsolute;
                    qrCodeResult = codeSanner;
                  });
                },
                child: Text(
                  "Open Scanner",
                  style:
                      TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.blue, width: 3.0),
                    borderRadius: BorderRadius.circular(20.0)),
              ),
              ElevatedButton(
                onPressed: () {
                  _getPhotoByGallery();
                },
                child: Text("Select File"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(15.0),
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.blue, width: 3.0),
                      borderRadius: BorderRadius.circular(20.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //its quite simple as that you can use try and catch staatements too for platform exception
}
