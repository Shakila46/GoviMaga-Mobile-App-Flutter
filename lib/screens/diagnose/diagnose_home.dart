import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/diagnosis_service.dart';

class DiagnoseHome extends StatelessWidget {
  final String language;
  const DiagnoseHome({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return DiseaseDiagnosisScreen(language: language);
  }
}

class DiseaseDiagnosisScreen extends StatefulWidget {
  final String language;
  const DiseaseDiagnosisScreen({super.key, required this.language});

  @override
  State<DiseaseDiagnosisScreen> createState() => _DiseaseDiagnosisScreenState();
}

class _DiseaseDiagnosisScreenState extends State<DiseaseDiagnosisScreen> {
  File? _selectedImage;
  Map<String, dynamic>? _diagnosisData;
  List<Map<String, dynamic>> _recentDiagnoses = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isAuthenticated = false;

  final DiagnosisService _diagnosisService = DiagnosisService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get API key from environment - NO HARDCODED FALLBACK
  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  @override
  void initState() {
    super.initState();
    _isAuthenticated = _auth.currentUser != null;
    if (_isAuthenticated) {
      _loadRecentDiagnoses();
    }
  }

  String _t(String key) {
    final Map<String, Map<String, String>> translations = {
      'EN': {
        'title': 'Crop Disease Diagnosis',
        'subtitle': 'Upload or take a photo of your crop to identify diseases',
        'takePhotoInfo': 'Take or Upload Photo',
        'camera': 'Camera',
        'gallery': 'Gallery',
        'chooseBtn': 'Choose Image',
        'diagnoseBtn': 'Diagnose Disease',
        'cancelBtn': 'Cancel',
        'analyzing': 'Analyzing disease...',
        'confidence': 'Confidence',
        'treatment': 'Recommended Treatment',
        'prevention': 'Future Prevention',
        'unknown': 'Unknown Disease',
        'recentDiagnoses': 'Recent Diagnoses',
        'error': 'Error analyzing image. Please try again.',
        'noApiKey': 'API Key not configured. Please contact support.',
        'noImage': 'Please select an image first',
        'cropName': 'Crop Name',
        'diseaseName': 'Disease Name',
        'severity': 'Severity',
        'tryAgain': 'Try Again',
        'clearHistory': 'Clear History',
        'capturePhoto': 'Take a photo',
        'chooseFromGallery': 'Choose from gallery',
        'saving': 'Saving to cloud...',
        'saved': 'Saved to cloud',
      },
      'SI': {
        'title': 'බෝග රෝග හඳුනාගැනීම',
        'subtitle': 'රෝග හඳුනා ගැනීම සඳහා ඔබේ බෝගයේ ඡායාරූපයක් උඩුගත කරන්න හෝ ගන්න',
        'takePhotoInfo': 'පින්තූරයක් ලබා දෙන්න',
        'camera': 'කැමරාව',
        'gallery': 'ගැලරිය',
        'chooseBtn': 'පින්තූරය තෝරන්න',
        'diagnoseBtn': 'රෝගය හඳුනාගන්න',
        'cancelBtn': 'අවලංගු කරන්න',
        'analyzing': 'රෝගය විශ්ලේෂණය කරමින්...',
        'confidence': 'විශ්වාසනීයත්වය',
        'treatment': 'නිර්දේශිත ප්‍රතිකාර',
        'prevention': 'අනාගත ආරක්ෂණ ක්‍රම',
        'unknown': 'හඳුනා නොගත් රෝගයකි',
        'recentDiagnoses': 'මෑතකාලීන පරීක්ෂාවන්',
        'error': 'පින්තූරය විශ්ලේෂණය කිරීමේ දෝෂයකි. නැවත උත්සාහ කරන්න.',
        'noApiKey': 'API යතුර වින්‍යාස කර නැත. සහාය අමතන්න.',
        'noImage': 'කරුණාකර පළමුව රූපයක් තෝරන්න',
        'cropName': 'බෝග නම',
        'diseaseName': 'රෝගයේ නම',
        'severity': 'බරපතලකම',
        'tryAgain': 'නැවත උත්සාහ කරන්න',
        'clearHistory': 'ඉතිහාසය මකන්න',
        'capturePhoto': 'ඡායාරූපයක් ගන්න',
        'chooseFromGallery': 'ගැලරියෙන් තෝරන්න',
        'saving': 'වලාකුළට සුරකිමින්...',
        'saved': 'වලාකුළට සුරකින ලදී',
      },
      'TA': {
        'title': 'பயிர் நோய் கண்டறிதல்',
        'subtitle': 'நோய்களை அடையாளம் காண உங்கள் பயிரின் புகைப்படத்தை பதிவேற்றவும் அல்லது எடுக்கவும்',
        'takePhotoInfo': 'புகைப்படம் பதிவேற்றவும்',
        'camera': 'கேமரா',
        'gallery': 'கேலரி',
        'chooseBtn': 'படத்தைத் தேர்ந்தெடுக்கவும்',
        'diagnoseBtn': 'நோயைக் கண்டறியவும்',
        'cancelBtn': 'ரத்து செய்',
        'analyzing': 'பகுப்பாய்வு செய்கிறது...',
        'confidence': 'நம்பிக்கை',
        'treatment': 'பரிந்துரைக்கப்பட்ட சிகிச்சை',
        'prevention': 'எதிர்கால தடுப்பு',
        'unknown': 'அறியப்படாத நோய்',
        'recentDiagnoses': 'சமீபத்திய நோயறிதல்கள்',
        'error': 'படத்தை பகுப்பாய்வு செய்வதில் பிழை. மீண்டும் முயற்சிக்கவும்.',
        'noApiKey': 'API விசை கட்டமைக்கப்படவில்லை. ஆதரவைத் தொடர்பு கொள்ளவும்.',
        'noImage': 'தயவுசெய்து முதலில் ஒரு படத்தைத் தேர்ந்தெடுக்கவும்',
        'cropName': 'பயிர் பெயர்',
        'diseaseName': 'நோயின் பெயர்',
        'severity': 'தீவிரம்',
        'tryAgain': 'மீண்டும் முயற்சிக்கவும்',
        'clearHistory': 'வரலாற்றை அழிக்கவும்',
        'capturePhoto': 'புகைப்படம் எடுக்கவும்',
        'chooseFromGallery': 'கேலரியிலிருந்து தேர்வு செய்யவும்',
        'saving': 'மேகத்தில் சேமிக்கிறது...',
        'saved': 'மேகத்தில் சேமிக்கப்பட்டது',
      },
    };
    return translations[widget.language]?[key] ?? translations['EN']![key]!;
  }

