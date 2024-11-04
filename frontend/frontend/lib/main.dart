import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brain Tumor Detection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto', // Custom font
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ImageUploadPage(),
    );
  }
}

class ImageUploadPage extends StatefulWidget {
  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  File? _image;
  final picker = ImagePicker();
  String _result = '';
  String _username = '';
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _uploadImage() async {
    if (_image == null || _username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image and enter your username.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://127.0.0.1:5000/predict'),
    );

    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
    request.fields['username'] = _username;

    final response = await request.send();
    final responseData = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      final result = json.decode(responseData.body);
      setState(() {
        _result = result['tumor_detected'] ? 'Tumor Detected' : 'No Tumor Detected';
        _isLoading = false;
      });
    } else {
      setState(() {
        _result = 'Error: ${responseData.body}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Brain Tumor Detection'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Local background image
          Positioned.fill(
            child: Image.asset(
              'assets/medical_background.jpg', // Path to the local asset
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.3),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Username Input Card
                  Card(
                    color: Colors.white.withOpacity(0.8),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                          counterText: "", // Hides the counter if maxLength is set
                        ),
                        onChanged: (value) {
                          setState(() {
                            _username = value;
                          });
                        },
                        maxLength: 20, // Optional: Set a max length if needed
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Image Preview
                  Card(
                    color: Colors.white.withOpacity(0.8),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      height: 200,
                      child: _image == null
                          ? Center(
                              child: Text(
                                'No image selected.',
                                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                              ),
                            )
                          : Image.file(_image!, fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.image),
                        label: Text('Pick Image'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _pickImage,
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.cloud_upload),
                        label: Text('Upload Image'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _uploadImage,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Loading Indicator or Result
                  _isLoading
                      ? CircularProgressIndicator()
                      : Text(
                          _result,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
        child: Text(
          '© 2024 Brain Tumor Detection App',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
