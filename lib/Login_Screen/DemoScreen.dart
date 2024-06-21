import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:ssbiproject/Other_screen/APIs_Screen.dart';
import 'package:ssbiproject/Screen/Bottom_Screen.dart';
import 'dart:ui' as ui;
import 'package:ssbiproject/Setting/Constvariable.dart';
import 'package:image/image.dart' as img;
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'dart:developer';

class Demo_Screen extends StatefulWidget {
  const Demo_Screen({super.key});

  @override
  State<Demo_Screen> createState() => _Demo_ScreenState();
}

class _Demo_ScreenState extends State<Demo_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Temp_Qr(),
      ),
    );
  }
}

//

class Temp_Qr extends StatefulWidget {
  @override
  State<Temp_Qr> createState() => _Temp_QrState();
}

class _Temp_QrState extends State<Temp_Qr> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  final TempAPIs apiservice = TempAPIs();
  late Future<List<Temp>> item;
  String qrval = '';
  String responseMessage = '';

  late List<Temp> tempData; // Declare tempData at the class level

  @override
  void initState() {
    super.initState();
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
                    Text('Scan a code'),
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
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => Temp_Product(
                                data: result!.code ?? "No Available Data")),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          "Next",
                          style: TextStyle(
                              color: Color(ColorVal),
                              fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Icon(Icons.arrow_forward),
                        )
                      ],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
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
                  .startsWith('No data found for qrvalue:')) {
                InvaildQrMass(context);
              } else if (responseMessage.startsWith('Failed host lookup:')) {
                NetworkIssueMass(context);
              } else {
                _saveImageToGallery(controller);
              }
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

  Future<void> _saveImageToGallery(QRViewController controller) async {
    Completer<void> completer = Completer<void>();

    try {
      GlobalKey repaintKey = GlobalKey();

      // Wrap QRView with RepaintBoundary
      Widget qrViewWithRepaint = RepaintBoundary(
        key: repaintKey,
        child: QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          // ... other properties ...
        ),
      );

      // Wait until the widget tree is fully built
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        // Check if repaintKey.currentContext is not null before proceeding
        if (repaintKey.currentContext != null) {
          RenderRepaintBoundary boundary = repaintKey.currentContext!
              .findRenderObject() as RenderRepaintBoundary;

          // Check if boundary.toImage returns a non-null value
          ui.Image? image = await boundary.toImage(pixelRatio: 3.0);

          if (image != null) {
            ByteData? byteData =
                await image.toByteData(format: ui.ImageByteFormat.rawRgba);

            if (byteData != null) {
              Uint8List byteList = byteData.buffer.asUint8List();

              // Save the image to a temporary file
              File tempFile =
                  await File('path/to/temp_image.png').writeAsBytes(byteList);

              // Save the temporary file to the gallery
              final result = await ImageGallerySaver.saveFile(tempFile.path);

              print('Image saved to gallery: $result');
              completer
                  .complete(); // Complete the Future when everything is done
            } else {
              completer.completeError('ByteData is null');
            }
          } else {
            completer.completeError('Image is null');
          }
        } else {
          completer.completeError('Repaint key current context is null');
        }
      });
    } catch (e) {
      print('Error saving image to gallery: $e');
      completer.completeError(e); // Complete with an error if there's an issue
    }

    // Remove the line below, as Completer<void> doesn't return a value
    // await completer.future; // Wait for the completion of the entire process
  }

  void _exitApp(List<Temp> tempData) {
    print('Exiting the app after scanning and handling data.');
    exit(0);
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

// Peoduct Screen
class Temp_Product extends StatefulWidget {
  final String data;
  Temp_Product({required this.data});
  @override
  State<Temp_Product> createState() => _Temp_ProductState();
}

class _Temp_ProductState extends State<Temp_Product> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Product Detailas',
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
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(ColorVal),
      ),
      body: Center(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: "Weaver Name"),
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Product Name"),
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Organization Name"),
                ),
              ],
            ),
          )
        ]),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              children: [
                Text("QR Code "),
                Text(widget.data),
                TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => Temp_Image(
                                  data: widget.data,
                                )),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          "Next",
                          style: TextStyle(
                              color: Color(ColorVal),
                              fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Icon(Icons.arrow_forward),
                        )
                      ],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Image
class Temp_Image extends StatefulWidget {
  final String data;
  Temp_Image({required this.data});
  @override
  State<Temp_Image> createState() => _Temp_ImageState();
}

class _Temp_ImageState extends State<Temp_Image> {
  String originalImagePath = '';
  String compressedImagePath = '';

  void initState() {
    super.initState();
    // Call the method to open the camera when the screen loads
    selectImageFromCamera(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Captured Images',
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
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(ColorVal),
      ),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: [
          _buildImage(originalImagePath, 'Original Image'),
          _buildImage(compressedImagePath, 'Compressed Image'),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              children: [
                Text("Qr Code "),
                Text(widget.data),
                TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => Temp_Videos(
                                  data: widget.data,
                                )),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          "Next",
                          style: TextStyle(
                              color: Color(ColorVal),
                              fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Icon(Icons.arrow_forward),
                        )
                      ],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Path set Image Screen
  Widget _buildImage(String imagePath, String title) {
    return imagePath.isNotEmpty
        ? Card(
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  width: 200,
                  height: 200,
                ),
              ],
            ),
          )
        : Container();
  }

