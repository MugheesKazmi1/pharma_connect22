import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_pharma/services/request_service.dart';

class PharmacistRequestsScreen extends StatefulWidget {
  const PharmacistRequestsScreen({super.key});

  @override
  State<PharmacistRequestsScreen> createState() => _PharmacistRequestsScreenState();
}

class _PharmacistRequestsScreenState extends State<PharmacistRequestsScreen> {
  // TODO: Replace with logged-in pharmacist ID dynamically
  final String pharmacistId = 'pharmacy_001';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incoming Requests')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // Listen to broadcast requests only (status=open)
        stream: RequestService.streamOpenBroadcastRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No open requests'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(data['medicineName'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text('Status: ${data['status']}'),
                      if (data['prescriptionUrl'] != null)
                        const Text('Prescription attached'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ACCEPT BUTTON
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () async {
                          try {
                            await RequestService.acceptRequest(doc.id, pharmacistId);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Request accepted')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().contains('already accepted')
                                        ? 'Request already accepted by another pharmacy'
                                        : 'Error: $e',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      // REJECT BUTTON
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () async {
                          try {
                            await RequestService.cancelRequest(doc.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Request cancelled')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
