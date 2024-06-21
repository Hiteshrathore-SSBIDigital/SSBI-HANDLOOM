import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ssbiproject/Setting/Constvariable.dart';

class WitSensorKey {
  // Replace with your actual sensor keys
  static const String accX = 'accX';
  static const String accY = 'accY';
  // Add more keys as needed
}

class Sensor_demo extends StatefulWidget {
  const Sensor_demo({Key? key}) : super(key: key);

  @override
  _Sensor_demoState createState() => _Sensor_demoState();
}

class _Sensor_demoState extends State<Sensor_demo> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? targetDevice;
  List<int> rawData = [];
  List<String> collectedDataList = [];
  String deviceInfo = '';

  @override
  void initState() {
    super.initState();
    startScanning();
  }

  void startScanning() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.id.toString().contains('F6:8F:B3:64:8A:02')) {
          flutterBlue.stopScan();
          connectToDevice(result.device);
          break;
        }
      }
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      targetDevice = device;
      deviceInfo = 'Connected to: ${device.name ?? 'Unknown Device'}';
    });
    discoverServices(device);
  }

  void discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid.toString() ==
            '0000ffe4-0000-1000-8000-00805f9a34fb') {
          listenToCharacteristic(characteristic);
        }
      }
    }
  }

  void listenToCharacteristic(BluetoothCharacteristic characteristic) {
    characteristic.setNotifyValue(true);
    characteristic.value.listen((value) {
      // Process the raw data from the sensor
      rawData.addAll(value);

      // Display the collected data in the UI
      updateUIWithData();
    });
  }

  void updateUIWithData() {
    setState(() {
      // Convert the raw data to a string and add it to the list
      String collectedData = buildSensorData(WitSensorKey.accX);
      collectedDataList.add(collectedData);

      // You may want to clear rawData after processing or displaying it
      rawData.clear();
    });
  }

  String buildSensorData(String key) {
    // Modify this method to match your actual data extraction logic
    List<String> sensorValues = [];
    for (int i = 0; i < rawData.length; i++) {
      // Replace this with the actual logic to extract data based on the key
      String value = rawData[i].toString();
      sensorValues.add(value);
    }

    // Build a formatted string using the extracted sensor values
    return sensorValues.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sensor Data',
          style: TextStyle(
              fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(ColorVal),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(deviceInfo),
          SizedBox(height: 20),
          Text('Collecting data...'),
          Expanded(
            child: ListView.builder(
              itemCount: collectedDataList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                      'Data Point ${index + 1}: ${collectedDataList[index]}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    targetDevice?.disconnect();
    super.dispose();
  }
}
