import 'package:connect_pharma/widgets/FadeInSlide.dart';

class PharmacistRequestsScreen extends StatefulWidget {
  // ... existing code ...

  Widget _buildIncomingRequests() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
            return FadeInSlide(
              index: index,
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(data['medicineName'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text('Status: ${data['status']}'),
                      if (data['prescriptionUrl'] != null)
                        const Text('Prescription attached', style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => _acceptRequest(doc.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _cancelRequest(doc.id),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMyJobs() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: RequestService.streamRequestsAcceptedByPharmacist(currentPharmacistId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('You haven\'t accepted any requests yet'));
        }

        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            return FadeInSlide(
              index: index,
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                color: Colors.green.shade50,
                child: ListTile(
                  title: Text(data['medicineName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text('Status: ${data['status']}'),
                      const SizedBox(height: 4),
                      const Text('Click chat to talk to user', style: TextStyle(fontStyle: FontStyle.italic)),
                    ],
                  ),
                  trailing: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: doc.id,
                            title: 'Chat with User',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Chat'),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _acceptRequest(String requestId) async {
    try {
      await RequestService.acceptRequest(requestId, currentPharmacistId);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request accepted')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _cancelRequest(String requestId) async {
    try {
      await RequestService.cancelRequest(requestId);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request cancelled')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
