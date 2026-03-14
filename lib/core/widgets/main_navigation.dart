import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/notifications/providers/notification_provider.dart';

class MainNavigation extends StatefulWidget {
  final Widget child;
  
  const MainNavigation({super.key, required this.child});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/activity')) return 1;
    if (location.startsWith('/stats')) return 2;
    if (location.startsWith('/notifications')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/activity');
        break;
      case 2:
        context.go('/stats');
        break;
      case 3:
        context.go('/notifications');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    final bool showChatFab = !location.startsWith('/chat');
    final bool showJournalFab = !location.startsWith('/journal');
    final bool showFabStack = showChatFab || showJournalFab;

    return Scaffold(
      body: widget.child,
      floatingActionButton: showFabStack
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (showJournalFab)
                  FloatingActionButton(
                    heroTag: 'journalFab',
                    onPressed: () => context.push('/journal'),
                    tooltip: 'Journal',
                    child: const Icon(Icons.book_outlined),
                  ),
                if (showChatFab && showJournalFab)
                  const SizedBox(height: 12),
                if (showChatFab)
                  FloatingActionButton(
                    heroTag: 'chatFab',
                    onPressed: () => context.push('/chat'),
                    tooltip: 'Chat',
                    child: const Icon(Icons.chat_bubble_outline),
                  ),
              ],
            )
          : null,
      floatingActionButtonLocation:
          showFabStack ? FloatingActionButtonLocation.endFloat : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Activities',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Consumer<NotificationProvider>(
              builder: (context, provider, _) {
                final unreadCount = provider.unreadCount;
                return Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text(unreadCount > 9 ? '9+' : unreadCount.toString()),
                  child: const Icon(Icons.notifications_outlined),
                );
              },
            ),
            activeIcon: Consumer<NotificationProvider>(
              builder: (context, provider, _) {
                final unreadCount = provider.unreadCount;
                return Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text(unreadCount > 9 ? '9+' : unreadCount.toString()),
                  child: const Icon(Icons.notifications),
                );
              },
            ),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
