// lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/authentication_screen/authentication_screen.dart';
import '../presentation/home_dashboard_screen/home_dashboard_screen.dart';
import '../presentation/transaction_list_screen/transaction_list_screen.dart';
import '../presentation/add_transaction_screen/add_transaction_screen.dart';
import '../presentation/budget_management_screen/budget_management_screen.dart';
import '../presentation/user_profile_screen/user_profile_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String authentication = '/authentication-screen';
  static const String homeDashboard = '/home-dashboard-screen';
  static const String transactionList = '/transaction-list-screen';
  static const String addTransaction = '/add-transaction-screen';
  static const String budgetManagement = '/budget-management-screen';
  static const String userProfile = '/user-profile-screen';

  static Map<String, WidgetBuilder> get routes => {
    initial: (context) => const SplashScreen(),
    authentication: (context) => const AuthenticationScreen(),
    homeDashboard: (context) => const HomeDashboardScreen(),
    transactionList: (context) => const TransactionListScreen(),
    addTransaction: (context) => const AddTransactionScreen(),
    budgetManagement: (context) => const BudgetManagementScreen(),
    userProfile: (context) => const UserProfileScreen(),
  };
}
