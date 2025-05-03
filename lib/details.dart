import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'homepage.dart';

class CompanyFormPage extends StatefulWidget {
  @override
  _CompanyFormPageState createState() => _CompanyFormPageState();
}

class _CompanyFormPageState extends State<CompanyFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _facebookController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _twitterController = TextEditingController();
  final _instagramController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();

  File? _logoImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickLogo() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _logoImage = File(picked.path);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _logoImage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            companyName: _nameController.text,
            email: _emailController.text,
            facebook: _facebookController.text,
            linkedin: _linkedinController.text,
            twitter: _twitterController.text,
            instagram: _instagramController.text,
            mobile: _mobileController.text,
            address: _addressController.text,
            logo: _logoImage!, // already validated for null
          ),
        ),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 120,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber, Colors.brown],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                padding: const EdgeInsets.only(left: 130, top: 50),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'FESTIVAL CARD',
                  style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Image.asset(
                  'assets/images/flower.png', // <-- Path to flower image from your laptop
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Company Name'),
                      validator: (value) => value!.isEmpty ? 'Enter company name' : null,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) => value!.isEmpty ? 'Enter email' : null,
                    ),
                    TextFormField(
                      controller: _facebookController,
                      decoration: const InputDecoration(labelText: 'Facebook Link'),
                    ),
                    TextFormField(
                      controller: _linkedinController,
                      decoration: const InputDecoration(labelText: 'LinkedIn Link'),
                    ),
                    TextFormField(
                      controller: _twitterController,
                      decoration: const InputDecoration(labelText: 'Twitter Link'),
                    ),
                    TextFormField(
                      controller: _instagramController,
                      decoration: const InputDecoration(labelText: 'Instagram Link'),
                    ),
                    TextFormField(
                      controller: _mobileController,
                      decoration: const InputDecoration(labelText: 'Mobile Number'),
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.isEmpty ? 'Enter mobile number' : null,
                    ),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Company Address'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    const Text('Upload Company Logo'),
                    ElevatedButton(
                      onPressed: _pickLogo,
                      child: const Text('Choose Logo'),
                    ),
                    if (_logoImage != null)
                      Image.file(_logoImage!, height: 100),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CompanyFormPage(),
  ));
}
