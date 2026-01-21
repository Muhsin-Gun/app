import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../providers/employee_provider.dart';
import '../../../../models/user_model.dart';
import '../../../../widgets/custom_icon_widget.dart';
import '../../../../widgets/custom_image_widget.dart';

class ManageEmployeesScreen extends StatelessWidget {
  const ManageEmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Professionals', style: TextStyle(fontWeight: FontWeight.w900)), centerTitle: false),
      body: Consumer<EmployeeProvider>(
        builder: (context, provider, _) {
          final employees = provider.allEmployees;
          if (provider.isLoading && employees.isEmpty) return const Center(child: CircularProgressIndicator());
          if (employees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_alt_rounded, size: 64, color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  const Text('No employees found', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => provider.refreshEmployees(),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final employee = employees[index];
                final stats = provider.employeeStatistics[employee.uid] ?? {};

                return Container(
                  margin: EdgeInsets.only(bottom: 2.h),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CustomAvatarWidget(imageUrl: employee.photoUrl, fallbackText: employee.name[0], radius: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(employee.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                Text(employee.email, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                SizedBox(height: 0.5.h),
                                Row(
                                  children: [
                                    Container(width: 8, height: 8, decoration: BoxDecoration(color: employee.isActive ? Colors.green : Colors.red, shape: BoxShape.circle)),
                                    const SizedBox(width: 6),
                                    Text(employee.isActive ? 'Active' : 'Inactive', style: TextStyle(color: employee.isActive ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(value: employee.isActive, onChanged: (v) => provider.toggleEmployeeStatus(employee.uid, v)),
                        ],
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat(context, 'Jobs', stats['totalBookings']?.toString() ?? '0', Icons.assignment_rounded, Colors.blue),
                          _buildStat(context, 'Rating', '4.9', Icons.star_rounded, Colors.orange),
                          _buildStat(context, 'Success', '${stats['completionRate'] ?? 0}%', Icons.check_circle_rounded, Colors.green),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05, end: 0);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          ],
        ),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
