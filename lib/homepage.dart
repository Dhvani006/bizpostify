import 'dart:convert';
import 'dart:io';
import 'package:festival_card/SeeMorePage.dart';
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
  List<dynamic> priorityTemplates = [];
  List<dynamic> masterCategories = [];
  List<dynamic> selectedSubCategories = [];
  List<dynamic> selectedTemplates = [];
  String? selectedMaster;
  String? selectedCategory;
  bool isLoading = true;
  //try

  @override
  void initState() {
    super.initState();
    fetchTemplates();
  }

  Future<void> fetchTemplates() async {
    const String apiUrl = 'http://172.27.61.186/practice_api/get_templates.php';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          priorityTemplates = data['priority'] ?? [];
          masterCategories = data['general'] ?? [];
          isLoading = false;
        });
      } else {
        print('Failed to fetch templates');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching templates: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Festival card'),
        backgroundColor: Colors.amber[700],
        leading: const Icon(Icons.menu),
        actions: [
          TextButton.icon(
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
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text(
              'Customize',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(8),
        children: [
          // Top banner
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.purple),
            ),
          ),

          // ---------- General Category Section ----------
          const Text(
            'General Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Master Category buttons
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: masterCategories.map<Widget>((master) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedMaster == master['master_category']
                      ? Colors.purple
                      : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    selectedMaster = master['master_category'];
                    selectedSubCategories = master['categories'];
                    selectedCategory = null;
                    selectedTemplates = [];
                  });
                },
                child: Text(master['master_category']),
              );
            }).toList(),
          ),

          const SizedBox(height: 10),

          // Subcategory buttons
          if (selectedSubCategories.isNotEmpty)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: selectedSubCategories.map<Widget>((cat) {
                return OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                    selectedCategory == cat['category'] ? Colors.amber[200] : null,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedCategory = cat['category'];
                      selectedTemplates = cat['templates'];
                    });
                  },
                  child: Text(cat['category']),
                );
              }).toList(),
            ),

          const SizedBox(height: 10),

          // Templates grid
          if (selectedTemplates.isNotEmpty)
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: selectedTemplates.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final imgPath = selectedTemplates[index];
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage("http://172.27.61.186/practice_api/$imgPath"),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 30),

          // ---------- Priority Categories ----------
          for (var item in priorityTemplates)
            _buildCategorySection(item['category'], item['templates']),

          const SizedBox(height: 20),




        ],
      ),
    );
  }

  Widget _buildCategorySection(String category, List<dynamic> templates) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category title and See More
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SeeMorePage(
                        categoryTitle: category,
                        templates: templates,
                      ),
                    ),
                  );
                },
                child: const Text('see more', style: TextStyle(color: Colors.purple)),
              ),

            ],
          ),
          const SizedBox(height: 8),

          // 2 template preview
          Row(
            children: [
              for (var imgPath in templates.take(2))
                Expanded(
                  child: Container(
                    height: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage("http://172.27.61.186/practice_api/$imgPath"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
