import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import 'edit_details.dart';
import 'activity_log.dart';
import 'privacy_security.dart';

class ProfileHome extends StatefulWidget {
  final String language;
  const ProfileHome({super.key, required this.language});

  @override
  State<ProfileHome> createState() => _ProfileHomeState();
}

class _ProfileHomeState extends State<ProfileHome> {
  final UserService _userService = UserService();

  Future<void> _logout() async {
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app_auth.AuthProvider>(context);
    
    if (authProvider.isGuest) {
      return _buildGuestProfile();
    }

    final userId = authProvider.user?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to view profile")),
      );
    }

    //  Real-time user data stream
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(width: 8),
            Text("My Profile"),
          ],
        ),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userService.getUserStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            // Fallback to Auth Provider if Firestore document doesn't exist yet
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              return _buildProfileUI(
                context,
                UserModel(
                  id: currentUser.uid,
                  name: currentUser.displayName ?? 'Unknown User',
                  email: currentUser.email ?? '',
                  phone: currentUser.phoneNumber ?? 'Not provided',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              );
            }
            return const Center(
              child: Text('Profile data not found. Please contact support.'),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final user = UserModel.fromJson(data);

          return _buildProfileUI(context, user);
        },
      ),
    );
  }

  Widget _buildProfileUI(BuildContext context, UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
                const SizedBox(height: 20),
                // Profile Avatar
                CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFF1B5E20),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 48, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  user.phone,
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
                const SizedBox(height: 32),
                _buildMenuItem(
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditDetails(
                          name: user.name,
                          email: user.email,
                          phone: user.phone,
                          language: widget.language,
                        ),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.history,
                  title: 'Activity Log',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ActivityLog()));
                  },
                ),
                _buildMenuItem(
                  icon: Icons.security,
                  title: 'Privacy & Security',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacySecurity()));
                  },
                ),
                const Divider(),
                _buildMenuItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  textColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: _logout,
                ),
              ],
            ),
    );
  }

  Widget _buildGuestProfile() {
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
            Text("Profile"),
          ],
        ),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_outline, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'GUEST MODE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'You are browsing as a guest',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Text(
                'Login to save your crops and track your data.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
                  await authProvider.logout(); // Clears guest mode and logs out
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                icon: const Icon(Icons.login),
                label: const Text('Login / Sign Up'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Color? textColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.blueGrey),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? Colors.black87),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}