  Future<void> _loadRecentDiagnoses() async {
    setState(() => _isLoading = true);
    
    try {
      // Load from Firebase first
      final diagnoses = await _diagnosisService.getDiagnoses();
      if (diagnoses.isNotEmpty) {
        setState(() {
          _recentDiagnoses = diagnoses;
        });
      } else {
        // Fallback to local storage
        final prefs = await SharedPreferences.getInstance();
        final String? data = prefs.getString('recent_diagnoses');
        if (data != null) {
          try {
            List<dynamic> decoded = json.decode(data);
            setState(() {
              _recentDiagnoses = decoded.cast<Map<String, dynamic>>();
            });
          } catch (e) {
            debugPrint('Error loading diagnoses: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading from Firebase: $e');
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString('recent_diagnoses');
      if (data != null) {
        try {
          List<dynamic> decoded = json.decode(data);
          setState(() {
            _recentDiagnoses = decoded.cast<Map<String, dynamic>>();
          });
        } catch (e) {
          debugPrint('Error loading diagnoses: $e');
        }
      }
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _saveDiagnoses() async {
    // Save to local storage as backup
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('recent_diagnoses', json.encode(_recentDiagnoses));
  }

  Future<void> _clearHistory() async {
    setState(() {
      _recentDiagnoses.clear();
    });
    await _saveDiagnoses();
    
    // Also clear from Firebase
    try {
      // Delete all diagnoses from Firebase
      final diagnoses = await _diagnosisService.getDiagnoses();
      for (var diagnosis in diagnoses) {
        await _diagnosisService.deleteDiagnosis(
          diagnosis['id'], 
          diagnosis['imageUrl']
        );
      }
    } catch (e) {
      debugPrint('Error clearing Firebase history: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _diagnosisData = null;
        });
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Text(
              _t('takePhotoInfo'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: Text(_t('capturePhoto')),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: Text(_t('chooseFromGallery')),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _analyzeImage(File image) async {
    if (_apiKey.isEmpty) {
      _showError(_t('noApiKey'));
      return;
    }

    setState(() {
      _isLoading = true;
      _diagnosisData = null;
    });

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      final imageBytes = await image.readAsBytes();

      final prompt = """
      You are an expert agricultural disease detection system. Analyze this plant/crop image and identify any diseases.
      
      Return ONLY a valid JSON object with this exact structure (no markdown formatting, no extra text):
      {
        "cropName": {
          "EN": "Crop name in English",
          "SI": "Crop name in Sinhala",
          "TA": "Crop name in Tamil"
        },
        "diseaseName": {
          "EN": "Disease name in English (or 'Healthy' if no disease)",
          "SI": "Disease name in Sinhala",
          "TA": "Disease name in Tamil"
        },
        "severity": "HIGH/MEDIUM/LOW/NONE",
        "confidence": 85,
        "treatments": {
          "EN": ["Treatment step 1", "Treatment step 2"],
          "SI": ["ප්‍රතිකාර පියවර 1", "ප්‍රතිකාර පියවර 2"],
          "TA": ["சிகிச்சை படி 1", "சிகிச்சை படி 2"]
        },
        "preventions": {
          "EN": ["Prevention method 1", "Prevention method 2"],
          "SI": ["වැළැක්වීමේ ක්‍රමය 1", "වැළැක්වීමේ ක්‍රමය 2"],
          "TA": ["தடுப்பு முறை 1", "தடுப்பு முறை 2"]
        }
      }
      
      If the plant appears healthy, set diseaseName to "Healthy" and severity to "NONE".
      """;

      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ];

      final response = await model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('No response from API');
      }

      String cleanText = response.text!;
      int start = cleanText.indexOf('{');
      int end = cleanText.lastIndexOf('}');
      if (start != -1 && end != -1) {
        cleanText = cleanText.substring(start, end + 1);
      }
      
      Map<String, dynamic> diagnosisData = json.decode(cleanText);

      setState(() {
        _diagnosisData = diagnosisData;
        _isLoading = false;
      });

      // Save to Firebase (show saving indicator)
      setState(() => _isSaving = true);
      
      try {
        await _diagnosisService.saveDiagnosis(
          imageFile: image,
          diagnosisData: diagnosisData,
          language: widget.language,
        );
        
        // Refresh recent diagnoses from Firebase
        await _loadRecentDiagnoses();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_t('saved')),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        // Save to local storage as fallback
        final newDiagnosis = {
          'date': DateTime.now().toIso8601String(),
          'data': diagnosisData,
          'imagePath': image.path,
        };
        _recentDiagnoses.insert(0, newDiagnosis);
        if (_recentDiagnoses.length > 10) {
          _recentDiagnoses = _recentDiagnoses.take(10).toList();
        }
        await _saveDiagnoses();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved locally only. ${_t('error')}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
      
      setState(() => _isSaving = false);
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSaving = false;
      });
      _showError('${_t('error')}\n${e.toString()}');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _cancelDiagnosis() {
    setState(() {
      _selectedImage = null;
      _diagnosisData = null;
    });
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.yellow[700]!;
      case 'NONE':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateTimeString) {
    try {
      DateTime date = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 7) {
        return '${(diff.inDays / 7).floor()} weeks ago';
      } else if (diff.inDays > 0) {
        return '${diff.inDays} days ago';
      } else if (diff.inHours > 0) {
        return '${diff.inHours} hours ago';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_apiKey.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF2F7F4),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'API Key Not Configured',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please add GEMINI_API_KEY to .env file',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Contact Support'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.health_and_safety,
                      size: 48,
                      color: Color(0xFF1B5E20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _t('title'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _t('subtitle'),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Image Selection Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Image Preview
                      _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImage!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green[200]!),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.photo_camera,
                                    size: 48,
                                    color: Colors.green[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _t('takePhotoInfo'),
                                    style: TextStyle(color: Colors.green[700]),
                                  ),
                                ],
                              ),
                            ),
                      const SizedBox(height: 16),

                      // Action Buttons
                      if (_selectedImage == null)
                        ElevatedButton.icon(
                          onPressed: _showImageSourceDialog,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: Text(_t('chooseBtn')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading || _isSaving
                                    ? null
                                    : () => _analyzeImage(_selectedImage!),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
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
                                    : Text(_t('diagnoseBtn')),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isLoading || _isSaving
                                    ? null
                                    : _cancelDiagnosis,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.grey[700],
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(_t('cancelBtn')),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // Loading Indicator
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: Colors.green),
                        SizedBox(height: 12),
                        Text('Analyzing image...'),
                      ],
                    ),
                  ),
                ),

              // Diagnosis Result
              if (_diagnosisData != null && !_isLoading) ...[
                const SizedBox(height: 20),

                // Disease Info Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _diagnosisData!['diseaseName']?[widget.language] ?? _t('unknown'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getSeverityColor(
                                  _diagnosisData!['severity'] ?? 'LOW',
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _diagnosisData!['severity'] ?? 'UNKNOWN',
                                style: TextStyle(
                                  color: _getSeverityColor(
                                    _diagnosisData!['severity'] ?? 'LOW',
                                  ),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_diagnosisData!['cropName']?[widget.language] ?? 'Plant'}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.analytics,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_t('confidence')}: ${_diagnosisData!['confidence'] ?? 0}%',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (_diagnosisData!['confidence'] ?? 0) / 100,
                          backgroundColor: Colors.grey[200],
                          color: Colors.green,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Treatment Card
                if (_diagnosisData!['treatments'] != null)
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.medical_services,
                                  color: Colors.orange[700],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _t('treatment'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(
                            (_diagnosisData!['treatments'][widget.language]
                                    as List)
                                .length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.green[50],
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _diagnosisData!['treatments'][widget
                                              .language][index]
                                          .toString(),
                                      style: const TextStyle(height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Prevention Card
                if (_diagnosisData!['preventions'] != null)
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.shield,
                                  color: Colors.blue[700],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _t('prevention'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(
                            (_diagnosisData!['preventions'][widget.language]
                                    as List)
                                .length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green[400],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _diagnosisData!['preventions'][widget
                                              .language][index]
                                          .toString(),
                                      style: const TextStyle(height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],

              // Recent Diagnoses
              if (_recentDiagnoses.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _t('recentDiagnoses'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _clearHistory,
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: Text(_t('clearHistory')),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._recentDiagnoses.take(5).map((item) {
                  final data = item['data'];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[100],
                        child: const Icon(Icons.eco, color: Colors.green),
                      ),
                      title: Text(
                        data['diseaseName']?[widget.language] ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        data['cropName']?[widget.language] ?? 'Plant',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Text(
                        _formatDate(item['date']),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      onTap: () {
                        setState(() {
                          _diagnosisData = data;
                        });
                        // Scroll to top
                        Scrollable.ensureVisible(context);
                      },
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}