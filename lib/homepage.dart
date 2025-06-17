import 'dart:convert';
import 'dart:io';
import 'package:festival_card/SeeMorePage.dart';
import 'package:festival_card/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'editing_page.dart';
import 'model/CompanyInfo.dart';
import 'module/CompanyInfoSelectionDialog.dart';
import 'details.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> priorityTemplates = [];
  List<dynamic> masterCategories = [];
  List<dynamic> selectedSubCategories = [];
  List<dynamic> selectedTemplates = [];
  String? selectedMaster;
  String? selectedCategory;
  bool isLoading = true;
  CompanyInfo companyInfo = CompanyInfo(
    name: '',
    email: '',
    mobile: '',
    address: '',
    facebook: '',
    linkedin: '',
    twitter: '',
    instagram: '',
    logoPath: '',
  );

  @override
  void initState() {
    super.initState();
    loadCompanyInfo();
    fetchTemplates();
  }

  Future<void> loadCompanyInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      companyInfo = CompanyInfo(
        name: prefs.getString('company_name') ?? '',
        email: prefs.getString('email') ?? '',
        mobile: prefs.getString('mobile') ?? '',
        address: prefs.getString('address') ?? '',
        facebook: prefs.getString('facebook') ?? '',
        linkedin: prefs.getString('linkedin') ?? '',
        twitter: prefs.getString('twitter') ?? '',
        instagram: prefs.getString('instagram') ?? '',
        logoPath: prefs.getString('logo_path') ?? '',
      );
    });
  }

  Future<void> fetchTemplates() async {
    const String apiUrl = '$baseUrl/practice_api/get_templates.php';
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
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFE8E0D3),
        title: const Text(
          'Biz Postify',
          style: TextStyle(
            color: Color(0xFF4A4A4A),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF4A4A4A)),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => CompanyInfoSelectionDialog(
                  companyInfo: companyInfo,
                ),
              );
            },
            icon: const Icon(Icons.edit, color: Color.fromARGB(255, 5, 5, 5)),
            label: const Text(
              'Customize',
              style: TextStyle(color: Color.fromARGB(255, 243, 228, 96)),
            ),
          ),
        ],
      ),
      drawer: SizedBox(
        width: 250,
        child: Drawer(
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: companyInfo.logoPath.isNotEmpty
                            ? Image.network(
                                companyInfo.logoPath.startsWith('http')
                                    ? companyInfo.logoPath
                                    : "$baseUrl/practice_api/uploaded_logo/${companyInfo.logoPath}",
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Error loading logo: $error');
                                  return const Icon(
                                    Icons.business,
                                    size: 40,
                                    color: Color(0xFF4A4A4A),
                                  );
                                },
                              )
                            : const Icon(
                                Icons.business,
                                size: 40,
                                color: Color(0xFF4A4A4A),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      companyInfo.name.isNotEmpty
                          ? companyInfo.name
                          : 'Company Name',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A4A4A),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                color: Colors.grey.withOpacity(0.1),
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF4A4A4A)),
                title: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Color(0xFF4A4A4A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CompanyFormPage(changes: true),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFF4A4A4A)),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Color(0xFF4A4A4A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear(); // Clear all stored data
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEFC997)),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Top banner
                Container(
                  height: 200,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEFC997), Color(0xFFE8E0D3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Create Beautiful Cards',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Choose from our wide range of templates',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // General Categories Section
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),

                // Master Category buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: masterCategories.map<Widget>((master) {
                      final isSelected =
                          selectedMaster == master['master_category'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? const Color(0xFFEFC997)
                                : Colors.white,
                            foregroundColor: isSelected
                                ? Colors.white
                                : const Color(0xFFEFC997),
                            elevation: isSelected ? 4 : 1,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
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
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Subcategory chips
                if (selectedSubCategories.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedSubCategories.map<Widget>((cat) {
                      final isSelected = selectedCategory == cat['category'];
                      return FilterChip(
                        label: Text(cat['category']),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = cat['category'];
                            selectedTemplates = cat['templates'];
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFFEFC997),
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF6B6B6B),
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 24),

                // Templates grid
                if (selectedTemplates.isNotEmpty) ...[
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: selectedTemplates.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final imgPath = selectedTemplates[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditingPage(
                                selectedFields: {
                                  'name': true,
                                  'email': true,
                                  'mobile': true,
                                  'address': true,
                                  'facebook': true,
                                  'linkedin': true,
                                  'twitter': true,
                                  'instagram': true,
                                  'logo': true,
                                },
                                companyInfo: companyInfo,
                                templateUrl: "$baseUrl/practice_api/$imgPath",
                              ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              "$baseUrl/practice_api/$imgPath",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],

                // Priority Categories
                for (var item in priorityTemplates)
                  _buildCategorySection(item['category'], item['templates']),
              ],
            ),
    );
  }

  Widget _buildCategorySection(String category, List<dynamic> templates) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
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
                child: const Text(
                  'See More',
                  style: TextStyle(
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: templates.take(3).map((imgPath) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditingPage(
                          selectedFields: {
                            'name': true,
                            'email': true,
                            'mobile': true,
                            'address': true,
                            'facebook': true,
                            'linkedin': true,
                            'twitter': true,
                            'instagram': true,
                            'logo': true,
                          },
                          companyInfo: companyInfo,
                          templateUrl: "$baseUrl/practice_api/$imgPath",
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 200,
                    height: 120,
                    margin: const EdgeInsets.only(right: 12),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          "$baseUrl/practice_api/$imgPath",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
