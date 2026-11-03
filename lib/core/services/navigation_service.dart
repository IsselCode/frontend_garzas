import 'package:flutter/material.dart';

class AppRouteInfo {
  const AppRouteInfo({required this.sectionId, required this.title});

  final String sectionId;
  final String title;
}

class AppNavigationState {
  const AppNavigationState({
    this.pages = const [],
    this.hasModal = false,
    this.captionOnPrimary = false,
  });

  final List<AppRouteInfo?> pages;
  final bool hasModal;
  final bool captionOnPrimary;
  AppRouteInfo? get current => pages.isEmpty ? null : pages.last;
  bool get canGoBack => pages.length > 1;
}

class NavigationService {
  NavigationService({
    this.routes = const {},
    this.captionOnPrimaryRoutes = const {},
  }) {
    observer = _AppNavigationObserver(state);
  }

  final Map<Type, AppRouteInfo> routes;

  /// Pages whose top-right caption actions sit over a primary-colored panel.
  final Set<Type> captionOnPrimaryRoutes;
  final state = ValueNotifier(const AppNavigationState());
  late final NavigatorObserver observer;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<T?> navigateTo<T>(Widget route) {
    return navigatorKey.currentState?.push<T>(_instantPageRoute<T>(route)) ??
        Future.value(null);
  }

  void pushReplacement(Widget route) {
    navigatorKey.currentState?.pushReplacement(_instantPageRoute(route));
  }

  void pushAndRemoveUntil(Widget route) {
    navigatorKey.currentState?.pushAndRemoveUntil(
      _instantPageRoute(route),
      (route) => false,
    );
  }

  void popUntilWidget(Type widgetType) {
    navigatorKey.currentState?.popUntil(
      (route) => route.settings.name == widgetType.toString(),
    );
  }

  void goBack() {
    navigatorKey.currentState?.pop();
  }

  RouteSettings _settings(Widget route) => _AppRouteSettings(
    name: route.runtimeType.toString(),
    arguments: routes[route.runtimeType],
    captionOnPrimary: captionOnPrimaryRoutes.contains(route.runtimeType),
  );

  // Same route presentation as PPG: a section appears immediately, without
  // animating the outgoing page behind the incoming page.
  PageRoute<T> _instantPageRoute<T>(Widget route) => PageRouteBuilder<T>(
    settings: _settings(route),
    pageBuilder: (context, animation, secondaryAnimation) => route,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        child,
  );
}

class _AppRouteSettings extends RouteSettings {
  const _AppRouteSettings({
    super.name,
    super.arguments,
    required this.captionOnPrimary,
  });

  final bool captionOnPrimary;
}

// Dialogs never change the selected section. Publish after the frame so route
// changes cannot notify widgets while Navigator is building them.
class _AppNavigationObserver extends NavigatorObserver {
  _AppNavigationObserver(this.state);

  final ValueNotifier<AppNavigationState> state;
  final List<Route<dynamic>> _pages = [];
  final Set<Route<dynamic>> _modals = {};
  bool _scheduled = false;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute) _pages.add(route);
    if (route is PopupRoute) _modals.add(route);
    _publish();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _pages.remove(route);
    _modals.remove(route);
    _publish();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _pages.remove(route);
    _modals.remove(route);
    _publish();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = oldRoute == null ? -1 : _pages.indexOf(oldRoute);
    _modals.remove(oldRoute);
    if (newRoute is PopupRoute) _modals.add(newRoute);
    if (index >= 0) {
      if (newRoute is PageRoute) {
        _pages[index] = newRoute;
      } else {
        _pages.removeAt(index);
      }
    }
    _publish();
  }

  void _publish() {
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      final settings = _pages.isEmpty ? null : _pages.last.settings;
      state.value = AppNavigationState(
        hasModal: _modals.isNotEmpty,
        captionOnPrimary:
            settings is _AppRouteSettings && settings.captionOnPrimary,
        pages: _pages
            .map((page) {
              final info = page.settings.arguments;
              return info is AppRouteInfo ? info : null;
            })
            .toList(growable: false),
      );
    });
  }
}
