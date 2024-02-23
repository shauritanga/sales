import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/models/sale.dart';

final saleSupervisorSummaryStreamProvider =
    StreamProvider.autoDispose<Sale>((ref) {
  final firestore = FirebaseFirestore.instance;

  final salesStream = firestore.collection("sales").snapshots();
  final outletStream = firestore.collection("outlets").snapshots();

  final combinedStream = StreamZip([salesStream, outletStream]);
  return combinedStream.asyncMap((snapshot) {
    // final totalSales = snapshot[0].docs.length;
    // final totalOutlets = snapshot[1].docs.length;
    final outletDocuments = snapshot[1].docs;
    final saleDocuments = snapshot[0].docs;
    final sales = saleDocuments.map((document) => document.data()).toList();
    final outlets = outletDocuments.map((document) => document.data()).toList();
    final reqiredSales = sales.where((sale) =>
        sale['distributor']['supervisor']['email'] ==
        FirebaseAuth.instance.currentUser?.email);

    final reqiredOutlets = outlets.where((outlet) =>
        outlet['distributor']['supervisor']['email'] ==
        FirebaseAuth.instance.currentUser?.email);

    final totalSales = reqiredSales.length;
    final totalOutlets = reqiredOutlets.length;

    // Create a map to store sale counts for each seller
    Map<String, int> saleCounts = {};

    // Calculate sale counts for each seller
    for (var sale in reqiredSales) {
      var sellerDetails = sale['distributor'];
      var sellerKey = '${sellerDetails['name']}_${sellerDetails['imageUrl']}';
      saleCounts.update(sellerKey, (value) => value + 1, ifAbsent: () => 1);
    }

    // Prepare the final result
    List<Map<String, dynamic>> result = [];

    // Populate the final result with sale counts and seller details
    saleCounts.forEach((sellerKey, saleCount) {
      var sellerDetails = sellerKey.split('_');
      result.add({
        'sale_count': saleCount,
        'seller': {'name': sellerDetails[0], 'imageUrl': sellerDetails[1]}
      });
    });

    final sale = Sale(
      totalSales: totalSales,
      totalOutlets: totalOutlets,
      topSellers: result,
    );
    return sale;
  });
});
