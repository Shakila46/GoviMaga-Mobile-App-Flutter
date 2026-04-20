import 'package:flutter/material.dart';

void main() {
  runApp(const AgriMateApp());
}

class AgriMateApp extends StatelessWidget {
  const AgriMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A34D),
          primary: const Color(0xFF00A34D),
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F8F5),
        useMaterial3: true,
        fontFamily: 'sans-serif',
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 5; // "Learn" tab
  String _selectedLanguage = 'English';

  final Map<String, String> _localizedLogoNames = {
    'English': 'AgriMate',
    'සිංහල': 'ඇග්‍රිමේට්',
    'தமிழ்': 'அக்ரிமேட்',
  };

  String _getCountryCode(String language) {
    switch (language) {
      case 'English':
        return 'GB';
      case 'සිංහල':
      case 'தமிழ்':
        return 'LK';
      default:
        return 'GB';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      const Center(child: Text('Home')),
      const Center(child: Text('Scan')),
      const Center(child: Text('Weather')),
      const Center(child: Text('Market')),
      const Center(child: Text('Crops')),
      KnowledgeHubPage(language: _selectedLanguage),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A34D),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.eco, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              _localizedLogoNames[_selectedLanguage] ?? 'AgriMate',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String language) {
              setState(() {
                _selectedLanguage = language;
              });
            },
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                enabled: false,
                height: 30,
                child: Text(
                  'SELECT LANGUAGE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const PopupMenuDivider(height: 1),
              _buildLanguageItem('English', 'GB'),
              _buildLanguageItem('සිංහල', 'LK'),
              _buildLanguageItem('தமிழ்', 'LK'),
            ],
            child: Container(
              margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.language, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _getCountryCode(_selectedLanguage),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00A34D),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.wb_cloudy_outlined), label: 'Weather'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_basket_outlined), label: 'Market'),
          BottomNavigationBarItem(icon: Icon(Icons.grass_outlined), label: 'Crops'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Learn'),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildLanguageItem(String language, String countryCode) {
    bool isSelected = _selectedLanguage == language;
    return PopupMenuItem<String>(
      value: language,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Text(
              countryCode,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                language,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF00A34D) : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Color(0xFF00A34D), size: 16),
          ],
        ),
      ),
    );
  }
}

class KnowledgeHubPage extends StatefulWidget {
  final String language;
  const KnowledgeHubPage({super.key, required this.language});

  @override
  State<KnowledgeHubPage> createState() => _KnowledgeHubPageState();
}

class _KnowledgeHubPageState extends State<KnowledgeHubPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchText = '';

  final Map<String, Map<String, String>> _localizedStrings = {
    'English': {
      'title': 'Knowledge Hub & Forum',
      'subtitle': 'Learn from experts and fellow farmers',
      'search': 'Search topics...',
    },
    'සිංහල': {
      'title': 'දැනුම් මධ්‍යස්ථානය සහ සංසදය',
      'subtitle': 'විශේෂඥයන් සහ සෙසු ගොවීන්ගෙන් ඉගෙන ගන්න',
      'search': 'මාතෘකා සොයන්න...',
    },
    'தமிழ்': {
      'title': 'அறிவு மையம் மற்றும் மன்றம்',
      'subtitle': 'நிபுணர்கள் மற்றும் சக விவசாயிகளிடமிருந்து கற்றுக்கொள்ளுங்கள்',
      'search': 'தலைப்புகளைத் தேடுங்கள்...',
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _t(String key) {
    return _localizedStrings[widget.language]?[key] ?? _localizedStrings['English']![key]!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          _t('title'),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF004D25)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          _t('subtitle'),
          style: const TextStyle(color: Color(0xFF004D25), fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
            decoration: InputDecoration(
              hintText: _t('search'),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFE8ECEF),
            borderRadius: BorderRadius.circular(30),
          ),
          child: TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey[600],
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: const [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book, size: 18),
                    SizedBox(width: 8),
                    Text('Guides'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.forum_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Forum'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              BestPracticesTab(language: widget.language, searchText: _searchText),
              CommunityForumTab(language: widget.language, searchText: _searchText),
            ],
          ),
        ),
      ],
    );
  }
}

