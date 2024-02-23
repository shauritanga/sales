import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:sales/Providers/auth.dart';
import 'package:sales/auth_wrapper.dart';
import 'package:sales/screens/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String email = "";
  String password = "";
  bool hidePassword = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome back",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              const Text("Please login to continue"),
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
                  var pattern2 = r'^[a-z]+([a-z0-9.-]+)?\@[a-z]+\.[a-z]{2,3}$';
                  RegExp regExp = RegExp(pattern2);
                  if (value!.isEmpty) {
                    return "Please enter your name";
                  } else if (!regExp.hasMatch(value.trim())) {
                    return "Tafadhali jaza majina halisi";
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
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
                obscureText: hidePassword,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter your name";
                  }
                  return null;
                },
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),
              MaterialButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState?.save();

                    final result = await showDialog(
                      context: context,
                      builder: (context) => FutureProgressDialog(
                        ref
                            .watch(authService)
                            .signInWithEmailAndPassword(email, password),
                        message: const Text('Loading...'),
                      ),
                    );

                    if (result) {
                      SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      final document = await FirebaseFirestore.instance
                          .collection("users")
                          .where("email",
                              isEqualTo:
                                  FirebaseAuth.instance.currentUser?.email)
                          .get();

                      if (document.docs.isEmpty) {
                        return;
                      }
                      await preferences.setString(
                          "role", document.docs.first.data()['role']);

                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const AuthWrapper(),
                          ),
                          (route) => false);
                    }
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Inavilid email or password")));
                  }
                },
                height: 56,
                color: Theme.of(context).colorScheme.primary,
                minWidth: double.infinity,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't hava an account"),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text("Register"),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
