import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../theme/app_colors.dart';
import 'hero_weather_card.dart';
import 'recommendations_section.dart';
import 'farming_alerts_section.dart';
import 'forecast_section.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

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

  List<dynamic> forecastList = [];

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

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
    super.dispose();
  }

  Future<void> _getWeatherByLocation() async {
    setState(() => isLoading = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services are disabled.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
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

        setState(() {
          currentCity = currentData['name']?.toString() ?? "Unknown City";
          temperature =
              (currentData['main']?['temp'] ?? 0).round().toString();
          humidity = (currentData['main']?['humidity'] ?? 0).toString();
          windSpeed = ((currentData['wind']?['speed'] ?? 0) * 3.6)
              .round()
              .toString();
          rainfall = rainVolume.toStringAsFixed(1);
          weatherDescription = _capitalize(desc);
          forecastList = dailyForecasts.take(5).toList();
          isLoading = false;
        });
        _fadeController.forward(from: 0);
        _slideController.forward(from: 0);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        currentCity = "Location Error";
      });
      debugPrint('Weather Error: $e');
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    // ✅ SizedBox.expand() — Scaffold body space සම්පූර්ණයෙන් fill කරනවා
    return SizedBox.expand(
      child: isLoading
          ? _buildLoader()
          : FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildLocationPill(),
                      const SizedBox(height: 24),
                      HeroWeatherCard(
                        temperature: temperature,
                        humidity: humidity,
                        windSpeed: windSpeed,
                        rainfall: rainfall,
                        description: weatherDescription,
                      ),
                      const SizedBox(height: 20),
                      TodaysRecommendationsSection(
                        temperature: temperature,
                        humidity: humidity,
                        windSpeed: windSpeed,
                      ),
                      const SizedBox(height: 18),
                      FarmingAlertsSection(
                        temperature: temperature,
                        humidity: humidity,
                        windSpeed: windSpeed,
                        forecastData: forecastList,
                      ),
                      const SizedBox(height: 18),
                      Forecast5DaySection(forecastData: forecastList),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Fixed: width/height double.infinity දුන්නා — සම්පූර්ණ screen fill වෙනවා
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
            const Text(
              'Fetching your farm data...',
              style: TextStyle(
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

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.accentDeep,
      expandedHeight: 108,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.5, 1.0],
              colors: [
                AppColors.accentDeep,
                AppColors.gradientMid,
                AppColors.accent,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Positioned(
                right: 30,
                bottom: 10,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 54, 20, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.eco_rounded,
                            color: AppColors.accentHero,
                            size: 20,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'Govi Maga',
                            style: TextStyle(
                              color: AppColors.textOnGreen,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Weather-Driven Crop Advisory',
                            style: TextStyle(
                              color: Color(0xCCFFFFFF),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.notifications_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationPill() {
    return GestureDetector(
      onTap: _getWeatherByLocation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.accentBorder, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowGreen,
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  colors: [AppColors.accentLight, AppColors.accent],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 9),
            const Icon(
              Icons.location_on_rounded,
              color: AppColors.accent,
              size: 15,
            ),
            const SizedBox(width: 5),
            Text(
              currentCity,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(width: 12),
            Container(width: 1, height: 14, color: AppColors.accentBorder),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceMid,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.refresh_rounded,
                    color: AppColors.textSecondary,
                    size: 13,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Refresh',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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
}