import 'package:flutter/material.dart';
import '../../services/api_appointment.dart';
import 'update_medical.dart';

class AppointmentPage extends StatefulWidget {
  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  List<Map<String, dynamic>> appointments = [];

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    try {
      final data = await AddAppointments.getAppoitment();
      setState(() {
        appointments = data != null
            ? data.where((appt) => appt['id'] != null).toList()
            : [];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải tình huống: $e'), backgroundColor: Colors.red),
        );
      }
      setState(() => appointments = []);
    }
  }

  int get totalCases => appointments.length;
  int get pendingCases => appointments.where((a) => a['status'] == 'Đang chờ tư vấn').length;
  int get completedCases => appointments.where((a) => a['status'] == 'Đã tư vấn').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách tình huống'),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Thống kê trực quan
            Card(
              elevation: 4,
              color: Colors.teal.shade100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatBox('Tổng tình huống', totalCases.toString(), Icons.list_alt),
                    _StatBox('Đang chờ', pendingCases.toString(), Icons.hourglass_top),
                    _StatBox('Đã tư vấn', completedCases.toString(), Icons.check_circle),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: appointments.isEmpty
                  ? const Center(child: Text('Không có tình huống', style: TextStyle(fontSize: 18)))
                  : ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appt = appointments[index];
                  return _buildAppointmentCard(appt);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appt) {
    final userName = appt['patientName'] ?? 'Chưa có tên';
    final date = appt['date'] ?? 'Không có';
    final time = appt['time'] ?? 'Không có';
    final status = appt['status'] ?? 'Đang chờ tư vấn';

    Color statusColor = status == 'Đã tư vấn'
        ? Colors.green
        : status == 'Người dùng hủy'
        ? Colors.red
        : Colors.orange;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.chat, color: Colors.teal),
        title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ngày: $date'),
            Text('Giờ: $time'),
            Text('Trạng thái: $status', style: TextStyle(color: statusColor)),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          if (appt['id'] == null) return;
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AppointmentDetailPage(appointment: appt),
            ),
          );
          if (result == true) loadAppointments();
        },
      ),
    );
  }
}

class AppointmentDetailPage extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const AppointmentDetailPage({Key? key, required this.appointment}) : super(key: key);

  Future<void> updateStatus(BuildContext context, String id, String newStatus) async {
    try {
      await AddAppointments.updateStatus(id, newStatus);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã cập nhật trạng thái: $newStatus'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi cập nhật: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showStatusMenu(BuildContext context, String appointmentId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Cập nhật trạng thái', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.hourglass_top, color: Colors.orange),
                title: const Text('Đang chờ tư vấn'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  updateStatus(context, appointmentId, 'Đang chờ tư vấn');
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Đã tư vấn'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  updateStatus(context, appointmentId, 'Đã tư vấn');
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Người dùng hủy'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  updateStatus(context, appointmentId, 'Người dùng hủy');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appt = appointment;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết tình huống'),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Người tư vấn', appt['patientName']),
                _detailRow('Email', appt['email']),
                _detailRow('Ngày', appt['date']),
                _detailRow('Giờ', appt['time']),
                _detailRow('Khoa', appt['departmentName']),
                _detailRow('Lý do', appt['reason']),
                _detailRow('Trạng thái', appt['status']),
                _detailRow('Mã tiến sĩ', appt['doctorName']),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _showStatusMenu(context, appt['id'].toString()),
                    icon: const Icon(Icons.edit),
                    label: const Text('Cập nhật trạng thái'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text('$label: ${value ?? "Không có"}', style: const TextStyle(fontSize: 16)),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String count;
  final IconData icon;

  const _StatBox(this.label, this.count, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.teal),
        const SizedBox(height: 8),
        Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
