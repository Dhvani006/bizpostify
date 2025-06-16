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
  final uri = Uri.parse(
      '$baseUrl/practice_api/submit_user_data.php'); // <-- Replace with your actual domain
  final request = http.MultipartRequest('POST', uri);

  request.fields['company_name'] = companyName;
  request.fields['email'] = email;
  request.fields['password'] = password;
  request.fields['facebook'] = facebook;
  request.fields['linkedin'] = linkedin;
  request.fields['twitter'] = twitter;
  request.fields['instagram'] = instagram;
  request.fields['mobile'] = mobile;
  request.fields['address'] = address;

  request.files.add(await http.MultipartFile.fromPath(
    'logo',
    logo.path,
    contentType: MediaType('image', 'jpeg'),
  ));

  final response = await request.send();

  if (response.statusCode == 200) {
    print("Uploaded successfully");
  } else {
    print("Failed to upload");
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
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('user_id');

  if (userId == null) {
    throw Exception('User ID not found');
  }

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
    request.files.add(
      await http.MultipartFile.fromPath(
        'logo',
        logo.path,
      ),
    );
  }

  final response = await request.send();
  final responseData = await response.stream.bytesToString();
  final data = jsonDecode(responseData);

  if (data['status'] != 'success') {
    throw Exception(data['message'] ?? 'Failed to update profile');
  }
}
