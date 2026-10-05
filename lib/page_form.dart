import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  static const List<(String, String)> _fields = [
    ('fullName', 'Full Name'),
    ('age', 'Age'),
    ('dateOfBirth', 'Date of Birth'),
    ('birthplace', 'Birthplace'),
    ('address', 'Address'),
    ('elementary', 'Elementary'),
    ('elementaryYear', 'Elementary Year'),
    ('juniorHigh', 'Junior High'),
    ('juniorHighYear', 'Junior High Year'),
    ('seniorHigh', 'Senior High'),
    ('seniorHighYear', 'Senior High Year'),
    ('college', 'College'),
    ('collegeYear', 'College Year'),
    ('skill1', 'Skill 1'),
    ('skill2', 'Skill 2'),
    ('skill3', 'Skill 3'),
    ('skill4', 'Skill 4'),
    ('contactNumber', 'Contact Number'),
    ('email', 'Email'),
  ];

  final Map<String, TextEditingController> _controllers = {
    for (final (key, _) in _fields) key: TextEditingController(),
  };
  bool _isSaving = false;

  Future<void> _loadData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bio_data')
          .doc('king_barcelona')
          .get();
      final data = snapshot.data();
      if (!mounted || data == null) return;

      for (final (key, _) in _fields) {
        _controllers[key]!.text = data[key]?.toString() ?? '';
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load bio-data: $error')),
      );
    }
  }

  Future<void> _saveData() async {
    setState(() => _isSaving = true);
    try {
      final data = {
        for (final (key, _) in _fields) key: _controllers[key]!.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await FirebaseFirestore.instance
          .collection('bio_data')
          .doc('king_barcelona')
          .set(data, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bio-data saved successfully')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save bio-data: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Bio-Data')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final (key, label) in _fields) ...[
            TextField(
              controller: _controllers[key],
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
              ),
              keyboardType: key == 'email'
                  ? TextInputType.emailAddress
                  : key == 'contactNumber'
                  ? TextInputType.phone
                  : TextInputType.text,
            ),
            const SizedBox(height: 12),
          ],
          FilledButton.icon(
            onPressed: _isSaving ? null : _saveData,
            icon: _isSaving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(_isSaving ? 'Saving...' : 'Save bio-data'),
          ),
        ],
      ),
    );
  }
}
