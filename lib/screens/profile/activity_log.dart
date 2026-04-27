import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActivityLog extends StatefulWidget {
  const ActivityLog({super.key});

  @override
  State<ActivityLog> createState() => _ActivityLogState();
}

class _ActivityLogState extends State<ActivityLog> {
  List<Map<String, dynamic>> _getMockActivities() {
    return [
      {
        "title": "Logged In",
        "time": DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        "icon": "login"
      },
      {
        "title": "Added New Crop",
        "time": DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        "icon": "crop"
      },
      {
        "title": "Diagnosed Disease",
        "time": DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        "icon": "diagnose"
      },
      {
        "title": "Checked Weather",
        "time": DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        "icon": "weather"
      },
      {
        "title": "Updated Profile",
        "time": DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        "icon": "edit"
      },
    ];
  }

  IconData getIcon(String type) {
    switch (type) {
      case "login":
        return Icons.login;
      case "logout":
        return Icons.logout;
      case "edit":
        return Icons.edit;
      case "crop":
        return Icons.grass;
      case "diagnose":
        return Icons.health_and_safety;
      case "weather":
        return Icons.cloud;
      default:
        return Icons.info;
    }
  }

  Color getColor(String type) {
    switch (type) {
      case "login":
        return Colors.green;
      case "logout":
        return Colors.red;
      case "edit":
        return Colors.blue;
      case "crop":
        return const Color(0xFF1B5E20);
      case "diagnose":
        return Colors.purple;
      case "weather":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 7) {
        return '${(difference.inDays / 7).floor()} weeks ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateTimeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

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
            Text("Activity Log"),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: userId == null
          ? _buildActivityList(_getMockActivities())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('activities')
                  .orderBy('timestamp', descending: true)
                  .limit(50)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  // Fallback to mock data if there is an error
                  return _buildActivityList(_getMockActivities());
                }

                final docs = snapshot.data!.docs;
                
                if (docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No activities yet',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                final activities = docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
                return _buildActivityList(activities);
              },
            ),
    );
  }

  Widget _buildActivityList(List<Map<String, dynamic>> activities) {
    return ListView.builder(
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final iconType = activity["icon"] ?? "info";
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getColor(iconType).withValues(alpha: 0.2),
              child: Icon(
                getIcon(iconType),
                color: getColor(iconType),
                size: 20,
              ),
            ),
            title: Text(
              activity["title"] ?? "Activity",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              formatTime(activity["time"] ?? DateTime.now().toIso8601String()),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ),
        );
      },
    );
  }
}