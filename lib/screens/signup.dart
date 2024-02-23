import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales/Providers/auth.dart';
import 'package:sales/auth_wrapper.dart';
import 'package:sales/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String name = "";
  String email = "";
  String phone = "";
  String password = "";
  String zone = "";
  String code = "";
  String? role;
  Map? supervisor;
  String? selectedSupervisor;
  String imageUrl = "";
  bool hidePassword = true;

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
      await FirebaseAuth.instance.currentUser?.updatePhotoURL(urlDownload);
      setState(() {
        imageUrl = urlDownload;
      });
    } catch (e) {
      throw Exception("Fail to upload to firebase storage");
    }
  }

  Stream<QuerySnapshot> getSupervisor() {
    return _firestore
        .collection('users')
        .where("role", isEqualTo: "supervisor")
        .snapshots();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registration"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text("Full name"),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Enter your name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onSaved: (value) => name = value!,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter your name";
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
                    hintText: "Enter your number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onSaved: (value) => phone = value!,
                  validator: (value) {
                    String pattern = r'^[+255|0]+[6|7]\d{8}$';
                    RegExp regExp = RegExp(pattern);
                    if (value!.isEmpty) {
                      return "Please enter your name";
                    } else if (!regExp.hasMatch(value)) {
                      return "Jaza namba ya simu sahihi";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                const Text("Email"),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onSaved: (value) => email = value!,
                  validator: (value) {
                    var pattern2 =
                        r'^[a-z]+([a-z0-9.-]+)?\@[a-z]+\.[a-z]{2,3}$';
                    RegExp regExp = RegExp(pattern2);
                    if (value!.isEmpty) {
                      return "Enter an email";
                    } else if (!regExp.hasMatch(value)) {
                      return "Enter valid email";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                const Text("Role"),
                const SizedBox(height: 8),
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text('Select role'),
                        value: role,
                        onChanged: (String? value) {
                          setState(() {
                            role = value;
                          });
                        },
                        items: [
                          "admin",
                          "supervisor",
                          "distributor",
                        ].map((role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                if (role?.toLowerCase() == "supervisor")
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Text("Zone"),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: "Enter your spervision zone",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onSaved: (value) => zone = value!,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter your name";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      const Text("Company code"),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: "Enter  code",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onSaved: (value) => code = value!,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter your name";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                if (role?.toLowerCase() == "distributor")
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Text("Zone"),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: "Enter your spervision zone",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onSaved: (value) => zone = value!,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter your name";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      const Text("Supervisor"),
                      const SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot>(
                        stream: getSupervisor(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }

                          List<QueryDocumentSnapshot> documents =
                              snapshot.data!.docs;

                          final supervisors = documents
                              .map((document) => document.data() as Map)
                              .toList();
                          return Container(
                            height: 56,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  hint: Text(selectedSupervisor ??
                                      'Select your supervisor'),
                                  onChanged: (String? value) {
                                    final selected = supervisors
                                        .where((element) =>
                                            element['name'] == value!)
                                        .first;

                                    setState(() {
                                      selectedSupervisor = value;
                                      supervisor = selected;
                                    });
                                  },
                                  items: supervisors.map((supr) {
                                    return DropdownMenuItem<String>(
                                      value: supr['name'],
                                      child: Text("${supr['name']}"),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text("Picha"),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () async {
                            ImagePicker picker = ImagePicker();
                            final pickedImage = await picker.pickImage(
                                source: ImageSource.camera);

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
                    ],
                  ),
                const SizedBox(height: 16),
                const Text("Password"),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Enter password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                      icon: Icon(
                        hidePassword
                            ? EvaIcons.eyeOffOutline
                            : EvaIcons.eyeOutline,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  onSaved: (value) => password = value!,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter your name";
                    }
                    return null;
                  },
                  obscureText: hidePassword,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                MaterialButton(
                  onPressed: () async {
                    SharedPreferences preferences =
                        await SharedPreferences.getInstance();
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      Map<String, dynamic> data = {
                        "name": name,
                        "email": email,
                        "phone": phone,
                        "role": role!,
                        "password": password,
                      };

                      if (role?.toLowerCase() == "supervisor") {
                        Map<String, dynamic> additional = {
                          "zone": zone,
                          "code": code
                        };
                        data.addAll(additional);
                      }
                      if (role?.toLowerCase() == "distributor") {
                        Map<String, dynamic> additional = {
                          "zone": zone,
                          "supervisor": supervisor,
                          "imageUrl": imageUrl,
                        };
                        data.addAll(additional);
                      }

                      // ignore: use_build_context_synchronously
                      final result = await showDialog(
                        context: context,
                        builder: (context) => FutureProgressDialog(
                          ref
                              .watch(authService)
                              .signUpWithEmailAndPassword(data),
                          message: const Text('Loading...'),
                        ),
                      );

                      if (result) {
                        preferences.setString("role", role!);
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const AuthWrapper()),
                            (route) => false);
                      }
                    }
                  },
                  height: 56,
                  color: Theme.of(context).colorScheme.primary,
                  minWidth: double.infinity,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Text(
                    "Register",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already hava an account"),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text("Login"))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
