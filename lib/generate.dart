import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:qrcode/drawer.dart';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pref/pref.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image/image.dart' as im;
import 'package:barcode_image/barcode_image.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class GeneratePage extends StatefulWidget {
  final dynamic sharedText;
  GeneratePage({this.sharedText});
  @override
  _GeneratePageState createState() =>
      _GeneratePageState(sharedText: sharedText);
}

class _GeneratePageState extends State<GeneratePage> {
  String qrData = "https://kaditya97.com.np";
  dynamic sharedText;
  _GeneratePageState({this.sharedText});
  final _formKey = GlobalKey<FormState>();
  File myfile;
  double _panelHeightOpen;
  double _panelHeightClosed = 95.0;
  PanelController _pc = new PanelController();
  String dropdownValue = 'qrCode';

  @override
  void initState() {
    super.initState();
    if (sharedText != null) {
      setState(() {
        qrData = sharedText.toString();
      });
    }
  }

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

  Future<void> _downloadData() async {
    final bc = Barcode.qrCode();
    final image = im.Image(280, 240);
    im.fill(image, im.getColor(255, 255, 255));
    drawBarcode(image, bc, qrData, font: im.arial_48);
    final data = im.encodePng(image);
    Uint8List bytes = Uint8List.fromList(data);
    MimeType type = MimeType.PNG;
    if (Platform.isIOS || Platform.isAndroid) {
      bool status = await Permission.storage.isGranted;
      if (!status) await Permission.storage.request();
    }
    await FileSaver.instance.saveFile("myqr", bytes, "png", mimeType:type);
    final snackBar = SnackBar(content: Text('Image Downloaded'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final startPage = PrefService.of(context).get('start_page');
    print(startPage);
    _panelHeightOpen = MediaQuery.of(context).size.height * .80;
    return Scaffold(
      drawer: CustomDrawer(),
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
                  height: 10.0,
                ),
                Text(
                  qrData,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20.0,
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
                Padding(
                  padding: EdgeInsets.fromLTRB(40, 20, 40, 0),
                  child: FlatButton(
                    padding: EdgeInsets.all(15.0),
                    onPressed: () async {
                      _downloadData();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.file_download,
                          color: Colors.blue,
                          size: 30.0,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Download",
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
                  "QR and Barcode Generator",
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    child: Text("QR Code"),
                    value: 'qrCode',
                  ),
                  DropdownMenuItem(
                    child: Text("QR Wifi"),
                    value: 'qrWifi',
                  ),
                  DropdownMenuItem(
                    child: Text("Code 39"),
                    value: 'code39',
                  ),
                  DropdownMenuItem(
                    child: Text("Code 93"),
                    value: 'code 93',
                  ),
                  DropdownMenuItem(
                    child: Text("Code 128A"),
                    value: 'code128a',
                  ),
                  DropdownMenuItem(
                    child: Text("Code 128B"),
                    value: 'code128b',
                  ),
                  DropdownMenuItem(
                    child: Text("Code 128C"),
                    value: 'code128c',
                  ),
                  DropdownMenuItem(
                    child: Text("GS1-128"),
                    value: 'gs1128',
                  ),
                  DropdownMenuItem(
                    child: Text("ITF"),
                    value: 'itf',
                  ),
                  DropdownMenuItem(
                    child: Text("ITF-14"),
                    value: 'itf14',
                  ),
                  DropdownMenuItem(
                    child: Text("ITF-16"),
                    value: 'itf16',
                  ),
                  DropdownMenuItem(
                    child: Text("EAN 13"),
                    value: 'ean13',
                  ),
                  DropdownMenuItem(
                    child: Text("EAN 8"),
                    value: 'ean8',
                  ),
                  DropdownMenuItem(
                    child: Text("EAN 2"),
                    value: 'ean2',
                  ),
                  DropdownMenuItem(
                    child: Text("EAN 5"),
                    value: 'ean5',
                  ),
                  DropdownMenuItem(
                    child: Text("ISBN"),
                    value: 'isbn',
                  ),
                  DropdownMenuItem(
                    child: Text("UPC-A"),
                    value: 'upca',
                  ),
                  DropdownMenuItem(
                    child: Text("UPC-E"),
                    value: 'upce',
                  ),
                  DropdownMenuItem(
                    child: Text("Telepen"),
                    value: 'telepen',
                  ),
                  DropdownMenuItem(
                    child: Text("Codabar"),
                    value: 'codabar',
                  ),
                  DropdownMenuItem(
                    child: Text("RM4SCC"),
                    value: 'rm4scc',
                  ),
                  DropdownMenuItem(
                    child: Text("PDF417"),
                    value: 'pdf417',
                  ),
                  DropdownMenuItem(
                    child: Text("Data Matrix"),
                    value: 'datamatrix',
                  ),
                  DropdownMenuItem(
                    child: Text("Aztec"),
                    value: 'aztec',
                  ),
                ],
              ),
            ),
            TextField(
              controller: qrdataFeed,
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
                  FocusScope.of(context).requestFocus(FocusNode());
                  _pc.close();
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
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
