import 'dart:io';

class CompanyInfo {
  final String name;
  final String email;
  final String mobile;
  final String address;
  final String facebook;
  final String linkedin;
  final String twitter;
  final String instagram;
  final File logoPath;

  CompanyInfo({
    required this.name,
    required this.email,
    required this.mobile,
    required this.address,
    required this.facebook,
    required this.linkedin,
    required this.twitter,
    required this.instagram,
    required this.logoPath,
  });
}
