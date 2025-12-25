import 'package:flutter/material.dart';

class PatientDetailScreen extends StatelessWidget {
  final Map<String, String> patient;

  const PatientDetailScreen({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết người dùng'),
        backgroundColor: Colors.teal,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal[100],
              child: Icon(Icons.person, size: 50, color: Colors.teal[700]),
            ),
            SizedBox(height: 16),

            // Tên người dùng
            Text(
              patient['name'] ?? '',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal[900],
              ),
            ),
            SizedBox(height: 16),

            // Thông tin chi tiết
            _buildInfoCard("Ngày sinh", patient['dob']),
            _buildInfoCard("Giới tính", patient['gender']),
            _buildInfoCard("Số điện thoại", patient['phone']),
            _buildInfoCard("Địa chỉ", patient['address']),
            SizedBox(height: 24),

            // Nút chức năng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Chuyển sang màn sửa
                  },
                  icon: Icon(Icons.edit),
                  label: Text('Sửa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    elevation: 2,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Xác nhận xoá
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Xác nhận xoá"),
                        content: Text("Bạn có chắc muốn xoá người dùng này?"),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Huỷ")
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context); // quay về danh sách
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Đã xoá người dùng"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                            child: Text("Xoá", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(Icons.delete),
                  label: Text('Xoá'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    elevation: 2,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Card hiển thị thông tin
  Widget _buildInfoCard(String label, String? value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text(
              "$label: ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Expanded(
              child: Text(value ?? '', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
