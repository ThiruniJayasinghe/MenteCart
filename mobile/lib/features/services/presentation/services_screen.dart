import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../bloc/services_bloc.dart';
import '../bloc/services_event.dart';
import '../bloc/services_state.dart';
import '../../cart/bloc/cart_bloc.dart';
import '../../cart/bloc/cart_state.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../../core/theme/theme_cubit.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String? _selectedCategory;
  final _searchCtrl = TextEditingController();

  final List<Map<String, String>> _categories = [
    {'label': 'All', 'value': ''},
    {'label': 'Cleaning', 'value': 'cleaning'},
    {'label': 'Plumbing', 'value': 'plumbing'},
    {'label': 'Tutoring', 'value': 'tutoring'},
    {'label': 'Beauty', 'value': 'beauty'},
    {'label': 'Appliance', 'value': 'appliance'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _fetchServices() {
    context.read<ServicesBloc>().add(ServicesFetchRequested(
          category:
              (_selectedCategory?.isEmpty == true || _selectedCategory == null)
                  ? null
                  : _selectedCategory,
          search: _searchCtrl.text.trim().isEmpty
              ? null
              : _searchCtrl.text.trim(),
        ));
  }

  void _applyFilter(String? category) {
    setState(() => _selectedCategory = category);
    context.read<ServicesBloc>().add(ServicesFetchRequested(
          category: category?.isEmpty == true ? null : category,
          search: _searchCtrl.text.trim().isEmpty
              ? null
              : _searchCtrl.text.trim(),
        ));
  }

  void _openProfileMenu(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final themeCubit = context.read<ThemeCubit>();
    final isDark = themeCubit.isDark;

    String userName = 'User';
    String userEmail = '';

    if (authState is AuthAuthenticated) {
      userName = authState.user['name'] ?? 'User';
      userEmail = authState.user['email'] ?? '';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProfileBottomSheet(
        userName: userName,
        userEmail: userEmail,
        isDark: isDark,
        onToggleTheme: () {
          themeCubit.toggle();
          Navigator.pop(context);
        },
        onBookings: () {
          Navigator.pop(context);
          context.push('/bookings');
        },
        onLogout: () {
          Navigator.pop(context);
          context.read<AuthBloc>().add(AuthLogoutRequested());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/images/logo.svg',
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 10),
            const Text(
              'MenteCart',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // 
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (ctx, state) {
              final count = state is CartLoaded ? state.itemCount : 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => context.push('/cart'),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => _openProfileMenu(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _applyFilter(_selectedCategory);
                        },
                      )
                    : null,
              ),
              onSubmitted: (v) => _applyFilter(_selectedCategory),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final cat = _categories[i];
                final selected = (_selectedCategory ?? '') == cat['value'];
                return FilterChip(
                  label: Text(cat['label']!),
                  selected: selected,
                  onSelected: (_) => _applyFilter(cat['value']),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<ServicesBloc, ServicesState>(
              builder: (ctx, state) {
                if (state is ServicesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ServicesFailure) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(state.message),
                        TextButton(
                          onPressed: _fetchServices,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                if (state is ServicesLoaded) {
                  if (state.services.isEmpty) {
                    return const Center(child: Text('No services found'));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: state.services.length,
                    itemBuilder: (ctx, i) => _ServiceCard(
                      service: state.services[i] as Map<String, dynamic>,
                      onBack: _fetchServices,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBottomSheet extends StatelessWidget {
  final String userName;
  final String userEmail;
  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback onBookings;
  final VoidCallback onLogout;

  const _ProfileBottomSheet({
    required this.userName,
    required this.userEmail,
    required this.isDark,
    required this.onToggleTheme,
    required this.onBookings,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF2563EB),
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Sri Lanka',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: Colors.amber.shade700,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Appearance',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      isDark ? 'Dark' : 'Light',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade500),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: isDark,
                      onChanged: (_) => onToggleTheme(),
                      activeColor: const Color(0xFF2563EB),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _MenuItem(
            icon: Icons.calendar_today_outlined,
            iconColor: const Color(0xFF2563EB),
            iconBg: const Color(0xFF2563EB),
            label: 'My bookings',
            onTap: onBookings,
          ),
          const Divider(indent: 20, endIndent: 20),
          _MenuItem(
            icon: Icons.logout,
            iconColor: Colors.red,
            iconBg: Colors.red,
            label: 'Log out',
            labelColor: Colors.red,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final Color? labelColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final VoidCallback onBack;

  const _ServiceCard({required this.service, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await context.push('/services/${service['_id']}');
        onBack();
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Image.network(
                service['image'] ?? '',
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFEFF6FF),
                  child: const Center(
                    child: Icon(Icons.image_not_supported_outlined,
                        color: Colors.grey),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        service['category'] ?? '',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        service['title'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rs. ${service['price']}',
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}