import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/event_model.dart';
import 'providers/attendance_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/event_provider.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/auth_gate_screen.dart';
import 'screens/create_event_screen.dart';
import 'screens/event_attendance_screen.dart';
import 'screens/login_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/register_screen.dart';
import 'screens/student_dashboard_screen.dart';
import 'utils/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SmartCollegeApp());
}

class SmartCollegeApp extends StatelessWidget {
  const SmartCollegeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
      ],
      child: MaterialApp(
        title: 'Smart College Event & Attendance',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.login,
        routes: {
          AppRoutes.login: (_) => const AuthGateScreen(),
          AppRoutes.register: (_) => const RegisterScreen(),
          AppRoutes.adminDashboard: (_) => const AdminDashboardScreen(),
          AppRoutes.studentDashboard: (_) => const StudentDashboardScreen(),
          AppRoutes.createEvent: (_) => const CreateEventScreen(),
          AppRoutes.eventAttendance: (_) => const EventAttendanceScreen(),
          AppRoutes.qrScanner: (_) => const QrScannerScreen(),
          AppRoutes.analytics: (_) => const AnalyticsScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.eventAttendance &&
              settings.arguments is EventModel) {
            return MaterialPageRoute(
              builder: (_) => const EventAttendanceScreen(),
              settings: settings,
            );
          }
          return null;
        },
      ),
    );
  }
}
