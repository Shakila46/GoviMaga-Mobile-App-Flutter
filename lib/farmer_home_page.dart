import 'package:flutter/material.dart';
import 'screens/weather/widgets/weather_screen.dart';

// අනෙක් අයගේ Screen files මෙතනට import කරන්න
// දැනට මේවා comment කර ඇත්තේ files නොමැති නම් error එකක් එන බැවිනි
// import 'screens/diagnose/diagnose_home.dart';
// import 'screens/market/market_home.dart';
// import 'screens/crops/crops_home.dart';
// import 'screens/forum/forum_home.dart';
// import 'screens/profile/profile_home.dart';

class FarmerHomePage extends StatefulWidget {
  const FarmerHomePage({super.key});

  @override
  State<FarmerHomePage> createState() => _FarmerHomePageState();
}

class _FarmerHomePageState extends State<FarmerHomePage> {
  int _selectedIndex = 0;
  // --- මෙතැන false ලෙස වෙනස් කළ විට App එක ආරම්භ වන්නේ ඉංග්‍රීසි භාෂාවෙනි ---
  bool isSinhala = false;
  String currentCrop = "Paddy";

  final Map<String, Map<String, String>> localizedText = {
    'en': {
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
      'fertilizer': 'Fertilizer Application',
      'pesticide': 'Pest Control (Oil/Liquid)',
      'current_crop': 'Current Crop: ',
      'ask_ai': 'Ask AI',
    },
    'si': {
      'app_title': 'ගොවිමඟ',
      'welcome': 'ආයුබෝවන්, ගොවි මහතාණෙනි!',
      'alerts': 'සැලකිලිමත් වන්න (Reminders)',
      'features': 'මූලික සේවාවන්',
      'home': 'ප්‍රධාන',
      'diagnose': 'රෝග',
      'market': 'මිල ගණන්',
      'crops': 'වගාවන්',
      'weather': 'කාලගුණය',
      'forum': 'සමූහය',
      'profile': 'ගිණුම',
      'fertilizer': 'පොහොර යෙදීම',
      'pesticide': 'තෙල්/බෙහෙත් ඉසීම',
      'current_crop': 'දැනට වගාව: ',
      'ask_ai': 'AI ගෙන් අසන්න',
    },
  };

  String t(String key) => localizedText[isSinhala ? 'si' : 'en']![key]!;

  List<Map<String, dynamic>> getAutoNotices() {
    if (currentCrop == "Paddy") {
      return [
        {
          "title": t('fertilizer'),
          "msg": isSinhala
              ? "වී වගාවට යුරියා යෙදීමට කාලයයි."
              : "Time to apply Urea for Paddy.",
          "icon": Icons.science,
          "color": Colors.blue,
        },
        {
          "title": t('pesticide'),
          "msg": isSinhala
              ? "ගොයම් මැස්සාගෙන් ආරක්ෂා වීමට තෙල් ඉසින්න."
              : "Spray pesticide to prevent leaf folders.",
          "icon": Icons.opacity,
          "color": Colors.redAccent,
        },
      ];
    }
    return [];
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    // සාමාජිකයින්ගේ Screens ලැයිස්තුව
    final List<Widget> pages = [
      HomeContent(
        onFeatureTap: _onItemTapped,
        isSinhala: isSinhala,
        t: t,
        notices: getAutoNotices(),
        currentCropName: currentCrop == "Paddy"
            ? (isSinhala ? "වී" : "Paddy")
            : (isSinhala ? "තක්කාලි" : "Tomato"),
      ),
      const Center(
        child: Text("Diagnose Screen (Member 2)"),
      ),
      const Center(
        child: Text("Market Screen (Member 3)"),
      ),
      const Center(child: Text("Crops Screen (Member 4)")),
      const WeatherScreen(),
      const Center(child: Text("Forum Screen (Member 6)")),
      const Center(child: Text("Profile Screen (Member 7)")),
    ];

    // Weather tab active නම් AppBar hide කරන්න (WeatherScreen එකේ තමන්ගේම AppBar තියෙනවා)
    final bool isWeatherTab = _selectedIndex == 4;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: isWeatherTab
          ? null
          : AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/app_logo.jpeg',
                height: 35,
                width: 35,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) =>
                const Icon(Icons.eco, color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              t('app_title'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => isSinhala = !isSinhala),
            child: Text(
              isSinhala ? "English" : "සිංහල",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
        onPressed: () {
          debugPrint("Navigating to AI Chat...");
        },
        backgroundColor: const Color(0xFF1B5E20),
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: Text(
          t('ask_ai'),
          style: const TextStyle(color: Colors.white),
        ),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: t('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.camera_alt),
            label: t('diagnose'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.storefront),
            label: t('market'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.grass),
            label: t('crops'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.cloud),
            label: t('weather'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.forum),
            label: t('forum'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: t('profile'),
          ),
        ],
      ),
    );
  }
}

// HomeContent සහ අනෙකුත් widgets මෙතැන් සිට...
class HomeContent extends StatelessWidget {
  final Function(int) onFeatureTap;
  final bool isSinhala;
  final String Function(String) t;
  final List<Map<String, dynamic>> notices;
  final String currentCropName;

  const HomeContent({
    super.key,
    required this.onFeatureTap,
    required this.isSinhala,
    required this.t,
    required this.notices,
    required this.currentCropName,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 25),
          Text(
            t('alerts'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...notices
              .map(
                (n) => _buildNoticeTile(
              n['title'],
              n['msg'],
              n['icon'],
              n['color'],
            ),
          )
              .toList(),
          const SizedBox(height: 25),
          Text(
            t('features'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildFeatureGrid(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('welcome'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "${t('current_crop')}$currentCropName",
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeTile(
      String title,
      String msg,
      IconData icon,
      Color color,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(msg, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _featureItem(t('diagnose'), Icons.camera_alt, Colors.blue, 1),
        _featureItem(t('market'), Icons.storefront, Colors.orange, 2),
        _featureItem(t('crops'), Icons.grass, Colors.green, 3),
        _featureItem(t('weather'), Icons.cloud, Colors.lightBlue, 4),
        _featureItem(t('ask_ai'), Icons.auto_awesome, Colors.purple, 100),
      ],
    );
  }

  Widget _featureItem(String title, IconData icon, Color color, int index) {
    return InkWell(
      onTap: () {
        if (index == 100) {
          debugPrint("Ask AI tapped from Grid!");
        } else {
          onFeatureTap(index);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 35),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}