import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List bookings = [];
  bool isLoading = true;

  static const String baseUrl =
      'https://interior-app-backend-1.onrender.com/api';

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        if (!mounted) return;

        setState(() {
          bookings = [];
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/bookings'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        setState(() {
          bookings = decodedData is List ? decodedData : [];
        });
      } else {
        debugPrint(
          'Failed to fetch bookings: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> deleteBooking(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        return;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/bookings/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking deleted successfully')),
        );

        setState(() {
          bookings.removeWhere((booking) => booking['_id']?.toString() == id);
        });
      } else {
        debugPrint(
          'Failed to delete booking: ${response.statusCode} ${response.body}',
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete booking')),
        );
      }
    } catch (e) {
      debugPrint('Error deleting booking: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to connect to the server')),
      );
    }
  }

  Future<void> confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Delete this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await deleteBooking(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
          ? const Center(child: Text('No bookings found'))
          : RefreshIndicator(
              onRefresh: fetchBookings,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final b = bookings[index];
                  final designer = b['designer'] is Map
                      ? b['designer'] as Map
                      : {};

                  final imageUrl = designer['image']?.toString() ?? '';
                  final bookingId = b['_id']?.toString() ?? '';

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: Icon(Icons.image),
                                  );
                                },
                              )
                            : const SizedBox(
                                width: 60,
                                height: 60,
                                child: Icon(Icons.image),
                              ),
                      ),
                      title: Text(
                        designer['name']?.toString() ?? 'No Name',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(designer['specialty']?.toString() ?? ''),
                          const SizedBox(height: 4),
                          Text('📅 ${b['date'] ?? ''}'),
                          Text('⏰ ${b['time'] ?? ''}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: bookingId.isEmpty
                            ? null
                            : () => confirmDelete(bookingId),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
