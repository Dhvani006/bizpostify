// SeeMorePage.dart
import 'package:flutter/material.dart';

import 'api_config.dart';

class SeeMorePage extends StatelessWidget {
  final String categoryTitle;
  final List<dynamic> templates;

  const SeeMorePage({
    Key? key,
    required this.categoryTitle,
    required this.templates,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryTitle),
        backgroundColor: Colors.amber[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: GridView.builder(
          itemCount: templates.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3-column grid
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final imgPath = templates[index];
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage("$baseUrl/practice_api/$imgPath"),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
