import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../providers/booking_provider.dart';
import '../../../../providers/product_provider.dart';
import '../../../../providers/employee_provider.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed Analytics', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Revenue Trends', Icons.trending_up_rounded),
            SizedBox(height: 2.h),
            _buildRevenueChart(context),
            SizedBox(height: 4.h),
            
            Row(
              children: [
                Expanded(child: _buildSectionHeader(context, 'By Category', Icons.pie_chart_rounded)),
                Expanded(child: _buildSectionHeader(context, 'Success Rate', Icons.speed_rounded)),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(child: _buildCategoryDistribution(context)),
                SizedBox(width: 4.w),
                Expanded(child: _buildCompletionRateGauge(context)),
              ],
            ),
            SizedBox(height: 4.h),
            
            _buildSectionHeader(context, 'Employee Performance', Icons.leaderboard_rounded),
            SizedBox(height: 2.h),
            _buildEmployeePerformanceBarChart(context),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
      ],
    );
  }

  Widget _buildRevenueChart(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 30.h,
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 3),
                FlSpot(1, 4),
                FlSpot(2, 3.5),
                FlSpot(3, 5),
                FlSpot(4, 4.5),
                FlSpot(5, 6),
              ],
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 4,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildCategoryDistribution(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 20.h,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 30,
          sections: [
            PieChartSectionData(color: Colors.blue, value: 40, title: '40%', radius: 20, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
            PieChartSectionData(color: Colors.green, value: 30, title: '30%', radius: 20, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
            PieChartSectionData(color: Colors.orange, value: 15, title: '15%', radius: 20, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
            PieChartSectionData(color: Colors.purple, value: 15, title: '15%', radius: 20, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildCompletionRateGauge(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 20.h,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: 0.92,
                strokeWidth: 10,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                color: Colors.green,
                strokeCap: StrokeCap.round,
              ),
            ),
            const Text('92%', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildEmployeePerformanceBarChart(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 25.h,
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: theme.colorScheme.primary, width: 12, borderRadius: BorderRadius.circular(4))]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: theme.colorScheme.secondary, width: 12, borderRadius: BorderRadius.circular(4))]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 7, color: theme.colorScheme.tertiary, width: 12, borderRadius: BorderRadius.circular(4))]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 9, color: Colors.orange, width: 12, borderRadius: BorderRadius.circular(4))]),
            BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 5, color: Colors.blue, width: 12, borderRadius: BorderRadius.circular(4))]),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms);
  }
}
