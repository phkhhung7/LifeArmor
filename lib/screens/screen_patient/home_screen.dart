import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_application_datlichkham/screens/screen_authencication/login_screen.dart';
import 'package:flutter_application_datlichkham/screens/screen_authencication/register_screen.dart';
import 'package:flutter_application_datlichkham/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'doctors_screen.dart';
import 'booking_screen.dart';
import 'profile_screen.dart';
import 'discussion_screen.dart';
import '../screen_doctor/doctor_home_screen.dart';
import '../screens_admin/home.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _user;
  List<Map<String, dynamic>> diagnosisHistory = [];
  bool isLoading = true;
  String? userId;
  String? errorMessage;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    print("_loadUserData: Bắt đầu...");
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final userData = await ApiService.getCurrentUser();
      print("_loadUserData: userData = $userData");
      if (userData != null) {
        setState(() {
          _user = userData;
          userId = userData['_id']?.toString();
          print("_loadUserData: userId = $userId");
        });
        await fetchUserInfor();
      } else {
        setState(() {
          _user = null;
          userId = null;
          isLoading = false;
          errorMessage = "Không tìm thấy người dùng đã đăng nhập.";
          print("_loadUserData: Không có user, isLoading = $isLoading");
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
      print("_loadUserData: Lỗi: $e");
    }
  }

  Future<void> fetchUserInfor() async {
    print("fetchUserInfor: Bắt đầu với userId = $userId");
    if (userId == null) {
      setState(() {
        isLoading = false;
        diagnosisHistory = [];
        errorMessage = "Không tìm thấy ID người dùng.";
      });
      print("fetchUserInfor: userId null, isLoading = $isLoading");
      return;
    }
    try {
      final records = await ApiService.getUserInfor(userId!);
      print("fetchUserInfor: Đã nhận dữ liệu: $records");
      setState(() {
        diagnosisHistory = records;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        diagnosisHistory = [];
        errorMessage = e.toString();
      });
      print("fetchUserInfor: Lỗi: $e");
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    setState(() {
      _user = null;
      userId = null;
      diagnosisHistory = [];
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return _buildHomeContent();
      case 1:
        return ProfileScreen(user: _user ?? {});
      case 2:
        return DiscussionScreen();
      case 3:
        return AIChatScreen();
      default:
        return _buildHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Life Armor', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          _user == null
              ? Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      child: Text(
                        'Đăng nhập',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/register');
                      },
                      child: Text(
                        'Đăng ký',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Text(
                      'Xin chào, ${_user!['name'] ?? 'Người dùng'}',
                      style: TextStyle(color: Colors.white),
                    ),
                    IconButton(
                      icon: Icon(Icons.logout),
                      onPressed: _logout,
                    ),
                  ],
                ),
        ],
      ),
      drawer: buildDrawerMenu(context),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildScreen(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Tình huống'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Chat'
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                kToolbarHeight -
                kBottomNavigationBarHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            _buildCarousel(),
            SizedBox(height: 20),
            _buildProfileCard(),
            SizedBox(height: 20),
            _buildBookingCard(),
            SizedBox(height: 20),
            _buildDoctorSection(),
            SizedBox(height: 20),
            _buildServiceSection(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    final List<String> images = [
      'assets/banner1.jpg',
      'assets/banner2.jpg',
      'assets/banner3.jpg',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Giao tiếp tốt, ứng xử hay',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.teal[800],
          ),
        ),
        SizedBox(height: 12),
        CarouselSlider(
          options: CarouselOptions(
            height: 200,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
          ),
          items: images.map((imgPath) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  )
                ],
                image: DecorationImage(
                  image: AssetImage(imgPath),
                  fit: BoxFit.cover,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    // Nếu CHƯA đăng nhập
    if (_user == null) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Vui lòng đăng nhập để xem hồ sơ cá nhân',
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      );
    }

    // Nếu ĐÃ đăng nhập
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hồ Sơ Cá Nhân',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
            ),
            const SizedBox(height: 12),

            // ✅ DÒNG DUY NHẤT CẦN HIỂN THỊ
            Text(
              'Chào mừng, ${_user!['name'] ?? 'Người dùng'} !',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(user: _user!),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: const Text(
                'Xem chi tiết',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBookingCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = 3; // Chuyển sang tab Chat
          });
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.chat_bubble, color: Colors.teal, size: 30),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal[800])),
                    SizedBox(height: 5),
                    Text('Chat with AI', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.teal),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildDoctorSection() {
    final List<Map<String, String>> doctors = [
      {
        'name': 'TS.Lê Đăng Quân',
        'specialty': 'Mentor',
        'image': 'assets/doctor1.jpg'
      },
      {
        'name': 'TS.Nguyễn Thị Thanh Nhàn',
        'specialty': 'Mentor',
        'image': 'assets/doctor2.jpg'
      },
      {
        'name': 'Tú Khắc',
        'specialty': 'Mentor',
        'image': 'assets/doctor3.jpg'
      },
    ];

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nhà tâm lý nổi bật ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DoctorsScreen()),
                  );
                },
                child: Text('Xem tất cả', style: TextStyle(color: Colors.teal)),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        CarouselSlider(
          options: CarouselOptions(
            height: 350,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.7,
          ),
          items: doctors.map((doctor) {
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded( // 🔥 quan trọng
                    child: ClipRRect(
                      borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.asset(
                        doctor['image']!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Text(
                          doctor['name']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor['specialty']!,
                          style: const TextStyle(color: Colors.teal),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildDrawerMenu(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.teal),
            child: Center(
              child: Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          _buildDrawerItem(context, 'Profile', ProfileScreen(user: _user ?? {})),
          _buildDrawerItem(context, 'Tình huống', DiscussionScreen()),
          _buildDrawerItem(context, 'Tien sy', DoctorsScreen()),
          _buildDrawerItem(context, 'AI', AIChatScreen()),
          _buildDrawerItem(context, 'Logout', LoginScreen()),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, Widget screen) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 18)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );
  }

  Widget _buildServiceSection() {
    final List<Map<String, dynamic>> services = [
      {
        'title': 'Xin nghỉ phép',
        'desc': 'Cách nói chuyện với sếp để được đồng ý',
        'icon': Icons.event_available,
        'color': Colors.teal,
      },
      {
        'title': 'Giải quyết xung đột',
        'desc': 'Kỹ năng xử lý mâu thuẫn hiệu quả',
        'icon': Icons.group_work,
        'color': Colors.orange,
      },
      {
        'title': 'Ứng xử online',
        'desc': 'Giao tiếp lịch sự và tránh lừa đảo mạng',
        'icon': Icons.smart_display,
        'color': Colors.blue,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tình huống nổi bật',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: Text('Xem tất cả', style: TextStyle(color: Colors.teal)),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Column(
          children: services.map((service) {
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: service['color'],
                  child: Icon(
                    service['icon'],
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  service['title'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(service['desc']),
                trailing: Icon(Icons.arrow_forward_ios,
                    color: Colors.teal, size: 16),
                onTap: () {
                  // Xử lý khi nhấn vào tình huống
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }


  Widget _buildLoginDialog() {
    final _formKey = GlobalKey<FormState>();
    String email = '', password = '';
    bool isPasswordVisible = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/logo.png', height: 80),
                  SizedBox(height: 10),
                  Text(
                    "Mỗi ngày một niềm vui mới",
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Chào mừng trở lại!",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Đăng nhập để tiếp tục",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 25),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon:
                          Icon(Icons.email, color: Colors.blue.shade700),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Không được để trống" : null,
                    onChanged: (value) => email = value,
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: Icon(Icons.lock, color: Colors.blue.shade700),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !isPasswordVisible,
                    validator: (value) =>
                        value!.isEmpty ? "Không được để trống" : null,
                    onChanged: (value) => password = value,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final result =
                            await ApiService.loginUser(email, password);
                        if (!context.mounted) return;

                        if (result != null && result['error'] == null) {
                          final role = result['role'];
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('user', jsonEncode(result));

                          setState(() {
                            _user = result;
                          });
                          Navigator.pop(context);

                          if (role == 'admin') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => AdminDashboard()),
                            );
                          } else if (role == 'doctor') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => DoctorDashboard()),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  result?['error'] ?? 'Đăng nhập thất bại'),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                    ),
                    child: Text("Đăng nhập", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegisterDialog() {
    final _formKey = GlobalKey<FormState>();
    String name = '', email = '', password = '';
    bool isPasswordVisible = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/logo.png', height: 80),
                  SizedBox(height: 10),
                  Text(
                    "Chăm sóc sức khỏe toàn diện - Vì bạn xứng đáng!",
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Đăng Ký Tài Khoản",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Tạo tài khoản để trải nghiệm dịch vụ",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 25),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Họ và tên',
                      prefixIcon:
                          Icon(Icons.person, color: Colors.blue.shade700),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Không được để trống" : null,
                    onChanged: (value) => name = value,
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon:
                          Icon(Icons.email, color: Colors.blue.shade700),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Không được để trống" : null,
                    onChanged: (value) => email = value,
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: Icon(Icons.lock, color: Colors.blue.shade700),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !isPasswordVisible,
                    validator: (value) =>
                        value!.isEmpty ? "Không được để trống" : null,
                    onChanged: (value) => password = value,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final response = await http.post(
                            Uri.parse(
                                'http://your-backend-url/api/auth/register'),
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode({
                              'name': name,
                              'email': email,
                              'password': password,
                              'role': 'patient',
                            }),
                          );
                          if (response.statusCode == 201) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Đăng ký thành công, vui lòng đăng nhập')),
                            );
                          } else {
                            throw Exception(
                                'Đăng ký thất bại: ${response.body}');
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                    ),
                    child: Text("Đăng ký", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
