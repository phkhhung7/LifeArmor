import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AIChatScreen extends StatefulWidget {
  @override
  _AIChatScreenState createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _instructionController = TextEditingController();
  final TextEditingController _contextController = TextEditingController();

  final List<Map<String, String>> messages = [];

  // Gửi dữ liệu tới backend Flask
  Future<String> sendToAI(String category, String instruction, String context) async {
    final url = Uri.parse('http://10.0.2.2:5000/predict/'); // Chạy trên emulator

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "category": category,
        "instruction": instruction,
        "context": context,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response']; // Backend trả về {"response": "..."}
    } else {
      throw Exception('Backend error: ${response.body}');
    }
  }

  // Gửi tin nhắn
  void _sendMessage() async {
    final category = _categoryController.text.trim();
    final instruction = _instructionController.text.trim();
    final context = _contextController.text.trim();

    if (instruction.isEmpty) return;

    setState(() {
      messages.add({'role': 'user', 'message': instruction});
    });

    _instructionController.clear();

    try {
      setState(() {
        messages.add({'role': 'ai', 'message': 'AI đang trả lời...'});
      });

      final reply = await sendToAI(category.isEmpty ? "Chung" : category, instruction, context);

      setState(() {
        messages.removeLast();
        messages.add({'role': 'ai', 'message': reply});
      });
    } catch (e) {
      setState(() {
        messages.removeLast();
        messages.add({'role': 'ai', 'message': '❌ Lỗi kết nối AI'});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Chat'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.teal : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['message']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _instructionController,
                    decoration: InputDecoration(
                      hintText: 'Nhập instruction (tin nhắn)...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.teal),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
