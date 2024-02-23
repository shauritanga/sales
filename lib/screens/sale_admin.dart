import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/widgets/admin_drawer.dart';

class AdminSalesScreen extends ConsumerStatefulWidget {
  const AdminSalesScreen({super.key});

  @override
  ConsumerState<AdminSalesScreen> createState() => _AdminSalesScreenState();
}

class _AdminSalesScreenState extends ConsumerState<AdminSalesScreen> {
  final TextEditingController _dayController = TextEditingController();

  late Stream<List<DocumentSnapshot>> _stream;
  DateTime createdAt = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance
        .collection("sales")
        .where("timestamp", isEqualTo: createdAt.toIso8601String())
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  void _filterSearchResults(String query) {
    setState(() {
      if (query.isNotEmpty) {
        _stream = FirebaseFirestore.instance
            .collection('sales')
            .where("timestamp", isEqualTo: query)
            .snapshots()
            .map((snapshot) => snapshot.docs);
      } else {
        // If query is empty, load all documents again
        _stream = FirebaseFirestore.instance
            .collection('sales')
            .where("timestamp", isEqualTo: createdAt.toIso8601String())
            .snapshots()
            .map((snapshot) => snapshot.docs);
      }
    });
  }

  String? daySold;

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).viewPadding.top;
    double bottomBarHeight = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      drawer: AdminDrawer(
          statusBarHeight: statusBarHeight, bottomBarHeight: bottomBarHeight),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: "search bt date",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                suffixIcon: IconButton(
                  onPressed: () async {
                    DateTime? doBirth = await showDatePicker(
                      currentDate: DateTime.now(),
                      context: context,
                      firstDate: DateTime(
                        DateTime.now().year - 2,
                      ),
                      lastDate: DateTime(
                        DateTime.now().year + 3,
                      ),
                    );
                    final daySoldText =
                        doBirth!.toIso8601String().split("T")[0];
                    _dayController.text = daySoldText;
                    setState(() {
                      createdAt = doBirth;
                      _filterSearchResults(createdAt.toIso8601String());
                    });
                  },
                  icon: const Icon(Icons.calendar_month),
                ),
              ),
              controller: _dayController,
              onSaved: (value) => daySold = value,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Jaza tarehe ya kuzaliwa";
                }
                return null;
              },
              keyboardType: TextInputType.datetime,
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
                      child: Text("No any sale on this day"),
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
                              CircleAvatar(
                                backgroundImage:
                                    NetworkImage("${person['place_image']}"),
                              ),
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
                                          "${person['outlet']['name']}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          "${person['outlet']['location']}",
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
    );
  }
}
