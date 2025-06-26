import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StaffFormPage extends StatefulWidget {
  final DocumentSnapshot? existingData;

  StaffFormPage({this.existingData});

  @override
  _StaffFormPageState createState() => _StaffFormPageState();
}

class _StaffFormPageState extends State<StaffFormPage> {
  final nameController = TextEditingController();
  final idController = TextEditingController();
  final ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      final data = widget.existingData!.data() as Map<String, dynamic>;
      nameController.text = data['name'] ?? '';
      idController.text = data['id'] ?? '';
      ageController.text = data['age'].toString();
    }
  }

  Future<void> submitData() async {
    final name = nameController.text.trim();
    final id = idController.text.trim();
    final age = int.tryParse(ageController.text.trim());

    if (name.length < 3) {
      showMessage('Name must be at least 3 characters');
      return;
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      showMessage('Name must contain only letters and spaces');
      return;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(id)) {
      showMessage('ID must be numeric');
      return;
    }
    if (age == null || age < 18 || age > 65) {
      showMessage('Age must be between 18 and 65');
      return;
    }

    try {
      if (widget.existingData != null) {
        await widget.existingData!.reference.update({
          'name': name,
          'id': id,
          'age': age,
        });
      } else {
        await FirebaseFirestore.instance.collection('staff').add({
          'name': name,
          'id': id,
          'age': age,
        });
      }
      Navigator.pop(context);
    } catch (e) {
      print('❌ Failed to save: $e');
      showMessage('Failed to save. Check Firebase setup.');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _handleBack() async {
    Navigator.pop(context);
    return false;
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      keyboardType: inputType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBack,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.existingData != null ? 'Edit Staff' : 'Add New Staff',
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _handleBack,
          ),
          centerTitle: true,
          elevation: 2,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existingData != null
                    ? 'Update staff details below.'
                    : 'Enter new staff details.',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 24),
              buildTextField(controller: nameController, label: 'Full Name'),
              SizedBox(height: 16),
              buildTextField(
                controller: idController,
                label: 'Staff ID',
                inputType: TextInputType.number,
              ),
              SizedBox(height: 16),
              buildTextField(
                controller: ageController,
                label: 'Age',
                inputType: TextInputType.number,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: submitData,
                icon: Icon(
                  widget.existingData != null ? Icons.save : Icons.send,
                ),
                label: Text(
                  widget.existingData != null ? 'Update Staff' : 'Submit',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
