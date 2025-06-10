import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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
