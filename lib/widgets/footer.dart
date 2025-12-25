import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      color: Colors.teal[700],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '© 2025 - Ứng dụng Giao tiếp & Ứng xử Xã hội',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text(
                'support@socialapp.com',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              SizedBox(width: 16),
              Icon(Icons.phone, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text(
                'Hotline: 0123 456 789',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Hỗ trợ bạn giao tiếp tốt và xử lý tình huống hiệu quả mỗi ngày!',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
