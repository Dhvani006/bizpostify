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
  final _passwordController = TextEditingController();

  File? _logoImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _pickLogo() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _logoImage = File(picked.path);
      });
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    int lines = 1,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: lines,
        obscureText: isPassword && obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Enter ${label.toLowerCase()}',
          prefixIcon: Icon(icon),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6366F1)),
          ),
        ),
        validator: required
            ? (value) => value!.isEmpty ? 'Please enter $label' : null
            : null,
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _logoImage != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        // First submit to the API
        await submitCompanyForm(
          companyName: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          facebook: _facebookController.text,
          linkedin: _linkedinController.text,
          twitter: _twitterController.text,
          instagram: _instagramController.text,
          mobile: _mobileController.text,
          address: _addressController.text,
          logo: _logoImage!,
        );

        // Then save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('company_name', _nameController.text);
        await prefs.setString('email', _emailController.text);
        await prefs.setString('password', _passwordController.text);
        await prefs.setString('facebook', _facebookController.text);
        await prefs.setString('linkedin', _linkedinController.text);
        await prefs.setString('twitter', _twitterController.text);
        await prefs.setString('instagram', _instagramController.text);
        await prefs.setString('mobile', _mobileController.text);
        await prefs.setString('address', _addressController.text);
        await prefs.setString('logo_path', _logoImage!.path);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving company information')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields and select a logo.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/splash_logo.png',
                    height: 40,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Company Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please fill in your company details',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo Upload Section
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _pickLogo,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(60),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x1A000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: _logoImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(60),
                                        child: Image.file(
                                          _logoImage!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.add_photo_alternate_outlined,
                                        size: 40,
                                        color: Color(0xFF6366F1),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Company Logo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Form Fields
                      _buildTextField(
                        'Company Name',
                        _nameController,
                        Icons.business_outlined,
                        required: true,
                      ),
                      _buildTextField(
                        'Email',
                        _emailController,
                        Icons.email_outlined,
                        required: true,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildTextField(
                        'Password',
                        _passwordController,
                        Icons.lock_outline,
                        required: true,
                        isPassword: true,
                        obscureText: _obscurePassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      _buildTextField(
                        'Mobile Number',
                        _mobileController,
                        Icons.phone_outlined,
                        required: true,
                        keyboardType: TextInputType.phone,
                      ),
                      _buildTextField(
                        'Address',
                        _addressController,
                        Icons.location_on_outlined,
                        lines: 3,
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        'Social Media Links',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        'Facebook',
                        _facebookController,
                        Icons.facebook_outlined,
                      ),
                      _buildTextField(
                        'LinkedIn',
                        _linkedinController,
                        Icons.link,
                      ),
                      _buildTextField(
                        'Twitter',
                        _twitterController,
                        Icons.alternate_email,
                      ),
                      _buildTextField(
                        'Instagram',
                        _instagramController,
                        Icons.camera_alt_outlined,
                      ),

                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF6366F1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
