import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_medicalRecordBlockchain.dart';

class MedicalRecordDetailPage extends StatefulWidget {
  final String recordId;

  const MedicalRecordDetailPage({super.key, required this.recordId});

  @override
  State<MedicalRecordDetailPage> createState() =>
      _MedicalRecordDetailPageState();
}

class _MedicalRecordDetailPageState extends State<MedicalRecordDetailPage> {
  Map<String, dynamic>? record;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final data = await MedicalRecordBlockchainService.getMedicalRecordDetail(
        widget.recordId,
      );
      setState(() {
        record = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      debugPrint('❌ Lỗi load chi tiết: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (record == null) {
      return const Scaffold(
        body: Center(child: Text('Không tải được hồ sơ')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết hồ sơ tình huống'),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin cơ bản về tình huống
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '👤 Thông tin người dùng',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    _infoRow('Tên', record!['patientName'] ?? '-'),
                    _infoRow('ID', record!['patientId'] ?? '-'),
                    _infoRow('Ngày xử lý', record!['visitDate'] ?? '-'),
                    _infoRow('Tạo lúc', record!['createdAt'] ?? '-'),
                    _infoRow('Mô tả tình huống', record!['reason'] ?? '-'),
                    _infoRow('Người tư vấn', record!['doctorName'] ?? '-'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Blockchain section
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🛡️ XÁC MINH BLOCKCHAIN',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    _infoRow('PDF Hash', record!['pdfHash']?.toString()),
                    _infoRow('IPFS Hash', record!['ipfsHash']?.toString()),
                    _infoRow('TX Hash', record!['blockchainTx']?.toString()),
                    _infoRow('Block', record!['blockNumber']?.toString()),
                    _infoRow('Network',
                        record!['blockchainNetwork']?.toString() ?? 'Sepolia'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.verified),
                      label: const Text('XÁC MINH BLOCKCHAIN'),
                      onPressed: record!['blockchainTx'] == null
                          ? null
                          : () => _openEtherscan(record!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Tải PDF'),
                    onPressed: record!['pdfUrl'] == null
                        ? null
                        : () => _openPdf(record!['pdfUrl']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tạo phiên bản mới'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Chức năng tạo phiên bản mới (TODO)'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // 🔗 HELPERS
  // =========================
  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value ?? '-',
              style: const TextStyle(fontFamily: 'monospace'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _openPdf(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openEtherscan(Map<String, dynamic> r) async {
    final tx = r['blockchainTx'];
    if (tx == null) return;

    final network = (r['blockchainNetwork'] ?? 'sepolia').toString();
    final baseUrl = network == 'sepolia'
        ? 'https://sepolia.etherscan.io/tx/'
        : 'https://etherscan.io/tx/';

    final uri = Uri.parse('$baseUrl$tx');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
