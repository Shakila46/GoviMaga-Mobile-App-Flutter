import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

class HeroWeatherCard extends StatelessWidget {
  final String temperature, humidity, windSpeed, rainfall, description;

  const HeroWeatherCard({
    super.key,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.rainfall,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: AppColors.surface,
        border: Border.all(color: AppColors.accentBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowDeep,
            blurRadius: 30,
            spreadRadius: 0,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 7,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(27)),
              gradient: LinearGradient(
                colors: [
                  AppColors.accentLight,
                  AppColors.accentDark,
                  AppColors.accentDeep,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              temperature,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 88,
                                fontWeight: FontWeight.w200,
                                height: 1,
                                letterSpacing: -5,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Text(
                                '°C',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.surfaceMid,
                                AppColors.accentGlow,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.accentBorder,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            description.isEmpty
                                ? 'Current Weather'
                                : description,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.accentLight,
                                AppColors.accentDeep,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.45),
                                blurRadius: 20,
                                offset: const Offset(0, 7),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.wb_sunny_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentGlow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.accentBorder,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            DateFormat('MMM d').format(DateTime.now()),
                            style: const TextStyle(
                              color: AppColors.accentDark,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Container(
                  height: 1.5,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.accentBorder,
                        AppColors.accent,
                        AppColors.accentBorder,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        icon: Icons.water_drop_outlined,
                        value: '$humidity%',
                        label: 'Humidity',
                        color: AppColors.coolBlue,
                      ),
                    ),
                    Container(width: 1, height: 44, color: AppColors.divider),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.air_rounded,
                        value: '$windSpeed km/h',
                        label: 'Wind',
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Container(width: 1, height: 44, color: AppColors.divider),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.grain_rounded,
                        value: '$rainfall mm',
                        label: 'Rainfall',
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.12),
                color.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 14.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary.withValues(alpha: 0.45),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}