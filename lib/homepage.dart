import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'editing_page.dart';
import 'model/CompanyInfo.dart';
import 'module/CompanyInfoSelectionDialog.dart';

class HomePage extends StatefulWidget {
  final String companyName;
  final String email;
  final String facebook;
  final String linkedin;
  final String twitter;
  final String instagram;
  final String mobile;
  final String address;
  final File logo;

  const HomePage({
    Key? key,
    required this.companyName,
    required this.email,
    required this.facebook,
    required this.linkedin,
    required this.twitter,
    required this.instagram,
    required this.mobile,
    required this.address,
    required this.logo,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTemplates();
  }

  Future<void> fetchTemplates() async {
    final url = Uri.parse('http://192.168.70.148/practice_api/viewTemplate.php'); // Replace with real path
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          categories = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load templates");
      }
    } catch (e) {
      print("API Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Festival card'),
        backgroundColor: Colors.amber[700],
        actions: [Icon(Icons.search)],
        leading: Icon(Icons.menu),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(8),
        children: [
          // Big top card
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.purple),
            ),
          ),
          // Categories with templates
          for (var item in categories)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category name and see more
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['category'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to "see more" screen
                        },
                        child: const Text('see more', style: TextStyle(color: Colors.purple)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Templates preview (2 only)
                  Row(
                    children: [
                      for (var imgPath in (item['templates'] as List).take(2))
                        Expanded(
                          child: Container(
                            height: 100,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage("http://192.168.70.148/practice_api/$imgPath"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          // Customize button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => CompanyInfoSelectionDialog(
                    companyInfo: CompanyInfo(
                      name: widget.companyName,
                      email: widget.email,
                      mobile: widget.mobile,
                      address: widget.address,
                      facebook: widget.facebook,
                      linkedin: widget.linkedin,
                      twitter: widget.twitter,
                      instagram: widget.instagram,
                      logoPath: widget.logo,
                    ),
                  ),
                );
              },
              child: const Text('Customize'),
            ),



          )
        ],
      ),
    );
  }
}
