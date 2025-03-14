import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/user/user_dashboard.dart';
import 'screens/inventory/inventory_screen.dart';
import 'screens/sales/voice_sales_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/profile_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vet Cashier',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            // User is logged in, determine role and show appropriate dashboard
            return FutureBuilder<DocumentSnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(snapshot.data!.uid)
                      .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                // Check user role
                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  Map<String, dynamic> userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;

                  String role = userData['role'] ?? 'user';
                  String storeId = userData['storeId'] ?? '';

                  if (role == 'admin') {
                    return AdminDashboard();
                  } else {
                    return UserDashboard();
                  }
                }

                // Default to user dashboard if role not found
                return UserDashboard();
              },
            );
          }

          // User is not logged in, show login screen
          return const LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/admin-dashboard': (context) => const AdminDashboard(),
        '/user-dashboard': (context) => const UserDashboard(),
        // For inventory, we need to get the store ID from the current user
        '/inventory': (context) {
          // Get store ID from current user
          final User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            return FutureBuilder<DocumentSnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasData && snapshot.data!.exists) {
                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final storeId = userData['storeId'] ?? '';

                  if (storeId.isEmpty) {
                    return const Scaffold(
                      body: Center(
                        child: Text('No store assigned to this user'),
                      ),
                    );
                  }

                  return InventoryScreen(storeId: storeId);
                }

                return const Scaffold(
                  body: Center(child: Text('Unable to load user data')),
                );
              },
            );
          }

          return const LoginScreen();
        },
        '/voice-sales': (context) {
          // Get store ID from current user
          final User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            return FutureBuilder<DocumentSnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasData && snapshot.data!.exists) {
                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final storeId = userData['storeId'] ?? '';

                  if (storeId.isEmpty) {
                    return const Scaffold(
                      body: Center(
                        child: Text('No store assigned to this user'),
                      ),
                    );
                  }

                  return VoiceSalesScreen(storeId: storeId);
                }

                return const Scaffold(
                  body: Center(child: Text('Unable to load user data')),
                );
              },
            );
          }

          return const LoginScreen();
        },
        '/reports': (context) {
          // Get store ID from current user
          final User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            return FutureBuilder<DocumentSnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasData && snapshot.data!.exists) {
                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final storeId = userData['storeId'] ?? '';

                  if (storeId.isEmpty) {
                    return const Scaffold(
                      body: Center(
                        child: Text('No store assigned to this user'),
                      ),
                    );
                  }

                  return ReportsScreen(storeId: storeId);
                }

                return const Scaffold(
                  body: Center(child: Text('Unable to load user data')),
                );
              },
            );
          }

          return const LoginScreen();
        },
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
        // Add more routes as we create screens
        // '/user-management': (context) => const UserManagementScreen(),
      },
    );
  }
}
