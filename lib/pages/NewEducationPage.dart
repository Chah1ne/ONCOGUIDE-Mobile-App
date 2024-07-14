import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:cloudinary_flutter/cloudinary_object.dart';

import '../widgets/DoctorBottom_navigation.dart';

final storage = FlutterSecureStorage();

class NewEducationPage extends StatefulWidget {
  @override
  _NewEducationPageState createState() => _NewEducationPageState();
}

class _NewEducationPageState extends State<NewEducationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _videoController = TextEditingController();
  TextEditingController _iconImageController = TextEditingController();
  TextEditingController _imagesController = TextEditingController();

  File? _iconImage;
  List<File> _images = [];

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

  Future<void> _getImage(bool isIconImage) async {
    List<XFile>? pickedFiles;

    if (isIconImage) {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      pickedFiles = pickedFile != null ? [pickedFile] : null;
    } else {
      pickedFiles = await ImagePicker().pickMultiImage(); // Suppression du paramètre source
    }

    setState(() {
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        if (isIconImage) {
          _iconImage = File(pickedFiles[0].path);
          _uploadIconImageToCloudinary(); // Upload the icon image immediately after selection
        } else {
          _images.addAll(pickedFiles.map((file) => File(file.path)).toList());
        }
      }
    });

    if (!isIconImage && _images.isNotEmpty) {
      // This is the first image selected for the images field
      // Perform upload to Cloudinary for the entire _images list
      await _uploadImagesToCloudinary();
    }
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
    if (_nameController.text.isEmpty ||
        _iconImage == null ||
        _descriptionController.text.isEmpty) {
      // Display error message if required fields are not filled
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

    // Validate YouTube video URL format
    if (_videoController.text.isNotEmpty &&
        !_videoController.text.startsWith('https://youtu.be/')) {
      // Display error message if video URL format is incorrect
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'The video URL link must start with "https://youtu.be/"',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.red.shade600,
        duration: Duration(seconds: 5),
      ));
      return;
    }

    final token = await storage.read(key: 'token');
    final userId = Jwt.parseJwt(token!)['id'];

    final Uri url = Uri.parse('http://102.219.179.156:8082/education/create');

    final http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'name': _nameController.text,
        'iconImage': _iconImageController.text,
        'description': _descriptionController.text,
        'images': _imagesController.text,
        'video': _videoController.text,
        'senderId': userId,
      }),
    );

    if (response.statusCode == 201) {
      // Education saved successfully
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Education successfully registered',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ));
    } else {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Error saving education',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.red.shade600,
        duration: Duration(seconds: 3),
      ));
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create a New Educational Experience',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[900],
        iconTheme: IconThemeData(color: Colors.white),

      ),
      body: Container(
        color: Colors.white, // Mettre le fond du corps en blanc
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20.0),
              Text(
                'Educational Card Name *',
                style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.w700, color: Colors.blue[900]),
              ),
              SizedBox(height: 15.0),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: 'Enter the name of the educational card',
                  hintStyle: TextStyle(color: Colors.grey[800]), // Couleur rouge pour indiquer le champ obligatoire
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Select a Cover Image *',
                style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.w700, color: Colors.blue[900]),
              ),
              SizedBox(height: 10.0),
              GestureDetector(
                onTap: () => _getImage(true), // For icon image
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(11.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: _iconImage == null
                      ? Icon(Icons.add_a_photo, size: 50, color: Colors.blue[900])
                      : Image.file(_iconImage!, width: 200, height: 200, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Description *',
                style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.w700, color: Colors.blue[900]),
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: 'Enter description',
                  hintStyle: TextStyle(color: Colors.grey[800]), // Couleur rouge pour indiquer le champ obligatoire
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Select Images',
                style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.w700, color: Colors.blue[900]),
              ),
              SizedBox(height: 10.0),
              GestureDetector(
                onTap: () => _getImage(false), // For images field
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(11.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: _images.isEmpty
                      ? Icon(Icons.add_a_photo, size: 50, color: Colors.blue[900])
                      : Image.file(_images[0], width: 200, height: 200, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'YouTube Video URL Link',
                style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.w700, color: Colors.blue[900]),
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: _videoController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: 'Enter the video URL link (optional)',
                  hintStyle: TextStyle(color: Colors.grey[800]),
                ),
              ),
              SizedBox(height: 25.0),
              ElevatedButton(
                onPressed: _saveEducation,
                child: Text(
                  'Save',
                  style: TextStyle(color: Colors.black, fontSize: 18.0),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade300),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
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
