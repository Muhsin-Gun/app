// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/user_model.dart';
import 'package:app/core/constants.dart';

void main() {
  group('ProMarket App Tests', () {
    test('UserModel creation and validation', () {
      final user = UserModel(
        uid: 'test-uid',
        name: 'Test User',
        email: 'test@example.com',
        role: 'client',
        createdAt: DateTime.now(),
      );

      expect(user.uid, 'test-uid');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.role, 'client');
      expect(user.isClient, true);
      expect(user.isAdmin, false);
      expect(user.isEmployee, false);
      expect(user.isValid, true);
    });

    test('App constants are defined', () {
      expect(AppConstants.appName, 'ProMarket');
      expect(AppConstants.appVersion, '1.0.0');
      expect(AppConstants.adminRole, 'admin');
      expect(AppConstants.clientRole, 'client');
      expect(AppConstants.employeeRole, 'employee');
    });

    test('App strings are defined', () {
      expect(AppStrings.signInWithGoogle, 'Sign in with Google');
      expect(AppStrings.admin, 'Admin');
      expect(AppStrings.client, 'Client');
      expect(AppStrings.employee, 'Employee');
    });
  });
}
