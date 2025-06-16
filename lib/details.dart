import 'dart:io';
import 'package:festival_card/login_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';
import 'package:festival_card/submit_company_form.dart';

class CompanyFormPage extends StatefulWidget {
  final bool changes;
  const CompanyFormPage({Key? key, this.changes = false}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    if (widget.changes) {
      _loadExistingData();
    }
  }

  Future<void> _loadExistingData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('company_name') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _facebookController.text = prefs.getString('facebook') ?? '';
      _linkedinController.text = prefs.getString('linkedin') ?? '';
      _twitterController.text = prefs.getString('twitter') ?? '';
      _instagramController.text = prefs.getString('instagram') ?? '';
      _mobileController.text = prefs.getString('mobile') ?? '';
      _addressController.text = prefs.getString('address') ?? '';

      String? logoPath = prefs.getString('logo_path');
      if (logoPath != null && logoPath.isNotEmpty) {
        _logoImage = File(logoPath);
      }
    });
  }

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
        style: const TextStyle(color: Color(0xFF4A4A4A)),
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Enter ${label.toLowerCase()}',
          labelStyle: const TextStyle(color: Color(0xFF4A4A4A)),
          hintStyle: TextStyle(color: const Color(0xFF4A4A4A).withOpacity(0.5)),
          prefixIcon: Icon(icon, color: const Color(0xFFEFC997)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFFEFC997),
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEFC997)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEFC997)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEFC997)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
        validator: required
            ? (value) => value!.isEmpty ? 'Please enter $label' : null
            : null,
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() &&
        (widget.changes || _logoImage != null)) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (widget.changes) {
          await updateUserData(
            companyName: _nameController.text,
            email: _emailController.text,
            facebook: _facebookController.text,
            linkedin: _linkedinController.text,
            twitter: _twitterController.text,
            instagram: _instagramController.text,
            mobile: _mobileController.text,
            address: _addressController.text,
            logo: _logoImage,
          );
        } else {
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
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('company_name', _nameController.text);
        await prefs.setString('email', _emailController.text);
        await prefs.setString('facebook', _facebookController.text);
        await prefs.setString('linkedin', _linkedinController.text);
        await prefs.setString('twitter', _twitterController.text);
        await prefs.setString('instagram', _instagramController.text);
        await prefs.setString('mobile', _mobileController.text);
        await prefs.setString('address', _addressController.text);
        if (_logoImage != null) {
          await prefs.setString('logo_path', _logoImage!.path);
        }

        if (widget.changes) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.changes
              ? 'Please fill all required fields.'
              : 'Please fill all required fields and select a logo.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E0D3),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFEFC997),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.changes ? 'Edit Profile' : 'Company Information',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.changes
                        ? 'Update your company details'
                        : 'Please fill in your company details',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4A4A4A),
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
                            InkWell(
                              onTap: _pickLogo,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(60),
                                  border: Border.all(
                                    color: const Color(0xFFEFC997),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
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
                                        color: Color(0xFFEFC997),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Company Logo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A4A4A),
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
                      if (!widget.changes)
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
                          color: Color(0xFF4A4A4A),
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
                            backgroundColor: const Color(0xFFEFC997),
                            foregroundColor: const Color(0xFF4A4A4A),
                            disabledBackgroundColor:
                                const Color(0xFFEFC997).withOpacity(0.6),
                            elevation: 0,
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
                                        Color(0xFF4A4A4A)),
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
                      const SizedBox(height: 24),
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
