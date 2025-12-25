import 'package:flutter/material.dart';
import '../../services/api_doctors.dart';

class DoctorListScreen extends StatefulWidget {
  @override
  _DoctorListScreenState createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  List<Map<String, dynamic>> managers = [];

  @override
  void initState() {
    super.initState();
    fetchManagers();
  }

  Future<void> fetchManagers() async {
    try {
      final data = await DoctorService.getDoctors(); // dùng cùng API, chỉ đổi tên biến
      setState(() {
        managers = data;
      });
    } catch (e) {
      print('Lỗi khi lấy danh sách: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh sách tiến sỹ / người quản lý tình huống"),
        backgroundColor: Colors.teal,
      ),
      body: managers.isEmpty
          ? Center(child: Text('Chưa có người quản lý nào'))
          : ListView.builder(
        itemCount: managers.length,
        itemBuilder: (context, index) {
          final manager = managers[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal[100],
                child: Icon(Icons.person, color: Colors.teal[700]),
              ),
              title: Text(
                manager['doctorName'] ?? 'Không rõ tên',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Email: ${manager['email'] ?? 'Chưa có'}\nPhòng ban: ${manager['departmentName'] ?? 'Không rõ'}',
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'editRole') {
                    // Thêm chỉnh role hoặc thông tin
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                      value: 'editRole', child: Text('Chỉnh role')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
