import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/Providers/summary_distributor.dart';
import 'package:sales/widgets/distributor_drawer.dart';
import 'package:sales/widgets/summary.dart';

class DistributorHomeScreen extends ConsumerStatefulWidget {
  const DistributorHomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DistributorHomeScreenState();
}

class _DistributorHomeScreenState extends ConsumerState<DistributorHomeScreen> {
  List<Map<String, dynamic>> sellers = [
    {"name": "Athanas Shauritanga", "sales": 2609},
    {"name": "Athanas Shauritanga", "sales": 2609},
    {"name": "Athanas Shauritanga", "sales": 2609},
    {"name": "Athanas Shauritanga", "sales": 2609},
    {"name": "Athanas Shauritanga", "sales": 2609},
  ];
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double statusBarHeight = MediaQuery.of(context).viewPadding.top;
    double bottomBarHeight = MediaQuery.of(context).viewPadding.bottom;
    final asyncValue = ref.watch(saleDisributorSummaryStreamProvider);

    return asyncValue.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Text("$error"),
      data: (data) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Dashboard"),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          drawer: DistributorDrawer(
            statusBarHeight: statusBarHeight,
            bottomBarHeight: bottomBarHeight,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: size.height * 0.2,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        "https://images.unsplash.com/photo-1524250426644-e24b385c291a?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MzR8fEFsY29ob2wlMjBzaG9wfGVufDB8fDB8fHww",
                        scale: 1.0,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Sales Summary"),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        size: size,
                        backgroundColor: Colors.amber,
                        icon: EvaIcons.shoppingBagOutline,
                        value: "${data.totalSales}",
                        title: "Total Sales",
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SummaryCard(
                        size: size,
                        backgroundColor: Colors.red,
                        icon: EvaIcons.peopleOutline,
                        value: "${data.totalOutlets}",
                        title: "Total customers",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
