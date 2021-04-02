import 'dart:io';
import 'dart:typed_data';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_tools/qr_code_tools.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as syspaths;

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
      qrCodeResult = pickedFile;
    });
  }

  Future _getPhotoByGallery() async {
    final pickedFile = await picker
        .getImage(source: ImageSource.gallery)
        .then((value) => QrCodeToolsPlugin.decodeFrom(value.path))
        .onError((error, stackTrace) => "No Useful Information Found");
    setState(() {
      qrCodeResult = pickedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scanner"),
        centerTitle: true,
      ),
      body: Container(
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
            SizedBox(
              height: 20.0,
            ),
            FlatButton(
              padding: EdgeInsets.all(15.0),
              onPressed: () async {
                String codeSanner =
                    await BarcodeScanner.scan(); //barcode scnner
                setState(() {
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
    );
  }

  //its quite simple as that you can use try and catch staatements too for platform exception
}
