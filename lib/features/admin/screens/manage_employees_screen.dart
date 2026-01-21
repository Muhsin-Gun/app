import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../../providers/employee_provider.dart';
import '../../../../models/user_model.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/utils/animations.dart';
import '../../../widgets/custom_icon_widget.dart';

class ManageEmployeesScreen extends StatelessWidget {
  const ManageEmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Employees'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Consumer<EmployeeProvider>(
        builder: (context, employeeProvider, _) {
          final employees = employeeProvider.allEmployees;

          if (employeeProvider.isLoading && employees.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (employees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CustomIconWidget(iconName: 'people', size: 64, color: Colors.grey),
                  SizedBox(height: 2.h),
                  const Text('No employees yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text('Hire your first expert to grow your marketplace', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => employeeProvider.refreshEmployees(),
            child: ListView.builder(
              padding: EdgeInsets.all(4.w),
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final employee = employees[index];
                final stats = employeeProvider.employeeStatistics[employee.uid] ?? {};

                return FadeListItem(
                  index: index,
                  child: HoverWidget(
                    child: Card(
                      elevation: 0,
                      margin: EdgeInsets.only(bottom: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                  backgroundImage: employee.photoUrl != null ? NetworkImage(employee.photoUrl!) : null,
                                  child: employee.photoUrl == null
                                      ? Text(
                                          employee.name[0].toUpperCase(),
                                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                                        )
                                      : null,
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        employee.name,
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        employee.email,
                                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    const Text('Active', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                    Switch.adaptive(
                                      value: employee.isActive,
                                      activeColor: Colors.green,
                                      onChanged: (val) {
                                        employeeProvider.toggleEmployeeStatus(employee.uid, val);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  context,
                                  'Jobs',
                                  stats['totalBookings']?.toString() ?? '0',
                                  Icons.assignment_outlined,
                                  Colors.blue,
                                ),
                                _buildStatItem(
                                  context,
                                  'Success',
                                  '${stats['completionRate'] ?? 0}%',
                                  Icons.trending_up,
                                  Colors.green,
                                ),
                                _buildStatItem(
                                  context,
                                  'Recent',
                                  stats['thisMonthBookings']?.toString() ?? '0',
                                  Icons.calendar_today_outlined,
                                  Colors.orange,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
