import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    final userId = _supabase.auth.currentUser!.id;
    final data = await _supabase
        .from('bookings')
        .select('*, tours(name, location, image_url)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    setState(() {
      _bookings = List<Map<String, dynamic>>.from(data);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(child: Text('No bookings yet'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookings.length,
                  itemBuilder: (context, i) {
                    final b = _bookings[i];
                    final tour = b['tours'] as Map<String, dynamic>?;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            tour?['image_url'] ?? '',
                            width: 56, height: 56, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.tour, size: 40),
                          ),
                        ),
                        title: Text(tour?['name'] ?? 'Tour',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tour?['location'] ?? ''),
                            Text('Date: ${b['date']}  •  Seats: ${b['seats']}'),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(b['status'] ?? 'pending'),
                          backgroundColor: b['status'] == 'confirmed'
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}