import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/prisoner_provider.dart';
import 'providers/hospitalization_provider.dart';
import 'providers/alert_provider.dart';
import 'providers/report_provider.dart';
import 'providers/audit_provider.dart';
import 'providers/expense_management_provider.dart';
import 'providers/food_management_provider.dart';
import 'providers/digital_document_provider.dart';
import 'app.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PrisonerProvider()),
        ChangeNotifierProvider(create: (_) => HospitalizationProvider()),
        ChangeNotifierProvider(create: (_) => AlertProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => AuditProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseManagementProvider()),
        ChangeNotifierProvider(create: (_) => FoodManagementProvider()),
        ChangeNotifierProvider(create: (_) => DigitalDocumentProvider()),
      ],
      child: MaterialApp(
        title: 'PenitSystem Quantum',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const App(),
      ),
    );
  }
}
