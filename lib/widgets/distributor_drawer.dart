import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/Providers/auth.dart';
import 'package:sales/auth_wrapper.dart';
import 'package:sales/screens/distributor_home.dart';
import 'package:sales/screens/outlet_distributor.dart';
import 'package:sales/screens/sale_distributor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DistributorDrawer extends ConsumerWidget {
  const DistributorDrawer({
    required this.statusBarHeight,
    required this.bottomBarHeight,
    super.key,
  });

  final double statusBarHeight;
  final double bottomBarHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: Column(
        children: [
          SizedBox(height: statusBarHeight),
          ListTile(
            leading: const Icon(EvaIcons.gridOutline),
            title: const Text("Dashboard"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const DistributorHomeScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(EvaIcons.shoppingBagOutline),
            title: const Text("Sales"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const DistributorSalesScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(EvaIcons.personDoneOutline),
            title: const Text("Outlets"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const OutletScreen(),
                ),
              );
            },
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ListTile(
                leading: const Icon(EvaIcons.powerOutline),
                title: const Text("Logout"),
                onTap: () async {
                  SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                  await ref.read(authService).signOut();
                  await preferences.remove("role");
                  //ignore: use_build_context_synchronously
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AuthWrapper(),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: bottomBarHeight),
        ],
      ),
    );
  }
}
