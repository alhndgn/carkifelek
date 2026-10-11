import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/wheel_editor_screen.dart';
import 'screens/wheel_list_screen.dart';
import 'screens/wheel_screen.dart';

/// Uygulama rotaları. Tek kaynak: `/` çarklar, `/wheel/:id` çark detayı,
/// `/wheel/:id/edit` seçenek düzenleme.
final Provider<GoRouter> routerProvider = Provider<GoRouter>(
  (Ref ref) => GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'wheels',
        builder: (BuildContext context, GoRouterState state) =>
            const WheelListScreen(),
      ),
      GoRoute(
        path: '/wheel/:id',
        name: 'wheel',
        builder: (BuildContext context, GoRouterState state) =>
            WheelScreen(wheelId: state.pathParameters['id'] ?? ''),
        routes: <RouteBase>[
          GoRoute(
            path: 'edit', // /wheel/:id/edit
            name: 'wheelEdit',
            builder: (BuildContext context, GoRouterState state) =>
                WheelEditorScreen(wheelId: state.pathParameters['id'] ?? ''),
          ),
        ],
      ),
    ],
  ),
);
