import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';
import 'package:festival_card/submit_company_form.dart';

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

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _logoImage != null) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('company_name', _nameController.text);
      await prefs.setString('email', _emailController.text);
      await prefs.setString('facebook', _facebookController.text);
      await prefs.setString('linkedin', _linkedinController.text);
      await prefs.setString('twitter', _twitterController.text);
      await prefs.setString('instagram', _instagramController.text);
      await prefs.setString('mobile', _mobileController.text);
      await prefs.setString('address', _addressController.text);
      await prefs.setString('logo_path', _logoImage!.path);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E5), // Light beige background
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 150,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFFFD8A9), // Soft peach (logo's background)
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/splash_logo.png', // Make sure this matches your logo's asset path
                  height: 80,
                ),
                const SizedBox(width: 12),
                const Text(
                  'FESTIVAL CARD',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField('Company Name', _nameController, required: true),
                        _buildTextField('Email', _emailController, required: true),
                        _buildTextField('Facebook Link', _facebookController),
                        _buildTextField('LinkedIn Link', _linkedinController),
                        _buildTextField('Twitter Link', _twitterController),
                        _buildTextField('Instagram Link', _instagramController),
                        _buildTextField(
                          'Mobile Number',
                          _mobileController,
                          required: true,
                          inputType: TextInputType.phone,
                        ),
                        _buildTextField(
                          'Company Address',
                          _addressController,
                          lines: 2,
                        ),

                        const SizedBox(height: 20),
                        const Text(
                          'Upload Company Logo',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _pickLogo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF333333),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Choose Logo'),
                        ),
                        if (_logoImage != null) ...[
                          const SizedBox(height: 10),
                          Image.file(_logoImage!, height: 100),
                        ],
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate() && _logoImage != null) {
                              await submitCompanyForm(
                                companyName: _nameController.text,
                                email: _emailController.text,
                                facebook: _facebookController.text,
                                linkedin: _linkedinController.text,
                                twitter: _twitterController.text,
                                instagram: _instagramController.text,
                                mobile: _mobileController.text,
                                address: _addressController.text,
                                logo: _logoImage!,
                              );
                              _submitForm();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please fill all required fields and select a logo."),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF111111),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        bool required = false,
        TextInputType inputType = TextInputType.text,
        int lines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: lines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: required ? (value) => value!.isEmpty ? 'Enter $label' : null : null,
      ),
    );
  }

}
