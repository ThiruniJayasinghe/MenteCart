import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/auth/presentation/splash_screen.dart';          
import 'features/services/bloc/services_bloc.dart';
import 'features/services/data/service_repository.dart';
import 'features/services/presentation/services_screen.dart';
import 'features/services/presentation/service_detail_screen.dart';
import 'features/cart/bloc/cart_bloc.dart';
import 'features/cart/data/cart_repository.dart';
import 'features/cart/presentation/cart_screen.dart';
import 'features/bookings/bloc/booking_bloc.dart';
import 'features/bookings/data/booking_repository.dart';
import 'features/bookings/presentation/bookings_screen.dart';
import 'features/bookings/presentation/checkout_screen.dart';

class App extends StatelessWidget {
  App({super.key});

  final _themeCubit = ThemeCubit();
  late final _authBloc = AuthBloc(AuthRepository(apiClient));

  late final _router = GoRouter(
    // ← start on splash; it listens to AuthBloc and redirects automatically
    initialLocation: '/splash',
    refreshListenable: _GoRouterRefreshStream(_authBloc.stream),
    redirect: (context, state) {
      final authState = _authBloc.state;
      final loc = state.matchedLocation;

      // Let splash handle itself
      if (loc == '/splash') return null;

      final isAuth = authState is AuthAuthenticated;
      final isOnAuth = loc == '/login' || loc == '/signup';

      if (!isAuth && !isOnAuth) return '/login';
      if (isAuth && isOnAuth) return '/services';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),   
      GoRoute(path: '/login',  builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(path: '/services', builder: (_, __) => const ServicesScreen()),
      GoRoute(
        path: '/services/:id',
        builder: (_, state) =>
            ServiceDetailScreen(serviceId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/cart',     builder: (_, __) => const CartScreen()),
      GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
      GoRoute(path: '/bookings', builder: (_, __) => const BookingsScreen()),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _themeCubit),
        BlocProvider.value(value: _authBloc..add(AuthCheckRequested())),
        BlocProvider(create: (_) => ServicesBloc(ServiceRepository(apiClient))),
        BlocProvider(create: (_) => CartBloc(CartRepository(apiClient))),
        BlocProvider(create: (_) => BookingBloc(BookingRepository(apiClient))),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'MenteCart',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) => notifyListeners());
  }
}