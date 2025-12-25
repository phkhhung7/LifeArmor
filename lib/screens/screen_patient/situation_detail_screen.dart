import 'package:flutter/material.dart';

class SituationDetailScreen extends StatelessWidget {
  final String title;
  final List<Map<String, String>> situations;

  const SituationDetailScreen({
    super.key,
    required this.title,
    required this.situations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: situations.length,
        itemBuilder: (context, index) {
          final item = situations[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              title: Text(
                item['question']!,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              childrenPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                Text(
                  item['answer']!,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
