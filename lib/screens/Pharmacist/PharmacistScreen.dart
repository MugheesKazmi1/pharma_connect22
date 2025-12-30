import 'package:flutter/material.dart';
import 'package:connect_pharma/screens/Pharmacist/PharmacistRequestsScreen.dart';

class PharmacistScreen extends StatelessWidget {
	const PharmacistScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Pharmacist')),
			body: Padding(
				padding: const EdgeInsets.all(16.0),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						const Text(
							'Welcome, Pharmacist',
							style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
						),
						const SizedBox(height: 12),
						ElevatedButton(
							onPressed: () {
								Navigator.push(
									context,
									MaterialPageRoute(builder: (_) => const PharmacistRequestsScreen()),
								);
							},
							child: const Padding(
								padding: EdgeInsets.symmetric(vertical: 14.0),
								child: Text('View Medicine Requests'),
							),
						),
					],
				),
			),
		);
	}
}

