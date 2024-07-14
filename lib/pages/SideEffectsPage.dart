import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:cloudinary_flutter/cloudinary_object.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show Uint8List, rootBundle;

final storage = FlutterSecureStorage();

class SideEffectsPage extends StatefulWidget {
  @override
  _SideEffectsPageState createState() => _SideEffectsPageState();
}

class _SideEffectsPageState extends State<SideEffectsPage> {
  String? _selectedSymptom;
  String? _selectedType;
  String? _selectedSeverity;
  String? _duration;
  String? _additionalNotes;

  List<String> _sideEffectTypes = [];
  List<String> _severities = ['Mild', 'Moderate', 'Severe'];

  List<String> selectedSideEffects = [];
  TextEditingController _otherSymptomController = TextEditingController();
  TextEditingController _otherSideEffectController = TextEditingController();
  File? _image;

  Future<void> _showCustomSideEffectDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add a custom side effect'),
          content: TextField(
            controller: _otherSideEffectController,
            decoration: InputDecoration(hintText: 'Enter side effect'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String customSideEffect = _otherSideEffectController.text;
                setState(() {
                  selectedSideEffects.add(customSideEffect);
                });
                _otherSideEffectController.clear();
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void fetchSideEffectTypes() async {
    List<String> data = [
      'Nausea',
      'Fatigue',
      'Hair loss',
      'Pain',
      'Anxiety',
      'Depression',
      'Vomiting',
      'Diarrhea',
      'Headache'
    ];
    setState(() {
      _sideEffectTypes = data;
    });
  }


  List<String> _symptoms = [
    'Unexplained weight loss',
    'Persistent fever',
    'Extreme fatigue',
    'Chronic pain',
    'Persistent cough',
    'Nausea',
    'Hair loss',
    'Fatigue',
    'Changes in taste and appetite',
    'Neutropenia'
  ];


  @override
  void initState() {
    super.initState();
    fetchSideEffectTypes();

  }

  Future<void> _getImage() async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Reporting of Adverse Effects',
            style: TextStyle(color: Colors.white , fontSize: 20 )),
        backgroundColor: Colors.blue[900],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.0),
              // Dropdown for selecting a new symptom
              Text(
                'New Symptom *',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade500,
                ),
              ),
              SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                value: _selectedSymptom,
                items: _symptoms.map((symptom) {
                  return DropdownMenuItem(
                    value: symptom,
                    child: Text(symptom, style: TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSymptom = value!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 20.0),
              // Dropdown for selecting type of adverse effect
              Text(
                'Type of Undesirable effect *',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade500,
                ),
              ),
              SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: _sideEffectTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type, style: TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 20.0),
              // Dropdown for selecting severity of adverse effect
              Text(
                'Severity *',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade500,
                ),
              ),
              SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                value: _selectedSeverity,
                items: _severities.map((severity) {
                  return DropdownMenuItem(
                    value: severity,
                    child: Text(severity, style: TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSeverity = value!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 20.0),
              // Text field for entering duration
              Text(
                'Duration (in days) *',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade500,
                ),
              ),
              SizedBox(height: 10.0),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _duration = value;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 20.0),
              // Text field for entering additional notes
              Text(
                'Additional Notes',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade500,
                ),
              ),
              SizedBox(height: 10.0),
              TextFormField(
                maxLines: 3,
                onChanged: (value) {
                  _additionalNotes = value;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Select an image',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade500,
                ),
              ),
              SizedBox(height: 10.0),
              Center(
                child: GestureDetector(
                  onTap: _getImage,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.blue.shade500),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: _image == null
                        ? Icon(Icons.add_a_photo, size: 50, color: Colors.blue.shade500)
                        : Image.file(_image!, fit: BoxFit.cover),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Reporting of Side Effects',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10.0),
              ListTile(
                title: Text('Selected side effects:', style: TextStyle(color: Colors.black)),
                subtitle: Wrap(
                  children: selectedSideEffects.map((effect) {
                    return Chip(
                      label: Text(effect, style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.blue.shade500,
                      deleteIcon: Icon(Icons.cancel, color: Colors.white),
                      onDeleted: () {
                        setState(() {
                          selectedSideEffects.remove(effect);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              ListTile(
                title: Text('Other', style: TextStyle(color: Colors.black)),
                trailing: IconButton(
                  icon: Icon(Icons.add, color: Colors.blue.shade500),
                  onPressed: _showCustomSideEffectDialog,
                ),
              ),
              SizedBox(height: 20.0),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _submitSymptomEntry();
                        // Ajoutez ici la logique de soumission des effets indésirables
                      },
                      child: Text('Submit', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                    SizedBox(width: 20.0),
                    ElevatedButton(
                      onPressed: _exportToPdf,
                      child: Text('Export to PDF', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Future<String?> _getToken() async {
    try {
      final token = await storage.read(key: 'token');
      return token;
    } catch (e) {
      print('Error retrieving token: $e');
      return null;
    }
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    final cloudName = 'asqii';
    final uploadPreset = 'eujvrqrl'; // Specify your upload preset here

    final cloudinaryURL = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

    final request = http.MultipartRequest('POST', Uri.parse(cloudinaryURL));
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['secure_url'];
    } else {
      throw Exception('Failed to upload image to Cloudinary');
    }
  }

  Future<void> _submitSymptomEntry() async {
    // Vérifier si le champ Symptôme est vide lorsque "Autre" est sélectionné
    if (_selectedSymptom == null && _otherSymptomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Please enter the Symptom field.',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.red.shade700,
        duration: Duration(seconds: 3),
      ));
      return;
    }

    // Vérifier si tous les autres champs obligatoires sont remplis
    if (_selectedType == null || _selectedSeverity == null || _duration == null || _duration!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Please complete all required fields containing *',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.red.shade600,
        duration: Duration(seconds: 3),
      ));
      return;
    }

    final symptom = _selectedSymptom == 'Autre' ? _otherSymptomController.text : _selectedSymptom;

    // Récupérer l'ID du token depuis votre système d'authentification
    final token = await _getToken();
    final userId = Jwt.parseJwt(token!)['id'];

    if (token != null) {
      // Si une image est sélectionnée, la télécharger sur Cloudinary et obtenir l'URL
      String? imageUrl = '';
      if (_image != null) {
        try {
          imageUrl = await _uploadImageToCloudinary(_image!);
        } catch (e) {
          print('Error uploading image: $e');
          // Gérer l'erreur de téléchargement de l'image
          return;
        }
      }

      // Construire les données à envoyer au backend
      final Uri url = Uri.parse('http://102.219.179.156:8082/side-effects/save');

      final http.Response response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': '$token',
        },
        body: jsonEncode(<String, dynamic>{
          'userId': userId.toString(),
          'selectedSymptom': symptom,
          'selectedType': _selectedType!,
          'selectedSeverity': _selectedSeverity!,
          'duration': _duration ?? '',
          'additionalNotes': _additionalNotes ?? '',
          'selectedSideEffects': selectedSideEffects.join(','),
          'imageUrl': imageUrl, // Envoyer l'URL de l'image au backend
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Adverse reaction successfully recorded',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Error recording adverse reaction',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.red.shade700,
          duration: Duration(seconds: 3),
        ));
      }
    }
  }


  Future<void> _exportToPdf() async {
    final pdf = pw.Document();

    final Directory? externalDir = await getExternalStorageDirectory();

    if (externalDir != null) {
      final String baseFileName = 'symptom_report';
      String fileName = '$baseFileName.pdf';

      int fileNumber = 1;
      while (await File('${externalDir.path}/$fileName').exists()) {
        fileName = '$baseFileName($fileNumber).pdf';
        fileNumber++;
      }

      final String filePath = '${externalDir.path}/$fileName';

      final Uint8List asqiiLogo = (await rootBundle.load('assets/asqii.jpg')).buffer.asUint8List();

      final pw.TextStyle titleStyle = pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue);
      final pw.TextStyle subtitleStyle = pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.grey);
      final pw.TextStyle bodyStyle = pw.TextStyle(fontSize: 12, color: PdfColors.black);

      final PdfColor primaryColor = PdfColors.blue;
      final PdfColor accentColor = PdfColors.grey;

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Container(
              padding: pw.EdgeInsets.all(30),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: accentColor)),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Image(pw.MemoryImage(asqiiLogo), width: 100),
                      pw.Text('Symptom Report', style: titleStyle),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text('Symptom Details', style: subtitleStyle),
                  pw.Divider(height: 10, color: accentColor),
                  pw.SizedBox(height: 10),
                  pw.Text('New Symptom: $_selectedSymptom', style: bodyStyle),
                  pw.SizedBox(height: 10),
                  pw.Text('Type of Undesirable effect: $_selectedType', style: bodyStyle),
                  pw.SizedBox(height: 10),
                  pw.Text('Severity: $_selectedSeverity', style: bodyStyle),
                  pw.SizedBox(height: 10),
                  pw.Text('Duration (in days): $_duration', style: bodyStyle),
                  pw.SizedBox(height: 10),
                  pw.Text('Additional Notes: $_additionalNotes', style: bodyStyle),
                  pw.SizedBox(height: 10),
                  pw.Text('Selected side effects: ${selectedSideEffects.join(", ")}', style: bodyStyle),
                  pw.SizedBox(height: 20),
                  if (_image != null) pw.Image(pw.MemoryImage(_image!.readAsBytesSync())),
                ],
              ),
            );
          },
        ),
      );

      final File file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Le rapport a été exporté en PDF avec succès dans votre téléphone'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible d\'accéder au répertoire de téléchargement externe.'),
        ),
      );
    }
  }




}


