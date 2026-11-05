import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/core.dart';
import 'features/dashboard_page.dart';
import 'features/explore_page.dart';
import 'features/idea_details_page.dart';
import 'features/landing_page.dart';
import 'features/profile_page.dart';
import 'features/saved_page.dart';
import 'features/submit_idea_page.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});
  final String location;
  final Widget child;

  int get _index {
    final i = navItems.indexWhere((n) => location.startsWith(n.path));
    return i < 0 ? 1 : i;
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      return Scaffold(body: Row(children: [CustomSidebar(selected: _index), Expanded(child: child)]));
    }
    return Scaffold(
      appBar: AppBar(backgroundColor: C.surface, title: const Logo(), automaticallyImplyLeading: false),
      body: child,
      bottomNavigationBar: NavigationBar(
        backgroundColor: C.surface,
        selectedIndex: _index,
        onDestinationSelected: (i) => context.go(navItems[i].path),
        destinations: [
          for (final n in navItems) NavigationDestination(icon: Icon(n.icon), label: n.label),
        ],
      ),
    );
  }
}

Page<void> _t(GoRouterState s, Widget w) => CustomTransitionPage<void>(
      key: s.pageKey,
      child: w,
      transitionsBuilder: (c, a, sa, child) => FadeTransition(
        opacity: a,
        child: SlideTransition(
            position: Tween(begin: const Offset(0, .03), end: Offset.zero).animate(a), child: child),
      ),
    );

GoRouter buildRouter() => GoRouter(
      routes: [
        GoRoute(path: '/', pageBuilder: (c, s) => _t(s, const LandingPage())),
        ShellRoute(
          builder: (c, s, child) => AppShell(location: s.uri.path, child: child),
          routes: [
            GoRoute(path: '/dashboard', pageBuilder: (c, s) => _t(s, const DashboardPage())),
            GoRoute(path: '/explore', pageBuilder: (c, s) => _t(s, const ExplorePage())),
            GoRoute(path: '/submit', pageBuilder: (c, s) => _t(s, const SubmitIdeaPage())),
            GoRoute(path: '/saved', pageBuilder: (c, s) => _t(s, const SavedIdeasPage())),
            GoRoute(path: '/profile', pageBuilder: (c, s) => _t(s, const ProfilePage())),
            GoRoute(
                path: '/idea/:id',
                pageBuilder: (c, s) => _t(s, IdeaDetailsPage(id: s.pathParameters['id']!))),
          ],
        ),
      ],
      errorBuilder: (c, s) => Scaffold(
        body: EmptyStateWidget(
          icon: Icons.explore_off_rounded,
          title: 'Page not found',
          message: 'That page does not exist.',
          action: GradientButton(label: 'Go home', onPressed: () => c.go('/')),
        ),
      ),
    );

class IdeaVaultApp extends StatefulWidget {
  const IdeaVaultApp({super.key, required this.provider});
  final IdeaProvider provider;
  @override
  State<IdeaVaultApp> createState() => _IdeaVaultAppState();
}

class _IdeaVaultAppState extends State<IdeaVaultApp> {
  final _router = buildRouter();
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
        value: widget.provider,
        child: MaterialApp.router(
          title: 'Student Innovation Idea Vault',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(),
          routerConfig: _router,
        ),
      );
}
