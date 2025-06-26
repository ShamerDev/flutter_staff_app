import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'staff_form_page.dart';

class StaffListPage extends StatelessWidget {
  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final staffRef = FirebaseFirestore.instance.collection('staff');

    void showMessage(String message) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('👥 Staff Directory'),
        centerTitle: true,
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: staffRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("🔥 Firestore error: ${snapshot.error}");
            return Center(child: Text('Error loading staff'));
          }
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final staffDocs = snapshot.data!.docs;

          if (staffDocs.isEmpty) {
            return Center(
              child: Text(
                'No staff added yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: staffDocs.length,
            padding: EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final doc = staffDocs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Container(
                margin: EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple.shade100,
                      child: Icon(Icons.person, color: Colors.deepPurple),
                    ),
                    title: Text(
                      data['name'] ?? 'No Name',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text('ID: ${data['id']} • Age: ${data['age']}'),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.green),
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (_, __, ___) =>
                                        StaffFormPage(existingData: doc),
                                transitionsBuilder:
                                    (_, anim, __, child) => SlideTransition(
                                      position: Tween<Offset>(
                                        begin: Offset(1, 0),
                                        end: Offset(0, 0),
                                      ).animate(
                                        CurvedAnimation(
                                          parent: anim,
                                          curve: Curves.easeOut,
                                        ),
                                      ),
                                      child: child,
                                    ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            try {
                              await doc.reference.delete();
                              showMessage('Staff member deleted successfully');
                            } catch (e) {
                              showMessage('Failed to delete staff member');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => StaffFormPage(),
              transitionsBuilder:
                  (_, anim, __, child) =>
                      FadeTransition(opacity: anim, child: child),
            ),
          );
        },
        icon: Icon(Icons.add),
        label: Text('Add Staff'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
    );
  }
}
