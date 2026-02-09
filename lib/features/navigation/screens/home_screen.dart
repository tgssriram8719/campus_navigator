import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/navigation_providers.dart';
import '../widgets/floor_plan_viewer.dart';
import 'search_screen.dart';
import 'qr_scanner_screen.dart';
import 'navigation_screen.dart';
import '../../admin/screens/admin_dashboard.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final currentPosition = ref.watch(currentPositionProvider);
    final destination = ref.watch(destinationProvider);
    final isAdminMode = ref.watch(isAdminModeProvider);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(context, isAdminMode),
            
            // Main Content
            Expanded(
              child: _selectedIndex == 0
                  ? _buildHomeContent(context, currentPosition, destination)
                  : _selectedIndex == 1
                      ? const SearchScreen()
                      : const AdminDashboard(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: _selectedIndex == 0 ? _buildFAB(context) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
  
  Widget _buildAppBar(BuildContext context, bool isAdminMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo and Title
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.explore,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Campus Wayfinder',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  isAdminMode ? 'Admin Mode' : 'Indoor Navigation',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isAdminMode ? AppColors.warning : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Admin Toggle
          IconButton(
            onPressed: () {
              ref.read(isAdminModeProvider.notifier).state = !isAdminMode;
            },
            icon: Icon(
              isAdminMode ? Icons.admin_panel_settings : Icons.admin_panel_settings_outlined,
              color: isAdminMode ? AppColors.warning : AppColors.textSecondary,
            ),
            tooltip: isAdminMode ? 'Exit Admin Mode' : 'Enter Admin Mode',
          ),
        ],
      ),
    );
  }
  
  Widget _buildHomeContent(BuildContext context, currentPosition, destination) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Cards Row
          Row(
            children: [
              Expanded(
                child: _StatusCard(
                  icon: Icons.my_location,
                  label: 'Your Location',
                  value: currentPosition?.name ?? 'Scan QR Code',
                  color: AppColors.currentLocation,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QRScannerScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatusCard(
                  icon: Icons.flag,
                  label: 'Destination',
                  value: destination?.name ?? 'Select Location',
                  color: AppColors.destination,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _QuickActionCard(
                  icon: Icons.qr_code_scanner,
                  label: 'Scan QR',
                  color: AppColors.primary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QRScannerScreen()),
                  ),
                ),
                _QuickActionCard(
                  icon: Icons.search,
                  label: 'Find Room',
                  color: AppColors.secondary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  ),
                ),
                _QuickActionCard(
                  icon: Icons.wc,
                  label: 'Restroom',
                  color: const Color(0xFF0EA5E9),
                  onTap: () => _findNearest(context, 'restroom'),
                ),
                _QuickActionCard(
                  icon: Icons.local_library,
                  label: 'Library',
                  color: const Color(0xFF8B5CF6),
                  onTap: () => _navigateTo(context, 'library'),
                ),
                _QuickActionCard(
                  icon: Icons.person,
                  label: 'Principal',
                  color: AppColors.accent,
                  onTap: () => _navigateTo(context, 'principal_office'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Floor Plan Preview
          Text(
            'Campus Map',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          SizedBox(
            height: 300,
            child: FloorPlanViewer(
              showNodes: ref.watch(isAdminModeProvider),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Navigation Button
          if (currentPosition != null && destination != null)
            _buildNavigationButton(context),
            
          const SizedBox(height: 20),
          
          // Recent Locations
          _buildRecentLocations(context),
        ],
      ),
    );
  }
  
  Widget _buildNavigationButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NavigationScreen()),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.navigation,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Start Navigation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildRecentLocations(BuildContext context) {
    final graph = ref.watch(campusGraphProvider);
    final recentNodes = graph.searchableNodes.take(4).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Destinations',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...recentNodes.map((node) => _RecentLocationTile(
          node: node,
          onTap: () {
            ref.read(destinationProvider.notifier).state = node;
          },
        )),
      ],
    );
  }
  
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                isSelected: _selectedIndex == 0,
                onTap: () => setState(() => _selectedIndex = 0),
              ),
              const SizedBox(width: 60), // Space for FAB
              _NavBarItem(
                icon: Icons.search_outlined,
                activeIcon: Icons.search,
                label: 'Search',
                isSelected: _selectedIndex == 1,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QRScannerScreen()),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.qr_code_scanner,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
  
  void _findNearest(BuildContext context, String type) {
    // TODO: Implement find nearest of type
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Finding nearest $type...')),
    );
  }
  
  void _navigateTo(BuildContext context, String nodeId) {
    final graph = ref.read(campusGraphProvider);
    final node = graph.getNode(nodeId);
    if (node != null) {
      ref.read(destinationProvider.notifier).state = node;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Destination set to ${node.name}')),
      );
    }
  }
}

// Supporting Widgets

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;
  
  const _StatusCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        width: 85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : Colors.grey.shade400,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentLocationTile extends ConsumerWidget {
  final dynamic node;
  final VoidCallback onTap;
  
  const _RecentLocationTile({
    required this.node,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: node.type.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            node.type.icon,
            color: node.type.color,
            size: 20,
          ),
        ),
        title: Text(
          node.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Floor ${node.floor}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}
