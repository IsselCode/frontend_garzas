import 'package:flutter/material.dart';
import 'package:frontend_garzas/core/app/consts.dart';
import 'package:frontend_garzas/core/services/navigation_service.dart';
import 'package:frontend_garzas/inject_container.dart';
import 'package:frontend_garzas/src/admin/clean/enums/enums.dart';
import 'package:frontend_garzas/src/admin/navigation/admin_navigation.dart';
import 'package:frontend_garzas/src/auth/controllers/auth_controller.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';

import 'app_top_bar.dart';
import 'session_actions.dart';

class AppWindowLayout extends StatefulWidget {
  const AppWindowLayout({super.key, required this.child});

  final Widget child;

  @override
  State<AppWindowLayout> createState() => _AppWindowLayoutState();
}

class _AppWindowLayoutState extends State<AppWindowLayout> {
  bool _sidebarOpen = true;

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.select<AuthController, bool>(
      (auth) => auth.role == AppRole.admin,
    );
    final navigation = locator<NavigationService>();
    final theme = Theme.of(context);
    final adminTheme = theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        titleLarge: theme.textTheme.titleLarge?.copyWith(fontSize: 25),
        titleMedium: theme.textTheme.titleMedium?.copyWith(fontSize: 20),
        titleSmall: theme.textTheme.titleSmall?.copyWith(fontSize: 18),
        bodyLarge: theme.textTheme.bodyLarge?.copyWith(fontSize: 17),
        bodyMedium: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
        bodySmall: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
        labelLarge: theme.textTheme.labelLarge?.copyWith(fontSize: 13),
        labelMedium: theme.textTheme.labelMedium?.copyWith(fontSize: 12),
        labelSmall: theme.textTheme.labelSmall?.copyWith(fontSize: 11),
      ),
    );
    return Overlay.wrap(
      child: ValueListenableBuilder<AppNavigationState>(
        valueListenable: navigation.state,
        child: widget.child,
        builder: (context, state, child) {
          final showAdminLayout = isAdmin && state.current != null;
          return Theme(
            data: showAdminLayout ? adminTheme : theme,
            child: IsselDesktopScaffold(
              config: const IsselDesktopConfig(sidebarWidth: 250),
              edgeToEdge: !showAdminLayout,
              sidebarOpen: showAdminLayout && _sidebarOpen,
              onSidebarClose: () => setState(() => _sidebarOpen = false),
              caption: AppTopBar(
                actionsEnabled: !state.hasModal,
                section: showAdminLayout ? state.current : null,
                canGoBack: showAdminLayout && state.canGoBack,
                onMenuPressed: showAdminLayout && !_sidebarOpen
                    ? () => setState(() => _sidebarOpen = true)
                    : null,
                backgroundColor: Colors.transparent,
                onPrimaryBackground: !showAdminLayout && state.captionOnPrimary,
              ),
              sidebar: !showAdminLayout
                  ? null
                  : IgnorePointer(
                      ignoring: state.hasModal,
                      child: Theme(
                        data: adminTheme.copyWith(
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              fixedSize: const Size.fromHeight(40),
                              visualDensity: VisualDensity.standard,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ),
                        child: IsselNavigationPane(
                          width: 250,
                          selectedId: state.current?.sectionId,
                          items: adminDestinations
                              .map((destination) => destination.item)
                              .toList(),
                          header: Stack(
                            children: [
                              Center(
                                child: Image.asset(
                                  AppAssets.drawerIcon,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              if (MediaQuery.sizeOf(context).width < 900)
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IsselCaptionButton(
                                    tooltip: 'Ocultar menú',
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed: () =>
                                        setState(() => _sidebarOpen = false),
                                  ),
                                ),
                            ],
                          ),
                          footer: IsselButton(
                            text: 'Cerrar sesión',
                            height: 40,
                            color: theme.colorScheme.error,
                            textColor: theme.colorScheme.onError,
                            onTap: () {
                              final dialogContext =
                                  navigation.navigatorKey.currentContext;
                              if (dialogContext == null) return;
                              requestLogout(dialogContext);
                            },
                          ),
                          onSelected: (id) {
                            if (id != state.current?.sectionId ||
                                state.canGoBack) {
                              navigation.pushAndRemoveUntil(
                                adminDestinations
                                    .firstWhere(
                                      (destination) => destination.id == id,
                                    )
                                    .page,
                              );
                            }
                            if (MediaQuery.sizeOf(context).width < 900) {
                              setState(() => _sidebarOpen = false);
                            }
                          },
                        ),
                      ),
                    ),
              child: child!,
            ),
          );
        },
      ),
    );
  }
}
