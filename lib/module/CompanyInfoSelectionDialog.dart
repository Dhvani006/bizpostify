import 'package:flutter/material.dart';
import '../editing_page.dart';
import '../model/CompanyInfo.dart';
import '../editing_page.dart';


class CompanyInfoSelectionDialog extends StatefulWidget {
  final CompanyInfo companyInfo;
  const CompanyInfoSelectionDialog({required this.companyInfo});

  @override
  _CompanyInfoSelectionDialogState createState() => _CompanyInfoSelectionDialogState();
}

class _CompanyInfoSelectionDialogState extends State<CompanyInfoSelectionDialog> {
  Map<String, bool> selectedFields = {
    'name': true,
    'email': true,
    'mobile': false,
    'address': false,
    'facebook': false,
    'linkedin': false,
    'twitter': false,
    'instagram': false,
    'logo': true,
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Fields to Customize'),
      content: SingleChildScrollView(
        child: Column(
          children: selectedFields.keys.map((field) {
            return CheckboxListTile(
              title: Text(field.toUpperCase()),
              value: selectedFields[field],
              onChanged: (val) {
                setState(() {
                  selectedFields[field] = val!;
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            print("Selected Fields: $selectedFields");

            // First close the dialog
            Navigator.of(context).pop();

            // Then navigate to EditingPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditingPage(
                  selectedFields: selectedFields,
                  companyInfo: widget.companyInfo,
                ),
              ),
            );
          },
          child: const Text("Continue"),
        ),
      ],
    );
  }
}
