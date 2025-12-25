import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, dynamic> _user;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _genderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _user = widget.user;

    _nameController.text = _user['name'] ?? '';
    _phoneController.text = _user['phone'] ?? '';
    _addressController.text = _user['address'] ?? '';
    _genderController.text = _user['gender'] ?? '';
  }

  Future<void> _updateProfile() async {
    final result = await ApiService.updateUserInfor(
      _user['_id'],
      _nameController.text,
      _phoneController.text,
      _addressController.text,
      _genderController.text,
      _user['healthInsurance'] ?? '',
      _user['avatar'] ?? '',
    );

    if (result == 'success') {
      final prefs = await SharedPreferences.getInstance();

      final updatedUser = {
        ..._user,
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'gender': _genderController.text,
      };

      await prefs.setString('user', jsonEncode(updatedUser));
      setState(() => _user = updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✨ Cập nhật thành công!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00B4DB), Color(0xFF008350)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🌟 Câu khích lệ
                const Text(
                  'Hãy sống vui mỗi ngày bạn nha! 💙',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Hãy đảm bảo thông tin cá nhân luôn chính xác nhé!',
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 24),

                /// 👤 Thẻ Profile
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 45, color: Colors.blue),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _user['name'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _user['email'] ?? '',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// 📝 Thông tin chỉnh sửa
                _buildField(_nameController, 'Họ và tên', Icons.person),
                _buildField(_phoneController, 'Số điện thoại', Icons.phone),
                _buildField(_addressController, 'Địa chỉ', Icons.home),
                _buildField(_genderController, 'Giới tính', Icons.wc),

                const SizedBox(height: 20),

                /// ✅ Nút cập nhật
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Cập nhật thông tin',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
      TextEditingController controller,
      String label,
      IconData icon,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.white54),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
