import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_medicalRecordBlockchain.dart';
import 'medical_record_formblockchain.dart';
import 'medical_record_detail_page.dart';

class MedicalRecordListPage extends StatefulWidget {
  const MedicalRecordListPage({super.key});

  @override
  State<MedicalRecordListPage> createState() => _MedicalRecordListPageState();
}

class _MedicalRecordListPageState extends State<MedicalRecordListPage> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;

  List<Map<String, dynamic>> _records = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    try {
      final data = await MedicalRecordBlockchainService.listMedicalRecal();
      setState(() => _records = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải hồ sơ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _records = []);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _filteredRecords() {
    final q = _searchController.text.trim().toLowerCase();
    return _records.where((r) {
      final name = (r['patientName'] ?? '').toString().toLowerCase();
      final id = (r['patientId'] ?? '').toString().toLowerCase();
      if (q.isNotEmpty && !name.contains(q) && !id.contains(q)) return false;
      if (_selectedDate != null && r['visitDate'] != null) {
        final d = DateTime.parse(r['visitDate']);
        if (d.year != _selectedDate!.year ||
            d.month != _selectedDate!.month ||
            d.day != _selectedDate!.day) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _goToCreateRecord() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const MedicalRecordForm()),
    );
    if (created == true) _loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    final records = _filteredRecords();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý hồ sơ tình huống'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToCreateRecord,
        icon: const Icon(Icons.add),
        label: const Text('Tạo hồ sơ'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search & Date Filter
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Tìm theo tên người dùng / mã hồ sơ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Ngày xử lý tình huống',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_selectedDate == null ? 'Tất cả' : fmt.format(_selectedDate!)),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : records.isEmpty
                  ? const Center(
                child: Text('Không có hồ sơ', style: TextStyle(fontSize: 18)),
              )
                  : ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) =>
                    _buildRecordCard(records[index], fmt),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> r, DateFormat fmt) {
    final name = (r['patientName'] ?? '').toString();
    final id = (r['patientId'] ?? '').toString();
    final visitDate =
    r['visitDate'] != null ? fmt.format(DateTime.parse(r['visitDate'])) : '-';
    final createdAt =
    r['createdAt'] != null ? fmt.format(DateTime.parse(r['createdAt'])) : '-';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.description, color: Colors.teal),
        title: Text(name.isNotEmpty ? name : 'Không có tên',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mã hồ sơ: $id'),
            Text('Ngày xử lý: $visitDate'),
            Text('Tạo lúc: $createdAt'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          final recordId = r['_id']?.toString() ?? '';
          if (recordId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Hồ sơ không hợp lệ (thiếu ID)'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MedicalRecordDetailPage(recordId: recordId),
            ),
          );
        },
      ),
    );
  }
}
