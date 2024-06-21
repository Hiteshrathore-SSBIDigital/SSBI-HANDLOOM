import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:ssbiproject/Other_screen/APIs_Screen.dart';
import 'dart:ui' as ui;
import 'package:ssbiproject/Setting/Constvariable.dart';

class QRScan_Screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRScan_ScreenState();
}

class _QRScan_ScreenState extends State<QRScan_Screen> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final GlobalKey GlobalKeys = GlobalKey();
  Completer<void> completer = Completer<void>();
  late QRViewController qrController;
  late double scanArea;

  final TempAPIs apiservice = TempAPIs();
  late Future<List<Temp>> item;
  String qrval = '';
  String responseMessage = '';

  late List<Temp> tempData; // Declare tempData at the class level

  @override
  void initState() {
    super.initState();
    scanArea = 300.0; // Default scan area size
    fetchData(); // Call fetchData in initState to initiate the API call
  }

  void fetchData() async {
    try {
      List<Temp> tempData = await apiservice.fetchTemp(qrval);

      // Assuming you want to display the data in a simple way, you can print it
      for (Temp temp in tempData) {
        print('Temp URL: ${temp.tempurl}');
      }

      // Assuming the response message is the first tempurl, you can update the state
      if (tempData.isNotEmpty) {
        setState(() {
          responseMessage = '${tempData[0].tempurl}';
        });
      } else {
        // Handle the case where tempData is empty
        setState(() {
          responseMessage = '';
        });
      }
    } catch (e) {
      // Handle errors here
      print('Error fetching data: $e');
      setState(() {
        responseMessage = 'Error: $e';
      });
    }
  }

// used qrcode massage
  void AlertMassage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.maxFinite,
            height: 50,
            child: Column(
              children: [
                Text(
                  "This QR code has already been used. Please scan a new QR code.!",
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 10),
                // You can add additional content or widgets here
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "OK",
                style: TextStyle(fontSize: 16, color: Color(ColorVal)),
              ),
            ),
          ],
        );
      },
    );
  }

// Invaild qr massage
  void InvaildQrMass(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.maxFinite,
            height: 50,
            child: Column(
              children: [
                Text(
                  "Invaild QR code Please vaild QR code scan !",
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 10),
                // You can add additional content or widgets here
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "OK",
                style: TextStyle(fontSize: 16, color: Color(ColorVal)),
              ),
            ),
          ],
        );
      },
    );
  }

//
  void NetworkIssueMass(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.maxFinite,
            height: 50,
            child: Column(
              children: [
                Text(
                  "Oops! You don't seem to be connected to the internet Please connect & try again.",
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 10),
                // You can add additional content or widgets here
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "OK",
                style: TextStyle(fontSize: 16, color: Color(ColorVal)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "QR Scan",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onPressed: () {
            // Handle back button press here
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Color(ColorVal),
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result != null)
                    Text(
                        'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                  else
                    const Text('Scan a code'),
                  //   Text(responseMessage), QR Massage Display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await controller?.toggleFlash();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getFlashStatus(),
                              builder: (context, snapshot) {
                                return Text('Flash: ${snapshot.data}');
                              },
                            )),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await controller?.flipCamera();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getCameraInfo(),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return Text(
                                      'Camera facing ${describeEnum(snapshot.data!)}');
                                } else {
                                  return const Text('loading');
                                }
                              },
                            )),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.pauseCamera();
                          },
                          child: const Text('Pause',
                              style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.resumeCamera();
                          },
                          child: const Text('Resume',
                              style: TextStyle(fontSize: 20)),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 300.0
        : 300.0;

    return RepaintBoundary(
      key: qrKey,
      child: QRView(
          key: GlobalKeys, // Use GlobalKeys for QRView instead
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
            borderColor: Colors.red,
            borderRadius: 10,
            borderLength: 30,
            borderWidth: 10,
            cutOutSize: scanArea,
          ),
          // Removed the extra argument here
          onPermissionSet: _onPermissionSet),
    );
  }

  void _onPermissionSet(QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Permission')),
      );
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });

      if (result != null && result!.code != null && result!.code!.isNotEmpty) {
        String qrValue = result!.code!;
        try {
          List<Temp> tempData = await apiservice.fetchTemp(qrValue);
          for (Temp temp in tempData) {
            print('Temp URL: ${temp.tempurl}');
          }

          // Display the printed value in the UI
          if (tempData.isNotEmpty) {
            setState(() {
              responseMessage = '${tempData[0].tempurl}';
              if (responseMessage == 'QR code is Already Used.') {
                AlertMassage(context);
              } else if (responseMessage
                  .startsWith('QR Code Verified Successfully')) {
                _saveImageAndExit(context);
              } else {}
            });
          } else {
            // Handle the case where tempData is empty
            setState(() {
              responseMessage = '';
            });
          }
        } catch (e) {
          print('Error calling API: $e');
          // Handle errors here
          setState(() {
            responseMessage = 'Error: $e';
          });
        }
      }
    });
  }

  Future<void> _saveImageAndExit(BuildContext context) async {
    Completer<void> completer = Completer();

    try {
      Uint8List? byteList = await captureImage(qrKey);

      if (byteList != null) {
        Directory tempDir = await getTemporaryDirectory();
        String tempFileName = '${DateTime.now().millisecondsSinceEpoch}.png';

        // Create a custom directory named "ssbi" if it doesn't exist
        Directory ssbiDir = Directory('${tempDir.path}/ssbi');
        if (!ssbiDir.existsSync()) {
          ssbiDir.createSync();
        }

        File tempFile = File('${ssbiDir.path}/$tempFileName');
        await tempFile.writeAsBytes(byteList);

        // Image saved to the "ssbi" folder
        print('Image saved to: ${tempFile.path}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image saved to ssbi folder.'),
          ),
        );
        completer.complete();
      } else {
        completer.completeError('Image is null');
      }
    } catch (e) {
      print('Error saving image to ssbi folder: $e');
      completer.completeError(e.toString());
    }

    return completer.future;
  }

  Future<Uint8List?> captureImage(GlobalKey keys) async {
    try {
      // Find the render object associated with the GlobalKey
      final RenderObject? renderObject =
          keys.currentContext?.findRenderObject();

      // Check if the render object is a RenderRepaintBoundary
      if (renderObject is RenderRepaintBoundary) {
        // Capture the image of the RenderRepaintBoundary
        ui.Image image = await renderObject.toImage(pixelRatio: 3.0);

        // Convert the image to byte data
        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);

        if (byteData != null) {
          // Convert the byte data to Uint8List
          Uint8List pngBytes = byteData.buffer.asUint8List();
          return pngBytes;
        } else {
          // Handle the case where byteData is null
          print('Error: ByteData is null');
          return null;
        }
      } else {
        // Handle the case where RenderRepaintBoundary is not found
        print('Error: RenderRepaintBoundary not found');
        return null;
      }
    } catch (e, stackTrace) {
      // Handle any errors that occur during image capture
      print('Error capturing image: $e');
      print('StackTrace: $stackTrace');
      return null;
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
