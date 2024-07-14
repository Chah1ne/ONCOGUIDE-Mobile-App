import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:patient_app/services/treatment_service.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../widgets/bottom_navigation.dart';

class AddNewTreatmentPage extends StatefulWidget {
  @override
  _AddNewTreatmentPageState createState() => _AddNewTreatmentPageState();
}

class _AddNewTreatmentPageState extends State<AddNewTreatmentPage> {
  TextEditingController _idController = TextEditingController();
  TextEditingController _birthDateController = TextEditingController(); // New controller for birth date
  final storage = FlutterSecureStorage();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  Future<String?> _getToken() async {
    try {
      // Retrieve the token from storage
      final token = await storage.read(key: 'token');
      return token;
    } catch (e) {
      print('Error retrieving token: $e');
      return null;
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Add New Treatment', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _initScanner(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Scan the QR Code',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Or',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8.0),
            TextButton(
              onPressed: () {
                _showAddIdManuallyPopup(context);
              },
              child: Text(
                'Add my ID manually',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 4,
        onTabTapped: (index) {
          // Handle bottom navigation item tapped, add logic if needed
        },
      ),
    );
  }

  void _initScanner(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _onQRViewCreated(QRViewController? controller) {
    if (controller != null) {
      this.controller = controller;
      controller.scannedDataStream.listen((scanData) {
        Navigator.pop(context); // Close the scanner dialog
        _handleScannedQRCode(context, scanData.code);
      });
    }
  }

  void _handleScannedQRCode(BuildContext context, String? qrCodeData) async {
    try {
      if (qrCodeData != null) {
        final token = await _getToken();

        if (token != null) {
          final Map<String, dynamic> decodedToken = Jwt.parseJwt(token);

          if (decodedToken.containsKey('id')) {
            int userId = decodedToken['id']; // Extract the user ID from the 'id' claim

            await AddTreatmentService.addIdManually(userId.toString(), qrCodeData, token);
            // Handle success if needed
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('QR Code scanned successfully.'),
              ),
            );
          }
        }
      } else {
        // Handle the case when the scanned QR code data is null
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR Code is null.'),
          ),
        );
      }
    } catch (error) {
      // Handle error if needed
      print('Error handling scanned QR code: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error handling scanned QR code. Please try again.'),
        ),
      );
    }
  }

  void _showAddIdManuallyPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add ID Manually'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _idController,
                decoration: InputDecoration(labelText: 'Enter your ID'),
              ),
              SizedBox(height: 16.0),
              TextField( // New text field for birth date
                controller: _birthDateController,
                decoration: InputDecoration(labelText: 'Enter your Birth Date (YYYY-MM-DD)'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _addIdManually(context, _idController.text, _birthDateController.text); // Pass birth date
                  Navigator.pop(context);
                },
                child: Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addIdManually(BuildContext context, String manuallyAddedId, String birthDate) async {
    try {
      final token = await _getToken();

      if (token != null) {
        final Map<String, dynamic> decodedToken = Jwt.parseJwt(token);

        if (decodedToken.containsKey('id')) {
          int userId = decodedToken['id']; // Extract the user ID from the 'id' claim

          // Sépare la chaîne de date en prenant uniquement la partie date (YYYY-MM-DD)
          final List<String> dateParts = birthDate.split(' ');
          final String formattedDate = dateParts.first;

          // Envoie la date formatée au back-end
          await AddTreatmentService.addIdManuallyWithBirthDate(userId.toString(), manuallyAddedId, formattedDate, token);

          // Handle success if needed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ID added manually successfully.'),
            ),
          );
        }
      }
    } catch (error) {
      // Handle error if needed
      print('Error adding ID manually: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding ID manually. Please try again.'),
        ),
      );
    }
  }




}
