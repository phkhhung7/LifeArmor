import 'package:flutter/material.dart';

class AppointmentListScreen extends StatefulWidget {
  @override
  _AppointmentListScreenState createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  List<Map<String, dynamic>> scenarios = [
    {
      'id': 'SCN001',
      'userName': 'Nguyễn Văn A',
      'scenarioOwner': 'Trần Thị B',
      'date': '2025-04-22',
      'time': '09:00 AM',
      'status': 'Chưa xử lý'
    },
    {
      'id': 'SCN002',
      'userName': 'Lê Thị C',
      'scenarioOwner': 'Nguyễn Văn D',
      'date': '2025-04-22',
      'time': '10:30 AM',
      'status': 'Đang xử lý'
    },
  ];

  void markCompleted(int index) {
    setState(() {
      scenarios[index]['status'] = 'Đã hoàn thành';
    });
  }

  void cancelScenario(int index) {
    setState(() {
      scenarios[index]['status'] = 'Đã huỷ';
    });
  }

  void viewDetails(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Chi tiết tình huống"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mã tình huống: ${scenarios[index]['id']}"),
            Text("Người dùng: ${scenarios[index]['userName']}"),
            Text("Người quản lý: ${scenarios[index]['scenarioOwner']}"),
            Text("Ngày: ${scenarios[index]['date']}"),
            Text("Giờ: ${scenarios[index]['time']}"),
            Text("Trạng thái: ${scenarios[index]['status']}"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Đóng"))
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Đã hoàn thành':
        return Colors.green;
      case 'Đã huỷ':
        return Colors.red;
      case 'Đang xử lý':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh sách tình huống"),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        itemCount: scenarios.length,
        itemBuilder: (context, index) {
          final scenario = scenarios[index];
          return Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(Icons.chat_bubble, color: _statusColor(scenario['status'])),
              title: Text('${scenario['userName']} → ${scenario['scenarioOwner']}'),
              subtitle: Text('${scenario['date']} | ${scenario['time']}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'complete') markCompleted(index);
                  if (value == 'cancel') cancelScenario(index);
                  if (value == 'view') viewDetails(index);
                },
                itemBuilder: (_) => [
                  if (scenario['status'] == 'Chưa xử lý')
                    PopupMenuItem(value: 'complete', child: Text('Hoàn thành')),
                  if (scenario['status'] != 'Đã huỷ')
                    PopupMenuItem(value: 'cancel', child: Text('Huỷ')),
                  PopupMenuItem(value: 'view', child: Text('Xem chi tiết')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
