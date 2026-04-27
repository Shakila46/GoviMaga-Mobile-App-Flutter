import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';

class PrivacySecurity extends StatefulWidget {
  const PrivacySecurity({super.key});

  @override
  State<PrivacySecurity> createState() => _PrivacySecurityState();
}

class _PrivacySecurityState extends State<PrivacySecurity> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  final UserService _userService = UserService();

  String _t(String key) {
    final Map<String, Map<String, String>> translations = {
      'EN': {
        'title': 'Privacy & Security',
        'change_password': 'Change Password',
        'new_password': 'New Password',
        'confirm_password': 'Confirm Password',
        'update': 'Update Password',
        'password_mismatch': 'Passwords do not match',
        'password_empty': 'Please fill all password fields',
        'password_short': 'Password must be at least 6 characters',
        'password_success': 'Password updated successfully',
        'password_error': 'Error updating password',
        'security_settings': 'Security Settings',
        'two_factor': 'Enable Two-Factor Authentication',
        'private_profile': 'Private Profile',
        'location_sharing': 'Location Sharing',
        'privacy_actions': 'Privacy Actions',
        'delete_account': 'Delete Account',
        'manage_permissions': 'Manage Permissions',
        'coming_soon': 'Coming soon',
        'delete_warning': 'This action cannot be undone',
        'setting_updated': 'Setting updated',
      },
      'SI': {
        'title': 'පෞද්ගලිකත්වය සහ ආරක්ෂාව',
        'change_password': 'මුරපදය වෙනස් කරන්න',
        'new_password': 'නව මුරපදය',
        'confirm_password': 'මුරපදය තහවුරු කරන්න',
        'update': 'මුරපදය යාවත්කාලීන කරන්න',
        'password_mismatch': 'මුරපද ගැලපෙන්නේ නැත',
        'password_empty': 'කරුණාකර සියලුම මුරපද ක්ෂේත්‍ර පුරවන්න',
        'password_short': 'මුරපදය අවම වශයෙන් අකුරු 6 ක් විය යුතුය',
        'password_success': 'මුරපදය සාර්ථකව යාවත්කාලීන කරන ලදී',
        'password_error': 'මුරපදය යාවත්කාලීන කිරීමේ දෝෂයකි',
        'security_settings': 'ආරක්ෂක සැකසුම්',
        'two_factor': 'ද්වි-සාධක සත්‍යාපනය සබල කරන්න',
        'private_profile': 'පුද්ගලික පැතිකඩ',
        'location_sharing': 'ස්ථාන බෙදාගැනීම',
        'privacy_actions': 'පෞද්ගලිකත්ව ක්‍රියා',
        'delete_account': 'ගිණුම මකන්න',
        'manage_permissions': 'අවසර කළමනාකරණය කරන්න',
        'coming_soon': 'ඉක්මනින් පැමිණේ',
        'delete_warning': 'මෙම ක්‍රියාව ආපසු හැරවිය නොහැක',
        'setting_updated': 'සැකසුම යාවත්කාලීන කරන ලදී',
      },
      'TA': {
        'title': 'தனியுரிமை மற்றும் பாதுகாப்பு',
        'change_password': 'கடவுச்சொல்லை மாற்றவும்',
        'new_password': 'புதிய கடவுச்சொல்',
        'confirm_password': 'கடவுச்சொல்லை உறுதிப்படுத்தவும்',
        'update': 'கடவுச்சொல்லை புதுப்பிக்கவும்',
        'password_mismatch': 'கடவுச்சொற்கள் பொருந்தவில்லை',
        'password_empty': 'தயவுசெய்து அனைத்து கடவுச்சொல் புலங்களையும் நிரப்பவும்',
        'password_short': 'கடவுச்சொல் குறைந்தது 6 எழுத்துகளாக இருக்க வேண்டும்',
        'password_success': 'கடவுச்சொல் வெற்றிகரமாக புதுப்பிக்கப்பட்டது',
        'password_error': 'கடவுச்சொல்லைப் புதுப்பிப்பதில் பிழை',
        'security_settings': 'பாதுகாப்பு அமைப்புகள்',
        'two_factor': 'இரண்டு-காரணி அங்கீகாரத்தை இயக்கவும்',
        'private_profile': 'தனிப்பட்ட சுயவிவரம்',
        'location_sharing': 'இருப்பிடப் பகிர்வு',
        'privacy_actions': 'தனியுரிமை நடவடிக்கைகள்',
        'delete_account': 'கணக்கை நீக்கு',
        'manage_permissions': 'அனுமதிகளை நிர்வகிக்கவும்',
        'coming_soon': 'விரைவில் வருகிறது',
        'delete_warning': 'இந்த செயலை மீளமுடியாது',
        'setting_updated': 'அமைப்பு புதுப்பிக்கப்பட்டது',
      },
    };
    return translations['EN']?[key] ?? key;
  }

  Future<void> _changePassword() async {
    if (_passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      _showMessage(_t('password_empty'), isError: true);
      return;
    }
    
    if (_passwordController.text.length < 6) {
      _showMessage(_t('password_short'), isError: true);
      return;
    }
    
    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage(_t('password_mismatch'), isError: true);
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.updatePassword(_passwordController.text);
      
      _showMessage(_t('password_success'));
      _passwordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      _showMessage('${_t('password_error')}: $e', isError: true);
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _updateSetting(String field, bool value) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        field: value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _showMessage(_t('setting_updated'));
    } catch (e) {
      _showMessage('Error: $e', isError: true);
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text(_t('delete_warning')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseAuth.instance.currentUser?.delete();
                _showMessage('Account deleted successfully');
              } catch (e) {
                _showMessage('Error: $e', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/app_logo.jpeg'),
              radius: 16,
            ),
            const SizedBox(width: 8),
            Text(_t('title')),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: userId == null
          ? const Center(child: Text("Please login to view settings"))
          : StreamBuilder<DocumentSnapshot>(
              stream: _userService.getUserStream(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                bool is2FAEnabled = false;
                bool isProfilePrivate = false;
                bool isLocationSharing = true;

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final user = UserModel.fromJson(data);
                  is2FAEnabled = user.is2FAEnabled;
                  isProfilePrivate = user.isProfilePrivate;
                  isLocationSharing = user.isLocationSharing;
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Password Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('change_password'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: _t('new_password'),
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock_outline),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: _t('confirm_password'),
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _changePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B5E20),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(_t('update')),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Security Settings
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('security_settings'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            title: Text(_t('two_factor')),
                            value: is2FAEnabled,
                            onChanged: (value) => _updateSetting('is2FAEnabled', value),
                            activeThumbColor: const Color(0xFF1B5E20),
                          ),
                          SwitchListTile(
                            title: Text(_t('private_profile')),
                            value: isProfilePrivate,
                            onChanged: (value) => _updateSetting('isProfilePrivate', value),
                            activeThumbColor: const Color(0xFF1B5E20),
                          ),
                          SwitchListTile(
                            title: Text(_t('location_sharing')),
                            value: isLocationSharing,
                            onChanged: (value) => _updateSetting('isLocationSharing', value),
                            activeThumbColor: const Color(0xFF1B5E20),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Privacy Actions
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('privacy_actions'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ListTile(
                            leading: const Icon(Icons.delete_forever, color: Colors.red),
                            title: Text(_t('delete_account')),
                            onTap: _showDeleteAccountDialog,
                          ),
                          ListTile(
                            leading: const Icon(Icons.lock, color: Colors.blue),
                            title: Text(_t('manage_permissions')),
                            onTap: () => _showMessage(_t('coming_soon')),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}