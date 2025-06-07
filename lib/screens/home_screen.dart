import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'donations_screen.dart';
import 'coverages_screen.dart';
import 'user_profile_screen.dart';
import 'contact_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const DonationsScreen(),
    const CoveragesScreen(),
    const UserProfileScreen(),
    const ContactScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Donation Registry'),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'logout') {
                    await authProvider.logout();
                    if (mounted) {
                      Navigator.of(context).pushReplacementNamed('/auth');
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bloodtype),
            label: 'Donations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: 'Coverages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_support),
            label: 'Contact',
          ),
        ],
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to Blood Donation Registry',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your blood donations and view your history',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _DashboardCard(
                  title: 'My Donations',
                  subtitle: 'View donation history',
                  icon: Icons.bloodtype,
                  color: AppTheme.error,
                  onTap: () {
                    // Navigate to donations tab
                    if (context.findAncestorStateOfType<_HomeScreenState>() != null) {
                      context.findAncestorStateOfType<_HomeScreenState>()!.setState(() {
                        context.findAncestorStateOfType<_HomeScreenState>()!._currentIndex = 1;
                      });
                    }
                  },
                ),
                _DashboardCard(
                  title: 'Coverages',
                  subtitle: 'View blood coverages',
                  icon: Icons.local_hospital,
                  color: AppTheme.success,
                  onTap: () {
                    // Navigate to coverages tab
                    if (context.findAncestorStateOfType<_HomeScreenState>() != null) {
                      context.findAncestorStateOfType<_HomeScreenState>()!.setState(() {
                        context.findAncestorStateOfType<_HomeScreenState>()!._currentIndex = 2;
                      });
                    }
                  },
                ),
                _DashboardCard(
                  title: 'My Profile',
                  subtitle: 'View personal info',
                  icon: Icons.person,
                  color: AppTheme.accent,
                  onTap: () {
                    // Navigate to profile tab
                    if (context.findAncestorStateOfType<_HomeScreenState>() != null) {
                      context.findAncestorStateOfType<_HomeScreenState>()!.setState(() {
                        context.findAncestorStateOfType<_HomeScreenState>()!._currentIndex = 3;
                      });
                    }
                  },
                ),
                _DashboardCard(
                  title: 'Contact Support',
                  subtitle: 'Get help & support',
                  icon: Icons.contact_support,
                  color: AppTheme.warning,
                  onTap: () {
                    // Navigate to contact tab
                    if (context.findAncestorStateOfType<_HomeScreenState>() != null) {
                      context.findAncestorStateOfType<_HomeScreenState>()!.setState(() {
                        context.findAncestorStateOfType<_HomeScreenState>()!._currentIndex = 4;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 32,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
