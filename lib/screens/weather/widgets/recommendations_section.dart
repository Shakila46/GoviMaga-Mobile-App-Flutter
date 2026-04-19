import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'shared_components.dart';

class TodaysRecommendationsSection extends StatelessWidget {
  final String temperature;
  final String humidity;
  final String windSpeed;

  const TodaysRecommendationsSection({
    super.key,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
  });

  List<Map<String, dynamic>> _getRecommendations() {
    List<Map<String, dynamic>> tips = [];
    int temp = int.tryParse(temperature) ?? 25;
    int hum = int.tryParse(humidity) ?? 60;
    int wind = int.tryParse(windSpeed) ?? 10;

    if (temp >= 30) {
      tips.add({
        'text':
        'High temperature (${temp}°C). Water crops early morning or late evening to reduce evaporation.',
        'icon': Icons.thermostat_rounded,
        'color': AppColors.warmOrange,
      });
    } else if (temp >= 22 && temp < 30) {
      tips.add({
        'text':
        'Ideal temperature (${temp}°C) for most crops. Good day for transplanting seedlings.',
        'icon': Icons.check_circle_outline_rounded,
        'color': AppColors.accent,
      });
    } else if (temp >= 15 && temp < 22) {
      tips.add({
        'text':
        'Mild temperature (${temp}°C). Suitable for cool-season crops like cabbage, carrots and lettuce.',
        'icon': Icons.eco_rounded,
        'color': AppColors.accentDark,
      });
    } else if (temp < 15) {
      tips.add({
        'text':
        'Cool temperature (${temp}°C). Protect sensitive crops from cold stress with mulching.',
        'icon': Icons.ac_unit_rounded,
        'color': AppColors.coolBlue,
      });
    }

    if (hum >= 80) {
      tips.add({
        'text':
        'Very high humidity (${hum}%). High risk of fungal diseases — apply preventive fungicide and improve airflow.',
        'icon': Icons.warning_amber_rounded,
        'color': AppColors.alertAmber,
      });
    } else if (hum >= 60 && hum < 80) {
      tips.add({
        'text':
        'Moderate humidity (${hum}%). Monitor crops for early signs of leaf blight or mildew.',
        'icon': Icons.water_drop_outlined,
        'color': AppColors.coolBlue,
      });
    } else if (hum >= 40 && hum < 60) {
      tips.add({
        'text':
        'Good humidity level (${hum}%). Maintain regular irrigation schedule.',
        'icon': Icons.opacity_rounded,
        'color': AppColors.accent,
      });
    } else if (hum < 40) {
      tips.add({
        'text':
        'Low humidity (${hum}%). Increase irrigation frequency. Mulch soil to retain moisture.',
        'icon': Icons.water_drop_outlined,
        'color': AppColors.alertAmber,
      });
    }

    if (wind <= 15) {
      tips.add({
        'text':
        'Low wind (${wind} km/h). Good conditions for spraying fertilizer or pesticides today.',
        'icon': Icons.air_rounded,
        'color': AppColors.accent,
      });
    } else if (wind > 15 && wind <= 30) {
      tips.add({
        'text':
        'Moderate wind (${wind} km/h). Avoid spraying chemicals — solution may drift away from crops.',
        'icon': Icons.air_rounded,
        'color': AppColors.alertAmber,
      });
    } else {
      tips.add({
        'text':
        'Strong winds (${wind} km/h). Secure greenhouse covers and young plants. Avoid field operations.',
        'icon': Icons.storm_rounded,
        'color': AppColors.alertRed,
      });
    }

    if (temp >= 25 && hum >= 70) {
      tips.add({
        'text':
        'Warm and humid conditions — ideal for pest activity. Scout fields for insects today.',
        'icon': Icons.bug_report_outlined,
        'color': AppColors.alertAmber,
      });
    }

    if (temp >= 20 && temp <= 28 && hum >= 50 && hum < 75 && wind <= 20) {
      tips.add({
        'text':
        'Overall favorable weather. Good day for harvesting mature crops.',
        'icon': Icons.agriculture_rounded,
        'color': AppColors.accent,
      });
    }

    return tips;
  }

  @override
  Widget build(BuildContext context) {
    final tips = _getRecommendations();
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: "Today's Recommendations",
            icon: Icons.tips_and_updates_rounded,
            iconColor: AppColors.accent,
          ),
          const SizedBox(height: 16),
          ...tips.asMap().entries.map((entry) {
            final tip = entry.value;
            final Color tipColor = tip['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.surfaceLight,
                      AppColors.surfaceMid.withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: tipColor.withValues(alpha: 0.22),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: tipColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: tipColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        tip['icon'] as IconData,
                        color: tipColor,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          tip['text'] as String,
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