import 'package:flutter/material.dart';
import '../../../services/api_department.dart';

class SituationManagement extends StatefulWidget {
  @override
  _SituationManagementState createState() => _SituationManagementState();
}

class _SituationManagementState extends State<SituationManagement> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<dynamic> situations = [];

  // Các topic mặc định
  final List<String> fixedTopics = [
    'Gia đình',
    'Công sở',
    'Tình cảm',
    'Lừa đảo',
    'Xung đột',
  ];

  @override
  void initState() {
    super.initState();
    fetchSituations();
  }

  void showSnackbar(String message, {bool isError = false}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> fetchSituations() async {
    try {
      final data = await DepartmentService.getDepartments();
      setState(() {
        situations = data;
      });
      print("Loaded situations: $situations"); // kiểm tra dữ liệu
    } catch (e) {
      showSnackbar('Lỗi khi tải dữ liệu: $e', isError: true);
    }
  }

  Map<String, dynamic> getTopicStyle(String? topic) {
    switch (topic?.toLowerCase()) {
      case 'gia đình':
        return {'color': Colors.orange, 'icon': Icons.family_restroom};
      case 'công sở':
        return {'color': Colors.blue, 'icon': Icons.business_center};
      case 'tình cảm':
        return {'color': Colors.pink, 'icon': Icons.favorite};
      case 'lừa đảo':
        return {'color': Colors.red, 'icon': Icons.warning_amber};
      case 'xung đột':
        return {'color': Colors.purple, 'icon': Icons.people_alt};
      default:
        return {'color': Colors.grey, 'icon': Icons.topic};
    }
  }

  void _showAddEditDialog({dynamic situation}) {
    String? selectedTopic;
    final TextEditingController newTopicController = TextEditingController();

    if (situation != null) {
      _nameController.text = situation['departmentName'] ?? '';
      _descriptionController.text = situation['description'] ?? '';
      final topic = situation['topic'];
      if (fixedTopics.contains(topic)) {
        selectedTopic = topic;
      } else {
        newTopicController.text = topic ?? '';
      }
    } else {
      _nameController.clear();
      _descriptionController.clear();
      selectedTopic = null;
      newTopicController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(situation != null ? 'Chỉnh sửa tình huống' : 'Thêm tình huống mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Tên tình huống'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Mô tả tình huống'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Chọn topic có sẵn'),
                value: selectedTopic,
                items: fixedTopics.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (value) {
                  selectedTopic = value;
                  newTopicController.clear();
                },
              ),
              TextField(
                controller: newTopicController,
                decoration: InputDecoration(labelText: 'Hoặc tạo topic mới'),
                onChanged: (value) {
                  if (value.isNotEmpty) selectedTopic = null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy')),
          TextButton(
            onPressed: () async {
              final name = _nameController.text.trim();
              final description = _descriptionController.text.trim();
              final topic = newTopicController.text.trim().isNotEmpty
                  ? newTopicController.text.trim()
                  : selectedTopic;

              if (name.isEmpty || description.isEmpty || topic == null) {
                showSnackbar('Vui lòng điền đầy đủ thông tin và chọn topic', isError: true);
                return;
              }

              String result;
              if (situation != null) {
                result = await DepartmentService.updateDepartment(
                    situation['id'], name, description, topic);
              } else {
                result = await DepartmentService.addDepartment(name, description, topic);
              }

              if (!context.mounted) return;
              if (result == "success") {
                Navigator.pop(context);
                showSnackbar(situation != null ? "Cập nhật thành công" : "Thêm thành công");
                fetchSituations();
              } else {
                showSnackbar(result ?? 'Lỗi không xác định', isError: true);
              }
            },
            child: Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _deleteSituation(String id) async {
    final result = await DepartmentService.deleteDepartment(id);
    if (result == "success") {
      showSnackbar("Xóa thành công");
      fetchSituations();
    } else {
      showSnackbar(result ?? "Lỗi khi xóa", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý tình huống'),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: () => _showAddEditDialog()),
        ],
      ),
      body: situations.isEmpty
          ? Center(child: Text('Không có dữ liệu'))
          : ListView.builder(
        itemCount: situations.length,
        itemBuilder: (context, index) {
          final situation = situations[index];
          final topic = situation['topic'] ?? 'Không rõ';
          final style = getTopicStyle(topic);

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: (style['color'] as Color).withOpacity(0.2),
                child: Icon(style['icon'] as IconData, color: style['color'] as Color),
              ),
              title: Text(situation['departmentName'] ?? ''),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(situation['description'] ?? ''),
                  SizedBox(height: 4),
                  Text(
                    'Chủ đề: $topic',
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        color: Colors.grey[700]),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showAddEditDialog(situation: situation),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteSituation(situation['id']),
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
