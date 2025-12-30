import 'package:flutter/material.dart';

class PharmacistRequestsScreen extends StatelessWidget {
  const PharmacistRequestsScreen({super.key});

  // Dummy data for medicine requests
  List<Map<String, dynamic>> get _dummyRequests => const [
        {
          'medicine': 'Paracetamol 500mg',
          'quantity': 20,
          'requester': 'John Doe',
          'date': '2025-12-01',
          'status': 'Pending'
        },
        {
          'medicine': 'Amoxicillin 250mg',
          'quantity': 10,
          'requester': 'Clinic A',
          'date': '2025-12-02',
          'status': 'Pending'
        },
        {
          'medicine': 'Cetirizine 10mg',
          'quantity': 15,
          'requester': 'Jane Smith',
          'date': '2025-12-03',
          'status': 'Approved'
        },
      ];

  @override
  Widget build(BuildContext context) {
    final requests = _dummyRequests;
    return Scaffold(
      appBar: AppBar(title: const Text('Pharmacist - Requests')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: requests.isEmpty
            ? const Center(child: Text('No requests'))
            : ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, i) {
                  final r = requests[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(r['medicine'] as String),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text('Quantity: ${r['quantity']}'),
                          Text('Requested by: ${r['requester']}'),
                          Text('Date: ${r['date']}'),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            r['status'] as String,
                            style: TextStyle(
                              color: (r['status'] == 'Approved') ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
