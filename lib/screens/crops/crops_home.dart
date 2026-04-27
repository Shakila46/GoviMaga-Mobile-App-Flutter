import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/crop_service.dart';
import '../../widgets/login_required_dialog.dart';
import 'add_crop_screen.dart';
import 'package:intl/intl.dart';

class CropsHome extends StatefulWidget {
  final String language;
  const CropsHome({super.key, required this.language});

  @override
  State<CropsHome> createState() => _CropsHomeState();
}

class _CropsHomeState extends State<CropsHome> {
  final CropService _cropService = CropService();
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _checkGuestMode();
  }

  Future<void> _checkGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isGuest = prefs.getBool('is_guest') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isGuest || FirebaseAuth.instance.currentUser == null) {
      return _buildGuestMessage();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: StreamBuilder<QuerySnapshot>(
        stream: _cropService.getUserCrops(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)));
          }

          var crops = snapshot.data?.docs.toList() ?? [];
          crops.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = (aData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bTime = (bData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime);
          });

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(crops.length),
              if (crops.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCropCard(crops[index]),
                      childCount: crops.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_isGuest) {
            LoginRequiredDialog.show(context: context, action: 'add a crop');
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCropScreen(language: widget.language),
            ),
          );
        },
        backgroundColor: const Color(0xFF1B5E20),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Crop', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 4,
      ),
    );
  }

  Widget _buildSliverAppBar(int totalCrops) {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1B5E20),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(width: 8),
            Text(
              'My Farm',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: -50,
              child: Icon(
                Icons.eco,
                size: 200,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 60,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.grass, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '$totalCrops Active Crops',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.yard_outlined, size: 80, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your Field is Empty',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
          ),
          const SizedBox(height: 12),
          Text(
            'Plant your first crop to get personalized\ncare reminders and harvest estimates.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCropScreen(language: widget.language)),
              );
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Plant First Crop'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final plantedDate = (data['plantedDate'] as Timestamp?)?.toDate() ?? DateTime.now();
    final daysPlanted = DateTime.now().difference(plantedDate).inDays;
    
    // Simple mock estimation based on crop variety/name
    int estHarvestDays = 100;
    if (data['name'].toString().toLowerCase().contains('paddy')) {
      estHarvestDays = 120;
    } else if (data['name'].toString().toLowerCase().contains('tomato')) {
      estHarvestDays = 75;
    }
    
    final progress = (daysPlanted / estHarvestDays).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showTasksBottomSheet(context, doc.id, data['name'] ?? 'Unknown'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.energy_savings_leaf, color: Color(0xFF2E7D32), size: 28),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['name'] ?? 'Unknown Crop',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                data['variety'] ?? 'Standard Variety',
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            final dataWithId = Map<String, dynamic>.from(data);
                            dataWithId['id'] = doc.id;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddCropScreen(language: widget.language, cropToEdit: dataWithId),
                              ),
                            );
                          } else if (value == 'delete') {
                            _showDeleteConfirmation(doc.id);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatColumn('Planted', DateFormat('MMM d, y').format(plantedDate)),
                      _buildStatColumn('Age', '$daysPlanted days'),
                      _buildStatColumn('Status', progress >= 1.0 ? 'Ready' : 'Growing', valueColor: progress >= 1.0 ? Colors.green : Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: valueColor ?? Colors.black87)),
      ],
    );
  }

  void _showDeleteConfirmation(String cropId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Crop'),
        content: const Text('Are you sure you want to delete this crop and all its tasks? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cropService.deleteCrop(cropId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showTasksBottomSheet(BuildContext context, String cropId, String cropName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.calendar_month, color: Color(0xFF2E7D32)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$cropName Care',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Upcoming Reminders & Tasks',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _cropService.getTasksForCrop(cropId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)));
                  }
                  final tasks = snapshot.data?.docs ?? [];
                  if (tasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('All caught up!', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index].data() as Map<String, dynamic>;
                      final dueDate = (task['dueDate'] as Timestamp).toDate();
                      final isCompleted = task['isCompleted'] ?? false;
                      final isOverdue = !isCompleted && dueDate.isBefore(DateTime.now().subtract(const Duration(days: 1)));
                      
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: isCompleted ? Colors.grey[50] : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCompleted ? Colors.grey[200]! : (isOverdue ? Colors.red[100]! : Colors.grey[200]!),
                            width: 1,
                          ),
                          boxShadow: isCompleted ? [] : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CheckboxListTile(
                          value: isCompleted,
                          activeColor: const Color(0xFF2E7D32),
                          checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            task['title'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isCompleted ? FontWeight.normal : FontWeight.w600,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              color: isCompleted ? Colors.grey[400] : Colors.black87,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time, 
                                  size: 14, 
                                  color: isCompleted ? Colors.grey[400] : (isOverdue ? Colors.red : Colors.grey[600]),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('MMM d, yyyy').format(dueDate),
                                  style: TextStyle(
                                    color: isCompleted ? Colors.grey[400] : (isOverdue ? Colors.red : Colors.grey[600]),
                                    fontWeight: isOverdue && !isCompleted ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onChanged: (bool? value) async {
                            if (value != null) {
                              await _cropService.toggleTaskCompletion(cropId, tasks[index].id, value);
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestMessage() {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircleAvatar(
              backgroundImage: AssetImage('assets/app_logo.jpeg'),
              radius: 16,
            ),
            SizedBox(width: 8),
            Text('My Crops'),
          ],
        ),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Login Required',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please login to manage your crops.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                LoginRequiredDialog.show(context: context, action: 'manage crops');
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}