import 'package:flutter/material.dart';

class ClassificationResultsPage extends StatelessWidget {
  final List<Map<String, String>> results = [
    {'user': 'Người dùng 1', 'level': 'Cấp độ cao'},
    {'user': 'Người dùng 2', 'level': 'Cấp độ trung bình'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết Quả Phân Loại Tình Huống'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Kết Quả Phân Loại Tình Huống Xã Hội',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal.shade800),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final item = results[index];
                  Color levelColor = item['level'] == 'Cấp độ cao'
                      ? Colors.red
                      : item['level'] == 'Cấp độ trung bình'
                      ? Colors.orange
                      : Colors.green;

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.bar_chart, color: Colors.teal),
                      title: Text(item['user'] ?? 'Không có tên', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Mức độ: ${item['level']}', style: TextStyle(color: levelColor)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // TODO: Navigate to detailed classification result
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
