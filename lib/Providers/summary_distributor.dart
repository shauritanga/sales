import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/models/sale.dart';

final saleDisributorSummaryStreamProvider =
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
        sale['distributorId'] == FirebaseAuth.instance.currentUser?.uid);

    final reqiredOutlets = outlets.where((outlet) =>
        outlet['distributorId'] == FirebaseAuth.instance.currentUser?.uid);

    final totalSales = reqiredSales.length;
    final totalOutlets = reqiredOutlets.length;

    final sale = Sale(
      totalSales: totalSales,
      totalOutlets: totalOutlets,
    );
    return sale;
  });
});