class BestPracticesTab extends StatefulWidget {
  final String language;
  final String searchText;
  const BestPracticesTab({super.key, required this.language, this.searchText = ''});

  @override
  State<BestPracticesTab> createState() => _BestPracticesTabState();
}

class _BestPracticesTabState extends State<BestPracticesTab> {
  int? _expandedRiceIndex;
  int? _expandedPestIndex;
  int? _expandedFertilizerIndex;

  final Map<String, Map<String, dynamic>> _content = const {
    'English': {
      'rice': {
        'title': 'Rice Cultivation Guide',
        'questions': [
          {
            'q': 'What is the best season for planting rice?',
            'a': 'Yala (April-September) and Maha (October-March) are the two main rice cultivation seasons in Sri Lanka. Choose based on your region\'s rainfall patterns.'
          },
          {
            'q': 'How much water does rice need?',
            'a': 'Rice fields typically need 5-10 cm of standing water during vegetative stage. Reduce water 2 weeks before harvesting.'
          },
          {
            'q': 'What spacing should I use?',
            'a': 'Maintain 15cm x 15cm spacing for traditional varieties and 20cm x 20cm for improved varieties to ensure optimal growth.'
          },
        ]
      },
      'pest': {
        'title': 'Pest Management',
        'questions': [
          {
            'q': 'How to identify rice pest attacks?',
            'a': 'Look for damaged leaves, discolored plants, or insects on stems. Common pests include brown plant hopper, stem borer, and leaf folder.'
          },
          {
            'q': 'Organic pest control methods?',
            'a': 'Use neem oil spray, introduce natural predators, maintain proper field sanitation, and practice crop rotation.'
          },
          {
            'q': 'When to apply pesticides?',
            'a': 'Apply during early morning or late evening. Follow recommended dosage and observe pre-harvest intervals.'
          },
        ]
      },
      'fertilizer': {
        'title': 'Fertilizer Application',
        'questions': [
          {
            'q': 'NPK ratios for vegetables?',
            'a': 'Leafy vegetables need higher N (20-10-10), fruiting vegetables need balanced NPK (10-10-10), root vegetables need higher K (5-10-10).'
          },
          {
            'q': 'Organic fertilizer options?',
            'a': 'Compost, cow dung, poultry manure, green manure, and bio-fertilizers are excellent organic options.'
          },
          {
            'q': 'How often to fertilize?',
            'a': 'Apply basal fertilizer at planting, then split applications every 2-3 weeks based on crop growth stage.'
          },
        ]
      }
    },
    'සිංහල': {
      'rice': {
        'title': 'වී වගා මාර්ගෝපදේශය',
        'questions': [
          {
            'q': 'වී වැපිරීමට හොඳම කාලය කුමක්ද?',
            'a': 'යල (අප්‍රේල්-සැප්තැම්බර්) සහ මහ (ඔක්තෝබර්-මාර්තු) ශ්‍රී ලංකාවේ ප්‍රධාන වී වගා කාලයන් වේ. ඔබේ ප්‍රදේශයේ වර්ෂාපතන රටාව අනුව තෝරාගන්න.'
          },
          {
            'q': 'වී වලට කොපමණ ජලය අවශ්‍යද?',
            'a': 'වර්ධන අවධියේදී වී කුඹුරුවලට සාමාන්‍යයෙන් සෙන්ටිමීටර 5-10 ක රැඳී පවතින ජලය අවශ්‍ය වේ. අස්වනු නෙලීමට සති 2 කට පෙර ජලය අඩු කරන්න.'
          },
          {
            'q': 'මම භාවිතා කළ යුතු පරතරය කුමක්ද?',
            'a': 'ප්‍රශස්ත වර්ධනයක් සහතික කිරීම සඳහා සාම්ප්‍රදායික ප්‍රභේද සඳහා සෙන්ටිමීටර 15x15 පරතරය සහ වැඩිදියුණු කළ ප්‍රභේද සඳහා සෙන්ටිමීටර 20x20 පරතරය පවත්වා ගන්න.'
          },
        ]
      },
      'pest': {
        'title': 'පළිබෝධ කළමනාකරණය',
        'questions': [
          {
            'q': 'වී පළිබෝධ හානි හඳුනා ගන්නේ කෙසේද?',
            'a': 'හානි වූ පත්‍ර, අවපැහැ ගැන්වූ ශාක හෝ කඳේ සිටින කෘමීන් දෙස බලන්න. දුඹුරු පැල මැක්කා, පුරුක් පණුවා සහ කොළ හකුලන පණුවා පොදු පළිබෝධකයන් වේ.'
          },
          {
            'q': 'කාබනික පළිබෝධ පාලන ක්‍රම?',
            'a': 'කොහොඹ තෙල් ඉසින භාවිතා කරන්න, ස්වභාවික විලෝපිකයන් හඳුන්වා දෙන්න, නිසි ක්ෂේත්‍ර සනීපාරක්ෂාව පවත්වා ගන්න, සහ බෝග මාරු කිරීම පුරුදු කරන්න.'
          },
          {
            'q': 'කෘමිනාශක යෙදිය යුත්තේ කවදාද?',
            'a': 'උදේ පාන්දර හෝ සවස් වරුවේ යොදන්න. නිර්දේශිත මාත්‍රාව අනුභව කරන්න සහ අස්වැන්න නෙලීමට පෙර කාල පරතරයන් නිරීක්ෂණය කරන්න.'
          },
        ]
      },
      'fertilizer': {
        'title': 'පොහොර යෙදීම',
        'questions': [
          {
            'q': 'එළවළු සඳහා NPK අනුපාත?',
            'a': 'පත්‍ර සහිත එළවළු සඳහා වැඩි N (20-10-10), ගෙඩි එළවළු සඳහා සමබර NPK (10-10-10), අල බෝග සඳහා වැඩි K (5-10-10) අවශ්‍ය වේ.'
          },
          {
            'q': 'කාබනික පොහොර විකල්ප?',
            'a': 'කොම්පෝස්ට්, ගොම, කුකුළු පොහොර, කොළ පොහොර සහ ජෛව පොහොර විශිෂ්ට කාබනික විකල්ප වේ.'
          },
          {
            'q': 'කොපමණ වාරයක් පොහොර යෙදිය යුතුද?',
            'a': 'සිටුවීමේදී මූලික පොහොර යොදන්න, ඉන්පසු බෝග වර්ධන අවධිය මත පදනම්ව සෑම සති 2-3 කට වරක් කොටස් වශයෙන් යොදන්න.'
          },
        ]
      }
    },
    'தமிழ்': {
      'rice': {
        'title': 'நெல் சாகுபடி வழிகாட்டி',
        'questions': [
          {
            'q': 'நெல் நடவு செய்ய சிறந்த பருவம் எது?',
            'a': 'இலங்கையில் யால (ஏப்ரல்-செப்டம்பர்) மற்றும் மஹா (அக்டோபர்-மார்ச்) ஆகிய இரண்டு முக்கிய நெல் சாகுபடி பருவங்கள் உள்ளன. உங்கள் பிராந்தியத்தின் மழைவீழ்ச்சி முறைகளின் அடிப்படையில் தேர்வு செய்யவும்.'
          },
          {
            'q': 'நெல்லுக்கு எவ்வளவு தண்ணீர் தேவை?',
            'a': 'வளர்ச்சி நிலையில் நெல் வயல்களில் பொதுவாக 5-10 செமீ தேங்கி நிற்கும் நீர் தேவைப்படுகிறது. அறுவடைக்கு 2 வாரங்களுக்கு முன்பு தண்ணீரைக் குறைக்கவும்.'
          },
          {
            'q': 'நான் என்ன இடைவெளியைப் பயன்படுத்த வேண்டும்?',
            'a': 'உகந்த வளர்ச்சியை உறுதிப்படுத்த பாரம்பரிய ரகங்களுக்கு 15செமீ x 15செமீ இடைவெளியையும், மேம்படுத்தப்பட்ட ரகங்களுக்கு 20செமீ x 20செமீ இடைவெளியையும் பராமரிக்கவும்.'
          },
        ]
      },
      'pest': {
        'title': 'பூச்சி மேலாண்மை',
        'questions': [
          {
            'q': 'நெல் பூச்சித் தாக்குதல்களை எவ்வாறு கண்டறிவது?',
            'a': 'சேதமடைந்த இலைகள், நிறமாற்றம் அடைந்த செடிகள் அல்லது தண்டுகளில் உள்ள பூச்சிகளைக் கவனியுங்கள். புகையான், தண்டு துளைப்பான் மற்றும் இலை சுருட்டி ஆகியவை பொதுவான பூச்சிகளாகும்.'
          },
          {
            'q': 'இயற்கை பூச்சி கட்டுப்பாடு முறைகள்?',
            'a': 'வேப்ப எண்ணெய் தெளிப்பைப் பயன்படுத்துங்கள், இயற்கை எதிரிகளை அறிமுகப்படுத்துங்கள், முறையான வயல் சுகாதாரத்தைப் பேணுங்கள் மற்றும் பயிர் சுழற்சியைப் பயிற்சி செய்யுங்கள்.'
          },
          {
            'q': 'பூச்சிக்கொல்லிகளை எப்போது பயன்படுத்துவது?',
            'a': 'அதிகாலை அல்லது மாலை வேளையில் பயன்படுத்துங்கள். பரிந்துரைக்கப்பட்ட அளவைப் பின்பற்றுங்கள் மற்றும் அறுவடைக்கு முந்தைய இடைவெளிகளைக் கவனியுங்கள்.'
          },
        ]
      },
      'fertilizer': {
        'title': 'உரம் இடுதல்',
        'questions': [
          {
            'q': 'காயறிகளுக்கான NPK விகிதங்கள்?',
            'a': 'இலை காயறிகளுக்கு அதிக N (20-10-10), காய் காயறிகளுக்கு சமநிலையான NPK (10-10-10), கிழங்கு பயிர்களுக்கு அதிக K (5-10-10) தேவைப்படுகிறது.'
          },
          {
            'q': 'இயற்கை உர விருப்பங்கள்?',
            'a': 'உரம், மாட்டு சாணம், கோழி எரு, பசுந்தாள் உரம் மற்றும் உயிர் உரங்கள் சிறந்த இயற்கை உர விருப்பங்களாகும்.'
          },
          {
            'q': 'எவ்வளவு அடிக்கடி உரம் இட வேண்டும்?',
            'a': 'நடவு செய்யும் போது அடிப்படை உரத்தைப் பயன்படுத்துங்கள், பின்னர் பயிர் வளர்ச்சி நிலையின் அடிப்படையில் ஒவ்வொரு 2-3 வாரங்களுக்கு பிரித்து உரமிடவும்.'
          },
        ]
      }
    }
  };

