import 'package:flutter/material.dart';

class StaffManagement extends StatefulWidget {
  @override
  _StaffManagementState createState() => _StaffManagementState();
}

class _StaffManagementState extends State<StaffManagement> {
  List<Map<String, String>> staffList = [
    {
      'name': 'Nguyễn Văn A',
      'role': 'Tiến sỹ',
      'email': 'a@example.com',
    },
    {
      'name': 'Trần Thị B',
      'role': 'Người xử lý tình huống',
      'email': 'b@example.com',
    },
  ];

  void _addStaff() {
    _showStaffDialog();
  }

  void _editStaff(int index) {
    _showStaffDialog(staff: staffList[index], index: index);
  }

  void _deleteStaff(int index) {
    setState(() {
      staffList.removeAt(index);
    });
  }

  void _showStaffDialog({Map<String, String>? staff, int? index}) {
    final nameController = TextEditingController(text: staff?['name'] ?? '');
    final emailController = TextEditingController(text: staff?['email'] ?? '');
    String role = staff?['role'] ?? 'Tiến sỹ';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(staff == null ? 'Thêm người dùng' : 'Chỉnh sửa người dùng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Tên'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            DropdownButtonFormField<String>(
              value: role,
              decoration: InputDecoration(labelText: 'Role'),
              items: [
                'Tiến sỹ',
                'Người xử lý tình huống',
                'Nhân viên hỗ trợ',
              ]
                  .map((r) => DropdownMenuItem(
                value: r,
                child: Text(r),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) role = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Huỷ'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text(staff == null ? 'Thêm' : 'Lưu'),
            onPressed: () {
              if (nameController.text.isEmpty || emailController.text.isEmpty)
                return;
              setState(() {
                final newStaff = {
                  'name': nameController.text,
                  'email': emailController.text,
                  'role': role,
                };
                if (index != null) {
                  staffList[index] = newStaff;
                } else {
                  staffList.add(newStaff);
                }
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý người dùng'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addStaff,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: staffList.length,
        itemBuilder: (context, index) {
          final staff = staffList[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal[100],
                child: Text(
                  staff['name']![0],
                  style: TextStyle(color: Colors.teal[800]),
                ),
              ),
              title: Text(
                staff['name'] ?? '',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${staff['role']} - ${staff['email']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _editStaff(index),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteStaff(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
