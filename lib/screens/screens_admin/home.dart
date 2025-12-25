import 'package:flutter/material.dart';
import 'package:flutter_application_datlichkham/screens/screen_authencication/login_screen.dart';
import 'patient_list.dart';
import 'appoitment.dart';
import 'overview.dart';
import 'doctor_list.dart';
import 'staff_list.dart';
import 'inventory_management.dart';
import 'report_statistics.dart';
import 'departmenr_screens/department_management.dart';
import 'security_screens/security_ayth.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedMenuIndex = 0;

  final List<Widget> pages = [
    DashboardOverview(),       // Tổng quan
    PatientListScreen(),       // Người dùng
    AppointmentListScreen(),   // Lịch giao tiếp / tình huống
    DoctorListScreen(),        // Người hướng dẫn
    StaffManagement(),         // Nhân viên / Hỗ trợ
    SituationInventory(),       // Quản lý tài nguyên / kho dữ liệu
    MonthlyReportScreen(),     // Báo cáo & Thống kê
    SituationManagement(),    // Quản lý tình huống
    UserManagementScreen(),    // Bảo mật & Phân quyền
  ];

  void onSelectMenu(int index) {
    setState(() {
      selectedMenuIndex = index;
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        elevation: 4,
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.teal[50],
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal, Colors.teal[300]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.people, size: 32, color: Colors.teal),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Quản trị viên",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Ứng dụng Giao tiếp & Ứng xử",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(Icons.dashboard, 'Tổng quan', 0),
              _buildDrawerItem(Icons.people, 'Người dùng', 1),
              _buildDrawerItem(Icons.calendar_today, 'Lịch giao tiếp', 2),
              _buildDrawerItem(Icons.person, 'Người hướng dẫn', 3),
              _buildDrawerItem(Icons.medical_services, 'Nhân viên', 4),
              _buildDrawerItem(Icons.add_business_sharp, 'Quản lý tài nguyên', 5),
              _buildDrawerItem(Icons.bar_chart_sharp, 'Báo cáo & Thống kê', 6),
              _buildDrawerItem(Icons.business, 'Quản lý tình huống', 7),
              _buildDrawerItem(Icons.security_sharp, 'Bảo mật & Phân quyền', 8),
              Divider(thickness: 1, color: Colors.teal[200]),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.teal[800]),
                title: Text('Đăng xuất', style: TextStyle(color: Colors.teal[800])),
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: pages[selectedMenuIndex],
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    final isSelected = selectedMenuIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.teal : Colors.teal[700]),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.teal[900] : Colors.teal[800],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? Colors.teal[100] : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () => onSelectMenu(index),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
