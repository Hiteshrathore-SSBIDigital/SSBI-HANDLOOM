import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nehhdc_app/Model_Screen/APIs_Screen.dart';
import 'package:nehhdc_app/Setting_Screen/Directory_Screen.dart';
import 'package:nehhdc_app/Setting_Screen/Setting_Screen.dart';
import 'package:nehhdc_app/Setting_Screen/Static_Verible';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';

class QRScan_Screen extends StatefulWidget {
  const QRScan_Screen({Key? key}) : super(key: key);

  @override
  State<QRScan_Screen> createState() => _QRScan_ScreenState();
}

class _QRScan_ScreenState extends State<QRScan_Screen> {
  bool isFlashOn = false;
  bool isFrontCamera = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isScanCompleted = false;
  MobileScannerController cameraController = MobileScannerController();
  String responseMessage = '';
  final TempAPIs apiService = TempAPIs();
  late DateTime startdate;

  void closeScreen() {
    setState(() {
      isScanCompleted = false;
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    closeScreen();
    startScanner();
  }

  void startScanner() {
    cameraController.start();
  }

  void stopScanner() {
    cameraController.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff022a72),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Colors.white,
        ),
        title: Text(
          "QR Scanner",
          style: TextStyle(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: RepaintBoundary(
          key: qrKey,
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: cameraController,
                      onDetect: (barcodeCapture) async {
                        if (!isScanCompleted) {
                          setState(() {
                            isScanCompleted = true;
                          });
                          final List<Barcode> barcodes =
                              barcodeCapture.barcodes;
                          final String qrValue = barcodes.isNotEmpty
                              ? barcodes.first.rawValue ?? '---'
                              : '---';
                          await fetchDataAndUpdateResponse(qrValue);
                        }
                      },
                    ),
                    QRScannerOverlay(
                      overlayColor: Colors.black26,
                      borderColor: Colors.white,
                      borderRadius: 5,
                      borderStrokeWidth: 5,
                      scanAreaWidth: 250,
                      scanAreaHeight: 250,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "|Scan properly to see results|",
                    style: TextStyle(
                      color: Color(0xff022a72),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchDataAndUpdateResponse(String qrValue) async {
    try {
      List<Temp> tempData =
          await apiService.fetchTemp(context, qrValue, closeScreen);
      if (tempData.isNotEmpty) {
        setState(() {
          responseMessage = '${tempData[0].tempurl}';
          int statusCode = tempData[0].status;
          if (statusCode == 1) {
            _saveImageAndExit(context).then((qrImagePath) {
              getCurrentLocation().then((position) {
                if (position != null) {
                  double latitude = position.latitude;
                  double longitude = position.longitude;
                  startdate = DateTime.now();
                  showMessageDialog(context, responseMessage);
                  uploadservicedata(
                    context: context,
                    qrcodevalue: staticverible.qrval,
                    startdate: startdate,
                    latitude: latitude,
                    longitude: longitude,
                  );
                  stopScanner();
                } else {
                  print("Could not get location");
                }
              });
            });
          }
        });
      } else {
        setState(() {
          responseMessage = '';
        });
      }
    } catch (e) {
      print('Error calling API: $e');
      setState(() {
        responseMessage = 'Error: $e';
      });
    }
  }

  Future<String> _saveImageAndExit(BuildContext context) async {
    try {
      Uint8List? byteList = await _captureImage(qrKey);

      if (byteList != null) {
        String? qrCode = staticverible.qrval;
        if (qrCode == '') {
          print("QR code is null");
          return '';
        }

        String fileName = '$qrCode.png';
        String folderName = "Scan_Images";

        List<int> compressedByteList = await _compressImage(byteList);

        await saveFileToExternalStorage(
          context,
          folderName,
          fileName,
          Uint8List.fromList(compressedByteList),
        );

        return '$folderName/$fileName';
      } else {
        print("Error: Byte list is null");
        return '';
      }
    } catch (e, stackTrace) {
      print('Error saving image: $e');
      print(stackTrace);
      return '';
    }
  }

  Future<Uint8List?> _captureImage(GlobalKey keys) async {
    try {
      final RenderRepaintBoundary boundary =
          keys.currentContext!.findRenderObject()! as RenderRepaintBoundary;

      if (boundary.debugNeedsPaint) {
        print('Error: Widget needs painting');
        return null;
      }

      ui.Image? image = await boundary.toImage(pixelRatio: 1.0);

      if (image == '') {
        print('Error: Rendered image is null');
        return null;
      }

      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        print('Error: ByteData is null');
        return null;
      }

      Uint8List byteList = byteData.buffer.asUint8List();

      return byteList;
    } catch (e) {
      print('Error capturing image: $e');
      return null;
    }
  }

  Future<List<int>> _compressImage(Uint8List byteList) async {
    img.Image originalImage = img.decodeImage(byteList)!;
    List<int> compressedByteList = img.encodeJpg(originalImage, quality: 30);
    return compressedByteList;
  }
}
