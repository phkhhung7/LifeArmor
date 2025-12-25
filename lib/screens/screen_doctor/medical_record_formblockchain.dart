import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import '../../services/api_medicalRecordBlockchain.dart';

class MedicalRecordForm extends StatefulWidget {
  const MedicalRecordForm({super.key});

  @override
  State<MedicalRecordForm> createState() => _MedicalRecordFormState();
}

class _MedicalRecordFormState extends State<MedicalRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController patientIdController = TextEditingController();
  final TextEditingController doctorIdController = TextEditingController();
  final TextEditingController patientNameController = TextEditingController();
  final TextEditingController symptomsController = TextEditingController();
  final TextEditingController diagnosisController = TextEditingController();
  final TextEditingController treatmentController = TextEditingController();

  DateTime? visitDate;
  final List<XFile> attachments = [];
  final ImagePicker picker = ImagePicker();

  Future<void> pickAttachments() async {
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        attachments.addAll(pickedFiles);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tạo Hồ Sơ Tình Huống"),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(patientIdController, "Patient ID"),
                  const SizedBox(height: 12),
                  _buildTextField(doctorIdController, "Doctor ID"),
                  const SizedBox(height: 12),
                  _buildTextField(patientNameController, "Patient Name"),
                  const SizedBox(height: 12),

                  // Ngày khám
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Ngày khám: ${visitDate != null ? visitDate.toString().substring(0, 10) : 'Chưa chọn'}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            initialDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => visitDate = date);
                          }
                        },
                        child: const Text("Chọn ngày"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(symptomsController, "Triệu chứng", maxLines: 3),
                  const SizedBox(height: 12),
                  _buildTextField(diagnosisController, "Chẩn đoán", maxLines: 3),
                  const SizedBox(height: 12),
                  _buildTextField(treatmentController, "Điều trị", maxLines: 3),
                  const SizedBox(height: 16),

                  // Upload attachments
                  const Text("Tệp đính kèm (ảnh/X-ray):"),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: pickAttachments,
                    child: const Text("Chọn tệp"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...attachments.map((x) => Text("• ${p.basename(x.path)}")),

                  const SizedBox(height: 20),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text("Tạo Hồ Sơ"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      maxLines: maxLines,
      validator: (value) =>
      value == null || value.isEmpty ? "Vui lòng nhập $label" : null,
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && visitDate != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đang gửi dữ liệu...")),
      );
      try {
        await MedicalRecordBlockchainService.addMedicalRecord(
          patientId: patientIdController.text.trim(),
          doctorId: doctorIdController.text.trim(),
          patientName: patientNameController.text.trim(),
          symptoms: symptomsController.text.trim(),
          diagnosis: diagnosisController.text.trim(),
          treatment: treatmentController.text.trim(),
          visitDate: visitDate!,
          attachments: attachments,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tạo hồ sơ thành công!")),
        );
        _formKey.currentState!.reset();
        setState(() {
          visitDate = null;
          attachments.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e")),
        );
      }
    } else if (visitDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn ngày khám")),
      );
    }
  }
}
