import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'api_config.dart';

Future<void> submitCompanyForm({
  required String companyName,
  required String email,
  required String password,
  required String facebook,
  required String linkedin,
  required String twitter,
  required String instagram,
  required String mobile,
  required String address,
  required File logo,
}) async {
  try {
    final uri = Uri.parse('$baseUrl/practice_api/submit_user_data.php');
    print('Submitting form to: $uri');

    final request = http.MultipartRequest('POST', uri);

    // Add text fields
    request.fields['company_name'] = companyName;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['facebook'] = facebook;
    request.fields['linkedin'] = linkedin;
    request.fields['twitter'] = twitter;
    request.fields['instagram'] = instagram;
    request.fields['mobile'] = mobile;
    request.fields['address'] = address;

    // Add logo file
    print('Adding logo file: ${logo.path}');
    request.files.add(
      await http.MultipartFile.fromPath(
        'logo',
        logo.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    print('Sending request...');
    final streamedResponse = await request.send();
    print('Response status code: ${streamedResponse.statusCode}');

    final response = await http.Response.fromStream(streamedResponse);
    print('Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to submit form: ${response.statusCode}');
    }

    try {
      final data = jsonDecode(response.body);
      if (data['status'] != 'success') {
        throw Exception(data['message'] ?? 'Failed to submit form');
      }
    } catch (e) {
      print('Error parsing response: $e');
      throw Exception('Invalid response from server');
    }
  } catch (e) {
    print('Error in submitCompanyForm: $e');
    if (e is SocketException) {
      throw Exception(
          'Cannot connect to server. Please check your internet connection and server address.');
    }
    rethrow;
  }
}

Future<void> updateUserData({
  required String companyName,
  required String email,
  required String facebook,
  required String linkedin,
  required String twitter,
  required String instagram,
  required String mobile,
  required String address,
  File? logo,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      throw Exception('User ID not found');
    }

    print('Updating user data for ID: $userId');
    print('Company Name: $companyName');
    print('Email: $email');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/practice_api/update_user_data.php'),
    );

    // Add text fields
    request.fields['user_id'] = userId;
    request.fields['company_name'] = companyName;
    request.fields['email'] = email;
    request.fields['facebook'] = facebook;
    request.fields['linkedin'] = linkedin;
    request.fields['twitter'] = twitter;
    request.fields['instagram'] = instagram;
    request.fields['mobile'] = mobile;
    request.fields['address'] = address;

    // Add logo if provided
    if (logo != null) {
      print('Adding logo file: ${logo.path}');
      request.files.add(
        await http.MultipartFile.fromPath(
          'logo',
          logo.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    print('Sending request to: ${request.url}');
    final streamedResponse = await request.send();
    print('Response status code: ${streamedResponse.statusCode}');

    final response = await http.Response.fromStream(streamedResponse);
    print('Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile: ${response.statusCode}');
    }

    try {
      final data = jsonDecode(response.body);
      print('Decoded response: $data');

      if (data['status'] != 'success') {
        throw Exception(data['message'] ?? 'Failed to update profile');
      }

      // If logo was uploaded, save the new path
      if (logo != null && data['logo_path'] != null) {
        await prefs.setString('logo_path', data['logo_path']);
      }
    } catch (e) {
      print('Error parsing response: $e');
      throw Exception('Invalid response from server');
    }
  } catch (e) {
    print('Error in updateUserData: $e');
    if (e is SocketException) {
      throw Exception(
          'Cannot connect to server. Please check your internet connection and server address.');
    }
    rethrow;
  }
}
