import 'package:flutter/material.dart';

void main() {
  runApp(const CancerSupportApp());
}

class CancerSupportApp extends StatelessWidget {
  const CancerSupportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cancer Support Community',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const RoleSelectionScreen(),
    );
  }
}

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? selectedRole;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool rememberMe = false;
  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // Logo and welcome message
              Column(
                children: [
                  Image.asset(
                    'assets/community_logo.png', // Replace with your actual logo
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Cancer Support Community',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please select your role and sign in',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              // Role selection
              const Text(
                'I am a:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              
              // Doctor and Caregiver selection buttons
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Doctor'),
                      selected: selectedRole == 'doctor',
                      onSelected: (selected) {
                        setState(() {
                          selectedRole = selected ? 'doctor' : null;
                        });
                      },
                      selectedColor: Colors.blue[200],
                      avatar: const Icon(Icons.medical_services),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Caregiver'),
                      selected: selectedRole == 'caregiver',
                      onSelected: (selected) {
                        setState(() {
                          selectedRole = selected ? 'caregiver' : null;
                        });
                      },
                      selectedColor: Colors.green[200],
                      avatar: const Icon(Icons.people),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              
              // Email field
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              
              // Password field
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                obscureText: obscurePassword,
              ),
              const SizedBox(height: 10),
              
              // Remember me and forgot password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value!;
                          });
                        },
                      ),
                      const Text('Remember me'),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // Forgot password action
                    },
                    child: const Text('Forgot password?'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              
              // Sign in button
              ElevatedButton(
                onPressed: selectedRole == null || isLoading
                    ? null
                    : () {
                        // Handle login
                        setState(() {
                          isLoading = true;
                        });
                        // Simulate login process
                        Future.delayed(const Duration(seconds: 2), () {
                          setState(() {
                            isLoading = false;
                          });
                          // Navigate to appropriate dashboard
                          if (selectedRole == 'doctor') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DoctorDashboard(),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CaregiverDashboard(),
                              ),
                            );
                          }
                        });
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                    : const Text(
                        'SIGN IN',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 20),
              
              // Sign up prompt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      // Navigate to sign up screen
                    },
                    child: const Text('Sign up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder screens for navigation
class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Dashboard')),
      body: const Center(child: Text('Doctor Dashboard Content')),
    );
  }
}

class CaregiverDashboard extends StatelessWidget {
  const CaregiverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caregiver Dashboard')),
      body: const Center(child: Text('Caregiver Dashboard Content')),
    );
  }
}