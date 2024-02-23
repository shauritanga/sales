import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales/widgets/custom_search.dart';

class SaleEntryDialog extends ConsumerStatefulWidget {
  const SaleEntryDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SaleEntryDialogState();
}

class _SaleEntryDialogState extends ConsumerState<SaleEntryDialog> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController _dayController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String nameContactPerson = "";
  String numberOfBottles = "";
  String numberOfCartons = "";
  bool bottles = false;
  bool cartoons = false;
  String? daySold;
  String day = "";
  String query = "";
  String searchedKey = "Search";
  String imageUrl = "";
  String phone = "";
  Map<String, dynamic> outlet = {};

  @override
  void dispose() {
    _dayController.dispose();
    super.dispose();
  }

  bool isLoading = false;
  UploadTask? uploadTask;

  Future uploadProfileImage(File file, XFile? pickedImage) async {
    final path = "images/${pickedImage!.name}";
    final ref = FirebaseStorage.instance.ref().child(path);

    try {
      ref.putFile(file);
    } catch (e) {
      throw Exception("File upload failed");
    }

    setState(() {
      uploadTask = ref.putFile(file);
    });
    try {
      final snapshot = await uploadTask!.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      setState(() {
        imageUrl = urlDownload;
      });
    } catch (e) {
      throw Exception("Fail to upload to firebase storage");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New sale',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          TextButton(
            onPressed: isLoading
                ? null
                : () async {
                    final result = await FirebaseFirestore.instance
                        .collection("users")
                        .where("email",
                            isEqualTo: FirebaseAuth.instance.currentUser?.email)
                        .get();

                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState?.save();

                      Map<String, dynamic> data = {
                        "outlet": outlet,
                        "timestamp": day,
                        "contact_person": nameContactPerson,
                        "contact_phone": phone,
                        "place_image": imageUrl,
                        "distributorId": FirebaseAuth.instance.currentUser?.uid,
                        "distributor": result.docs.first.data(),
                      };
                      if (bottles) {
                        Map<String, dynamic> additional = {
                          "number_of_bottles": numberOfBottles,
                        };
                        data.addAll(additional);
                      }
                      if (cartoons) {
                        Map<String, dynamic> additional = {
                          "number_of_cartons": numberOfCartons,
                        };
                        data.addAll(additional);
                      }
                      try {
                        // ignore: use_build_context_synchronously
                        await showDialog(
                          context: context,
                          builder: (context) => FutureProgressDialog(
                            firestore.collection("sales").add(data),
                            message: const Text('Loading...'),
                          ),
                        );
                        // await firestore.collection("sales").add(data);
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                      } catch (e) {
                        print(e);
                      }
                    }
                  },
            child: Text(
              'Save',
              style: TextStyle(
                  color: isLoading
                      ? Colors.grey
                      : Theme.of(context).colorScheme.onPrimary),
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
                //showSearch(context: context, delegate: delegate)
                GestureDetector(
                  onTap: () async {
                    final result = await showSearch(
                        context: context, delegate: CustomSearchClass());
                    final outletResult = result.data();
                    setState(() {
                      searchedKey = outletResult['name'];
                      outlet = outletResult;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    height: 56,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey),
                        borderRadius: BorderRadius.circular(5)),
                    child: Row(
                      children: [
                        const Icon(Icons.search),
                        const SizedBox(width: 8),
                        Text(searchedKey)
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Text("Date"),
                const SizedBox(height: 8),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: "Sold day",
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
                            DateTime.now().month,
                            DateTime.now().day,
                          ),
                          lastDate: DateTime(
                            DateTime.now().year + 3,
                            DateTime.now().month,
                            DateTime.now().day,
                          ),
                        );
                        final daySoldText =
                            doBirth!.toIso8601String().split("T")[0];
                        _dayController.text = daySoldText;
                        setState(() {
                          day = doBirth.toIso8601String();
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
                const SizedBox(height: 16),
                const Text("Contact person"),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Enter person name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onSaved: (value) => nameContactPerson = value!,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Jaza kijiji au mtaa anaoishi";
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
                const SizedBox(height: 16),
                const Text("Sales"),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Checkbox(
                            value: bottles,
                            onChanged: (value) {
                              setState(() {
                                bottles = value!;
                              });
                            },
                          ),
                          const Text("Bottles"),
                        ],
                      ),
                    ),
                    Expanded(
                      child: bottles
                          ? TextFormField(
                              onSaved: (value) => numberOfBottles = value!,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter your name";
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                            )
                          : const SizedBox(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Checkbox(
                            value: cartoons,
                            onChanged: (value) {
                              setState(() {
                                cartoons = value!;
                              });
                            },
                          ),
                          const Text("Cartons")
                        ],
                      ),
                    ),
                    Expanded(
                      child: cartoons
                          ? TextFormField(
                              onSaved: (value) => numberOfCartons = value!,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter your name";
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                            )
                          : const SizedBox(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text("Picha"),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: () async {
                      ImagePicker picker = ImagePicker();
                      final pickedImage =
                          await picker.pickImage(source: ImageSource.camera);

                      final file = File(pickedImage!.path);
                      setState(() {
                        isLoading = true;
                      });
                      await uploadProfileImage(file, pickedImage);
                      setState(() {
                        isLoading = false;
                      });
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        border: Border.all(width: 1, color: Colors.grey),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: isLoading
                          ? const Center(
                              child: SizedBox(
                                height: 35,
                                width: 35,
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : Image.network(
                              imageUrl == ""
                                  ? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQofHJFmvUkoZgk9cHJsB5XrkMGy2W-qIiCqkIhXWv3e1GkxA_N2mfS&usqp=CAE&s"
                                  : imageUrl,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
