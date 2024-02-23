import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/Providers/summary_admin.dart';
import 'package:sales/widgets/admin_drawer.dart';
import 'package:sales/widgets/summary.dart';

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double statusBarHeight = MediaQuery.of(context).viewPadding.top;
    double bottomBarHeight = MediaQuery.of(context).viewPadding.bottom;
    final asyncValue = ref.watch(saleSummaryStreamProvider);

    return asyncValue.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => const Text("Something went wrong"),
      data: (data) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Dashboard"),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          drawer: AdminDrawer(
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Sales Summary"),
                    Text("Today"),
                  ],
                ),
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
                const SizedBox(height: 24),
                const Text(
                  "Top 5 sellers",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("seller"), Text("Number of sales")],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.topSellers!.length > 5
                        ? 5
                        : data.topSellers!.length,
                    itemBuilder: (context, index) {
                      final seller = data.topSellers![index];
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 0.5, color: Colors.grey),
                          ),
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        "${seller['seller']['imageUrl']}"),
                                  ),
                                  const SizedBox(width: 12),
                                  Text("${seller['seller']['name']}"),
                                ],
                              ),
                              Text("${seller['sale_count']}"),
                            ]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
