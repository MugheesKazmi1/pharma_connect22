import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    final role = arg is String ? arg : authService.currentUser == null ? 'Unknown' : 'User';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
            },
          )
        ],
      ),
      body: Center(
        child: Text('Welcome, role: $role', style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}