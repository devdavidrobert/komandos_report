import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(SalesDataApp());
}

class SalesDataApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FMCG Sales Data',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SalesDataForm(),
    );
  }
}

class SalesDataForm extends StatefulWidget {
  @override
  _SalesDataFormState createState() => _SalesDataFormState();
}

class _SalesDataFormState extends State<SalesDataForm> {
  final _formKey = GlobalKey<FormState>();
  String? _outletName;
  String? _availability;
  int? _casesBought;
  File? _outletPhoto;
  Position? _currentPosition;
  final ImagePicker _picker = ImagePicker();

  // Get current location
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }

      _currentPosition = await Geolocator.getCurrentPosition();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  // Pick image from camera
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _outletPhoto = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sales Data Collection')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Geolocation
                ElevatedButton(
                  onPressed: _getCurrentLocation,
                  child: Text('Get Location'),
                ),
                Text(_currentPosition != null
                    ? 'Lat: ${_currentPosition!.latitude}, Long: ${_currentPosition!.longitude}'
                    : 'Location not captured'),

                // Outlet Name
                TextFormField(
                  decoration: InputDecoration(labelText: 'Outlet Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter outlet name';
                    }
                    return null;
                  },
                  onSaved: (value) => _outletName = value,
                ),

                // Availability Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Availability'),
                  items: ['Yes', 'No']
                      .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select availability';
                    }
                    return null;
                  },
                  onChanged: (value) => _availability = value,
                ),

                // Cases Bought
                TextFormField(
                  decoration: InputDecoration(labelText: 'Cases Bought'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter number of cases';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) => _casesBought = int.parse(value!),
                ),

                // Photo Upload
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Take Outlet Photo'),
                ),
                _outletPhoto != null
                    ? Image.file(_outletPhoto!, height: 200)
                    : Container(),

                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Here you would typically send data to backend
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Form submitted successfully')),
                      );
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}