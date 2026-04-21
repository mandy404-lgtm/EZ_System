import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onLogin;

  const AuthScreen({super.key, required this.onLogin});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isSignUp = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final businessController = TextEditingController();
  final regionController = TextEditingController();

  void handleAuth() {
    if (isSignUp) {
      // 🔥 REGISTER (LOCAL ONLY)
      if (nameController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all required fields")),
        );
        return;
      }

      debugPrint("REGISTER:");
      debugPrint("Name: ${nameController.text}");
      debugPrint("Email: ${emailController.text}");
      debugPrint("Business: ${businessController.text}");
      debugPrint("Region: ${regionController.text}");
    } else {
      // 🔥 LOGIN (LOCAL ONLY)
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter email and password")),
        );
        return;
      }

      debugPrint("LOGIN:");
      debugPrint("Email: ${emailController.text}");
    }

    // simulate success login/register
    widget.onLogin();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    businessController.dispose();
    regionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.business_center,
                    size: 80, color: Colors.green),

                const SizedBox(height: 10),

                const Text(
                  "EZ SYSTEM",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),

                const Text(
                  "AI-powered Business Intelligence",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      // TOGGLE
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => setState(() => isSignUp = false),
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: !isSignUp ? Colors.green : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () => setState(() => isSignUp = true),
                              child: Text(
                                "Register",
                                style: TextStyle(
                                  color: isSignUp ? Colors.green : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // NAME
                      if (isSignUp) ...[
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: "Full Name",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // EMAIL
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // PASSWORD
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      // REGISTER FIELDS
                      if (isSignUp) ...[
                        const SizedBox(height: 10),
                        TextField(
                          controller: businessController,
                          decoration: const InputDecoration(
                            labelText: "Business Name",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: regionController,
                          decoration: const InputDecoration(
                            labelText: "Region",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: handleAuth,
                          child: Text(
                            isSignUp ? "Create Account" : "Login",
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
