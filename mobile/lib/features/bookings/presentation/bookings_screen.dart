// bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(BookingsFetchRequested());
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.hourglass_empty;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My bookings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/services'),
        ),
      ),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (ctx, state) {
          if (state is BookingLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BookingFailure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(state.message, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<BookingBloc>().add(BookingsFetchRequested()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is BookingsLoaded) {
            if (state.bookings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No bookings yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.go('/services'),
                      child: const Text('Browse services'),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final b = state.bookings[i] as Map<String, dynamic>;
                final items = (b['items'] as List?) ?? [];
                final status = b['status'] as String;

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Booking #${(b['_id'] as String).substring(b['_id'].toString().length - 6)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor(status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _statusIcon(status),
                                    size: 12,
                                    color: _statusColor(status),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      color: _statusColor(status),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...items.take(2).map((item) {
                          final m = item as Map<String, dynamic>;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              '• ${m['title']} — ${m['date']} at ${m['time']}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF475569),
                              ),
                            ),
                          );
                        }),
                        if (items.length > 2)
                          Text(
                            '+ ${items.length - 2} more',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rs. ${b['totalAmount']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            if (status == 'confirmed' || status == 'pending')
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Cancel booking'),
                                    content: const Text(
                                      'Are you sure you want to cancel this booking?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          context.read<BookingBloc>().add(
                                                BookingCancelRequested(
                                                    b['_id'] as String),
                                              );
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('Yes, cancel'),
                                      ),
                                    ],
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}