  @override
  Widget build(BuildContext context) {
    final langContent = _content[widget.language] ?? _content['English']!;
    final query = widget.searchText.toLowerCase();

    List<Widget> children = [];

    // Rice
    final riceVisible = langContent['rice']['title'].toLowerCase().contains(query) ||
        langContent['rice']['questions'].any((q) =>
        q['q'].toLowerCase().contains(query) || q['a'].toLowerCase().contains(query));
    if (riceVisible) {
      children.add(_buildExpansionCard(
        langContent['rice']['title'],
        List.generate(langContent['rice']['questions'].length, (index) {
          final qData = langContent['rice']['questions'][index];
          final qVisible = qData['q'].toLowerCase().contains(query) || qData['a'].toLowerCase().contains(query);
          if (!qVisible && !langContent['rice']['title'].toLowerCase().contains(query)) return const SizedBox.shrink();
          return _buildExpansionTile(
            index,
            qData['q'],
            qData['a'],
            _expandedRiceIndex,
                (isOpen) => setState(() => _expandedRiceIndex = isOpen ? index : null),
          );
        }),
      ));
      children.add(const SizedBox(height: 16));
    }

    // Pest
    final pestVisible = langContent['pest']['title'].toLowerCase().contains(query) ||
        langContent['pest']['questions'].any((q) =>
        q['q'].toLowerCase().contains(query) || q['a'].toLowerCase().contains(query));
    if (pestVisible) {
      children.add(_buildExpansionCard(
        langContent['pest']['title'],
        List.generate(langContent['pest']['questions'].length, (index) {
          final qData = langContent['pest']['questions'][index];
          final qVisible = qData['q'].toLowerCase().contains(query) || qData['a'].toLowerCase().contains(query);
          if (!qVisible && !langContent['pest']['title'].toLowerCase().contains(query)) return const SizedBox.shrink();
          return _buildExpansionTile(
            index,
            qData['q'],
            qData['a'],
            _expandedPestIndex,
                (isOpen) => setState(() => _expandedPestIndex = isOpen ? index : null),
          );
        }),
      ));
      children.add(const SizedBox(height: 16));
    }

    // Fertilizer
    final fertilizerVisible = langContent['fertilizer']['title'].toLowerCase().contains(query) ||
        langContent['fertilizer']['questions'].any((q) =>
        q['q'].toLowerCase().contains(query) || q['a'].toLowerCase().contains(query));
    if (fertilizerVisible) {
      children.add(_buildExpansionCard(
        langContent['fertilizer']['title'],
        List.generate(langContent['fertilizer']['questions'].length, (index) {
          final qData = langContent['fertilizer']['questions'][index];
          final qVisible = qData['q'].toLowerCase().contains(query) || qData['a'].toLowerCase().contains(query);
          if (!qVisible && !langContent['fertilizer']['title'].toLowerCase().contains(query)) return const SizedBox.shrink();
          return _buildExpansionTile(
            index,
            qData['q'],
            qData['a'],
            _expandedFertilizerIndex,
                (isOpen) => setState(() => _expandedFertilizerIndex = isOpen ? index : null),
          );
        }),
      ));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: children,
    );
  }

