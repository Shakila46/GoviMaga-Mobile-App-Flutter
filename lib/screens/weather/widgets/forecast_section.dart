import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import 'shared_components.dart';

class Forecast5DaySection extends StatelessWidget {
  final List<dynamic> forecastData;
  const Forecast5DaySection({super.key, required this.forecastData});

  IconData _getWeatherIcon(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('rain') || c.contains('drizzle')) return Icons.grain_rounded;
    if (c.contains('cloud')) return Icons.cloud_rounded;
    if (c.contains('storm') || c.contains('thunder')) return Icons.flash_on;
    if (c.contains('snow')) return Icons.ac_unit_rounded;
    if (c.contains('clear')) return Icons.wb_sunny_rounded;
    return Icons.cloud_outlined;
  }

  Color _getTempColor(int temp) {
    if (temp >= 35) return AppColors.alertRed;
    if (temp >= 28) return AppColors.warmOrange;
    if (temp >= 20) return AppColors.accent;
    return AppColors.coolBlue;
  }

  // ✅ Fixed: was uppercasing entire string
  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: '5-Day Forecast',
            icon: Icons.calendar_month_rounded,
            iconColor: AppColors.coolBlue,
          ),
          const SizedBox(height: 16),
          ...forecastData.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            DateTime date = DateTime.parse(item['dt_txt'].toString());
            String day =
            i == 0 ? 'Today' : DateFormat('EEE, MMM d').format(date);
            int tempVal = ((item['main']?['temp'] ?? 0) as num).round();
            String temp = '$tempVal°C';

            var weatherList = item['weather'];
            String description =
            (weatherList is List && weatherList.isNotEmpty)
                ? weatherList[0]['description']?.toString() ?? ""
                : "";
            String mainCondition =
            (weatherList is List && weatherList.isNotEmpty)
                ? weatherList[0]['main']?.toString() ?? ""
                : "";

            final Color tempColor = _getTempColor(tempVal);

            return Container(
              margin: const EdgeInsets.only(bottom: 9),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                gradient: i == 0
                    ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.accentGlow, AppColors.surfaceMid],
                )
                    : LinearGradient(
                  colors: [
                    AppColors.surfaceLight,
                    AppColors.surfaceLight.withValues(alpha: 0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: i == 0
                      ? AppColors.accent.withValues(alpha: 0.4)
                      : AppColors.divider,
                  width: i == 0 ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 95,
                    child: Row(
                      children: [
                        if (i == 0)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: const BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.accentLight,
                                  AppColors.accent,
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        Flexible(
                          child: Text(
                            day,
                            style: TextStyle(
                              color: i == 0
                                  ? AppColors.accentDark
                                  : AppColors.textPrimary,
                              fontWeight: i == 0
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.coolBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getWeatherIcon(mainCondition),
                      color: AppColors.coolBlue,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _capitalize(description),
                      style: TextStyle(
                        color: i == 0
                            ? AppColors.textSecondary
                            : AppColors.textPrimary.withValues(alpha: 0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: i == 0
                          ? const LinearGradient(
                        colors: [
                          AppColors.accentLight,
                          AppColors.accentDark,
                        ],
                      )
                          : LinearGradient(
                        colors: [
                          tempColor.withValues(alpha: 0.15),
                          tempColor.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(11),
                      border: i == 0
                          ? null
                          : Border.all(
                        color: tempColor.withValues(alpha: 0.25),
                        width: 1,
                      ),
                      boxShadow: i == 0
                          ? [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                          : null,
                    ),
                    child: Text(
                      temp,
                      style: TextStyle(
                        color: i == 0 ? Colors.white : tempColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}