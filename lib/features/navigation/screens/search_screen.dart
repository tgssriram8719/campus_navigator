import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/navigation_providers.dart';
import '../../../core/models/models.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final graph = ref.watch(campusGraphProvider);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Find Location',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSearchField(context),
                ],
              ),
            ),
            
            // Category Filters
            _buildCategoryFilters(context),
            
            // Results
            Expanded(
              child: _searchController.text.isEmpty
                  ? _buildCategories(context, graph)
                  : _buildSearchResults(context, searchResults),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSearchField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: 'Search rooms, labs, offices...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                    setState(() {});
                  },
                  icon: Icon(Icons.clear, color: Colors.grey.shade400),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
  
  Widget _buildCategoryFilters(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _CategoryChip(label: 'All', isSelected: true, onTap: () {}),
          _CategoryChip(label: 'Rooms', isSelected: false, onTap: () {}),
          _CategoryChip(label: 'Labs', isSelected: false, onTap: () {}),
          _CategoryChip(label: 'Offices', isSelected: false, onTap: () {}),
          _CategoryChip(label: 'Facilities', isSelected: false, onTap: () {}),
        ],
      ),
    );
  }
  
  Widget _buildCategories(BuildContext context, CampusGraph graph) {
    // Group nodes by type
    final nodesByType = <NodeType, List<NavNode>>{};
    for (final node in graph.searchableNodes) {
      nodesByType.putIfAbsent(node.type, () => []).add(node);
    }
    
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Popular Destinations
        _buildSectionHeader(context, 'Popular Destinations'),
        const SizedBox(height: 12),
        _buildPopularGrid(context, graph.searchableNodes.take(6).toList()),
        
        const SizedBox(height: 24),
        
        // Browse by Category
        _buildSectionHeader(context, 'Browse by Category'),
        const SizedBox(height: 12),
        ...nodesByType.entries.map((entry) => _CategorySection(
          type: entry.key,
          nodes: entry.value,
          onNodeTap: (node) => _selectDestination(context, node),
        )),
      ],
    );
  }
  
  Widget _buildPopularGrid(BuildContext context, List<NavNode> nodes) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final node = nodes[index];
        return _PopularCard(
          node: node,
          onTap: () => _selectDestination(context, node),
        );
      },
    );
  }
  
  Widget _buildSearchResults(BuildContext context, List<NavNode> results) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No locations found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final node = results[index];
        return _SearchResultTile(
          node: node,
          searchQuery: _searchController.text,
          onTap: () => _selectDestination(context, node),
        );
      },
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  void _selectDestination(BuildContext context, NavNode node) {
    ref.read(destinationProvider.notifier).state = node;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Destination set to ${node.name}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

// Supporting Widgets

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary.withOpacity(0.1),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : Colors.grey.shade600,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _PopularCard extends StatelessWidget {
  final NavNode node;
  final VoidCallback onTap;
  
  const _PopularCard({
    required this.node,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            node.type.color.withOpacity(0.8),
            node.type.color,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: node.type.color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  node.type.icon,
                  color: Colors.white,
                  size: 28,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Floor ${node.floor}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final NodeType type;
  final List<NavNode> nodes;
  final Function(NavNode) onNodeTap;
  
  const _CategorySection({
    required this.type,
    required this.nodes,
    required this.onNodeTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: type.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(type.icon, color: type.color, size: 20),
        ),
        title: Text(
          '${type.displayName}s',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${nodes.length} locations',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        children: nodes.map((node) => ListTile(
          title: Text(node.name),
          subtitle: Text('Floor ${node.floor}'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => onNodeTap(node),
        )).toList(),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final NavNode node;
  final String searchQuery;
  final VoidCallback onTap;
  
  const _SearchResultTile({
    required this.node,
    required this.searchQuery,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: node.type.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            node.type.icon,
            color: node.type.color,
            size: 24,
          ),
        ),
        title: _buildHighlightedText(node.name, searchQuery),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (node.description != null) ...[
              const SizedBox(height: 4),
              Text(
                node.description!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.layers,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  'Floor ${node.floor}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                if (node.isAccessible) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.accessible,
                    size: 14,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Accessible',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.navigation,
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ),
    );
  }
  
  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      );
    }
    
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final startIndex = lowerText.indexOf(lowerQuery);
    
    if (startIndex == -1) {
      return Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      );
    }
    
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        children: [
          TextSpan(text: text.substring(0, startIndex)),
          TextSpan(
            text: text.substring(startIndex, startIndex + query.length),
            style: TextStyle(
              backgroundColor: AppColors.primary.withOpacity(0.2),
              color: AppColors.primary,
            ),
          ),
          TextSpan(text: text.substring(startIndex + query.length)),
        ],
      ),
    );
  }
}
