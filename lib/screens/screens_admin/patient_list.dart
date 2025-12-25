import 'package:flutter/material.dart';
import './patient_detail.dart'; // bạn có thể đổi tên file này nếu muốn: user_detail.dart

class PatientListScreen extends StatelessWidget {
  final List<Map<String, String>> users = [
    {
      'name': 'Nguyễn Văn A',
      'dob': '12/05/1985',
      'gender': 'Nam',
      'phone': '0901234567',
      'role': 'Người dùng',
      'address': '123 Lê Lợi, Q1, TP.HCM'
    },
    {
      'name': 'Trần Thị B',
      'dob': '25/11/1990',
      'gender': 'Nữ',
      'phone': '0912345678',
      'role': 'Người hướng dẫn',
      'address': '456 Hai Bà Trưng, Q3, TP.HCM'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách người dùng'),
        backgroundColor: Colors.teal,
        elevation: 3,
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.teal[100],
                child: Icon(Icons.person, color: Colors.teal[800]),
              ),
              title: Text(
                user['name'] ?? '',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text("SĐT: ${user['phone']}"),
                  Text("Vai trò: ${user['role'] ?? 'Người dùng'}"),
                ],
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.teal[300]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PatientDetailScreen(patient: user),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