  Widget _buildExpansionCard(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.menu_book, color: Color(0xFF00A34D), size: 22),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF00A34D)),
                ),
              ],
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(int index, String title, String content, int? expandedIndex, Function(bool) onExpansionChanged) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: GlobalKey(),
        initiallyExpanded: expandedIndex == index,
        onExpansionChanged: onExpansionChanged,
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
        iconColor: Colors.grey,
        collapsedIconColor: Colors.grey,
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
        expandedAlignment: Alignment.topLeft,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              content,
              style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class Discussion {
  final String author;
  final DateTime createdAt;
  final Map<String, String> title;
  final Map<String, String> content;
  int repliesCount;
  int likesCount;
  bool isLiked;
  final List<Map<String, dynamic>> comments;

  Discussion({
    required this.author,
    required this.createdAt,
    required this.title,
    required this.content,
    required this.repliesCount,
    required this.likesCount,
    this.isLiked = false,
    required this.comments,
  });
}

class CommunityForumTab extends StatefulWidget {
  final String language;
  final String searchText;
  const CommunityForumTab({super.key, required this.language, this.searchText = ''});

  @override
  State<CommunityForumTab> createState() => _CommunityForumTabState();
}

class _CommunityForumTabState extends State<CommunityForumTab> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  final List<Discussion> _discussions = [
    Discussion(
      author: 'Nimal Perera',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      title: {
        'English': 'Best time to harvest paddy in Anuradhapura?',
        'සිංහල': 'අනුරාධපුරයේ සහල් අස්වනු නෙලීමට හොඳම කාලය?',
        'தமிழ்': 'அனுராதபுரத்தில் நெல் அறுவடைக்கு சிறந்த நேரம்?'
      },
      content: {
        'English': 'I planted BG 300 variety 3 months ago. When is the optimal time to harvest?',
        'සිංහල': 'මම මාස 3කට පෙර BG 300 ප්‍රභේදය සිටුවා ඇත්තෙමි. අස්වනු නෙලීමට ප්‍රශස්ත කාලය කවද්ද?',
        'தமிழ்': 'நான் 3 மாதங்களுக்கு முன்பு BG 300 ரகத்தை நட்டேன். அறுவடைக்கு உகந்த நேரம் எப்போது?'
      },
      repliesCount: 12,
      likesCount: 8,
      comments: [{'text': 'Harvest when 80-85% of grains are straw-colored.', 'time': DateTime.now().subtract(const Duration(minutes: 30))}],
    ),
    Discussion(
      author: 'Kamala Fernando',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      title: {
        'English': 'Organic fertilizer for tomato plants?',
        'සිංහල': 'තක්කාලි පැල සඳහා කාබනික පොහොර?',
        'தமிழ்': 'தக்காளி செடிகளுக்கு கரிம உரம்?'
      },
      content: {
        'English': 'Looking for recommendations on organic fertilizers that work well for tomatoes in Sri Lankan climate.',
        'සිංහල': 'ශ්‍රී ලංකා දේශගුණය තුළ තක්කාලි සඳහා හොඳින් ක්‍රියා කරන කාබනික පොහොර පිළිබඳ නිර්දේශ සොයමි.',
        'தமிழ்': 'இலங்கை காலடியில் தக்காளிக்கு நன்றாக வேலை செய்யும் கரிம உரங்கள் பற்றிய பரிந்துரைகளைத் தேடுகிறேன்.'
      },
      repliesCount: 7,
      likesCount: 15,
      comments: [{'text': 'Try compost mixed with bone meal.', 'time': DateTime.now().subtract(const Duration(hours: 1))}],
    ),
    Discussion(
      author: 'Sunil Silva',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      title: {
        'English': 'Dealing with leaf curl in chili plants',
        'සිංහල': 'මිරිස් පැලවල කොළ කරකැවීම සමඟ කටයුතු කිරීම',
        'தமிழ்': 'மிளகாய் செடிகளில் இலை சுருள் கையாளுதல்'
      },
      content: {
        'English': 'My chili plants are showing leaf curl symptoms. What are the effective treatment methods?',
        'සිංහල': 'මගේ මිරිස් පැල කොළ කරකැවීමේ රෝග ලක්ෂණ පෙන්වයි. ඵලදායී ප්‍රතිකාර ක්‍රම මොනවාද?',
        'தமிழ்': 'என் மிளகாய் செடிகள் இலை சுருள் அறிகுறிகளைக் காட்டுகின்றன. பயனுள்ள சிகிச்சை முறைகள் என்ன?'
      },
      repliesCount: 9,
      likesCount: 11,
      comments: [{'text': 'Check for mites or thrips under the leaves.', 'time': DateTime.now().subtract(const Duration(hours: 12))}],
    ),
  ];

  final Map<String, Map<String, String>> _forumStrings = const {
    'English': {
      'askTitle': 'Ask a Question',
      'yourQuestion': 'Your Question',
      'questionDetails': 'Question Details',
      'postButton': 'Post Question',
      'recentDiscussions': 'Recent Discussions',
      'replies': 'replies',
      'likes': 'likes',
      'addComment': 'Add a comment...',
      'comment': 'Comment',
      'justNow': 'Just now',
      'minutesAgo': 'minutes ago',
      'hoursAgo': 'hours ago',
      'daysAgo': 'days ago',
      'ago': 'ago'
    },
    'සිංහල': {
      'askTitle': 'ප්‍රශ්නයක් අසන්න',
      'yourQuestion': 'ඔබේ ප්‍රශ්නය',
      'questionDetails': 'ප්‍රශ්නයේ විස්තර',
      'postButton': 'ප්‍රශ්නය යොමු කරන්න',
      'recentDiscussions': 'මෑත සාකච්ඡා',
      'replies': 'පිළිතුරු',
      'likes': 'කැමැත්ත',
      'addComment': 'අදහසක් එක් කරන්න...',
      'comment': 'අදහස',
      'justNow': 'දැන්',
      'minutesAgo': 'මිනිත්තු වලට පෙර',
      'hoursAgo': 'පැය වලට පෙර',
      'daysAgo': 'දින වලට පෙර',
      'ago': 'පෙර'
    },
    'தமிழ்': {
      'askTitle': 'கேள்வி கேளுங்கள்',
      'yourQuestion': 'உங்கள் கேள்வி',
      'questionDetails': 'கேள்வி விவரங்கள்',
      'postButton': 'கேள்வியை இடுகையிடவும்',
      'recentDiscussions': 'சமீபத்திய விவாதங்கள்',
      'replies': 'பதில்கள்',
      'likes': 'விரும்புகிறது',
      'addComment': 'ஒரு கருத்தைச் சேர்க்கவும்...',
      'comment': 'கருத்து',
      'justNow': 'இப்போது',
      'minutesAgo': 'நிமிடங்களுக்கு முன்பு',
      'hoursAgo': 'மணிநேரங்களுக்கு முன்பு',
      'daysAgo': 'நாட்களுக்கு முன்பு',
      'ago': 'முன்பு'
    }
  };

  String _formatTimeAgo(DateTime dateTime) {
    final s = _forumStrings[widget.language] ?? _forumStrings['English']!;
    final diff = DateTime.now().difference(dateTime);

    if (diff.inSeconds < 60) {
      return s['justNow']!;
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} ${s['minutesAgo']}';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} ${s['hoursAgo']}';
    } else {
      return '${diff.inDays} ${s['daysAgo']}';
    }
  }

  void _postQuestion() {
    if (_questionController.text.isNotEmpty) {
      setState(() {
        _discussions.insert(0, Discussion(
          author: 'Me',
          createdAt: DateTime.now(),
          title: {'English': _questionController.text, 'සිංහල': _questionController.text, 'தமிழ்': _questionController.text},
          content: {'English': _detailsController.text, 'සිංහල': _detailsController.text, 'தமிழ்': _detailsController.text},
          repliesCount: 0,
          likesCount: 0,
          comments: [],
        ));
        _questionController.clear();
        _detailsController.clear();
      });
    }
  }

  void _toggleLike(int index) {
    setState(() {
      if (_discussions[index].isLiked) {
        _discussions[index].likesCount--;
        _discussions[index].isLiked = false;
      } else {
        _discussions[index].likesCount++;
        _discussions[index].isLiked = true;
      }
    });
  }

  void _showComments(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(_forumStrings[widget.language]!['comment']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _discussions[index].comments.length,
                  itemBuilder: (context, cIndex) {
                    final comment = _discussions[index].comments[cIndex];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(radius: 12, child: Icon(Icons.person, size: 14)),
                          const SizedBox(width: 8),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                                child: Text(comment['text']),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 4, top: 2),
                                child: Text(_formatTimeAgo(comment['time']), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              ),
                            ],
                          )),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: _forumStrings[widget.language]!['addComment'],
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF00A34D)),
                      onPressed: () {},
                    ),
                  ),
                  onSubmitted: (val) {
                    if (val.isNotEmpty) {
                      setState(() {
                        _discussions[index].comments.add({'text': val, 'time': DateTime.now()});
                        _discussions[index].repliesCount++;
                      });
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = _forumStrings[widget.language] ?? _forumStrings['English']!;
    final query = widget.searchText.toLowerCase();

    final filteredDiscussions = _discussions.where((disc) {
      final title = (disc.title[widget.language] ?? disc.title['English']!).toLowerCase();
      final content = (disc.content[widget.language] ?? disc.content['English']!).toLowerCase();
      return title.contains(query) || content.contains(query);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (query.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD1FAE5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['askTitle']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF065F46))),
                const SizedBox(height: 16),
                TextField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    hintText: s['yourQuestion'],
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _detailsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: s['questionDetails'],
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _postQuestion,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: Text(s['postButton']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A34D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        Text(s['recentDiscussions']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1F2937))),
        const SizedBox(height: 16),
        ...List.generate(filteredDiscussions.length, (index) {
          final originalIndex = _discussions.indexOf(filteredDiscussions[index]);
          return _buildDiscussionCard(originalIndex, s);
        }),
      ],
    );
  }

  Widget _buildDiscussionCard(int index, Map<String, String> s) {
    final disc = _discussions[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_outline, color: Color(0xFF22C55E), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      disc.title[widget.language] ?? disc.title['English']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${disc.author} • ${_formatTimeAgo(disc.createdAt)}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            disc.content[widget.language] ?? disc.content['English']!,
            style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              GestureDetector(
                onTap: () => _showComments(index),
                child: _buildInteractionItem(Icons.chat_bubble_outline, '${disc.repliesCount} ${s['replies']}'),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => _toggleLike(index),
                child: _buildInteractionItem(
                  disc.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  '${disc.likesCount} ${s['likes']}',
                  color: disc.isLiked ? const Color(0xFF00A34D) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionItem(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[500]),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: color ?? Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
// update
// final update