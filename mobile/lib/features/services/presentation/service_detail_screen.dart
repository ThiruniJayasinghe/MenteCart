import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/services_bloc.dart';
import '../bloc/services_event.dart';
import '../bloc/services_state.dart';
import '../../cart/bloc/cart_bloc.dart';
import '../../cart/bloc/cart_event.dart';
import '../../cart/bloc/cart_state.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String serviceId;
  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  String? _selectedDate;
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    context
        .read<ServicesBloc>()
        .add(ServiceDetailRequested(widget.serviceId));
  }

  Map<String, List<String>> _groupSlots(List<dynamic> slots) {
    final grouped = <String, List<String>>{};
    for (final slot in slots) {
      final m = slot as Map<String, dynamic>;
      final date = m['date'] as String;
      final time = m['time'] as String;
      final capacity = (m['capacity'] as num).toInt();
      final booked = (m['booked'] as num).toInt();
      if (capacity - booked > 0) {
        grouped.putIfAbsent(date, () => []).add(time);
      }
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(), // ← triggers onBack in card
        ),
      ),
      body: BlocBuilder<ServicesBloc, ServicesState>(
        builder: (ctx, state) {
          if (state is ServicesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ServicesFailure) {
            return Center(child: Text(state.message));
          }
          if (state is ServiceDetailLoaded) {
            final service = state.service;
            final slots = service['slots'] as List? ?? [];
            final grouped = _groupSlots(slots);
            final dates = grouped.keys.toList()..sort();

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero image
                        Image.network(
                          service['image'] ?? '',
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 220,
                            color: const Color(0xFFEFF6FF),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service['title'] ?? '',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      size: 16,
                                      color: Color(0xFF64748B)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${service['duration']} min',
                                    style: const TextStyle(
                                        color: Color(0xFF64748B)),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Rs. ${service['price']}',
                                    style: const TextStyle(
                                      color: Color(0xFF2563EB),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                service['description'] ?? '',
                                style: const TextStyle(
                                  color: Color(0xFF475569),
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Select date',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (dates.isEmpty)
                                const Text(
                                  'No available slots',
                                  style: TextStyle(color: Colors.grey),
                                )
                              else
                                SizedBox(
                                  height: 40,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: dates.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 8),
                                    itemBuilder: (ctx, i) {
                                      final date = dates[i];
                                      final selected =
                                          _selectedDate == date;
                                      return ChoiceChip(
                                        label:
                                            Text(date.substring(5)),
                                        selected: selected,
                                        onSelected: (_) => setState(
                                            () {
                                          _selectedDate = date;
                                          _selectedTime = null;
                                        }),
                                      );
                                    },
                                  ),
                                ),
                              if (_selectedDate != null) ...[
                                const SizedBox(height: 20),
                                const Text(
                                  'Select time',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      (grouped[_selectedDate] ?? [])
                                          .map((time) => ChoiceChip(
                                                label: Text(time),
                                                selected:
                                                    _selectedTime ==
                                                        time,
                                                onSelected: (_) =>
                                                    setState(() =>
                                                        _selectedTime =
                                                            time),
                                              ))
                                          .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Add to cart button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        top: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: BlocConsumer<CartBloc, CartState>(
                    listener: (ctx, state) {
                      if (state is CartLoaded) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('Added to cart!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                      if (state is CartFailure) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (ctx, state) => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_selectedDate != null &&
                                _selectedTime != null &&
                                state is! CartLoading)
                            ? () {
                                context.read<CartBloc>().add(
                                      CartItemAdded(
                                        serviceId:
                                            service['_id'] as String,
                                        date: _selectedDate!,
                                        time: _selectedTime!,
                                        quantity: 1,
                                      ),
                                    );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: state is CartLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Add to cart',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}