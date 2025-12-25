import 'package:flutter/material.dart';
import 'situation_detail_screen.dart';
import '../../../services/api_department.dart';

class DiscussionScreen extends StatefulWidget {
  const DiscussionScreen({super.key});

  @override
  _DiscussionScreenState createState() => _DiscussionScreenState();
}

class _DiscussionScreenState extends State<DiscussionScreen> {
  bool isLoading = true;
  List<dynamic> situations = [];

  final List<String> fixedTopics = [
    'Gia đình',
    'Công sở',
    'Tình cảm',
    'Lừa đảo',
    'Xung đột',
  ];

  Map<String, List<Map<String, String>>> topicMap = {};

  @override
  void initState() {
    super.initState();
    fetchSituations();
  }

  Future<void> fetchSituations() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await DepartmentService.getDepartments();
      situations = data;

      topicMap.clear();
      for (var s in situations) {
        final topic = s['topic'] ?? 'Khác';
        if (!topicMap.containsKey(topic)) {
          topicMap[topic] = [];
        }
        topicMap[topic]!.add({
          'question': s['departmentName'] ?? '',
          'answer': s['description'] ?? '',
        });
      }
    } catch (e) {
      topicMap.clear();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Map<String, dynamic> getTopicStyle(String topic) {
    switch (topic.toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final topics = fixedTopics.map((topic) {
      final data = topicMap[topic] ?? [];
      final style = getTopicStyle(topic);
      return {
        'title': topic,
        'desc': 'Có ${data.length} tình huống',
        'color': style['color'],
        'icon': style['icon'],
        'data': data,
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tình huống cuộc sống'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: topics.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            final item = topics[index];
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // Chỉ mở nếu có dữ liệu
                if ((item['data'] as List).isEmpty) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SituationDetailScreen(
                      title: item['title'] as String,
                      situations: item['data'] as List<Map<String, String>>,
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                        (item['color'] as Color).withOpacity(0.15),
                        child: Icon(
                          item['icon'] as IconData,
                          size: 32,
                          color: item['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item['title'] as String,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['desc'] as String,
                        textAlign: TextAlign.center,
                        style:
                        TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