// Camera Using Image Click
  Future<void> selectImageFromCamera(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      final originalImagePath = image.path;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Image captured and saved!"),
        ),
      );

      await _compressAndSaveImage(originalImagePath);
      setState(() {
        this.originalImagePath = originalImagePath;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No image captured!"),
        ),
      );
    }
  }

//Orignal or Compress Image Save in Gallery
  Future<void> _compressAndSaveImage(String originalImagePath) async {
    final originalFile = File(originalImagePath);

    try {
      if (!originalFile.existsSync()) {
        throw FileSystemException("File not found");
      }

      final originalBytes = await originalFile.readAsBytes();
      if (originalBytes.isEmpty) {
        throw Exception("Empty file bytes");
      }

      final image = img.decodeImage(originalBytes);
      if (image == null) {
        throw Exception("Failed to decode image");
      }

      final compressedImage = img.encodeJpg(image, quality: 50);
      final compressedFile =
          File(originalFile.path.replaceAll('.jpg', '_compressed.jpg'));
      await compressedFile.writeAsBytes(compressedImage);

      await ImageGallerySaver.saveFile(originalFile.path,
          isReturnPathOfIOS: true);
      await ImageGallerySaver.saveFile(compressedFile.path,
          isReturnPathOfIOS: true);

      setState(() {
        this.compressedImagePath = compressedFile.path;
      });
    } catch (e) {
      print("Error compressing image: $e");
    }
  }

// Select Image For Camera
  Future<void> selectImage(BuildContext context) async {
    await selectImageFromCamera(context);
  }
}

// videos screen Starts
class Temp_Videos extends StatefulWidget {
  final String data;
  Temp_Videos({required this.data});
  @override
  State<Temp_Videos> createState() => _Temp_VideosState();
}

class _Temp_VideosState extends State<Temp_Videos> {
  String originalVideoPath = '';
  String compressedVideoPath = '';
  VideoPlayerController? _controller;
  bool isProcessing = false; // Track whether video processing is ongoing

  void initState() {
    super.initState();
    checkPermissionsAndSelectVideo(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Captured Videos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(ColorVal),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          if (_controller != null) _buildVideo(_controller!, 'Original Video'),
          _buildVideoPlayer(),
          if (isProcessing)
            LinearProgressIndicator(), // Show progress bar when processing
          _buildVideo(
            compressedVideoPath.isNotEmpty
                ? VideoPlayerController.file(File(compressedVideoPath))
                : VideoPlayerController.asset('assets/empty_video.mp4'),
            'Compressed Video',
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              children: [
                Text("Qr Code "),
                Text(widget.data),
                TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => Bottom_Screen()),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          "Finish",
                          style: TextStyle(
                              color: Color(ColorVal),
                              fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Icon(Icons.arrow_forward),
                        )
                      ],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideo(VideoPlayerController controller, String title) {
    return Card(
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return _controller != null && _controller!.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          )
        : Container();
  }

  Future<void> checkPermissionsAndSelectVideo(BuildContext context) async {
    final permissionStatus = await Permission.camera.request();
    if (permissionStatus.isGranted) {
      selectVideo(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permission denied for accessing camera.'),
        ),
      );
    }
  }

  Future<void> selectVideo(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedVideo = await _picker.pickVideo(
        source: ImageSource.camera, maxDuration: Duration(seconds: 30));

    if (pickedVideo != null) {
      final String videoPath = pickedVideo.path;

      try {
        setState(() {
          isProcessing =
              true; // Set processing to true when video selection starts
        });

        final MediaInfo? compressedVideoInfo =
            await VideoCompress.compressVideo(
          videoPath,
          quality: VideoQuality.DefaultQuality,
          deleteOrigin: false,
        );

        if (compressedVideoInfo != null) {
          final String originalVideoPath = videoPath;
          final String compressedVideoPath =
              compressedVideoInfo.path ?? originalVideoPath;

          setState(() {
            this.originalVideoPath = originalVideoPath;
            this.compressedVideoPath = compressedVideoPath;
            _controller = VideoPlayerController.file(File(originalVideoPath))
              ..initialize().then((_) {
                setState(() {});
                _controller!.play();
              });
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Video captured and compressed!"),
            ),
          );

          await GallerySaver.saveVideo(compressedVideoPath);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Video saved to gallery!"),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to compress video!"),
            ),
          );
        }
      } catch (e) {
        print("Error compressing video: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error compressing video!"),
          ),
        );
      } finally {
        setState(() {
          isProcessing =
              false; // Set processing to false when video processing is done
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No video captured!"),
        ),
      );
    }
  }
}
