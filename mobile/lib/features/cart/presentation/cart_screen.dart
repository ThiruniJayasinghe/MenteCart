import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(CartFetchRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My cart')),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (ctx, state) {
          if (state is CartLoading) return const Center(child: CircularProgressIndicator());
          if (state is CartFailure) return Center(child: Text(state.message));
          if (state is CartLoaded) {
            if (state.items.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Your cart is empty', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ],
                ),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final item = state.items[i] as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          title: Text(item['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('${item['date']} at ${item['time']}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                              Text('Qty: ${item['quantity']} × Rs. ${item['price']}', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Rs. ${(item['price'] as num) * (item['quantity'] as int)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => context.read<CartBloc>().add(CartItemRemoved(item['_id'] as String)),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          Text('Rs. ${state.total.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.push('/checkout'),
                        child: const Text('Proceed to checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ],
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