import 'package:flutter/material.dart';
import 'package:flutter_application_datlichkham/screens/screens_admin/security_screens/create_account_screen.dart';
import 'package:flutter_application_datlichkham/services/api_service.dart';

class DashboardOverview extends StatefulWidget {
  @override
  _DashboardOverviewState createState() => _DashboardOverviewState();
}

class _DashboardOverviewState extends State<DashboardOverview> {
  List<dynamic> users = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getUsers();
      setState(() {
        users = data.where((u) => u['_id'] != null).toList();
      });
    } catch (e) {
      showSnackbar("Lỗi khi lấy người dùng: $e", isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _toggleUserActive(String id, String currentStatus) async {
    final newStatus = currentStatus == "activity" ? "inactive" : "activity";
    final result = await ApiService.toggleUserStatus(id, newStatus);
    if (result) {
      showSnackbar("Cập nhật trạng thái thành công");
      fetchUsers();
    } else {
      showSnackbar("Lỗi khi cập nhật trạng thái", isError: true);
    }
  }

  Future<void> _changeUserRole(String id, String newRole) async {
    final result = await ApiService.changeUserRole(id, newRole);
    if (result) {
      showSnackbar("Cập nhật vai trò thành công");
      fetchUsers();
    } else {
      showSnackbar("Lỗi khi cập nhật vai trò", isError: true);
    }
  }

  void _showRoleSelectionMenu(String userId, String currentRole) {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: ['patient', 'staff', 'doctor', 'admin']
                  .map((role) => ListTile(
                leading: Icon(Icons.person, color: Colors.teal),
                title: Text(role.toUpperCase()),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _confirmChangeRole(userId, role);
                },
              ))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  void _confirmChangeRole(String userId, String newRole) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Xác nhận đổi vai trò'),
        content: Text('Bạn có chắc muốn đổi vai trò thành "$newRole"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text('Hủy')),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _changeUserRole(userId, newRole);
            },
            child: Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _createUser() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => CreateUserScreenState()))
        .then((_) => fetchUsers());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Tổng quan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard("Người dùng", users.length.toString(), Colors.teal),
              _buildStatCard(
                  "Hoạt động",
                  users.where((u) => u['status'] == 'activity').length.toString(),
                  Colors.green),
              _buildStatCard(
                  "Không hoạt động",
                  users.where((u) => u['status'] != 'activity').length.toString(),
                  Colors.red),
            ],
          ),
          SizedBox(height: 24),
          // Danh sách người dùng
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Danh sách người dùng",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal[800])),
                      IconButton(onPressed: _createUser, icon: Icon(Icons.person_add, color: Colors.teal))
                    ],
                  ),
                  Divider(),
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : users.isEmpty
                      ? Center(child: Text("Không có dữ liệu"))
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal[100],
                            child: Icon(Icons.person, color: Colors.teal),
                          ),
                          title: Text(user['name'] ?? 'Không có tên'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("ID: ${user['_id'] ?? 'N/A'}"),
                              Text("Email: ${user['email'] ?? 'N/A'}"),
                              Text("Role: ${user['role'] ?? 'N/A'}"),
                              Text(
                                "Status: ${user['status'] ?? 'N/A'}",
                                style: TextStyle(
                                    color: user['status'] == 'activity' ? Colors.green : Colors.red),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'toggle') _toggleUserActive(user['_id'], user['status']);
                              if (value == 'change_role') _showRoleSelectionMenu(
                                  user['_id'], user['role'] ?? 'patient');
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(value: 'change_role', child: Text('Chuyển vai trò')),
                              PopupMenuItem(
                                value: 'toggle',
                                child: Text(user['status'] == 'activity'
                                    ? 'Vô hiệu hóa'
                                    : 'Kích hoạt lại'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Icon(Icons.analytics, size: 36, color: color),
              SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              SizedBox(height: 4),
              Text(title, style: TextStyle(fontSize: 14, color: Colors.black87), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
