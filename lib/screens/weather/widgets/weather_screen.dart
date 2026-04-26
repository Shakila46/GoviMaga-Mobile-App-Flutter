import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../theme/app_colors.dart';
import 'hero_weather_card.dart';
import 'recommendations_section.dart';
import 'farming_alerts_section.dart';
import 'forecast_section.dart';

class WeatherScreen extends StatefulWidget {
  final String language;
  const WeatherScreen({super.key, required this.language});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  final String apiKey = dotenv.env['WEATHER_API_KEY'] ?? '';

  String currentCity = "Locating...";
  String temperature = "--";
  String humidity = "--";
  String windSpeed = "--";
  String rainfall = "0.0";
  String weatherDescription = "";
  bool isLoading = true;
  bool isRefreshing = false;

  List<dynamic> forecastList = [];

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _refreshController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _t(String key) {
    final Map<String, Map<String, String>> translations = {
      'EN': {
        'fetching_data': 'Fetching your farm data...',
        'weather_advisory': 'Weather-Driven Crop Advisory',
        'loading': 'Loading...',
        'your_location': 'Your Location',
        'tap_refresh': 'Tap to refresh',
      },
      'SI': {
        'fetching_data': 'ඔබේ ගොවිපල දත්ත ලබා ගනිමින්...',
        'weather_advisory': 'කාලගුණය මත පදනම් වූ බෝග උපදෙස්',
        'loading': 'පූරණය වෙමින්...',
        'your_location': 'ඔබේ ස්ථානය',
        'tap_refresh': 'නැවුම් කිරීමට තට්ටු කරන්න',
      },
      'TA': {
        'fetching_data': 'உங்கள் பண்ணை தரவைப் பெறுகிறது...',
        'weather_advisory': 'வானிலை சார்ந்த பயிர் ஆலோசனை',
        'loading': 'ஏற்றுகிறது...',
        'your_location': 'உங்கள் இடம்',
        'tap_refresh': 'புதுப்பிக்க தட்டவும்',
      },
    };
    return translations[widget.language]?[key] ?? translations['EN']![key]!;
  }

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _getWeatherByLocation();
    _setupPushNotifications();
  }

  void _setupPushNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission for notifications');
      await messaging.subscribeToTopic('weather_alerts');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.notification!.title ?? 'Alert',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(message.notification!.body ?? ''),
                ],
              ),
              backgroundColor: AppColors.alertRed,
              duration: const Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _getWeatherByLocation() async {
    _refreshController.repeat();
    setState(() {
      isRefreshing = true;
      isLoading = true;
      currentCity = "Locating...";
      temperature = "--";
      humidity = "--";
      windSpeed = "--";
      rainfall = "0.0";
      weatherDescription = "";
      forecastList = [];
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable location services.')),
          );
        }
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions denied.')),
            );
          }
          throw Exception('Location permissions are denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location permissions permanently denied. Enable in settings.',
              ),
            ),
          );
        }
        throw Exception('Location permissions are permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final currentWeatherUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric',
      );
      final forecastUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric',
      );

      final currentResponse = await http.get(currentWeatherUrl);
      final forecastResponse = await http.get(forecastUrl);

      if (currentResponse.statusCode == 200 &&
          forecastResponse.statusCode == 200) {
        final currentData = json.decode(currentResponse.body);
        final forecastData = json.decode(forecastResponse.body);

        List dailyForecasts = [];
        String lastDate = "";
        var list = forecastData['list'];
        if (list != null && list is List) {
          for (var item in list) {
            String dtTxt = item['dt_txt']?.toString() ?? "";
            if (dtTxt.isNotEmpty) {
              String date = dtTxt.split(' ')[0];
              if (date != lastDate) {
                dailyForecasts.add(item);
                lastDate = date;
              }
            }
          }
        }

        double rainVolume = 0.0;
        if (currentData.containsKey('rain') &&
            currentData['rain'].containsKey('1h')) {
          rainVolume = (currentData['rain']['1h'] as num).toDouble();
        }

        String desc = "";
        var weatherArr = currentData['weather'];
        if (weatherArr is List && weatherArr.isNotEmpty) {
          desc = weatherArr[0]['description']?.toString() ?? "";
        }

        _refreshController.stop();
        _refreshController.reset();

        setState(() {
          currentCity = currentData['name']?.toString() ?? "Unknown City";
          temperature = (currentData['main']?['temp'] ?? 0).round().toString();
          humidity = (currentData['main']?['humidity'] ?? 0).toString();
          windSpeed = ((currentData['wind']?['speed'] ?? 0) * 3.6)
              .round()
              .toString();
          rainfall = rainVolume.toStringAsFixed(1);
          weatherDescription = _capitalize(desc);
          forecastList = dailyForecasts.take(5).toList();
          isLoading = false;
          isRefreshing = false;
        });

        _fadeController.forward(from: 0);
        _slideController.forward(from: 0);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      _refreshController.stop();
      _refreshController.reset();
      setState(() {
        isLoading = false;
        isRefreshing = false;
        currentCity = "Location Error";
      });
      debugPrint('Weather Error: $e');
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: isLoading
          ? _buildLoader()
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: RefreshIndicator(
                  onRefresh: _getWeatherByLocation,
                  color: AppColors.accent,
                  backgroundColor: AppColors.surface,
                  strokeWidth: 2.5,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      const SliverToBoxAdapter(child: SizedBox(height: 12)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                          child: Column(
                            children: [
                              _buildLocationBar(),
                              const SizedBox(height: 20),
                              HeroWeatherCard(
                                temperature: temperature,
                                humidity: humidity,
                                windSpeed: windSpeed,
                                rainfall: rainfall,
                                description: weatherDescription,
                                language: widget.language,
                              ),
                              const SizedBox(height: 20),
                              TodaysRecommendationsSection(
                                temperature: temperature,
                                humidity: humidity,
                                windSpeed: windSpeed,
                                language: widget.language,
                              ),
                              const SizedBox(height: 18),
                              FarmingAlertsSection(
                                temperature: temperature,
                                humidity: humidity,
                                windSpeed: windSpeed,
                                forecastData: forecastList,
                                language: widget.language,
                              ),
                              const SizedBox(height: 18),
                              Forecast5DaySection(
                                forecastData: forecastList,
                                language: widget.language,
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLocationBar() {
    return GestureDetector(
      onTap: isRefreshing ? null : _getWeatherByLocation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E20).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t('your_location'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currentCity,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white30, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _refreshController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _refreshController.value * 2 * math.pi,
                        child: child,
                      );
                    },
                    child: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isRefreshing ? _t('loading') : _t('tap_refresh'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
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

  Widget _buildLoader() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bg, AppColors.surfaceMid],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.accentLight, AppColors.accentDark],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    blurRadius: 28,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _t('fetching_data'),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 3,
              width: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accentLight, AppColors.accentDark],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
