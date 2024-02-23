import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:sales/Providers/auth.dart';

class CustomerEntryDialog extends ConsumerStatefulWidget {
  const CustomerEntryDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CustomerEntryDialogState();
}

class _CustomerEntryDialogState extends ConsumerState<CustomerEntryDialog> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController _dayController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String name = "";
  String location = "";
  String owner = "";
  String phone = "";

  @override
  void dispose() {
    _dayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New customer',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          TextButton(
            onPressed: () async {
              final result = await FirebaseFirestore.instance
                  .collection("users")
                  .where("email",
                      isEqualTo: FirebaseAuth.instance.currentUser?.email)
                  .get();
              if (_formKey.currentState!.validate()) {
                _formKey.currentState?.save();

                Map<String, dynamic> data = {
                  "name": name,
                  "location": location,
                  "owerner": owner,
                  "phone": phone,
                  "distributorId": ref.watch(authService).currentUser?.uid,
                  "distributor": result.docs.first.data(),
                };

                try {
                  // ignore: use_build_context_synchronously
                  await showDialog(
                    context: context,
                    builder: (context) => FutureProgressDialog(
                      firestore.collection("outlets").add(data),
                      message: const Text('Loading...'),
                    ),
                  );
                  //await firestore.collection("outlets").add(data);
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                } catch (e) {
                  print(e);
                }
              }
            },
            child: Text(
              'Save',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Outlet Name"),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Enter outlet name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onSaved: (value) => name = value!,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Jaza kijiji au mtaa anaoishi";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16),
                const Text("Location"),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Enter location name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onSaved: (value) => location = value!,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Jaza kijiji au mtaa anaoishi";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16),
                const Text("Owner"),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Enter person name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onSaved: (value) => owner = value!,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Plesae enter owner name";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16),
                const Text("Phone number"),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Enter phone number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onSaved: (value) => phone = value!,
                  validator: (value) {
                    String pattern = r'^[+255|0]+[6|7]\d{8}$';
                    RegExp regExp = RegExp(pattern);
                    if (value!.isEmpty) {
                      return "Enter phone number";
                    } else if (!regExp.hasMatch(value)) {
                      return "Enter a valid phone number";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
