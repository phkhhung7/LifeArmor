import 'package:flutter/material.dart';
import '../../widgets/doctor_card.dart';
import '../../models/doctor.dart';
import 'doctor_detail_screen.dart';

class DoctorsScreen extends StatelessWidget {
  final List<Doctor> doctors = [
    Doctor(
      name: 'TS. Lê Minh Anh',
      specialty: 'Tâm lý học, Giao tiếp xã hội',
      imageUrl: 'assets/doctor1.jpg',
      hospital: 'Trung tâm Tâm lý ABC',
      experience: 15,
      description:
      'Chuyên gia tâm lý học và giao tiếp xã hội, có hơn 15 năm kinh nghiệm tư vấn cá nhân và nhóm.',
      phone: '0987 654 321',
      email: 'leminhanh@psychology.com',
      address: '123 Nguyễn Trãi, Hà Nội',
      workingHours: 'Thứ 2 - Thứ 6 (09:00 - 18:00)',
      bookingLink:
      'https://docs.google.com/forms/d/e/1FAIpQLSfPsych1/viewform',
    ),
    Doctor(
      name: 'TS. Nguyễn Thị Bích Hạnh',
      specialty: 'Tâm lý lâm sàng, Giao tiếp xã hội',
      imageUrl: 'assets/doctor2.jpg',
      hospital: 'Trung tâm Tâm lý DEF',
      experience: 12,
      description:
      'Chuyên khám và tư vấn tâm lý lâm sàng, hỗ trợ kỹ năng giao tiếp xã hội cho mọi lứa tuổi.',
      phone: '0976 543 210',
      email: 'nguyenthihan@psychology.com',
      address: '45 Lý Thường Kiệt, Hà Nội',
      workingHours: 'Thứ 2 - Thứ 6 (08:00 - 17:00)',
      bookingLink:
      'https://docs.google.com/forms/d/e/1FAIpQLSfPsych2/viewform',
    ),
    Doctor(
      name: 'TS. Trần Hoàng Tú',
      specialty: 'Tâm lý học phát triển, Tư vấn giao tiếp',
      imageUrl: 'assets/doctor3.jpg',
      hospital: 'Trung tâm Tâm lý GHI',
      experience: 18,
      description:
      'Chuyên gia tâm lý phát triển và tư vấn giao tiếp, có kinh nghiệm hơn 18 năm trong lĩnh vực tư vấn cá nhân và nhóm.',
      phone: '0934 567 890',
      email: 'tranhoangtu@psychology.com',
      address: '201B Nguyễn Chí Thanh, TP. HCM',
      workingHours: 'Thứ 3 - Thứ 7 (08:00 - 17:00)',
      bookingLink:
      'https://docs.google.com/forms/d/e/1FAIpQLSfPsych3/viewform',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Danh sách Tiến sĩ Tâm lý')),
      body: ListView.builder(
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DoctorDetailScreen(doctor: doctors[index]),
                ),
              );
            },
            child: DoctorCard(doctor: doctors[index]),
          );
        },
      ),
    );
  }
}
