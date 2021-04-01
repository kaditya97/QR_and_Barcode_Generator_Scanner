import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image/image.dart' as im;
import 'package:barcode_image/barcode_image.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class GeneratePage extends StatefulWidget {
  final String sharedText;
  GeneratePage({this.sharedText});
  @override
  State<StatefulWidget> createState() => GeneratePageState();
}

class GeneratePageState extends State<GeneratePage> {
  final _formKey = GlobalKey<FormState>();
  File myfile;
  double _panelHeightOpen;
  double _panelHeightClosed = 95.0;
  PanelController _pc = new PanelController();
  // String _basename;
  String dropdownValue = 'lulc';

  void shareQrcode(
    Barcode bc,
    String data, {
    String filename,
    double width,
    double height,
    double fontHeight,
  }) async {
    final box = context.findRenderObject() as RenderBox;
    final directory = (await getExternalStorageDirectory()).path;
    filename ??= bc.name.replaceAll(RegExp(r'\s'), '-').toLowerCase();
    final image = im.Image(280, 240);
    im.fill(image, im.getColor(255, 255, 255));
    drawBarcode(image, bc, data, font: im.arial_24);
    File('$directory/$filename.png').writeAsBytesSync(im.encodePng(image));
    await Share.shareFiles(['$directory/$filename.png'],
        text: filename,
        subject: filename,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  @override
  Widget build(BuildContext context) {
    String qrData = (widget.sharedText).toString();
    _panelHeightOpen = MediaQuery.of(context).size.height * .80;
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Generator'),
        actions: <Widget>[],
      ),
      body: SlidingUpPanel(
        controller: _pc,
        maxHeight: _panelHeightOpen,
        minHeight: _panelHeightClosed,
        parallaxEnabled: true,
        parallaxOffset: .5,
        panelBuilder: (sc) => _panel(sc),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
        body: Container(
          padding: EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Stack(
                  alignment: Alignment.center,
                  children: [
                    BarcodeWidget(
                      barcode: Barcode.qrCode(
                        errorCorrectLevel: BarcodeQRCorrectionLevel.high,
                      ),
                      data: qrData,
                      width: 200,
                      height: 200,
                    ),
                    Container(
                      color: Colors.white,
                      width: 30,
                      height: 30,
                      child: const FlutterLogo(),
                    ),
                  ],
                ),

                // BarcodeWidget(
                //   barcode: Barcode.qrCode(),
                //   data: qrData,
                // ),
                SizedBox(
                  height: 40.0,
                ),
                Text(
                  "New QR Link Generator",
                  style: TextStyle(fontSize: 20.0),
                ),
                TextField(
                  controller: qrdataFeed..text = qrData,
                  decoration: InputDecoration(
                    hintText: "Input your link or data",
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(40, 20, 40, 0),
                  child: FlatButton(
                    padding: EdgeInsets.all(15.0),
                    onPressed: () async {
                      if (qrdataFeed.text.isEmpty) {
                        //a little validation for the textfield
                        setState(() {
                          qrData = "";
                        });
                      } else {
                        setState(() {
                          qrData = qrdataFeed.text;
                        });
                      }
                    },
                    child: Text(
                      "Generate QR",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.blue, width: 3.0),
                        borderRadius: BorderRadius.circular(20.0)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(40, 20, 40, 0),
                  child: FlatButton(
                    padding: EdgeInsets.all(15.0),
                    onPressed: () async {
                      shareQrcode(
                        Barcode.qrCode(),
                        qrData,
                        height: 200,
                        filename: "QRExample",
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.share,
                          color: Colors.blue,
                          size: 30.0,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Share QR",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.blue, width: 3.0),
                        borderRadius: BorderRadius.circular(20.0)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final qrdataFeed = TextEditingController();

  Widget _panel(ScrollController sc) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          controller: sc,
          children: <Widget>[
            SizedBox(
              height: 12.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 30,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                ),
              ],
            ),
            SizedBox(
              height: 18.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "QR and Bar Code Generator",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 24.0,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 36.0,
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 24.0, right: 24.0),
              child: _form(), // Form for data submition
            ),
          ],
        ));
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: DropdownButton<String>(
              value: dropdownValue,
              icon: Icon(Icons.arrow_drop_down_outlined),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String newValue) {
                setState(() {
                  dropdownValue = newValue;
                });
              },
              items: [
                DropdownMenuItem(
                  child: Text("Land Cover"),
                  value: 'lulc',
                ),
                DropdownMenuItem(
                  child: Text("DEM"),
                  value: 'dem',
                ),
                DropdownMenuItem(
                  child: Text("NDVI"),
                  value: 'ndvi',
                ),
                DropdownMenuItem(
                  child: Text("NDBI"),
                  value: 'ndbi',
                ),
                DropdownMenuItem(
                  child: Text("NDWI"),
                  value: 'ndwi',
                ),
                DropdownMenuItem(
                  child: Text("Hillshade"),
                  value: 'hillshade',
                ),
                DropdownMenuItem(
                  child: Text("Slope"),
                  value: 'slope',
                ),
                DropdownMenuItem(
                  child: Text("Aspect"),
                  value: 'aspect',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                void sendData(String name, File file) async {
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('Processing Data')));
                }

                final String name = dropdownValue;
                // if (filedata == null && dropdownValue == 'dem' ||
                //     filedata == null && dropdownValue == 'lulc') {
                //   final File file = null;
                //   sendData(name, file);
                // } else if (filedata == null) {
                //   Scaffold.of(context).showSnackBar(
                //       SnackBar(content: Text('Please Select a geojsonfile')));
                // }
                // if (filedata != null) {
                //   final File file = filedata;
                //   sendData(name, file);
                // }
              },
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
