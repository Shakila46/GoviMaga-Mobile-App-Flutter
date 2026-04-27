import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/user_service.dart';

class EditDetails extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String language;

  const EditDetails({
    required this.name,
    required this.email,
    required this.phone,
    required this.language,
    super.key,
  });

  @override
  State<EditDetails> createState() => _EditDetailsState();
}

class _EditDetailsState extends State<EditDetails> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  String _t(String key) {
    final Map<String, Map<String, String>> translations = {
      'EN': {
        'title': 'Edit Details',
        'name': 'Name',
        'email': 'Email',
        'phone': 'Phone',
        'save': 'Save Changes',
        'name_required': 'Please enter your name',
        'email_required': 'Please enter your email',
        'valid_email': 'Enter valid email',
        'phone_required': 'Please enter your phone',
        'valid_phone': 'Enter valid phone number',
        'success': 'Details Updated Successfully',
        'error': 'Error updating details',
      },
      'SI': {
        'title': 'විස්තර සංස්කරණය කරන්න',
        'name': 'නම',
        'email': 'විද්‍යුත් තැපෑල',
        'phone': 'දුරකථනය',
        'save': 'වෙනස්කම් සුරකින්න',
        'name_required': 'කරුණාකර ඔබේ නම ඇතුළත් කරන්න',
        'email_required': 'කරුණාකර ඔබේ විද්‍යුත් තැපෑල ඇතුළත් කරන්න',
        'valid_email': 'වලංගු විද්‍යුත් තැපෑලක් ඇතුළත් කරන්න',
        'phone_required': 'කරුණාකර ඔබේ දුරකථන අංකය ඇතුළත් කරන්න',
        'valid_phone': 'වලංගු දුරකථන අංකයක් ඇතුළත් කරන්න',
        'success': 'විස්තර සාර්ථකව යාවත්කාලීන කරන ලදී',
        'error': 'විස්තර යාවත්කාලීන කිරීමේ දෝෂයකි',
      },
      'TA': {
        'title': 'விவரங்களைத் திருத்துக',
        'name': 'பெயர்',
        'email': 'மின்னஞ்சல்',
        'phone': 'தொலைபேசி',
        'save': 'மாற்றங்களைச் சேமிக்கவும்',
        'name_required': 'தயவுசெய்து உங்கள் பெயரை உள்ளிடவும்',
        'email_required': 'தயவுசெய்து உங்கள் மின்னஞ்சலை உள்ளிடவும்',
        'valid_email': 'சரியான மின்னஞ்சலை உள்ளிடவும்',
        'phone_required': 'தயவுசெய்து உங்கள் தொலைபேசி எண்ணை உள்ளிடவும்',
        'valid_phone': 'சரியான தொலைபேசி எண்ணை உள்ளிடவும்',
        'success': 'விவரங்கள் வெற்றிகரமாக புதுப்பிக்கப்பட்டன',
        'error': 'விவரங்களைப் புதுப்பிப்பதில் பிழை',
      },
    };
    return translations[widget.language]?[key] ?? translations['EN']![key]!;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final userId = _auth.currentUser?.uid;
        if (userId != null) {
          await _userService.updateUserProfile(
            userId: userId,
            name: _nameController.text,
            phone: _phoneController.text,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_t('success')),
              backgroundColor: Colors.green,
            ),
          );

          // IMPORTANT: Return true to indicate success
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_t('error')}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: _t('name'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _t('name_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: _t('email'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                  suffixIcon: const Icon(Icons.lock, size: 16),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: _t('phone'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _t('phone_required');
                  }
                  if (value.length < 10) {
                    return _t('valid_phone');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                      : Text(_t('save'), style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}