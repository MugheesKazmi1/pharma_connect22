import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _go(BuildContext context, String role) {
    Navigator.pushNamed(context, '/signup', arguments: role);
  }

  Widget _roleButton(BuildContext context, String label) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        onPressed: () => _go(context, label),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.medical_services, size: 88, color: Colors.blue),
              const SizedBox(height: 12),
              const Text(
                'CONNECT-PHARMA',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Find Your Medicine Fast and Easy',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              const Align(
                  alignment: Alignment.centerLeft,
                  child:
                      Text('Login As :', style: TextStyle(fontSize: 16))),
              const SizedBox(height: 12),
              _roleButton(context, 'User'),
              const SizedBox(height: 12),
              _roleButton(context, 'Pharmacist'),
              const SizedBox(height: 12),
              _roleButton(context, 'Driver'),
            ],
          ),
        ),
      ),
    );
  }
}