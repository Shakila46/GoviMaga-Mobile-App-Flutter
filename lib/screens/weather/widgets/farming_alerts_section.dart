import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'shared_components.dart';

class FarmingAlertsSection extends StatelessWidget {
  final String temperature;
  final String humidity;
  final String windSpeed;
  final List<dynamic> forecastData;

  const FarmingAlertsSection({
    super.key,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.forecastData,
  });

  List<Map<String, dynamic>> _getDynamicAlerts() {
    List<Map<String, dynamic>> alerts = [];
    int temp = int.tryParse(temperature) ?? 25;
    int hum = int.tryParse(humidity) ?? 60;
    int wind = int.tryParse(windSpeed) ?? 10;

    bool hasRain = false;
    for (var item in forecastData) {
      var weatherList = item['weather'];
      String weatherCondition =
      (weatherList is List && weatherList.isNotEmpty)
          ? weatherList[0]['main']?.toString().toLowerCase() ?? ""
          : "";
      if (weatherCondition.contains("rain") ||
          weatherCondition.contains("storm") ||
          weatherCondition.contains("thunderstorm")) {
        hasRain = true;
        break;
      }
    }

    if (hasRain) {
      alerts.add({
        'text':
        'Rainy conditions expected in the next few days. Check your drainage systems.',
        'icon': Icons.umbrella_rounded,
        'color': AppColors.coolBlue,
        'bgColor': const Color(0xFFEFF8FF),
        'borderColor': const Color(0xFFBFE3F9),
      });
    }

    if (temp >= 35) {
      alerts.add({
        'text':
        'High temperature ($temp°C)! Provide shade for young plants and supply extra water.',
        'icon': Icons.thermostat_rounded,
        'color': AppColors.alertRed,
        'bgColor': const Color(0xFFFFF5F5),
        'borderColor': const Color(0xFFFECACA),
      });
    } else if (temp <= 15) {
      alerts.add({
        'text':
        'Low temperatures detected ($temp°C). Apply mulch to protect crops from the cold.',
        'icon': Icons.ac_unit_rounded,
        'color': AppColors.coolBlue,
        'bgColor': const Color(0xFFEFF8FF),
        'borderColor': const Color(0xFFBFE3F9),
      });
    }

    if (hum >= 80) {
      alerts.add({
        'text':
        'Very high humidity ($hum%)! High risk of fungal diseases spreading. Monitor your crops closely.',
        'icon': Icons.water_drop_rounded,
        'color': AppColors.alertAmber,
        'bgColor': AppColors.alertAmberBg,
        'borderColor': AppColors.alertAmberBorder,
      });
    }

    if (wind >= 30) {
      alerts.add({
        'text':
        'Strong winds ($wind km/h). Protect greenhouses and tall crops from wind damage.',
        'icon': Icons.storm_rounded,
        'color': AppColors.alertRed,
        'bgColor': const Color(0xFFFFF5F5),
        'borderColor': const Color(0xFFFECACA),
      });
    }

    if (alerts.isEmpty) {
      alerts.add({
        'text':
        'No significant weather risks at the moment. Favorable conditions for farming today!',
        'icon': Icons.check_circle_rounded,
        'color': AppColors.accent,
        'bgColor': AppColors.accentGlow,
        'borderColor': AppColors.accentBorder,
      });
    }

    return alerts;
  }

  @override
  Widget build(BuildContext context) {
    final currentAlerts = _getDynamicAlerts();

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Farming Alerts',
            icon: Icons.notification_important_rounded,
            iconColor: AppColors.alertAmber,
          ),
          const SizedBox(height: 16),
          ...currentAlerts.map((alert) {
            final color = alert['color'] as Color;
            final bgColor =
                alert['bgColor'] as Color? ?? color.withValues(alpha: 0.07);
            final borderColor = alert['borderColor'] as Color? ??
                color.withValues(alpha: 0.25);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1.2),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: color.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        alert['icon'] as IconData,
                        color: color,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          alert['text'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}