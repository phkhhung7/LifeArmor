import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services//config.dart';
import '../../services/api_appointment.dart';

class MonthlyReportScreen extends StatefulWidget {
  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  int get totalUsers => appointments.map((e) => e['_id'] ?? e['patientName']).toSet().length;
  final int totalAppointments = 95;
  final double totalInteractions = 35600000; // ví dụ doanh thu → tổng tương tác
  final List<int> weeklyInteractions = [30, 25, 35, 30]; // Tuần 1 -> 4

  List<dynamic> appointments = [];

  @override
  void initState() {
    super.initState();
    fetchAppointmentData();
  }

  Future<void> fetchAppointmentData() async {
    try {
      final data = await AddAppointments.getMonthlyAppointments();
      setState(() {
        appointments = data;
      });
    } catch (e) {
      print('Lỗi khi lấy dữ liệu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Báo cáo & Thống kê tháng', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryCard(
              title: 'Tổng số người dùng',
              value: '$totalUsers người',
              icon: Icons.people,
              color: Colors.teal,
            ),
            _buildSummaryCard(
              title: 'Tổng tương tác',
              value: _formatNumber(totalInteractions),
              icon: Icons.chat_bubble,
              color: Colors.green,
            ),
            _buildSummaryCard(
              title: 'Lịch giao tiếp hoàn thành',
              value: '$totalAppointments ca',
              icon: Icons.calendar_today,
              color: Colors.purple,
            ),
            SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Số lượng tương tác theo tuần',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 250, child: _buildBarChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 50,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 10,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString()),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final weekNames = ['Tuần 1', 'Tuần 2', 'Tuần 3', 'Tuần 4'];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(weekNames[value.toInt()], style: TextStyle(fontSize: 12)),
                );
              },
              reservedSize: 30,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(weeklyInteractions.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: weeklyInteractions[index].toDouble(),
                width: 22,
                color: Colors.teal,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }
}
