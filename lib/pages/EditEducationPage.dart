import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decode/jwt_decode.dart';

final storage = FlutterSecureStorage();

class EditEducationPage extends StatefulWidget {
  final Map<String, dynamic> cardDetails;

  const EditEducationPage({Key? key, required this.cardDetails}) : super(key: key);

  @override
  _EditEducationPageState createState() => _EditEducationPageState();
}

class _EditEducationPageState extends State<EditEducationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _videoController = TextEditingController();
  TextEditingController _iconImageController = TextEditingController();
  TextEditingController _imagesController = TextEditingController();

  File? _iconImage;
  List<File> _images = [];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.cardDetails['name'];
    _descriptionController.text = widget.cardDetails['description'] ?? '';
    _videoController.text = widget.cardDetails['video'] ?? '';
    _iconImageController.text = widget.cardDetails['iconImage'] ?? '';
    _imagesController.text = widget.cardDetails['images'] ?? '';
  }

  Future<void> _uploadIconImageToCloudinary() async {
    try {
      final imageUrl = await _uploadImageToCloudinary(_iconImage!);
      setState(() {
        _iconImageController.text = imageUrl;
      });
    } catch (e) {
      print('Error uploading icon image: $e');
      // Handle error uploading icon image
    }
  }

  Future<void> _getImageForIconImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _iconImage = File(pickedFile.path);
        _uploadIconImageToCloudinary();
      }
    });
  }

  Future<void> _uploadImagesToCloudinary() async {
    List<String> imageUrls = []; // Utiliser une liste pour stocker les URLs des images
    for (int i = 0; i < _images.length; i++) {
      try {
        final imageUrl = await _uploadImageToCloudinary(_images[i]);
        imageUrls.add(imageUrl); // Ajouter l'URL de l'image à la liste des URLs
      } catch (e) {
        print('Error uploading image ${i + 1}: $e');
        // Handle error uploading individual image
      }
    }
    setState(() {
      _imagesController.text = imageUrls.join(','); // Convertir la liste en chaîne séparée par des virgules
    });
  }

  Future<void> _getImageForImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage(); // Utilisation de pickMultiImage pour permettre la sélection de plusieurs images

    setState(() {
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        _images.addAll(pickedFiles.map((file) => File(file.path)).toList());
        _uploadImagesToCloudinary(); // Upload des images sélectionnées vers Cloudinary
      }
    });
  }


  Future<String> _uploadImageToCloudinary(File imageFile) async {
    final cloudName = 'asqii';
    final uploadPreset = 'gfyvogrn'; // Specify your upload preset here

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

  Future<void> _saveEducation() async {
    final token = await storage.read(key: 'token');
    final userId = Jwt.parseJwt(token!)['id'];

    final Uri url = Uri.parse('http://102.219.179.156:8082/education/update/${widget.cardDetails['id']}');

    final http.Response response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'name': _nameController.text,
        'iconImage': _iconImageController.text,
        'description': _descriptionController.text,
        'images': _imagesController.text, // Utiliser les nouvelles URL des images
        'video': _videoController.text,
        'senderId': userId,
      }),
    );

    if (response.statusCode == 200) {
      // Education updated successfully
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Education successfully updated'),
        duration: Duration(seconds: 2),
      ));
    } else {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error updating education'),
        duration: Duration(seconds: 2),
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit an educational experience',
            style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[900],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.white, // Mettre le fond du corps en blanc
        child: SingleChildScrollView(
          padding: EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16.0),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Educational Card Name',
                  labelStyle: TextStyle(color: Colors.blue[900],fontSize: 19,fontWeight: FontWeight.bold), // labelText en bleu
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black), // Bord noir

                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Select a cover image',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              GestureDetector(
                onTap: () => _getImageForIconImage(),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.blue.shade900),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: _iconImage == null
                      ? Icon(Icons.add_a_photo, size: 50, color: Colors.blue.shade800)
                      : Image.file(_iconImage!, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.blue[900],fontSize: 19,fontWeight: FontWeight.bold), // labelText en bleu
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black), // Bord noir

                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Select images',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              GestureDetector(
                onTap: () => _getImageForImages(),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.blue.shade900),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: _images.isEmpty
                      ? Icon(Icons.add_a_photo, size: 50, color: Colors.blue.shade800)
                      : Image.file(_images[0], fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _videoController,
                decoration: InputDecoration(
                  labelText: 'Link Url Video',
                  labelStyle: TextStyle(color: Colors.blue[900],fontSize: 16,fontWeight: FontWeight.bold), // labelText en bleu
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black), // Bord noir

                  ),
                ),
              ),
              SizedBox(height: 25.0),
              ElevatedButton(
                onPressed: _saveEducation,
                child: Text('Save',style: TextStyle(color: Colors.black, fontSize: 18.0),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade300),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
