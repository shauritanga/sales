import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sales/widgets/add_customer_entry.dart';

class CustomSearchClass extends SearchDelegate {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  List<Widget> buildActions(BuildContext context) {
// this will show clear query button
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
// adding a back button to close the search
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('outlets').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        List<DocumentSnapshot> results = snapshot.data!.docs
            .where((DocumentSnapshot document) => document['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(results[index]['name']),
            // You can customize ListTile as per your requirement
            onTap: () {
              // Handle when a result is tapped
              close(context, results[index]);
            },
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('outlets').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final results = snapshot.data!.docs
            .where((e) => e['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
        if (results.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("No match"),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<Null>(
                            builder: (BuildContext context) {
                              return const CustomerEntryDialog();
                            },
                            fullscreenDialog: true),
                      );
                    },
                    child: const Text("add")),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) => InkWell(
            onTap: () {
              query = results[index]['name'];
              showResults(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    results[index]['name'],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_pin,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        results[index]['location'],
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
