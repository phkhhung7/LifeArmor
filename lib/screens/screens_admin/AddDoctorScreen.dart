import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import API của staff/user app
import '../../services/api_doctors.dart'; // có thể đổi tên service thành api_user.dart
import '../../services/api_department.dart'; // dùng cho danh sách "tình huống"

class AddUserScreen extends StatefulWidget {
  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  List<Map<String, dynamic>> situations = [];
  String? selectedSituationId;
  String role = 'Tiến sỹ';
  File? _image;

  @override
  void initState() {
    super.initState();
    fetchSituations();
  }

  Future<void> fetchSituations() async {
    try {
      final data = await DepartmentService.getDepartments(); // đổi thành lấy danh sách tình huống
      setState(() {
        situations = data;
      });
    } catch (e) {
      print('Lỗi khi lấy danh sách tình huống: $e');
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> saveUser() async {
    final userName = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();

    if (userName.isEmpty || selectedSituationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập tên và chọn tình huống xử lý")),
      );
      return;
    }

    final avatar = _image?.path ?? "";

    final result = await DoctorService.addDoctor( // đổi API thành addUser
      userName,
      email,
      phone,
      address,
      selectedSituationId!,
      role,
      avatar,
    );

    if (!context.mounted) return;
    if (result == 'success') {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thêm người dùng / tiến sỹ')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: _image == null
                  ? CircleAvatar(
                radius: 40,
                child: Icon(Icons.camera_alt, size: 30),
              )
                  : CircleAvatar(
                radius: 40,
                backgroundImage: FileImage(_image!),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Tên người dùng'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Số điện thoại'),
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Địa chỉ'),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Role'),
              value: role,
              items: ['Tiến sỹ', 'Người xử lý tình huống', 'Nhân viên hỗ trợ']
                  .map((r) => DropdownMenuItem(
                value: r,
                child: Text(r),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => role = value);
              },
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Tình huống xử lý'),
              value: selectedSituationId,
              items: situations.map((s) {
                final id = s['id']?.toString() ?? '';
                return DropdownMenuItem<String>(
                  value: id,
                  child: Text(s['departmentName']?.toString() ?? 'Không rõ tên'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSituationId = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveUser,
              child: Text('Lưu'),
            )
          ],
        ),
      ),
    );
  }
}
