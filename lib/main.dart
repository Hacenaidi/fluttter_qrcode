import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(background: Colors.amber.shade900),
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code App'),
        backgroundColor: Colors.amber.shade900,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => QrCodeGeneratorScreen()),
                );
              },
              child: Text('Generate QR Code'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => QrCodeScannerScreen()),
                );
              },
              child: Text('Scan QR Code'),
            ),
          ],
        ),
      ),
    );
  }
}

class QrCodeGeneratorScreen extends StatefulWidget {
  final Map<String, String>? initialValues;

  QrCodeGeneratorScreen({this.initialValues});

  @override
  _QrCodeGeneratorScreenState createState() => _QrCodeGeneratorScreenState();
}

class _QrCodeGeneratorScreenState extends State<QrCodeGeneratorScreen> {
  final List<Map<String, String>> _fields = [
    {'key': '', 'value': ''}
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialValues != null) {
      widget.initialValues!.forEach((key, value) {
        _fields.add({'key': key, 'value': value});
      });
    }
  }

  void _addField() {
    setState(() {
      _fields.add({'key': '', 'value': ''});
    });
  }

  void _generateQrCode() {
    Map<String, String> data = {};
    for (var field in _fields) {
      if (field['key']!.isNotEmpty && field['value']!.isNotEmpty) {
        data[field['key']!] = field['value']!;
      }
    }

    String tlvData = encodeTLV(data);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: PrettyQr(
          data: tlvData,
          size: 200,
          roundEdges: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade900,
        title: Text('Generate QR Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _fields.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(labelText: 'key'),
                          onChanged: (value) {
                            _fields[index]['key'] = value;
                          },
                          controller: TextEditingController(
                            text: _fields[index]['key'],
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(labelText: 'Value'),
                          onChanged: (value) {
                            _fields[index]['value'] = value;
                          },
                          controller: TextEditingController(
                            text: _fields[index]['value'],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _addField,
              child: Text('Add Field'),
            ),
            ElevatedButton(
              onPressed: _generateQrCode,
              child: Text('Generate QR Code'),
            ),
          ],
        ),
      ),
    );
  }
}

class QrCodeScannerScreen extends StatefulWidget {
  @override
  _QrCodeScannerScreenState createState() => _QrCodeScannerScreenState();
}

class _QrCodeScannerScreenState extends State<QrCodeScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();

  void _onScan(BarcodeCapture barcodeCapture) {
    if (barcodeCapture.barcodes.isNotEmpty) {
      String tlv = barcodeCapture.barcodes.first.rawValue ??
          ''; // Fallback to empty string
      print('Scanned TLV: $tlv'); // Debug output

      if (tlv.isNotEmpty) {
        Map<String, String> decodedData = decodeTLV(tlv);

        // Redirect to the generator screen with the decoded values
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                QrCodeGeneratorScreen(initialValues: decodedData),
          ),
        );
      } else {
        // Handle the case where tlv is empty
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No valid QR code found.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isFlashOn = false;
    bool isFrontCamera = false;
    bool isScanCompleted = false;
    final MobileScannerController _scannerController =
        MobileScannerController();
    MobileScannerController cameraController = MobileScannerController();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade900,
        centerTitle: true,
        title: Text(
          "QR Scanner",
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: (BarcodeCapture barcodeCapture) {
                        _onScan(
                            barcodeCapture); // Call the method to handle scanned code
                      },
                    ),
                    QRScannerOverlay(
                      overlayColor: Colors.black26,
                      borderColor: Colors.amber.shade900,
                      borderRadius: 20,
                      borderStrokeWidth: 10,
                      scanAreaWidth: 250,
                      scanAreaHeight: 250,
                    )
                  ],
                )),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Place the QR code in designated area",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

class DisplayDecodedDataScreen extends StatelessWidget {
  final Map<String, String> data;

  DisplayDecodedDataScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Decoded Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: data.entries.map((entry) {
            return Text('${entry.key}: ${entry.value}');
          }).toList(),
        ),
      ),
    );
  }
}

// Encoding function
String encodeTLV(Map<String, String> data) {
  StringBuffer tlv = StringBuffer();

  data.forEach((key, value) {
    // Key type and value type definitions
    String keyType = 'LB'; // Assuming LB for label keys
    String valueType = 'VL'; // Assuming VL for value fields

    // Lengths
    int keyLength = key.length;
    int valueLength = value.length;

    // Append the TLV components
    tlv.write('$keyType$keyLength$key$valueType$valueLength$value');
  });

  return tlv.toString();
}

// Decoding function
Map<String, String> decodeTLV(String tlv) {
  Map<String, String> data = {};
  int i = 0;

  while (i < tlv.length) {
    // Read the key type (e.g., LB)
    String keyType = tlv.substring(i, i + 2);
    i += 2; // Move past key type

    // Read the key length
    int keyLength = int.tryParse(tlv[i].toString()) ?? 0;
    i++; // Move past the length character

    // Read the key value based on its length
    String key = tlv.substring(i, i + keyLength);
    i += keyLength; // Move past the key value

    // Read the value type (e.g., VL)
    String valueType = tlv.substring(i, i + 2);
    i += 2; // Move past value type

    // Read the value length
    int valueLength = int.tryParse(tlv[i].toString()) ?? 0;
    i++; // Move past the length character

    // Read the value based on its length
    String value = tlv.substring(i, i + valueLength);
    i += valueLength; // Move index past the value

    // Store the key-value pair
    data[key] = value; // Use the key as the map key
  }

  return data;
}
