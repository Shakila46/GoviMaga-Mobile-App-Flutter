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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B7A3E)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const CropManagementPage(),
    );
  }
}

// ─────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────

class CropData {
  final String name;
  final String plantedDate;
  final String stage;
  final Color stageColor;
  final double progress;
  final int daysGrown;
  final String nextTask;
  final String taskDate;

  const CropData({
    required this.name,
    required this.plantedDate,
    required this.stage,
    required this.stageColor,
    required this.progress,
    required this.daysGrown,
    required this.nextTask,
    required this.taskDate,
  });
}

class UpcomingTask {
  final String title;
  final String crop;
  final String date;
  final IconData icon;
  final Color iconColor;

  const UpcomingTask({
    required this.title,
    required this.crop,
    required this.date,
    required this.icon,
    required this.iconColor,
  });
}

// ─────────────────────────────────────────────
// MAIN PAGE
// ─────────────────────────────────────────────

class CropManagementPage extends StatefulWidget {
  const CropManagementPage({super.key});

  @override
  State<CropManagementPage> createState() => _CropManagementPageState();
}

class _CropManagementPageState extends State<CropManagementPage> {
  int _selectedIndex = 4; // Crops tab selected

  static const Color primaryGreen = Color(0xFF1B7A3E);
  static const Color lightGreen = Color(0xFFE8F5EE);
  static const Color bgColor = Color(0xFFF2F7F4);

  final List<CropData> crops = const [
    CropData(
      name: 'Rice (Nadu)',
      plantedDate: '2026-01-15',
      stage: 'Vegetative',
      stageColor: Color(0xFF4CAF50),
      progress: 0.35,
      daysGrown: 24,
      nextTask: 'Apply fertilizer',
      taskDate: '2026-02-10',
    ),
    CropData(
      name: 'Tomato',
      plantedDate: '2026-01-20',
      stage: 'Flowering',
      stageColor: Color(0xFFFF9800),
      progress: 0.45,
      daysGrown: 19,
      nextTask: 'Pest inspection',
      taskDate: '2026-02-09',
    ),
    CropData(
      name: 'Green Chili',
      plantedDate: '2026-01-05',
      stage: 'Fruiting',
      stageColor: Color(0xFFF44336),
      progress: 0.70,
      daysGrown: 34,
      nextTask: 'Start harvesting',
      taskDate: '2026-02-12',
    ),
  ];

  final List<UpcomingTask> upcomingTasks = const [
    UpcomingTask(
      title: 'Water rice field',
      crop: 'Rice',
      date: '2026-02-08',
      icon: Icons.water_drop_outlined,
      iconColor: Color(0xFF2196F3),
    ),
    UpcomingTask(
      title: 'Apply fertilizer to tomato',
      crop: 'Tomato',
      date: '2026-02-09',
      icon: Icons.eco_outlined,
      iconColor: Color(0xFF4CAF50),
    ),
    UpcomingTask(
      title: 'Pest control for chili',
      crop: 'Chili',
      date: '2026-02-11',
      icon: Icons.notifications_outlined,
      iconColor: Color(0xFFFF5722),
    ),
  ];

  final List<_NavItem> navItems = const [
    _NavItem(icon: Icons.home_outlined, label: 'Home'),
    _NavItem(icon: Icons.qr_code_scanner_outlined, label: 'Scan'),
    _NavItem(icon: Icons.wb_sunny_outlined, label: 'Weather'),
    _NavItem(icon: Icons.storefront_outlined, label: 'Market'),
    _NavItem(icon: Icons.grass_outlined, label: 'Crops'),
    _NavItem(icon: Icons.menu_book_outlined, label: 'Learn'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPageHeader(),
                    const SizedBox(height: 16),
                    _buildAddCropButton(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('🌱 My Crops'),
                    const SizedBox(height: 12),
                    ...crops.map((crop) => _buildCropCard(crop)),
                    const SizedBox(height: 20),
                    _buildUpcomingTasks(),
                    const SizedBox(height: 20),
                    _buildStageCard(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ── App Bar ──────────────────────────────────

  Widget _buildAppBar() {
    return Container(
      color: primaryGreen,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          const Text(
            'AgriMate',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white54),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.language, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text('GB', style: TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Page Header ──────────────────────────────

  Widget _buildPageHeader() {
  return SizedBox(
    width: double.infinity,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Crop Management Tracker',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B7A3E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Track your crops with automated care reminders',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
      ],
    ),
  );
}

  // ── Add Crop Button ──────────────────────────

  Widget _buildAddCropButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add New Crop',
          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
      ),
    );
  }

  // ── Section Title ────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  // ── Crop Card ────────────────────────────────

  Widget _buildCropCard(CropData crop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Stage badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                crop.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              _buildStageBadge(crop.stage, crop.stageColor),
            ],
          ),
          const SizedBox(height: 6),

          // Planted date
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                'Planted: ${crop.plantedDate}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Growth Progress', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
              Text(
                '${(crop.progress * 100).toInt()}%',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: crop.progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
              minHeight: 7,
            ),
          ),
          const SizedBox(height: 8),

          // Days grown
          Row(
            children: [
              Icon(Icons.access_time, size: 13, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                '${crop.daysGrown} days grown',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Next task box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications_outlined, size: 14, color: primaryGreen),
                    const SizedBox(width: 4),
                    Text(
                      'Next Task',
                      style: TextStyle(
                        fontSize: 12,
                        color: primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  crop.nextTask,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  crop.taskDate,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageBadge(String stage, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        stage,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Upcoming Tasks ───────────────────────────

  Widget _buildUpcomingTasks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_month, color: Color(0xFF1B7A3E), size: 20),
            const SizedBox(width: 6),
            const Text(
              'Upcoming Tasks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: upcomingTasks.asMap().entries.map((entry) {
              final i = entry.key;
              final task = entry.value;
              return Column(
                children: [
                  _buildTaskRow(task),
                  if (i < upcomingTasks.length - 1)
                    Divider(height: 1, color: Colors.grey[100], indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskRow(UpcomingTask task) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: task.iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(task.icon, size: 18, color: task.iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${task.crop} • ${task.date}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle_outline, color: Colors.grey[400], size: 20),
        ],
      ),
    );
  }

  // ── Stage Card ───────────────────────────────

  Widget _buildStageCard() {
    final stages = ['Germination', 'Vegetative', 'Flowering', 'Fruiting', 'Mature'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stage',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ...stages.map(
            (stage) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.circle, color: Colors.white, size: 8),
                  const SizedBox(width: 10),
                  Text(
                    stage,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Navigation ─────────────────────────

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: navItems.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final selected = i == _selectedIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  size: 22,
                  color: selected ? primaryGreen : Colors.grey[400],
                ),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 10,
                    color: selected ? primaryGreen : Colors.grey[400],
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
