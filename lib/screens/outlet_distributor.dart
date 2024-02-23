import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/widgets/add_customer_entry.dart';
import 'package:sales/widgets/distributor_drawer.dart';

class OutletScreen extends ConsumerStatefulWidget {
  const OutletScreen({super.key});

  @override
  ConsumerState<OutletScreen> createState() => _OutletScreenState();
}

class _OutletScreenState extends ConsumerState<OutletScreen> {
  final TextEditingController _searchController = TextEditingController();

  late Stream<List<DocumentSnapshot>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance
        .collection("outlets")
        .where("distributorId",
            isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  void _filterSearchResults(String query) {
    setState(() {
      if (query.isNotEmpty) {
        _stream = FirebaseFirestore.instance
            .collection('outlets')
            .where("distributorId",
                isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots()
            .map((snapshot) => snapshot.docs
                .where(
                  (doc) => doc['location'].toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList());
      } else {
        // If query is empty, load all documents again
        _stream = FirebaseFirestore.instance
            .collection('outlets')
            .where("distributorId",
                isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots()
            .map((snapshot) => snapshot.docs);
      }
    });
  }

  String queryString = "";

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).viewPadding.top;
    double bottomBarHeight = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Outlets"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      drawer: DistributorDrawer(
          statusBarHeight: statusBarHeight, bottomBarHeight: bottomBarHeight),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
              ),
              child: SizedBox(
                height: 48,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      queryString = value;

                      _filterSearchResults(queryString);
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Search by location',
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7.0)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder(
                stream: _stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final documents = snapshot.data!;
                  if (documents.isEmpty) {
                    return const Center(
                      child: Text("Hujasajiri mtu yeyote"),
                    );
                  }
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> person =
                          documents[index].data() as Map<String, dynamic>;
                      return InkWell(
                        onTap: () {},
                        child: Container(
                          margin: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(220),
                            borderRadius: BorderRadius.circular(7),
                            boxShadow: const [
                              BoxShadow(
                                offset: Offset(1, 2),
                                color: Colors.grey,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${person['name']}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          "${person['location']}",
                                          style: const TextStyle(
                                              fontSize: 10, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CustomerEntryDialog()),
          );
        },
        backgroundColor: const Color(0xff102d61),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
