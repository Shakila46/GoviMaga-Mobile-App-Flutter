import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/crop_service.dart';
import '../widgets/floating_robo.dart'; 

import '../screens/weather/widgets/weather_screen.dart';
import '../screens/diagnose/diagnose_home.dart';
import '../screens/market/market_home.dart';
import '../screens/crops/crops_home.dart';
import '../screens/forum/forum_home.dart';
import '../screens/profile/profile_home.dart';

class FarmerHomePage extends StatefulWidget {
  const FarmerHomePage({super.key});

  @override
  State<FarmerHomePage> createState() => _FarmerHomePageState();
}

class _FarmerHomePageState extends State<FarmerHomePage> {
  int _selectedIndex = 0;
  String _selectedLanguage = 'EN';
  String currentCrop = "Paddy";

  final CropService _cropService = CropService();
  List<Map<String, dynamic>> _upcomingTasks = [];
  bool _isAuthenticated = false;
  StreamSubscription<User?>? _authSubscription;

  final Map<String, Map<String, String>> localizedText = {
    'EN': {
      'app_title': 'GoviMaga',
      'welcome': 'Welcome, Farmer!',
      'alerts': 'Care Reminders',
      'features': 'Key Services',
      'home': 'Home',
      'diagnose': 'Diagnose',
      'market': 'Market',
      'crops': 'Crops',
      'weather': 'Weather',
      'forum': 'Forum',
      'profile': 'Profile',
      'no_tasks': 'No pending tasks',
      'view_all': 'View All',
      'current_crop': 'Current Crop: ',
    },
    'SI': {
      'app_title': 'ගොවිමඟ',
      'welcome': 'ආයුබෝවන්, ගොවි මහතාණෙනි!',
      'alerts': 'සැලකිලිමත් වන්න',
      'features': 'මූලික සේවාවන්',
      'home': 'ප්‍රධාන',
      'diagnose': 'රෝග',
      'market': 'මිල ගණන්',
      'crops': 'වගාවන්',
      'weather': 'කාලගුණය',
      'forum': 'සමූහය',
      'profile': 'ගිණුම',
      'no_tasks': 'විවෘත කාර්යයන් නැත',
      'view_all': 'සියල්ල බලන්න',
      'current_crop': 'දැනට වගාව: ',
    },
    'TA': {
      'app_title': 'கோவிமகா',
      'welcome': 'வணக்கம், விவசாயியே!',
      'alerts': 'கவனிப்பு நினைவூட்டல்கள்',
      'features': 'முக்கிய சேவைகள்',
      'home': 'முகப்பு',
      'diagnose': 'கண்டறிதல்',
      'market': 'சந்தை',
      'crops': 'பயிர்கள்',
      'weather': 'வானிலை',
      'forum': 'மன்றம்',
      'profile': 'சுயவிவரம்',
      'no_tasks': 'நிலுவையில் உள்ள பணிகள் இல்லை',
      'view_all': 'அனைத்தையும் காண்க',
      'current_crop': 'தற்போதைய பயிர்: ',
    },
  };

  String t(String key) => localizedText[_selectedLanguage]![key] ?? key;

  @override
  void initState() {
    super.initState();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() => _isAuthenticated = user != null);
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!_isAuthenticated) {
      if (mounted) setState(() { _upcomingTasks = []; currentCrop = "Paddy"; });
      return;
    }
    await _cropService.loadCrops();
    if (mounted) {
      setState(() {
        if (_cropService.crops.isNotEmpty) {
          currentCrop = _cropService.crops.first['name'] as String;
        }
      });
      _updateTasks();
    }
  }

  Future<void> _updateTasks() async {
    final tasks = await _cropService.getAllUpcomingTasks(days: 7);
    if (mounted) setState(() => _upcomingTasks = tasks);
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeContent(
        onFeatureTap: _onItemTapped,
        language: _selectedLanguage,
        t: t,
        notices: _upcomingTasks.take(3).map((task) => {
          'title': task['title'],
          'msg': '${task['cropName'] ?? 'Unknown'} - Upcoming task',
          'icon': Icons.notifications,
          'color': Colors.orange,
          'taskId': task['id'],
          'cropId': task['cropId'],
          'dueDate': task['dueDate'],
        }).toList(),
        currentCropName: currentCrop,
        onTaskComplete: (cId, tId) async {
          await _cropService.toggleTaskCompletion(cId, tId, true);
          _updateTasks();
        },
      ),
      DiagnoseHome(language: _selectedLanguage),
      MarketHome(language: _selectedLanguage),
      CropsHome(language: _selectedLanguage),
      WeatherScreen(language: _selectedLanguage),
      ForumHome(language: _selectedLanguage),
      ProfileHome(language: _selectedLanguage),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/app_logo.jpeg'),
              radius: 16,
            ),
            const SizedBox(width: 8),
            Text(t('app_title'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        actions: [
          _langButton('EN', 'EN'),
          const VerticalDivider(color: Colors.white54, indent: 20, endIndent: 20),
          _langButton('SI', 'සිං'),
          const VerticalDivider(color: Colors.white54, indent: 20, endIndent: 20),
          _langButton('TA', 'தமி'),
          const SizedBox(width: 8),
        ],
      ),
      body: pages[_selectedIndex],

      
      floatingActionButton: FloatingRobo(language: _selectedLanguage),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: t('home')),
          BottomNavigationBarItem(icon: const Icon(Icons.camera_alt), label: t('diagnose')),
          BottomNavigationBarItem(icon: const Icon(Icons.storefront), label: t('market')),
          BottomNavigationBarItem(icon: const Icon(Icons.grass), label: t('crops')),
          BottomNavigationBarItem(icon: const Icon(Icons.cloud), label: t('weather')),
          BottomNavigationBarItem(icon: const Icon(Icons.forum), label: t('forum')),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: t('profile')),
        ],
      ),
    );
  }

  Widget _langButton(String code, String text) {
    bool isSelected = _selectedLanguage == code;
    return GestureDetector(
      onTap: () => setState(() => _selectedLanguage = code),
      child: Center(child: Text(text, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
    );
  }
}

class HomeContent extends StatelessWidget {
  final Function(int) onFeatureTap;
  final String language;
  final String Function(String) t;
  final List<Map<String, dynamic>> notices;
  final String currentCropName;
  final Function(String, String) onTaskComplete;

  const HomeContent({super.key, required this.onFeatureTap, required this.language, required this.t, required this.notices, required this.currentCropName, required this.onTaskComplete});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 25),
          Text(t('alerts'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (notices.isEmpty) const Center(child: Text("No tasks pending")) else ...notices.map((n) => Card(
            child: ListTile(
              leading: Icon(n['icon'], color: n['color']),
              title: Text(n['title']),
              subtitle: Text(n['msg']),
              trailing: IconButton(icon: const Icon(Icons.check_circle_outline, color: Colors.green), onPressed: () => onTaskComplete(n['cropId'], n['taskId'])),
            ),
          )),
          const SizedBox(height: 25),
          Text(t('features'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _featureItem(t('diagnose'), Icons.camera_alt, Colors.blue, 1),
              _featureItem(t('market'), Icons.storefront, Colors.orange, 2),
              _featureItem(t('crops'), Icons.grass, Colors.green, 3),
              _featureItem(t('weather'), Icons.cloud, Colors.lightBlue, 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)]), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t('welcome'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("${t('current_crop')}$currentCropName", style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _featureItem(String title, IconData icon, Color color, int index) {
    return InkWell(
      onTap: () => onFeatureTap(index),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color, size: 35), const SizedBox(height: 10), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]),
      ),
    );
  }
}