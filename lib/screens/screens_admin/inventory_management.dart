import 'package:flutter/material.dart';

class SituationInventory extends StatefulWidget {
  @override
  _SituationInventoryState createState() => _SituationInventoryState();
}

class _SituationInventoryState extends State<SituationInventory> {
  List<Map<String, String>> situationList = [
    {
      'name': 'Xử lý lừa đảo trực tuyến',
      'level': 'Cao',
      'type': 'An ninh số',
      'note': 'Cần đào tạo kỹ năng nhận diện',
    },
    {
      'name': 'Xin nghỉ phép khéo léo',
      'level': 'Trung bình',
      'type': 'Giao tiếp công sở',
      'note': 'Tình huống thường gặp',
    },
  ];

  void _addSituation() {
    // TODO: Hiển thị form dialog hoặc điều hướng đến màn hình thêm tình huống
  }

  void _editSituation(int index) {
    // TODO: Hiển thị form dialog hoặc điều hướng đến màn hình sửa tình huống
  }

  void _deleteSituation(int index) {
    setState(() {
      situationList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý tình huống & tài nguyên'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addSituation,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: situationList.length,
        itemBuilder: (context, index) {
          final situation = situationList[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: Icon(Icons.warning_amber_outlined, color: Colors.teal),
              title: Text(situation['name'] ?? ''),
              subtitle: Text(
                  'Mức độ: ${situation['level']} | Loại: ${situation['type']}\nGhi chú: ${situation['note']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _editSituation(index),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteSituation(index),
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
