import 'package:flutter/material.dart';
import 'package:sales/auth_wrapper.dart';
import 'package:sales/screens/admin_home.dart';
import 'package:sales/screens/distributor_home.dart';
import 'package:sales/screens/supervisor_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<String> checkRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    final role = preferences.getString("role");
    return role!;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final data = snapshot.data;
        if (data == null) {
          return const AuthWrapper();
        }
        if (data == "admin") {
          return const AdminHomeScreen();
        }
        if (data == "supervisor") {
          return const SupervisorHomeScreen();
        }
        return const DistributorHomeScreen();
      },
    );
  }
}
